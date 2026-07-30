from django.contrib import admin

from .models import Artigo, ArtigoLike, Comentario


@admin.register(Artigo)
class ArtigoAdmin(admin.ModelAdmin):
    list_display = ("id", "autor", "data_criacao", "link_externo")
    search_fields = ("texto", "autor__username")
    list_filter = ("data_criacao", "autor")


@admin.register(Comentario)
class ComentarioAdmin(admin.ModelAdmin):
    list_display = ("artigo", "autor", "data_criacao")
    search_fields = ("texto", "autor__username")
    list_filter = ("data_criacao",)


@admin.register(ArtigoLike)
class ArtigoLikeAdmin(admin.ModelAdmin):
    list_display = ("artigo", "user", "session_key", "data_criacao")
    list_filter = ("data_criacao",)
