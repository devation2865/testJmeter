package com.example.dto;

import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class BatchRequest {
    @NotEmpty(message = "Items list cannot be empty")
    private List<BatchItem> items;

    public BatchRequest() {}

    public BatchRequest(List<BatchItem> items) {
        this.items = items;
    }

    public List<BatchItem> getItems() { return items; }
    public void setItems(List<BatchItem> items) { this.items = items; }

    public static class BatchItem {
        private String id;
        private double value;

        public BatchItem() {}

        public BatchItem(String id, double value) {
            this.id = id;
            this.value = value;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public double getValue() { return value; }
        public void setValue(double value) { this.value = value; }
    }
}
