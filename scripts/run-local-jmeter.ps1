# Local JMeter GUI Test Script for Scaling Architecture
# For running JMeter tests locally with GUI interface

param(
    [string]$JMeterPath = "",
    [string]$TestPlan = "scaling-test.jmx",
    [switch]$OpenGUI,
    [switch]$RunTest
)

Write-Host "🎯 Local JMeter GUI Test Script" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue

# Check if JMeter path is provided
if (-not $JMeterPath) {
    Write-Host "請提供 JMeter 安裝路徑" -ForegroundColor Yellow
    Write-Host "例如: .\scripts\run-local-jmeter.ps1 -JMeterPath 'C:\apache-jmeter-5.6.2'" -ForegroundColor White
    Write-Host ""
    Write-Host "或者使用以下選項:" -ForegroundColor Yellow
    Write-Host "  -OpenGUI    只打開 JMeter GUI" -ForegroundColor White
    Write-Host "  -RunTest    運行測試計劃" -ForegroundColor White
    exit 1
}

# Check if JMeter exists
$jmeterBat = Join-Path $JMeterPath "bin\jmeter.bat"
if (-not (Test-Path $jmeterBat)) {
    Write-Host "❌ 找不到 JMeter: $jmeterBat" -ForegroundColor Red
    Write-Host "請檢查 JMeter 安裝路徑是否正確" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 找到 JMeter: $jmeterBat" -ForegroundColor Green

# Check if test plan exists
$testPlanPath = Join-Path (Get-Location) "jmeter\$TestPlan"
if (-not (Test-Path $testPlanPath)) {
    Write-Host "❌ 找不到測試計劃: $testPlanPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 找到測試計劃: $testPlanPath" -ForegroundColor Green

# Function to open JMeter GUI
function Open-JMeterGUI {
    Write-Host "🚀 正在打開 JMeter GUI..." -ForegroundColor Blue
    
    $args = @(
        "-t", $testPlanPath,
        "-H", "localhost",
        "-P", "80"
    )
    
    try {
        Start-Process -FilePath $jmeterBat -ArgumentList $args -NoNewWindow
        Write-Host "✅ JMeter GUI 已打開" -ForegroundColor Green
        Write-Host "📝 提示: 在 GUI 中點擊綠色播放按鈕開始測試" -ForegroundColor Yellow
    }
    catch {
        Write-Host "❌ 打開 JMeter GUI 失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to run JMeter test
function Run-JMeterTest {
    Write-Host "🧪 正在運行 JMeter 測試..." -ForegroundColor Blue
    
    $resultsDir = Join-Path (Get-Location) "results\local-test-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
    
    $args = @(
        "-n",  # Non-GUI mode
        "-t", $testPlanPath,
        "-l", "$resultsDir\results.jtl",
        "-e",  # Generate HTML report
        "-o", "$resultsDir\report",
        "-H", "localhost",
        "-P", "80"
    )
    
    try {
        Write-Host "📊 測試結果將保存到: $resultsDir" -ForegroundColor Yellow
        Write-Host "⏳ 正在執行測試..." -ForegroundColor Blue
        
        & $jmeterBat @args
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 測試完成!" -ForegroundColor Green
            Write-Host "📁 結果文件: $resultsDir\results.jtl" -ForegroundColor Blue
            Write-Host "🌐 HTML 報告: $resultsDir\report\index.html" -ForegroundColor Blue
            
            # Open results folder
            Start-Process "explorer.exe" -ArgumentList $resultsDir
        } else {
            Write-Host "❌ 測試失敗，退出碼: $LASTEXITCODE" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ 運行測試失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
if ($OpenGUI) {
    Open-JMeterGUI
} elseif ($RunTest) {
    Run-JMeterTest
} else {
    Write-Host "🔧 使用說明:" -ForegroundColor Blue
    Write-Host "  1. 打開 JMeter GUI: .\scripts\run-local-jmeter.ps1 -JMeterPath '你的JMeter路徑' -OpenGUI" -ForegroundColor White
    Write-Host "  2. 運行測試: .\scripts\run-local-jmeter.ps1 -JMeterPath '你的JMeter路徑' -RunTest" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 測試計劃文件:" -ForegroundColor Blue
    Get-ChildItem -Path "jmeter" -Filter "*.jmx" | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
}
