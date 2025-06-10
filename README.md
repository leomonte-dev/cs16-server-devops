## 🚀 Servidor CS 1.6 via Docker

> 💡 Após iniciar o servidor com `start_cs_server.bat`, o CS 1.6 ficará acessível pela porta `27015` do seu IP WSL2 e `28015` para IP Ethernet Windows.

## ⚡ Como rodar

    1. Inicie o Docker Desktop


    2. Clonar repositório
    git clone https://github.com/leomonte-dev/cs16-server-devops.git
    cd cs16-server-devops


    3. Instalar requisitos
    pip install -r requirements.txt


    4. Editar o "users.ini" em /users-adm-config para definir os ADM do servidor
    (OBS: comando "status" no console do cs mostra seu Steam ID! )
    

    5. Editar o ".env.example" para ".env" com as configuracoes locais


    6. Iniciar servidor
    start_cs_server.bat
    (Opcional: start_cs_server.bat <mapa> <max_jogadores>)


    7. Conectar ao servidor
    Abra o CS 1.6
    No console do jogo, use:

    connect IP_DO_WINDOWS:28015 | connect IP_DO_WSL2:27015
    (Substitua pelo IP mostrado após executar o bat)

## 🔌 Informações de Conexão

### 🌐 IPs disponíveis
Execute o script abaixo no PowerShell para ver seus IPs de conexão:
```powershell
.\mostrar-ip.ps1

Exemplo de saída:

=========== Informacoes de Conexão ===========
IP do Windows: 192.168.1.100 192.168.56.1
IP do WSL2: 172.25.14.201

Comandos para conectar no console do CS 1.6:
connect 192.168.1.100:28015    (IP do Windows)
connect 172.25.14.201:27015    (IP do WSL2)

🔄 Alternativas para verificar IPs
Windows: ipconfig (procure por "Ethernet" ou "Wi-Fi")

WSL2: wsl hostname -I


🧱 O que está incluso
Dockerfile: Imagem Docker com HLDS + CS 1.6 otimizada

docker-compose.yml: Configuração padrão com portas mapeadas

docker-compose.override.yml: Personalização do servidor

.env: Configurações básicas do servidor

start_cs_server.bat: Inicializador automático para Windows

mostrar-ip.ps1: Script para identificar IPs de conexão



⚙️ Configurações Padrão
docker-compose.override.yml
yaml
version: "3.8"

services:
  csserver:
    command:
      - "-game"
      - "cstrike"
      - "+maxplayers"
      - "${MAXPLAYERS}"
      - "+map"
      - "${MAP}"
      - "+sv_lan"
      - "0"
      - "+ip"
      - "0.0.0.0"
      - "-port"
      - "27015"
      - "-strictportbind"
    environment:
      MAXPLAYERS: "12"
      MAP: "de_dust2"


.env
MAXPLAYERS=12
MAP=de_dust2


🖥️ Requisitos
Docker Desktop (com WSL2 integrado se usar Linux)
2 GB RAM livre (recomendado)
Conexão estável para download inicial (~500MB)


🛠️ Personalização Avançada

Variável	     Descrição	                    Valores	     Exemplo
MAXPLAYERS	   Número máximo de jogadores	                 12, 16, 32
MAP	           Mapa inicial	                               de_dust2,cs_office,de_inferno
SV_LAN	       Modo LAN                 (0=Internet, 1=LAN)


❓ Troubleshooting
Problemas comuns e soluções:
Conexão recusada?

powershell
## Liberar porta no firewall
New-NetFirewallRule -DisplayName "CS16 Server" -Direction Inbound -Protocol TCP -LocalPort 27015 -Action Allow
Servidor não aparece na LAN?
