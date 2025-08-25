package com.example.dto;

import java.lang.management.MemoryUsage;
import java.time.Instant;

public class InfoResponse {
    private String instanceId;
    private String hostname;
    private int port;
    private String javaVersion;
    private String platform;
    private MemoryUsage memoryUsage;
    private Instant timestamp;

    public InfoResponse() {}

    public InfoResponse(String instanceId, String hostname, int port, String javaVersion, 
                       String platform, MemoryUsage memoryUsage, Instant timestamp) {
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.port = port;
        this.javaVersion = javaVersion;
        this.platform = platform;
        this.memoryUsage = memoryUsage;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public int getPort() { return port; }
    public void setPort(int port) { this.port = port; }

    public String getJavaVersion() { return javaVersion; }
    public void setJavaVersion(String javaVersion) { this.javaVersion = javaVersion; }

    public String getPlatform() { return platform; }
    public void setPlatform(String platform) { this.platform = platform; }

    public MemoryUsage getMemoryUsage() { return memoryUsage; }
    public void setMemoryUsage(MemoryUsage memoryUsage) { this.memoryUsage = memoryUsage; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
}
