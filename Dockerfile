# Usa una imagen base de Python
FROM python:3.12-slim

# Instala dependencias del sistema necesarias para Chrome y Selenium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    libasound2 \
    fonts-liberation \
    libgbm-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Añade la clave GPG de Google y el repositorio de Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# Instalar la última versión de Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Descargar manualmente ChromeDriver 134
RUN wget -O /tmp/chromedriver.zip https://storage.googleapis.com/chrome-for-testing-public/134.0.6998.88/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /usr/local/bin/chromedriver-linux64

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivos del proyecto al contenedor
COPY . .

# Instalar dependencias del proyecto
RUN pip install --no-cache-dir -r requirements.txt

# Exponer el puerto en el que corre FastAPI
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
