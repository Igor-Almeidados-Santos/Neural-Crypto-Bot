#!/bin/bash
# setup_docker.sh

echo "=== Configurando Docker para o Trading Bot ==="

# Cria diretório para Dockerfiles
mkdir -p deployment/docker

# Cria Dockerfile.api
echo "Criando Dockerfile.api..."
cat > deployment/docker/Dockerfile.api << EOF
# Dockerfile.api
FROM python:3.11-slim as python-base

# Configuração de ambiente não interativo
ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PIP_NO_CACHE_DIR=off \\
    PIP_DISABLE_PIP_VERSION_CHECK=on \\
    PIP_DEFAULT_TIMEOUT=100 \\
    POETRY_HOME="/opt/poetry" \\
    POETRY_VIRTUALENVS_IN_PROJECT=true \\
    POETRY_NO_INTERACTION=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$POETRY_HOME/bin:\$VENV_PATH/bin:\$PATH"

# Instalação de dependências do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    build-essential \\
    curl \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Instalação do Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Cópia dos arquivos de configuração do Poetry
WORKDIR \$PYSETUP_PATH
COPY pyproject.toml poetry.lock* ./

# Instalação das dependências do projeto
RUN poetry install --no-dev --no-root

# Imagem final
FROM python:3.11-slim as production

ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$VENV_PATH/bin:\$PATH"

# Instalação de dependências mínimas do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    libpq5 \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Cópia do ambiente virtual da etapa anterior
COPY --from=python-base \$VENV_PATH \$VENV_PATH

# Cópia do código fonte
WORKDIR /app
COPY . .

# Exposição da porta da API
EXPOSE 8000

# Configuração de variáveis de ambiente
ENV PYTHONPATH=/app
ENV ENVIRONMENT=production

# Comando para iniciar a API
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Cria Dockerfile.collector
echo "Criando Dockerfile.collector..."
cat > deployment/docker/Dockerfile.collector << EOF
# Dockerfile.collector
FROM python:3.11-slim as python-base

# Configuração de ambiente não interativo
ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PIP_NO_CACHE_DIR=off \\
    PIP_DISABLE_PIP_VERSION_CHECK=on \\
    PIP_DEFAULT_TIMEOUT=100 \\
    POETRY_HOME="/opt/poetry" \\
    POETRY_VIRTUALENVS_IN_PROJECT=true \\
    POETRY_NO_INTERACTION=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$POETRY_HOME/bin:\$VENV_PATH/bin:\$PATH"

# Instalação de dependências do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    build-essential \\
    curl \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Instalação do Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Cópia dos arquivos de configuração do Poetry
WORKDIR \$PYSETUP_PATH
COPY pyproject.toml poetry.lock* ./

# Instalação das dependências do projeto
RUN poetry install --no-dev --no-root

# Imagem final
FROM python:3.11-slim as production

ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$VENV_PATH/bin:\$PATH"

# Instalação de dependências mínimas do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    libpq5 \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Cópia do ambiente virtual da etapa anterior
COPY --from=python-base \$VENV_PATH \$VENV_PATH

# Cópia do código fonte
WORKDIR /app
COPY . .

# Configuração de variáveis de ambiente
ENV PYTHONPATH=/app
ENV ENVIRONMENT=production

# Comando para iniciar o serviço de coleta
CMD ["python", "-m", "src.data_collection.main"]
EOF

# Cria Dockerfile.execution
echo "Criando Dockerfile.execution..."
cat > deployment/docker/Dockerfile.execution << EOF
# Dockerfile.execution
FROM python:3.11-slim as python-base

# Configuração de ambiente não interativo
ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PIP_NO_CACHE_DIR=off \\
    PIP_DISABLE_PIP_VERSION_CHECK=on \\
    PIP_DEFAULT_TIMEOUT=100 \\
    POETRY_HOME="/opt/poetry" \\
    POETRY_VIRTUALENVS_IN_PROJECT=true \\
    POETRY_NO_INTERACTION=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$POETRY_HOME/bin:\$VENV_PATH/bin:\$PATH"

# Instalação de dependências do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    build-essential \\
    curl \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Instalação do Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Cópia dos arquivos de configuração do Poetry
WORKDIR \$PYSETUP_PATH
COPY pyproject.toml poetry.lock* ./

# Instalação das dependências do projeto
RUN poetry install --no-dev --no-root

# Imagem final
FROM python:3.11-slim as production

ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$VENV_PATH/bin:\$PATH"

# Instalação de dependências mínimas do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    libpq5 \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Cópia do ambiente virtual da etapa anterior
COPY --from=python-base \$VENV_PATH \$VENV_PATH

# Cópia do código fonte
WORKDIR /app
COPY . .

# Configuração de variáveis de ambiente
ENV PYTHONPATH=/app
ENV ENVIRONMENT=production

# Comando para iniciar o serviço de execução
CMD ["python", "-m", "src.execution_service.main"]
EOF

# Cria Dockerfile.training
echo "Criando Dockerfile.training..."
cat > deployment/docker/Dockerfile.training << EOF
# Dockerfile.training
FROM python:3.11-slim as python-base

# Configuração de ambiente não interativo
ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PIP_NO_CACHE_DIR=off \\
    PIP_DISABLE_PIP_VERSION_CHECK=on \\
    PIP_DEFAULT_TIMEOUT=100 \\
    POETRY_HOME="/opt/poetry" \\
    POETRY_VIRTUALENVS_IN_PROJECT=true \\
    POETRY_NO_INTERACTION=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$POETRY_HOME/bin:\$VENV_PATH/bin:\$PATH"

# Instalação de dependências do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    build-essential \\
    curl \\
    libopenblas-dev \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Instalação do Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Cópia dos arquivos de configuração do Poetry
WORKDIR \$PYSETUP_PATH
COPY pyproject.toml poetry.lock* ./

# Instalação das dependências do projeto
RUN poetry install --no-dev --no-root

# Imagem final
FROM python:3.11-slim as production

ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PYSETUP_PATH="/opt/pysetup" \\
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="\$VENV_PATH/bin:\$PATH"

# Instalação de dependências mínimas do sistema
RUN apt-get update \\
    && apt-get install --no-install-recommends -y \\
    libpq5 \\
    libopenblas-base \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Cópia do ambiente virtual da etapa anterior
COPY --from=python-base \$VENV_PATH \$VENV_PATH

# Cópia do código fonte
WORKDIR /app
COPY . .

# Configuração de variáveis de ambiente
ENV PYTHONPATH=/app
ENV ENVIRONMENT=production

# Comando para iniciar o serviço de treinamento
CMD ["python", "-m", "src.model_training.main"]
EOF

# Cria docker-compose.yml
echo "Criando docker-compose.yml..."
cat > docker-compose.yml << EOF
version: '3.8'

services:
  # Serviço de API
  api:
    build:
      context: .
      dockerfile: deployment/docker/Dockerfile.api
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
      - kafka
    environment:
      - DATABASE_URL=postgresql://tradingbot:password@postgres:5432/tradingbot
      - REDIS_URL=redis://redis:6379/0
      - KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Serviço de coleta de dados
  collector:
    build:
      context: .
      dockerfile: deployment/docker/Dockerfile.collector
    depends_on:
      - postgres
      - kafka
    environment:
      - DATABASE_URL=postgresql://tradingbot:password@postgres:5432/tradingbot
      - KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Serviço de execução de ordens
  execution:
    build:
      context: .
      dockerfile: deployment/docker/Dockerfile.execution
    depends_on:
      - postgres
      - redis
      - kafka
    environment:
      - DATABASE_URL=postgresql://tradingbot:password@postgres:5432/tradingbot
      - REDIS_URL=redis://redis:6379/0
      - KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Serviço de treinamento de modelos
  training:
    build:
      context: .
      dockerfile: deployment/docker/Dockerfile.training
    depends_on:
      - postgres
      - redis
    environment:
      - DATABASE_URL=postgresql://tradingbot:password@postgres:5432/tradingbot
      - REDIS_URL=redis://redis:6379/0
      - MODEL_STORAGE_PATH=/app/models
    volumes:
      - model-storage:/app/models
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Banco de dados PostgreSQL com TimescaleDB
  postgres:
    image: timescale/timescaledb:latest-pg14
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=tradingbot
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=tradingbot
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Redis para cache e armazenamento em memória
  redis:
    image: redis:7.0-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - tradingbot-network
    command: redis-server --appendonly yes
    restart: unless-stopped

  # Kafka para mensageria
  kafka:
    image: confluentinc/cp-kafka:7.3.0
    ports:
      - "9092:9092"
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      - KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
      - KAFKA_AUTO_CREATE_TOPICS_ENABLE=true
      - KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0
      - KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
      - KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
    depends_on:
      - zookeeper
    networks:
      - tradingbot-network
    restart: unless-stopped

  # Zookeeper para Kafka
  zookeeper:
    image: confluentinc/cp-zookeeper:7.3.0
    ports:
      - "2181:2181"
    environment:
      - ZOOKEEPER_CLIENT_PORT=2181
      - ZOOKEEPER_TICK_TIME=2000
    networks:
      - tradingbot-network
    restart: unless-stopped

networks:
  tradingbot-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
  model-storage:
EOF

echo "✅ Configuração Docker concluída com sucesso!"