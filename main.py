from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time

app = FastAPI()


# ✅ Modelo de Retorno con Pydantic
class FacebookProfile(BaseModel):
    nombre: str
    direccion: str
    telefono: str


@app.get("/scrape_facebook/", response_model=FacebookProfile)
def scrape_facebook(url: str):
    """Endpoint para extraer información de un perfil de Facebook."""
    return scrape_facebook_data(url)


def scrape_facebook_data(profile_url: str) -> FacebookProfile:
    """Función para extraer datos de un perfil de Facebook usando Selenium."""

    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Ejecutar en segundo plano
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        driver.get(profile_url)
        time.sleep(5)  # Esperar carga

        wait = WebDriverWait(driver, 15)

        # Extraer nombre
        try:
            name_element = wait.until(EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div/div[1]/div/div[3]/div/div/div[1]/div[1]/div/div/div[1]/div[2]/div/div/div/div[3]/div/div/div[1]/div/div/span/h1')))
            name = name_element.text
        except:
            name = "No disponible"

        # Extraer dirección
        try:
            address_element = wait.until(
                EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div/div[1]/div/div[3]/div/div/div[1]/div[1]/div/div/div[4]/div[2]/div/div[1]/div[2]/div/div[1]/div/div/div/div/div[2]/div[1]/div/ul/div[2]/div[2]/div/span')))
            address = address_element.text
        except:
            address = "No disponible"

        # Extraer teléfono
        try:
            phone_element = wait.until(
                EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div/div[1]/div/div[3]/div/div/div[1]/div[1]/div/div/div[4]/div[2]/div/div[1]/div[2]/div/div[1]/div/div/div/div/div[2]/div[1]/div/ul/div[3]/div[2]/div/div/span')))
            phone = phone_element.text
        except:
            phone = "No disponible"

        driver.quit()

        return FacebookProfile(
            nombre=name,
            direccion=address,
            telefono=phone
        )

    except Exception as e:
        driver.quit()
        raise HTTPException(status_code=500, detail=f"Error extrayendo datos: {e}")
