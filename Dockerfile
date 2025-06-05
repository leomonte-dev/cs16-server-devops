FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
  && apt update \
  && apt install -y wget ca-certificates lib32gcc-s1 libsdl1.2debian libstdc++6:i386 libgcc1:i386 \
  && useradd -m steam

USER steam
WORKDIR /home/steam

RUN mkdir steamcmd && cd steamcmd \
  && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
  && tar -xvzf steamcmd_linux.tar.gz

WORKDIR /home/steam/hlds

RUN ../steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/hlds +app_update 90 validate +quit

EXPOSE 27015/udp 27005/udp 26900/udp

CMD ["./hlds_run", "-game", "cstrike", "+maxplayers", "12", "+map", "de_dust2"]
