package com.example.dto;

import java.time.Instant;
import java.util.List;

public class RootResponse {
    private String message;
    private String instanceId;
    private String hostname;
    private List<String> endpoints;
    private Instant timestamp;

    public RootResponse() {}

    public RootResponse(String message, String instanceId, String hostname, 
                       List<String> endpoints, Instant timestamp) {
        this.message = message;
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.endpoints = endpoints;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public List<String> getEndpoints() { return endpoints; }
    public void setEndpoints(List<String> endpoints) { this.endpoints = endpoints; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
}
