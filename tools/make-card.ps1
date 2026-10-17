# Builds assets/stats.svg (player stats + inventory + now learning) and assets/sidequests.svg (hobbies).
#   powershell -ExecutionPolicy Bypass -File tools/make-card.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$icon = @{
  db = @("..oooooo..", ".occccccco", ".occccccco", "..oooooo..", ".occccccco", ".occccccco", "..oooooo..", ".occccccco", ".occccccco", "..oooooo..")
  chart = @("..........", "..........", "......yy..", "..rr..yy..", "..rr..yy.g", "..rr..yy.g", ".brr..yy.g", ".brrbyyybg", ".bbbbbbbbb", "..........")
  term = @("oooooooooo", "ooooooooxo", "oooooooooo", "occooooooo", "oooccoooo.".Replace(".", "o"), "occooooooo", "ooooooccoo", "oooooooooo", "oooooooooo", "..........")
  chip = @("..p.pp.p..", ".oooooooo.", "pocccccco.", ".occkkcco.", "pocckkcco.", ".occcccco.", "pocccccco.", ".oooooooo.", "..p.pp.p..", "..........")
  gear = @("...gggg...", ".g.gggg.g.", "..gggggg..", "gggg..gggg", "gggg..gggg", "..gggggg..", ".g.gggg.g.", "...gggg...", "..........", "..........")
  hat = @("..wwwwww..", ".wwwwwwww.", "wwwwwwwwww", "wwwwwwwwww", ".wwwwwwww.", "..xxxxxx..", "..wwwwww..", "..wwwwww..", "..wwwwww..", "..xxxxxx..")
  phones = @("...oooo...", "..o....o..", ".o......o.", ".o......o.", ".o......o.", "ooo....ooo", "ooo....ooo", "ooo....ooo", ".o......o.", "..........")
  plane = @("..........", "....o.....", "....oo....", "..oooooo..", "oooooooooo", "..oooooo..", "....oo....", "....o.....", "..........", "..........")
}
$iconColors = @{
  db = @{ o = "#b9a2ff"; c = "#5ec8ff" }
  chart = @{ y = "#ffc857"; r = "#ff7a6b"; g = "#6fe3b0"; b = "#b9a2ff" }
  term = @{ o = "#3a2f66"; x = "#ff5d8f"; c = "#6fe3b0" }
  chip = @{ o = "#6a58a8"; c = "#2f2354"; k = "#6fe3b0"; p = "#ffc857" }
  gear = @{ g = "#ffc857" }
  hat = @{ w = "#fff3d6"; x = "#d9d2e9" }
  phones = @{ o = "#ff5d8f" }
  plane = @{ o = "#5ec8ff" }
}

# ================= stats.svg =================
$W = 1000; $H = 470
$o = New-Object System.Text.StringBuilder
function A([string]$s) { [void]$script:o.Append($s); [void]$script:o.Append("`n") }
A (SvgOpen $W $H "Player stats: skill levels, inventory of tools and what I am learning right now")
A "<rect width=`"$W`" height=`"$H`" fill=`"#1a1333`"/>"
A "<pattern id=`"dots`" width=`"16`" height=`"16`" patternUnits=`"userSpaceOnUse`"><rect x=`"6`" y=`"6`" width=`"4`" height=`"4`" fill=`"#241a42`"/></pattern><rect width=`"$W`" height=`"$H`" fill=`"url(#dots)`"/>"

# --- left: player stats ---
A (PxPanel 12 12 560 446 "#6a58a8" "#241a42" 8 4)
A (PxText "PLAYER STATS" 40 36 4 "#ffc857")
A (PxText "1 UP" 500 38 3 "#ff8fb1")
$meta = @(@("CLASS", "DATA ANALYST > FDE"), @("GUILD", "LASERTECH / SHANGHAI"), @("SCHOOL", "UC BERKELEY, UW"), @("TALENT", "COOKING + R&B"))
$y = 84
foreach ($m in $meta) { A (PxText $m[0] 40 $y 2 "#a79bd0"); A (PxText $m[1] 150 $y 2 "#fff3d6"); $y += 26 }
A "<path d=`"M40 $($y + 4)h492`" stroke=`"#3a2f66`" stroke-width=`"4`" stroke-dasharray=`"8 8`"/>"
$skills = @(@("PYTHON", 5, "#6fe3b0"), @("SQL", 5, "#6fe3b0"), @("ETL", 5, "#5ec8ff"), @("TABLEAU", 5, "#5ec8ff"), @("R", 4, "#ffc857"), @("JAVASCRIPT", 3, "#ff9a5c"))
$y += 26
foreach ($s in $skills) {
  A (PxText $s[0] 40 ($y + 3) 2 "#fff3d6")
  A (PxBar 188 $y ($s[1] * 2) 10 22 18 4 $s[2] "#352a5e")
  A (PxText ("LV " + $s[1]) 520 ($y + 3) 2 "#a79bd0" "end")
  $y += 36
}
A (PxText "STAT BOOST: +3 FROM COFFEE" 40 ($y + 6) 2 "#ff8fb1")
A "<rect x=`"430`" y=`"$($y + 4)`" width=`"12`" height=`"18`" fill=`"#6fe3b0`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>"

# --- right: inventory ---
A (PxPanel 588 12 400 262 "#6a58a8" "#241a42" 8 4)
A (PxText "INVENTORY" 616 36 4 "#ffc857")
$gear = @(@("db", "SQL"), @("chart", "TABLEAU"), @("term", "PYTHON"), @("chip", "FAB / MAE"), @("gear", "FIELD OPS"), @("hat", "COOKING"), @("phones", "R&B"), @("plane", "TRAVEL"))
$i = 0
foreach ($it in $gear) {
  $col = $i % 4; $row = [math]::Floor($i / 4)
  $sx = 616 + $col * 90; $sy = 78 + $row * 98
  A (PxPanel $sx $sy 78 78 "#3a2f66" "#1a1333" 4 3)
  A (PxSprite $icon[$it[0]] $iconColors[$it[0]] ($sx + 14) ($sy + 12) 5)
  A (PxText $it[1] ($sx + 39) ($sy + 64) 1.6 "#fff3d6" "middle")
  $i++
}

# --- right-bottom: now learning ---
A (PxPanel 588 286 400 172 "#6a58a8" "#241a42" 8 4)
A (PxText "SIDE QUESTS" 616 310 3 "#ffc857")
A "<rect x=`"834`" y=`"312`" width=`"10`" height=`"10`" fill=`"#6fe3b0`"><animate attributeName=`"opacity`" values=`"1;.2;1`" dur=`"1.4s`" repeatCount=`"indefinite`"/></rect>"
A (PxText "IN PROGRESS" 852 314 1.6 "#a79bd0")
$learn = @(@("LINUX", 4, "#6fe3b0"), @("FAB", 2, "#ff8fb1"), @("MAE", 3, "#ffc857"), @("EAP", 3, "#5ec8ff"), @("HPC", 2, "#b9a2ff"), @("TCP/IP", 4, "#ff9a5c"))
$i = 0
foreach ($l in $learn) {
  $col = $i % 2; $row = [math]::Floor($i / 2)
  $lx = 616 + $col * 186; $ly = 342 + $row * 32
  A (PxText $l[0] $lx $ly 2 "#fff3d6")
  $anim = "><animate attributeName=`"opacity`" values=`"1;.55;1`" dur=`"$(1.6 + $i * 0.2)s`" repeatCount=`"indefinite`"/></path"
  A (PxBar ($lx + 84) ($ly) $l[1] 6 10 14 3 $l[2] "#352a5e")
  $i++
}
A (PxText "SEMICONDUCTOR + SYSTEMS" 616 432 1.6 "#a79bd0")
A "<rect x=`"2`" y=`"2`" width=`"$($W - 4)`" height=`"$($H - 4)`" fill=`"none`" stroke=`"#2b1d4d`" stroke-width=`"4`"/>"
A "</svg>"
$f = Join-Path $root "assets\stats.svg"
[IO.File]::WriteAllText($f, $o.ToString(), (New-Object Text.UTF8Encoding $false))
[xml](Get-Content $f -Raw -Encoding UTF8) | Out-Null
"stats: $((Get-Item $f).Length) bytes"

# ================= sidequests.svg =================
$W = 1000; $H = 150
$o = New-Object System.Text.StringBuilder
A (SvgOpen $W $H "Side quests: cooking, R and B music, travel and tinkering with new tech")
A "<rect width=`"$W`" height=`"$H`" fill=`"#1a1333`"/>"
$tiles = @(
  @("COOKING", "MICHELIN LOG", "hat", "#ffc857"),
  @("R&B", "ON REPEAT", "phones", "#ff5d8f"),
  @("TRAVEL", "5 CITIES", "plane", "#5ec8ff"),
  @("TINKER", "NEW TOOLS", "gear", "#6fe3b0")
)
$i = 0
foreach ($t in $tiles) {
  $tx = 12 + $i * 247
  A (PxPanel $tx 12 232 126 "#6a58a8" "#241a42" 8 4)
  A (PxPanel ($tx + 16) 32 64 64 $t[3] "#1a1333" 4 3)
  A (PxSprite $icon[$t[2]] $iconColors[$t[2]] ($tx + 26) 42 4.4)
  A (PxText $t[0] ($tx + 108) 48 2.6 $t[3])
  A (PxText $t[1] ($tx + 108) 80 1.6 "#fff3d6")
  if ($i -eq 1) {
    # equalizer
    foreach ($k in 0..5) {
      $hh = @(14, 24, 10, 28, 18, 22)[$k]
      A "<rect x=`"$($tx + 108 + $k * 12)`" y=`"$(118 - $hh)`" width=`"8`" height=`"$hh`" fill=`"#ff5d8f`"><animate attributeName=`"height`" values=`"$hh;$([math]::Max(6, 34 - $hh));$hh`" dur=`"$(0.7 + $k * 0.13)s`" repeatCount=`"indefinite`"/><animate attributeName=`"y`" values=`"$(118 - $hh);$(118 - [math]::Max(6, 34 - $hh));$(118 - $hh)`" dur=`"$(0.7 + $k * 0.13)s`" repeatCount=`"indefinite`"/></rect>"
    }
  } else {
    A (PxText "> LV MAX" ($tx + 108) 104 1.6 "#a79bd0")
  }
  $i++
}
A "</svg>"
$f = Join-Path $root "assets\sidequests.svg"
[IO.File]::WriteAllText($f, $o.ToString(), (New-Object Text.UTF8Encoding $false))
[xml](Get-Content $f -Raw -Encoding UTF8) | Out-Null
"sidequests: $((Get-Item $f).Length) bytes"
