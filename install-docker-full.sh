#!/bin/bash

set -e

echo "🔍 ตรวจสอบ Docker..."

if command -v docker &> /dev/null
then
    echo "✅ Docker ติดตั้งอยู่แล้ว: $(docker --version)"
    exit 0
fi

echo "🚀 เริ่มติดตั้ง Docker..."

# ติดตั้ง dependencies
sudo apt update && sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# เพิ่ม GPG Key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# เพิ่ม Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# อัปเดตและติดตั้ง Docker + Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# เปิดใช้งาน service
sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Docker ติดตั้งเรียบร้อย!"

# เพิ่ม user เข้ากลุ่ม docker
if ! groups $USER | grep -q docker; then
  sudo usermod -aG docker $USER
  echo "👥 เพิ่ม $USER เข้ากลุ่ม docker แล้ว (กรุณา logout/login หรือใช้คำสั่ง: newgrp docker)"
fi

# ทดสอบเวอร์ชัน
echo
docker --version
docker compose version
echo
echo "🎉 พร้อมใช้งาน Docker + Compose แล้ว!"

# ทดสอบ run container เล็กๆ
echo "🧪 ทดสอบ docker run hello-world..."
docker run --rm hello-world || echo "⚠️  ต้อง login ใหม่ก่อนถึงจะใช้ docker โดยไม่ต้อง sudo"

