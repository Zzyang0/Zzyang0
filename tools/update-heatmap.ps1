# Rebuilds assets/heatmap.svg (a pixel "crop field") from the public GitHub contribution calendar.
# Runs locally or on GitHub Actions (PowerShell 7 on ubuntu-latest). No token needed.
#   powershell -ExecutionPolicy Bypass -File tools/update-heatmap.ps1 [-User Zzyang0]
param([string]$User = "Zzyang0", [int]$FromYear = 2020)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
. (Join-Path $PSScriptRoot "px.ps1")
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path (Join-Path $root "assets") "heatmap.svg"
$hdr = @{ "User-Agent" = "Mozilla/5.0" }

# projects: a gold star on the day each one started
$projects = @(
  @{ d = "2022-01-23"; n = "HEALDISH" },
  @{ d = "2022-03-10"; n = "COVID VACCINATION (R)" },
  @{ d = "2022-03-16"; n = "COVID ANALYSIS (PY)" },
  @{ d = "2022-05-10"; n = "DVOGUE" },
  @{ d = "2024-12-19"; n = "CHRONIC DISEASE ML" },
  @{ d = "2025-05-29"; n = "ACCENT RECOGNITION" },
  @{ d = "2025-08-15"; n = "KOBO TO SHAREPOINT" },
  @{ d = "2025-12-22"; n = "MASS SAVE RESEARCH" }
)

# ---- fetch every year ----
$days = [ordered]@{}
for ($y = $FromYear; $y -le (Get-Date).Year; $y++) {
  $html = (Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/users/$User/contributions?from=$y-01-01&to=$y-12-31" -Headers $hdr).Content
  $counts = @{}
  foreach ($m in [regex]::Matches($html, '<tool-tip[^>]*for="([^"]+)"[^>]*>([^<]*)</tool-tip>')) {
    $n = 0
    if ($m.Groups[2].Value -match '^(\d+) contribution') { $n = [int]$Matches[1] }
    $counts[$m.Groups[1].Value] = $n
  }
  foreach ($c in [regex]::Matches($html, '<td[^>]*data-date="[^"]+"[^>]*>')) {
    $tag = $c.Value
    $date = [regex]::Match($tag, 'data-date="([^"]+)"').Groups[1].Value
    $lvl = [int][regex]::Match($tag, 'data-level="(\d)"').Groups[1].Value
    $id = [regex]::Match($tag, ' id="([^"]+)"').Groups[1].Value
    $days["$date"] = @([int]$counts[$id], $lvl)
  }
}
$today = (Get-Date).ToString("yyyy-MM-dd")
$dates = @($days.Keys | Sort-Object | Where-Object { $_ -le $today })
$first = $dates | Where-Object { $days[$_][0] -gt 0 } | Select-Object -First 1
$dates = @($dates | Where-Object { $_.Substring(0, 4) -ge $first.Substring(0, 4) })
$total = ($dates | ForEach-Object { $days[$_][0] } | Measure-Object -Sum).Sum
$active = @($dates | Where-Object { $days[$_][0] -gt 0 }).Count
try { $repos = (Invoke-RestMethod "https://api.github.com/users/$User" -Headers $hdr).public_repos } catch { $repos = "15" }
$yearList = @($dates | ForEach-Object { $_.Substring(0, 4) } | Select-Object -Unique)

# ---- layout: one block per year, two columns ----
$W = 1000; $step = 8; $cell = 6; $blockW = 54 * $step; $colX = @(36, (36 + $blockW + 40))
$rowH = 104; $top0 = 130
$H = $top0 + 3 * $rowH + 34
$colors = @("#2b2150", "#3f7f6a", "#4fb286", "#7fe3b8", "#ffe89a")
$marks = @{}; $i = 0
foreach ($p in $projects) { $i++; $marks[$p.d] = $i }

$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }
A (SvgOpen $W $H "GitHub contributions for $User as a pixel crop field: $total contributions on $active active days, with a star on the day each project started")
A "<rect width=`"$W`" height=`"$H`" fill=`"#1a1333`"/>"

# stat boxes
$stats = @(@("$total", "CONTRIBUTIONS", "#6fe3b0"), @("$active", "ACTIVE DAYS", "#ffc857"), @("$repos", "PUBLIC REPOS", "#5ec8ff"))
for ($k = 0; $k -lt 3; $k++) {
  $bx = 12 + $k * 190
  A (PxPanel $bx 12 178 70 "#6a58a8" "#241a42" 6 3)
  A (PxText $stats[$k][0] ($bx + 18) 26 4 $stats[$k][2])
  A (PxText $stats[$k][1] ($bx + 18) 60 1.6 "#a79bd0")
}
A (PxText "HARVEST = MORE COMMITS" 988 28 1.6 "#a79bd0" "end")
$lx = 988 - 5 * 22
for ($k = 0; $k -lt 5; $k++) { A "<rect x=`"$($lx + $k * 22)`" y=`"50`" width=`"16`" height=`"16`" fill=`"$($colors[$k])`" shape-rendering=`"crispEdges`"/>" }

$star = @(".y.", "yyy", ".y.")
$starMap = @{ y = "#ffc857" }
$slot = 0
foreach ($yr in $yearList) {
  $col = if ($slot -lt 3) { 0 } else { 1 }; $row = $slot % 3; $slot++
  $x0 = $colX[$col]; $y0 = $top0 + $row * $rowH
  $ydates = @($dates | Where-Object { $_.StartsWith($yr) })
  $yt = ($ydates | ForEach-Object { $days[$_][0] } | Measure-Object -Sum).Sum
  A (PxText $yr $x0 ($y0 - 30) 3 "#fff3d6")
  A (PxText "$yt COMMITS" ($x0 + $blockW - 6) ($y0 - 22) 1.6 "#a79bd0" "end")
  $startWd = [int][datetime]::ParseExact($ydates[0], "yyyy-MM-dd", [Globalization.CultureInfo]::InvariantCulture).DayOfWeek
  $bg = New-Object System.Text.StringBuilder; $lv = @(@(), @(), @(), @(), @())
  $lvp = @(); 0..4 | ForEach-Object { $lvp += (New-Object System.Text.StringBuilder) }
  $stars = New-Object System.Text.StringBuilder
  for ($k = 0; $k -lt $ydates.Count; $k++) {
    $d = $ydates[$k]; $wd = ($startWd + $k) % 7; $wk = [math]::Floor(($startWd + $k) / 7)
    $cx = $x0 + $wk * $step; $cy = $y0 + $wd * $step
    $lvl = $days[$d][1]
    [void]$lvp[$lvl].Append("M$cx $($cy)h$($cell)v$($cell)h-$($cell)z")
    if ($marks.ContainsKey($d)) {
      [void]$stars.Append("<g>" + (PxSprite $star $starMap ($cx - 3) ($cy - 3) 4) + "<animate attributeName=`"opacity`" values=`"1;.35;1`" dur=`"1.8s`" repeatCount=`"indefinite`"/></g>")
      [void]$stars.Append((PxText ([string]$marks[$d]) ($cx + 1) ($cy - 14) 1.4 "#ffc857"))
    }
  }
  for ($l = 0; $l -le 4; $l++) { if ($lvp[$l].Length -gt 0) { A "<path d=`"$($lvp[$l].ToString())`" fill=`"$($colors[$l])`" shape-rendering=`"crispEdges`"/>" } }
  A $stars.ToString()
}

# project legend panel (last slot)
$px0 = $colX[1]; $py0 = $top0 + 2 * $rowH - 22
A (PxPanel ($px0 - 8) ($py0) ($blockW + 16) 112 "#3a2f66" "#241a42" 6 3)
A (PxText "STARS = PROJECT STARTED" ($px0 + 6) ($py0 + 12) 1.6 "#ffc857")
$i = 0
foreach ($p in $projects) {
  $c = [math]::Floor($i / 4); $r = $i % 4; $i++
  $ix = $px0 + 6 + $c * 212; $iy = $py0 + 34 + $r * 17
  A (PxText ([string]$i) $ix $iy 1.4 "#ffc857")
  A (PxText $p.n ($ix + 16) $iy 1.4 "#fff3d6")
}
$stamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
A (PxText "REFRESHED DAILY BY GITHUB ACTIONS  -  LAST RUN $stamp" 36 ($H - 20) 1.4 "#a79bd0")
A "</svg>"
[IO.File]::WriteAllText($out, $o.ToString(), (New-Object Text.UTF8Encoding $false))
[xml](Get-Content $out -Raw -Encoding UTF8) | Out-Null
"heatmap: $total contributions, $active active days, $((Get-Item $out).Length) bytes"
