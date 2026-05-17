$root = Resolve-Path "$PSScriptRoot\..\.."
cjpm build --path "$PSScriptRoot"
Copy-Item -Force "$root\bridge.dll" "$PSScriptRoot\target\release\bin\"
& "$PSScriptRoot\target\release\bin\main.exe"
