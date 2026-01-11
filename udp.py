import socket
import threading
import select
import time
import os
from dotenv import load_dotenv

load_dotenv()

WSL_IP = os.getenv("WSL_IP")
WSL_PORT = 27015
PROXY_IP = "0.0.0.0"
PROXY_PORT = 28015

# BUFFERS MAIORES
RECV_BUFFER_SIZE = 8 * 1024 * 1024  # 8 MB
SEND_BUFFER_SIZE = 8 * 1024 * 1024  # 8 MB
CLIENT_TIMEOUT = 60

sock_clients = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECV_BUFFER_SIZE)
sock_clients.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SEND_BUFFER_SIZE)
# DESABILITA NAGLE (reduz latência)
sock_clients.setsockopt(socket.IPPROTO_IP, socket.IP_TOS, 0x10)  # IPTOS_LOWDELAY
sock_clients.bind((PROXY_IP, PROXY_PORT))
sock_clients.setblocking(False)

sock_wsl = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, RECV_BUFFER_SIZE)
sock_wsl.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SEND_BUFFER_SIZE)
sock_wsl.setsockopt(socket.IPPROTO_IP, socket.IP_TOS, 0x10)
sock_wsl.bind(("0.0.0.0", 0))
sock_wsl.setblocking(False)

clients = {}
clients_lock = threading.Lock()

def cleanup_clients():
    while True:
        now = time.time()
        with clients_lock:
            to_remove = [addr for addr, last in clients.items() if now - last > CLIENT_TIMEOUT]
            for addr in to_remove:
                del clients[addr]
        time.sleep(10)  # Reduzido para economizar CPU

def proxy_loop():
    while True:
        # TIMEOUT REDUZIDO PARA MENOR LATÊNCIA
        rlist, _, _ = select.select([sock_clients, sock_wsl], [], [], 0.0001)
        
        for sock in rlist:
            try:
                data, addr = sock.recvfrom(65536)
            except (BlockingIOError, OSError):
                continue

            if sock is sock_clients:
                if data == b"ping":
                    sock_clients.sendto(b"SUCCESS", addr)
                    continue
                
                with clients_lock:
                    clients[addr] = time.time()
                
                # ENVIO DIRETO SEM DELAY
                try:
                    sock_wsl.sendto(data, (WSL_IP, WSL_PORT))
                except:
                    pass
                
            elif sock is sock_wsl:
                with clients_lock:
                    client_list = list(clients.keys())
                
                # BROADCAST OTIMIZADO
                for client_addr in client_list:
                    try:
                        sock_clients.sendto(data, client_addr)
                    except:
                        pass

if __name__ == "__main__":
    print(f"[PROXY OTIMIZADO] {PROXY_IP}:{PROXY_PORT} -> WSL {WSL_IP}:{WSL_PORT}")
    print(f"[BUFFERS] RX/TX: {RECV_BUFFER_SIZE // 1024 // 1024}MB")
    
    threading.Thread(target=cleanup_clients, daemon=True).start()
    threading.Thread(target=proxy_loop, daemon=True).start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[PROXY] Finalizado")
