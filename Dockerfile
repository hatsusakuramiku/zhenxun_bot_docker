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
    apt install -y --no-install-recommends curl fontconfig fonts-noto-color-emoji bash vim nano procps \
    && apt clean \
    && fc-cache -fv \
    && apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖项和应用代码
COPY --from=build-stage /wheel /wheel
COPY . .

# 确保 start.sh 有执行权限并转换行结束符
RUN ls -la /app/zhenxun_bot/ && \
    sed -i 's/\r$//' /app/zhenxun_bot/start.sh && \
    chmod +x /app/zhenxun_bot/start.sh

RUN pip install --no-cache-dir --no-index --find-links=/wheel -r /wheel/requirements.txt && rm -rf /wheel

RUN playwright install --with-deps chromium \
  && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=metadata-stage /tmp/VERSION /app/VERSION

VOLUME ["/app/zhenxun_bot/data", "/app/zhenxun_bot/resources", "/app/zhenxun_bot/log"]

CMD ["bash", "/app/zhenxun_bot/start.sh"]
