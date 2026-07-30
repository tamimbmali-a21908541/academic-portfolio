from django.contrib import messages
from django.contrib.auth.decorators import login_required, user_passes_test
from django.core.exceptions import PermissionDenied
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse

from .forms import ArtigoForm, ComentarioForm
from .models import Artigo, ArtigoLike, Rating


def is_autor(user):
    return user.is_authenticated and (
        user.is_superuser or user.groups.filter(name="autores").exists()
    )


def artigos_view(request):
    artigos = Artigo.objects.select_related("autor").prefetch_related("likes").all()
    return render(request, "artigos/lista.html", {"artigos": artigos})


def artigo_detalhe(request, id):
    artigo = get_object_or_404(
        Artigo.objects.select_related("autor").prefetch_related("comentarios__autor"),
        id=id,
    )

    if request.method == "POST":
        if not request.user.is_authenticated:
            return redirect("accounts:login")
        comentario_form = ComentarioForm(request.POST)
        if comentario_form.is_valid():
            comentario = comentario_form.save(commit=False)
            comentario.artigo = artigo
            comentario.autor = request.user
            comentario.save()
            return redirect("artigos:artigo_detalhe", id=artigo.id)
    else:
        comentario_form = ComentarioForm()

    can_edit = is_autor(request.user) and (
        request.user.is_superuser or artigo.autor_id == request.user.id
    )
    return render(
        request,
        "artigos/detalhe.html",
        {
            "artigo": artigo,
            "comentario_form": comentario_form,
            "can_edit": can_edit,
        },
    )


@login_required
@user_passes_test(is_autor)
def artigo_novo(request):
    if request.method == "POST":
        form = ArtigoForm(request.POST, request.FILES)
        if form.is_valid():
            artigo = form.save(commit=False)
            artigo.autor = request.user
            artigo.save()
            messages.success(request, "Artigo criado.")
            return redirect("artigos:artigo_detalhe", id=artigo.id)
    else:
        form = ArtigoForm()

    return render(request, "artigos/form.html", {"form": form, "modo": "novo"})


@login_required
@user_passes_test(is_autor)
def artigo_editar(request, id):
    artigo = get_object_or_404(Artigo, id=id)
    if not request.user.is_superuser and artigo.autor_id != request.user.id:
        raise PermissionDenied

    if request.method == "POST":
        form = ArtigoForm(request.POST, request.FILES, instance=artigo)
        if form.is_valid():
            form.save()
            messages.success(request, "Artigo atualizado.")
            return redirect("artigos:artigo_detalhe", id=artigo.id)
    else:
        form = ArtigoForm(instance=artigo)

    return render(
        request,
        "artigos/form.html",
        {"form": form, "modo": "editar", "artigo": artigo},
    )


def artigo_like(request, id):
    artigo = get_object_or_404(Artigo, id=id)
    if request.method != "POST":
        return redirect("artigos:artigo_detalhe", id=artigo.id)

    if request.user.is_authenticated:
        like = ArtigoLike.objects.filter(artigo=artigo, user=request.user).first()
        if like:
            like.delete()
        else:
            ArtigoLike.objects.create(artigo=artigo, user=request.user)
    else:
        if not request.session.session_key:
            request.session.create()
        like = ArtigoLike.objects.filter(
            artigo=artigo,
            user__isnull=True,
            session_key=request.session.session_key,
        ).first()
        if like:
            like.delete()
        else:
            ArtigoLike.objects.create(
                artigo=artigo,
                session_key=request.session.session_key,
            )

    return redirect(request.META.get("HTTP_REFERER") or reverse("artigos:artigo_detalhe", args=[artigo.id]))


def artigo_rating(request, id):
    artigo = get_object_or_404(Artigo, id=id)
    if request.method != "POST":
        return redirect("artigos:artigo_detalhe", id=artigo.id)

    pontuacao = request.POST.get("pontuacao")
    if not pontuacao or not pontuacao.isdigit():
        messages.error(request, "Pontuacao invalida.")
        return redirect("artigos:artigo_detalhe", id=artigo.id)

    pontuacao = int(pontuacao)
    if pontuacao < 1 or pontuacao > 5:
        messages.error(request, "Pontuacao deve ser entre 1 e 5.")
        return redirect("artigos:artigo_detalhe", id=artigo.id)

    if request.user.is_authenticated:
        rating, created = Rating.objects.update_or_create(
            artigo=artigo,
            user=request.user,
            defaults={"pontuacao": pontuacao, "session_key": ""},
        )
    else:
        if not request.session.session_key:
            request.session.create()
        rating, created = Rating.objects.update_or_create(
            artigo=artigo,
            user__isnull=True,
            session_key=request.session.session_key,
            defaults={"pontuacao": pontuacao},
        )

    if created:
        messages.success(request, "Pontuacao registada.")
    else:
        messages.success(request, "Pontuacao atualizada.")

    return redirect(request.META.get("HTTP_REFERER") or reverse("artigos:artigo_detalhe", args=[artigo.id]))
