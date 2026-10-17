# Builds assets/banner.svg: a pixel-art Shanghai dusk with the player's name.
#   powershell -ExecutionPolicy Bypass -File tools/make-banner.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "assets\banner.svg"
$W = 1000; $H = 400; $G = 336
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }

# ---------- sky bands with dithered seams ----------
$bands = @("#140f2b", "#1a1335", "#21173f", "#2b1d4d", "#3a2460", "#4d2b72", "#6a3482", "#8f3f88", "#b84a82", "#e0587a", "#ff7a6b", "#ffa466")
$defs = New-Object System.Text.StringBuilder
$sky = New-Object System.Text.StringBuilder
$bh = 28
for ($i = 0; $i -lt $bands.Count; $i++) {
  [void]$sky.Append("<rect x=`"0`" y=`"$($i * $bh)`" width=`"$W`" height=`"$bh`" fill=`"$($bands[$i])`"/>")
  if ($i -gt 0) {
    [void]$defs.Append("<pattern id=`"dt$i`" width=`"8`" height=`"8`" patternUnits=`"userSpaceOnUse`"><rect width=`"4`" height=`"4`" fill=`"$($bands[$i])`"/><rect x=`"4`" y=`"4`" width=`"4`" height=`"4`" fill=`"$($bands[$i])`"/></pattern>")
    [void]$sky.Append("<rect x=`"0`" y=`"$($i * $bh - 8)`" width=`"$W`" height=`"8`" fill=`"url(#dt$i)`"/>")
  }
}

# ---------- stars ----------
$stars = New-Object System.Text.StringBuilder
$script:seed = 11
for ($i = 0; $i -lt 46; $i++) {
  $x = (Rnd 245) * 4; $y = (Rnd 42) * 4 + 8
  if ($x -gt 780 -and $x -lt 950 -and $y -gt 10 -and $y -lt 150) { continue }
  $s = if ((Rnd 4) -eq 0) { 8 } else { 4 }
  $col = @("#fff3d6", "#fff3d6", "#ffc857", "#b9a2ff", "#5ec8ff")[(Rnd 5)]
  $dur = 1.8 + (Rnd 30) / 10; $begin = - (Rnd 30) / 10
  $shape = if ($s -eq 8) { "<path d=`"M$($x+4) ${y}h4v4h4v4h-4v4h-4v-4h-4v-4h4z`" fill=`"$col`"/>" } else { "<rect x=`"$x`" y=`"$y`" width=`"4`" height=`"4`" fill=`"$col`"/>" }
  [void]$stars.Append("<g shape-rendering=`"crispEdges`">$shape<animate attributeName=`"opacity`" values=`"1;.15;1`" dur=`"${dur}s`" begin=`"${begin}s`" repeatCount=`"indefinite`"/></g>")
}

# ---------- moon ----------
$moon = (PxDisc 860 78 52 6 "rgba(255,200,150,.10)") + (PxDisc 860 78 40 6 "#ffe9b8") +
  "<g fill=`"#f0c98a`" shape-rendering=`"crispEdges`"><rect x=`"842`" y=`"60`" width=`"12`" height=`"12`"/><rect x=`"872`" y=`"84`" width=`"18`" height=`"12`"/><rect x=`"848`" y=`"96`" width=`"6`" height=`"6`"/></g>"

# ---------- clouds ----------
function Cloud([double]$x, [double]$y, [double]$u, [string]$fill) {
  $rows = @("....##......", "..######....", ".#########..", "############")
  $d = ""
  for ($r = 0; $r -lt $rows.Count; $r++) {
    $row = $rows[$r]; $c = 0
    while ($c -lt $row.Length) { if ($row[$c] -eq '#') { $e = $c; while ($e -lt $row.Length -and $row[$e] -eq '#') { $e++ }; $d += "M$(N ($x + $c * $u)) $(N ($y + $r * $u))h$(N (($e - $c) * $u))v$(N $u)h-$(N (($e - $c) * $u))z"; $c = $e } else { $c++ } }
  }
  "<path d=`"$d`" fill=`"$fill`" shape-rendering=`"crispEdges`"/>"
}
$clouds = "<g opacity=`".55`"><g>$(Cloud 0 120 12 '#b84a82')<animateTransform attributeName=`"transform`" type=`"translate`" values=`"-200 0;1100 0`" dur=`"90s`" begin=`"-30s`" repeatCount=`"indefinite`"/></g>" +
  "<g>$(Cloud 0 56 8 '#8f3f88')<animateTransform attributeName=`"transform`" type=`"translate`" values=`"-160 0;1100 0`" dur=`"130s`" begin=`"-90s`" repeatCount=`"indefinite`"/></g></g>"

# ---------- skyline ----------
function Rect([double]$x, [double]$y, [double]$w, [double]$h, [string]$fill) { "<rect x=`"$(N $x)`" y=`"$(N $y)`" width=`"$(N $w)`" height=`"$(N $h)`" fill=`"$fill`"/>" }
$back = New-Object System.Text.StringBuilder; $front = New-Object System.Text.StringBuilder; $wins = New-Object System.Text.StringBuilder
$script:seed = 5
$x = 380
while ($x -lt 1000) {
  $bw1 = (4 + (Rnd 6)) * 8; $bh1 = (6 + (Rnd 14)) * 8
  [void]$back.Append((Rect $x ($G - $bh1) $bw1 $bh1 "#3b2460"))
  $x += $bw1 + (Rnd 3) * 4
}
function Windows([double]$x, [double]$y, [double]$w, [double]$h, [int]$count, [string]$only = "") {
  $cols = @("#ffc857", "#ffc857", "#ff8fb1", "#6fe3b0", "#fff3d6")
  for ($i = 0; $i -lt $count; $i++) {
    $mx = [math]::Max(1, [int](($w - 16) / 8)); $my = [math]::Max(1, [int](($h - 20) / 12))
    $wx = $x + 6 + (Rnd $mx) * 8; $wy = $y + 8 + (Rnd $my) * 12
    if ($wy -gt $G - 10) { continue }
    $dur = 2 + (Rnd 40) / 10; $b = - (Rnd 40) / 10
    $script:wins_append = "<rect x=`"$(N $wx)`" y=`"$(N $wy)`" width=`"4`" height=`"6`" fill=`"$($cols[(Rnd 5)])`"><animate attributeName=`"opacity`" values=`".9;.25;.9`" dur=`"${dur}s`" begin=`"${b}s`" repeatCount=`"indefinite`"/></rect>"
    [void]$script:wins.Append($script:wins_append)
  }
}
# generic front towers
$ft = @(@(430, 56, 96), @(492, 40, 150), @(540, 48, 70), @(600, 44, 120), @(660, 38, 90), @(990, 20, 130))
foreach ($b in $ft) { [void]$front.Append((Rect $b[0] ($G - $b[2]) $b[1] $b[2] "#1d1238")); Windows $b[0] ($G - $b[2]) $b[1] $b[2] ([int]($b[1] * $b[2] / 900)) }

# Jin Mao style stepped tower (cx 720)
$jx = 720; $jw = 40; [void]$front.Append((Rect ($jx - $jw / 2) ($G - 110) $jw 110 "#241648"))
for ($i = 0; $i -lt 8; $i++) { $ww = $jw - ($i + 1) * 4; [void]$front.Append((Rect ($jx - $ww / 2) ($G - 110 - ($i + 1) * 16) $ww 16 "#241648")) }
[void]$front.Append((Rect ($jx - 2) ($G - 110 - 8 * 16 - 20) 4 20 "#241648"))
Windows ($jx - 20) ($G - 110) 40 110 7

# Oriental Pearl tower (cx 806)
$px = 806
foreach ($lx in @(($px - 26), ($px - 4), ($px + 18))) { [void]$front.Append((Rect $lx ($G - 80) 8 80 "#2a1a4f")) }
[void]$front.Append((Rect ($px - 4) ($G - 214) 8 140 "#2a1a4f"))
[void]$front.Append((PxDisc $px ($G - 104) 28 4 "#2a1a4f")); [void]$front.Append((PxDisc $px ($G - 172) 16 4 "#2a1a4f")); [void]$front.Append((PxDisc $px ($G - 214) 11 4 "#2a1a4f"))
[void]$front.Append((Rect ($px - 2) ($G - 268) 4 56 "#2a1a4f"))
foreach ($d in @(@(-12, -112), @(6, -98), @(-4, -118), @(10, -108), @(-8, -176), @(4, -168), @(0, -214))) { [void]$wins.Append("<rect x=`"$($px + $d[0])`" y=`"$($G + $d[1])`" width=`"4`" height=`"4`" fill=`"#ff8fb1`"><animate attributeName=`"opacity`" values=`"1;.2;1`" dur=`"$(2 + (Rnd 20) / 10)s`" repeatCount=`"indefinite`"/></rect>") }
[void]$wins.Append("<rect x=`"$($px - 2)`" y=`"$($G - 270)`" width=`"4`" height=`"4`" fill=`"#ff5d8f`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1.2s`" repeatCount=`"indefinite`"/></rect>")

# Shanghai Tower (cx 880): tapering in steps
$sx = 880; $y0 = $G
$tw = @(56, 48, 40, 32, 24, 16)
for ($i = 0; $i -lt $tw.Count; $i++) { $hh = 48; $y0 -= $hh; [void]$front.Append((Rect ($sx - $tw[$i] / 2) $y0 $tw[$i] $hh "#2e1c58")); [void]$front.Append((Rect ($sx - $tw[$i] / 2) $y0 4 $hh "#3d2870")) ; Windows ($sx - $tw[$i] / 2) $y0 $tw[$i] $hh 2 }
[void]$front.Append((Rect ($sx - 2) ($y0 - 28) 4 28 "#2e1c58"))
[void]$wins.Append("<rect x=`"$($sx - 2)`" y=`"$($y0 - 30)`" width=`"4`" height=`"4`" fill=`"#ff5d8f`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1.6s`" repeatCount=`"indefinite`"/></rect>")

# bottle-opener tower (cx 950)
$bx = 950
[void]$front.Append((Rect ($bx - 24) ($G - 230) 48 230 "#241648"))
[void]$front.Append("<polygon points=`"$($bx - 24),$($G - 230) $($bx + 24),$($G - 230) $($bx + 24),$($G - 250) $($bx - 24),$($G - 214)`" fill=`"#241648`" shape-rendering=`"crispEdges`"/>")
[void]$front.Append((Rect ($bx - 8) ($G - 206) 16 24 "#b84a82"))
Windows ($bx - 24) ($G - 180) 48 180 8

# FRANK neon sign on a mid tower
$sign = (PxPanel 506 148 92 28 "#ff5d8f" "#1a1335" 4 3) + (PxText "COOK" 518 156 2 "#ffc857") + (PxText "LAB" 562 156 2 "#6fe3b0") +
  "<animate attributeName=`"opacity`" values=`"1;1;.45;1;.7;1`" keyTimes=`"0;.5;.52;.56;.6;1`" dur=`"5s`" repeatCount=`"indefinite`"/>"
$sign = "<g>$sign</g>"

# ---------- ground ----------
$ground = (Rect 0 $G $W 64 "#0f0a1e") + (Rect 0 $G $W 6 "#2b1d4d") + (Rect 0 ($G + 6) $W 4 "#1c1436")
$tiles = ""; for ($tx = 0; $tx -lt $W; $tx += 48) { $tiles += "M$tx $($G + 24)h24v4h-24z" }
$ground += "<path d=`"$tiles`" fill=`"#1c1436`"/>"
# string lights
$lights = New-Object System.Text.StringBuilder
for ($lx = 8; $lx -lt $W; $lx += 24) {
  $col = @("#ffc857", "#ff5d8f", "#6fe3b0", "#5ec8ff")[(($lx / 24) % 4)]
  $dur = 1.4 + (($lx / 24) % 5) * 0.3
  [void]$lights.Append("<rect x=`"$lx`" y=`"$($G + 14)`" width=`"6`" height=`"6`" fill=`"$col`"><animate attributeName=`"opacity`" values=`"1;.3;1`" dur=`"${dur}s`" repeatCount=`"indefinite`"/></rect>")
}
[void]$lights.Append("<path d=`"M0 $($G + 12)h$W`" stroke=`"#3a2f66`" stroke-width=`"2`"/>")

# ---------- character: chef hat + headphones ----------
$chef = @(
  "......wwww......", "....wwwwwwww....", "...wwwwwwwwww...", "...wwwwwwwwww...", "....xxxxxxxx....", "....hhhhhhhh....",
  "...phhhhhhhhp...", "..qqssssssssqq..", ("..qq" + "sesssses" + "qq.."), "..qqssssssssqq..", "...p.ssmmss.p...", ".....yyyyyy.....",
  "...jjjjaajjjj...", "..jjjjjaajjjjj..", "..jjjjjaajjjjj..", "..sjjjjaajjjjs..", "..sjjjgaagjjjs..", "...jjjjaajjjj...",
  "....bbbbbbbb....", "....bbb..bbb....", "....bbb..bbb....", "...kkkk..kkkk..."
)
$cmap = @{ w = "#ffffff"; x = "#d9d2e9"; h = "#2a1a3a"; p = "#ff5d8f"; q = "#c23b72"; s = "#ffcba4"; e = "#1a1333"; m = "#c0504d"; y = "#e8a57c"; j = "#5ec8ff"; a = "#fff3d6"; g = "#ffc857"; b = "#3a2f66"; k = "#120c24" }
$charSvg = "<g><g>$(PxSprite $chef $cmap 626 ($G - 132) 6)<animateTransform attributeName=`"transform`" type=`"translate`" values=`"0 0;0 -4;0 0`" dur=`"1.2s`" repeatCount=`"indefinite`" calcMode=`"discrete`"/></g></g>"
# blinking: two tiny dark rects over the eyes now and then
$blink = "<rect x=`"$(626 + 5 * 6)`" y=`"$($G - 132 + 8 * 6)`" width=`"6`" height=`"6`" fill=`"#ffcba4`" opacity=`"0`"><animate attributeName=`"opacity`" values=`"0;0;1;0;0`" keyTimes=`"0;.94;.96;.98;1`" dur=`"4s`" repeatCount=`"indefinite`"/></rect><rect x=`"$(626 + 10 * 6)`" y=`"$($G - 132 + 8 * 6)`" width=`"6`" height=`"6`" fill=`"#ffcba4`" opacity=`"0`"><animate attributeName=`"opacity`" values=`"0;0;1;0;0`" keyTimes=`"0;.94;.96;.98;1`" dur=`"4s`" repeatCount=`"indefinite`"/></rect>"
$charSvg = $charSvg.Substring(0, $charSvg.Length - 8) + $blink + "</g></g>"

# wok stall (left of the character)
$stall = @(
  "..........", "..DDDDDD..", ".DDDDDDDD.", ".kkkkkkkk.", ".rrrrrrrr.", ".tttttttt.", ".t......t.", ".t......t."
)
$smap = @{ D = "#4a3a78"; k = "#1a1333"; r = "#ff7a6b"; t = "#7a4a2a" }
$wok = PxSprite $stall $smap 530 ($G - 40) 5
$steam = New-Object System.Text.StringBuilder
foreach ($i in 0..2) {
  $sx2 = 548 + $i * 14; $b = - $i * 0.8
  [void]$steam.Append("<rect x=`"$sx2`" y=`"$($G - 50)`" width=`"6`" height=`"6`" fill=`"#fff3d6`" opacity=`"0`"><animate attributeName=`"y`" values=`"$($G - 50);$($G - 90)`" dur=`"2.4s`" begin=`"${b}s`" repeatCount=`"indefinite`"/><animate attributeName=`"opacity`" values=`"0;.7;0`" dur=`"2.4s`" begin=`"${b}s`" repeatCount=`"indefinite`"/></rect>")
}

# boombox + notes (right of the character)
$box = @(
  "..cccccccccccc..", ".cBBBBBBBBBBBBc.", ".cBkkkBggBkkkBc.", ".cBkokBggBkokBc.", ".cBkkkBBBBkkkBc.", ".cBBBBBBBBBBBBc.", "..cccccccccccc.."
)
$bmap = @{ c = "#c23b72"; B = "#ff5d8f"; k = "#1a1333"; o = "#ffc857"; g = "#6fe3b0" }
$boom = PxSprite $box $bmap 740 ($G - 28) 4
$note = @("..##.", "..#.#", "..#..", "..#..", "##...", "##...")
$notes = New-Object System.Text.StringBuilder
foreach ($i in 0..2) {
  $nx = 748 + $i * 18; $b = - $i * 1.1; $col = @("#ffc857", "#6fe3b0", "#ff8fb1")[$i]
  [void]$notes.Append("<g opacity=`"0`"><animate attributeName=`"opacity`" values=`"0;1;0`" dur=`"3.3s`" begin=`"${b}s`" repeatCount=`"indefinite`"/><animateTransform attributeName=`"transform`" type=`"translate`" values=`"0 0;$((@(6, -6, 8)[$i])) -60`" dur=`"3.3s`" begin=`"${b}s`" repeatCount=`"indefinite`"/>$(PxSprite $note @{ '#' = $col } $nx ($G - 48) 3)</g>")
}

# ---------- headline text ----------
$zh = Z 0x6797,0x5B50,0x6D0B
$text = New-Object System.Text.StringBuilder
[void]$text.Append("<rect x=`"0`" y=`"0`" width=`"640`" height=`"$G`" fill=`"url(#fadeL)`"/>")
[void]$text.Append((PxText "PLAYER 1" 48 40 3 "#ffc857"))
[void]$text.Append("<g><rect x=`"$((48 + (PxW 'PLAYER 1' 3)) + 14)`" y=`"40`" width=`"12`" height=`"21`" fill=`"#6fe3b0`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect></g>")
[void]$text.Append((PxTextS "TZUYANG LIN" 48 84 8 "#fff3d6" "#7a2f78" "start" 6))
[void]$text.Append((PxText "AKA" 50 160 3 "#ffc857"))
[void]$text.Append((PxText "FRANK" 112 154 5 "#ffc857"))
[void]$text.Append("<text x=`"262`" y=`"184`" fill=`"#fff3d6`" font-size=`"30`" font-family=`"'Microsoft YaHei', 'PingFang SC', 'Noto Sans SC', sans-serif`" font-weight=`"700`">$zh</text>")
[void]$text.Append((PxText "DATA ANALYST  >" 50 212 3 "#fff3d6"))
[void]$text.Append((PxText "FIELD DEPLOYMENT ENGINEER" 50 238 3 "#fff3d6"))
[void]$text.Append((PxText "COOKHOLIC / R&B LOVER / TECH EXPLORER" 50 272 2 "#6fe3b0"))
[void]$text.Append((PxText "> PRESS START" 50 308 3 "#ffc857" "start" "") )
$cur = "<rect x=`"$(50 + (PxW '> PRESS START' 3) + 12)`" y=`"308`" width=`"12`" height=`"21`" fill=`"#ffc857`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>"

# ---------- assemble ----------
A (SvgOpen $W $H "Pixel-art Shanghai skyline at dusk. Tzuyang Lin, also known as Frank: data analyst, field deployment engineer, cookholic and R&amp;B lover.")
A "<defs>$($defs.ToString())<linearGradient id=`"fadeL`" x1=`"0`" x2=`"1`"><stop offset=`"0`" stop-color=`"#140f2b`" stop-opacity=`".86`"/><stop offset=`".72`" stop-color=`"#140f2b`" stop-opacity=`".5`"/><stop offset=`"1`" stop-color=`"#140f2b`" stop-opacity=`"0`"/></linearGradient><clipPath id=`"r`"><rect width=`"$W`" height=`"$H`" rx=`"0`"/></clipPath></defs>"
A "<g clip-path=`"url(#r)`">"
A $sky.ToString()
A $stars.ToString()
A $moon
A $clouds
A "<g>$($back.ToString())</g>"
A "<g>$($front.ToString())</g>"
A "<g>$($wins.ToString())</g>"
A $sign
A $ground
A $lights.ToString()
A $wok; A $steam.ToString()
A $charSvg
A $boom; A $notes.ToString()
A $text.ToString()
A $cur
A "</g>"
A "<rect x=`"2`" y=`"2`" width=`"$($W - 4)`" height=`"$($H - 4)`" fill=`"none`" stroke=`"#6a58a8`" stroke-width=`"4`"/>"
A "</svg>"
[IO.File]::WriteAllText($out, $o.ToString(), (New-Object Text.UTF8Encoding $false))
"banner: $((Get-Item $out).Length) bytes"