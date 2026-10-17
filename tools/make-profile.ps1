# Builds assets/strip.svg (four facts) and assets/toolbox.svg (skills + what I am learning).
#   powershell -ExecutionPolicy Bypass -File tools/make-profile.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root "assets"
$arrow = [string][char]0x2192; $dot = [string][char]0x00B7

# ---------------- strip.svg ----------------
$icons = @{
  pin = @("..aaaa..", ".aaaaaa.", ".aa..aa.", ".aaaaaa.", "..aaaa..", "...aa...", "...aa...", "........")
  case = @("..aaaa..", "..a..a..", "aaaaaaaa", "aa....aa", "aaaaaaaa", "aaaaaaaa", "aaaaaaaa", "........")
  cap = @("...aa...", "..aaaa..", ".aaaaaa.", "aaaaaaaa", ".a.aa.a.", ".a.aa.a.", "..aaaa..", "........")
  chip = @("..a..a..", ".aaaaaa.", "aaaaaaaa", "aa.aa.aa", "aaaaaaaa", "aaaaaaaa", ".aaaaaa.", "..a..a..")
}
$cells = @(
  @("LOCATION", "Shanghai, China", "UTC+8", "pin"),
  @("NEXT", "LaserTech", "Field Deployment Engineer, Oct 2026", "case"),
  @("EDUCATION", "UC Berkeley $dot UW", "M.Analytics '25 $dot B.A. Econ '24", "cap"),
  @("FOCUS", "Data $arrow systems", "ETL, BI, semiconductor tooling", "chip")
)
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }
A (SvgOpen 1000 92 "Four quick facts: based in Shanghai, joining LaserTech, studied at UC Berkeley and UW, focused on data and systems")
for ($i = 0; $i -lt 4; $i++) {
  $x = $i * 254
  A (Card $x 0 238 92)
  A (Txt $cells[$i][0] ($x + 18) 24 10.5 $T.dim 500 "start" "letter-spacing=`"1.6`"")
  A (PxSprite $icons[$cells[$i][3]] @{ a = $T.amber } ($x + 238 - 18 - 16) 16 2)
  A (Txt $cells[$i][1] ($x + 18) 55 16.5 $T.head 600)
  A (Txt $cells[$i][2] ($x + 18) 75 12 $T.mute 400)
}
A "</svg>"
SaveSvg (Join-Path $assets "strip.svg") $o.ToString()

# ---------------- toolbox.svg ----------------
$cols = @(
  @("LANGUAGES", @(@("Python", 5), @("SQL", 5), @("R", 4), @("JavaScript", 3))),
  @("ANALYTICS & BI", @(@("Pandas / NumPy", 5), @("Tableau", 5), @("scikit-learn", 4), @("Streamlit", 4))),
  @("DATA & SYSTEMS", @(@("ETL pipelines", 5), @("MySQL / Azure SQL", 4), @("Git", 4), @("Linux", 3)))
)
$o = New-Object System.Text.StringBuilder
A (SvgOpen 1000 232 "Toolbox: languages, analytics and BI, data and systems, plus what I am learning now")
A (Card 0 0 1000 232)
A (PxText "TOOLBOX" 28 22 2 $T.amber)
for ($c = 0; $c -lt 3; $c++) {
  $x = 28 + $c * 322
  A (Txt $cols[$c][0] $x 56 10.5 $T.dim 500 "start" "letter-spacing=`"1.6`"")
  $y = 92
  foreach ($it in $cols[$c][1]) {
    A (Txt $it[0] $x $y 14.5 $T.text 500)
    $bx = $x + 188
    for ($k = 0; $k -lt 5; $k++) {
      $fill = if ($k -lt $it[1]) { $T.amber } else { "#222c3c" }
      A "<rect x=`"$($bx + $k * 11)`" y=`"$($y - 9)`" width=`"8`" height=`"8`" fill=`"$fill`" shape-rendering=`"crispEdges`"/>"
    }
    $y += 28
  }
  if ($c -lt 2) { A "<path d=`"M$($x + 300) 48V176`" stroke=`"$($T.line)`"/>" }
}
A "<path d=`"M28 196H972`" stroke=`"$($T.line)`"/>"
A (Txt "LEARNING NOW" 28 220 10.5 $T.dim 500 "start" "letter-spacing=`"1.6`"")
$px0 = 170
$i = 0
foreach ($l in @("Linux", "FAB", "MAE", "EAP", "HPC", "TCP/IP")) {
  $p = Pill $px0 204 $l 12 "none" "" 22
  A $p.svg
  A "<rect x=`"$($px0 + 9)`" y=`"$(204 + 9)`" width=`"5`" height=`"5`" fill=`"$($T.amber)`" shape-rendering=`"crispEdges`"><animate attributeName=`"opacity`" values=`"1;.25;1`" dur=`"$(1.6 + $i * 0.25)s`" repeatCount=`"indefinite`"/></rect>"
  $i++
  $px0 += $p.w + 22
}
A (Txt "semiconductor + systems" 972 217 11.5 $T.dim 400 "end")
A "</svg>"
SaveSvg (Join-Path $assets "toolbox.svg") $o.ToString()
