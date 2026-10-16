[CmdletBinding()]
param(
    [Parameter()]
    [string] $Path
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Path)) {
    $repositoryRoot = Split-Path -Parent $PSScriptRoot
    $Path = Join-Path $repositoryRoot 'config/server.json'
}

try {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Configuration file not found: '$Path'."
    }

    $jsonText = Get-Content -LiteralPath $Path -Raw
    try {
        $config = ConvertFrom-Json -InputObject $jsonText -ErrorAction Stop
    }
    catch {
        throw "Invalid JSON in '$Path': $($_.Exception.Message)"
    }

    if ($null -eq $config -or $config -isnot [System.Management.Automation.PSCustomObject]) {
        throw 'The JSON root must be an object.'
    }

    $properties = @{}
    foreach ($property in $config.PSObject.Properties) {
        $properties[$property.Name] = $property.Value
    }

    foreach ($requiredName in @('serverName', 'maxPlayers', 'loggingEnabled')) {
        if (-not $properties.ContainsKey($requiredName)) {
            throw "Missing required field '$requiredName'."
        }
    }

    if ($properties.serverName -isnot [string] -or [string]::IsNullOrWhiteSpace($properties.serverName)) {
        throw "Field 'serverName' must be a non-empty string."
    }

    $maxPlayers = $properties.maxPlayers
    if ($maxPlayers -isnot [byte] -and $maxPlayers -isnot [int16] -and $maxPlayers -isnot [int32] -and $maxPlayers -isnot [int64]) {
        throw "Field 'maxPlayers' must be an integer."
    }
    if ($maxPlayers -lt 1 -or $maxPlayers -gt 64) {
        throw "Field 'maxPlayers' must be in the range 1 to 64."
    }

    if ($properties.loggingEnabled -isnot [bool]) {
        throw "Field 'loggingEnabled' must be a JSON boolean (true or false)."
    }

    if ($properties.ContainsKey('logLevel')) {
        $logLevel = $properties.logLevel
        if ($logLevel -isnot [string]) {
            throw "Field 'logLevel' must be a string."
        }
        if ($logLevel -cnotin @('debug', 'info', 'warn', 'error')) {
            throw "Invalid 'logLevel' value: '$logLevel'. Allowed values: debug, info, warn, error."
        }
    }

    Write-Output "Configuration '$Path' is valid."
    exit 0
}
catch {
    Write-Output "Configuration validation failed: $($_.Exception.Message)"
    exit 1
}
