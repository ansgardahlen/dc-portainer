#!/bin/bash

if [[ -f portainer.conf ]]; then
  read -r -p "config file portainer.conf exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv portainer.conf portainer.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$PUBLIC_FQDN" ]; then
  read -p "Hostname (FQDN): " -ei "portainer.example.org" PUBLIC_FQDN
fi

if [ -z "$ADMIN_MAIL" ]; then
  read -p "Portainer admin Mail address: " -ei "mail@example.com" ADMIN_MAIL
fi

[[ -f /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
fi


DBNAME=portainer
DBUSER=portainer
DBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

HTTP_PORT=9000
PORTAINER_PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
ENC_PORTAINER_PASS=$(docker run --rm httpd:2.4-alpine htpasswd -nbB admin $PORTAINER_PASS | cut -d ":" -f 2)


cat << EOF > portainer.conf
# ------------------------------
# portainer web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
PUBLIC_FQDN=${PUBLIC_FQDN}

# ------------------------------
# PORTAINER admin user
# ------------------------------
PORTAINER_ADMIN=portaineradmin
ADMIN_MAIL=${ADMIN_MAIL}
PORTAINER_PASS=${PORTAINER_PASS}
ENC_PORTAINER_PASS=${ENC_PORTAINER_PASS}

# ------------------------------
# Bindings
# ------------------------------

# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=${HTTP_PORT}
HTTP_BIND=0.0.0.0

# Your timezone
TZ=${TZ}

# Fixed project name
#COMPOSE_PROJECT_NAME=portainer

EOF

