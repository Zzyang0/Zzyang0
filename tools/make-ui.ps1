# Builds the project cards, the small section label and the contact pills.
#   powershell -ExecutionPolicy Bypass -File tools/make-ui.ps1
. "$PSScriptRoot\px.ps1"
$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root "assets"
$up = [string][char]0x2197
$zhwen = Z 0x4E2D, 0x6587

# ---------------- projects ----------------
$projects = @(
  @{ f = "q1"; t = "FRANK.DB"; k = "WEB, 2026"; l1 = "This portfolio, built like a database:"; l2 = "3D city, SQL console, EN / $zhwen."; tags = @("JavaScript", "Three.js") },
  @{ f = "q2"; t = "Mass Save research"; k = "ANALYSIS, 2025"; l1 = "15 years of Massachusetts energy data:"; l2 = "cost to deliver, heat pumps, retrofits."; tags = @("Python", "Pandas") },
  @{ f = "q3"; t = "Kobo to SharePoint"; k = "PIPELINE, 2025"; l1 = "Field media straight into SharePoint,"; l2 = "incremental uploads, duplicate checks."; tags = @("Python", "Graph API") },
  @{ f = "q4"; t = "AccentRecognition"; k = "ML, 2025"; l1 = "Fine-tuned wav2vec2 on 167K+ clips to"; l2 = "tell 11 English accents apart (Flask)."; tags = @("PyTorch", "Flask") },
  @{ f = "q5"; t = "Chronic disease risk"; k = "ML TEAM, 2024"; l1 = "Predictive models and clustering on"; l2 = "NHANES survey data, Berkeley team."; tags = @("scikit-learn", "Jupyter") },
  @{ f = "q6"; t = "COVID-19 analysis"; k = "DASHBOARD, 2022"; l1 = "Vaccinations, cases and deaths worldwide"; l2 = "with Plotly / Dash and a Tableau book."; tags = @("Python", "Plotly", "Tableau") }
)
$n = 0
foreach ($q in $projects) {
  $n++
  $W = 320; $H = 152
  $s = (SvgOpen $W $H "Project: $($q.t)") + (Card 0 0 $W $H)
  $s += PxText ("{0:00}" -f $n) 20 16 2 $T.amber
  $s += Txt $q.k.ToLower() 300 28 11 $T.dim 400 "end"
  $s += Txt $q.t 20 62 18 $T.head 600
  $s += Txt $q.l1 20 88 12.5 $T.mute 400
  $s += Txt $q.l2 20 106 12.5 $T.mute 400
  $tx = 20
  foreach ($tg in $q.tags) { $pl = Pill $tx 120 $tg 11; $s += $pl.svg; $tx += $pl.w + 6 }
  $s += Txt $up 298 140 16 $T.amber 400 "end"
  $s += "</svg>"
  SaveSvg (Join-Path $assets "$($q.f).svg") $s
}

# ---------------- section label ----------------
$label = "SELECTED WORK"
$s = (SvgOpen 1000 28 $label) + (PxText $label 4 7 2 $T.amber) + "<path d=`"M$(N (4 + (PxW $label 2) + 16)) 14H996`" stroke=`"$($T.line)`"/></svg>"
SaveSvg (Join-Path $assets "h-projects.svg") $s

# ---------------- contact pills ----------------
$btns = @(@("b-site", "Portfolio", "zzyang0.github.io"), @("b-linkedin", "LinkedIn", "connect"), @("b-insta", "Instagram", "@zzyang0528"), @("b-mail", "Email", "say hi"))
foreach ($b in $btns) {
  $w2 = 232; $h2 = 52
  $s = (SvgOpen $w2 $h2 $b[1]) + (Card 0 0 $w2 $h2 26)
  $s += "<rect x=`"22`" y=`"$(($h2 / 2) - 3)`" width=`"6`" height=`"6`" fill=`"$($T.amber)`" shape-rendering=`"crispEdges`"/>"
  $s += Txt $b[1] 40 23 14 $T.head 600
  $s += Txt $b[2] 40 40 11.5 $T.mute 400
  $s += Txt $up 206 31 16 $T.amber 400 "end"
  $s += "</svg>"
  SaveSvg (Join-Path $assets "$($b[0]).svg") $s
}
