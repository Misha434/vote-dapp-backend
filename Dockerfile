# ビルドステージ
FROM golang:1.20.8-slim AS builder

WORKDIR /build

# モジュールファイルをコピーし依存関係をダウンロード
COPY go.mod go.sum ./
RUN go mod download

# ソースコードをコピー
COPY ./cmd/vote-dapp-backend ./cmd/vote-dapp-backend
COPY ./pkg ./pkg
COPY ./proto/gen ./proto/gen

# アプリケーションのビルド
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/vote-dapp-backend/main.go

# 実行ステージ
# distroless base imageを使用
FROM gcr.io/distroless/base-debian10

WORKDIR /app

# ビルドステージから実行可能バイナリをコピー
COPY --from=builder /build/main .

# アプリケーションが使用するポートをEXPOSE
EXPOSE 8080

# アプリケーションを実行
CMD ["./main"]
