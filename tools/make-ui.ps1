# Builds the small pixel pieces: section headers, quest cards (projects), contact buttons and the outro.
#   powershell -ExecutionPolicy Bypass -File tools/make-ui.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root "assets"
function Save([string]$name, [string]$svg) {
  $f = Join-Path $assets $name
  [IO.File]::WriteAllText($f, $svg, (New-Object Text.UTF8Encoding $false))
  [xml](Get-Content $f -Raw -Encoding UTF8) | Out-Null
  "{0,-18} {1,7:N0} bytes" -f $name, (Get-Item $f).Length
}

# ---------------- section headers ----------------
$headers = @(
  @("h-stats", "PLAYER STATS", "#ffc857"), @("h-world", "OVERWORLD", "#5ec8ff"), @("h-quests", "QUEST LOG", "#ff8fb1"),
  @("h-log", "CONTRIBUTIONS", "#6fe3b0")
)
foreach ($h in $headers) {
  $tw = PxW $h[1] 4
  $svg = (SvgOpen 1000 56 $h[1]) + "<path d=`"M0 0h1000v56H0z`" fill=`"#1a1333`"/>" +
    (PxText ">" 12 14 4 $h[2]) + (PxText $h[1] 52 14 4 "#fff3d6") +
    "<path d=`"M$(N (52 + $tw + 20)) 28H976`" stroke=`"#3a2f66`" stroke-width=`"4`" stroke-dasharray=`"8 8`"/>" +
    "<rect x=`"976`" y=`"20`" width=`"12`" height=`"16`" fill=`"$($h[2])`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>" +
    "<rect x=`"12`" y=`"6`" width=`"6`" height=`"6`" fill=`"$($h[2])`" opacity=`"0`"/></svg>"
  Save "$($h[0]).svg" $svg
}

# ---------------- quest cards ----------------
$icon = @{
  db = @("..oooooo..", ".occccccco", ".occccccco", "..oooooo..", ".occccccco", ".occccccco", "..oooooo..", ".occccccco", ".occccccco", "..oooooo..")
  chart = @("..........", "..........", "......yy..", "..rr..yy..", "..rr..yy.g", "..rr..yy.g", ".brr..yy.g", ".brrbyyybg", ".bbbbbbbbb", "..........")
  term = @("oooooooooo", "ooooooooxo", "oooooooooo", "occooooooo", "oooccooooo", "occooooooo", "ooooooccoo", "oooooooooo", "oooooooooo", "..........")
  phones = @("...oooo...", "..o....o..", ".o......o.", ".o......o.", ".o......o.", "ooo....ooo", "ooo....ooo", "ooo....ooo", ".o......o.", "..........")
  gear = @("...gggg...", ".g.gggg.g.", "..gggggg..", "gggg..gggg", "gggg..gggg", "..gggggg..", ".g.gggg.g.", "...gggg...", "..........", "..........")
  plane = @("..........", "....o.....", "....oo....", "..oooooo..", "oooooooooo", "..oooooo..", "....oo....", "....o.....", "..........", "..........")
}
$iconColors = @{
  db = @{ o = "#b9a2ff"; c = "#5ec8ff" }; chart = @{ y = "#ffc857"; r = "#ff7a6b"; g = "#6fe3b0"; b = "#b9a2ff" }
  term = @{ o = "#3a2f66"; x = "#ff5d8f"; c = "#6fe3b0" }; phones = @{ o = "#ff5d8f" }; gear = @{ g = "#ffc857" }; plane = @{ o = "#5ec8ff" }
}
$quests = @(
  @{ f = "q1"; t = "FRANK.DB"; y = "2026"; k = "MAIN QUEST"; c = "#ffc857"; i = "db"; l1 = "This portfolio, built like a database:"; l2 = ("3D city, SQL console, EN / " + (Z 0x4E2D, 0x6587) + "."); tags = @("JAVASCRIPT", "THREE.JS") },
  @{ f = "q2"; t = "MASS SAVE"; y = "2025"; k = "RESEARCH"; c = "#6fe3b0"; i = "chart"; l1 = "15 years of Massachusetts energy data:"; l2 = "cost to deliver, heat pumps, retrofits."; tags = @("PYTHON", "PANDAS") },
  @{ f = "q3"; t = "KOBO > SHAREPOINT"; y = "2025"; k = "PIPELINE"; c = "#5ec8ff"; i = "term"; l1 = "Field media straight into SharePoint,"; l2 = "incremental uploads, duplicate checks."; tags = @("PYTHON", "GRAPH API") },
  @{ f = "q4"; t = "ACCENT AI"; y = "2025"; k = "ML MODEL"; c = "#ff8fb1"; i = "phones"; l1 = "Fine-tuned wav2vec2 on 167K+ clips to"; l2 = "tell 11 English accents apart (Flask)."; tags = @("PYTORCH", "FLASK") },
  @{ f = "q5"; t = "CHRONIC RISK"; y = "2024"; k = "ML TEAM"; c = "#b9a2ff"; i = "gear"; l1 = "Predictive models and clustering on"; l2 = "NHANES survey data, Berkeley team."; tags = @("SCIKIT-LEARN", "JUPYTER") },
  @{ f = "q6"; t = "COVID-19 DATA"; y = "2022"; k = "DASHBOARD"; c = "#ff9a5c"; i = "plane"; l1 = "Vaccinations, cases and deaths worldwide"; l2 = "with Plotly / Dash and a Tableau book."; tags = @("PYTHON", "PLOTLY", "TABLEAU") }
)
foreach ($q in $quests) {
  $W = 320; $H = 188
  $s = (SvgOpen $W $H "Project: $($q.t)") + "<rect width=`"$W`" height=`"$H`" fill=`"#1a1333`"/>"
  $s += PxPanel 3 3 314 182 "#6a58a8" "#241a42" 8 4
  $s += "<rect x=`"13`" y=`"13`" width=`"294`" height=`"6`" fill=`"$($q.c)`"/>"
  $s += PxText "$($q.y)  $($q.k)" 22 32 1.6 $q.c
  $s += PxSprite $icon[$q.i] $iconColors[$q.i] 262 32 3.4
  $s += PxTextS $q.t 22 56 2.2 "#fff3d6" "#7a2f78" "start" 2
  $s += "<text x=`"22`" y=`"108`" fill=`"#d8cff5`" font-size=`"12.5`" $($script:MONO)>$($q.l1)</text>"
  $s += "<text x=`"22`" y=`"126`" fill=`"#d8cff5`" font-size=`"12.5`" font-family=`"Consolas, Menlo, 'Courier New', 'Microsoft YaHei', 'Noto Sans SC', monospace`">$($q.l2)</text>"
  $tx = 22
  foreach ($tg in $q.tags) {
    $tw = (PxW $tg 1.4) + 14
    $s += "<rect x=`"$tx`" y=`"142`" width=`"$(N $tw)`" height=`"20`" fill=`"#1a1333`" stroke=`"#6a58a8`" stroke-width=`"2`"/>" + (PxText $tg ($tx + 7) 148 1.4 "#fff3d6")
    $tx += $tw + 8
  }
  $s += PxText "> OPEN" 246 148 1.6 $q.c
  $s += "<rect x=`"$(N (246 + (PxW '> OPEN' 1.6) + 6))`" y=`"148`" width=`"7`" height=`"11`" fill=`"$($q.c)`"><animate attributeName=`"opacity`" values=`"1;0;1`" dur=`"1s`" calcMode=`"discrete`" repeatCount=`"indefinite`"/></rect>"
  $s += "</svg>"
  Save "$($q.f).svg" $s
}

# ---------------- contact buttons ----------------
$btns = @(
  @("b-site", "PORTFOLIO", "ZZYANG0.GITHUB.IO", "#ffc857"), @("b-linkedin", "LINKEDIN", "CONNECT", "#5ec8ff"),
  @("b-insta", "INSTAGRAM", "@ZZYANG0528", "#ff8fb1"), @("b-mail", "EMAIL", "SAY HI", "#6fe3b0")
)
foreach ($b in $btns) {
  $w2 = 232; $h2 = 64
  $s = (SvgOpen $w2 $h2 $b[1]) + (PxPanel 2 2 ($w2 - 4) ($h2 - 4) $b[3] "#241a42" 6 4)
  $s += "<rect x=`"10`" y=`"10`" width=`"8`" height=`"$($h2 - 20)`" fill=`"$($b[3])`"/>"
  $s += (PxText $b[1] 30 16 2.6 "#fff3d6") + (PxText $b[2] 30 42 1.6 $b[3])
  $s += (PxText ">" ($w2 - 30) 24 2.4 $b[3]) + "<animate attributeName=`"opacity`" values=`"1`" dur=`"1s`" repeatCount=`"indefinite`"/></svg>"
  Save "$($b[0]).svg" $s
}

# ---------------- outro ----------------
$s = (SvgOpen 1000 120 "Thanks for playing. Data earns its value by serving people.") + "<rect width=`"1000`" height=`"120`" fill=`"#1a1333`"/>"
$s += PxTextS "THANKS FOR PLAYING" 500 22 5 "#fff3d6" "#7a2f78" "middle" 4
$s += PxText "DATA EARNS ITS VALUE BY SERVING PEOPLE." 500 76 2.4 "#6fe3b0" "middle"
$hx = 500 - (PxW "THANKS FOR PLAYING" 5) / 2 - 40
$s += "<g>" + (PxText "~" $hx 26 4 "#ff5d8f") + "<animate attributeName=`"opacity`" values=`"1;.3;1`" dur=`"1.4s`" repeatCount=`"indefinite`"/></g>"
$s += "<g>" + (PxText "~" (1000 - $hx - 24) 26 4 "#ff5d8f") + "<animate attributeName=`"opacity`" values=`".3;1;.3`" dur=`"1.4s`" repeatCount=`"indefinite`"/></g>"
$s += (PxText "SHANGHAI  CN  *  2026" 500 102 1.6 "#a79bd0" "middle") + "</svg>"
Save "outro.svg" $s
