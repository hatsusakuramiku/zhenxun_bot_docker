# 真寻机器人 Docker 配配置

## 🎯 实现的功能

### 1. 环境变量配置

- ✅ 支持通过 `-e` 参数设置 `SUPERUSERS`、`DB_URL`、`HOST`、`PORT`
- ✅ 自动同步 `PLATFORM_SUPERUSERS` 中的 `qq` 平台与 `SUPERUSERS` 保持一致
- ✅ 默认配置：`DB_URL="sqlite:data/db/zhenxun.db"`、`HOST="0.0.0.0"`、`PORT="8080", "SUPERUSERS=[792408751]"`

### 2. 多阶段构建优化

- ✅ 使用 Poetry 导出依赖
- ✅ 预编译 wheel 包加速安装
- ✅ 轻量级最终镜像

### 3. 调试支持

- ✅ 添加 bash、vim、nano、procps 等调试工具
- ✅ 支持 `docker exec -it zhenxun_bot bash` 进入容器

### 4. 数据持久化

- ✅ 数据卷挂载：`/app/zhenxun_bot/data`、`/app/zhenxun_bot/resources`、`/app/zhenxun_bot/log`

## 📁 新增文件

### 核心文件

- `start.sh` - Docker 启动脚本，处理环境变量和配置文件生成
- `DOCKER_USAGE.md` - 详细使用说明文档

### Docker Compose 配置

- `docker-compose.yml` - 基础配置（SQLite）
- `docker-compose-mysql.yml` - MySQL 数据库配置
- `docker-compose-postgres.yml` - PostgreSQL 数据库配置

### 快速启动脚本

- `quick-start.sh` - Linux/macOS 快速启动脚本
- `quick-start.bat` - Windows 快速启动脚本

## 🔧 修改的文件

### Dockerfile

```dockerfile
# 添加调试工具
RUN apt install -y --no-install-recommends curl fontconfig fonts-noto-color-emoji bash vim nano procps

# 设置默认环境变量
ENV TZ=Asia/Shanghai PYTHONUNBUFFERED=1 \
    SUPERUSERS='["792408751"]' \
    DB_URL="sqlite:data/db/zhenxun.db" \
    HOST="0.0.0.0" \
    PORT="8080" \
    PLATFORM_SUPERUSERS='{"qq": ["792408751"], "dodo": [""]}'

# 使用启动脚本
COPY ./start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
```

### .dockerignore

```dockerignore
# .env.dev  # 注释掉，因为启动脚本需要生成这个文件
```

## 🚀 使用方法

### 1. 拉取`zhenxun_bot`仓库

```bash
git clone https://github.com/zhenxun-org/zhenxun_bot.git

# 复制并覆盖`Dockerfile`等文件
cp .dockerignore zhenxun_bot/ && cp Dockerfile zhenxun_bot/ && cp start.sh zhenxun_bot/

# 进入项目目录
cd zhenxun_bot
```

### 2. 基本使用

```bash
# 构建镜像
docker build -t zhenxun_bot .

# 运行容器
docker run -d --name zhenxun_bot -p 8080:8080 \
  -e SUPERUSERS='["123456789"]' \
  -v ./data:/app/zhenxun_bot/data \
  -v ./resources:/app/zhenxun_bot/resources \
  -v ./log:/app/zhenxun_bot/log \
  zhenxun_bot
```

### 3. 使用 Docker Compose

```bash
# SQLite（推荐新手）
docker-compose up -d

# MySQL
docker-compose -f docker-compose-mysql.yml up -d

# PostgreSQL
docker-compose -f docker-compose-postgres.yml up -d
```

### 4. 快速启动

```bash
# Linux/macOS
./quick-start.sh

# Windows
quick-start.bat
```

## 🔍 环境变量说明

| 变量名       | 默认值                      | 说明                      |
| ------------ | --------------------------- | ------------------------- |
| `SUPERUSERS` | `["792408751"]`             | 超级用户列表（JSON 格式） |
| `DB_URL`     | `sqlite:data/db/zhenxun.db` | 数据库连接 URL            |
| `HOST`       | `0.0.0.0`                   | 服务监听地址              |
| `PORT`       | `8080`                      | 服务监听端口              |

## 📊 支持的数据库

### SQLite（默认）

```
sqlite:data/db/zhenxun.db
```

### MySQL

```
mysql://username:password@host:port/database
```

### PostgreSQL

```
postgres://username:password@host:port/database
```

## 🛠️ 调试功能

### 进入容器

```bash
docker exec -it zhenxun_bot bash
```

### 查看日志

```bash
docker logs zhenxun_bot
docker logs -f zhenxun_bot  # 实时日志
```

### 可用工具

- `bash` - Shell 环境
- `vim` - 文本编辑器
- `nano` - 简单文本编辑器
- `ps` - 进程查看
- `top` - 系统监控

## 🌐 Web UI 访问

容器启动后访问：`http://localhost:8080`

## ⚠️ 注意事项

1. **PLATFORM_SUPERUSERS 自动同步**：设置 `SUPERUSERS` 时会自动更新 `PLATFORM_SUPERUSERS` 中的 `qq` 平台
2. **配置文件生成**：启动时自动生成 `.env.dev` 配置文件
3. **数据持久化**：确保正确挂载数据卷
4. **端口映射**：默认 8080 端口，可自定义
5. **数据库连接**：使用外部数据库时确保网络连通性

## 📈 性能优化

- 多阶段构建减少镜像大小
- 预编译 wheel 包加速依赖安装
- 使用 slim 基础镜像
- 清理不必要的缓存和文件

## 🔒 安全考虑

- 使用非 root 用户运行
- 最小化安装的软件包
- 清理构建缓存
- 数据卷隔离
