import socket
import sys
import os
from dotenv import load_dotenv
load_dotenv()  # Carrega variáveis de ambiente do arquivo .env

PROXY_IP = "127.0.0.1"  # Ou o IP da sua máquina Windows
PROXY_PORT = 28015
TIMEOUT = 6  # segundos

try:
    # print(f"[DEBUG] Tentando conectar ao proxy UDP em {PROXY_IP}:{PROXY_PORT}")

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)

    message = b"ping"
    sock.sendto(message, (PROXY_IP, PROXY_PORT))
    # print("[DEBUG] Mensagem 'ping' enviada, aguardando resposta...")

    data, addr = sock.recvfrom(1024)  # Espera resposta do proxy

    if data:
        # print(f"[DEBUG] Resposta recebida de {addr}: {data}")
        sys.exit(0)  # OK

except Exception as e:
    print(f"[ERRO] Falha na comunicação com o proxy UDP: {e}")
    sys.exit(1)  # Falhou
