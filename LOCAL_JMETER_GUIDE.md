# 🎯 本地 JMeter GUI 測試指南

## 📋 前置要求

1. **JMeter 已下載並解壓** (例如: `C:\apache-jmeter-5.6.2`)
2. **Docker 架構正在運行** (Node.js + Spring Boot + Nginx)
3. **PowerShell 環境**

## 🚀 快速開始

### 1. 打開 JMeter GUI

```powershell
# 替換為你的 JMeter 實際路徑
.\scripts\run-local-jmeter.ps1 -JMeterPath "C:\apache-jmeter-5.6.2" -OpenGUI
```

### 2. 運行測試

```powershell
# 替換為你的 JMeter 實際路徑
.\scripts\run-local-jmeter.ps1 -JMeterPath "C:\apache-jmeter-5.6.2" -RunTest
```

## 🔧 手動操作步驟

### 步驟 1: 啟動 JMeter GUI

1. 進入 JMeter 安裝目錄的 `bin` 文件夾
2. 雙擊 `jmeter.bat` (Windows) 或 `jmeter.sh` (Linux/Mac)
3. 等待 GUI 界面加載完成

### 步驟 2: 打開測試計劃

1. 在 JMeter GUI 中點擊 `File` → `Open`
2. 導航到你的項目目錄: `jmeter/local-scaling-test.jmx`
3. 選擇並打開測試計劃

### 步驟 3: 配置測試參數

在測試計劃中，你可以修改以下參數：

- **host**: `localhost` (測試目標)
- **port**: `80` (Nginx 端口)
- **threads**: `50` (並發用戶數)
- **rampup**: `10` (用戶啟動時間，秒)
- **duration**: `120` (測試持續時間，秒)

### 步驟 4: 運行測試

1. 點擊綠色播放按鈕 ▶️ 開始測試
2. 觀察實時結果
3. 點擊停止按鈕 ⏹️ 結束測試

## 📊 測試結果分析

### 實時監控

- **View Results Tree**: 查看每個請求的詳細信息
- **Aggregate Report**: 查看聚合統計數據
- **Summary Report**: 查看摘要報告

### 關鍵指標

- **Throughput**: 每秒請求數 (RPS)
- **Response Time**: 響應時間 (平均值、中位數、95% 分位數)
- **Error Rate**: 錯誤率
- **Active Threads**: 活躍線程數

## 🎛️ 自定義測試場景

### 1. 修改並發用戶數

在 `Thread Group` 中修改 `Number of Threads` 參數

### 2. 調整測試持續時間

在 `Thread Group` 中修改 `Duration` 參數

### 3. 添加新的測試端點

複製現有的 `HTTP Request` 並修改路徑和方法

### 4. 設置不同的負載模式

- **階梯式負載**: 逐步增加用戶數
- **脈衝式負載**: 短時間高負載
- **持續負載**: 長時間穩定負載

## 🔍 故障排除

### 常見問題

1. **連接被拒絕**
   - 檢查 Docker 服務是否運行
   - 確認端口 80 是否可訪問

2. **測試結果為空**
   - 檢查測試計劃配置
   - 確認目標服務正常響應

3. **JMeter 啟動失敗**
   - 檢查 Java 環境
   - 確認 JMeter 路徑正確

### 調試技巧

1. **啟用詳細日誌**
   - 在 JMeter 中設置日誌級別為 DEBUG

2. **使用監聽器**
   - 添加 `Debug Sampler` 查看變量值
   - 使用 `Simple Data Writer` 保存原始數據

3. **檢查網絡**
   - 使用 `ping` 確認網絡連接
   - 檢查防火牆設置

## 📈 性能優化建議

### JMeter 配置

1. **增加堆內存**
   - 修改 `jmeter.bat` 中的 `HEAP` 參數
   - 建議: `-Xms2g -Xmx4g`

2. **調整線程設置**
   - 根據系統性能調整並發數
   - 監控 CPU 和內存使用率

3. **優化測試計劃**
   - 移除不必要的監聽器
   - 使用 `CSV Data Set Config` 進行參數化

### 系統優化

1. **Docker 資源限制**
   - 調整容器內存和 CPU 限制
   - 監控容器性能指標

2. **網絡優化**
   - 使用本地網絡避免網絡延遲
   - 調整 Nginx 緩衝區大小

## 🎯 測試場景示例

### 場景 1: 基本負載測試
- 並發用戶: 50
- 持續時間: 2 分鐘
- 目標: 驗證基本性能

### 場景 2: 壓力測試
- 並發用戶: 200
- 持續時間: 5 分鐘
- 目標: 找出性能瓶頸

### 場景 3: 穩定性測試
- 並發用戶: 100
- 持續時間: 30 分鐘
- 目標: 驗證長期穩定性

## 📚 進階功能

### 1. 參數化測試
- 使用 `CSV Data Set Config` 讀取測試數據
- 動態修改請求參數

### 2. 條件邏輯
- 使用 `If Controller` 實現條件分支
- 根據響應結果選擇不同路徑

### 3. 數據提取
- 使用 `Regular Expression Extractor` 提取響應數據
- 在後續請求中使用提取的數據

### 4. 監控和報告
- 生成 HTML 報告
- 導出 CSV 數據進行分析
- 集成到 CI/CD 流程

## 🎉 總結

使用本地 JMeter GUI 進行測試的優勢：

✅ **靈活性高**: 可以實時調整測試參數
✅ **可視化強**: 實時查看測試結果和圖表
✅ **調試方便**: 可以逐步執行和檢查每個步驟
✅ **功能完整**: 支持所有 JMeter 功能
✅ **無環境限制**: 不需要 Docker 容器

現在你可以開始使用本地 JMeter 進行專業的負載測試了！🎯
