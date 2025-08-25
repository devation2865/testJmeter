FROM node:18-alpine

# 設置工作目錄
WORKDIR /app

# 複製package文件
COPY package*.json ./

# 安裝依賴 (使用npm install而不是npm ci，更靈活)
RUN npm install --only=production

# 複製應用代碼
COPY . .

# 創建非root用戶
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# 更改文件所有權
RUN chown -R nodejs:nodejs /app
USER nodejs

# 暴露端口
EXPOSE 3000

# 健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# 啟動應用
CMD ["npm", "start"]
