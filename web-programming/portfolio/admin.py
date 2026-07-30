from django.contrib import admin
from .models import (
    Licenciatura, Docente, UnidadeCurricular, Tecnologia, TipoTecnologia,
    Projeto, TFC, Competencia, Formacao, MakingOf, Interesse, APIKey
)

@admin.register(TipoTecnologia)
class TipoTecnologiaAdmin(admin.ModelAdmin):
    list_display = ('nome', 'ordem')
    search_fields = ('nome',)
    ordering = ('ordem', 'nome')

@admin.register(Licenciatura)
class LicenciaturaAdmin(admin.ModelAdmin):
    list_display = ('nome', 'instituicao', 'grau', 'duracao_anos', 'ects_total', 'codigo_curso')
    search_fields = ('nome', 'instituicao')
    list_filter = ('grau', 'instituicao')

@admin.register(Docente)
class DocenteAdmin(admin.ModelAdmin):
    list_display = ('nome', 'email', 'link_lusofona')
    search_fields = ('nome', 'email')

@admin.register(UnidadeCurricular)
class UnidadeCurricularAdmin(admin.ModelAdmin):
    list_display = ('nome', 'codigo', 'ano_curricular', 'semestre', 'ects', 'licenciatura')
    search_fields = ('nome', 'codigo')
    list_filter = ('ano_curricular', 'semestre', 'licenciatura')
    filter_horizontal = ('docentes',)

@admin.register(Tecnologia)
class TecnologiaAdmin(admin.ModelAdmin):
    list_display = ('nome', 'tipo', 'nivel_interesse', 'link_oficial')
    search_fields = ('nome',)
    list_filter = ('tipo', 'nivel_interesse')
    filter_horizontal = ('ucs',)
    autocomplete_fields = ('tipo',)

@admin.register(Projeto)
class ProjetoAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'uc', 'data_inicio', 'data_fim', 'nota', 'link_github')
    search_fields = ('titulo', 'descricao')
    list_filter = ('uc', 'data_fim')
    filter_horizontal = ('tecnologias',)

@admin.register(TFC)
class TFCAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'autores', 'orientador', 'ano', 'classificacao_interesse')
    search_fields = ('titulo', 'autores', 'orientador', 'tags')
    list_filter = ('ano', 'classificacao_interesse')

@admin.register(Competencia)
class CompetenciaAdmin(admin.ModelAdmin):
    list_display = ('nome', 'nivel', 'categoria')
    search_fields = ('nome',)
    list_filter = ('nivel', 'categoria')
    filter_horizontal = ('tecnologias', 'projetos')

@admin.register(Formacao)
class FormacaoAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'tipo', 'instituicao', 'data_inicio', 'data_fim', 'em_curso')
    search_fields = ('titulo', 'instituicao')
    list_filter = ('tipo', 'em_curso')

@admin.register(MakingOf)
class MakingOfAdmin(admin.ModelAdmin):
    list_display = ('titulo', 'tipo', 'entidade_relacionada', 'data_registo')
    search_fields = ('titulo', 'descricao', 'entidade_relacionada')
    list_filter = ('tipo', 'entidade_relacionada')

@admin.register(Interesse)
class InteresseAdmin(admin.ModelAdmin):
    list_display = ('area', 'nivel_interesse', 'objetivo_profissional')
    search_fields = ('descricao', 'objetivo_profissional')
    list_filter = ('area', 'nivel_interesse')
    filter_horizontal = ('tecnologias', 'projetos')


@admin.register(APIKey)
class APIKeyAdmin(admin.ModelAdmin):
    list_display = ('name', 'key', 'is_active', 'expiration_date', 'created_at')
    list_filter = ('is_active',)
    search_fields = ('name',)
    readonly_fields = ('key', 'created_at')
