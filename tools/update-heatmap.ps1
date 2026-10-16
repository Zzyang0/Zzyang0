# Rebuilds assets/heatmap.svg from the public GitHub contribution calendar.
# Runs locally or on GitHub Actions (PowerShell 7 on ubuntu-latest). No token needed.
#   powershell -ExecutionPolicy Bypass -File tools/update-heatmap.ps1 [-User Zzyang0]
param([string]$User = "Zzyang0", [int]$FromYear = 2020)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root "assets\heatmap.svg"
$inv = [Globalization.CultureInfo]::InvariantCulture
$hdr = @{ "User-Agent" = "Mozilla/5.0" }

# projects: a yellow diamond on the day each one started
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
$years = [ordered]@{}
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
    $years["$date"] = @([int]$counts[$id], $lvl)
  }
}
$today = (Get-Date).ToString("yyyy-MM-dd")
$dates = @($years.Keys | Sort-Object | Where-Object { $_ -le $today })
$first = $dates | Where-Object { $years[$_][0] -gt 0 } | Select-Object -First 1
$dates = @($dates | Where-Object { $_.Substring(0, 4) -ge $first.Substring(0, 4) })
$total = ($dates | ForEach-Object { $years[$_][0] } | Measure-Object -Sum).Sum
$active = @($dates | Where-Object { $years[$_][0] -gt 0 }).Count
try { $repos = (Invoke-RestMethod "https://api.github.com/users/$User" -Headers $hdr).public_repos } catch { $repos = "13" }

# ---- layout ----
$W = 1100; $left = 44; $avail = $W - 2 * $left
$startWd = [int][datetime]::ParseExact($dates[0], "yyyy-MM-dd", $inv).DayOfWeek
$weeks = [math]::Floor(($startWd + $dates.Count - 1) / 7) + 1
$gap = 1
$cell = [math]::Max(2, [math]::Floor($avail / $weeks) - $gap)
$step = $cell + $gap
$stripY = 118
$colors = @("rgba(120,220,230,.07)", "rgba(62,230,224,.30)", "rgba(62,230,224,.52)", "rgba(62,230,224,.76)", "#7be9b8")
$marks = @{}; $i = 0
foreach ($p in $projects) { $i++; $marks[$p.d] = $i }

$cells = New-Object System.Text.StringBuilder
$yearLabels = New-Object System.Text.StringBuilder
$diamonds = New-Object System.Text.StringBuilder
$lastYear = ""
for ($k = 0; $k -lt $dates.Count; $k++) {
  $d = $dates[$k]; $wd = ($startWd + $k) % 7; $wk = [math]::Floor(($startWd + $k) / 7)
  $x = $left + $wk * $step; $y = $stripY + $wd * $step
  $yr = $d.Substring(0, 4)
  if ($yr -ne $lastYear) {
    $lastYear = $yr
    $yt = ($dates | Where-Object { $_.StartsWith($yr) } | ForEach-Object { $years[$_][0] } | Measure-Object -Sum).Sum
    [void]$yearLabels.Append("<line x1=`"$x`" y1=`"74`" x2=`"$x`" y2=`"$($stripY + 7 * $step)`" class=`"yl`"/><text x=`"$($x + 6)`" y=`"88`" class=`"yr`">$yr</text><text x=`"$($x + 6 + 44)`" y=`"88`" class=`"yc`">$yt</text>")
  }
  $lvl = $years[$d][1]
  if ($marks.ContainsKey($d)) {
    $cx = $x + $cell / 2; $cy = $y + $cell / 2
    [void]$diamonds.Append("<path d=`"M$($cx.ToString('0.#',$inv)),$(($cy-5).ToString('0.#',$inv)) L$(($cx+5).ToString('0.#',$inv)),$($cy.ToString('0.#',$inv)) L$($cx.ToString('0.#',$inv)),$(($cy+5).ToString('0.#',$inv)) L$(($cx-5).ToString('0.#',$inv)),$($cy.ToString('0.#',$inv)) Z`" fill=`"#f4e04d`" class=`"dm`"/>")
    $num = $marks[$d]; $ty = if ($num % 2) { 108 } else { 99 }
    [void]$diamonds.Append("<text x=`"$($cx.ToString('0.#',$inv))`" y=`"$ty`" text-anchor=`"middle`" class=`"mk`">$num</text>")
  } elseif ($lvl -gt 0) {
    [void]$cells.Append("<rect x=`"$x`" y=`"$y`" width=`"$cell`" height=`"$cell`" fill=`"$($colors[$lvl])`"/>")
  }
}

# legend (project list), wraps over two rows
$legend = New-Object System.Text.StringBuilder
$lx = $left; $ly = $stripY + 7 * $step + 34; $i = 0
foreach ($p in $projects) {
  $i++
  $itemW = 28 + $p.n.Length * 7.3 + 22
  if ($lx + $itemW -gt $W - $left) { $lx = $left; $ly += 24 }
  [void]$legend.Append("<g transform=`"translate($lx,$ly)`"><path d=`"M6,-5 L11,0 L6,5 L1,0 Z`" fill=`"#f4e04d`"/><text x=`"18`" y=`"4`" class=`"lg`"><tspan fill=`"#f4e04d`" font-weight=`"700`">$i</tspan> $($p.n)</text></g>")
  $lx += $itemW
}
$H = $ly + 62
$stamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
$legendY = $stripY + 7 * $step + 14

$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $W $H" width="$W" height="$H" role="img" aria-label="GitHub contribution heatmap for $User, $total contributions on $active active days, with project start dates marked">
<defs>
  <style>
    text { font-family: Consolas, "SF Mono", Menlo, "Courier New", monospace; }
    .bg { fill: #05080b; stroke: rgba(62,230,224,.28); }
    .ttl { fill: #f2f7f8; font-size: 19px; font-weight: 700; letter-spacing: 3px; }
    .sub { fill: #7794a0; font-size: 12.5px; }
    .stat { fill: #3ee6e0; font-size: 13px; font-weight: 700; }
    .yr { fill: #ffffff; font-size: 15px; font-weight: 800; }
    .yc { fill: #7794a0; font-size: 11.5px; }
    .yl { stroke: rgba(120,220,230,.28); stroke-dasharray: 2 3; }
    .lg { fill: #cfe0e6; font-size: 12px; }
    .mk { fill: #f4e04d; font-size: 10px; font-weight: 800; }
    .dm { animation: pop 2.6s ease-in-out infinite; transform-box: fill-box; transform-origin: center; }
    @keyframes pop { 50% { transform: scale(1.35); } }
    .dot { fill: #3dff8a; animation: blink 1.6s steps(1) infinite; }
    @keyframes blink { 50% { opacity: .25; } }
  </style>
  <pattern id="grid" width="25" height="25" patternUnits="userSpaceOnUse"><path d="M25 0H0V25" fill="none" stroke="rgba(120,220,230,.05)"/></pattern>
  <pattern id="empty" x="$left" y="$stripY" width="$step" height="$step" patternUnits="userSpaceOnUse"><rect width="$cell" height="$cell" fill="rgba(120,220,230,.07)"/></pattern>
</defs>
<rect class="bg" x=".5" y=".5" width="$($W - 1)" height="$($H - 1)" rx="10"/>
<rect x="1" y="1" width="$($W - 2)" height="$($H - 2)" rx="10" fill="url(#grid)"/>
<circle cx="62" cy="38" r="5" class="dot"/>
<text x="82" y="44" class="ttl">CONTRIBUTIONS</text>
<text x="$($W - 50)" y="36" text-anchor="end" class="stat">$total contributions &#183; $active active days &#183; $repos public repos</text>
<text x="$($W - 50)" y="54" text-anchor="end" class="sub">SELECT * FROM contributions WHERE user = '$User';</text>
<rect x="$left" y="$stripY" width="$($weeks * $step)" height="$(7 * $step)" fill="url(#empty)"/>
$($yearLabels.ToString())
$($cells.ToString())
$($diamonds.ToString())
<text x="$left" y="$legendY" class="sub">project started on this day:</text>
$($legend.ToString())
<text x="$($W - 50)" y="$($H - 16)" text-anchor="end" class="sub">refreshed daily by GitHub Actions &#183; last run $stamp</text>
<g transform="translate($left,$($H - 20))"><text class="sub">less</text><g transform="translate(30,-9)">$(0..4 | ForEach-Object { "<rect x=`"$($_ * 14)`" width=`"10`" height=`"10`" fill=`"$($colors[$_])`"/>" })</g><text x="108" class="sub">more</text></g>
</svg>
"@
[IO.File]::WriteAllText($out, $svg, (New-Object Text.UTF8Encoding $false))
"heatmap: $total contributions, $active active days, weeks $weeks, cell $cell, $((Get-Item $out).Length) bytes"
