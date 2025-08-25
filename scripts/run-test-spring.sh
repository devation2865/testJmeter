#!/bin/bash

# JMeter Spring Boot Scaling 架構測試腳本
# 用於測試Spring Boot應用的性能和負載分散效果

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置變量
JMETER_IMAGE="justb4/jmeter:latest"
TEST_PLAN="scaling-test.jmx"
RESULTS_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 函數：打印帶顏色的消息
print_message() {
    echo -e "${2}${1}${NC}"
}

# 函數：檢查Docker是否運行
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_message "❌ Docker未運行，請先啟動Docker" $RED
        exit 1
    fi
}

# 函數：檢查服務是否運行
check_services() {
    print_message "🔍 檢查服務狀態..." $BLUE
    
    if ! docker ps | grep -q "scaling-nginx"; then
        print_message "❌ Nginx服務未運行，請先啟動架構" $RED
        print_message "   運行: docker-compose up -d" $YELLOW
        exit 1
    fi
    
    if ! docker ps | grep -q "scaling-app-spring"; then
        print_message "❌ Spring Boot服務未運行，請先啟動架構" $RED
        print_message "   運行: docker-compose up -d" $YELLOW
        exit 1
    fi
    
    print_message "✅ 所有服務運行正常" $GREEN
}

# 函數：創建結果目錄
create_results_dir() {
    if [ ! -d "$RESULTS_DIR" ]; then
        mkdir -p "$RESULTS_DIR"
        print_message "📁 創建結果目錄: $RESULTS_DIR" $BLUE
    fi
}

# 函數：運行單一測試
run_single_test() {
    local test_name=$1
    local threads=$2
    local duration=$3
    local rampup=$4
    
    print_message "🚀 開始測試: $test_name" $BLUE
    print_message "   並發用戶: $threads" $YELLOW
    print_message "   測試時長: ${duration}秒" $YELLOW
    print_message "   爬升時間: ${rampup}秒" $YELLOW
    
    local test_results_dir="$RESULTS_DIR/${test_name}_${TIMESTAMP}"
    mkdir -p "$test_results_dir"
    
    docker run --rm \
        --network scaling-network \
        -v "$(pwd)/jmeter:/tests" \
        -v "$test_results_dir:/results" \
        -e JMETER_ARGS="-n -t /tests/$TEST_PLAN -l /results/results.jtl -e -o /results/report \
            -Jthreads=$threads -Jduration=$duration -Jrampup=$rampup" \
        $JMETER_IMAGE
    
    if [ $? -eq 0 ]; then
        print_message "✅ 測試完成: $test_name" $GREEN
        print_message "   結果保存在: $test_results_dir" $BLUE
    else
        print_message "❌ 測試失敗: $test_name" $RED
    fi
    
    echo ""
}

# 函數：顯示測試結果摘要
show_results_summary() {
    print_message "📊 測試結果摘要" $BLUE
    echo "=================================="
    
    for dir in "$RESULTS_DIR"/*; do
        if [ -d "$dir" ]; then
            local test_name=$(basename "$dir")
            local jtl_file="$dir/results.jtl"
            local report_dir="$dir/report"
            
            if [ -f "$jtl_file" ]; then
                print_message "📁 $test_name" $YELLOW
                if [ -d "$report_dir" ]; then
                    print_message "   📈 HTML報告: $report_dir/index.html" $GREEN
                fi
                print_message "   📄 原始數據: $jtl_file" $GREEN
            fi
        fi
    done
}

# 函數：顯示幫助信息
show_help() {
    echo "使用方法: $0 [選項]"
    echo ""
    echo "選項:"
    echo "  -h, --help              顯示此幫助信息"
    echo "  -s, --single            運行單一測試 (100用戶, 5分鐘)"
    echo "  -m, --multi             運行多服務器測試 (100用戶, 5分鐘)"
    echo "  -c, --custom <threads> <duration> <rampup>  自定義測試參數"
    echo "  -a, --all               運行所有測試場景"
    echo ""
    echo "示例:"
    echo "  $0 -s                    # 單一測試"
    echo "  $0 -m                    # 多服務器測試"
    echo "  $0 -c 200 600 60         # 200用戶, 10分鐘, 1分鐘爬升"
    echo "  $0 -a                    # 所有測試"
    echo ""
    echo "注意: 此腳本專門測試Spring Boot應用服務器"
}

# 主程序
main() {
    print_message "🔧 JMeter Spring Boot Scaling 架構測試工具" $BLUE
    echo "=================================="
    
    # 檢查依賴
    check_docker
    check_services
    create_results_dir
    
    # 解析命令行參數
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--single)
            run_single_test "spring_single_server" 100 300 30
            ;;
        -m|--multi)
            print_message "🔍 檢查多服務器配置..." $BLUE
            local spring_count=$(docker ps | grep -c "scaling-app-spring" || echo "0")
            if [ "$spring_count" -lt 2 ]; then
                print_message "⚠️  檢測到少於2個Spring Boot實例，建議先擴展服務器" $YELLOW
                print_message "   運行: docker-compose up -d --scale app-spring=3" $YELLOW
                read -p "是否繼續測試? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
            run_single_test "spring_multi_server" 100 300 30
            ;;
        -c|--custom)
            if [ $# -lt 4 ]; then
                print_message "❌ 自定義測試需要3個參數: 用戶數 時長 爬升時間" $RED
                exit 1
            fi
            run_single_test "spring_custom_test" "$2" "$3" "$4"
            ;;
        -a|--all)
            print_message "🔄 運行所有測試場景..." $BLUE
            run_single_test "spring_single_server" 100 300 30
            run_single_test "spring_multi_server" 100 300 30
            run_single_test "spring_high_load" 200 600 60
            ;;
        "")
            print_message "⚠️  未指定測試類型，運行默認單一測試" $YELLOW
            run_single_test "spring_single_server" 100 300 30
            ;;
        *)
            print_message "❌ 未知選項: $1" $RED
            show_help
            exit 1
            ;;
    esac
    
    # 顯示結果摘要
    show_results_summary
    
    print_message "🎉 所有測試完成！" $GREEN
}

# 執行主程序
main "$@"
