const express = require('express');
const cors = require('cors');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// 中間件
app.use(cors());
app.use(express.json());

// 生成唯一實例ID
const instanceId = Math.random().toString(36).substr(2, 9);
const hostname = os.hostname();

// 健康檢查端點
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    instanceId: instanceId,
    hostname: hostname,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// 基本信息端點
app.get('/info', (req, res) => {
  res.json({
    instanceId: instanceId,
    hostname: hostname,
    port: PORT,
    nodeVersion: process.version,
    platform: process.platform,
    memoryUsage: process.memoryUsage(),
    timestamp: new Date().toISOString()
  });
});

// 模擬計算密集型任務
app.post('/compute', (req, res) => {
  const { iterations = 1000000 } = req.body;
  
  const startTime = Date.now();
  
  // 模擬CPU密集型計算
  let result = 0;
  for (let i = 0; i < iterations; i++) {
    result += Math.sqrt(i) * Math.sin(i);
  }
  
  const endTime = Date.now();
  const duration = endTime - startTime;
  
  res.json({
    result: result,
    iterations: iterations,
    duration: duration,
    instanceId: instanceId,
    hostname: hostname,
    timestamp: new Date().toISOString()
  });
});

// 模擬數據庫查詢
app.get('/data/:id', (req, res) => {
  const { id } = req.params;
  
  // 模擬數據庫延遲
  setTimeout(() => {
    res.json({
      id: id,
      data: `Sample data for ID ${id}`,
      instanceId: instanceId,
      hostname: hostname,
      timestamp: new Date().toISOString()
    });
  }, Math.random() * 100 + 50); // 50-150ms隨機延遲
});

// 批量數據處理
app.post('/batch', (req, res) => {
  const { items = [] } = req.body;
  
  if (items.length === 0) {
    return res.status(400).json({ error: 'No items provided' });
  }
  
  const startTime = Date.now();
  const results = items.map((item, index) => ({
    id: item.id || index,
    processed: true,
    value: item.value * 2,
    instanceId: instanceId
  }));
  
  const endTime = Date.now();
  const duration = endTime - startTime;
  
  res.json({
    results: results,
    totalItems: items.length,
    duration: duration,
    instanceId: instanceId,
    hostname: hostname,
    timestamp: new Date().toISOString()
  });
});

// 壓力測試端點
app.get('/stress', (req, res) => {
  const { level = 'medium' } = req.query;
  
  let iterations;
  switch (level) {
    case 'low':
      iterations = 100000;
      break;
    case 'high':
      iterations = 5000000;
      break;
    default:
      iterations = 1000000;
  }
  
  const startTime = Date.now();
  
  // 模擬CPU壓力
  let result = 0;
  for (let i = 0; i < iterations; i++) {
    result += Math.sqrt(i) * Math.cos(i);
  }
  
  const endTime = Date.now();
  const duration = endTime - startTime;
  
  res.json({
    stressLevel: level,
    iterations: iterations,
    result: result,
    duration: duration,
    instanceId: instanceId,
    hostname: hostname,
    timestamp: new Date().toISOString()
  });
});

// 根端點
app.get('/', (req, res) => {
  res.json({
    message: 'Scaling Test Application',
    instanceId: instanceId,
    hostname: hostname,
    endpoints: [
      '/health - Health check',
      '/info - Instance information',
      '/compute - CPU intensive task',
      '/data/:id - Simulated database query',
      '/batch - Batch processing',
      '/stress - Stress testing endpoint'
    ],
    timestamp: new Date().toISOString()
  });
});

// 啟動服務器
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Instance ID: ${instanceId}`);
  console.log(`🖥️  Hostname: ${hostname}`);
  console.log(`⏰ Started at: ${new Date().toISOString()}`);
});

// 優雅關閉
process.on('SIGTERM', () => {
  console.log('🛑 SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🛑 SIGINT received, shutting down gracefully');
  process.exit(0);
});
