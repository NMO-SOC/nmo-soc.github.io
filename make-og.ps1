# Draws og.png, the link-preview card, into the current folder.
# Run it from inside the nmo-soc.github.io repo:
#     powershell -ExecutionPolicy Bypass -File make-og.ps1

Add-Type -AssemblyName System.Drawing

$W = 1200
$H = 630

$plaster   = [System.Drawing.Color]::FromArgb(232, 223, 200)
$plasterD  = [System.Drawing.Color]::FromArgb(207, 194, 164)
$pompeian  = [System.Drawing.Color]::FromArgb(142, 49, 34)
$ochre     = [System.Drawing.Color]::FromArgb(239, 203, 132)
$ink       = [System.Drawing.Color]::FromArgb(36, 28, 23)
$inkSoft   = [System.Drawing.Color]::FromArgb(92, 78, 66)

$bmp = New-Object System.Drawing.Bitmap $W, $H
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# ---- the plaster ground ----
$g.Clear($plaster)

# ---- the cinnabar band, closed with a gold rule ----
$band = 96
$g.FillRectangle((New-Object System.Drawing.SolidBrush $pompeian), 0, 0, $W, $band)
$g.FillRectangle((New-Object System.Drawing.SolidBrush $ochre), 0, $band, $W, 3)

# ---- centred text, with optional letter-spacing ----
function Draw-Centred {
    param($text, $font, $colour, $y, $tracking = 0)

    $brush = New-Object System.Drawing.SolidBrush $colour
    $fmt   = [System.Drawing.StringFormat]::GenericTypographic

    if ($tracking -eq 0) {
        $w = $g.MeasureString($text, $font, 10000, $fmt).Width
        $g.DrawString($text, $font, $brush, [single](($W - $w) / 2), [single]$y, $fmt)
        return
    }

    $widths = @()
    foreach ($c in $text.ToCharArray()) {
        $widths += $g.MeasureString([string]$c, $font, 10000, $fmt).Width
    }
    $total = ($widths | Measure-Object -Sum).Sum + $tracking * ($text.Length - 1)
    $x = ($W - $total) / 2
    for ($i = 0; $i -lt $text.Length; $i++) {
        $g.DrawString([string]$text[$i], $font, $brush, [single]$x, [single]$y, $fmt)
        $x += $widths[$i] + $tracking
    }
}

$fTitle = New-Object System.Drawing.Font("Georgia", 54, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font("Georgia", 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSmall = New-Object System.Drawing.Font("Georgia", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

Draw-Centred "A.D. IV KAL. AVG.  .  MMDCCLXXIX A.V.C.  .  SOL IN LEONE" $fSmall $ochre 34 2
Draw-Centred "NMO . SOC" $fTitle $ink 225 22

# ---- the hedera, flanked by rules ----
$cy  = 372
$pen = New-Object System.Drawing.Pen $plasterD, 2
$g.DrawLine($pen, [single]($W/2 - 210), [single]$cy, [single]($W/2 - 34), [single]$cy)
$g.DrawLine($pen, [single]($W/2 + 34), [single]$cy, [single]($W/2 + 210), [single]$cy)

$leaf = @(
    (New-Object System.Drawing.Point 600,350), (New-Object System.Drawing.Point 585,363),
    (New-Object System.Drawing.Point 574,378), (New-Object System.Drawing.Point 578,391),
    (New-Object System.Drawing.Point 591,392), (New-Object System.Drawing.Point 586,401),
    (New-Object System.Drawing.Point 600,414), (New-Object System.Drawing.Point 614,401),
    (New-Object System.Drawing.Point 609,392), (New-Object System.Drawing.Point 622,391),
    (New-Object System.Drawing.Point 626,378), (New-Object System.Drawing.Point 615,363)
)
$g.FillPolygon((New-Object System.Drawing.SolidBrush $pompeian), $leaf)

Draw-Centred "Guides, tools and resources for English." $fSub $ink 440
Draw-Centred "nmo-soc.github.io" $fSmall $inkSoft 508 3

# ---- save into the folder this was run from ----
$out = Join-Path (Get-Location) "og.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

Write-Host "Wrote $out"
