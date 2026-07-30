from pathlib import Path
import os
import environ
from decouple import config, Csv

BASE_DIR = Path(__file__).resolve().parent.parent

# inicializar environ e ler ficheiro .env
env = environ.Env()
environ.Env.read_env(os.path.join(BASE_DIR, ".env"))

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost', cast=Csv())

CSRF_TRUSTED_ORIGINS = [
    "https://21908541.pw.deisi.ulusofona.pt",
]

# Permite embeber a documentacao Swagger da API (/api/docs) num <iframe> na
# propria aplicacao (mesma origem). Sem isto, o X-Frame-Options DENY do Django
# bloquearia o iframe na pagina "API" do menu.
X_FRAME_OPTIONS = "SAMEORIGIN"

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.sites",
    "allauth",
    "allauth.account",
    "allauth.socialaccount",
    "allauth.socialaccount.providers.google",
    "cloudinary",
    "cloudinary_storage",
    "markdownify.apps.MarkdownifyConfig",
    "django_extensions",
    "portfolio",
    "accounts.apps.AccountsConfig",
    "artigos.apps.ArtigosConfig",
    "tarefas.apps.TarefasConfig",
]

GRAPH_MODELS = {
    "all_applications": True,
    "group_models": True,
}

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "allauth.account.middleware.AccountMiddleware",
]

ROOT_URLCONF = "project.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [os.path.join(BASE_DIR, "templates")],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "project.wsgi.application"

DB_ENGINE = config('DB_ENGINE', default='sqlite')

if DB_ENGINE == 'postgres':
    # base de dados PostgreSQL em Neon (cloud) via DATABASE_URL
    DATABASES = {
        "default": env.db("DATABASE_URL")
    }
elif DB_ENGINE == 'mysql':
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': config('DB_NAME'),
            'USER': config('DB_USER'),
            'PASSWORD': config('DB_PASSWORD'),
            'HOST': config('DB_HOST', default='localhost'),
            'PORT': config('DB_PORT', default='3306'),
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "pt-pt"
TIME_ZONE = "Europe/Lisbon"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

FIXTURE_DIRS = [BASE_DIR]

# Media: o STORAGES default é Cloudinary (uploads novos vão para a cloud),
# mas mantemos MEDIA_URL/MEDIA_ROOT definidos conforme exigido na ficha.
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'mediafiles')

# Cloudinary: armazenamento de ficheiros media na cloud
CLOUDINARY_STORAGE = {
    'CLOUD_NAME': env('CLOUDINARY_CLOUD_NAME', default=''),
    'API_KEY': env('CLOUDINARY_API_KEY', default=''),
    'API_SECRET': env('CLOUDINARY_API_SECRET', default=''),
}

# Em produção usamos o backend "Manifest" do WhiteNoise (com hashing de
# nomes) porque há um passo de collectstatic no Dockerfile que gera o
# manifesto. Em testes/dev não há manifesto, por isso usamos o backend
# simples — evita ValueError: "Missing staticfiles manifest entry".
_USE_MANIFEST = config('USE_STATIC_MANIFEST', default=not DEBUG, cast=bool)

STORAGES = {
    "default": {
        "BACKEND": "cloudinary_storage.storage.MediaCloudinaryStorage",
    },
    "staticfiles": {
        "BACKEND": (
            "whitenoise.storage.CompressedManifestStaticFilesStorage"
            if _USE_MANIFEST
            else "django.contrib.staticfiles.storage.StaticFilesStorage"
        ),
    },
}

LOGIN_URL = "accounts:login"
LOGIN_REDIRECT_URL = "portfolio:index"
LOGOUT_REDIRECT_URL = "portfolio:index"

# django-allauth configuration
AUTHENTICATION_BACKENDS = [
    "django.contrib.auth.backends.ModelBackend",
    "allauth.account.auth_backends.AuthenticationBackend",
]

SITE_ID = 1

SOCIALACCOUNT_PROVIDERS = {
    "google": {
        "SCOPE": [
            "profile",
            "email",
        ],
        "AUTH_PARAMS": {
            "access_type": "online",
        },
    }
}

EMAIL_BACKEND = os.environ.get(
    "EMAIL_BACKEND",
    "django.core.mail.backends.console.EmailBackend",
)
EMAIL_HOST = os.environ.get("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.environ.get("EMAIL_PORT", "587"))
EMAIL_USE_TLS = os.environ.get("EMAIL_USE_TLS", "True") == "True"
EMAIL_HOST_USER = os.environ.get("EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.environ.get("EMAIL_HOST_PASSWORD", "")
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER or "webmaster@localhost"

MARKDOWNIFY = {
    "default": {
        "WHITELIST_TAGS": [
            'a', 'abbr', 'acronym',
            'strong', 'b',
            'blockquote', 'em', 'i',
            'ul', 'li', 'ol',
            'p',
            'h1', 'h2', 'h3', 'h4',
        ],
    },
    "alternative": {
        "WHITELIST_TAGS": ["a", "p"],
        "MARKDOWN_EXTENSIONS": ["markdown.extensions.fenced_code"],
    },
}
