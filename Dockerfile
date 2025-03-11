# Usa una imagen base con Python y Chrome preinstalados
FROM python:3.10-slim

# Instala dependencias del sistema necesarias para Chrome y Selenium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    xvfb \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivos del proyecto al contenedor
COPY . .

# Instalar dependencias del proyecto
RUN pip install --no-cache-dir -r requirements.txt

# Configuración para Chrome sin interfaz gráfica (headless)
ENV DISPLAY=:99

# Exponer el puerto en el que corre FastAPI
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
