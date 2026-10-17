# Pixel-art helpers shared by the generators (dot-source this file).
#   . "$PSScriptRoot\px.ps1"
# Everything here returns SVG snippets made of crisp square pixels. ASCII only; Chinese text comes from code points.
$script:inv = [Globalization.CultureInfo]::InvariantCulture
function N([double]$n) { $n.ToString("0.##", $script:inv) }
function Z([int[]]$cp) { -join ($cp | ForEach-Object { [char]$_ }) }

# ---------------- palette: a warm night, very different from the website ----------------
$P = @{
  ink = "#120c24"; night = "#1a1333"; plum = "#2b1d4d"; panel = "#241a42"; panel2 = "#2f2354"; edge = "#6a58a8"
  cream = "#fff3d6"; gold = "#ffc857"; orange = "#ff9a5c"; coral = "#ff7a6b"; rose = "#ff5d8f"
  mint = "#6fe3b0"; sky = "#5ec8ff"; lilac = "#b9a2ff"; mute = "#a79bd0"
}

# ---------------- 5x7 bitmap font (upper case) ----------------
$script:FONT = @{
  'A'='.###.|#...#|#...#|#####|#...#|#...#|#...#'; 'B'='####.|#...#|#...#|####.|#...#|#...#|####.'
  'C'='.####|#....|#....|#....|#....|#....|.####'; 'D'='####.|#...#|#...#|#...#|#...#|#...#|####.'
  'E'='#####|#....|#....|####.|#....|#....|#####'; 'F'='#####|#....|#....|####.|#....|#....|#....'
  'G'='.####|#....|#....|#..##|#...#|#...#|.###.'; 'H'='#...#|#...#|#...#|#####|#...#|#...#|#...#'
  'I'='#####|..#..|..#..|..#..|..#..|..#..|#####'; 'J'='..###|...#.|...#.|...#.|...#.|#..#.|.##..'
  'K'='#...#|#..#.|#.#..|##...|#.#..|#..#.|#...#'; 'L'='#....|#....|#....|#....|#....|#....|#####'
  'M'='#...#|##.##|#.#.#|#.#.#|#...#|#...#|#...#'; 'N'='#...#|##..#|#.#.#|#..##|#...#|#...#|#...#'
  'O'='.###.|#...#|#...#|#...#|#...#|#...#|.###.'; 'P'='####.|#...#|#...#|####.|#....|#....|#....'
  'Q'='.###.|#...#|#...#|#...#|#.#.#|#..#.|.##.#'; 'R'='####.|#...#|#...#|####.|#.#..|#..#.|#...#'
  'S'='.####|#....|#....|.###.|....#|....#|####.'; 'T'='#####|..#..|..#..|..#..|..#..|..#..|..#..'
  'U'='#...#|#...#|#...#|#...#|#...#|#...#|.###.'; 'V'='#...#|#...#|#...#|#...#|#...#|.#.#.|..#..'
  'W'='#...#|#...#|#...#|#.#.#|#.#.#|##.##|#...#'; 'X'='#...#|#...#|.#.#.|..#..|.#.#.|#...#|#...#'
  'Y'='#...#|#...#|.#.#.|..#..|..#..|..#..|..#..'; 'Z'='#####|....#|...#.|..#..|.#...|#....|#####'
  '0'='.###.|#...#|#..##|#.#.#|##..#|#...#|.###.'; '1'='..#..|.##..|..#..|..#..|..#..|..#..|.###.'
  '2'='.###.|#...#|....#|...#.|..#..|.#...|#####'; '3'='####.|....#|....#|.###.|....#|....#|####.'
  '4'='...#.|..##.|.#.#.|#..#.|#####|...#.|...#.'; '5'='#####|#....|####.|....#|....#|#...#|.###.'
  '6'='.###.|#....|#....|####.|#...#|#...#|.###.'; '7'='#####|....#|...#.|..#..|.#...|.#...|.#...'
  '8'='.###.|#...#|#...#|.###.|#...#|#...#|.###.'; '9'='.###.|#...#|#...#|.####|....#|....#|.###.'
  '.'='.....|.....|.....|.....|.....|.##..|.##..'; ','='.....|.....|.....|.....|.....|.##..|.#...'
  ':'='.....|.##..|.##..|.....|.##..|.##..|.....'; '!'='..#..|..#..|..#..|..#..|..#..|.....|..#..'
  '?'='.###.|#...#|....#|...#.|..#..|.....|..#..'; '-'='.....|.....|.....|#####|.....|.....|.....'
  '+'='.....|..#..|..#..|#####|..#..|..#..|.....'; '/'='....#|....#|...#.|..#..|.#...|#....|#....'
  "'"='..#..|..#..|.#...|.....|.....|.....|.....'; '('='...#.|..#..|.#...|.#...|.#...|..#..|...#.'
  ')'='.#...|..#..|...#.|...#.|...#.|..#..|.#...'; '='='.....|.....|#####|.....|#####|.....|.....'
  '&'='.##..|#..#.|#.#..|.#...|#.#.#|#..#.|.##.#'; '%'='##..#|##..#|...#.|..#..|.#...|#..##|#..##'
  '_'='.....|.....|.....|.....|.....|.....|#####'; '>'='#....|##...|###..|####.|###..|##...|#....'
  '<'='....#|...##|..###|.####|..###|...##|....#'; '*'='..#..|#.#.#|.###.|#####|.###.|#.#.#|..#..'
  '~'='.#.#.|#####|#####|.###.|..#..|.....|.....'; '#'='.#.#.|#####|.#.#.|.#.#.|#####|.#.#.|.....'
  '@'='.###.|#...#|#.###|#.#.#|#.###|#....|.####'
}

# width of a text run in pixels
function PxW([string]$t, [double]$s) {
  $w = 0; foreach ($ch in $t.ToUpper().ToCharArray()) { $w += $(if ($ch -eq ' ') { 4 } else { 6 }) * $s }; [math]::Max(0, $w - $s)
}

# text as one <path>; anchor = start | middle | end
function PxText([string]$t, [double]$x, [double]$y, [double]$s, [string]$fill, [string]$anchor = "start", [string]$extra = "") {
  $w = PxW $t $s
  if ($anchor -eq "middle") { $x -= $w / 2 } elseif ($anchor -eq "end") { $x -= $w }
  $d = New-Object System.Text.StringBuilder
  $cx = $x
  foreach ($ch in $t.ToUpper().ToCharArray()) {
    if ($ch -eq ' ') { $cx += 4 * $s; continue }
    $g = $script:FONT["$ch"]
    if (-not $g) { $g = $script:FONT['?'] }
    $rows = $g.Split('|')
    for ($r = 0; $r -lt 7; $r++) {
      $row = $rows[$r]; $c = 0
      while ($c -lt 5) {
        if ($row[$c] -eq '#') {
          $e = $c; while ($e -lt 5 -and $row[$e] -eq '#') { $e++ }
          [void]$d.Append("M$(N ($cx + $c * $s)) $(N ($y + $r * $s))h$(N (($e - $c) * $s))v$(N $s)h-$(N (($e - $c) * $s))z")
          $c = $e
        } else { $c++ }
      }
    }
    $cx += 6 * $s
  }
  "<path d=`"$($d.ToString())`" fill=`"$fill`" shape-rendering=`"crispEdges`" $extra/>"
}

# text with a hard drop shadow
function PxTextS([string]$t, [double]$x, [double]$y, [double]$s, [string]$fill, [string]$shadow, [string]$anchor = "start", [double]$off = 0) {
  if ($off -le 0) { $off = $s }
  (PxText $t ($x + $off) ($y + $off) $s $shadow $anchor) + (PxText $t $x $y $s $fill $anchor)
}

# sprite: rows of equal-length strings, $map maps a letter to a colour ('.' = empty). Optional $flip mirrors it.
function PxSprite([string[]]$rows, [hashtable]$map, [double]$x, [double]$y, [double]$s, [bool]$flip = $false) {
  $w = $rows[0].Length
  foreach ($r in $rows) { if ($r.Length -ne $w) { throw "sprite row has wrong width: '$r' ($($r.Length) vs $w)" } }
  $byColor = New-Object System.Collections.Hashtable
  for ($r = 0; $r -lt $rows.Count; $r++) {
    $row = $rows[$r]; if ($flip) { $row = -join ($row.ToCharArray()[($w - 1)..0]) }
    $c = 0
    while ($c -lt $w) {
      $ch = $row[$c]
      if ($ch -ne '.') {
        $e = $c; while ($e -lt $w -and $row[$e] -eq $ch) { $e++ }
        if (-not $byColor.ContainsKey("$ch")) { $byColor["$ch"] = New-Object System.Text.StringBuilder }
        [void]$byColor["$ch"].Append("M$(N ($x + $c * $s)) $(N ($y + $r * $s))h$(N (($e - $c) * $s))v$(N $s)h-$(N (($e - $c) * $s))z")
        $c = $e
      } else { $c++ }
    }
  }
  $o = New-Object System.Text.StringBuilder
  foreach ($k in $byColor.Keys) { [void]$o.Append("<path d=`"$($byColor[$k].ToString())`" fill=`"$($map[$k])`"/>") }
  "<g shape-rendering=`"crispEdges`">$($o.ToString())</g>"
}

# pixel disc made of $u-sized cells
function PxDisc([double]$cx, [double]$cy, [double]$r, [double]$u, [string]$fill) {
  $d = New-Object System.Text.StringBuilder
  $n = [math]::Ceiling($r / $u)
  for ($j = -$n; $j -le $n; $j++) {
    $span = [math]::Floor([math]::Sqrt([math]::Max(0, ($r / $u) * ($r / $u) - ($j + 0.5) * ($j + 0.5)) ) )
    if ($span -ge 0) {
      $half = [math]::Sqrt([math]::Max(0, ($r / $u) * ($r / $u) - ($j + 0.5) * ($j + 0.5)))
      $w = [math]::Round($half * 2)
      if ($w -ge 1) { [void]$d.Append("M$(N ($cx - $w * $u / 2)) $(N ($cy + $j * $u))h$(N ($w * $u))v$(N $u)h-$(N ($w * $u))z") }
    }
  }
  "<path d=`"$($d.ToString())`" fill=`"$fill`" shape-rendering=`"crispEdges`"/>"
}

# notched pixel panel (border + fill)
function PxPanel([double]$x, [double]$y, [double]$w, [double]$h, [string]$border, [string]$fill, [double]$n = 6, [double]$bw = 4) {
  function Poly([double]$x, [double]$y, [double]$w, [double]$h, [double]$n) {
    "$(N ($x+$n)),$(N $y) $(N ($x+$w-$n)),$(N $y) $(N ($x+$w-$n)),$(N ($y+$n)) $(N ($x+$w)),$(N ($y+$n)) $(N ($x+$w)),$(N ($y+$h-$n)) $(N ($x+$w-$n)),$(N ($y+$h-$n)) $(N ($x+$w-$n)),$(N ($y+$h)) $(N ($x+$n)),$(N ($y+$h)) $(N ($x+$n)),$(N ($y+$h-$n)) $(N $x),$(N ($y+$h-$n)) $(N $x),$(N ($y+$n)) $(N ($x+$n)),$(N ($y+$n))"
  }
  "<polygon points=`"$(Poly $x $y $w $h $n)`" fill=`"$border`" shape-rendering=`"crispEdges`"/><polygon points=`"$(Poly ($x+$bw) ($y+$bw) ($w-2*$bw) ($h-2*$bw) ($n-2))`" fill=`"$fill`" shape-rendering=`"crispEdges`"/>"
}

# segmented pixel bar: $on of $total segments lit
function PxBar([double]$x, [double]$y, [int]$on, [int]$total, [double]$sw, [double]$sh, [double]$gap, [string]$fill, [string]$off, [string]$anim = "") {
  $a = New-Object System.Text.StringBuilder; $b = New-Object System.Text.StringBuilder
  for ($i = 0; $i -lt $total; $i++) {
    $rx = $x + $i * ($sw + $gap)
    if ($i -lt $on) { [void]$a.Append("M$(N $rx) $(N $y)h$(N $sw)v$(N $sh)h-$(N $sw)z") } else { [void]$b.Append("M$(N $rx) $(N $y)h$(N $sw)v$(N $sh)h-$(N $sw)z") }
  }
  "<path d=`"$($b.ToString())`" fill=`"$off`" shape-rendering=`"crispEdges`"/><path d=`"$($a.ToString())`" fill=`"$fill`" shape-rendering=`"crispEdges`" $anim/>"
}

# deterministic pseudo-random numbers for scatter (stars etc.)
$script:seed = 7
function Rnd([int]$max) { $script:seed = ($script:seed * 1103515245 + 12345) % 2147483648; [int]($script:seed % $max) }

function SvgOpen([int]$w, [int]$h, [string]$label) {
  "<svg xmlns=`"http://www.w3.org/2000/svg`" xmlns:xlink=`"http://www.w3.org/1999/xlink`" viewBox=`"0 0 $w $h`" width=`"$w`" height=`"$h`" role=`"img`" aria-label=`"$label`">"
}
$script:MONO = 'font-family="Consolas, Menlo, ''Courier New'', monospace"'
