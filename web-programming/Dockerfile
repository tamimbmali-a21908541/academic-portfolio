FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Defaults de BUILD apenas — em runtime são SOBREPOSTOS pelos -e do
# `docker run` no workflow .github/workflows/build-push-deploy.yml,
# que injecta os GitHub Secrets (SECRET_KEY, DATABASE_URL, CLOUDINARY_*).
ENV SECRET_KEY=build-placeholder-overridden-at-runtime
ENV DEBUG=False
ENV ALLOWED_HOSTS=21908541.pw.deisi.ulusofona.pt,localhost,127.0.0.1
ENV DB_ENGINE=sqlite

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

# collectstatic é seguro fazer em build (não precisa de BD nem de Cloudinary)
RUN python manage.py collectstatic --noinput

EXPOSE 3000

# Em runtime: aplica migrações em Neon (idempotente — no-op se já aplicadas)
# e arranca o gunicorn. As migrações precisam de DATABASE_URL, que vem dos
# Secrets via -e DATABASE_URL=... no docker run.
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn --bind 0.0.0.0:3000 project.wsgi:application"]
