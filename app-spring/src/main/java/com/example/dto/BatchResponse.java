package com.example.dto;

import java.time.Instant;
import java.util.List;

public class BatchResponse {
    private List<BatchResult> results;
    private int totalItems;
    private long duration;
    private String instanceId;
    private String hostname;
    private Instant timestamp;

    public BatchResponse() {}

    public BatchResponse(List<BatchResult> results, int totalItems, long duration, 
                        String instanceId, String hostname, Instant timestamp) {
        this.results = results;
        this.totalItems = totalItems;
        this.duration = duration;
        this.instanceId = instanceId;
        this.hostname = hostname;
        this.timestamp = timestamp;
    }

    // Getters and Setters
    public List<BatchResult> getResults() { return results; }
    public void setResults(List<BatchResult> results) { this.results = results; }

    public int getTotalItems() { return totalItems; }
    public void setTotalItems(int totalItems) { this.totalItems = totalItems; }

    public long getDuration() { return duration; }
    public void setDuration(long duration) { this.duration = duration; }

    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }

    public String getHostname() { return hostname; }
    public void setHostname(String hostname) { this.hostname = hostname; }

    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }

    public static class BatchResult {
        private String id;
        private boolean processed;
        private double value;
        private String instanceId;

        public BatchResult() {}

        public BatchResult(String id, boolean processed, double value, String instanceId) {
            this.id = id;
            this.processed = processed;
            this.value = value;
            this.instanceId = instanceId;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public boolean isProcessed() { return processed; }
        public void setProcessed(boolean processed) { this.processed = processed; }

        public double getValue() { return value; }
        public void setValue(double value) { this.value = value; }

        public String getInstanceId() { return instanceId; }
        public void setInstanceId(String instanceId) { this.instanceId = instanceId; }
    }
}
