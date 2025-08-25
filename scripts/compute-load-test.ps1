# Compute Load Test Script for Scaling Architecture
# Tests compute-intensive endpoints under load

param(
    [int]$Requests = 20,
    [int]$Delay = 100,
    [int]$Iterations = 1000000
)

Write-Host "🧮 Compute Load Test for Scaling Architecture" -ForegroundColor Blue
Write-Host "==============================================" -ForegroundColor Blue
Write-Host "Testing compute endpoints under load..." -ForegroundColor Yellow
Write-Host ""

$results = @()
$nodeCount = 0
$springCount = 0
$totalResponseTime = 0

for ($i = 1; $i -le $Requests; $i++) {
    Write-Host "Request $i/$Requests..." -NoNewline
    
    $startTime = Get-Date
    
    try {
        $response = docker run --rm --network testjmeter_scaling-network curlimages/curl:latest curl -s -X POST -H "Content-Type: application/json" -d "{\"iterations\": $Iterations}" http://scaling-nginx/compute
        $jsonResponse = $response | ConvertFrom-Json
        
        $endTime = Get-Date
        $responseTime = ($endTime - $startTime).TotalMilliseconds
        $totalResponseTime += $responseTime
        
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
        Write-Host "  Response Time: $([math]::Round($responseTime, 2))ms" -ForegroundColor Gray
        Write-Host "  Compute Time: $($jsonResponse.duration)ms" -ForegroundColor Gray
        Write-Host "  Instance: $($jsonResponse.instanceId)" -ForegroundColor Gray
        
        $results += [PSCustomObject]@{
            Request = $i
            Service = $service
            ResponseTime = $responseTime
            ComputeTime = $jsonResponse.duration
            InstanceId = $jsonResponse.instanceId
            Hostname = $jsonResponse.hostname
            Result = $jsonResponse.result
        }
        
    } catch {
        Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    if ($i -lt $Requests) {
        Start-Sleep -Milliseconds $Delay
    }
}

Write-Host ""
Write-Host "📊 Compute Load Test Summary" -ForegroundColor Blue
Write-Host "=============================" -ForegroundColor Blue
Write-Host "Total Requests: $Requests" -ForegroundColor White
Write-Host "Node.js Requests: $nodeCount ($([math]::Round(($nodeCount/$Requests)*100, 1))%)" -ForegroundColor Green
Write-Host "Spring Boot Requests: $springCount ($([math]::Round(($springCount/$Requests)*100, 1))%)" -ForegroundColor Cyan
Write-Host "Average Response Time: $([math]::Round($totalResponseTime/$Requests, 2))ms" -ForegroundColor Yellow

Write-Host ""
Write-Host "🔍 Performance Analysis:" -ForegroundColor Blue
$nodeResults = $results | Where-Object { $_.Service -eq "Node.js" }
$springResults = $results | Where-Object { $_.Service -eq "Spring Boot" }

if ($nodeResults) {
    $avgNodeResponse = ($nodeResults | Measure-Object -Property ResponseTime -Average).Average
    $avgNodeCompute = ($nodeResults | Measure-Object -Property ComputeTime -Average).Average
    Write-Host "Node.js - Avg Response: $([math]::Round($avgNodeResponse, 2))ms, Avg Compute: $([math]::Round($avgNodeCompute, 2))ms" -ForegroundColor Green
}

if ($springResults) {
    $avgSpringResponse = ($springResults | Measure-Object -Property ResponseTime -Average).Average
    $avgSpringCompute = ($springResults | Measure-Object -Property ComputeTime -Average).Average
    Write-Host "Spring Boot - Avg Response: $([math]::Round($avgSpringResponse, 2))ms, Avg Compute: $([math]::Round($avgSpringCompute, 2))ms" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "✅ Compute load test completed!" -ForegroundColor Green
