# Builds assets/banner.svg: a calm banner with a dithered Shanghai dusk on the right and the name on the left.
#   powershell -ExecutionPolicy Bypass -File tools/make-banner.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$W = 1000; $H = 300; $G = 282
$zh = Z 0x6797, 0x5B50, 0x6D0B
$arrow = [string][char]0x2192
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }
function Rc([double]$x, [double]$y, [double]$w, [double]$h, [string]$f, [string]$extra = "") { "<rect x=`"$(N $x)`" y=`"$(N $y)`" width=`"$(N $w)`" height=`"$(N $h)`" fill=`"$f`" $extra/>" }

A (SvgOpen $W $H "Tzuyang Lin, also known as Frank: data analyst heading into field deployment engineering in Shanghai. Cooking and R and B on the side.")
A "<defs>"
A "<clipPath id=`"c`"><rect width=`"$W`" height=`"$H`" rx=`"14`"/></clipPath>"
A "<pattern id=`"grid`" width=`"20`" height=`"20`" patternUnits=`"userSpaceOnUse`"><rect x=`"10`" y=`"10`" width=`"2`" height=`"2`" fill=`"#ffffff`" fill-opacity=`".07`"/></pattern>"
# ordered-dither densities (3px cells in a 12px tile)
$cellsets = @{
  d1 = @("0,0")
  d2 = @("0,0", "6,6")
  d3 = @("0,0", "6,0", "3,3", "9,3", "0,6", "6,6", "3,9", "9,9")
}
foreach ($k in @("d1", "d2", "d3")) {
  $cells = ($cellsets[$k] | ForEach-Object { $xy = $_.Split(","); "<rect x=`"$($xy[0])`" y=`"$($xy[1])`" width=`"3`" height=`"3`" fill=`"#ffb454`"/>" }) -join ""
  A "<pattern id=`"$k`" width=`"12`" height=`"12`" patternUnits=`"userSpaceOnUse`">$cells</pattern>"
}
A "<linearGradient id=`"fade`" x1=`"0`" x2=`"1`"><stop offset=`".40`" stop-color=`"#fff`" stop-opacity=`"0`"/><stop offset=`".68`" stop-color=`"#fff`" stop-opacity=`"1`"/></linearGradient>"
A "<mask id=`"m`"><rect width=`"$W`" height=`"$H`" fill=`"url(#fade)`"/></mask>"
A "<linearGradient id=`"bg`" x1=`"0`" y1=`"0`" x2=`"0`" y2=`"1`"><stop offset=`"0`" stop-color=`"#0d1117`"/><stop offset=`"1`" stop-color=`"#111827`"/></linearGradient>"
A "</defs>"
A "<g clip-path=`"url(#c)`">"
A (Rc 0 0 $W $H "url(#bg)")
A (Rc 0 0 $W $H "url(#grid)")

# ---------- right: dithered dusk + skyline (fades in from the left) ----------
$art = New-Object System.Text.StringBuilder
function Ad([string]$s) { [void]$script:art.Append($s) }
# haze bands, sparse at the top, dense at the horizon
Ad (Rc 0 120 $W 36 "url(#d1)" "opacity=`".55`"")
Ad (Rc 0 156 $W 36 "url(#d2)" "opacity=`".6`"")
Ad (Rc 0 192 $W 36 "url(#d3)" "opacity=`".55`"")
Ad (Rc 0 228 $W 54 "#ffb454" "opacity=`".16`"")
Ad (Rc 0 258 $W 24 "#ffb454" "opacity=`".14`"")
# moon
Ad (PxDisc 905 62 20 4 "#efe6d2" )
Ad (PxDisc 899 56 6 4 "#d9cfb8")
# skyline silhouettes
$sil = "#0a0e15"; $sil2 = "#0f1520"
$script:seed = 9
$x = 440
while ($x -lt 1000) {
  $bw = (4 + (Rnd 5)) * 6; $bh = (4 + (Rnd 9)) * 6
  Ad (Rc $x ($G - $bh) $bw $bh $sil2)
  $x += $bw + (Rnd 2) * 6
}
Ad (Rc 0 0 0 0 $sil)
# Jin Mao (stepped)
$jx = 700; Ad (Rc ($jx - 18) ($G - 80) 36 80 $sil)
for ($i = 0; $i -lt 7; $i++) { $ww = 36 - ($i + 1) * 4; Ad (Rc ($jx - $ww / 2) ($G - 80 - ($i + 1) * 12) $ww 12 $sil) }
Ad (Rc ($jx - 1.5) ($G - 80 - 7 * 12 - 16) 3 16 $sil)
# Oriental Pearl
$px = 790
foreach ($lx in @(($px - 20), ($px - 3), ($px + 14))) { Ad (Rc $lx ($G - 60) 6 60 $sil) }
Ad (Rc ($px - 3) ($G - 170) 6 112 $sil)
Ad (PxDisc $px ($G - 80) 22 3 $sil); Ad (PxDisc $px ($G - 134) 13 3 $sil); Ad (PxDisc $px ($G - 168) 9 3 $sil)
Ad (Rc ($px - 1.5) ($G - 214) 3 48 $sil)
# Shanghai Tower (stepped taper)
$sx = 870; $y0 = $G
foreach ($tw in @(48, 40, 33, 26, 19, 12)) { $y0 -= 38; Ad (Rc ($sx - $tw / 2) $y0 $tw 38 $sil) }
Ad (Rc ($sx - 1.5) ($y0 - 22) 3 22 $sil)
# bottle-opener tower
$bx = 950
Ad (Rc ($bx - 20) ($G - 190) 40 190 $sil)
Ad "<polygon points=`"$($bx - 20),$($G - 190) $($bx + 20),$($G - 190) $($bx + 20),$($G - 208) $($bx - 20),$($G - 176)`" fill=`"$sil`"/>"
Ad (Rc ($bx - 6) ($G - 170) 12 20 "#d9893a" "opacity=`".5`"")
# tiny lit windows
$script:seed = 21
for ($i = 0; $i -lt 46; $i++) {
  $wx = 450 + (Rnd 540); $wy = $G - 14 - (Rnd 150)
  if ($wx -gt 780 -and $wx -lt 800 -and $wy -lt $G - 60) { continue }
  $dur = 2.4 + (Rnd 40) / 10; $b = - (Rnd 40) / 10
  Ad "<rect x=`"$(6 * [math]::Floor($wx / 6) + 1)`" y=`"$(6 * [math]::Floor($wy / 6) + 1)`" width=`"3`" height=`"3`" fill=`"#ffb454`"><animate attributeName=`"opacity`" values=`".9;.2;.9`" dur=`"${dur}s`" begin=`"${b}s`" repeatCount=`"indefinite`"/></rect>"
}
# ground
Ad (Rc 0 $G $W 24 "#0a0e15")
Ad (Rc 0 $G $W 1 "#2a3345")
A "<g mask=`"url(#m)`">$($art.ToString())</g>"

# the cool one on the rooftop: shades, headphones, hoodie, smirk, tossing something in a pan (signature)
$cool = @(
  "...h..hh..h.....", "..hhhhhhhhhh....", ".hhhhhhhhhhhh...", ".phhihhhhihhhp..", ".pphsssssssshpp.",
  ".qpkkkksskkkkpq.", ".pqkkkksskkkkqp.", "..yssssssssssy..", "...ssssmmsssss..", "....yssssssy....",
  ".....yyyyyy.....", "...jjjwwwwjjj...", "..jjjjwjjwjjjj..", ".jjjjjjjjjjjjj..", ".jjajjjjjjjjjj..",
  ".jjjjjjjjjjjjs..", ".jjjjjjjjjjjjj..", ".tjjjjjjjjjjjt..", "..bbbbbbbbbbbb..", "..bbbbb..bbbbb..",
  "..bbbbb..bbbbb..", "..bbbbb..bbbbb..", ".nnnnnn..nnnnnn.", ".rrrrrr..rrrrrr."
)
$cmap = @{ h = "#1a1424"; i = "#3a2f58"; s = "#f2c29c"; y = "#d99b74"; k = "#06080d"; p = "#ffb454"; q = "#a8742f"; j = "#2c3858"; t = "#1c2540"; w = "#e9eef7"; a = "#ffb454"; m = "#8a3b3b"; b = "#222a40"; n = "#eef1f7"; r = "#ffb454" }
$pan = @(".....gggggggg.", "tttttfffffffff", ".....ffffffff.", "......ffffff..")
$pmap = @{ g = "#7b849a"; f = "#3b4256"; t = "#8a5a32" }
$cx = 652; $cy = $G - 24 * 3; $pxs = $cx + 13 * 3; $pys = $cy + 15 * 3 + 2
$flame = ""
foreach ($k in 0..2) {
  $fx = $pxs + 24 + $k * 9; $col = @("#ff7a3d", "#ffd36b", "#ff7a3d")[$k]; $b = - $k * 0.23
  $flame += "<rect x=`"$fx`" y=`"$($pys - 8)`" width=`"4`" height=`"6`" fill=`"$col`"><animate attributeName=`"height`" values=`"3;8;3`" dur=`"0.7s`" begin=`"${b}s`" repeatCount=`"indefinite`"/><animate attributeName=`"y`" values=`"$($pys - 5);$($pys - 10);$($pys - 5)`" dur=`"0.7s`" begin=`"${b}s`" repeatCount=`"indefinite`"/></rect>"
}
$toss = "<rect x=`"$($pxs + 30)`" y=`"$($pys - 10)`" width=`"5`" height=`"5`" fill=`"#7fe3b8`"><animate attributeName=`"y`" values=`"$($pys - 8);$($pys - 40);$($pys - 8)`" keyTimes=`"0;.5;1`" calcMode=`"spline`" keySplines=`".3 0 .6 1;.4 0 .7 1`" dur=`"1.6s`" repeatCount=`"indefinite`"/></rect>"
$glint = "<rect x=`"$($cx + 4 * 3)`" y=`"$($cy + 5 * 3)`" width=`"3`" height=`"3`" fill=`"#ffffff`" opacity=`"0`"><animate attributeName=`"opacity`" values=`"0;0;1;0;0`" keyTimes=`"0;.5;.55;.62;1`" dur=`"3.4s`" repeatCount=`"indefinite`"/></rect><rect x=`"$($cx + 10 * 3)`" y=`"$($cy + 6 * 3)`" width=`"3`" height=`"3`" fill=`"#ffffff`" opacity=`"0`"><animate attributeName=`"opacity`" values=`"0;0;1;0;0`" keyTimes=`"0;.52;.57;.64;1`" dur=`"3.4s`" repeatCount=`"indefinite`"/></rect>"
$bob = "<animateTransform attributeName=`"transform`" type=`"translate`" values=`"0 0;0 -3;0 0`" dur=`"1.2s`" repeatCount=`"indefinite`" calcMode=`"discrete`"/>"
A "<g>$(PxSprite $cool $cmap $cx $cy 3)$(PxSprite $pan $pmap $pxs $pys 3)$glint$flame$toss$bob</g>"

# ---------- left: text ----------
A (PxText "> WELCOME TO MY RESORT" 46 40 2 $T.amber)
A "<rect x=`"$(N (46 + (PxW '> WELCOME TO MY RESORT' 2) + 8))`" y=`"40`" width=`"8`" height=`"14`" fill=`"$($T.amber)`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1.1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>"
A (Txt "Tzuyang Lin" 44 116 56 $T.head 700 "start" "letter-spacing=`"-1.5`"")
A (Txt "Frank" 46 152 21 $T.amber 600)
A (Txt " $([char]0x00B7) $zh" 112 152 21 $T.mute 400)
A (Txt "Data analyst turning messy data into things people use." 46 192 15.5 "#aab6c6")
A (Txt "Next: tool software and data on the semiconductor fab floor." 46 214 15.5 "#aab6c6")
$px0 = 46
foreach ($l in @("Data Analyst", "Field Deployment Engineer", "Cooking", "R&B")) {
  $p = Pill $px0 238 $l 12.5
  A $p.svg; $px0 += $p.w + 8
}
A "</g>"
A "<rect x=`"0.5`" y=`"0.5`" width=`"$($W - 1)`" height=`"$($H - 1)`" rx=`"14`" fill=`"none`" stroke=`"$($T.line)`"/>"
A "</svg>"
SaveSvg (Join-Path (Join-Path $root "assets") "banner.svg") $o.ToString()