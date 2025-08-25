package com.example.dto;

import java.time.Instant;

public class HealthResponse {
    private String status;
    private String instanceId;
    private String hostname;
    private Instant timestamp;
    private double uptime;

    public HealthResponse() {}

    public HealthResponse(String status, String instanceId, String hostname, Instant timestamp, double uptime) {
        this.status = status;
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.timestamp = timestamp;
        this.uptime = uptime;
    }

    // Getters and Setters
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }

    public double getUptime() { return uptime; }
    public void setUptime(double uptime) { this.uptime = uptime; }
}
