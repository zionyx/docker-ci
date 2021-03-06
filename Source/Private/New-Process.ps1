function New-Process {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = 'true')]
        [String] $Command,

        [String] $Arguments = '',

        [ValidateNotNullOrEmpty()]
        [String] $WorkingDirectory = (Get-Location),

        [Switch]
        $RedirectStdIn
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Command
    $startInfo.Arguments = $Arguments

    $startInfo.UseShellExecute = $false
    $startInfo.WorkingDirectory = $WorkingDirectory

    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    if ($RedirectStdIn) {
        $startInfo.RedirectStandardInput = $true
    }

    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    return $process
}
