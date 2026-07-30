"""API RESTful da app `tarefas` — exposta via Django Ninja Router para que
seja montada na NinjaAPI principal do projeto sob o prefixo /api/.

Esta e' a API que o(a) colega de laboratorio consome a partir do seu site
(seguindo info1.txt: ambos os colegas tem a mesma API). Todos os endpoints
estao protegidos pela chave X-API-Key — a auth e' herdada da NinjaAPI
principal (auth=AuthAPIKey() em portfolio/api.py).
"""

from typing import List

from django.db import IntegrityError
from django.shortcuts import get_object_or_404
from ninja import Router

from .models import Tarefa
from .schemas import ErrorSchema, TarefaIn, TarefaOut

router = Router(tags=["Tarefas"])


@router.get("tarefas/", response={200: List[TarefaOut]},
            description=("Lista tarefas. Filtros: titulo (icontains), "
                         "concluida, prioridade. Ordenacao via ?sort= "
                         "(titulo, -titulo, prioridade, -prioridade, "
                         "data_limite, -data_limite). Paginacao: limit/offset."))
def list_tarefas(request, titulo: str = None, concluida: bool = None,
                 prioridade: int = None, sort: str = None,
                 limit: int = 50, offset: int = 0):
    qs = Tarefa.objects.all()
    if titulo:
        qs = qs.filter(titulo__icontains=titulo)
    if concluida is not None:
        qs = qs.filter(concluida=concluida)
    if prioridade is not None:
        qs = qs.filter(prioridade=prioridade)
    if sort in ("titulo", "-titulo", "prioridade", "-prioridade",
                "data_limite", "-data_limite"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@router.post("tarefas/", response={201: TarefaOut, 400: ErrorSchema},
             description="Cria uma nova tarefa.")
def create_tarefa(request, data: TarefaIn):
    try:
        tarefa = Tarefa.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, tarefa


@router.get("tarefas/{tarefa_id}/", response={200: TarefaOut, 404: ErrorSchema},
            description="Obtem uma tarefa pelo id.")
def get_tarefa(request, tarefa_id: int):
    return 200, get_object_or_404(Tarefa, id=tarefa_id)


@router.put("tarefas/{tarefa_id}/",
            response={200: TarefaOut, 400: ErrorSchema, 404: ErrorSchema},
            description="Substitui os dados de uma tarefa.")
def update_tarefa(request, tarefa_id: int, data: TarefaIn):
    tarefa = get_object_or_404(Tarefa, id=tarefa_id)
    try:
        for attr, value in data.dict().items():
            setattr(tarefa, attr, value)
        tarefa.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, tarefa


@router.delete("tarefas/{tarefa_id}/", response={204: None, 404: ErrorSchema},
               description="Apaga uma tarefa.")
def delete_tarefa(request, tarefa_id: int):
    tarefa = get_object_or_404(Tarefa, id=tarefa_id)
    tarefa.delete()
    return 204, None
