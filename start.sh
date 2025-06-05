#!/bin/bash

echo "[*] Subindo servidor CS 1.6 via docker-compose..."
docker-compose up -d --build
echo "[✓] Servidor rodando em udp://localhost:27015"
