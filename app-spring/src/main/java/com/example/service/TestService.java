package com.example.service;

import com.example.dto.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.scheduling.annotation.Async;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryUsage;
import java.net.InetAddress;
import java.time.Instant;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class TestService {

    private final String instanceId;
    private final String hostname;
    private final Random random = new Random();

    public TestService() {
        this.instanceId = UUID.randomUUID().toString().substring(0, 9);
        String tempHostname;
        try {
            tempHostname = InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            tempHostname = "unknown";
        }
        this.hostname = tempHostname;
    }

    public HealthResponse getHealthStatus() {
        return new HealthResponse(
            "healthy",
            instanceId,
            hostname,
            Instant.now(),
            ManagementFactory.getRuntimeMXBean().getUptime() / 1000.0
        );
    }

    public InfoResponse getInfo() {
        MemoryUsage heapMemoryUsage = ManagementFactory.getMemoryMXBean().getHeapMemoryUsage();
        return new InfoResponse(
            instanceId,
            hostname,
            3000,
            System.getProperty("java.version"),
            System.getProperty("os.name"),
            heapMemoryUsage,
            Instant.now()
        );
    }

    public ComputeResponse compute(long iterations) {
        long startTime = System.currentTimeMillis();
        
        double result = 0.0;
        for (long i = 0; i < iterations; i++) {
            result += Math.sqrt(i) * Math.sin(i);
        }
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        return new ComputeResponse(
            result,
            iterations,
            duration,
            instanceId,
            hostname,
            Instant.now()
        );
    }

    @Async
    public DataResponse getData(String id) {
        // 模擬數據庫延遲
        try {
            Thread.sleep(random.nextInt(100) + 50); // 50-150ms隨機延遲
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return new DataResponse(
            id,
            "Sample data for ID " + id,
            instanceId,
            hostname,
            Instant.now()
        );
    }

    public BatchResponse processBatch(List<BatchRequest.BatchItem> items) {
        long startTime = System.currentTimeMillis();
        
        List<BatchResponse.BatchResult> results = items.stream()
            .map(item -> new BatchResponse.BatchResult(
                item.getId() != null ? item.getId() : String.valueOf(items.indexOf(item)),
                true,
                item.getValue() * 2,
                instanceId
            ))
            .collect(Collectors.toList());
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        return new BatchResponse(
            results,
            items.size(),
            duration,
            instanceId,
            hostname,
            Instant.now()
        );
    }

    public StressResponse stress(String level) {
        long iterations;
        switch (level.toLowerCase()) {
            case "low":
                iterations = 100000;
                break;
            case "high":
                iterations = 5000000;
                break;
            default:
                iterations = 1000000;
        }
        
        long startTime = System.currentTimeMillis();
        
        double result = 0.0;
        for (long i = 0; i < iterations; i++) {
            result += Math.sqrt(i) * Math.cos(i);
        }
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        return new StressResponse(
            level,
            iterations,
            result,
            duration,
            instanceId,
            hostname,
            Instant.now()
        );
    }

    public RootResponse getRootInfo() {
        List<String> endpoints = List.of(
            "/health - Health check",
            "/info - Instance information",
            "/compute - CPU intensive task",
            "/data/:id - Simulated database query",
            "/batch - Batch processing",
            "/stress - Stress testing endpoint"
        );
        
        return new RootResponse(
            "Spring Boot Scaling Test Application",
            instanceId,
            hostname,
            endpoints,
            Instant.now()
        );
    }
}
