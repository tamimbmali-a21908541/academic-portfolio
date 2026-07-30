from django.contrib import admin

from .models import Tarefa


@admin.register(Tarefa)
class TarefaAdmin(admin.ModelAdmin):
    list_display = ("titulo", "prioridade", "concluida", "data_limite", "data_criacao")
    list_filter = ("prioridade", "concluida")
    search_fields = ("titulo", "descricao")
    list_editable = ("prioridade", "concluida")
    ordering = ("concluida", "-prioridade", "data_limite", "titulo")
