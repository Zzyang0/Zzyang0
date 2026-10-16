# Builds assets/footprints.svg: a dotted world map (Pacific-centred) with the route of the places I've lived.
# One-off generator; needs a land-mask PNG (equirectangular, land = dark).  Usage:
#   powershell -ExecutionPolicy Bypass -File tools/make-footprints.ps1 -Mask <earth-water.png>
param([Parameter(Mandatory = $true)][string]$Mask)

Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root "assets\footprints.svg"
$inv = [Globalization.CultureInfo]::InvariantCulture
function F([double]$n) { $n.ToString("0.#", $inv) }
function Z([int[]]$cp) { -join ($cp | ForEach-Object { [char]$_ }) }   # Chinese names from code points, so this file stays pure ASCII

# ---- projection: lon 100..300 (100E .. 60W), lat 12..58 ----
$S = 5.0; $OX = 50; $OY = 78
function PX([double]$lon) { $l = if ($lon -lt 0) { $lon + 360 } else { $lon }; $script:OX + ($l - 100) * $script:S }
function PY([double]$lat) { $script:OY + (58 - $lat) * $script:S }

$cities = @(
  @{ n = "Changhua"; z = (Z 0x5F70,0x5316); lat = 24.08; lng = 120.54; when = "born here"; c = "#ff3d8b" },
  @{ n = "Ningbo"; z = (Z 0x5B81,0x6CE2); lat = 29.87; lng = 121.54; when = "age 3 to 18"; c = "#3ee6e0" },
  @{ n = "Seattle"; z = (Z 0x897F,0x96C5,0x56FE); lat = 47.61; lng = -122.33; when = "2020 to 2024"; c = "#f4e04d" },
  @{ n = "Berkeley"; z = (Z 0x4F2F,0x514B,0x5229); lat = 37.87; lng = -122.27; when = "2024 to 2025"; c = "#3ee6e0" },
  @{ n = "New York"; z = (Z 0x7EBD,0x7EA6); lat = 40.71; lng = -74.01; when = "2025 to 2026"; c = "#ff3d8b" },
  @{ n = "Shanghai"; z = (Z 0x4E0A,0x6D77); lat = 31.23; lng = 121.47; when = "from Oct 2026"; c = "#f4e04d" }
)
foreach ($c in $cities) { $c.x = PX $c.lng; $c.y = PY $c.lat }

# ---- land dots ----
$bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $Mask).Path)
$dots = New-Object System.Text.StringBuilder
$count = 0
for ($lp = 100.0; $lp -lt 300.0; $lp += 1.6) {
  for ($lat = 12.0; $lat -le 58.0; $lat += 1.6) {
    $lon = if ($lp -gt 180) { $lp - 360 } else { $lp }
    $u = [int][Math]::Min($bmp.Width - 1, [Math]::Floor(($lon + 180) / 360 * $bmp.Width))
    $v = [int][Math]::Min($bmp.Height - 1, [Math]::Floor((90 - $lat) / 180 * $bmp.Height))
    if ($bmp.GetPixel($u, $v).R -lt 110) {
      [void]$dots.Append("<circle cx=`"$(F (PX $lon))`" cy=`"$(F (PY $lat))`" r=`"1.7`"/>")
      $count++
    }
  }
}
$bmp.Dispose()

# ---- route ----
$c = @{}; foreach ($x in $cities) { $c[$x.n] = $x }
function P($n) { "$(F $c[$n].x),$(F $c[$n].y)" }
$route = "M $(P 'Changhua') L $(P 'Ningbo') " +
  "C 290,120 560,20 $(P 'Seattle') " +
  "C 690,128 690,150 $(P 'Berkeley') " +
  "C 820,250 920,215 $(P 'New York') " +
  "C 840,10 380,-4 $(P 'Shanghai')"

# ---- labels: (city) -> label position + anchor ----
$labels = @{
  "Changhua" = @{ lx = 232; ly = 276; a = "start" }
  "Ningbo"   = @{ lx = 232; ly = 232; a = "start" }
  "Shanghai" = @{ lx = 232; ly = 186; a = "start" }
  "Seattle"  = @{ lx = 704; ly = 152; a = "end" }
  "Berkeley" = @{ lx = 704; ly = 214; a = "end" }
  "New York" = @{ lx = 1050; ly = 206; a = "end" }
}
$nodes = New-Object System.Text.StringBuilder
$i = 0
foreach ($ct in $cities) {
  $i++
  $L = $labels[$ct.n]
  $num = "{0:00}" -f $i
  $anchorDx = if ($L.a -eq "end") { 8 } else { -8 }
  [void]$nodes.Append("<line x1=`"$(F $ct.x)`" y1=`"$(F $ct.y)`" x2=`"$(F ($L.lx + $anchorDx))`" y2=`"$(F ($L.ly - 4))`" class=`"lead`"/>")
  [void]$nodes.Append("<circle cx=`"$(F $ct.x)`" cy=`"$(F $ct.y)`" r=`"4`" fill=`"$($ct.c)`" class=`"node`"/>")
  [void]$nodes.Append("<circle cx=`"$(F $ct.x)`" cy=`"$(F $ct.y)`" r=`"4`" fill=`"none`" stroke=`"$($ct.c)`" stroke-width=`"1.5`"><animate attributeName=`"r`" values=`"4;15`" dur=`"2.4s`" begin=`"$(F ($i * 0.35))s`" repeatCount=`"indefinite`"/><animate attributeName=`"opacity`" values=`"0.9;0`" dur=`"2.4s`" begin=`"$(F ($i * 0.35))s`" repeatCount=`"indefinite`"/></circle>")
  [void]$nodes.Append("<text x=`"$($L.lx)`" y=`"$($L.ly)`" text-anchor=`"$($L.a)`" class=`"lbl`"><tspan fill=`"$($ct.c)`" font-weight=`"700`">$num</tspan> $($ct.n) <tspan class=`"zh`">$($ct.z)</tspan></text>")
}

# ---- bottom timeline cards ----
$cards = New-Object System.Text.StringBuilder
$cw = 160; $gap = 12; $cx0 = 50; $cy0 = 352
$i = 0
foreach ($ct in $cities) {
  $x = $cx0 + $i * ($cw + $gap); $i++
  [void]$cards.Append("<g transform=`"translate($x,$cy0)`"><rect width=`"$cw`" height=`"54`" rx=`"4`" class=`"card`"/><rect width=`"$cw`" height=`"3`" fill=`"$($ct.c)`"/><text x=`"12`" y=`"24`" class=`"cn`">$('{0:00}' -f $i)  $($ct.n)</text><text x=`"12`" y=`"43`" class=`"cw`">$($ct.when)</text></g>")
}

$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1100 430" width="1100" height="430" role="img" aria-label="Map of the places I have lived: Changhua, Ningbo, Seattle, Berkeley, New York and Shanghai">
<defs>
  <style>
    text { font-family: Consolas, "SF Mono", Menlo, "Courier New", monospace; }
    .bg { fill: #05080b; stroke: rgba(62,230,224,.28); }
    .ttl { fill: #f2f7f8; font-size: 20px; font-weight: 700; letter-spacing: 3px; }
    .sub { fill: #7794a0; font-size: 12px; }
    .lbl { fill: #cfe0e6; font-size: 13px; }
    .zh { fill: #7794a0; font-size: 12px; }
    .lead { stroke: rgba(207,224,230,.35); stroke-width: 1; stroke-dasharray: 2 3; }
    .land { fill: #3ee6e0; opacity: .6; }
    .flow { fill: none; stroke: #f4e04d; stroke-width: 1.8; stroke-dasharray: 5 7; stroke-linecap: round; animation: flow 1.2s linear infinite; }
    .glow { fill: none; stroke: #3ee6e0; stroke-width: 6; opacity: .12; }
    @keyframes flow { to { stroke-dashoffset: -12; } }
    .card { fill: #0b161c; stroke: rgba(62,230,224,.22); }
    .cn { fill: #ffffff; font-size: 13px; font-weight: 700; }
    .cw { fill: #7794a0; font-size: 11.5px; }
    .dot { fill: #3dff8a; animation: blink 1.6s steps(1) infinite; }
    @keyframes blink { 50% { opacity: .25; } }
  </style>
  <pattern id="grid" width="25" height="25" patternUnits="userSpaceOnUse"><path d="M25 0H0V25" fill="none" stroke="rgba(120,220,230,.05)"/></pattern>
  <radialGradient id="halo" cx="50%" cy="45%" r="60%"><stop offset="0" stop-color="#3ee6e0" stop-opacity=".10"/><stop offset="1" stop-color="#3ee6e0" stop-opacity="0"/></radialGradient>
  <filter id="soft"><feGaussianBlur stdDeviation="2.2"/></filter>
</defs>
<rect class="bg" x=".5" y=".5" width="1099" height="429" rx="10"/>
<rect x="1" y="1" width="1098" height="428" rx="10" fill="url(#grid)"/>
<rect x="1" y="1" width="1098" height="428" rx="10" fill="url(#halo)"/>
<circle cx="52" cy="38" r="5" class="dot"/>
<text x="68" y="44" class="ttl">FOOTPRINTS</text>
<text x="1050" y="44" text-anchor="end" class="sub">SELECT city, when FROM footprints ORDER BY arrived;</text>
<g class="land">$($dots.ToString())</g>
<path d="$route" class="glow" filter="url(#soft)"/>
<path id="route" d="$route" class="flow"/>
$($nodes.ToString())
<g>
  <path d="M7,0 L-6,-5 L-3,0 L-6,5 Z" fill="#f2f7f8"><animateMotion dur="20s" repeatCount="indefinite" rotate="auto"><mpath xlink:href="#route"/></animateMotion></path>
</g>
$($cards.ToString())
</svg>
"@
[IO.File]::WriteAllText($out, $svg, (New-Object Text.UTF8Encoding $false))
"land dots: $count | svg bytes: $((Get-Item $out).Length) | $out"
