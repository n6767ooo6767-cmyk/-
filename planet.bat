@echo off
setlocal
title Rotating Planet

set "PSFILE=%TEMP%\rotating_planet_%RANDOM%.ps1"

for /f "tokens=1 delims=:" %%A in ('findstr /n /b "#PSCODE" "%~f0"') do set "LINE=%%A"
set /a LINE-=1

more +%LINE% "%~f0" > "%PSFILE%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

del "%PSFILE%" >nul 2>&1
exit /b

#PSCODE
$Host.UI.RawUI.WindowTitle = "ROTATING PLANET"
$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(90,45)
$Host.UI.RawUI.WindowSize = New-Object Management.Automation.Host.Size(90,45)
[Console]::CursorVisible = $false

$width = 70
$height = 32
$radius = 15
$angle = 0

$chars = " .:-=+*#%@"

while ($true) {

    $out = New-Object System.Collections.Generic.List[string]

    for ($y = -$radius; $y -le $radius; $y++) {

        $line = ""

        for ($x = -$radius; $x -le $radius; $x++) {

            $nx = $x / $radius
            $ny = $y / $radius

            if (($nx * $nx + $ny * $ny) -gt 1) {
                $line += " "
                continue
            }

            $nz = [Math]::Sqrt([Math]::Max(0, 1 - $nx*$nx - $ny*$ny))

            # Вращение планеты
            $lon = [Math]::Atan2($nz, $nx) + $angle
            $lat = [Math]::Asin($ny)

            # Освещение
            $lx = -0.45
            $ly = -0.35
            $lz = 0.82

            $light = $nx*$lx + $ny*$ly + $nz*$lz

            if ($light -lt 0) {
                $line += " "
                continue
            }

            # Процедурные "материки"
            $land = 0

            $land += [Math]::Sin($lon * 2.7 + 0.8) *
                     [Math]::Cos($lat * 3.1)

            $land += 0.55 * [Math]::Sin($lon * 5.2 - $lat * 2.3)

            $land += 0.30 * [Math]::Cos($lon * 9.0 + $lat * 6.0)

            $land += 0.20 * [Math]::Sin($lon * 15.0 - $lat * 8.0)

            if ($land -gt 0.55) {
                # Материк
                $brightness = [Math]::Max(0, [Math]::Min(1, $light))

                if ($brightness -gt 0.75) {
                    $char = "@"
                }
                elseif ($brightness -gt 0.50) {
                    $char = "#"
                }
                elseif ($brightness -gt 0.30) {
                    $char = "*"
                }
                else {
                    $char = "+"
                }
            }
            else {
                # Океан
                $brightness = [Math]::Max(0, [Math]::Min(1, $light))

                if ($brightness -gt 0.80) {
                    $char = "."
                }
                elseif ($brightness -gt 0.55) {
                    $char = ":"
                }
                elseif ($brightness -gt 0.30) {
                    $char = "-"
                }
                else {
                    $char = " "
                }
            }

            $line += $char
        }

        $out.Add($line)
    }

    [Console]::SetCursorPosition(0,0)

    foreach ($line in $out) {
        [Console]::WriteLine($line.PadRight($width))
    }

    [Console]::WriteLine("")
    [Console]::WriteLine("                  ROTATING PLANET")
    [Console]::WriteLine("                    Ctrl+C = exit")

    $angle += 0.12
    Start-Sleep -Milliseconds 50
}
