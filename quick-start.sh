#!/bin/bash

# 真寻机器人快速启动脚本

echo "🚀 真寻机器人 Docker 快速启动脚本"
echo "=================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p data resources log zhenxun

# 设置权限
chmod 755 data resources log zhenxun

echo "🔧 选择启动方式："
echo "1) 使用 SQLite 数据库（推荐新手）"
echo "2) 使用 MySQL 数据库"
echo "3) 使用 PostgreSQL 数据库"
echo "4) 自定义配置"

read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo "🐳 使用 SQLite 启动..."
        docker-compose up -d
        ;;
    2)
        echo "🐳 使用 MySQL 启动..."
        docker-compose -f docker-compose-mysql.yml up -d
        ;;
    3)
        echo "🐳 使用 PostgreSQL 启动..."
        docker-compose -f docker-compose-postgres.yml up -d
        ;;
    4)
        echo "🔧 自定义配置启动..."
        read -p "请输入超级用户QQ号 (多个用逗号分隔): " superusers
        read -p "请输入数据库URL (默认: sqlite:data/db/zhenxun.db): " db_url
        read -p "请输入端口 (默认: 8080): " port
        
        # 设置默认值
        db_url=${db_url:-"sqlite:data/db/zhenxun.db"}
        port=${port:-"8080"}
        
        # 构建 SUPERUSERS 格式
        if [ -n "$superusers" ]; then
            superusers_json='['$(echo $superusers | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')']'
        else
            superusers_json='["123456"]'
        fi
        
        echo "🐳 启动容器..."
        docker run -d \
          --name zhenxun_bot \
          -p ${port}:8080 \
          -e SUPERUSERS="$superusers_json" \
          -e DB_URL="$db_url" \
          -e HOST="0.0.0.0" \
          -e PORT="8080" \
          -v $(pwd)/data:/app/zhenxun_bot/data \
          -v $(pwd)/resources:/app/zhenxun_bot/resources \
          -v $(pwd)/log:/app/zhenxun_bot/log \
          zhenxun_bot
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 启动完成！"
echo "🌐 Web UI 地址: http://localhost:${port:-8080}"
echo "📊 查看日志: docker logs zhenxun_bot"
echo "🔧 进入容器: docker exec -it zhenxun_bot bash"
echo ""
echo "📖 更多信息请查看 DOCKER_USAGE.md" 