FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências com limpeza automática
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    wget \
    ca-certificates \
    lib32z1 \
    net-tools \
    iproute2 \
    libcurl4-gnutls-dev:i386 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Configurar usuário steam com permissões adequadas
RUN useradd -m -s /bin/bash steam \
 && mkdir -p /home/steam/{steamcmd,hlds} \
 && chown -R steam:steam /home/steam

USER steam

# Definir diretório de trabalho para instalação do steamcmd
WORKDIR /home/steam/steamcmd

# Baixar e instalar steamcmd de forma otimizada
RUN wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -xvzf steamcmd_linux.tar.gz \
 && rm steamcmd_linux.tar.gz \
 && chmod +x steamcmd.sh

# Instalar HLDS com validação rigorosa
RUN ./steamcmd.sh \
    +login anonymous \
    +force_install_dir /home/steam/hlds \
    +app_update 90 validate \
    +app_set_config 90 mod cstrike \
    +quit

# Configurar ambiente Steam corretamente
RUN mkdir -p /home/steam/.steam/sdk32 \
 && cp /home/steam/hlds/steamclient.so /home/steam/.steam/sdk32/ \
 && ln -s /home/steam/hlds/steamclient.so /home/steam/hlds/cstrike

# Configurações otimizadas do servidor
RUN mkdir -p /home/steam/hlds/cstrike \
 && printf "sv_lan 1\nmp_autokick 0\nmp_autoteambalance 0\nsv_region 255\n\
sv_visiblemaxplayers 12\nnet_public_adr 0.0.0.0\nlog on\n\
sv_logbans 1\nsv_logecho 1\nsv_logfile 1\n" > /home/steam/hlds/cstrike/server.cfg \
 && touch /home/steam/hlds/cstrike/{listip.cfg,banned.cfg}

# Definir diretório de trabalho para o servidor HLDS
WORKDIR /home/steam/hlds

# Portas essenciais (TCP + UDP)
EXPOSE 27015/tcp 27015/udp 27020/udp 26900/udp

# Entrypoint otimizado
ENTRYPOINT ["./hlds_run"]
CMD ["-game", "cstrike", "+maxplayers", "12", "+map", "de_dust2", "+sv_lan", "0", "+ip", "0.0.0.0", "-port", "27015", "+net_public_adr", "0.0.0.0", "-debug"]

