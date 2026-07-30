# Generated manually on 2026-05-13

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ("artigos", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="comentario",
            name="nome_anonimo",
            field=models.CharField(blank=True, max_length=100, verbose_name="Nome"),
        ),
        migrations.AlterField(
            model_name="comentario",
            name="autor",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="comentarios_artigos",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
    ]
