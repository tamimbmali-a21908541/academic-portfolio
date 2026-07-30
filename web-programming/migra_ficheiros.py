"""
Script de migração de ficheiros media locais (pasta media/) para Cloudinary.

Para cada modelo com ImageField, lê o ficheiro local (se existir) e volta a
guardá-lo no campo. Como o STORAGES default já é o MediaCloudinaryStorage,
o save() faz upload automático para Cloudinary e a URL fica armazenada na BD.

Uso:
    python manage.py shell
    >>> import migra_ficheiros

NOTA: Quando o storage default é Cloudinary, obj.imagem.path lança
NotImplementedError. Por isso construímos o caminho local manualmente a
partir de MEDIA_ROOT + obj.imagem.name (que ainda é o caminho relativo
guardado durante a fase de armazenamento local).
"""

import os
from django.conf import settings
from django.core.files import File

from artigos.models import Artigo
from portfolio.models import (
    Licenciatura,
    Docente,
    UnidadeCurricular,
    Tecnologia,
    Projeto,
    TFC,
    MakingOf,
)


def migrar(model, field_name):
    """Migra um campo ImageField de um modelo para Cloudinary."""
    nome_modelo = model.__name__
    print(f"\n=== {nome_modelo}.{field_name} ===")

    total = migrados = ja_cloud = sem_ficheiro = vazios = 0

    for obj in model.objects.all():
        total += 1
        campo = getattr(obj, field_name)

        if not campo or not campo.name:
            vazios += 1
            continue

        # Se o name já é uma URL absoluta do Cloudinary, saltar
        if campo.name.startswith("http://") or campo.name.startswith("https://"):
            ja_cloud += 1
            continue

        # Caminho local (ainda em media/) — construído manualmente porque
        # com Cloudinary como default storage, .path não funciona.
        local_path = os.path.join(settings.MEDIA_ROOT, campo.name)

        if not os.path.exists(local_path):
            sem_ficheiro += 1
            print(f"  [skip] {obj} -> ficheiro não existe: {campo.name}")
            continue

        try:
            with open(local_path, "rb") as f:
                # Guardar com o mesmo nome de ficheiro; o upload_to do
                # ImageField vai prefixar a pasta correcta (e.g. makingof/).
                campo.save(
                    os.path.basename(local_path),
                    File(f),
                    save=True,
                )
            migrados += 1
            print(f"  [ok]   {obj} -> {campo.url}")
        except Exception as e:
            print(f"  [erro] {obj}: {e}")

    print(
        f"  Total: {total} | migrados: {migrados} | já cloud: {ja_cloud} "
        f"| sem ficheiro local: {sem_ficheiro} | campo vazio: {vazios}"
    )


# Lista de (Modelo, nome_do_campo_imagem)
ALVOS = [
    (Artigo, "fotografia"),
    (Licenciatura, "imagem"),
    (Docente, "foto"),
    (UnidadeCurricular, "imagem"),
    (Tecnologia, "logo"),
    (Projeto, "imagem"),
    (TFC, "imagem"),
    (MakingOf, "fotografia"),
]

print("Iniciando migração de ficheiros media -> Cloudinary...")
for modelo, campo in ALVOS:
    migrar(modelo, campo)
print("\nMigração concluída.")
