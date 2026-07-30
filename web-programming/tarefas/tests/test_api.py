"""Testes da API `tarefas` exposta sob /api/tarefas/.

Confirmam que:
 - os 5 endpoints CRUD funcionam (200, 201, 204, 404, 400);
 - filtros e ordenacao via query parameters funcionam;
 - a autenticacao por X-API-Key e' herdada da NinjaAPI principal
   (sem chave -> 401; chave valida -> 200).
"""

import json
from datetime import timedelta

from django.test import Client, TestCase
from django.utils import timezone

from portfolio.models import APIKey
from tarefas.models import Tarefa


def _client_com_chave():
    chave = APIKey.objects.create(
        name="testes-tarefas",
        expiration_date=timezone.now() + timedelta(days=1),
    )
    return Client(HTTP_X_API_KEY=chave.key)


class TarefasAuthTests(TestCase):
    def test_sem_chave_devolve_401(self):
        resp = Client().get("/api/tarefas/")
        self.assertEqual(resp.status_code, 401)

    def test_chave_valida_devolve_200(self):
        resp = _client_com_chave().get("/api/tarefas/")
        self.assertEqual(resp.status_code, 200)


class TarefasCrudTests(TestCase):
    def setUp(self):
        self.client = _client_com_chave()

    def _post_json(self, url, payload):
        return self.client.post(url, data=json.dumps(payload),
                                content_type="application/json")

    def _put_json(self, url, payload):
        return self.client.put(url, data=json.dumps(payload),
                               content_type="application/json")

    def test_crud_completo(self):
        # CREATE (201)
        resp = self._post_json("/api/tarefas/", {
            "titulo": "Comprar pao",
            "prioridade": 3,
            "concluida": False,
            "data_limite": "2026-06-30",
        })
        self.assertEqual(resp.status_code, 201, resp.content)
        criada = resp.json()
        tid = criada["id"]
        self.assertEqual(criada["titulo"], "Comprar pao")
        self.assertEqual(criada["prioridade"], 3)
        self.assertFalse(criada["concluida"])

        # READ (200)
        resp = self.client.get(f"/api/tarefas/{tid}/")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.json()["titulo"], "Comprar pao")

        # UPDATE (200) — marca como concluida
        resp = self._put_json(f"/api/tarefas/{tid}/", {
            "titulo": "Comprar pao",
            "prioridade": 3,
            "concluida": True,
            "data_limite": "2026-06-30",
        })
        self.assertEqual(resp.status_code, 200, resp.content)
        self.assertTrue(resp.json()["concluida"])

        # DELETE (204)
        resp = self.client.delete(f"/api/tarefas/{tid}/")
        self.assertEqual(resp.status_code, 204)
        self.assertFalse(Tarefa.objects.filter(id=tid).exists())

    def test_get_inexistente_devolve_404(self):
        resp = self.client.get("/api/tarefas/99999/")
        self.assertEqual(resp.status_code, 404)

    def test_filtros_e_ordenacao(self):
        # Mais directo do que confiar nas tarefas semeadas pela data migration
        # (essas estao la mas dependem das definicoes do projeto). Aqui criamos
        # estado conhecido para o teste.
        Tarefa.objects.all().delete()
        Tarefa.objects.create(titulo="Aprender Ninja", prioridade=3)
        Tarefa.objects.create(titulo="Beber agua", prioridade=1)
        Tarefa.objects.create(titulo="Aprender requests", prioridade=2)

        # filtro por titulo
        resp = self.client.get("/api/tarefas/?titulo=Aprender")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual({t["titulo"] for t in resp.json()},
                         {"Aprender Ninja", "Aprender requests"})

        # ordenacao por prioridade desc
        resp = self.client.get("/api/tarefas/?sort=-prioridade")
        self.assertEqual([t["prioridade"] for t in resp.json()], [3, 2, 1])

        # paginacao
        resp = self.client.get("/api/tarefas/?limit=2&offset=0")
        self.assertEqual(len(resp.json()), 2)
