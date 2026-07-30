from django.conf import settings
from django.db import models


class Artigo(models.Model):
    texto = models.TextField()
    fotografia = models.ImageField(upload_to="artigos/", blank=True, null=True)
    link_externo = models.URLField(blank=True)
    data_criacao = models.DateTimeField(auto_now_add=True)
    autor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="artigos",
    )

    class Meta:
        ordering = ["-data_criacao"]

    def __str__(self):
        return self.texto[:80]

    @property
    def numero_likes(self):
        return self.likes.count()

    @property
    def numero_comentarios(self):
        return self.comentarios.count()

    @property
    def media_pontuacao(self):
        ratings = self.ratings.all()
        if not ratings:
            return 0
        return round(sum(r.pontuacao for r in ratings) / ratings.count(), 1)

    @property
    def numero_ratings(self):
        return self.ratings.count()


class Comentario(models.Model):
    artigo = models.ForeignKey(
        Artigo,
        on_delete=models.CASCADE,
        related_name="comentarios",
    )
    autor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="comentarios_artigos",
        blank=True,
        null=True,
    )
    nome_anonimo = models.CharField(max_length=100, blank=True, verbose_name="Nome")
    texto = models.TextField()
    data_criacao = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["data_criacao"]

    def __str__(self):
        nome = self.autor.username if self.autor else (self.nome_anonimo or "Anonimo")
        return f"{nome}: {self.texto[:50]}"

    @property
    def nome_exibicao(self):
        if self.autor:
            return self.autor.username
        return self.nome_anonimo or "Anonimo"


class ArtigoLike(models.Model):
    artigo = models.ForeignKey(
        Artigo,
        on_delete=models.CASCADE,
        related_name="likes",
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="likes_artigos",
    )
    session_key = models.CharField(max_length=40, blank=True)
    data_criacao = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-data_criacao"]
        unique_together = [["artigo", "session_key"]]

    def __str__(self):
        actor = self.user.username if self.user_id else self.session_key
        return f"{actor} gostou de {self.artigo_id}"


class Rating(models.Model):
    artigo = models.ForeignKey(
        Artigo,
        on_delete=models.CASCADE,
        related_name="ratings",
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="ratings_artigos",
    )
    session_key = models.CharField(max_length=40, blank=True)
    pontuacao = models.PositiveSmallIntegerField(
        choices=[(i, i) for i in range(1, 6)],
        verbose_name="Pontuacao (1-5)",
    )
    data_criacao = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-data_criacao"]
        unique_together = [["artigo", "session_key"]]

    def __str__(self):
        actor = self.user.username if self.user_id else self.session_key
        return f"{actor}: {self.pontuacao} estrelas"
