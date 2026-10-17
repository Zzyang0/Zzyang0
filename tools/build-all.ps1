# Regenerates every image except the heatmap (the GitHub Action refreshes that daily).
foreach ($s in "make-banner", "make-profile", "make-world", "make-ui") { & (Join-Path $PSScriptRoot "$s.ps1") }
