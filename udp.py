import socket
import threading
import time
import os
from dotenv import load_dotenv

# Carrega variáveis do arquivo .env
load_dotenv()

# IP do servidor WSL rodando CS 1.6
WSL_IP = os.getenv("WSL_IP", "127.0.0.1")
WSL_PORT = int(os.getenv("WSL_PORT", 27015))

# IP e porta onde o proxy escuta no Windows
PROXY_IP = os.getenv("PROXY_IP", "0.0.0.0")
PROXY_PORT = int(os.getenv("PROXY_PORT", 28015))

# Timeout para remover clientes inativos (em segundos)
CLIENT_TIMEOUT = int(os.getenv("CLIENT_TIMEOUT", 60))

# Criar socket UDP
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((PROXY_IP, PROXY_PORT))

# Aumentar buffer do socket para melhorar desempenho
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 65536)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 65536)

# Dicionário thread-safe para mapear clientes conectados { (ip, port): last_active_timestamp }
clients = {}
clients_lock = threading.Lock()

def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}")

def cleanup_clients():
    while True:
        now = time.time()
        with clients_lock:
            inactive = [addr for addr, last in clients.items() if now - last > CLIENT_TIMEOUT]
            for addr in inactive:
                log(f"Removendo cliente inativo {addr}")
                del clients[addr]
        time.sleep(10)

def handle_from_clients():
    while True:
        try:
            data, addr = sock.recvfrom(4096)
            with clients_lock:
                clients[addr] = time.time()
            sock.sendto(data, (WSL_IP, WSL_PORT))
        except ConnectionResetError:
            continue
        except Exception as e:
            log(f"Erro em handle_from_clients: {e}")

def handle_from_wsl():
    while True:
        try:
            data, addr = sock.recvfrom(4096)
            if addr[0] == WSL_IP and addr[1] == WSL_PORT:
                with clients_lock:
                    for client_addr in clients.keys():
                        try:
                            sock.sendto(data, client_addr)
                        except Exception as e:
                            log(f"Erro enviando para cliente {client_addr}: {e}")
        except Exception as e:
            log(f"Erro em handle_from_wsl: {e}")

if __name__ == "__main__":
    log(f"Proxy UDP iniciado. Escutando em {PROXY_IP}:{PROXY_PORT}, encaminhando para {WSL_IP}:{WSL_PORT}")

    threading.Thread(target=cleanup_clients, daemon=True).start()
    threading.Thread(target=handle_from_clients, daemon=True).start()
    threading.Thread(target=handle_from_wsl, daemon=True).start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        log("Proxy finalizado.")
