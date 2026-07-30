from django.contrib.auth import get_user_model
from django.test import TestCase

from accounts.forms import BaseUserCreationForm, LoginForm


class TesteLoginForm(TestCase):
    def test_campos_obrigatorios(self):
        form = LoginForm(data={})
        self.assertFalse(form.is_valid())
        self.assertIn("username", form.errors)
        self.assertIn("password", form.errors)

    def test_form_valido(self):
        form = LoginForm(data={"username": "x", "password": "y"})
        self.assertTrue(form.is_valid())


class TesteBaseUserCreationForm(TestCase):
    def test_email_obrigatorio(self):
        form = BaseUserCreationForm(data={
            "username": "alguem",
            "password1": "Pw9-MaisForte!",
            "password2": "Pw9-MaisForte!",
        })
        self.assertFalse(form.is_valid())
        self.assertIn("email", form.errors)

    def test_save_atribui_grupo_autores(self):
        form = BaseUserCreationForm(data={
            "username": "alguem",
            "email": "x@example.com",
            "password1": "Pw9-MaisForte!",
            "password2": "Pw9-MaisForte!",
        })
        self.assertTrue(form.is_valid(), form.errors)
        user = form.save()
        self.assertTrue(user.groups.filter(name="autores").exists())
