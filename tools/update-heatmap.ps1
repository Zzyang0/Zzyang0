# Rebuilds assets/heatmap.svg from the public GitHub contribution calendar (one pixel block per year).
# Runs locally or on GitHub Actions (PowerShell 7 on ubuntu-latest). No token needed.
#   powershell -ExecutionPolicy Bypass -File tools/update-heatmap.ps1 [-User Zzyang0]
param([string]$User = "Zzyang0", [int]$FromYear = 2020)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
. (Join-Path $PSScriptRoot "px.ps1")
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path (Join-Path $root "assets") "heatmap.svg"
$hdr = @{ "User-Agent" = "Mozilla/5.0" }
$dot = [string][char]0x00B7

# projects: a small marker on the day each one started
$projects = @(
  @{ d = "2022-01-23"; n = "HealDish" },
  @{ d = "2022-03-10"; n = "COVID vaccination (R)" },
  @{ d = "2022-03-16"; n = "COVID analysis (Python)" },
  @{ d = "2022-05-10"; n = "Dvogue" },
  @{ d = "2024-12-19"; n = "Chronic disease ML" },
  @{ d = "2025-05-29"; n = "AccentRecognition" },
  @{ d = "2025-08-15"; n = "Kobo to SharePoint" },
  @{ d = "2025-12-22"; n = "Mass Save research" }
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
$W = 1000; $step = 8; $cell = 6; $blockW = 54 * $step; $colX = @(28, (28 + $blockW + 44))
$rowH = 94; $top0 = 92
$H = $top0 + 3 * $rowH + 26
$colors = @("#1b2433", "#4a3a1e", "#8a6320", "#d99a33", "#ffb454")
$marks = @{}; $i = 0
foreach ($p in $projects) { $i++; $marks[$p.d] = $i }

$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }
A (SvgOpen $W $H "GitHub contributions for $User by year: $total contributions on $active active days, with a marker on the day each project started")
A (Card 0 0 $W $H)
A (PxText "CONTRIBUTIONS" 28 22 2 $T.amber)
A (Txt "$total contributions $dot $active active days $dot $repos public repos" 972 30 12.5 $T.mute 400 "end")
A "<path d=`"M28 52H972`" stroke=`"$($T.line)`"/>"

$star = @(".a.", "aaa", ".a.")
$slot = 0
foreach ($yr in $yearList) {
  $col = if ($slot -lt 3) { 0 } else { 1 }; $row = $slot % 3; $slot++
  $x0 = $colX[$col]; $y0 = $top0 + $row * $rowH
  $ydates = @($dates | Where-Object { $_.StartsWith($yr) })
  $yt = ($ydates | ForEach-Object { $days[$_][0] } | Measure-Object -Sum).Sum
  A (Txt $yr $x0 ($y0 - 14) 14 $T.head 600)
  A (Txt "$yt" ($x0 + $blockW - 6) ($y0 - 14) 12 $T.mute 400 "end")
  $startWd = [int][datetime]::ParseExact($ydates[0], "yyyy-MM-dd", [Globalization.CultureInfo]::InvariantCulture).DayOfWeek
  $lvp = @(); 0..4 | ForEach-Object { $lvp += (New-Object System.Text.StringBuilder) }
  $stars = New-Object System.Text.StringBuilder
  for ($k = 0; $k -lt $ydates.Count; $k++) {
    $d = $ydates[$k]; $wd = ($startWd + $k) % 7; $wk = [math]::Floor(($startWd + $k) / 7)
    $cx = $x0 + $wk * $step; $cy = $y0 + $wd * $step
    [void]$lvp[$days[$d][1]].Append("M$cx $($cy)h$($cell)v$($cell)h-$($cell)z")
    if ($marks.ContainsKey($d)) {
      [void]$stars.Append("<g>" + (PxSprite $star @{ a = "#f0f6fc" } ($cx - 3) ($cy - 3) 4) + "<animate attributeName=`"opacity`" values=`"1;.4;1`" dur=`"2.2s`" repeatCount=`"indefinite`"/></g>")
      [void]$stars.Append((Txt ([string]$marks[$d]) ($cx + 3) ($cy - 6) 9.5 $T.mute 400 "middle"))
    }
  }
  for ($l = 0; $l -le 4; $l++) { if ($lvp[$l].Length -gt 0) { A "<path d=`"$($lvp[$l].ToString())`" fill=`"$($colors[$l])`" shape-rendering=`"crispEdges`"/>" } }
  A $stars.ToString()
}

# legend (last slot): which marker is which project
$px0 = $colX[1]; $py0 = $top0 + 2 * $rowH - 28
A (Txt "markers = project started" $px0 $py0 11.5 $T.dim 400)
$i = 0
foreach ($p in $projects) {
  $c = [math]::Floor($i / 4); $r = $i % 4; $i++
  $ix = $px0 + $c * 214; $iy = $py0 + 20 + $r * 17
  A (Txt ([string]$i) $ix $iy 11.5 $T.amber 600)
  A (Txt $p.n ($ix + 16) $iy 11.5 "#c3cedb" 400)
}
$stamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
A (Txt "refreshed daily by GitHub Actions, last run $stamp" 28 ($H - 11) 11 $T.dim 400)
A "<g>"; $lx = 972 - 5 * 14
for ($k = 0; $k -lt 5; $k++) { A "<rect x=`"$($lx + $k * 14)`" y=`"$($H - 19)`" width=`"8`" height=`"8`" fill=`"$($colors[$k])`" shape-rendering=`"crispEdges`"/>" }
A "</g></svg>"
[IO.File]::WriteAllText($out, $o.ToString(), (New-Object Text.UTF8Encoding $false))
$xd = New-Object Xml.XmlDocument; $xd.Load($out)
"heatmap: $total contributions, $active active days, $((Get-Item $out).Length) bytes"
