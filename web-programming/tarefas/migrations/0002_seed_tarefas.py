"""Data migration: semeia algumas tarefas de exemplo para a API ja
responder com conteudo logo no primeiro deploy. Idempotente: usa
get_or_create por titulo, pelo que correr varias vezes nao duplica."""

from datetime import date, timedelta

from django.db import migrations


SEMENTES = [
    {"titulo": "Entregar relatorio de ficha 12",
     "descricao": "Compilar a documentacao da API RESTful e submeter.",
     "prioridade": 3, "concluida": False, "data_limite_delta": 7},
    {"titulo": "Estudar Django Ninja - autenticacao",
     "descricao": "Rever o capitulo de auth e fazer demos com APIKey.",
     "prioridade": 2, "concluida": False, "data_limite_delta": 14},
    {"titulo": "Configurar GitHub Secrets para a API",
     "descricao": "Adicionar COLEGA_API_KEY no repositorio.",
     "prioridade": 2, "concluida": True, "data_limite_delta": -3},
    {"titulo": "Marcar reuniao com o colega para trocar API Keys",
     "descricao": "Combinar com o(a) colega e trocar as chaves.",
     "prioridade": 1, "concluida": True, "data_limite_delta": -10},
    {"titulo": "Gravar videotutorial sobre requests",
     "descricao": "Explicar como consumir uma API com a biblioteca requests.",
     "prioridade": 1, "concluida": False, "data_limite_delta": 21},
]


def seed(apps, schema_editor):
    Tarefa = apps.get_model("tarefas", "Tarefa")
    hoje = date.today()
    for s in SEMENTES:
        Tarefa.objects.get_or_create(
            titulo=s["titulo"],
            defaults={
                "descricao": s["descricao"],
                "prioridade": s["prioridade"],
                "concluida": s["concluida"],
                "data_limite": hoje + timedelta(days=s["data_limite_delta"]),
            },
        )


def unseed(apps, schema_editor):
    Tarefa = apps.get_model("tarefas", "Tarefa")
    Tarefa.objects.filter(titulo__in=[s["titulo"] for s in SEMENTES]).delete()


class Migration(migrations.Migration):
    dependencies = [
        ("tarefas", "0001_initial"),
    ]
    operations = [
        migrations.RunPython(seed, reverse_code=unseed),
    ]
