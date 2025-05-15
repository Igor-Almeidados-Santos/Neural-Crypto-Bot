#!/bin/bash
# install.sh

set -e  # Encerra o script se algum comando falhar

echo "=== Iniciando instalação do Trading Bot ==="

# Executa scripts na ordem correta
echo "Passo 1: Criando estrutura de diretórios..."
bash ./create_dirs.sh

echo "Passo 2: Configurando Poetry..."
bash ./setup_poetry.sh

echo "Passo 3: Configurando Docker..."
bash ./setup_docker.sh

echo "Passo 4: Configurando arquivos de ambiente..."
bash ./setup_configs.sh

echo "Passo 5: Configurando scripts utilitários..."
bash ./setup_scripts.sh

echo "Passo 6: Configurando arquivos de domínio base..."
bash ./setup_base_domain.sh

# Torna os scripts executáveis
chmod +x scripts/setup_poetry.sh scripts/start_docker.sh

echo "=== Instalação concluída com sucesso! ==="
echo "Para instalar as dependências, execute: ./scripts/setup_poetry.sh"
echo "Para iniciar o ambiente Docker, execute: ./scripts/start_docker.sh"