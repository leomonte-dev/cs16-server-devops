import socket
import threading
import select
import time
import os
from dotenv import load_dotenv

load_dotenv()  # Carrega variáveis de ambiente do arquivo .env

# Configurações - configure seu IP WSL e portas aqui
WSL_IP = os.getenv("WSL_IP")
WSL_PORT = 27015

PROXY_IP = "0.0.0.0"  # Escuta todas interfaces do Windows
PROXY_PORT = 28015

# Buffers maximizados para performance
RECV_BUFFER_SIZE = 2 * 1024 * 1024  # 2 MB
SEND_BUFFER_SIZE = 2 * 1024 * 1024  # 2 MB

# Timeout para remover clientes inativos
CLIENT_TIMEOUT = 60

# Socket cliente (windows) - receber dos players
sock_clients = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECV_BUFFER_SIZE)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SEND_BUFFER_SIZE)
sock_clients.bind((PROXY_IP, PROXY_PORT))
sock_clients.setblocking(False)

# Socket servidor WSL
sock_wsl = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECV_BUFFER_SIZE)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SEND_BUFFER_SIZE)
sock_wsl.bind(("0.0.0.0", 0))  # Porta aleatória para escutar respostas
sock_wsl.setblocking(False)

clients = {}  # { (ip, port): last_active_time }

clients_lock = threading.Lock()

def cleanup_clients():
    while True:
        now = time.time()
        with clients_lock:
            to_remove = [addr for addr, last in clients.items() if now - last > CLIENT_TIMEOUT]
            for addr in to_remove:
                del clients[addr]
        time.sleep(5)  # Limpa rápido, mas não trava threads

def proxy_loop():
    while True:
        rlist, _, _ = select.select([sock_clients, sock_wsl], [], [], 0.01)

        for sock in rlist:
            try:
                data, addr = sock.recvfrom(65536)  # Pacotes até 64KB (UDP max)
            except BlockingIOError:
                continue
            except Exception:
                continue

            if sock is sock_clients:
                # Recebe dos players Windows -> encaminha para WSL
                with clients_lock:
                    clients[addr] = time.time()
                sock_wsl.sendto(data, (WSL_IP, WSL_PORT))


            elif sock is sock_wsl:
                # Recebe do servidor WSL -> encaminha para TODOS players ativos
                with clients_lock:
                    for client_addr in list(clients.keys()):
                        try:
                            sock_clients.sendto(data, client_addr)
                        except Exception:
                            pass

if __name__ == "__main__":
    print(f"Proxy UDP rodando no Windows {PROXY_IP}:{PROXY_PORT}, encaminhando para WSL {WSL_IP}:{WSL_PORT}")

    threading.Thread(target=cleanup_clients, daemon=True).start()
    threading.Thread(target=proxy_loop, daemon=True).start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Proxy finalizado.")
