#!/bin/bash
echo "Criando bucket S3 local..."
awslocal s3 mb s3://serasa-score-dev
echo "Bucket serasa-score-dev criado com sucesso!"
awslocal s3 ls
