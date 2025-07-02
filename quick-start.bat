@echo off
chcp 65001 >nul

echo 🚀 真寻机器人 Docker 快速启动脚本
echo ==================================

REM 检查 Docker 是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未安装，请先安装 Docker
    pause
    exit /b 1
)

REM 检查 Docker Compose 是否安装
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose 未安装，请先安装 Docker Compose
    pause
    exit /b 1
)

REM 创建必要的目录
echo 📁 创建必要的目录...
if not exist "data" mkdir data
if not exist "resources" mkdir resources
if not exist "log" mkdir log
if not exist "zhenxun" mkdir zhenxun

echo 🔧 选择启动方式：
echo 1) 使用 SQLite 数据库（推荐新手）
echo 2) 使用 MySQL 数据库
echo 3) 使用 PostgreSQL 数据库
echo 4) 自定义配置

set /p choice="请选择 (1-4): "

if "%choice%"=="1" (
    echo 🐳 使用 SQLite 启动...
    docker-compose up -d
    set port=8080
) else if "%choice%"=="2" (
    echo 🐳 使用 MySQL 启动...
    docker-compose -f docker-compose-mysql.yml up -d
    set port=8080
) else if "%choice%"=="3" (
    echo 🐳 使用 PostgreSQL 启动...
    docker-compose -f docker-compose-postgres.yml up -d
    set port=8080
) else if "%choice%"=="4" (
    echo 🔧 自定义配置启动...
    set /p superusers="请输入超级用户QQ号 (多个用逗号分隔): "
    set /p db_url="请输入数据库URL (默认: sqlite:data/db/zhenxun.db): "
    set /p port="请输入端口 (默认: 8080): "
    
    REM 设置默认值
    if "%db_url%"=="" set db_url=sqlite:data/db/zhenxun.db
    if "%port%"=="" set port=8080
    
    REM 构建 SUPERUSERS 格式
    if not "%superusers%"=="" (
        set superusers_json=["%superusers:,=","%"]
    ) else (
        set superusers_json=["123456"]
    )
    
    echo 🐳 启动容器...
    docker run -d --name zhenxun_bot -p %port%:8080 -e SUPERUSERS="%superusers_json%" -e DB_URL="%db_url%" -e HOST="0.0.0.0" -e PORT="8080" -v %cd%/data:/app/zhenxun_bot/data -v %cd%/resources:/app/zhenxun_bot/resources -v %cd%/log:/app/zhenxun_bot/log  zhenxun_bot
) else (
    echo ❌ 无效选择
    pause
    exit /b 1
)

echo.
echo ✅ 启动完成！
echo 🌐 Web UI 地址: http://localhost:%port%
echo 📊 查看日志: docker logs zhenxun_bot
echo 🔧 进入容器: docker exec -it zhenxun_bot bash
echo.
echo 📖 更多信息请查看 DOCKER_USAGE.md
pause 