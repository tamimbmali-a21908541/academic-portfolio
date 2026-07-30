"""Teste funcional de navegacao no site (Selenium).

Visita a pagina inicial, percorre paginas publicas e valida conteudos.

Uso:
    python selenium-navegacao.py [BASE_URL]

Default BASE_URL: http://127.0.0.1:8000
"""
import os
import sys
import time

from selenium import webdriver
from selenium.webdriver.common.by import By


BASE_URL = (sys.argv[1] if len(sys.argv) > 1 else os.environ.get(
    "BASE_URL", "http://127.0.0.1:8000"
)).rstrip("/")


def main():
    driver = webdriver.Chrome()
    try:
        # 1. Pagina inicial
        driver.get(f"{BASE_URL}/")
        time.sleep(2)
        assert "Portfolio" in driver.title or driver.find_element(By.TAG_NAME, "h1"), (
            "Pagina inicial nao carregou corretamente"
        )
        print(f"[OK] Pagina inicial: {driver.title}")

        # 2. Navegar pelas paginas publicas via menu
        paginas = [
            ("projetos", "Projetos"),
            ("tecnologias", "Tecnologias"),
            ("competencias", "Competencias"),
            ("formacoes", "Formac"),
            ("ucs", "Unidade"),
            ("makingof", "Making"),
            ("interesses", "Interesse"),
            ("sobre", "Sobre"),
        ]
        for slug, esperado in paginas:
            driver.get(f"{BASE_URL}/{slug}/")
            time.sleep(2)
            corpo = driver.find_element(By.TAG_NAME, "body").text
            assert esperado.lower() in corpo.lower(), (
                f"Pagina /{slug}/ nao mostra '{esperado}'"
            )
            print(f"[OK] /{slug}/ contem '{esperado}'")

        # 3. Validar que existe pelo menos um link no menu de navegacao
        driver.get(f"{BASE_URL}/")
        time.sleep(1)
        links = driver.find_elements(By.TAG_NAME, "a")
        assert len(links) >= 5, "Espera-se pelo menos 5 links na pagina inicial"
        print(f"[OK] Pagina inicial tem {len(links)} links")

        print("\nTodos os testes de navegacao passaram.")
    finally:
        time.sleep(2)
        driver.quit()


if __name__ == "__main__":
    main()
