# Builds assets/world.svg: a quiet dotted map of the places I have lived, with a tiny paper plane on the route.
#   powershell -ExecutionPolicy Bypass -File tools/make-world.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$W = 1000; $H = 276
$dash = [string][char]0x2013
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }

function TX([double]$x) { 60 + ($x - 50) * 0.875 }
function TY([double]$y) { 40 + ($y - 78) * 0.875 }
function PX0([double]$lon) { $l = if ($lon -lt 0) { $lon + 360 } else { $lon }; 50 + ($l - 100) * 5 }
function PY0([double]$lat) { 78 + (58 - $lat) * 5 }

$cities = @(
  @{ n = "Changhua"; zh = (Z 0x5F70, 0x5316); lat = 24.08; lng = 120.54; when = "born here"; lx = 214; ly = 206; a = "start" },
  @{ n = "Ningbo"; zh = (Z 0x5B81, 0x6CE2); lat = 29.87; lng = 121.54; when = "age 3${dash}18"; lx = 214; ly = 164; a = "start" },
  @{ n = "Seattle"; zh = (Z 0x897F, 0x96C5, 0x56FE); lat = 47.61; lng = -122.33; when = "2020${dash}2024"; lx = 596; ly = 70; a = "end" },
  @{ n = "Berkeley"; zh = (Z 0x4F2F, 0x514B, 0x5229); lat = 37.87; lng = -122.27; when = "2024${dash}2025"; lx = 596; ly = 140; a = "end" },
  @{ n = "New York"; zh = (Z 0x7EBD, 0x7EA6); lat = 40.71; lng = -74.01; when = "2025${dash}2026"; lx = 944; ly = 118; a = "end" },
  @{ n = "Shanghai"; zh = (Z 0x4E0A, 0x6D77); lat = 31.23; lng = 121.47; when = "from Oct 2026"; lx = 214; ly = 112; a = "start" }
)
foreach ($c in $cities) { $c.x = TX (PX0 $c.lng); $c.y = TY (PY0 $c.lat) }
$cn = @{}; foreach ($c in $cities) { $cn[$c.n] = $c }

A (SvgOpen $W $H "Map of the places I have lived: Changhua, Ningbo, Seattle, Berkeley, New York and Shanghai")
A (Card 0 0 $W $H)
A (PxText "FOOTPRINTS" 28 22 2 $T.amber)
A (Txt "six stops so far" 972 30 11.5 $T.dim 400 "end")

# land: small dim squares
$land = Get-Content (Join-Path $PSScriptRoot "land.txt")
$d = New-Object System.Text.StringBuilder
foreach ($l in $land) { $xy = $l.Split(','); $x = [math]::Round((TX ([double]$xy[0])) - 2); $y = [math]::Round((TY ([double]$xy[1])) - 2); [void]$d.Append("M$x $($y)h4v4h-4z") }
A "<path d=`"$($d.ToString())`" fill=`"$($T.land)`" shape-rendering=`"crispEdges`"/>"

# route
function Pt([string]$n) { @($cn[$n].x, $cn[$n].y) }
function TP([double]$x, [double]$y) { @((TX $x), (TY $y)) }
$segs = @(
  @{ t = "L"; p = @((Pt "Changhua"), (Pt "Ningbo")) },
  @{ t = "C"; p = @((Pt "Ningbo"), (TP 290 120), (TP 560 20), (Pt "Seattle")) },
  @{ t = "C"; p = @((Pt "Seattle"), (TP 690 128), (TP 690 150), (Pt "Berkeley")) },
  @{ t = "C"; p = @((Pt "Berkeley"), (TP 820 250), (TP 920 215), (Pt "New York")) },
  @{ t = "C"; p = @((Pt "New York"), (TP 840 10), (TP 380 -4), (Pt "Shanghai")) }
)
$path = "M $(N $segs[0].p[0][0]) $(N $segs[0].p[0][1])"
foreach ($s in $segs) {
  if ($s.t -eq "L") { $path += " L $(N $s.p[1][0]) $(N $s.p[1][1])" }
  else { $path += " C $(N $s.p[1][0]) $(N $s.p[1][1]) $(N $s.p[2][0]) $(N $s.p[2][1]) $(N $s.p[3][0]) $(N $s.p[3][1])" }
}
A "<path id=`"route`" d=`"$path`" fill=`"none`" stroke=`"$($T.amber)`" stroke-opacity=`".75`" stroke-width=`"1.6`" stroke-dasharray=`"3 6`"><animate attributeName=`"stroke-dashoffset`" from=`"0`" to=`"-18`" dur=`"2.4s`" repeatCount=`"indefinite`"/></path>"

# nodes + labels
$i = 0
foreach ($c in $cities) {
  $i++
  $ax = if ($c.a -eq "end") { $c.lx + 4 } else { $c.lx - 4 }
  A "<path d=`"M$(N $c.x) $(N $c.y)L$(N $ax) $(N ($c.ly - 4))`" stroke=`"$($T.line2)`" stroke-width=`"1`"/>"
  A "<rect x=`"$(N ($c.x - 4))`" y=`"$(N ($c.y - 4))`" width=`"8`" height=`"8`" fill=`"$($T.amber)`" shape-rendering=`"crispEdges`"/>"
  A "<rect x=`"$(N ($c.x - 4))`" y=`"$(N ($c.y - 4))`" width=`"8`" height=`"8`" fill=`"none`" stroke=`"$($T.amber)`" stroke-width=`"1.5`" shape-rendering=`"crispEdges`"><animate attributeName=`"opacity`" values=`".9;0`" dur=`"2.4s`" begin=`"$(N ($i * 0.3))s`" repeatCount=`"indefinite`"/><animate attributeName=`"x`" values=`"$(N ($c.x - 4));$(N ($c.x - 11))`" dur=`"2.4s`" begin=`"$(N ($i * 0.3))s`" repeatCount=`"indefinite`"/><animate attributeName=`"y`" values=`"$(N ($c.y - 4));$(N ($c.y - 11))`" dur=`"2.4s`" begin=`"$(N ($i * 0.3))s`" repeatCount=`"indefinite`"/><animate attributeName=`"width`" values=`"8;22`" dur=`"2.4s`" begin=`"$(N ($i * 0.3))s`" repeatCount=`"indefinite`"/><animate attributeName=`"height`" values=`"8;22`" dur=`"2.4s`" begin=`"$(N ($i * 0.3))s`" repeatCount=`"indefinite`"/></rect>"
  $bw = 128
  $bx = if ($c.a -eq "end") { $c.lx - $bw } else { $c.lx }
  A "<rect x=`"$(N ($bx + 0.5))`" y=`"$(N ($c.ly - 16.5))`" width=`"$bw`" height=`"40`" rx=`"8`" fill=`"$($T.bg)`" fill-opacity=`".88`" stroke=`"$($T.line2)`"/>"
  A (PxText ("{0:00}" -f $i) ($bx + 9) ($c.ly - 11) 2 $T.amber)
  A (Txt $c.n ($bx + 40) ($c.ly - 3) 13.5 $T.head 600)
  A (Txt $c.zh ($bx + 40 + [math]::Round($c.n.Length * 7.6) + 6) ($c.ly - 3) 11.5 $T.mute 400)
  A (Txt $c.when ($bx + 40) ($c.ly + 13) 11.5 $T.mute 400)
}

# tiny pixel paper plane flying the route
$plane = @("..a......", "..aa.....", "aaaaaaa..", ".aaaaaaa.", "aaaaaaa..", "..aa.....", "..a......")
A "<g><g transform=`"translate(-9 -7)`">$(PxSprite $plane @{ a = "#f0f6fc" } 0 0 2)</g><animateMotion dur=`"34s`" repeatCount=`"indefinite`" rotate=`"auto`"><mpath xlink:href=`"#route`"/></animateMotion></g>"
A "</svg>"
SaveSvg (Join-Path (Join-Path $root "assets") "world.svg") $o.ToString()
