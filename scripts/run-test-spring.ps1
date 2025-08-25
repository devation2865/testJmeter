# JMeter Spring Boot Scaling Test Script (PowerShell)
# For testing Spring Boot application performance and load distribution

param(
    [string]$TestType = "single",
    [int]$Threads = 100,
    [int]$Duration = 300,
    [int]$Rampup = 30
)

# Configuration
$JMETER_IMAGE = "justb4/jmeter:latest"
$TEST_PLAN = "headless-test.jmx"
$RESULTS_DIR = "./results"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

# Functions
function Write-ColorMessage {
    param([string]$Message, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Message -ForegroundColor Red }
        "Green" { Write-Host $Message -ForegroundColor Green }
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Blue" { Write-Host $Message -ForegroundColor Blue }
        default { Write-Host $Message }
    }
}

function Test-Docker {
    try { docker info | Out-Null; return $true }
    catch { return $false }
}

function Test-Services {
    Write-ColorMessage "Checking service status..." "Blue"
    
    $nginxRunning = docker ps --filter "name=scaling-nginx" --format "table {{.Names}}" | Select-String "scaling-nginx"
    $springRunning = docker ps --filter "name=scaling-app-spring" --format "table {{.Names}}" | Select-String "scaling-app-spring"
    
    if (-not $nginxRunning) {
        Write-ColorMessage "Nginx service not running. Please start the architecture first." "Red"
        Write-ColorMessage "Run: docker-compose up -d" "Yellow"
        exit 1
    }
    
    if (-not $springRunning) {
        Write-ColorMessage "Spring Boot service not running. Please start the architecture first." "Red"
        Write-ColorMessage "Run: docker-compose up -d" "Yellow"
        exit 1
    }
    
    Write-ColorMessage "All services are running normally" "Green"
}

function New-ResultsDirectory {
    if (-not (Test-Path $RESULTS_DIR)) {
        New-Item -ItemType Directory -Path $RESULTS_DIR | Out-Null
        Write-ColorMessage "Created results directory: $RESULTS_DIR" "Blue"
    }
}

function Start-SingleTest {
    param([string]$TestName, [int]$Threads, [int]$Duration, [int]$Rampup)
    
    Write-ColorMessage "Starting test: $TestName" "Blue"
    Write-ColorMessage "  Concurrent users: $Threads" "Yellow"
    Write-ColorMessage "  Test duration: $Duration seconds" "Yellow"
    Write-ColorMessage "  Ramp-up time: $Rampup seconds" "Yellow"
    
    $testResultsDir = "$RESULTS_DIR\$TestName`_$TIMESTAMP"
    New-Item -ItemType Directory -Path $testResultsDir -Force | Out-Null
    
    $dockerArgs = @(
        "run", "--rm",
        "--network", "testjmeter_scaling-network",
        "-v", "$(Get-Location)\jmeter:/tests",
        "-v", "$(Get-Location)\${testResultsDir}:/results",
        "-e", "JMETER_ARGS=-n -t /tests/$TEST_PLAN -l /results/results.jtl -e -o /results/report -Jthreads=$Threads -Jduration=$Duration -Jrampup=$Rampup",
        $JMETER_IMAGE
    )
    
    try {
        docker @dockerArgs
        if ($LASTEXITCODE -eq 0) {
            Write-ColorMessage "Test completed: $TestName" "Green"
            Write-ColorMessage "  Results saved in: $testResultsDir" "Blue"
        } else {
            Write-ColorMessage "Test failed: $TestName" "Red"
        }
    }
    catch {
        Write-ColorMessage "Test execution error: $($_.Exception.Message)" "Red"
    }
    
    Write-Host ""
}

function Show-ResultsSummary {
    Write-ColorMessage "Test Results Summary" "Blue"
    Write-Host "=================================="
    
    if (Test-Path $RESULTS_DIR) {
        Get-ChildItem -Path $RESULTS_DIR -Directory | ForEach-Object {
            $testName = $_.Name
            $jtlFile = Join-Path $_.FullName "results.jtl"
            $reportDir = Join-Path $_.FullName "report"
            
            if (Test-Path $jtlFile) {
                Write-ColorMessage "$testName" "Yellow"
                if (Test-Path $reportDir) {
                    Write-ColorMessage "  HTML Report: $reportDir/index.html" "Green"
                }
                Write-ColorMessage "  Raw Data: $jtlFile" "Green"
            }
        }
    }
}

function Show-Help {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TestType type        Test type: single, multi, custom, all"
    Write-Host "  -Threads number       Concurrent users (default: 100)"
    Write-Host "  -Duration seconds     Test duration (default: 300)"
    Write-Host "  -Rampup seconds       Ramp-up time (default: 30)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType single"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType multi"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType custom -Threads 200 -Duration 600 -Rampup 60"
    Write-Host "  $($MyInvocation.MyCommand.Name) -TestType all"
    Write-Host ""
    Write-Host "Note: This script is specifically for testing Spring Boot application servers"
}

# Main program
function Main {
    Write-ColorMessage "JMeter Spring Boot Scaling Architecture Test Tool (PowerShell)" "Blue"
    Write-Host "=================================="
    
    # Check dependencies
    if (-not (Test-Docker)) {
        Write-ColorMessage "Docker is not running. Please start Docker first." "Red"
        exit 1
    }
    
    Test-Services
    New-ResultsDirectory
    
    # Execute tests based on test type
    switch ($TestType.ToLower()) {
        "single" {
            Start-SingleTest "spring_single_server" 100 300 30
        }
        "multi" {
            Write-ColorMessage "Checking multi-server configuration..." "Blue"
            $springCount = (docker ps --filter "name=scaling-app-spring" --format "table {{.Names}}" | Select-String "scaling-app-spring").Count
            if ($springCount -lt 2) {
                Write-ColorMessage "Warning: Detected less than 2 Spring Boot instances. Consider scaling up first." "Yellow"
                Write-ColorMessage "  Run: docker-compose up -d --scale app-spring=3" "Yellow"
                $continue = Read-Host "Continue testing? (y/N)"
                if ($continue -notmatch "^[Yy]$") {
                    exit 1
                }
            }
            Start-SingleTest "spring_multi_server" 100 300 30
        }
        "custom" {
            Start-SingleTest "spring_custom_test" $Threads $Duration $Rampup
        }
        "all" {
            Write-ColorMessage "Running all test scenarios..." "Blue"
            Start-SingleTest "spring_single_server" 100 300 30
            Start-SingleTest "spring_multi_server" 100 300 30
            Start-SingleTest "spring_high_load" 200 600 60
        }
        default {
            Write-ColorMessage "No test type specified, running default single test" "Yellow"
            Start-SingleTest "spring_single_server" 100 300 30
        }
    }
    
    # Show results summary
    Show-ResultsSummary
    
    Write-ColorMessage "All tests completed!" "Green"
}

# Execute main program
Main
