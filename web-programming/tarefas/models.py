"""Modelo `Tarefa` — a API partilhada com o(a) colega de laboratorio
(ficha 13, info1.txt). Vive numa app dedicada para que a logica fique
isolada do resto do portfolio."""

from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models


class Tarefa(models.Model):
    PRIORIDADE_CHOICES = [
        (1, "Baixa"),
        (2, "Media"),
        (3, "Alta"),
    ]

    titulo = models.CharField(max_length=200)
    descricao = models.TextField(blank=True)
    prioridade = models.IntegerField(
        default=2,
        choices=PRIORIDADE_CHOICES,
        validators=[MinValueValidator(1), MaxValueValidator(3)],
        help_text="1=Baixa, 2=Media, 3=Alta",
    )
    concluida = models.BooleanField(default=False)
    data_limite = models.DateField(null=True, blank=True)
    data_criacao = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Tarefa"
        verbose_name_plural = "Tarefas"
        ordering = ["concluida", "-prioridade", "data_limite", "titulo"]

    def __str__(self):
        return self.titulo
