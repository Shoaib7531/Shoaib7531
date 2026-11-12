# Satark.AI - Layer 5 Intent & Persuasion Defense Engine
# PowerShell Benchmark Runner

$datasetFile = "$PSScriptRoot\dataset.json"
if (-not (Test-Path $datasetFile)) {
    $datasetFile = "C:\Users\ratho\.gemini\antigravity\brain\faf14187-1ddb-427c-961b-40d250bf31c5\dataset.json"
}

$dataset = Get-Content -Raw -Path $datasetFile | ConvertFrom-Json

$authorities = @('\bcbi\b', '\bpolice\b', '\bcrime branch\b', '\bcustoms\b', '\bnarcotics\b', '\bsupreme court\b', '\bed\b', '\benforcement directorate\b', '\btrai\b', '\btelecom regulatory\b', '\binspector\b', '\barrest warrant\b', '\bnon-bailable\b', '\bcrpf\b', '\bpmla\b', '\bhawala\b', '\bcyber cell\b')
$urgencies = @('\bimmediate\b', '\bimmediately\b', '\bwithin\b', '\btonight\b', '9:30 pm', '\burgent\b', '\bavert\b', 'closing at', 'limited slots', '\bdeactivated\b', '\bshutdown\b', '\btoday\b', '\bminutes\b')
$inversions = @('enter (your )?(upi )?pin', 'scan (this )?qr', 'pin to receive', 'credit deposit', 'receive this money', 'push refund', 'type amount and enter pin', 'receive money in your account')
$unrealistic = @('guaranteed', '300%', '250%', 'vip tier', 'vip merchant', 'bonus', 'lucky draw', 'kbc', 'lottery', '25,00,000', 'discount', 'prepaid security deposit', 'google review', 'per task', 'task pending', 'hotel review', 'youtube review', 'task order', 'affiliate account', 'payout of', 'balance clearance', 'ipo', 'allotment', 'grey market', 'freeze')
$apks = @('\.apk\b', '\bdownload\b', '\bquicksupport\b', '\banydesk\b', '\bteamviewer\b', '\bfastagsupport\b', '\binstall\b')

$tp = 0; $fp = 0; $tn = 0; $fn = 0
$results = @()
$catStats = @{}

foreach ($item in $dataset) {
    $text = "$($item.claim_text) $($item.claimed_persona)".ToLower()
    $claimed = ("$($item.claimed_persona)").ToLower()
    $bene = ("$($item.beneficiary_name)").ToLower()

    $authScore = 0; $urgScore = 0; $invScore = 0; $retScore = 0; $apkScore = 0; $mismatchScore = 0

    foreach ($w in $authorities) { if ($text -match $w) { $authScore += 25 } }
    foreach ($w in $urgencies) { if ($text -match $w) { $urgScore += 15 } }
    foreach ($w in $inversions) { if ($text -match $w) { $invScore += 50 } }
    foreach ($w in $unrealistic) { if ($text -match $w) { $retScore += 25 } }
    foreach ($w in $apks) { if ($text -match $w) { $apkScore += 40 } }

    $isClaimingAuth = ($authScore -gt 0) -or $claimed.Contains('army') -or $claimed.Contains('officer') -or $claimed.Contains('sbi') -or $claimed.Contains('electricity') -or $claimed.Contains('bses')
    $isInstitutional = $bene.Contains('limited') -or $bene.Contains('society') -or $bene.Contains('bbps') -or $bene.Contains('distribution')
    if ($isClaimingAuth -and (-not $isInstitutional)) {
        $mismatchScore = 40
    }

    $callBoost = 0
    # Active call is only suspicious if there is authority, financial inversion, or apk threat
    if ($item.active_call -and (($authScore -gt 0) -or ($invScore -gt 0) -or ($apkScore -gt 0))) {
        $callBoost = 25
    }

    # If it's a known peer-to-peer / family contact without phishing signals, provide safe contact damping
    $isFamilyOrFriend = $claimed.Contains('brother') -or $claimed.Contains('friend') -or $claimed.Contains('landlord') -or $claimed.Contains('colleague')
    $familyDamping = if ($isFamilyOrFriend -and ($authScore -eq 0) -and ($invScore -eq 0) -and ($apkScore -eq 0)) { 20 } else { 0 }

    $rawScore = [Math]::Max(0, ($authScore + $urgScore + $invScore + $retScore + $apkScore + $mismatchScore + $callBoost - $familyDamping))
    $riskScore = [Math]::Min(100, [int][Math]::Round($rawScore * 0.75))

    $pred = if ($riskScore -ge 45) { 'SCAM' } else { 'LEGITIMATE' }
    $truth = $item.ground_truth_label

    $cat = $item.category
    if (-not $catStats.ContainsKey($cat)) {
        $catStats[$cat] = @{ Total = 0; Correct = 0 }
    }
    $catStats[$cat].Total += 1

    if ($truth -eq 'SCAM' -and $pred -eq 'SCAM') {
        $tp++; $catStats[$cat].Correct += 1
    } elseif ($truth -eq 'LEGITIMATE' -and $pred -eq 'SCAM') {
        $fp++
    } elseif ($truth -eq 'LEGITIMATE' -and $pred -eq 'LEGITIMATE') {
        $tn++; $catStats[$cat].Correct += 1
    } elseif ($truth -eq 'SCAM' -and $pred -eq 'LEGITIMATE') {
        $fn++
    }

    $results += [PSCustomObject]@{
        ID = $item.id
        Category = $item.category
        Name = $item.name
        GroundTruth = $truth
        Predicted = $pred
        RiskScore = $riskScore
        Match = ($pred -eq $truth)
    }
}

$total = $dataset.Count
$accuracy = [Math]::Round((($tp + $tn) / $total) * 100, 2)
$precision = [Math]::Round(($tp / ($tp + $fp)) * 100, 2)
$recall = [Math]::Round(($tp / ($tp + $fn)) * 100, 2)
$f1 = [Math]::Round((2 * $precision * $recall) / ($precision + $recall), 2)
$fpr = [Math]::Round(($fp / ($fp + $tn)) * 100, 2)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       SATARK.AI BENCHMARK EVALUATION RESULTS (POWERSHELL)   " -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Total Test Cases  : $total"
Write-Host "True Positives    : $tp" -ForegroundColor Green
Write-Host "False Positives   : $fp" -ForegroundColor $(if ($fp -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "True Negatives    : $tn" -ForegroundColor Green
Write-Host "False Negatives   : $fn" -ForegroundColor $(if ($fn -gt 0) { 'Red' } else { 'Green' })
Write-Host "------------------------------------------------------------"
Write-Host "Overall Accuracy  : $accuracy %" -ForegroundColor Cyan
Write-Host "Recall (Catch Rate: $recall %" -ForegroundColor Green
Write-Host "Precision         : $precision %" -ForegroundColor Cyan
Write-Host "F1-Score          : $f1 %" -ForegroundColor Cyan
Write-Host "False Alarm Rate  : $fpr %" -ForegroundColor Yellow
Write-Host "============================================================"

Write-Host "`nCategory Performance Breakdown:" -ForegroundColor Magenta
foreach ($k in $catStats.Keys) {
    $rate = [Math]::Round(($catStats[$k].Correct / $catStats[$k].Total) * 100, 1)
    Write-Host ("{0,-28} : {1,2}/{2,2} ({3}%)" -f $k, $catStats[$k].Correct, $catStats[$k].Total, $rate)
}
