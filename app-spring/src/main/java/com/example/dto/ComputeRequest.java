package com.example.dto;

import jakarta.validation.constraints.Min;

public class ComputeRequest {
    @Min(value = 1, message = "Iterations must be at least 1")
    private long iterations = 1000000;

    public ComputeRequest() {}

    public ComputeRequest(long iterations) {
        this.iterations = iterations;
    }

    public long getIterations() { return iterations; }
    public void setIterations(long iterations) { this.iterations = iterations; }
}
