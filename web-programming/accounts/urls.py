from django.urls import path

from . import views


app_name = 'accounts'
urlpatterns = [
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("registo/", views.register_view, name="register"),
    path("login/magic-link/", views.login_magic_link, name="login_magic_link"),
    path("autentica/", views.autentica_view, name="autentica"),
]
