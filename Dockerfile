FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências necessárias para HLDS e AMX Mod X
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
    unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Criar usuário steam e diretórios
RUN useradd -m -s /bin/bash steam \
 && mkdir -p /home/steam/{steamcmd,hlds} \
 && chown -R steam:steam /home/steam

USER steam
WORKDIR /home/steam/steamcmd

# Baixar e instalar steamcmd
RUN wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -xvzf steamcmd_linux.tar.gz \
 && rm steamcmd_linux.tar.gz \
 && chmod +x steamcmd.sh

# Instalar HLDS com validação
RUN ./steamcmd.sh \
    +login anonymous \
    +force_install_dir /home/steam/hlds \
    +app_update 90 validate \
    +app_set_config 90 mod cstrike \
    +quit

# Remove DLL do Windows para evitar erros
RUN rm -f /home/steam/hlds/cstrike/dlls/mp.dll

WORKDIR /home/steam

# Baixar e instalar AMX Mod X v1.8.2 Base Linux (correto para Galileo)
RUN wget https://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz \
 && tar -xvzf amxmodx-1.8.2-base-linux.tar.gz \
 && cp -r addons /home/steam/hlds/cstrike/ \
 && rm amxmodx-1.8.2-base-linux.tar.gz

# Baixar e instalar Metamod 1.21.1 do link oficial AMX Mod X
RUN wget -O /home/steam/metamod.zip https://www.amxmodx.org/release/metamod-1.21.1-am.zip \
 && unzip /home/steam/metamod.zip -d /home/steam/ \
 && rm /home/steam/metamod.zip \
 && mkdir -p /home/steam/hlds/cstrike/addons \
 && rm -rf /home/steam/hlds/cstrike/addons/metamod \
 && mv /home/steam/addons/metamod /home/steam/hlds/cstrike/addons/ \
 && chown -R steam:steam /home/steam/hlds/cstrike/addons/metamod

# Criar arquivo plugins.ini para Metamod carregar AMX Mod X
USER root
RUN echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" > /home/steam/hlds/cstrike/addons/metamod/plugins.ini \
 && chown steam:steam /home/steam/hlds/cstrike/addons/metamod/plugins.ini

# Atualizar liblist.gam para usar Metamod
RUN sed -i 's|gamedll ".*"|gamedll "addons/metamod/dlls/metamod.so"|' /home/steam/hlds/cstrike/liblist.gam \
 && sed -i 's|gamedll_linux ".*"|gamedll_linux "addons/metamod/dlls/metamod.so"|' /home/steam/hlds/cstrike/liblist.gam

# Criar LANGS para AMX Mod X
USER root
RUN mkdir -p /home/steam/hlds/cstrike/addons/amxmodx/data/lang \
 && chown -R steam:steam /home/steam/hlds/cstrike/addons/amxmodx/data/lang


# Voltar a ser usuário steam para copiar plugins e configs
USER steam

# Copiar o plugin Galileo compilado (.amxx), config (.cfg) e linguagem (.lang)
COPY galileo/galileo.amxx /home/steam/hlds/cstrike/addons/amxmodx/plugins/
COPY galileo/galileo.cfg /home/steam/hlds/cstrike/addons/amxmodx/configs/galileo.cfg
COPY galileo/galileo.txt /home/steam/hlds/cstrike/addons/amxmodx/data/lang/galileo.txt

# Copiar seu arquivo users.ini personalizado para configs
COPY users-adm-config/users.ini /home/steam/hlds/cstrike/addons/amxmodx/configs/users.ini

# Adicionar linha para carregar galileo.cfg no amxx.cfg
USER root
RUN grep -qxF 'exec addons/amxmodx/configs/galileo.cfg' /home/steam/hlds/cstrike/addons/amxmodx/configs/amxx.cfg || \
    echo 'exec addons/amxmodx/configs/galileo.cfg' >> /home/steam/hlds/cstrike/addons/amxmodx/configs/amxx.cfg \
 && chown steam:steam /home/steam/hlds/cstrike/addons/amxmodx/configs/amxx.cfg

 
# Remover os arquivos fonte e compiladores (opcional, como limpeza)
USER steam
RUN rm -rf /home/steam/hlds/cstrike/addons/amxmodx/scripting/*

# Ajustar plugins.ini para carregar Galileo
USER root
RUN touch /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini \
 && sed -i '/mapchooser.amxx/d' /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini \
 && sed -i '/nextmap.amxx/d' /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini \
 && sed -i '/timeleft.amxx/d' /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini \
 && echo "galileo.amxx" >> /home/steam/hlds/cstrike/addons/amxmodx/configs/plugins.ini \
 && echo -e "de_dust2\nde_inferno\nde_nuke\nde_train\nde_aztec" > /home/steam/hlds/cstrike/addons/amxmodx/configs/maps.ini \
 && chown -R steam:steam /home/steam/hlds/cstrike/addons/amxmodx/configs

# Configurar ambiente Steam para SDK32
RUN mkdir -p /home/steam/.steam/sdk32 \
 && cp /home/steam/hlds/steamclient.so /home/steam/.steam/sdk32/ \
 && ln -sf /home/steam/hlds/steamclient.so /home/steam/hlds/cstrike/steamclient.so

# Configurações básicas do servidor
RUN mkdir -p /home/steam/hlds/cstrike \
 && printf "sv_lan 0\nmp_autokick 0\nmp_autoteambalance 0\nsv_region 255\n\
sv_visiblemaxplayers 12\nnet_public_adr 0.0.0.0\nlog on\n\
sv_logbans 1\nsv_logecho 1\nsv_logfile 1\n" > /home/steam/hlds/cstrike/server.cfg \
 && touch /home/steam/hlds/cstrike/{listip.cfg,banned.cfg} \
 && chown -R steam:steam /home/steam/hlds/cstrike

WORKDIR /home/steam/hlds

EXPOSE 27015/tcp 27015/udp 27020/udp 26900/udp

ENTRYPOINT ["./hlds_run"]
CMD ["-game", "cstrike", "+maxplayers", "12", "+map", "de_dust2", "+sv_lan", "0", "+ip", "0.0.0.0", "+port", "27015", "+net_public_adr", "0.0.0.0", "-debug"]
