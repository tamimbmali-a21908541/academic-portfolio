from django.test import SimpleTestCase
from django.urls import resolve, reverse

from artigos import views


class TesteUrlsArtigos(SimpleTestCase):
    def test_lista_artigos(self):
        url = reverse("artigos:artigos")
        self.assertEqual(url, "/artigos/")
        self.assertEqual(resolve(url).func, views.artigos_view)

    def test_artigo_novo(self):
        url = reverse("artigos:artigo_novo")
        self.assertEqual(url, "/artigos/novo/")
        self.assertEqual(resolve(url).func, views.artigo_novo)

    def test_artigo_detalhe(self):
        url = reverse("artigos:artigo_detalhe", args=[7])
        self.assertEqual(url, "/artigos/7/")
        self.assertEqual(resolve(url).func, views.artigo_detalhe)

    def test_artigo_editar(self):
        url = reverse("artigos:artigo_editar", args=[7])
        self.assertEqual(url, "/artigos/7/editar/")
        self.assertEqual(resolve(url).func, views.artigo_editar)

    def test_artigo_like(self):
        url = reverse("artigos:artigo_like", args=[7])
        self.assertEqual(url, "/artigos/7/like/")
        self.assertEqual(resolve(url).func, views.artigo_like)
