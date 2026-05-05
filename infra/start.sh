#!/bin/bash
# Script para subir o ambiente local completo
# Uso: chmod +x start.sh && ./start.sh

set -e

echo "=== Dando permissão nos scripts de init ==="
chmod +x init-localstack/*.sh 2>/dev/null || true

echo "=== Subindo containers ==="
docker compose up -d

echo "=== Aguardando MariaDB ficar pronto ==="
until docker exec serasa-score-db healthcheck.sh --connect --innodb_initialized 2>/dev/null; do
    echo "  Aguardando MariaDB..."
    sleep 3
done
echo "  MariaDB pronto!"

echo "=== Aguardando LocalStack ficar pronto ==="
until curl -sf http://localhost:4566/_localstack/health > /dev/null 2>&1; do
    echo "  Aguardando LocalStack..."
    sleep 3
done
echo "  LocalStack pronto!"

echo "=== Criando bucket S3 (se não existir) ==="
aws --endpoint-url=http://localhost:4566 s3 mb s3://serasa-score-dev 2>/dev/null || echo "  Bucket já existe"

echo ""
echo "=== AMBIENTE PRONTO ==="
echo ""
echo "MariaDB:"
echo "  Host: localhost:3306"
echo "  User: app_user"
echo "  Pass: app_pass123"
echo "  DB:   serasa_score_dev"
echo "  Test: mysql -h localhost -P 3306 -u app_user -papp_pass123 --skip-ssl serasa_score_dev -e 'SHOW TABLES;'"
echo ""
echo "S3 (LocalStack):"
echo "  Endpoint: http://localhost:4566"
echo "  Bucket:   serasa-score-dev"
echo "  Test: aws --endpoint-url=http://localhost:4566 s3 ls s3://serasa-score-dev/"
echo ""
