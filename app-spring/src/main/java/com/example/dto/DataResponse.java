package com.example.dto;

import java.time.Instant;

public class DataResponse {
    private String id;
    private String data;
    private String instanceId;
    private String hostname;
    private Instant timestamp;

    public DataResponse() {}

    public DataResponse(String id, String data, String instanceId, String hostname, Instant timestamp) {
        this.id = id;
        this.data = data;
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getData() { return data; }
    public void setData(String data) { this.data = data; }

    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
}
