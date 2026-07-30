from django.urls import path

from . import views


app_name = 'artigos'
urlpatterns = [
    path("", views.artigos_view, name="artigos"),
    path("novo/", views.artigo_novo, name="artigo_novo"),
    path("<int:id>/", views.artigo_detalhe, name="artigo_detalhe"),
    path("<int:id>/editar/", views.artigo_editar, name="artigo_editar"),
    path("<int:id>/like/", views.artigo_like, name="artigo_like"),
    path("<int:id>/rating/", views.artigo_rating, name="artigo_rating"),
]
