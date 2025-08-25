package com.example.controller;

import com.example.dto.ComputeRequest;
import com.example.dto.ComputeResponse;
import com.example.dto.DataResponse;
import com.example.dto.StressResponse;
import com.example.dto.BatchRequest;
import com.example.dto.BatchResponse;
import com.example.dto.InfoResponse;
import com.example.dto.HealthResponse;
import com.example.dto.RootResponse;
import com.example.service.TestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@CrossOrigin(origins = "*")
public class TestController {

    @Autowired
    private TestService testService;

    @GetMapping("/health")
    public ResponseEntity<HealthResponse> health() {
        return ResponseEntity.ok(testService.getHealthStatus());
    }

    @GetMapping("/info")
    public ResponseEntity<InfoResponse> info() {
        return ResponseEntity.ok(testService.getInfo());
    }

    @PostMapping("/compute")
    public ResponseEntity<ComputeResponse> compute(@Valid @RequestBody ComputeRequest request) {
        return ResponseEntity.ok(testService.compute(request.getIterations()));
    }

    @GetMapping("/data/{id}")
    public ResponseEntity<DataResponse> getData(@PathVariable String id) {
        return ResponseEntity.ok(testService.getData(id));
    }

    @PostMapping("/batch")
    public ResponseEntity<BatchResponse> processBatch(@Valid @RequestBody BatchRequest request) {
        return ResponseEntity.ok(testService.processBatch(request.getItems()));
    }

    @GetMapping("/stress")
    public ResponseEntity<StressResponse> stress(@RequestParam(defaultValue = "medium") String level) {
        return ResponseEntity.ok(testService.stress(level));
    }

    @GetMapping("/")
    public ResponseEntity<RootResponse> root() {
        return ResponseEntity.ok(testService.getRootInfo());
    }
}
