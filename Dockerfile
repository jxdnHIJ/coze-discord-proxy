# 使用 Golang 镜像作为构建阶段
FROM golang AS builder

# 设置环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

# 设置工作目录
WORKDIR /build

# 复制 go.mod 和 go.sum 文件, 先下载依赖
COPY go.mod go.sum ./
RUN go mod download

# 复制整个项目并构建可执行文件
COPY . .
RUN go build -o /coze-discord-proxy

# 使用 Alpine 镜像作为最终镜像
FROM alpine

# 安装基本的运行时依赖
RUN apk --no-cache add ca-certificates tzdata

# 从构建阶段复制可执行文件
COPY --from=builder /coze-discord-proxy /coze-discord-proxy

# 创建目录并设置权限
RUN mkdir -p /app/coze-discord-proxy/data/config && chmod 777 /app/coze-discord-proxy/data/config

# 写入配置文件
RUN printf '%s' "$BOT_CONFIG" | sed 's/\\/"/g' > /app/coze-discord-proxy/data/config/bot_config.json

# 暴露端口
EXPOSE 7077

# 设置工作目录
WORKDIR /app/coze-discord-proxy/data

# 设置入口命令
ENTRYPOINT ["/coze-discord-proxy"]
