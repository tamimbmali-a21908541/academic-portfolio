import secrets
from datetime import timedelta

from django.conf import settings
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.core.mail import send_mail
from django.shortcuts import redirect, render
from django.urls import reverse
from django.utils import timezone
from django.utils.http import url_has_allowed_host_and_scheme

from .forms import BaseUserCreationForm, LoginForm
from .models import Profile


def _safe_next_url(request):
    next_url = request.POST.get("next") or request.GET.get("next")
    if next_url and url_has_allowed_host_and_scheme(
        next_url,
        allowed_hosts={request.get_host()},
    ):
        return next_url
    return reverse("portfolio:index")


def login_view(request):
    if request.user.is_authenticated:
        return redirect("portfolio:index")

    if request.method == "POST":
        form = LoginForm(request.POST)
        if form.is_valid():
            user = authenticate(
                request,
                username=form.cleaned_data["username"],
                password=form.cleaned_data["password"],
            )
            if user is not None:
                login(request, user)
                return redirect(_safe_next_url(request))
            messages.error(request, "Credenciais invalidas.")
    else:
        form = LoginForm()

    return render(request, "accounts/login.html", {"form": form})


@login_required
def logout_view(request):
    logout(request)
    messages.success(request, "Sessao terminada.")
    return redirect("portfolio:index")


def register_view(request):
    if request.user.is_authenticated:
        return redirect("portfolio:index")

    if request.method == "POST":
        form = BaseUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user, backend="django.contrib.auth.backends.ModelBackend")
            messages.success(request, "Conta criada com sucesso.")
            return redirect("portfolio:index")
    else:
        form = BaseUserCreationForm()

    return render(request, "accounts/register.html", {"form": form})


def login_magic_link(request):
    email = request.GET.get("email", "").strip()
    if not email:
        messages.error(request, "Indique um email.")
        return redirect("accounts:login")

    User = get_user_model()
    user = User.objects.filter(email__iexact=email).first()
    if user:
        profile, _ = Profile.objects.get_or_create(user=user)
        profile.magic_token = secrets.token_urlsafe(32)
        profile.token_created_at = timezone.now()
        profile.save(update_fields=["magic_token", "token_created_at"])

        link = request.build_absolute_uri(
            f"{reverse('accounts:autentica')}?token={profile.magic_token}"
        )
        send_mail(
            "Link de autenticacao",
            f"Use este link para entrar no portfolio: {link}",
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )

    messages.success(
        request,
        "Se o email estiver registado, foi enviado um link de autenticacao.",
    )
    return redirect("accounts:login")


def autentica_view(request):
    token = request.GET.get("token", "").strip()
    if not token:
        messages.error(request, "Link de autenticacao invalido.")
        return redirect("accounts:login")

    profile = Profile.objects.select_related("user").filter(magic_token=token).first()
    if not profile or not profile.token_created_at:
        messages.error(request, "Link de autenticacao invalido.")
        return redirect("accounts:login")

    if timezone.now() - profile.token_created_at > timedelta(hours=1):
        profile.magic_token = ""
        profile.token_created_at = None
        profile.save(update_fields=["magic_token", "token_created_at"])
        messages.error(request, "Link de autenticacao expirado.")
        return redirect("accounts:login")

    login(request, profile.user, backend="django.contrib.auth.backends.ModelBackend")
    profile.magic_token = ""
    profile.token_created_at = None
    profile.save(update_fields=["magic_token", "token_created_at"])
    return redirect("portfolio:index")
