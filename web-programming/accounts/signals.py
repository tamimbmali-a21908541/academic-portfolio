from django.conf import settings
from django.contrib.auth.models import Group, Permission
from django.db.models.signals import post_migrate, post_save
from django.dispatch import receiver

from .models import Profile


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def ensure_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.get_or_create(user=instance)


@receiver(post_migrate)
def setup_default_groups(sender, **kwargs):
    portfolio_models = [
        "licenciatura",
        "docente",
        "unidadecurricular",
        "tipotecnologia",
        "tecnologia",
        "projeto",
        "tfc",
        "competencia",
        "formacao",
        "makingof",
        "interesse",
    ]
    artigos_models = ["artigo", "comentario", "artigolike"]

    gestor_permissions = Permission.objects.filter(
        content_type__app_label="portfolio",
        content_type__model__in=portfolio_models,
    )
    autor_permissions = Permission.objects.filter(
        content_type__app_label="artigos",
        content_type__model__in=artigos_models,
    )

    gestor_group, _ = Group.objects.get_or_create(name="gestor-portfolio")
    gestor_group.permissions.set(gestor_permissions)

    autores_group, _ = Group.objects.get_or_create(name="autores")
    autores_group.permissions.set(autor_permissions)
