#Run this file from the engine-sim-build_0_1_9a directory.
#Only tested with 0.1.9a and the included engines

#first get and display a list of available engines
$engines = Get-ChildItem -Recurse -path .\assets\engines\ -include *.mr

$i = 0
foreach ($engine in $engines)
{
      Write-Output  ("{0} : {1}" -f $i,$engine.Name)
      $i++
}

$choice = read-host "Select an engine"
$choice = $choice -as [int]
$engine = $engines[$choice]

$enginefile = Get-content -raw $engine
$enginefile -match "(?<=public node ).*(?= {[^}]*alias output __out: engine;[^}]*})" | out-null

try {$matches.count -eq 1}
catch { "regex matches != 1"}

$fileimportstring = $engine.FullName -replace '.*\\engines\\',''
$fileimportstring = $fileimportstring -replace '\\','/'
$enginename = $matches.Item(0)

$mainfile = @'
import "engine_sim.mr"
import "themes/default.mr"
import "engines/{0}"

use_default_theme()
set_engine(
    {1}()
)
'@ -f $fileimportstring, $enginename

$mainassetfile = $(Get-Location).Path + "\assets\main.mr"
#Out-File adds a BOM that engine-sim doesn't like, so this doesn't work
#Out-File -FilePath .\assets\main.mr -InputObject $mainfile -Encoding utf8
#but this does.
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($mainassetfile, $mainfile, $Utf8NoBomEncoding)