# 🎮 CS 1.6 High Performance Server

<div align="center">

![CS 1.6](https://img.shields.io/badge/CS%201.6-Server-orange?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square)
![Tickrate](https://img.shields.io/badge/Tickrate-1000-green?style=flat-square)

**Servidor CS 1.6 otimizado com tickrate 1000 e zero lag**

</div>

---

## 🚀 Como Usar (3 passos)

### 1. **Instalar Requisitos**
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Python 3.8+](https://www.python.org/downloads/)
- WSL2 (Windows) - [Guia de instalação](https://learn.microsoft.com/pt-br/windows/wsl/install)

### 2. **Configurar**

**Clone o repositório e instale dependências:**
```bash
git clone https://github.com/leomonte-dev/cs16-server-devops.git
cd cs16-server-devops
pip install -r requirements.txt
```

**Configure o ambiente:**
```bash
# Descubra o IP do WSL
wsl hostname -I

# Crie o .env baseado no exemplo
copy .env.example .env

# Edite o .env com o IP do WSL
notepad .env
```

**No arquivo `.env`, substitua `SEU_IP_AQUI` pelo IP do WSL:**
```env
WSL_IP=192.168.31.201
```

### 3. **Rodar**
```bash
# Iniciar servidor (de_dust2, 12 players)
start_cs_server.bat

# OU customizar mapa e jogadores
start_cs_server.bat de_inferno 16
```

---

## 🎮 Conectar ao Servidor

Abra o CS 1.6 e no console (`~`):
```
connect SEU_IP:28015
```

> 💡 Use `.\mostrar-ip.ps1` no PowerShell para ver seus IPs disponíveis

---

## ⚙️ Configurações Principais

### **Admins**
Edite `users-adm-config/users.ini`:
```ini
"SeuNick" "STEAM_ID" "abcdefghijklmnopqrstu" "ce"
```
> Use `status` no console do CS para ver seu Steam ID

### **Servidor**
Edite `server.cfg` para customizar:
```cfg
hostname "Meu Servidor"
rcon_password "minhasenha"
mp_startmoney 16000
```

---

## 🛠️ Comandos Úteis
```bash
# Reiniciar servidor
restart_cs_server.bat

# Parar servidor
docker-compose down

# Ver logs
docker logs cs1.6_server-plugin

# Verificar se está rodando
docker ps
```

---

## 🔧 Problemas Comuns

<details>
<summary><b>❌ Não consigo conectar</b></summary>

**Libere as portas no firewall (PowerShell como Admin):**
```powershell
New-NetFirewallRule -DisplayName "CS16 UDP" -Direction Inbound -Protocol UDP -LocalPort 27015,28015 -Action Allow
```

**Verifique se o container está rodando:**
```bash
docker ps
```
</details>

<details>
<summary><b>❌ Proxy UDP não responde</b></summary>

**Verifique o IP do WSL no .env:**
```bash
wsl hostname -I
type .env
```

**Inicie o proxy manualmente:**
```bash
python udp.py
```
</details>

<details>
<summary><b>❌ Servidor com lag</b></summary>

**Configure seu cliente CS 1.6:**
```
cl_updaterate 101
cl_cmdrate 101
rate 100000
fps_max 100
```

**Dê mais recursos no `docker-compose.yml`:**
```yaml
resources:
  limits:
    cpus: '4.0'
    memory: 4G
```
</details>

<details>
<summary><b>❌ Comandos AMX não funcionam</b></summary>

**Use RCON ou configure no server.cfg:**
```
rcon_password suasenha
rcon mp_startmoney 16000
```

OU adicione no `server.cfg`:
```cfg
mp_startmoney 16000
mp_maxmoney 16000
```
</details>

---

## ✨ Features

- ✅ Tickrate 1000 + FPS 1000
- ✅ Network otimizado (sv_maxupdaterate 101)
- ✅ Proxy UDP com buffers de 8MB
- ✅ AMX Mod X pré-instalado
- ✅ Deploy em 1 comando
- ✅ Scripts de start/restart/stop

---

## 📦 Estrutura
```
cs16-server-devops/
├── start_cs_server.bat      # Iniciar
├── restart_cs_server.bat    # Reiniciar
├── server.cfg               # Configs do servidor
├── udp.py                   # Proxy UDP
├── .env.example             # Template de configuração
├── .env                     # IP do WSL (criar baseado no .example)
└── users-adm-config/
    └── users.ini            # Admins
```

---

## 🤝 Contribuir

Pull requests são bem-vindos! Para mudanças grandes, abra uma issue primeiro.

---

## 📞 Suporte

- 🐛 [Issues](https://github.com/leomonte-dev/cs16-server-devops/issues)
- 💬 [Discussions](https://github.com/leomonte-dev/cs16-server-devops/discussions)

---

<div align="center">

**Feito com ❤️ por [Leonardo Monte](https://github.com/leomonte-dev)**

⭐ Se ajudou, deixe uma estrela!

</div>