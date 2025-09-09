FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/root/.local/bin

RUN apt-get update && \
    apt-get install -y wget curl ca-certificates gnupg python3 python3-pip jq && \
    rm -rf /var/lib/apt/lists/*

# Detect arch (amd64 or arm64) and download latest stable Geth
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then ARCH_DL="amd64"; \
    elif [ "$ARCH" = "arm64" ]; then ARCH_DL="arm64"; \
    else echo "❌ Unsupported arch: $ARCH" && exit 1; fi && \
    LATEST_URL=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases \
    | jq -r "[.[] | select(.prerelease == false)][0].assets[] | select(.name | test(\"linux-${ARCH_DL}.*tar.gz\")) | .browser_download_url") && \
    wget $LATEST_URL -O geth.tar.gz && \
    tar -xvzf geth.tar.gz && \
    mv geth-*/geth /usr/local/bin/ && \
    rm -rf geth* geth-*

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x start-node.sh

EXPOSE 9636 8000
CMD ["./start-node.sh"]
