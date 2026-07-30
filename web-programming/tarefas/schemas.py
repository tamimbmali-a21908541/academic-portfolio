"""Schemas Django Ninja para o modelo Tarefa. Mesma convencao do portfolio:
<Tarefa>In  -> payload que o cliente envia em POST/PUT
<Tarefa>Out -> payload devolvido pela API (inclui id)
ErrorSchema -> formato uniforme das mensagens de erro (campo `detail`).
"""

from datetime import date, datetime
from typing import Optional

from ninja import Schema


class ErrorSchema(Schema):
    detail: str


class TarefaIn(Schema):
    titulo: str
    descricao: str = ""
    prioridade: int = 2
    concluida: bool = False
    data_limite: Optional[date] = None


class TarefaOut(Schema):
    id: int
    titulo: str
    descricao: str
    prioridade: int
    concluida: bool
    data_limite: Optional[date] = None
    data_criacao: Optional[datetime] = None
