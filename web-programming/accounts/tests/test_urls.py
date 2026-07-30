from django.test import SimpleTestCase
from django.urls import resolve, reverse

from accounts import views


class TesteUrlsAccounts(SimpleTestCase):
    casos = [
        ("accounts:login", "/accounts/login/", views.login_view),
        ("accounts:logout", "/accounts/logout/", views.logout_view),
        ("accounts:register", "/accounts/registo/", views.register_view),
        ("accounts:login_magic_link", "/accounts/login/magic-link/", views.login_magic_link),
        ("accounts:autentica", "/accounts/autentica/", views.autentica_view),
    ]

    def test_reverse_devolve_path_esperado(self):
        for name, expected, _ in self.casos:
            with self.subTest(name=name):
                self.assertEqual(reverse(name), expected)

    def test_resolve_devolve_view_esperada(self):
        for _, path, view in self.casos:
            with self.subTest(path=path):
                self.assertEqual(resolve(path).func, view)
