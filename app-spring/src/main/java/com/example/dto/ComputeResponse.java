package com.example.dto;

import java.time.Instant;

public class ComputeResponse {
    private double result;
    private long iterations;
    private long duration;
    private String instanceId;
    private String hostname;
    private Instant timestamp;

    public ComputeResponse() {}

    public ComputeResponse(double result, long iterations, long duration, 
                          String instanceId, String hostname, Instant timestamp) {
        this.result = result;
        this.iterations = iterations;
        this.duration = duration;
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public double getResult() { return result; }
    public void setResult(double result) { this.result = result; }

    public long getIterations() { return iterations; }
    public void setIterations(long iterations) { this.iterations = iterations; }

    public long getDuration() { return duration; }
    public void setDuration(long duration) { this.duration = duration; }

    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
}
