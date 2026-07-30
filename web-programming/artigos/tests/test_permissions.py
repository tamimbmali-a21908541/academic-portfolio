from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.test import TestCase
from django.urls import reverse

from artigos.models import Artigo


class TesteCriacaoArtigoExigeAutor(TestCase):
    def setUp(self):
        User = get_user_model()
        self.normal = User.objects.create_user(username="normal", password="pw")
        self.autor = User.objects.create_user(username="aut", password="pw")
        autores, _ = Group.objects.get_or_create(name="autores")
        self.autor.groups.add(autores)

    def test_anonimo_redireciona_para_login(self):
        resp = self.client.get(reverse("artigos:artigo_novo"))
        self.assertEqual(resp.status_code, 302)
        self.assertIn(reverse("accounts:login"), resp.url)

    def test_user_sem_grupo_nao_acede(self):
        self.client.login(username="normal", password="pw")
        resp = self.client.get(reverse("artigos:artigo_novo"))
        self.assertEqual(resp.status_code, 302)

    def test_autor_acede(self):
        self.client.login(username="aut", password="pw")
        resp = self.client.get(reverse("artigos:artigo_novo"))
        self.assertEqual(resp.status_code, 200)


class TesteEdicaoArtigoSoDoAutor(TestCase):
    def setUp(self):
        User = get_user_model()
        self.dono = User.objects.create_user(username="dono", password="pw")
        self.outro = User.objects.create_user(username="outro", password="pw")
        autores, _ = Group.objects.get_or_create(name="autores")
        self.dono.groups.add(autores)
        self.outro.groups.add(autores)
        self.artigo = Artigo.objects.create(texto="meu", autor=self.dono)

    def test_dono_pode_editar(self):
        self.client.login(username="dono", password="pw")
        resp = self.client.get(reverse("artigos:artigo_editar", args=[self.artigo.id]))
        self.assertEqual(resp.status_code, 200)

    def test_outro_autor_nao_pode_editar(self):
        self.client.login(username="outro", password="pw")
        resp = self.client.get(reverse("artigos:artigo_editar", args=[self.artigo.id]))
        self.assertEqual(resp.status_code, 403)
