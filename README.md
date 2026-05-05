# Infraestrutura Local — API EFI Serasa Score

## Pré-requisitos

- Docker e Docker Compose instalados

## Subir ambiente

```bash
cd infra
chmod +x start.sh
./start.sh
```

Ou manualmente:

```bash
cd infra
chmod +x init-localstack/*.sh
docker compose up -d
# Aguardar ~10s e criar bucket se necessário:
aws --endpoint-url=http://localhost:4566 s3 mb s3://serasa-score-dev
```

## Serviços disponíveis

| Serviço | Porta | Credenciais |
|---------|-------|-------------|
| MariaDB | 3306 | user: `app_user` / pass: `app_pass123` / db: `serasa_score_dev` |
| LocalStack S3 | 4566 | region: `us-east-1` / access_key: `test` / secret: `test` |

## Testar conexão

```bash
# MariaDB
mysql -h localhost -P 3306 -u app_user -papp_pass123 --skip-ssl serasa_score_dev -e "SHOW TABLES;"

# S3 (via AWS CLI com endpoint local)
aws --endpoint-url=http://localhost:4566 s3 ls s3://serasa-score-dev/
```



## Parar ambiente

```bash
docker-compose down
```

## Resetar dados

```bash
docker-compose down -v
docker-compose up -d
```
