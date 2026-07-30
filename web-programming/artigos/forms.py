from django import forms

from .models import Artigo, Comentario


class ArtigoForm(forms.ModelForm):
    class Meta:
        model = Artigo
        fields = ["texto", "fotografia", "link_externo"]
        widgets = {
            "texto": forms.Textarea(attrs={"rows": 8}),
        }
        labels = {
            "texto": "Conteúdo do artigo",
            "fotografia": "Fotografia",
            "link_externo": "Link externo",
        }
        help_texts = {
            "fotografia": "Imagem ilustrativa, opcional (< 1 MB).",
            "link_externo": "URL relacionado, opcional.",
        }


class ComentarioForm(forms.ModelForm):
    class Meta:
        model = Comentario
        fields = ["nome_anonimo", "texto"]
        widgets = {
            "nome_anonimo": forms.TextInput(
                attrs={"placeholder": "O seu nome (opcional)"}
            ),
            "texto": forms.Textarea(
                attrs={"rows": 3, "placeholder": "Escreva um comentario"}
            ),
        }
        labels = {
            "nome_anonimo": "Nome",
            "texto": "Comentário",
        }
