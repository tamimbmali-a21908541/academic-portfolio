from django.contrib import admin
from django.urls import path, include

from portfolio.api import api as portfolio_api

urlpatterns = [
    path("admin/", admin.site.urls),
    path("accounts/", include("accounts.urls")),
    path("accounts/social/", include("allauth.urls")),
    path("artigos/", include("artigos.urls")),
    # API RESTful (Django Ninja) + documentacao Swagger em /api/docs
    path("api/", portfolio_api.urls),
    path("", include("portfolio.urls")),
]

# Os ficheiros media são agora servidos directamente pelo Cloudinary
# (https://res.cloudinary.com/...) — já não é preciso o Django servir /media/.
