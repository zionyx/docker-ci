function Invoke-DockerTag {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $Registry = '',

        [Parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $ImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag = 'latest',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewRegistry = '',

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $NewImageName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NewTag = 'latest',

        [Switch]
        $PassThru
    )

    $postfixedRegistry = Add-Postfix -Value $Registry
    $postfixedNewRegistry = Add-Postfix -Value $NewRegistry
    $source = "${postfixedRegistry}${ImageName}:${Tag}"
    $target = "${postfixedNewRegistry}${NewImageName}:${NewTag}"

    $commandResult = Invoke-Command "docker tag ${source} ${target}"
    Assert-ExitCodeOk $commandResult
    $result = [PSCustomObject]@{
        'Tag'           = $NewTag
        'ImageName'     = $NewImageName
        'Registry'      = $postfixedNewRegistry
        'CommandResult' = $commandResult
    }
    if ($PassThru) {
        Write-PassThruOuput $($commandResult.Output)
    }
    return $result
}