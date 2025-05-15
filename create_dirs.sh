#!/bin/bash
# create_dirs.sh

echo "=== Criando estrutura de diretórios do Trading Bot ==="

# Cria a estrutura de diretórios principal
mkdir -p src/{analytics,api,common,data_collection,execution_service,feature_engineering,model_training,risk_management,strategy_engine}/{domain,application,infrastructure}
mkdir -p deployment/{docker,kubernetes,terraform}
mkdir -p tests/{unit,integration,system}
mkdir -p docs/{architecture,api,models,strategies}
mkdir -p scripts

# Cria estrutura de domínio básica
mkdir -p src/common/domain
mkdir -p src/common/application
mkdir -p src/common/infrastructure/database
mkdir -p src/common/infrastructure/logging
mkdir -p src/common/utils

echo "✅ Estrutura de diretórios criada com sucesso!"