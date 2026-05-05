#!/bin/bash
# Script de instalação do Docker + ferramentas no Ubuntu
# Uso: chmod +x install-docker.sh && sudo ./install-docker.sh

set -e

echo "=== Removendo instalações anteriores do Docker ==="
apt remove -y docker docker.io docker-ce docker-ce-cli containerd containerd.io docker-compose-plugin docker-compose-v2 2>/dev/null || true
apt autoremove -y 2>/dev/null || true
rm -f /etc/apt/sources.list.d/docker.list*
dpkg --configure -a 2>/dev/null || true
apt --fix-broken install -y 2>/dev/null || true

echo "=== Instalando dependências ==="
apt update
apt install -y ca-certificates curl gnupg

echo "=== Adicionando repositório oficial Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Detectar codename (fallback para noble se não encontrar)
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
if [ -z "$CODENAME" ] || ! curl -s "https://download.docker.com/linux/ubuntu/dists/$CODENAME/Release" > /dev/null 2>&1; then
    CODENAME="noble"
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" > /etc/apt/sources.list.d/docker.list

echo "=== Instalando Docker ==="
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Instalando ferramentas auxiliares ==="
apt install -y mariadb-client-core awscli

echo "=== Adicionando usuário ao grupo docker ==="
usermod -aG docker ${SUDO_USER:-$USER}

echo "=== Habilitando Docker no boot ==="
systemctl enable docker
systemctl start docker

echo "=== Verificando instalação ==="
docker --version
docker compose version
mysql --version
aws --version

echo ""
echo "=== INSTALAÇÃO CONCLUÍDA ==="
echo ""
echo "Faça logout e login novamente (ou rode: newgrp docker)"
echo ""
echo "Depois suba o ambiente:"
echo "  cd infra"
echo "  docker compose up -d"
echo ""
echo "Testar:"
echo "  mysql -h localhost -P 3306 -u app_user -papp_pass123 --skip-ssl serasa_score_dev -e 'SHOW TABLES;'"
echo "  aws --endpoint-url=http://localhost:4566 s3 ls s3://serasa-score-dev/"
