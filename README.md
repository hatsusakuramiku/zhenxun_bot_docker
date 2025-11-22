# Zhenxun Bot Docker

[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

一个为 [zhenxun_bot](https://github.com/zhenxun-org/zhenxun_bot) 设计的、开箱即用的 Docker & Docker Compose 部署方案。

本项目通过 Git Submodule 集成了 `zhenxun_bot` 的官方源码，无需手动下载或配置，真正实现一键启动。

---

## ✨ 特性

- **🚀 一键启动**：仅需三条命令即可完成完整部署，无需关心环境依赖。
- **📦 开箱即用**：项目已包含 `zhenxun_bot` 源码，克隆后可直接构建。
- **💾 多数据库支持**：提供 SQLite (默认)、MySQL 和 PostgreSQL 的 Docker Compose 配置。
- **🔧 灵活配置**：通过环境变量轻松设置超级用户、端口和数据库连接。
- **🛠️ 调试友好**：内置 `bash`, `vim`, `nano` 等工具，方便进入容器进行调试。
- **🪟 跨平台**：提供 `quick-start.sh` (Linux/macOS) 和 `quick-start.bat` (Windows) 快速启动脚本。

---

## 🚀 快速上手

本项目支持两种部署方式，请根据你的需求任选其一。

### 方式一：从源码构建 (推荐)

此方法会使用最新的 `zhenxun_bot` 官方源码进行构建，适合希望使用最新功能或进行二次开发的用户。

1. **克隆本项目及子模块**

    ```bash
    # --recurse-submodules 参数会自动初始化并拉取 zhenxun_bot 源码
    git clone --recurse-submodules https://github.com/hatsusakuramiku/zhenxun_bot_docker.git
    cd zhenxun_bot_docker
    ```

2. **配置超级用户**

    打开 `docker-compose.yml` 文件，修改 `SUPERUSERS` 环境变量，填入你的 QQ 号。

3. **启动服务**

    运行快速启动脚本，并根据提示选择数据库。

    ```bash
    # Linux / macOS
    ./quick-start.sh

    # Windows
    .\quick-start.bat
    ```

### 方式二：使用预构建镜像

此方法会从 Docker Hub 拉取预构建的镜像，**启动速度更快**，适合不关心构建过程、希望快速部署的用户。

1. **克隆本项目**

    ```bash
    git clone https://github.com/hatsusakuramiku/zhenxun_bot_docker.git
    cd zhenxun_bot_docker
    ```

2. **修改 `docker-compose.yml`**

    打开 `docker-compose.yml` 文件，进行两处修改：

    - **注释掉 `build` 配置**
    - **取消 `image` 配置的注释**

    修改后如下所示：

    ```yaml
    services:
      zhenxun_bot:
        # --- 部署方式二选一 ---
        # 方式一：从源码构建 (推荐，可确保最新)
        # 如果使用此方式，请确保已克隆子模块 (zhenxun_bot 目录非空)
        # build: ./zhenxun_bot

        # 方式二：使用预构建镜像 (启动快，无需构建)
        # 如果使用此方式，请注释掉上面的 `build` 配置
        image: hsmk/zhenxun_bot_docker:latest
    ```

3. **配置超级用户**

    同样在该文件中，修改 `SUPERUSERS` 环境变量，填入你的 QQ 号。

4. **启动服务**

    运行快速启动脚本或 `docker-compose` 命令。

    ```bash
    # 推荐使用快速启动脚本
    ./quick-start.sh

    # 或者直接使用 docker-compose
    # docker-compose up -d
    ```

启动成功后，你可以通过 `http://[Bot所在服务器IP]:8080` 访问 Web UI。

---

## 📁 目录结构

```Text
.
├── zhenxun_bot/         # zhenxun_bot 源码 (Git Submodule)
├── docker-compose.yml   # 默认 Compose 配置 (SQLite)
├── docker-compose-mysql.yml # MySQL Compose 配置
├── docker-compose-postgres.yml # PostgreSQL Compose 配置
├── quick-start.sh       # Linux/macOS 启动脚本
├── quick-start.bat      # Windows 启动脚本
├── Dockerfile           # Docker 镜像构建文件 (位于 zhenxun_bot 目录中)
└── README.md            # 本文档
```

---

## 🗃️ 多数据库支持

本项目默认使用 SQLite，数据存储在 `data/` 目录下。如需使用更强大的数据库，请选择对应的 `docker-compose` 文件。

### MySQL

1. 在 `docker-compose-mysql.yml` 中按需修改数据库密码。
2. 通过以下命令启动：

    ```bash
    docker-compose -f docker-compose-mysql.yml up -d
    ```

### PostgreSQL

1. 在 `docker-compose-postgres.yml` 中按需修改数据库密码。
2. 通过以下命令启动：

    ```bash
    docker-compose -f docker-compose-postgres.yml up -d
    ```

---

## ⚙️ 高级用法

### 环境变量

你可以在 `docker-compose.yml` 文件中修改以下环境变量：

   ```yml
   volumes:
     # 数据持久化
     - ./data:/app/zhenxun_bot/data # bot成功启动一次后会在data目录下生成config.yaml文件，里面是bot的插件的配置信息
     - ./resources:/app/zhenxun_bot/resources # bot的基础资源文件
     - ./log:/app/zhenxun_bot/log # 运行日志
     - ./plugins:/app/zhenxun_bot/zhenxun/plugins # bot的插件，所有安装的非基础插件都在这里
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

4. 修改持久化数据路径，将镜像中的`/app/zhenxun_bot/data, /app/zhenxun_bot/resources, /app/zhenxun_bot/log, /app/zhenxun_bot/plugins`路径映射到宿主机的指定路径（可以不修改）。

   ```yml
   volumes:
     # 数据持久化
     - ./data:/app/zhenxun_bot/data # bot成功启动一次后会在data目录下生成config.yaml文件，里面是bot的插件的配置信息
     - ./resources:/app/zhenxun_bot/resources # bot的基础资源文件
     - ./log:/app/zhenxun_bot/log # 运行日志
     - ./plugins:/app/zhenxun_bot/plugins # 插件目录
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

### 调试与维护

- **查看实时日志**:

  ```bash
  docker logs -f zhenxun_bot
  ```

- **进入容器 Shell**:

  ```bash
  docker exec -it zhenxun_bot bash
  ```

- **停止服务**:

  ```bash
  docker-compose down
  ```

- **更新 `zhenxun_bot` 源码**:
  如果你是通过“方式一”从源码构建的，可以运行以下命令来同步 `zhenxun_bot` 的最新代码：

  ```bash
  git submodule update --remote --merge
  ```

  更新后，重新构建镜像即可生效 (`docker-compose build`)。

- **更新 `zhenxun_bot` 源码**:

  ```bash
  git submodule update --remote --merge
  ```

**注意：更新后需要重新安装插件依赖，否则可能无法正常使用插件**：

  ```bash
  # 进入容器
  docker exec -it zhenxun_bot bash
  # 安装插件依赖 
  pip install [插件对应的依赖包名]
  # 退出容器
  exit
  # 重新启动服务
  docker restart zhenxun_bot
  ``` 
