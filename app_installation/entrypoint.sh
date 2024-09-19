#!/bin/bash

## - move para aplicação -----------------------------------------------------------------------------------------------
cd /var/www/glpi

## ---------------------------------------------------------------------------------------------------------------------
## Configuração das pasta compartilhadas
## ---------------------------------------------------------------------------------------------------------------------
# Verificar se está vazio e mover os arquivos se necessário
if [ ! -f /mnt/efs_glpi/config/config_db.php ]; then
  echo "Configurando pasta config"
  mv /var/www/glpi/config/* /mnt/efs_glpi/config
  
  echo "Configurando pasta files"
  mv /var/www/glpi/files/* /mnt/efs_glpi/files/
  chown -R www-data:www-data /mnt/efs_glpi/files
  chmod -R 775 /mnt/efs_glpi/files

  echo "Configurando pasta logs"
  chown -R www-data:www-data /mnt/efs_glpi/logs
  chmod -R 775 /mnt/efs_glpi/logs
fi

# Copiar local_define.php de qualquer forma
cp -f /tmp/local_define.php /mnt/efs_glpi/config/local_define.php

## ---------------------------------------------------------------------------------------------------------------------
## Configuração do banco de dados
## ---------------------------------------------------------------------------------------------------------------------
echo "Configurando o banco de dados"

# Copiar config_db.php de qualquer forma
cp -f /tmp/config_db.php /mnt/efs_glpi/config/config_db.php

# Remover pastas 'config' e 'files' do diretorio publico de qualquer forma
rm -rf config
rm -rf files

# Remover arquivos temporarios de qualquer forma
rm /tmp/local_define.php
rm /tmp/config_db.php

## ---------------------------------------------------------------------------------------------------------------------
## Configurações adicionais do GLPI
## ---------------------------------------------------------------------------------------------------------------------
rm -f /var/www/glpi/install/install.php

## ---------------------------------------------------------------------------------------------------------------------
## Inicialização do Apache
## ---------------------------------------------------------------------------------------------------------------------
echo "Entrypoint iniciando o Apache"
exec apachectl -D FOREGROUND

## ---------------------------------------------------------------------------------------------------------------------