# JMeter Scaling 架構測試腳本 (PowerShell版本)
# 用於運行不同配置的壓力測試

param(
    [Parameter(Position=0)]
    [string]$TestType = "single",
    
    [Parameter(Position=1)]
    [int]$Threads = 100,
    
    [Parameter(Position=2)]
    [int]$Duration = 300,
    
    [Parameter(Position=3)]
    [int]$Rampup = 30
)

# 配置變量
$JMETER_IMAGE = "justb4/jmeter:latest"
$TEST_PLAN = "headless-test.jmx"
$RESULTS_DIR = "./results"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

# 函數：打印帶顏色的消息
function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    switch ($Color) {
        "Red" { Write-Host $Message -ForegroundColor Red }
        "Green" { Write-Host $Message -ForegroundColor Green }
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Blue" { Write-Host $Message -ForegroundColor Blue }
        default { Write-Host $Message }
    }
}

# 函數：檢查Docker是否運行
function Test-Docker {
    try {
        docker info | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# 函數：檢查服務是否運行
function Test-Services {
    Write-ColorMessage "🔍 檢查服務狀態..." "Blue"
    
    $nginxRunning = docker ps --filter "name=scaling-nginx" --format "table {{.Names}}" | Select-String "scaling-nginx"
    $appRunning = docker ps --filter "name=scaling-app" --format "table {{.Names}}" | Select-String "scaling-app"
    
    if (-not $nginxRunning) {
        Write-ColorMessage "❌ Nginx服務未運行，請先啟動架構" "Red"
        Write-ColorMessage "   運行: docker-compose up -d" "Yellow"
        exit 1
    }
    
    if (-not $appRunning) {
        Write-ColorMessage "❌ 應用服務未運行，請先啟動架構" "Red"
        Write-ColorMessage "   運行: docker-compose up -d" "Yellow"
        exit 1
    }
    
    Write-ColorMessage "✅ 所有服務運行正常" "Green"
}

# 函數：創建結果目錄
function New-ResultsDirectory {
    if (-not (Test-Path $RESULTS_DIR)) {
        New-Item -ItemType Directory -Path $RESULTS_DIR | Out-Null
        Write-ColorMessage "📁 創建結果目錄: $RESULTS_DIR" "Blue"
    }
}

# 函數：運行單一測試
function Start-SingleTest {
    param(
        [string]$TestName,
        [int]$Threads,
        [int]$Duration,
        [int]$Rampup
    )
    
    Write-ColorMessage "🚀 開始測試: $TestName" "Blue"
    Write-ColorMessage "   並發用戶: $Threads" "Yellow"
    Write-ColorMessage "   測試時長: ${Duration}秒" "Yellow"
    Write-ColorMessage "   爬升時間: ${Rampup}秒" "Yellow"
    
    $testResultsDir = "$RESULTS_DIR/${TestName}_$TIMESTAMP"
    New-Item -ItemType Directory -Path $testResultsDir -Force | Out-Null
    
    $dockerArgs = @(
        "run", "--rm",
        "--network", "testjmeter_scaling-network",
        "-v", "$(Get-Location)/jmeter:/tests",
        "-v", "${testResultsDir}:/results",
        "-e", "JMETER_ARGS=-n -t /tests/$TEST_PLAN -l /results/results.jtl -e -o /results/report -Jthreads=$Threads -Jduration=$Duration -Jrampup=$Rampup",
        $JMETER_IMAGE
    )
    
    try {
        docker @dockerArgs
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "✅ 測試完成: $TestName" "Green"
            Write-ColorMessage "   結果保存在: $testResultsDir" "Blue"
        } else {
            Write-ColorMessage "❌ 測試失敗: $TestName" "Red"
        }
    }
    catch {
        Write-ColorMessage "❌ 測試執行錯誤: $($_.Exception.Message)" "Red"
    }
    
    Write-Host ""
}

# 函數：顯示測試結果摘要
function Show-ResultsSummary {
    Write-ColorMessage "📊 測試結果摘要" "Blue"
    Write-Host "=================================="
    
    if (Test-Path $RESULTS_DIR) {
        Get-ChildItem -Path $RESULTS_DIR -Directory | ForEach-Object {
            $testName = $_.Name
            $jtlFile = Join-Path $_.FullName "results.jtl"
            $reportDir = Join-Path $_.FullName "report"
            
            if (Test-Path $jtlFile) {
                Write-ColorMessage "📁 $testName" "Yellow"
                if (Test-Path $reportDir) {
                    Write-ColorMessage "   📈 HTML報告: $reportDir/index.html" "Green"
                }
                Write-ColorMessage "   📄 原始數據: $jtlFile" "Green"
            }
        }
    }
}

# 函數：顯示幫助信息
function Show-Help {
    Write-Host "使用方法: $($MyInvocation.MyCommand.Name) [選項]"
    Write-Host ""
    Write-Host "選項:"
    Write-Host "  -TestType <type>      測試類型: single, multi, custom, all"
    Write-Host "  -Threads <number>     並發用戶數 (默認: 100)"
    Write-Host "  -Duration <seconds>   測試時長 (默認: 300)"
    Write-Host "  -Rampup <seconds>     爬升時間 (默認: 30)"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType single"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType multi"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType custom -Threads 200 -Duration 600 -Rampup 60"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType all"
}

# 主程序
function Main {
    Write-ColorMessage "🔧 JMeter Scaling 架構測試工具 (PowerShell)" "Blue"
    Write-Host "=================================="
    
    # 檢查依賴
    if (-not (Test-Docker)) {
        Write-ColorMessage "❌ Docker未運行，請先啟動Docker" "Red"
        exit 1
    }
    
    Test-Services
    New-ResultsDirectory
    
    # 根據測試類型執行相應測試
    switch ($TestType.ToLower()) {
        "single" {
            Start-SingleTest "single_server" 100 300 30
        }
        "multi" {
            Write-ColorMessage "🔍 檢查多服務器配置..." "Blue"
            $appCount = (docker ps --filter "name=scaling-app" --format "table {{.Names}}" | Select-String "scaling-app").Count
            if ($appCount -lt 2) {
                Write-ColorMessage "⚠️  檢測到少於2個應用實例，建議先擴展服務器" "Yellow"
                Write-ColorMessage "   運行: docker-compose up -d --scale app=3" "Yellow"
                $continue = Read-Host "是否繼續測試? (y/N)"
                if ($continue -notmatch "^[Yy]$") {
                    exit 1
                }
            }
            Start-SingleTest "multi_server" 100 300 30
        }
        "custom" {
            Start-SingleTest "custom_test" $Threads $Duration $Rampup
        }
        "all" {
            Write-ColorMessage "🔄 運行所有測試場景..." "Blue"
            Start-SingleTest "single_server" 100 300 30
            Start-SingleTest "multi_server" 100 300 30
            Start-SingleTest "high_load" 200 600 60
        }
        default {
            Write-ColorMessage "⚠️  未指定測試類型，運行默認單一測試" "Yellow"
            Start-SingleTest "single_server" 100 300 30
        }
    }
    
    # 顯示結果摘要
    Show-ResultsSummary
    
    Write-ColorMessage "🎉 所有測試完成！" "Green"
}

# 執行主程序
Main
