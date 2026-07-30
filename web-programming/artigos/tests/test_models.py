from django.contrib.auth import get_user_model
from django.test import TestCase

from artigos.models import Artigo, ArtigoLike, Comentario


class TesteModelosArtigos(TestCase):
    def setUp(self):
        User = get_user_model()
        self.user = User.objects.create_user(username="autor", password="pw")
        self.artigo = Artigo.objects.create(
            texto="Texto longo de exemplo " * 5,
            autor=self.user,
        )

    def test_artigo_str_eh_inicio_do_texto(self):
        self.assertTrue(str(self.artigo).startswith("Texto longo"))
        self.assertLessEqual(len(str(self.artigo)), 80)

    def test_comentario_str_inclui_username(self):
        c = Comentario.objects.create(
            artigo=self.artigo, autor=self.user, texto="Bom artigo"
        )
        self.assertIn(self.user.username, str(c))

    def test_artigolike_str_user_autenticado(self):
        like = ArtigoLike.objects.create(artigo=self.artigo, user=self.user)
        self.assertIn(self.user.username, str(like))

    def test_artigolike_str_user_anonimo(self):
        like = ArtigoLike.objects.create(artigo=self.artigo, session_key="abc123")
        self.assertIn("abc123", str(like))

    def test_artigo_relacao_likes(self):
        ArtigoLike.objects.create(artigo=self.artigo, user=self.user)
        self.assertEqual(self.artigo.likes.count(), 1)

    def test_artigo_relacao_comentarios(self):
        Comentario.objects.create(artigo=self.artigo, autor=self.user, texto="ola")
        Comentario.objects.create(artigo=self.artigo, autor=self.user, texto="adeus")
        self.assertEqual(self.artigo.comentarios.count(), 2)

    def test_artigo_propriedade_numero_likes(self):
        ArtigoLike.objects.create(artigo=self.artigo, user=self.user)
        self.assertEqual(self.artigo.numero_likes, 1)

    def test_artigo_propriedade_numero_comentarios(self):
        Comentario.objects.create(artigo=self.artigo, autor=self.user, texto="x")
        Comentario.objects.create(artigo=self.artigo, autor=self.user, texto="y")
        self.assertEqual(self.artigo.numero_comentarios, 2)
