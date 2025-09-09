FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/root/.local/bin

RUN apt-get update && \
    apt-get install -y wget curl ca-certificates gnupg python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Geth
RUN wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.13.14-c9a1f42c.tar.gz && \
    tar -xvzf geth-linux-amd64-1.13.14-c9a1f42c.tar.gz && \
    mv geth-linux-amd64-1.13.14-c9a1f42c/geth /usr/local/bin/ && \
    rm -rf geth-linux-amd64-1.13.14-c9a1f42c*

# Install Python deps
WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

RUN chmod +x start-node.sh

EXPOSE 9636 8000

CMD ["./start-node.sh"]
