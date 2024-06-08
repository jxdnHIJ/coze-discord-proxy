# 使用 Golang 镜像作为构建阶段
FROM golang AS builder

# 设置环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux

# 设置工作目录
WORKDIR /build

# 复制 go.mod 和 go.sum 文件,先下载依赖
COPY go.mod go.sum ./
#ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

# 复制整个项目并构建可执行文件
COPY . .
RUN go build -o /coze-discord-proxy

# 使用 Alpine 镜像作为最终镜像
FROM alpine

# 安装基本的运行时依赖
RUN apk --no-cache add ca-certificates tzdata

FROM deanxv/coze-discord-proxy:latest

RUN mkdir -p /app/coze-discord-proxy/data/config && chmod 777 /app/coze-discord-proxy/data/config
RUN printf '%s' "$BOT_CONFIG" | sed 's/\\/"/g' > /app/coze-discord-proxy/data/config/bot_config.json

WORKDIR /app/coze-discord-proxy/data
EXPOSE 7077

ENTRYPOINT ["/coze-discord-proxy"]
