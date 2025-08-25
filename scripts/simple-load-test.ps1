# Simple Load Test Script for Scaling Architecture
# Tests load distribution between Node.js and Spring Boot applications

param(
    [int]$Requests = 20,
    [int]$Delay = 100
)

Write-Host "🚀 Simple Load Test for Scaling Architecture" -ForegroundColor Blue
Write-Host "===============================================" -ForegroundColor Blue
Write-Host "Testing load distribution between services..." -ForegroundColor Yellow
Write-Host ""

$results = @()
$nodeCount = 0
$springCount = 0

for ($i = 1; $i -le $Requests; $i++) {
    Write-Host "Request $i/$Requests..." -NoNewline
    
    try {
        $response = docker run --rm --network testjmeter_scaling-network curlimages/curl:latest curl -s http://scaling-nginx/info
        $jsonResponse = $response | ConvertFrom-Json
        
        # Check hostname against container IDs
        if ($jsonResponse.hostname -eq "78fa34d4f581") {
            $nodeCount++
            $service = "Node.js"
            $color = "Green"
        } elseif ($jsonResponse.hostname -eq "e2b15e9d5392") {
            $springCount++
            $service = "Spring Boot"
            $color = "Cyan"
        } else {
            $service = "Unknown"
            $color = "Yellow"
        }
        
        Write-Host " $service" -ForegroundColor $color
        Write-Host "  Instance: $($jsonResponse.instanceId)" -ForegroundColor Gray
        Write-Host "  Hostname: $($jsonResponse.hostname)" -ForegroundColor Gray
        
        $results += [PSCustomObject]@{
            Request = $i
            Service = $service
            InstanceId = $jsonResponse.instanceId
            Hostname = $jsonResponse.hostname
            Timestamp = $jsonResponse.timestamp
        }
        
    } catch {
        Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    if ($i -lt $Requests) {
        Start-Sleep -Milliseconds $Delay
    }
}

Write-Host ""
Write-Host "📊 Load Distribution Summary" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "Total Requests: $Requests" -ForegroundColor White
Write-Host "Node.js Requests: $nodeCount ($([math]::Round(($nodeCount/$Requests)*100, 1))%)" -ForegroundColor Green
Write-Host "Spring Boot Requests: $springCount ($([math]::Round(($springCount/$Requests)*100, 1))%)" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔍 Detailed Results:" -ForegroundColor Blue
$results | Format-Table -AutoSize

Write-Host ""
Write-Host "✅ Load test completed!" -ForegroundColor Green
