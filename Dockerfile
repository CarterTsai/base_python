# 第一階段：編譯 Python
FROM rockylinux:9.3.20231119 AS builder

# 安裝編譯依賴
RUN dnf update -y && dnf install wget gcc zlib zlib-devel make openssl-devel libffi-devel -y
RUN dnf install bzip2-devel sqlite-devel -y

# 下載並解壓 Python
WORKDIR /src
RUN wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar -xzf Python-3.10.13.tgz

# 編譯 Python
WORKDIR /src/Python-3.10.13
RUN ./configure --enable-optimizations && make -j 2 && make altinstall
RUN pip3.10 install --upgrade pip==23.3.2
RUN pip3.10 install -U setuptools==65.5.1

# 第二階段：建立最終 image
FROM rockylinux:9.3.20231119

# 複製編譯好的 Python 到最終 image
COPY --from=builder /usr/local /usr/local

# 建立必要的連結
RUN  rm /usr/bin/python3 && ln -s /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3 && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip

# 設置工作目錄
WORKDIR /app

# 清除快取和不必要的檔案
RUN dnf clean all && dnf clean dbcache && dnf autoremove
