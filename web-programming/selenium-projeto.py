"""Teste funcional do ciclo de vida de um projeto (Selenium).

1. Login como gestor de portfolio
2. Criar novo projeto
3. Editar projeto
4. Eliminar projeto

Pressupoe que existe um utilizador no grupo 'gestor-portfolio'.
Por defeito usa SEL_USER='admin' e SEL_PASSWORD='admin' (ou variaveis de ambiente).

Uso:
    SEL_USER=admin SEL_PASSWORD=segredo python selenium-projeto.py [BASE_URL]
"""
import os
import sys
import time
import uuid

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select


BASE_URL = (sys.argv[1] if len(sys.argv) > 1 else os.environ.get(
    "BASE_URL", "http://127.0.0.1:8000"
)).rstrip("/")
USER = os.environ.get("SEL_USER", "admin")
PASSWORD = os.environ.get("SEL_PASSWORD", "admin")


def login(driver):
    driver.get(f"{BASE_URL}/accounts/login/")
    time.sleep(2)
    driver.find_element(By.NAME, "username").send_keys(USER)
    driver.find_element(By.NAME, "password").send_keys(PASSWORD)
    time.sleep(1)
    driver.find_element(By.CSS_SELECTOR, "button[type=submit], input[type=submit]").click()
    time.sleep(3)
    assert "/accounts/login/" not in driver.current_url, (
        "Login falhou — verifique SEL_USER/SEL_PASSWORD"
    )
    print(f"[OK] Login como {USER}")


def main():
    driver = webdriver.Chrome()
    try:
        login(driver)

        sufixo = uuid.uuid4().hex[:6]
        titulo = f"Projeto-Sel-{sufixo}"

        # 1. Criar
        driver.get(f"{BASE_URL}/projeto/novo/")
        time.sleep(2)
        driver.find_element(By.NAME, "titulo").send_keys(titulo)
        driver.find_element(By.NAME, "descricao").send_keys(
            "Projeto criado por Selenium para testar o ciclo CRUD."
        )
        time.sleep(1)
        driver.find_element(
            By.CSS_SELECTOR, "button[type=submit], input[type=submit]"
        ).click()
        time.sleep(3)
        assert titulo in driver.find_element(By.TAG_NAME, "body").text
        print(f"[OK] Projeto criado: {titulo}")

        url_detalhe = driver.current_url

        # 2. Editar
        # /projeto/<id>/ → /projeto/<id>/editar/
        if not url_detalhe.endswith("/"):
            url_detalhe += "/"
        url_editar = url_detalhe + "editar/"
        driver.get(url_editar)
        time.sleep(2)
        descr = driver.find_element(By.NAME, "descricao")
        descr.clear()
        descr.send_keys("Descricao actualizada via Selenium.")
        time.sleep(1)
        driver.find_element(
            By.CSS_SELECTOR, "button[type=submit], input[type=submit]"
        ).click()
        time.sleep(3)
        corpo = driver.find_element(By.TAG_NAME, "body").text
        assert "actualizada" in corpo, "Edicao nao aplicada"
        print("[OK] Projeto editado")

        # 3. Eliminar
        url_apagar = url_detalhe + "apagar/"
        driver.get(url_apagar)
        time.sleep(2)
        driver.find_element(
            By.CSS_SELECTOR, "button[type=submit], input[type=submit]"
        ).click()
        time.sleep(3)
        driver.get(f"{BASE_URL}/projetos/")
        time.sleep(2)
        corpo = driver.find_element(By.TAG_NAME, "body").text
        assert titulo not in corpo, "Projeto nao foi eliminado"
        print("[OK] Projeto eliminado")

        print("\nTodos os testes de projeto passaram.")
    finally:
        time.sleep(2)
        driver.quit()


if __name__ == "__main__":
    main()
