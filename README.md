# docker-virt-manager
The image I was using dissapeared from hub.
- recreated from: https://github.com/valentin-nasta/docker-virt-manager using the same https://github.com/jlesage/docker-baseimage-gui
- VM compiled from master: https://github.com/virt-manager/virt-manager

# example docker-compose.yml
```
version: '3.9'

services:

#--------------------------------------------------------------- #
### virt-manager
# -------------------------------------------------------------- #
  virt-manager-dev:
    image: popoviciri/docker-virt-manager
    container_name: virt-manager-dev
    restart: always
    ports:
      - 5800:5800
      - 5900:5800
    volumes:
      - ./data/virt-manager-dev:/config
      - /dev/urandom:/dev/urandom:ro
```
