Import-Module -Force $PSScriptRoot/../Source/Docker.Build.psm1
Import-Module -Global -Force $PSScriptRoot/Docker.Build.Tests.psm1
Import-Module -Global -Force $PSScriptRoot/MockReg.psm1

. "$PSScriptRoot\..\Source\Private\CommandResult.ps1"

Describe 'Login failure' {

    Context 'Login failure should not expose sensitive password in the logs' {

        BeforeEach {
            Initialize-MockReg
            $assertExitCodeOkMocked = {
                # Capture the masked command
                StoreMockValue -Key "maskedCommand" -Value $Result.Command
                throw [System.Exception]::new()
            }
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeOne -Verifiable -ModuleName $Global:ModuleName
            Mock -CommandName "Assert-ExitCodeOK" $assertExitCodeOkMocked -Verifiable -ModuleName $Global:ModuleName
        }

        it 'should mask password from the logs when login fails after thrown exception' {
            $loginCode = { Invoke-DockerLogin -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force) }
            $loginCode | Should -Throw -ExceptionType ([System.Exception]) -PassThru
            $result = GetMockValue -Key 'maskedCommand'
            $result | Should -BeExactly 'Write-Output "*********" | docker login --username "Mocked" --password-stdin'
        }
    }
}

Describe 'Docker login ' {

    BeforeEach {
        Initialize-MockReg
        Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName
    }

    Context 'Login to default docker registry' {

        It 'produced the correct command to invoke' {
            Invoke-DockerLogin -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'command'
            $result | Should -BeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin'
        }
    }

    Context 'Login to specific docker registry' {

        It 'produced the correct command to invoke' {
            Invoke-DockerLogin -Registry 'my.docker.registry' -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'command'
            $result | Should -BeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin my.docker.registry'
        }

        It 'produced the correct command to invoke, with $null registry parameter' {
            Invoke-DockerLogin -Registry $null -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force)
            $result = GetMockValue -Key 'command'
            $result | Should -BeExactly 'Write-Output "MockedPassword" | docker login --username "Mocked" --password-stdin'
        }
    }

    Context 'Passthru execution' {

        it 'can redirect output' {
            $tempFile = New-TemporaryFile
            Mock -CommandName "Invoke-Command" $Global:CodeThatReturnsExitCodeZero -Verifiable -ModuleName $Global:ModuleName

            Invoke-DockerLogin -Username "Mocked" -Password (ConvertTo-SecureString 'MockedPassword' –asplaintext –force) -Passthru 6> $tempFile
            $result = Get-Content $tempFile

            $result | Should -Be @('Hello', 'World')
        }
    }
}