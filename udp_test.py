import socket
import sys
import os
from dotenv import load_dotenv
load_dotenv()  # Carrega variáveis de ambiente do arquivo .env


PROXY_IP = os.getenv("PROXY_IP")  # Ou o IP da sua máquina Windows
PROXY_PORT = 28015
TIMEOUT = 8  # segundos

try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)

    message = b"ping"
    sock.sendto(message, (PROXY_IP, PROXY_PORT))

    data, addr = sock.recvfrom(1024)  # Espera resposta do proxy

    if data:
        sys.exit(0)  # OK
except Exception as e:
    sys.exit(1)  # Falhou
