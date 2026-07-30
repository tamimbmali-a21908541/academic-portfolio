from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.test import TestCase
from django.urls import reverse

from artigos.models import Artigo, ArtigoLike, Comentario


class TesteListaEDetalhe(TestCase):
    @classmethod
    def setUpTestData(cls):
        User = get_user_model()
        cls.user = User.objects.create_user(username="autor", password="pw")
        cls.artigo = Artigo.objects.create(
            texto="Texto de demonstracao publica",
            autor=cls.user,
        )

    def test_lista_artigos_status_e_template(self):
        response = self.client.get(reverse("artigos:artigos"))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "artigos/lista.html")
        self.assertContains(response, "Texto de demonstracao")

    def test_detalhe_artigo_status_e_template(self):
        response = self.client.get(reverse("artigos:artigo_detalhe", args=[self.artigo.id]))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "artigos/detalhe.html")
        self.assertContains(response, "Texto de demonstracao")

    def test_detalhe_artigo_inexistente_404(self):
        response = self.client.get(reverse("artigos:artigo_detalhe", args=[99999]))
        self.assertEqual(response.status_code, 404)


class TesteComentarioPost(TestCase):
    def setUp(self):
        User = get_user_model()
        self.autor = User.objects.create_user(username="autor", password="pw")
        self.leitor = User.objects.create_user(username="leitor", password="pw")
        self.artigo = Artigo.objects.create(texto="A", autor=self.autor)

    def test_anonimo_nao_pode_comentar(self):
        resp = self.client.post(
            reverse("artigos:artigo_detalhe", args=[self.artigo.id]),
            {"texto": "comentario"},
        )
        self.assertEqual(resp.status_code, 302)
        self.assertEqual(Comentario.objects.count(), 0)

    def test_autenticado_cria_comentario(self):
        self.client.login(username="leitor", password="pw")
        resp = self.client.post(
            reverse("artigos:artigo_detalhe", args=[self.artigo.id]),
            {"texto": "Excelente"},
        )
        self.assertEqual(resp.status_code, 302)
        self.assertEqual(Comentario.objects.count(), 1)
        self.assertEqual(Comentario.objects.first().autor, self.leitor)


class TesteLikes(TestCase):
    def setUp(self):
        User = get_user_model()
        self.autor = User.objects.create_user(username="autor", password="pw")
        self.user = User.objects.create_user(username="lker", password="pw")
        self.artigo = Artigo.objects.create(texto="t", autor=self.autor)

    def test_get_redireciona(self):
        resp = self.client.get(reverse("artigos:artigo_like", args=[self.artigo.id]))
        self.assertEqual(resp.status_code, 302)

    def test_post_autenticado_adiciona_like(self):
        self.client.login(username="lker", password="pw")
        self.client.post(reverse("artigos:artigo_like", args=[self.artigo.id]))
        self.assertEqual(ArtigoLike.objects.filter(artigo=self.artigo).count(), 1)

    def test_post_autenticado_segundo_remove_like(self):
        self.client.login(username="lker", password="pw")
        self.client.post(reverse("artigos:artigo_like", args=[self.artigo.id]))
        self.client.post(reverse("artigos:artigo_like", args=[self.artigo.id]))
        self.assertEqual(ArtigoLike.objects.filter(artigo=self.artigo).count(), 0)

    def test_post_anonimo_cria_like_por_sessao(self):
        self.client.post(reverse("artigos:artigo_like", args=[self.artigo.id]))
        self.assertEqual(
            ArtigoLike.objects.filter(artigo=self.artigo, user__isnull=True).count(),
            1,
        )
