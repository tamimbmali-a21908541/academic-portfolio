from django.test import TestCase

from artigos.forms import ArtigoForm, ComentarioForm


class TesteArtigoForm(TestCase):
    def test_texto_obrigatorio(self):
        form = ArtigoForm(data={})
        self.assertFalse(form.is_valid())
        self.assertIn("texto", form.errors)

    def test_form_valido(self):
        form = ArtigoForm(data={"texto": "ola mundo", "link_externo": ""})
        self.assertTrue(form.is_valid(), form.errors)

    def test_link_invalido_falha(self):
        form = ArtigoForm(data={"texto": "x", "link_externo": "not-a-url"})
        self.assertFalse(form.is_valid())
        self.assertIn("link_externo", form.errors)


class TesteComentarioForm(TestCase):
    def test_texto_obrigatorio(self):
        form = ComentarioForm(data={})
        self.assertFalse(form.is_valid())

    def test_form_valido(self):
        form = ComentarioForm(data={"texto": "interessante"})
        self.assertTrue(form.is_valid())
