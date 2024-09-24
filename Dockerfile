# Usar a imagem base do Ubuntu 24.10 no ECR público- Recebida com argumento
FROM public.ecr.aws/ubuntu/ubuntu:24.10

# Ajuda com instalações silenciosas
ENV DEBIAN_FRONTEND=noninteractive

# Atualizar pacotes
RUN apt-get -qq update > /dev/null

# Instalar apt-utils para evitar alertar e perda de tempo nas instalações
RUN apt-get -qq install apt-utils > /dev/null
# Instalar pre-requisitos gerais
RUN apt-get -qq install wget unzip > /dev/null

# Instalar Apache e módulos do sistema
RUN apt-get -qq install apache2 apache2-utils > /dev/null
# Habilitar módulos do Apache necessários para funcionamento do GLPI
RUN a2enmod rewrite

# Instalar PHP e módulos obrigatorios para o GLPI
RUN apt-get -qq install php php-curl php-gd php-intl php-mysql php-xml > /dev/null
# Instalar módulos php opcionais para o GLPI
RUN apt-get -qq install php-bz2 php-phar php-zip php-exif php-ldap php-opcache \
  php-mbstring > /dev/null

# Instalar cloudwatch agent
RUN wget -nv  https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
RUN dpkg -i -E ./amazon-cloudwatch-agent.deb > /dev/null
RUN rm -f ./amazon-cloudwatch-agent.deb

# Limpar cache de pacotes para economizar espaço
RUN apt-get -qq clean > /dev/null
RUN rm -rf /var/lib/apt/lists/*

# Verificar depois a limpeza de credenciais
# https://docs.docker.com/engine/reference/commandline/login/#credentials-store

# Esta imagem não será executada diretamente, então não precisa de CMD ou EXPOSE.

# Criar e definir o diretório de trabalho
RUN mkdir -p /var/www/glpi
WORKDIR /var/www/glpi

## ---------------------------------------------------------------------------------------------------------------------
## Configuração do Apache
## ---------------------------------------------------------------------------------------------------------------------

# Limpar configurações padrão do Apache
RUN rm /etc/apache2/sites-available/*
RUN rm /etc/apache2/sites-enabled/*

# Copiar a pasta server/etc do diretório local para /etc no container
COPY app_installation/server/etc/ /etc/

# Habilitar o site do GLPI
RUN ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf

## ---------------------------------------------------------------------------------------------------------------------
## Implantação do GLPI
## ---------------------------------------------------------------------------------------------------------------------

# Baixar e preparar a última versão do GLPI
RUN wget -nv https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz
RUN tar -xzf glpi-10.0.16.tgz --strip-components=1
RUN rm glpi-10.0.16.tgz

# Configurar permissões da aplicação
RUN chown -R www-data:www-data /var/www/glpi

## ---------------------------------------------------------------------------------------------------------------------
## Configuração das pasta compartilhadas
## ---------------------------------------------------------------------------------------------------------------------

# Criar pastas compartilhadas (prepara para o EFS)
RUN mkdir -p /mnt/efs_glpi

# Arquivo downstream.php e local_define para mudar a pasta config de lugar.
COPY app_installation/downstream.php inc/

# Copiar o arquivo de configuração do banco de dados para pasta temporaria
COPY app_installation/local_define.php /tmp
COPY app_installation/config_db.php /tmp
COPY app_installation/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

## ---------------------------------------------------------------------------------------------------------------------
## Configuração do Banco de Dados em arquivo temporario
## ---------------------------------------------------------------------------------------------------------------------

# Recebe dados do banco de dados
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_PORT

# Copiar e configurar o arquivo de configuração do banco de dados
RUN sed -i "s/YOUR_DB_HOST/$DB_HOST/g" /tmp/config_db.php
RUN sed -i "s/YOUR_DB_USER/$DB_USER/g" /tmp/config_db.php
RUN sed -i "s/YOUR_DB_PASSWORD/$DB_PASSWORD/g" /tmp/config_db.php
RUN sed -i "s/YOUR_DB_NAME/$DB_NAME/g" /tmp/config_db.php
RUN sed -i "s/YOUR_DB_PORT/$DB_PORT/g" /tmp/config_db.php

## ---------------------------------------------------------------------------------------------------------------------
## Incialização entrypoint
## ---------------------------------------------------------------------------------------------------------------------

# Expor a porta 80 (o ELB vai redirecionar para HTTPS)
EXPOSE 80

# Verificar depois a limpeza de credenciais
# https://docs.docker.com/engine/reference/commandline/login/#credentials-store

# Definir o entrypoint como o script de inicialização
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

## ---------------------------------------------------------------------------------------------------------------------
