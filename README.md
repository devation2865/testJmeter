# JMeter Scaling 架構測試專案

## 專案概述
這個專案模擬了一個可擴展的Web應用架構，使用JMeter進行壓力測試，驗證當增加服務器數量時負載分散的效果。

## 架構組件

### 1. 負載均衡器 (Load Balancer)
- 使用Nginx作為反向代理
- 支援輪詢(round-robin)負載分散
- 可配置健康檢查

### 2. 應用服務器 (Application Servers)
- **Node.js應用**: 基於Express.js的輕量級Web API
- **Spring Boot應用**: 基於Spring Boot 3.2的企業級Web API
- 兩種應用都支援多實例部署
- 每個實例都有唯一標識符
- 可以獨立擴展和測試

### 3. 監控和測試
- JMeter測試腳本
- 性能監控腳本
- 結果分析工具

## 目錄結構
```
testJmeter/
├── app/                    # Node.js應用程序代碼
├── app-spring/             # Spring Boot應用程序代碼
├── nginx/                  # Nginx配置
├── jmeter/                 # JMeter測試腳本
├── docker-compose.yml      # Docker編排文件
├── scripts/                # 部署和測試腳本
└── results/                # 測試結果
```

## 快速開始

### 1. 啟動基礎架構
```bash
docker-compose up -d
```

### 2. 運行JMeter測試

#### 測試Node.js應用
```bash
./scripts/run-test.sh
```

#### 測試Spring Boot應用
```bash
./scripts/run-test-spring.sh
```

### 3. 擴展服務器數量

#### 擴展Node.js服務器
```bash
docker-compose up -d --scale app-node=3
```

#### 擴展Spring Boot服務器
```bash
docker-compose up -d --scale app-spring=3
```

### 4. 重新運行測試
```bash
# 根據需要選擇對應的測試腳本
./scripts/run-test.sh          # Node.js測試
./scripts/run-test-spring.sh   # Spring Boot測試
```

## 測試場景

### 場景1: 單服務器測試
- 1個應用實例 (Node.js或Spring Boot)
- 100並發用戶
- 持續5分鐘

### 場景2: 多服務器測試
- 3個應用實例 (Node.js或Spring Boot)
- 100並發用戶
- 持續5分鐘

### 場景3: 擴展測試
- 從1個實例擴展到5個實例
- 觀察響應時間和吞吐量變化

### 場景4: 技術對比測試
- 比較Node.js和Spring Boot的性能表現
- 相同負載下的響應時間對比
- 內存和CPU使用率對比

## 預期結果
- 多服務器部署應該顯著改善響應時間
- 吞吐量應該隨服務器數量線性增長
- 單點故障風險降低
- Node.js和Spring Boot在不同負載下的性能差異
- JVM和Node.js運行時的資源使用模式對比

## 技術要求
- Docker & Docker Compose
- Java 8+ (JMeter運行環境)
- 至少4GB可用內存
