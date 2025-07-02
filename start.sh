#!/bin/bash

# 真寻机器人 Docker 启动脚本

# 设置默认值
DEFAULT_SUPERUSERS='["123456"]'
DEFAULT_DB_URL="sqlite:data/db/zhenxun.db"
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="8080"
DEFAULT_PLATFORM_SUPERUSERS='{"qq": ["123456"], "dodo": [""]}'

# 从环境变量获取配置，如果没有设置则使用默认值
SUPERUSERS=${SUPERUSERS:-$DEFAULT_SUPERUSERS}
DB_URL=${DB_URL:-$DEFAULT_DB_URL}
HOST=${HOST:-$DEFAULT_HOST}
PORT=${PORT:-$DEFAULT_PORT}

# 处理 PLATFORM_SUPERUSERS，确保 qq 平台与 SUPERUSERS 保持一致
if [ -n "$SUPERUSERS" ]; then
    # 提取 SUPERUSERS 中的 QQ 号
    QQ_USERS=$(echo $SUPERUSERS | sed 's/\[//;s/\]//;s/"//g' | tr ',' ' ')
    # 构建新的 PLATFORM_SUPERUSERS
    PLATFORM_SUPERUSERS='{"qq": ['$(echo $QQ_USERS | sed 's/ /","/g' | sed 's/^/"/;s/$/"/')'], "dodo": [""]}'
else
    PLATFORM_SUPERUSERS=${PLATFORM_SUPERUSERS:-$DEFAULT_PLATFORM_SUPERUSERS}
fi

# 创建或更新 .env.dev 文件
cat > .env.dev << EOF
SUPERUSERS=$SUPERUSERS

COMMAND_START=[""]

SESSION_RUNNING_EXPRESSION="别急呀,小真寻要宕机了!QAQ"

NICKNAME=["真寻", "小真寻", "绪山真寻", "小寻子"]

SESSION_EXPIRE_TIMEOUT=00:00:30

ALCONNA_USE_COMMAND_START=True

# 全局图片统一使用bytes发送，当真寻与协议端不在同一服务器上时为True
IMAGE_TO_BYTES = True

# 回复消息时自称
SELF_NICKNAME="小真寻"

# 官bot appid:bot账号
QBOT_ID_DATA = '{
    
}'

# 数据库配置
DB_URL = "$DB_URL"

# 系统代理
# SYSTEM_PROXY = "http://127.0.0.1:7890"

PLATFORM_SUPERUSERS = '$PLATFORM_SUPERUSERS'

DRIVER=~fastapi+~httpx+~websockets

# LOG_LEVEL=DEBUG

# 服务器和端口
HOST = $HOST
PORT = $PORT

# AccessToken = "set AccessToken here"

# kook adapter toekn
# kaiheila_bots =[{"token": ""}]

# # discode adapter
# DISCORD_BOTS='
# [
#   {
#     "token": "",
#     "intent": {
#       "guild_messages": true,
#       "direct_messages": true
#     },
#     "application_commands": {"*": ["*"]}
#   }
# ]
# '
# DISCORD_PROXY=''

# # dodo adapter
# DODO_BOTS='
# [
#   {
#     "client_id": "",
#     "token": ""
#   }
# ]
# '

# application_commands的{"*": ["*"]}代表将全部应用命令注册为全局应用命令
# {"admin": ["123", "456"]}则代表将admin命令注册为id是123、456服务器的局部命令，其余命令不注册
EOF

echo "配置已更新:"
echo "SUPERUSERS: $SUPERUSERS"
echo "DB_URL: $DB_URL"
echo "HOST: $HOST"
echo "PORT: $PORT"
echo "PLATFORM_SUPERUSERS: $PLATFORM_SUPERUSERS"

# 启动真寻机器人
exec python bot.py 