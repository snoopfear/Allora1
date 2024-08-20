#!/bin/bash

# Функция для логгирования сообщений
log_message() {
    echo -e "\e[32m$1\e[0m"
}

# Функция для выполнения команд с обработкой ошибок
run_command() {
    local command="$1"
    local error_message="$2"
    
    log_message "Выполняется: $command"
    if eval "$command"; then
        log_message "Успешно выполнено: $command"
    else
        log_message "$error_message"
        exit 1
    fi
}

# Функция для перезагрузки Docker
restart_docker() {
    log_message "Перезагружаем Docker..."
    run_command "sudo systemctl restart docker" "Не удалось перезагрузить Docker. Проверьте состояние сервиса Docker."
}

# Функция для клонирования репозитория
clone_repository() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ -d "$target_dir" ]; then
        log_message "Удаление существующей директории $target_dir..."
        rm -rf "$target_dir"
    fi
    
    run_command "git clone $repo_url $target_dir" "Не удалось клонировать репозиторий $repo_url"
}

# Логотип
echo -e '\e[32m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"

sleep 2

# Основной цикл меню
while true; do
    echo "1. Установить ноду Allora"
    echo "2. Проверить логи ноды Allora"
    echo "3. Проверить статус ноды Allora"
    echo "4. Выйти из скрипта"
    read -p "Выберите опцию: " option

    case $option in
        1)
            log_message "Обновление и установка пакетов..."
            run_command "sudo apt update && sudo apt upgrade -y" "Не удалось обновить и установить пакеты."
            run_command "sudo apt install ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 -y" "Не удалось установить необходимые пакеты."

            log_message "Установка Python..."
            run_command "sudo apt install python3 -y" "Не удалось установить Python."

            log_message "Установка pip3..."
            run_command "sudo apt install python3-pip -y" "Не удалось установить pip3."

            log_message "Установка Docker..."
            run_command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io -y" "Не удалось установить Docker."

            log_message "Установка Docker Compose..."
            run_command "sudo apt-get install docker-compose -y" "Не удалось установить Docker Compose."

            log_message "Установка GO..."
            run_command "sudo rm -rf /usr/local/go && curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local && echo 'export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin' >> \$HOME/.bash_profile && echo 'export PATH=\$PATH:\$(go env GOPATH)/bin' >> \$HOME/.bash_profile && source \$HOME/.bash_profile" "Не удалось установить GO."

            log_message "Установка Allorad Wallet..."
            clone_repository "https://github.com/allora-network/allora-chain.git" "allora-chain"
            run_command "cd allora-chain && make all" "Не удалось установить Allorad Wallet."

            log_message "Запрос Seed Phrase у пользователя..."
            run_command "allorad keys add testkey --recover" "Не удалось запросить Seed Phrase."

            log_message "Установка Allora Worker..."
            run_command "cd \$HOME"
            run_command "git clone https://github.com/allora-network/allora-huggingface-walkthrough"
            run_command "cd allora-huggingface-walkthrough"
            run_command "mkdir -p worker-data"
            run_command "chmod -R 777 worker-data"

            rm -rf config.json
            
            # Запрос Seed Phrase
            read -p "Введите вашу Seed Phrase: " seed_phrase

            # Создание нового файла config.json
            cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "testkey",
        "addressRestoreMnemonic": "$seed_phrase",
        "alloraHomeDir": "/root/.allorad",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-testnet-1-rpc.testnet.nodium.xyz/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "worker": [
        {
           "topicId": 1,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 1,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "ETH"
           }
       },
       {
           "topicId": 3,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 5,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "BTC"
           }
       },
       {
           "topicId": 5,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 4,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "SOL"
           }
       },
       {
           "topicId": 7,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 2,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "ETH"
           }
       },
       {
           "topicId": 8,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 3,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "BNB"
           }
       },
       {
           "topicId": 9,
           "inferenceEntrypointName": "api-worker-reputer",
           "loopSeconds": 5,
           "parameters": {
               "InferenceEndpoint": "http://inference:8000/inference/{Token}",
               "Token": "ARB"
           }
       }
       
   ]
}
EOF

            rm -rf app.py
            
            # Запрос Api
            read -p "Введите ваш API: " api_coin

            # Создание нового файла app.py
            cat <<EOF > app.py
            
from flask import Flask, Response
import requests
import json
import pandas as pd
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from sklearn.preprocessing import MinMaxScaler
import numpy as np

# create our Flask app
app = Flask(__name__)

def get_coingecko_url(token):
    base_url = "https://api.coingecko.com/api/v3/coins/"
    token_map = {
        'ETH': 'ethereum',
        'SOL': 'solana',
        'BTC': 'bitcoin',
        'BNB': 'binancecoin',
        'ARB': 'arbitrum'
    }
    
    token = token.upper()
    if token in token_map:
        url = f"{base_url}{token_map[token]}/market_chart?vs_currency=usd&days=1&interval=minute"
        return url
    else:
        raise ValueError("Unsupported token")

def prepare_data(df):
    # Нормализация данных
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_data = scaler.fit_transform(df["y"].values.reshape(-1, 1))

    # Формирование последовательностей для обучения модели
    sequence_length = 60
    X = []
    y = []
    for i in range(sequence_length, len(scaled_data)):
        X.append(scaled_data[i-sequence_length:i, 0])
        y.append(scaled_data[i, 0])
    X, y = np.array(X), np.array(y)

    # Преобразование данных в форму [samples, time steps, features]
    X = np.reshape(X, (X.shape[0], X.shape[1], 1))

    return X, y, scaler

def build_lstm_model(input_shape):
    model = Sequential()
    model.add(LSTM(units=50, return_sequences=True, input_shape=input_shape))
    model.add(LSTM(units=50, return_sequences=False))
    model.add(Dense(units=1))
    model.compile(optimizer='adam', loss='mean_squared_error')
    return model

# define our endpoint
@app.route("/inference/<string:token>")
def get_inference(token):
    """Generate inference for given token."""
    try:
        # Get the data from Coingecko
        url = get_coingecko_url(token)
    except ValueError as e:
        return Response(json.dumps({"error": str(e)}), status=400, mimetype='application/json')

    headers = {
        "accept": "application/json",
        "x-cg-demo-api-key": "CG-XXXXXXXXXXXXXXXXXXXXXX"  # Replace with your API key
    }

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        df = pd.DataFrame(data["prices"])
        df.columns = ["ds", "y"]
        df["ds"] = pd.to_datetime(df["ds"], unit='ms')
        print(df.tail(5))
    else:
        return Response(json.dumps({"Failed to retrieve data from the API": str(response.text)}),
                        status=response.status_code,
                        mimetype='application/json')

    # Prepare data for LSTM
    X, y, scaler = prepare_data(df)

    # Build and train the LSTM model
    model = build_lstm_model((X.shape[1], 1))
    model.fit(X, y, epochs=5, batch_size=32, verbose=1)

    # Make a forecast for the next 10-20 minutes
    last_sequence = df["y"].values[-60:].reshape(-1, 1)
    last_sequence_scaled = scaler.transform(last_sequence)
    X_new = np.array([last_sequence_scaled])
    X_new = np.reshape(X_new, (X_new.shape[0], X_new.shape[1], 1))

    predicted_value_scaled = model.predict(X_new)
    predicted_value = scaler.inverse_transform(predicted_value_scaled)

    forecasted_value = predicted_value[0, 0]
    print(forecasted_value)  # Print the forecasted value

    return Response(str(forecasted_value), status=200)

# run our Flask app
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)

EOF

            rm -rf requirements.txt
            
            # Создание нового файла requirements.txt
            cat <<EOF > requirements.txt
flask[async]
gunicorn[gthread]
transformers[torch]
pandas
torch==2.0.1 
python-dotenv
requests==2.31.0
plotly
prophet
tensorflow==2.12.0
scikit-learn

EOF

            log_message "Запуск Allora Worker..."
            chmod +x init.config
            ./init.config
            cd ~/allora-huggingface-walkthrough
            
            docker compose up -d --build
            ;;
        2)
            log_message "Проверка логов... Для выхода в меню скрипта используйте комбинацию клавиш CTRL+C"
            sleep 10
            run_command "docker compose logs -f worker" "Не удалось вывести логи контейнера. Проверьте состояние Docker."
            ;;
        3)
            log_message "Проверка цены Ethereum через ноду..."
            response=$(curl -s http://localhost:8000/inference/ETH)
            if [ -z "$response" ]; then
                log_message "Не удалось получить цену ETH. Проверьте состояние ноды."
            else
                log_message "Цена ETH: $response"
            fi
            ;;
        4)
            log_message "Выход из скрипта."
            exit 0
            ;;
        *)
            log_message "Неверный выбор. Пожалуйста, попробуйте снова."
            ;;
    esac
done
