# Builds assets/world.svg: a pixel overworld map of the places I have lived, with a little player walking the route.
#   powershell -ExecutionPolicy Bypass -File tools/make-world.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$W = 1000; $H = 392
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }

# old projection (lon 100..300, lat 12..58) -> this canvas, 7px pitch
function TX([double]$x) { 60 + ($x - 50) * 0.875 }
function TY([double]$y) { 46 + ($y - 78) * 0.875 }
function PX0([double]$lon) { $l = if ($lon -lt 0) { $lon + 360 } else { $lon }; 50 + ($l - 100) * 5 }
function PY0([double]$lat) { 78 + (58 - $lat) * 5 }

$cities = @(
  @{ n = "CHANGHUA"; zh = (Z 0x5F70, 0x5316); lat = 24.08; lng = 120.54; when = "BORN HERE"; c = "#ff5d8f"; lx = 219; ly = 223; a = "start" },
  @{ n = "NINGBO"; zh = (Z 0x5B81, 0x6CE2); lat = 29.87; lng = 121.54; when = "AGE 3 TO 18"; c = "#5ec8ff"; lx = 219; ly = 185; a = "start" },
  @{ n = "SEATTLE"; zh = (Z 0x897F, 0x96C5, 0x56FE); lat = 47.61; lng = -122.33; when = "2020 TO 2024"; c = "#ffc857"; lx = 596; ly = 100; a = "end" },
  @{ n = "BERKELEY"; zh = (Z 0x4F2F, 0x514B, 0x5229); lat = 37.87; lng = -122.27; when = "2024 TO 2025"; c = "#b9a2ff"; lx = 596; ly = 168; a = "end" },
  @{ n = "NEW YORK"; zh = (Z 0x7EBD, 0x7EA6); lat = 40.71; lng = -74.01; when = "2025 TO 2026"; c = "#ff9a5c"; lx = 940; ly = 150; a = "end" },
  @{ n = "SHANGHAI"; zh = (Z 0x4E0A, 0x6D77); lat = 31.23; lng = 121.47; when = "FROM OCT 2026"; c = "#6fe3b0"; lx = 219; ly = 142; a = "start" }
)
foreach ($c in $cities) { $c.x = TX (PX0 $c.lng); $c.y = TY (PY0 $c.lat) }
$cn = @{}; foreach ($c in $cities) { $cn[$c.n] = $c }

A (SvgOpen $W $H "Pixel world map of the places I have lived: Changhua, Ningbo, Seattle, Berkeley, New York and Shanghai")
A "<defs><pattern id=`"wave`" width=`"56`" height=`"28`" patternUnits=`"userSpaceOnUse`"><path d=`"M6 8h8v-2h8v2h8M34 22h8v-2h8v2h6`" stroke=`"#2c3978`" stroke-width=`"2`" fill=`"none`"/><animateTransform attributeName=`"patternTransform`" type=`"translate`" from=`"0 0`" to=`"56 0`" dur=`"9s`" repeatCount=`"indefinite`"/></pattern></defs>"
A "<rect width=`"$W`" height=`"$H`" fill=`"#1a1f4a`"/><rect width=`"$W`" height=`"$H`" fill=`"url(#wave)`"/>"


# ---- land ----
$land = Get-Content "$PSScriptRoot\land.txt"
$g1 = New-Object System.Text.StringBuilder; $g2 = New-Object System.Text.StringBuilder; $g3 = New-Object System.Text.StringBuilder
foreach ($l in $land) {
  $xy = $l.Split(','); $x = [math]::Round((TX ([double]$xy[0])) - 3); $y = [math]::Round((TY ([double]$xy[1])) - 3)
  $cell = "M$x $($y)h6v6h-6z"
  $k = (([int]$xy[0] * 7 + [int]$xy[1] * 13) % 7)
  if ($k -lt 4) { [void]$g1.Append($cell) } elseif ($k -lt 6) { [void]$g2.Append($cell) } else { [void]$g3.Append($cell) }
}
A "<g shape-rendering=`"crispEdges`"><path d=`"$($g1.ToString())`" fill=`"#3f9c75`"/><path d=`"$($g2.ToString())`" fill=`"#4fb286`"/><path d=`"$($g3.ToString())`" fill=`"#7fd6a0`"/></g>"

# ---- route: sampled along the beziers ----
function Pt([string]$n) { @($cn[$n].x, $cn[$n].y) }
function TP([double]$x, [double]$y) { @((TX $x), (TY $y)) }
$segs = @(
  @{ t = "L"; p = @((Pt "CHANGHUA"), (Pt "NINGBO")) },
  @{ t = "C"; p = @((Pt "NINGBO"), (TP 290 120), (TP 560 20), (Pt "SEATTLE")) },
  @{ t = "C"; p = @((Pt "SEATTLE"), (TP 690 128), (TP 690 150), (Pt "BERKELEY")) },
  @{ t = "C"; p = @((Pt "BERKELEY"), (TP 820 250), (TP 920 215), (Pt "NEW YORK")) },
  @{ t = "C"; p = @((Pt "NEW YORK"), (TP 840 10), (TP 380 -4), (Pt "SHANGHAI")) }
)
$d = "M $(N $segs[0].p[0][0]) $(N $segs[0].p[0][1])"
$pts = New-Object System.Collections.ArrayList
foreach ($s in $segs) {
  if ($s.t -eq "L") { $d += " L $(N $s.p[1][0]) $(N $s.p[1][1])"; [void]$pts.Add($s.p[0]); [void]$pts.Add($s.p[1]) }
  else {
    $d += " C $(N $s.p[1][0]) $(N $s.p[1][1]) $(N $s.p[2][0]) $(N $s.p[2][1]) $(N $s.p[3][0]) $(N $s.p[3][1])"
    for ($i = 0; $i -le 40; $i++) {
      $t = $i / 40; $u = 1 - $t
      $bx = $u*$u*$u*$s.p[0][0] + 3*$u*$u*$t*$s.p[1][0] + 3*$u*$t*$t*$s.p[2][0] + $t*$t*$t*$s.p[3][0]
      $by = $u*$u*$u*$s.p[0][1] + 3*$u*$u*$t*$s.p[1][1] + 3*$u*$t*$t*$s.p[2][1] + $t*$t*$t*$s.p[3][1]
      [void]$pts.Add(@($bx, $by))
    }
  }
}
# drop trail squares every ~15px along the sampled polyline
$trail = New-Object System.Text.StringBuilder
$acc = 0; $prev = $pts[0]; $idx = 0
foreach ($p in $pts) {
  $dx = $p[0] - $prev[0]; $dy = $p[1] - $prev[1]; $acc += [math]::Sqrt($dx*$dx + $dy*$dy); $prev = $p
  if ($acc -ge 15) {
    $acc = 0; $idx++
    $sx = [math]::Round($p[0] / 2) * 2 - 3; $sy = [math]::Round($p[1] / 2) * 2 - 3
    $col = if ($idx % 2) { "#ffc857" } else { "#fff3d6" }
    [void]$trail.Append("<rect x=`"$sx`" y=`"$sy`" width=`"6`" height=`"6`" fill=`"$col`"><animate attributeName=`"opacity`" values=`".25;1;.25`" dur=`"2.6s`" begin=`"-$(($idx * 0.13).ToString('0.00', $script:inv))s`" repeatCount=`"indefinite`"/></rect>")
  }
}
A "<g shape-rendering=`"crispEdges`">$($trail.ToString())</g>"
A "<path id=`"route`" d=`"$d`" fill=`"none`" stroke=`"none`"/>"

# ---- city flags + labels ----
$flag = @("..ffff", "..ffff", "..ffff", "..p...", "..p...", "..p...", "..p...", ".ppp..")
$i = 0
foreach ($c in $cities) {
  $i++
  $num = "{0:00}" -f $i
  $ax = if ($c.a -eq "end") { $c.lx + 6 } else { $c.lx - 6 }
  A "<path d=`"M$(N $c.x) $(N $c.y)L$(N $ax) $(N ($c.ly + 6))`" stroke=`"#a79bd0`" stroke-width=`"2`" stroke-dasharray=`"4 4`" opacity=`".7`"/>"
  A (PxSprite $flag @{ f = $c.c; p = "#fff3d6" } ($c.x - 6) ($c.y - 21) 3)
  A "<rect x=`"$(N ($c.x - 4))`" y=`"$(N ($c.y + 1))`" width=`"8`" height=`"8`" fill=`"none`" stroke=`"$($c.c)`" stroke-width=`"2`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"$(1.6 + $i * 0.15)s`" repeatCount=`"indefinite`"/></rect>"
  $labW = (PxW "$num $($c.n)" 2) + 12 + ($c.zh.Length * 14) + 12
  $lx0 = if ($c.a -eq "end") { $c.lx - $labW } else { $c.lx }
  A "<rect x=`"$(N $lx0)`" y=`"$(N ($c.ly - 6))`" width=`"$(N $labW)`" height=`"26`" fill=`"#120c24`" fill-opacity=`".82`" stroke=`"$($c.c)`" stroke-width=`"2`"/>"
  A (PxText $num ($lx0 + 8) ($c.ly) 2 $c.c)
  A (PxText $c.n ($lx0 + 8 + 30) ($c.ly) 2 "#fff3d6")
  A "<text x=`"$(N ($lx0 + 8 + 30 + (PxW $c.n 2) + 10))`" y=`"$(N ($c.ly + 12))`" fill=`"#a79bd0`" font-size=`"13`" font-family=`"'Microsoft YaHei', 'PingFang SC', 'Noto Sans SC', sans-serif`">$($c.zh)</text>"
}

# ---- the player walking the route ----
$chef = @("......wwww......", "....wwwwwwww....", "...wwwwwwwwww...", "...wwwwwwwwww...", "....xxxxxxxx....", "....hhhhhhhh....", "...phhhhhhhhp...", "..qqssssssssqq..", ("..qq" + "sesssses" + "qq.."), "..qqssssssssqq..", "...p.ssmmss.p...", ".....yyyyyy.....", "...jjjjaajjjj...", "..jjjjjaajjjjj..", "..sjjjjaajjjjs..", "...jjjjaajjjj...", "....bbbbbbbb....", "....bbb..bbb....", "...kkkk..kkkk...")
$cmap = @{ w = "#ffffff"; x = "#d9d2e9"; h = "#2a1a3a"; p = "#ff5d8f"; q = "#c23b72"; s = "#ffcba4"; e = "#1a1333"; m = "#c0504d"; y = "#e8a57c"; j = "#5ec8ff"; a = "#fff3d6"; b = "#3a2f66"; k = "#120c24" }
A "<g><g transform=`"translate(-16 -37)`">$(PxSprite $chef $cmap 0 0 2)</g><animateMotion dur=`"26s`" repeatCount=`"indefinite`" rotate=`"0`" calcMode=`"linear`"><mpath xlink:href=`"#route`"/></animateMotion></g>"

# ---- compass + hint ----
A (PxText "N" 958 20 2 "#fff3d6" "middle"); A "<path d=`"M958 36v26M950 44l8-8l8 8`" stroke=`"#fff3d6`" stroke-width=`"2`" fill=`"none`"/>"
A (PxText "SELECT STAGE" 26 262 2 "#a79bd0");
A "<rect x=`"176`" y=`"262`" width=`"10`" height=`"14`" fill=`"#ffc857`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>"

# ---- stage cards ----
$cw = 152; $gap = 12; $cy = 300
$i = 0
foreach ($c in $cities) {
  $x = 14 + $i * ($cw + $gap); $i++
  A (PxPanel $x $cy $cw 80 "#3a2f66" "#241a42" 6 3)
  A "<rect x=`"$(N ($x + 6))`" y=`"$($cy + 3)`" width=`"$($cw - 12)`" height=`"6`" fill=`"$($c.c)`"/>"
  A (PxText ("STAGE " + ("{0:00}" -f $i)) ($x + 14) ($cy + 20) 1.6 "#a79bd0")
  A (PxText $c.n ($x + 14) ($cy + 38) 2.2 "#fff3d6")
  A (PxText $c.when ($x + 14) ($cy + 62) 1.6 $c.c)
}
A "<g><rect x=`"$(N (14 + 5 * ($cw + $gap) + $cw - 26))`" y=`"$($cy + 18)`" width=`"10`" height=`"10`" fill=`"#6fe3b0`"><animate attributeName=`"opacity`" values=`"1;.2;1`" dur=`"1.2s`" repeatCount=`"indefinite`"/></rect></g>"
A "<rect x=`"3`" y=`"3`" width=`"994`" height=`"288`" fill=`"none`" stroke=`"#6a58a8`" stroke-width=`"6`"/><rect x=`"0`" y=`"0`" width=`"6`" height=`"6`" fill=`"#120c24`"/><rect x=`"994`" y=`"0`" width=`"6`" height=`"6`" fill=`"#120c24`"/>"
A "</svg>"
$f = Join-Path $root "assets\world.svg"
[IO.File]::WriteAllText($f, $o.ToString(), (New-Object Text.UTF8Encoding $false))
[xml](Get-Content $f -Raw -Encoding UTF8) | Out-Null
"world: $((Get-Item $f).Length) bytes"
