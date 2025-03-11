# Usa una imagen base de Python
FROM python:3.12-slim

# Instala dependencias del sistema necesarias para Chrome y Selenium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Añade la clave GPG de Google
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

# Añade el repositorio de Chrome
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# Instala Google Chrome
RUN apt-get update && apt-get install -y \
    google-chrome-stable=114.0.5735.198-1 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Descarga e instala ChromeDriver 114
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

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
