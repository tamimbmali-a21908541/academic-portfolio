# Web Programming

> A Django 5.2 portfolio platform with articles, task management, and authentication — including a typed REST API built with django-ninja, anonymous-capable engagement (likes, ratings, comments), and Selenium end-to-end test suites.

**Grade:** 17/20 · **ECTS:** 6 · **Year:** 2 · **Institution:** Universidade Lusófona

*The highest-graded course of Year 2.*

---

## Overview

One Django project composed of four apps sharing a settings module, user model, and migration history. The interesting parts are the API design and the engagement model — specifically, letting unauthenticated visitors participate without letting them cheat.

## Applications

| App | What it does |
|---|---|
| **portfolio** | The portfolio CMS — projects, skills, technologies, and training |
| **artigos** | Articles with comments, likes, and star ratings |
| **tarefas** | Task management, exposed through a typed REST API |
| **accounts** | Authentication, registration, and profile handling |

## Notable implementation details

**Typed REST API with django-ninja.** `tarefas/schemas.py` follows a deliberate convention — `TarefaIn` for request payloads, `TarefaOut` for responses (including `id`), and a single `ErrorSchema` so every error returns the same `detail` shape. Pydantic validates at the boundary, so handlers receive already-valid data and the OpenAPI schema is generated rather than hand-written.

**Anonymous engagement without double-voting.** `ArtigoLike` and `Rating` each carry *both* a nullable `user` foreign key and a `session_key`. Logged-in users are identified by account; anonymous visitors by session. That is what allows participation without an account while still enforcing one vote per visitor — a schema-level answer to a problem usually bodged in the view layer.

**Comments accept a name from anonymous posters** (`nome_anonimo`) while still linking to a `user` when one is present, so the same model serves both cases.

**Sanitised rich text.** `bleach` plus `django-markdownify` means article content is rendered as Markdown but escaped against XSS rather than trusted.

## Testing

Unit tests are organised per app in dedicated `tests/` packages — forms, models, URLs, views, and permissions tested separately:

- `accounts/tests/` — 5 modules
- `artigos/tests/` — 6 modules, including `test_permissions.py`
- `tarefas/tests/` — including `test_api.py`

Plus three **Selenium WebDriver** suites at the project root covering authentication, navigation, and project flows end to end.

## Tech stack

**Core** — Django 5.2.14, Python
**API** — django-ninja 1.4 with Pydantic 2 schemas
**Auth** — django-allauth (OAuth), PyJWT
**Content** — Markdown, django-markdownify, bleach sanitisation
**Media** — Cloudinary via django-cloudinary-storage, Pillow
**Database** — PostgreSQL (`psycopg2`, `dj-database-url`), SQLite locally
**Config** — django-environ / python-decouple
**Ops** — Docker, Docker Compose, Gunicorn, WhiteNoise
**Testing** — Selenium WebDriver

## Documentation

- `MAKINGOF.md` — design decisions and how the models evolved
- `portfolio_models.dot`, `mvt.dot`, `mapa_nav.dot` — Graphviz sources for the model, MVT, and navigation diagrams

## Running it

```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Opens at `http://localhost:8000`.

### With Docker

```bash
docker compose up --build
```

### Configuration

Settings are read from the environment (`django-environ` / `python-decouple`). Provide `SECRET_KEY`, `DEBUG`, and `DATABASE_URL`; Cloudinary credentials are needed only if you enable remote media storage.

## Key takeaways

- **Schema design solves problems the view layer would otherwise hack around.** Carrying `user` *and* `session_key` on likes and ratings made anonymous participation a modelling decision rather than a pile of conditionals.
- **Typed API boundaries pay for themselves.** Declaring `In`/`Out` schemas once gives validation, serialisation, and OpenAPI documentation from a single definition.
- **A uniform error shape matters more than it looks.** One `ErrorSchema` means clients write one error path instead of one per endpoint.
- **End-to-end tests catch what unit tests structurally cannot** — template errors, URL misconfiguration, and broken auth redirects only surface when a real browser drives the app.
