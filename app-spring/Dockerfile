FROM openjdk:17-jdk-alpine

# 設置工作目錄
WORKDIR /app

# 安裝必要的工具
RUN apk add --no-cache curl

# 複製Maven配置文件
COPY pom.xml .

# 複製源代碼
COPY src ./src

# 安裝Maven並構建應用
RUN apk add --no-cache maven && \
    mvn clean package -DskipTests && \
    apk del maven

# 創建非root用戶
RUN addgroup -g 1001 -S javauser && \
    adduser -S javauser -u 1001

# 更改文件所有權
RUN chown -R javauser:javauser /app
USER javauser

# 暴露端口
EXPOSE 3000

# 健康檢查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# 啟動應用
CMD ["java", "-jar", "target/scaling-test-app-1.0.0.jar"]
