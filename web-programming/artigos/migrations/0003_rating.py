# Generated manually on 2026-05-13

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ("artigos", "0002_comentario_anonimo"),
    ]

    operations = [
        migrations.CreateModel(
            name="Rating",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("session_key", models.CharField(blank=True, max_length=40)),
                (
                    "pontuacao",
                    models.PositiveSmallIntegerField(
                        choices=[(1, 1), (2, 2), (3, 3), (4, 4), (5, 5)],
                        verbose_name="Pontuacao (1-5)",
                    ),
                ),
                ("data_criacao", models.DateTimeField(auto_now_add=True)),
                (
                    "artigo",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="ratings",
                        to="artigos.artigo",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="ratings_artigos",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "ordering": ["-data_criacao"],
            },
        ),
        migrations.AddConstraint(
            model_name="rating",
            constraint=models.UniqueConstraint(
                fields=("artigo", "session_key"),
                name="unique_rating_per_session",
            ),
        ),
    ]
