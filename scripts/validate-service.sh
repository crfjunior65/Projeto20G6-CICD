#!/bin/bash

# URL do serviço a ser testado (substitua pelo endpoint real)
SERVICE_URL="https://brunoferreira86main.com:8443"

# Esperar alguns segundos para o serviço iniciar
sleep 15

# Realizar a verificação de saúde do serviço
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL")

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "Falha na verificação de saúde. Status HTTP: $HTTP_STATUS"
  exit 1
else
  echo "Serviço está saudável. Status HTTP: $HTTP_STATUS"
  exit 0
fi
