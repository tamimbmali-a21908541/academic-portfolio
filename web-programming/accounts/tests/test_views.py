from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse


class TesteLoginView(TestCase):
    def setUp(self):
        User = get_user_model()
        self.user = User.objects.create_user(username="zeca", password="pw1234!!")

    def test_get_apresenta_form(self):
        resp = self.client.get(reverse("accounts:login"))
        self.assertEqual(resp.status_code, 200)
        self.assertTemplateUsed(resp, "accounts/login.html")

    def test_post_credenciais_validas_redireciona(self):
        resp = self.client.post(
            reverse("accounts:login"),
            {"username": "zeca", "password": "pw1234!!"},
        )
        self.assertEqual(resp.status_code, 302)
        self.assertEqual(resp.url, reverse("portfolio:index"))

    def test_post_credenciais_invalidas_fica_no_form(self):
        resp = self.client.post(
            reverse("accounts:login"),
            {"username": "zeca", "password": "errado"},
        )
        self.assertEqual(resp.status_code, 200)


class TesteRegisterView(TestCase):
    def test_get_apresenta_form(self):
        resp = self.client.get(reverse("accounts:register"))
        self.assertEqual(resp.status_code, 200)
        self.assertTemplateUsed(resp, "accounts/register.html")

    def test_post_cria_user_e_autentica(self):
        resp = self.client.post(
            reverse("accounts:register"),
            {
                "username": "novo",
                "email": "novo@example.com",
                "password1": "MaracujA-90!@",
                "password2": "MaracujA-90!@",
            },
        )
        self.assertEqual(resp.status_code, 302)
        User = get_user_model()
        self.assertTrue(User.objects.filter(username="novo").exists())


class TesteLogoutView(TestCase):
    def test_logout_anonimo_redireciona_para_login(self):
        resp = self.client.get(reverse("accounts:logout"))
        self.assertEqual(resp.status_code, 302)
        self.assertIn(reverse("accounts:login"), resp.url)

    def test_logout_autenticado_termina_sessao(self):
        User = get_user_model()
        User.objects.create_user(username="x", password="pw1234!!")
        self.client.login(username="x", password="pw1234!!")
        resp = self.client.get(reverse("accounts:logout"))
        self.assertEqual(resp.status_code, 302)
