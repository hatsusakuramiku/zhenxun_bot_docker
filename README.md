# 真寻机器人 Docker 配置

## 说明

这是基于[zhenxun_bot](https://github.com/zhenxun-org/zhenxun_bot.git)仓库提供的`Dockerfile`进行修改的 Docker 镜像的配置文件的仓库。提供了预构建的镜像[hsmk/zhenxun_bot_docker(Linux amd64)](https://hub.docker.com/repository/docker/hsmk/zhenxun_bot_docker)。

## 🎯 实现的功能

### 1. 环境变量配置

- ✅ 支持通过 `-e` 参数设置 `SUPERUSERS`、`DB_URL`、`HOST`、`PORT`
- ✅ 自动同步 `PLATFORM_SUPERUSERS` 中的 `qq` 平台与 `SUPERUSERS` 保持一致
- ✅ 默认配置：`DB_URL="sqlite:data/db/zhenxun.db"`、`HOST="0.0.0.0"`、`PORT="8080", "SUPERUSERS=[123456]"`

### 2. 调试支持

- ✅ 添加 bash、vim、nano、procps 等调试工具
- ✅ 支持 `docker exec -it zhenxun_bot bash` 进入容器

### 3. 数据持久化

- ✅ 数据卷挂载：`/app/zhenxun_bot/data`、`/app/zhenxun_bot/resources`、`/app/zhenxun_bot/log`

## 📁 核心文件

### Docker Compose 配置

- `docker-compose.yml` - 基础配置（SQLite）
- `docker-compose-mysql.yml` - MySQL 数据库配置
- `docker-compose-postgres.yml` - PostgreSQL 数据库配置
- `Dockerfile` - 构建镜像的 Dockerfile
- `start.sh` - 启动脚本

### 一键启动脚本

- `quick-start.sh` - Linux/macOS 快速启动脚本
- `quick-start.bat` - Windows 快速启动脚本

## 🚀 使用方法

### 一、自行构建

#### 1. 拉取仓库

```bash
git clone https://github.com/hatsusakuramiku/zhenxun_bot_docker.git

# 进入项目目录
cd zhenxun_bot_docker
```

#### 2. 拉取`zhenxun_bot`仓库

```bash
git clone https://github.com/zhenxun-org/zhenxun_bot.git

# 复制并覆盖`Dockerfile`等文件
cp start.sh Dockerfile zhenxun_bot/
```

#### 3. 修改配置文件

选择你要使用的`docker-compose`配置文件，这里以`docker-compose.yml`为例。

1. 修改构建的`Dockerfile`的位置，如果你是按照上述步骤完成的，则修改为 `zhenxun_bot/Dockerfile`。

   ```yml
   build: ./zhenxun_bot/Dockerfile
   ```

2. 修改端口，比如你想时`bot`在主机的`7795`端口

   ```yml
   ports:
     - "7795:8080"
   ```

3. 修改环境变量，将`SUPERUSERS`设置为你的 QQ 号, `DB_URL`设置为你的数据库连接字符串（如果想使用`sqlite`可以不修改）。

   ```yml
   environment:
     # 超级用户配置
     - SUPERUSERS=["你的QQ号"]
     # 数据库配置
     - DB_URL=你的数据库连接字符串
   ```

4. 修改持久化数据路径，将镜像中的`/app/zhenxun_bot/data, /app/zhenxun_bot/resources, /app/zhenxun_bot/log`路径映射到宿主机的指定路径（可以不修改）。

   ```yml
   volumes:
     # 数据持久化
     - ./data:/app/zhenxun_bot/data # bot成功启动一次后会在data目录下生成config.yaml文件，里面是bot的插件的配置信息
     - ./resources:/app/zhenxun_bot/resources # bot的基础资源文件
     - ./log:/app/zhenxun_bot/log # 运行日志
   ```

#### 4. 构建镜像并运行容器

```bash
# 构建镜像并运行容器
docker-commpose -f docker-compose.yml up -d
# 或者
# docker commpose -f docker-compose.yml up -d
```

### 二、使用预构建镜像

#### 1. 拉取仓库

```bash
git clone https://github.com/hatsusakuramiku/zhenxun_bot_docker.git

# 进入项目目录
cd zhenxun_bot_docker
```

#### 2. 修改配置文件

选择你要使用的`docker-compose`配置文件，这里以`docker-compose.yml`为例。

1. 修改镜像。

   ```yml
   image: hsmk/zhenxun_bot_docker:latest
   ```

2. 修改端口，比如你想使`bot`在主机的`7795`端口

   ```yml
   ports:
     - "7795:8080"
   ```

3. 修改环境变量，将`SUPERUSERS`设置为你的 QQ 号, `DB_URL`设置为你的数据库连接字符串（如果想使用`sqlite`可以不修改）。

   ```yml
   environment:
     # 超级用户配置
     - SUPERUSERS=["你的QQ号"]
     # 数据库配置
     - DB_URL=你的数据库连接字符串
   ```

4. 修改持久化数据路径，将镜像中的`/app/zhenxun_bot/data, /app/zhenxun_bot/resources, /app/zhenxun_bot/log`路径映射到宿主机的指定路径（可以不修改）。

   ```yml
   volumes:
     # 数据持久化
     - ./data:/app/zhenxun_bot/data # bot成功启动一次后会在data目录下生成config.yaml文件，里面是bot的插件的配置信息
     - ./resources:/app/zhenxun_bot/resources # bot的基础资源文件
     - ./log:/app/zhenxun_bot/log # 运行日志
   ```

#### 3. 运行容器

```bash
# 构建镜像并运行容器
docker-commpose -f docker-compose.yml up -d
# 或者
# docker commpose -f docker-compose.yml up -d
```

## 🔍 环境变量说明

| 变量名       | 默认值                      | 说明                      |
| ------------ | --------------------------- | ------------------------- |
| `SUPERUSERS` | `["123456"]`                | 超级用户列表（JSON 格式） |
| `DB_URL`     | `sqlite:data/db/zhenxun.db` | 数据库连接 URL            |
| `HOST`       | `0.0.0.0`                   | 服务监听地址              |
| `PORT`       | `8080`                      | 服务监听端口              |

## 📊 支持的数据库

### SQLite（默认）

```yml
sqlite:data/db/zhenxun.db
```

### MySQL

```yml
mysql://username:password@host:port/database
```

### PostgreSQL

```yml
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

启动容器后在宿主机挂载的`~/data`目录下的`config.yaml`文件中设`web-ui`的用户名和密码，然后重启容器。
容器启动后访问：`http://localhost:bot的端口`。
bot 的`web-ui`现在功能已相当完善了，可以方便地进行插件的安装、数据库的管理、插件的配置等操作。

## ⚠️ 注意事项

1. **PLATFORM_SUPERUSERS 自动同步**：设置 `SUPERUSERS` 时会自动更新 `PLATFORM_SUPERUSERS` 中的 `qq` 平台
2. **配置文件生成**：启动时自动生成 `.env.dev` 配置文件
3. **数据持久化**：确保正确挂载数据卷
4. **端口映射**：默认 8080 端口，可自定义
5. **数据库连接**：使用外部数据库时确保网络连通性
