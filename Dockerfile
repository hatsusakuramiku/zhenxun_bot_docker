FROM python:3.11-bookworm AS requirements-stage

WORKDIR /tmp

ENV POETRY_HOME="/opt/poetry" PATH="${PATH}:/opt/poetry/bin"

RUN curl -sSL https://install.python-poetry.org | python - -y && \
  poetry self add poetry-plugin-export

COPY ./pyproject.toml ./poetry.lock* /tmp/

RUN poetry export \
      -f requirements.txt \
      --output requirements.txt \
      --without-hashes \
      --without-urls

FROM python:3.11-bookworm AS build-stage

WORKDIR /wheel

COPY --from=requirements-stage /tmp/requirements.txt /wheel/requirements.txt

# RUN python3 -m pip config set global.index-url https://mirrors.aliyun.com/pypi/simple

RUN pip wheel --wheel-dir=/wheel --no-cache-dir --requirement /wheel/requirements.txt

FROM python:3.11-bookworm AS metadata-stage

WORKDIR /tmp

RUN --mount=type=bind,source=./.git/,target=/tmp/.git/ \
  git describe --tags --exact-match > /tmp/VERSION 2>/dev/null \
  || git rev-parse --short HEAD > /tmp/VERSION \
  && echo "Building version: $(cat /tmp/VERSION)"

FROM python:3.11-slim-bookworm

WORKDIR /app/zhenxun_bot

ENV TZ=Asia/Shanghai PYTHONUNBUFFERED=1 \
    SUPERUSERS='["123456"]' \
    DB_URL="sqlite:data/db/zhenxun.db" \
    HOST="0.0.0.0" \
    PORT="8080" \
    PLATFORM_SUPERUSERS='{"qq": ["123456"], "dodo": [""]}'

EXPOSE 8080

RUN apt update && \
    apt install -y --no-install-recommends curl fontconfig fonts-noto-color-emoji bash vim nano procps git \
    && apt clean \
    && fc-cache -fv \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖项和应用代码
COPY --from=build-stage /wheel /wheel
COPY . .

# 在 /app/zhenxun_bot/ 下直接创建 start.sh
RUN cat <<'EOF' > /app/zhenxun_bot/start.sh
#!/bin/bash
# 真寻机器人 Docker 启动脚本
DEFAULT_SUPERUSERS='["123456"]'
DEFAULT_DB_URL="sqlite:data/db/zhenxun.db"
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="8080"
DEFAULT_PLATFORM_SUPERUSERS='{"qq": ["123456"], "dodo": [""]}'
SUPERUSERS=${SUPERUSERS:-$DEFAULT_SUPERUSERS}
DB_URL=${DB_URL:-$DEFAULT_DB_URL}
HOST=${HOST:-$DEFAULT_HOST}
PORT=${PORT:-$DEFAULT_PORT}
mkdir -p ./data/db
if [ -n "$SUPERUSERS" ]; then
    QQ_USERS=$(echo $SUPERUSERS | sed 's/\\[//;s/\\]//;s/\"//g' | tr ',' ' ')
    PLATFORM_SUPERUSERS='{"qq": ['$(echo $QQ_USERS | sed 's/ /\",\"/g' | sed 's/^/\"/;s/$/\"/')'], "dodo": [""]}'
else
    PLATFORM_SUPERUSERS=${PLATFORM_SUPERUSERS:-$DEFAULT_PLATFORM_SUPERUSERS}
fi
cat > .env.dev << EOFF
SUPERUSERS=$SUPERUSERS
COMMAND_START=[""]
SESSION_RUNNING_EXPRESSION="别急呀,小真寻要宕机了!QAQ"
NICKNAME=["真寻", "小真寻", "绪山真寻", "小寻子"]
SESSION_EXPIRE_TIMEOUT=00:00:30
ALCONNA_USE_COMMAND_START=True
IMAGE_TO_BYTES = True
SELF_NICKNAME="小真寻"
QBOT_ID_DATA = '{

}'
DB_URL = "$DB_URL"
PLATFORM_SUPERUSERS = '$PLATFORM_SUPERUSERS'
DRIVER=~fastapi+~httpx+~websockets
HOST = $HOST
PORT = $PORT
EOFF
echo "配置已更新:"
echo "SUPERUSERS: $SUPERUSERS"
echo "DB_URL: $DB_URL"
echo "HOST: $HOST"
echo "PORT: $PORT"
echo "PLATFORM_SUPERUSERS: $PLATFORM_SUPERUSERS"

# 安装插件依赖（只在容器运行时安装插件依赖，避免重新安装基础依赖）
echo "正在安装插件依赖..."

# 安装内置插件依赖
for plugin_dir in zhenxun/builtin_plugins/*/; do
    if [ -f "$plugin_dir/requirements.txt" ]; then
        echo "正在处理内置插件: $(basename $plugin_dir)"
        pip install --no-cache-dir -r "$plugin_dir/requirements.txt"
    elif [ -f "$plugin_dir/pyproject.toml" ]; then
        echo "正在处理内置插件: $(basename $plugin_dir) (使用poetry)"
        # 尝试使用poetry导出依赖
        cd "$plugin_dir"
        if command -v poetry >/dev/null 2>&1; then
            # 使用poetry导出依赖
            poetry export -f requirements.txt --output /tmp/plugin_requirements_$(basename $plugin_dir).txt --without-hashes --without-urls 2>/dev/null || true
            cd /app/zhenxun_bot
            if [ -f "/tmp/plugin_requirements_$(basename $plugin_dir).txt" ]; then
                pip install --no-cache-dir -r /tmp/plugin_requirements_$(basename $plugin_dir).txt
                rm /tmp/plugin_requirements_$(basename $plugin_dir).txt
            fi
        fi
    fi
done

# 安装插件仓库中的插件依赖
if [ -d "zhenxun/plugins" ]; then
    for plugin_dir in zhenxun/plugins/*/; do
        if [ -f "$plugin_dir/requirements.txt" ]; then
            echo "正在处理插件仓库插件: $(basename $plugin_dir)"
            pip install --no-cache-dir -r "$plugin_dir/requirements.txt"
        elif [ -f "$plugin_dir/pyproject.toml" ]; then
            echo "正在处理插件仓库插件: $(basename $plugin_dir) (使用poetry)"
            # 尝试使用poetry导出依赖
            cd "$plugin_dir"
            if command -v poetry >/dev/null 2>&1; then
                # 使用poetry导出依赖
                poetry export -f requirements.txt --output /tmp/plugin_requirements_$(basename $plugin_dir).txt --without-hashes --without-urls 2>/dev/null || true
                cd /app/zhenxun_bot
                if [ -f "/tmp/plugin_requirements_$(basename $plugin_dir).txt" ]; then
                    pip install --no-cache-dir -r /tmp/plugin_requirements_$(basename $plugin_dir).txt
                    rm /tmp/plugin_requirements_$(basename $plugin_dir).txt
                fi
            fi
        fi
    done
fi

exec python bot.py
EOF
RUN chmod +x /app/zhenxun_bot/start.sh

# 确保 start.sh 有执行权限并转换行结束符
RUN ls -la /app/zhenxun_bot/ && \
    sed -i 's/\\r$//' /app/zhenxun_bot/start.sh && \
    chmod +x /app/zhenxun_bot/start.sh

RUN pip install asyncpg packaging poetry

RUN pip install --no-cache-dir --no-index --find-links=/wheel -r /wheel/requirements.txt && rm -rf /wheel

RUN playwright install --with-deps chromium \
  && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=metadata-stage /tmp/VERSION /app/VERSION

VOLUME ["/app/zhenxun_bot/data", "/app/zhenxun_bot/resources", "/app/zhenxun_bot/log", "/app/zhenxun_bot/zhenxun/plugins"]

CMD ["bash", "/app/zhenxun_bot/start.sh"]