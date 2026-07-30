# api.py
# Aqui definimos e organizamos a logica da API RESTful com Django Ninja.
# Criamos a instancia `api` para configurar a API, definir rotas e gerir
# pedidos HTTP. Para CADA tabela do portfolio existem os 5 endpoints CRUD:
#   GET    <recurso>/            -> listar  (com filtros + paginacao)
#   POST   <recurso>/            -> criar
#   GET    <recurso>/{id}/       -> obter um
#   PUT    <recurso>/{id}/       -> substituir
#   DELETE <recurso>/{id}/       -> apagar
#
# Documentacao automatica (Swagger / OpenAPI) disponivel em /api/docs.

from typing import List

from django.db import IntegrityError, transaction
from django.shortcuts import get_object_or_404
from ninja import NinjaAPI
from ninja.security import APIKeyHeader

from .models import (
    APIKey,
    Competencia,
    Docente,
    Formacao,
    Interesse,
    Licenciatura,
    MakingOf,
    Projeto,
    TFC,
    Tecnologia,
    TipoTecnologia,
    UnidadeCurricular,
)
from .schemas import (
    CompetenciaIn,
    CompetenciaOut,
    DocenteIn,
    DocenteOut,
    ErrorSchema,
    FormacaoIn,
    FormacaoOut,
    InteresseIn,
    InteresseOut,
    LicenciaturaIn,
    LicenciaturaOut,
    MakingOfIn,
    MakingOfOut,
    ProjetoIn,
    ProjetoOut,
    TFCIn,
    TFCOut,
    TecnologiaIn,
    TecnologiaOut,
    TipoTecnologiaIn,
    TipoTecnologiaOut,
    UnidadeCurricularIn,
    UnidadeCurricularOut,
)

# Autenticacao por API Key no cabecalho HTTP "X-API-Key" (ver info.txt /
# Parte 1.2 Opcao 2). Validacao centralizada na classe AuthAPIKey, que
# devolve o nome do dono da chave em request.auth ou None -> 401.
class AuthAPIKey(APIKeyHeader):
    param_name = "X-API-Key"

    def authenticate(self, request, key):
        try:
            api_key = APIKey.objects.get(key=key)
            if api_key.is_valid():
                return api_key.name
        except APIKey.DoesNotExist:
            pass
        return None


# Criacao da instancia da API e sua configuracao (com mais detalhes).
# auth=AuthAPIKey() aplica a autenticacao a TODOS os endpoints (Opcao 2),
# incluindo os endpoints do router `tarefas` montado a seguir.
api = NinjaAPI(
    title="API RESTful Portfolio",
    description=(
        "API para gerir as entidades do portfolio (licenciaturas, unidades "
        "curriculares, tecnologias, projetos, etc.) com operacoes CRUD "
        "completas sobre os dados. Inclui filtros, ordenacao e paginacao. "
        "Todos os endpoints exigem o cabecalho X-API-Key."
    ),
    version="1.0.0",
    auth=AuthAPIKey(),
)

# Monta o router da app `tarefas` (ficha 13 / info1.txt): a API partilhada
# com o(a) colega vive numa app dedicada — registado aqui para que os seus
# endpoints aparecam tambem em /api/ e herdem a mesma autenticacao X-API-Key.
from tarefas.api import router as tarefas_router  # noqa: E402  (depende de `api` acima)
api.add_router("", tarefas_router)


# ===========================================================================
# 1. Licenciatura
# ===========================================================================
@api.get("licenciaturas/", response={200: List[LicenciaturaOut]}, tags=["Licenciaturas"],
         description="Lista licenciaturas. Filtros: nome, grau, instituicao. Ordenacao: sort. Paginacao: limit, offset.")
def list_licenciaturas(request, nome: str = None, grau: str = None, instituicao: str = None,
                       sort: str = None, limit: int = 50, offset: int = 0):
    qs = Licenciatura.objects.prefetch_related("ucs").all()
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if grau:
        qs = qs.filter(grau__icontains=grau)
    if instituicao:
        qs = qs.filter(instituicao__icontains=instituicao)
    if sort in ("nome", "-nome", "codigo_curso", "-codigo_curso"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("licenciaturas/", response={201: LicenciaturaOut, 400: ErrorSchema}, tags=["Licenciaturas"],
          description="Cria uma nova licenciatura.")
def create_licenciatura(request, data: LicenciaturaIn):
    try:
        licenciatura = Licenciatura.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, licenciatura


@api.get("licenciaturas/{licenciatura_id}/", response={200: LicenciaturaOut, 404: ErrorSchema},
         tags=["Licenciaturas"], description="Obtem uma licenciatura pelo id.")
def get_licenciatura(request, licenciatura_id: int):
    qs = Licenciatura.objects.prefetch_related("ucs")
    return 200, get_object_or_404(qs, id=licenciatura_id)


@api.put("licenciaturas/{licenciatura_id}/", response={200: LicenciaturaOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Licenciaturas"], description="Substitui os dados de uma licenciatura.")
def update_licenciatura(request, licenciatura_id: int, data: LicenciaturaIn):
    licenciatura = get_object_or_404(Licenciatura, id=licenciatura_id)
    try:
        for attr, value in data.dict().items():
            setattr(licenciatura, attr, value)
        licenciatura.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, licenciatura


@api.delete("licenciaturas/{licenciatura_id}/", response={204: None, 404: ErrorSchema},
            tags=["Licenciaturas"], description="Apaga uma licenciatura.")
def delete_licenciatura(request, licenciatura_id: int):
    licenciatura = get_object_or_404(Licenciatura, id=licenciatura_id)
    licenciatura.delete()
    return 204, None


# ===========================================================================
# 2. Docente
# ===========================================================================
@api.get("docentes/", response={200: List[DocenteOut]}, tags=["Docentes"],
         description="Lista docentes. Filtros: nome. Ordenacao: sort. Paginacao: limit, offset.")
def list_docentes(request, nome: str = None, sort: str = None, limit: int = 50, offset: int = 0):
    qs = Docente.objects.prefetch_related("ucs").all()
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if sort in ("nome", "-nome"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("docentes/", response={201: DocenteOut, 400: ErrorSchema}, tags=["Docentes"],
          description="Cria um novo docente.")
def create_docente(request, data: DocenteIn):
    try:
        docente = Docente.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, docente


@api.get("docentes/{docente_id}/", response={200: DocenteOut, 404: ErrorSchema}, tags=["Docentes"],
         description="Obtem um docente pelo id.")
def get_docente(request, docente_id: int):
    qs = Docente.objects.prefetch_related("ucs")
    return 200, get_object_or_404(qs, id=docente_id)


@api.put("docentes/{docente_id}/", response={200: DocenteOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Docentes"], description="Substitui os dados de um docente.")
def update_docente(request, docente_id: int, data: DocenteIn):
    docente = get_object_or_404(Docente, id=docente_id)
    try:
        for attr, value in data.dict().items():
            setattr(docente, attr, value)
        docente.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, docente


@api.delete("docentes/{docente_id}/", response={204: None, 404: ErrorSchema}, tags=["Docentes"],
            description="Apaga um docente.")
def delete_docente(request, docente_id: int):
    docente = get_object_or_404(Docente, id=docente_id)
    docente.delete()
    return 204, None


# ===========================================================================
# 3. UnidadeCurricular  (FK -> Licenciatura ; N:N -> Docentes)
# ===========================================================================
@api.get("ucs/", response={200: List[UnidadeCurricularOut]}, tags=["Unidades Curriculares"],
         description="Lista UCs. Filtros: nome, ano_curricular, semestre, licenciatura_id. Ordenacao: sort. Paginacao: limit, offset.")
def list_ucs(request, nome: str = None, ano_curricular: int = None, semestre: int = None,
             licenciatura_id: int = None, sort: str = None, limit: int = 50, offset: int = 0):
    qs = (UnidadeCurricular.objects
          .select_related("licenciatura")
          .prefetch_related("docentes", "tecnologias", "projetos").all())
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if ano_curricular is not None:
        qs = qs.filter(ano_curricular=ano_curricular)
    if semestre is not None:
        qs = qs.filter(semestre=semestre)
    if licenciatura_id is not None:
        qs = qs.filter(licenciatura_id=licenciatura_id)
    if sort in ("nome", "-nome", "ano_curricular", "-ano_curricular", "ects", "-ects"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("ucs/", response={201: UnidadeCurricularOut, 400: ErrorSchema}, tags=["Unidades Curriculares"],
          description="Cria uma nova unidade curricular.")
def create_uc(request, data: UnidadeCurricularIn):
    payload = data.dict()
    docentes = payload.pop("docentes", [])
    try:
        with transaction.atomic():
            uc = UnidadeCurricular.objects.create(**payload)
            uc.docentes.set(docentes)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, uc


@api.get("ucs/{uc_id}/", response={200: UnidadeCurricularOut, 404: ErrorSchema},
         tags=["Unidades Curriculares"], description="Obtem uma unidade curricular pelo id.")
def get_uc(request, uc_id: int):
    qs = (UnidadeCurricular.objects
          .select_related("licenciatura")
          .prefetch_related("docentes", "tecnologias", "projetos"))
    return 200, get_object_or_404(qs, id=uc_id)


@api.put("ucs/{uc_id}/", response={200: UnidadeCurricularOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Unidades Curriculares"], description="Substitui os dados de uma unidade curricular.")
def update_uc(request, uc_id: int, data: UnidadeCurricularIn):
    uc = get_object_or_404(UnidadeCurricular, id=uc_id)
    payload = data.dict()
    docentes = payload.pop("docentes", None)
    try:
        with transaction.atomic():
            for attr, value in payload.items():
                setattr(uc, attr, value)
            uc.save()
            if docentes is not None:
                uc.docentes.set(docentes)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, uc


@api.delete("ucs/{uc_id}/", response={204: None, 404: ErrorSchema}, tags=["Unidades Curriculares"],
            description="Apaga uma unidade curricular.")
def delete_uc(request, uc_id: int):
    uc = get_object_or_404(UnidadeCurricular, id=uc_id)
    uc.delete()
    return 204, None


# ===========================================================================
# 4. TipoTecnologia  (1:N -> Tecnologias)
# ===========================================================================
@api.get("tipos-tecnologia/", response={200: List[TipoTecnologiaOut]}, tags=["Tipos de Tecnologia"],
         description="Lista tipos de tecnologia. Filtros: nome. Ordenacao: sort. Paginacao: limit, offset.")
def list_tipos_tecnologia(request, nome: str = None, sort: str = None, limit: int = 50, offset: int = 0):
    qs = TipoTecnologia.objects.prefetch_related("tecnologias").all()
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if sort in ("nome", "-nome", "ordem", "-ordem"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("tipos-tecnologia/", response={201: TipoTecnologiaOut, 400: ErrorSchema}, tags=["Tipos de Tecnologia"],
          description="Cria um novo tipo de tecnologia.")
def create_tipo_tecnologia(request, data: TipoTecnologiaIn):
    try:
        tipo = TipoTecnologia.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, tipo


@api.get("tipos-tecnologia/{tipo_id}/", response={200: TipoTecnologiaOut, 404: ErrorSchema},
         tags=["Tipos de Tecnologia"], description="Obtem um tipo de tecnologia pelo id.")
def get_tipo_tecnologia(request, tipo_id: int):
    qs = TipoTecnologia.objects.prefetch_related("tecnologias")
    return 200, get_object_or_404(qs, id=tipo_id)


@api.put("tipos-tecnologia/{tipo_id}/", response={200: TipoTecnologiaOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Tipos de Tecnologia"], description="Substitui os dados de um tipo de tecnologia.")
def update_tipo_tecnologia(request, tipo_id: int, data: TipoTecnologiaIn):
    tipo = get_object_or_404(TipoTecnologia, id=tipo_id)
    try:
        for attr, value in data.dict().items():
            setattr(tipo, attr, value)
        tipo.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, tipo


@api.delete("tipos-tecnologia/{tipo_id}/", response={204: None, 404: ErrorSchema}, tags=["Tipos de Tecnologia"],
            description="Apaga um tipo de tecnologia.")
def delete_tipo_tecnologia(request, tipo_id: int):
    tipo = get_object_or_404(TipoTecnologia, id=tipo_id)
    tipo.delete()
    return 204, None


# ===========================================================================
# 5. Tecnologia  (FK -> TipoTecnologia ; N:N -> UCs)
# ===========================================================================
@api.get("tecnologias/", response={200: List[TecnologiaOut]}, tags=["Tecnologias"],
         description="Lista tecnologias. Filtros: nome, tipo_id, nivel_interesse. Ordenacao: sort. Paginacao: limit, offset.")
def list_tecnologias(request, nome: str = None, tipo_id: int = None, nivel_interesse: int = None,
                     sort: str = None, limit: int = 50, offset: int = 0):
    qs = Tecnologia.objects.select_related("tipo").prefetch_related("ucs", "projetos").all()
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if tipo_id is not None:
        qs = qs.filter(tipo_id=tipo_id)
    if nivel_interesse is not None:
        qs = qs.filter(nivel_interesse=nivel_interesse)
    if sort in ("nome", "-nome", "nivel_interesse", "-nivel_interesse"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("tecnologias/", response={201: TecnologiaOut, 400: ErrorSchema}, tags=["Tecnologias"],
          description="Cria uma nova tecnologia.")
def create_tecnologia(request, data: TecnologiaIn):
    payload = data.dict()
    ucs = payload.pop("ucs", [])
    try:
        with transaction.atomic():
            tec = Tecnologia.objects.create(**payload)
            tec.ucs.set(ucs)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, tec


@api.get("tecnologias/{tecnologia_id}/", response={200: TecnologiaOut, 404: ErrorSchema},
         tags=["Tecnologias"], description="Obtem uma tecnologia pelo id.")
def get_tecnologia(request, tecnologia_id: int):
    qs = Tecnologia.objects.select_related("tipo").prefetch_related("ucs", "projetos")
    return 200, get_object_or_404(qs, id=tecnologia_id)


@api.put("tecnologias/{tecnologia_id}/", response={200: TecnologiaOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Tecnologias"], description="Substitui os dados de uma tecnologia.")
def update_tecnologia(request, tecnologia_id: int, data: TecnologiaIn):
    tec = get_object_or_404(Tecnologia, id=tecnologia_id)
    payload = data.dict()
    ucs = payload.pop("ucs", None)
    try:
        with transaction.atomic():
            for attr, value in payload.items():
                setattr(tec, attr, value)
            tec.save()
            if ucs is not None:
                tec.ucs.set(ucs)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, tec


@api.delete("tecnologias/{tecnologia_id}/", response={204: None, 404: ErrorSchema}, tags=["Tecnologias"],
            description="Apaga uma tecnologia.")
def delete_tecnologia(request, tecnologia_id: int):
    tec = get_object_or_404(Tecnologia, id=tecnologia_id)
    tec.delete()
    return 204, None


# ===========================================================================
# 6. Projeto  (FK -> UnidadeCurricular ; N:N -> Tecnologias)
# ===========================================================================
@api.get("projetos/", response={200: List[ProjetoOut]}, tags=["Projetos"],
         description="Lista projetos. Filtros: titulo, uc_id. Ordenacao: sort. Paginacao: limit, offset.")
def list_projetos(request, titulo: str = None, uc_id: int = None, sort: str = None,
                  limit: int = 50, offset: int = 0):
    qs = Projeto.objects.select_related("uc").prefetch_related("tecnologias").all()
    if titulo:
        qs = qs.filter(titulo__icontains=titulo)
    if uc_id is not None:
        qs = qs.filter(uc_id=uc_id)
    if sort in ("titulo", "-titulo", "data_fim", "-data_fim", "nota", "-nota"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("projetos/", response={201: ProjetoOut, 400: ErrorSchema}, tags=["Projetos"],
          description="Cria um novo projeto.")
def create_projeto(request, data: ProjetoIn):
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", [])
    try:
        with transaction.atomic():
            projeto = Projeto.objects.create(**payload)
            projeto.tecnologias.set(tecnologias)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, projeto


@api.get("projetos/{projeto_id}/", response={200: ProjetoOut, 404: ErrorSchema}, tags=["Projetos"],
         description="Obtem um projeto pelo id.")
def get_projeto(request, projeto_id: int):
    qs = Projeto.objects.select_related("uc").prefetch_related("tecnologias")
    return 200, get_object_or_404(qs, id=projeto_id)


@api.put("projetos/{projeto_id}/", response={200: ProjetoOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Projetos"], description="Substitui os dados de um projeto.")
def update_projeto(request, projeto_id: int, data: ProjetoIn):
    projeto = get_object_or_404(Projeto, id=projeto_id)
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", None)
    try:
        with transaction.atomic():
            for attr, value in payload.items():
                setattr(projeto, attr, value)
            projeto.save()
            if tecnologias is not None:
                projeto.tecnologias.set(tecnologias)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, projeto


@api.delete("projetos/{projeto_id}/", response={204: None, 404: ErrorSchema}, tags=["Projetos"],
            description="Apaga um projeto.")
def delete_projeto(request, projeto_id: int):
    projeto = get_object_or_404(Projeto, id=projeto_id)
    projeto.delete()
    return 204, None


# ===========================================================================
# 7. TFC
# ===========================================================================
@api.get("tfcs/", response={200: List[TFCOut]}, tags=["TFCs"],
         description="Lista TFCs. Filtros: titulo, ano, orientador. Ordenacao: sort. Paginacao: limit, offset.")
def list_tfcs(request, titulo: str = None, ano: int = None, orientador: str = None,
              sort: str = None, limit: int = 50, offset: int = 0):
    qs = TFC.objects.all()
    if titulo:
        qs = qs.filter(titulo__icontains=titulo)
    if ano is not None:
        qs = qs.filter(ano=ano)
    if orientador:
        qs = qs.filter(orientador__icontains=orientador)
    if sort in ("titulo", "-titulo", "ano", "-ano", "classificacao_interesse", "-classificacao_interesse"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("tfcs/", response={201: TFCOut, 400: ErrorSchema}, tags=["TFCs"],
          description="Cria um novo TFC.")
def create_tfc(request, data: TFCIn):
    try:
        tfc = TFC.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, tfc


@api.get("tfcs/{tfc_id}/", response={200: TFCOut, 404: ErrorSchema}, tags=["TFCs"],
         description="Obtem um TFC pelo id.")
def get_tfc(request, tfc_id: int):
    return 200, get_object_or_404(TFC, id=tfc_id)


@api.put("tfcs/{tfc_id}/", response={200: TFCOut, 400: ErrorSchema, 404: ErrorSchema}, tags=["TFCs"],
         description="Substitui os dados de um TFC.")
def update_tfc(request, tfc_id: int, data: TFCIn):
    tfc = get_object_or_404(TFC, id=tfc_id)
    try:
        for attr, value in data.dict().items():
            setattr(tfc, attr, value)
        tfc.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, tfc


@api.delete("tfcs/{tfc_id}/", response={204: None, 404: ErrorSchema}, tags=["TFCs"],
            description="Apaga um TFC.")
def delete_tfc(request, tfc_id: int):
    tfc = get_object_or_404(TFC, id=tfc_id)
    tfc.delete()
    return 204, None


# ===========================================================================
# 8. Competencia  (N:N -> Tecnologias, Projetos)
# ===========================================================================
@api.get("competencias/", response={200: List[CompetenciaOut]}, tags=["Competencias"],
         description="Lista competencias. Filtros: nome, nivel, categoria. Ordenacao: sort. Paginacao: limit, offset.")
def list_competencias(request, nome: str = None, nivel: str = None, categoria: str = None,
                      sort: str = None, limit: int = 50, offset: int = 0):
    qs = Competencia.objects.prefetch_related("tecnologias", "projetos").all()
    if nome:
        qs = qs.filter(nome__icontains=nome)
    if nivel:
        qs = qs.filter(nivel=nivel)
    if categoria:
        qs = qs.filter(categoria=categoria)
    if sort in ("nome", "-nome", "nivel", "-nivel"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("competencias/", response={201: CompetenciaOut, 400: ErrorSchema}, tags=["Competencias"],
          description="Cria uma nova competencia.")
def create_competencia(request, data: CompetenciaIn):
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", [])
    projetos = payload.pop("projetos", [])
    try:
        with transaction.atomic():
            comp = Competencia.objects.create(**payload)
            comp.tecnologias.set(tecnologias)
            comp.projetos.set(projetos)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, comp


@api.get("competencias/{competencia_id}/", response={200: CompetenciaOut, 404: ErrorSchema},
         tags=["Competencias"], description="Obtem uma competencia pelo id.")
def get_competencia(request, competencia_id: int):
    qs = Competencia.objects.prefetch_related("tecnologias", "projetos")
    return 200, get_object_or_404(qs, id=competencia_id)


@api.put("competencias/{competencia_id}/", response={200: CompetenciaOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Competencias"], description="Substitui os dados de uma competencia.")
def update_competencia(request, competencia_id: int, data: CompetenciaIn):
    comp = get_object_or_404(Competencia, id=competencia_id)
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", None)
    projetos = payload.pop("projetos", None)
    try:
        with transaction.atomic():
            for attr, value in payload.items():
                setattr(comp, attr, value)
            comp.save()
            if tecnologias is not None:
                comp.tecnologias.set(tecnologias)
            if projetos is not None:
                comp.projetos.set(projetos)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, comp


@api.delete("competencias/{competencia_id}/", response={204: None, 404: ErrorSchema}, tags=["Competencias"],
            description="Apaga uma competencia.")
def delete_competencia(request, competencia_id: int):
    comp = get_object_or_404(Competencia, id=competencia_id)
    comp.delete()
    return 204, None


# ===========================================================================
# 9. Formacao
# ===========================================================================
@api.get("formacoes/", response={200: List[FormacaoOut]}, tags=["Formacoes"],
         description="Lista formacoes. Filtros: titulo, tipo, em_curso. Ordenacao: sort. Paginacao: limit, offset.")
def list_formacoes(request, titulo: str = None, tipo: str = None, em_curso: bool = None,
                   sort: str = None, limit: int = 50, offset: int = 0):
    qs = Formacao.objects.all()
    if titulo:
        qs = qs.filter(titulo__icontains=titulo)
    if tipo:
        qs = qs.filter(tipo=tipo)
    if em_curso is not None:
        qs = qs.filter(em_curso=em_curso)
    if sort in ("titulo", "-titulo", "data_inicio", "-data_inicio"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("formacoes/", response={201: FormacaoOut, 400: ErrorSchema}, tags=["Formacoes"],
          description="Cria uma nova formacao.")
def create_formacao(request, data: FormacaoIn):
    try:
        formacao = Formacao.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, formacao


@api.get("formacoes/{formacao_id}/", response={200: FormacaoOut, 404: ErrorSchema}, tags=["Formacoes"],
         description="Obtem uma formacao pelo id.")
def get_formacao(request, formacao_id: int):
    return 200, get_object_or_404(Formacao, id=formacao_id)


@api.put("formacoes/{formacao_id}/", response={200: FormacaoOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Formacoes"], description="Substitui os dados de uma formacao.")
def update_formacao(request, formacao_id: int, data: FormacaoIn):
    formacao = get_object_or_404(Formacao, id=formacao_id)
    try:
        for attr, value in data.dict().items():
            setattr(formacao, attr, value)
        formacao.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, formacao


@api.delete("formacoes/{formacao_id}/", response={204: None, 404: ErrorSchema}, tags=["Formacoes"],
            description="Apaga uma formacao.")
def delete_formacao(request, formacao_id: int):
    formacao = get_object_or_404(Formacao, id=formacao_id)
    formacao.delete()
    return 204, None


# ===========================================================================
# 10. Interesse  (N:N -> Tecnologias, Projetos)
# ===========================================================================
@api.get("interesses/", response={200: List[InteresseOut]}, tags=["Interesses"],
         description="Lista interesses. Filtros: area, nivel_interesse. Ordenacao: sort. Paginacao: limit, offset.")
def list_interesses(request, area: str = None, nivel_interesse: int = None, sort: str = None,
                    limit: int = 50, offset: int = 0):
    qs = Interesse.objects.prefetch_related("tecnologias", "projetos").all()
    if area:
        qs = qs.filter(area=area)
    if nivel_interesse is not None:
        qs = qs.filter(nivel_interesse=nivel_interesse)
    if sort in ("nivel_interesse", "-nivel_interesse", "area", "-area"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("interesses/", response={201: InteresseOut, 400: ErrorSchema}, tags=["Interesses"],
          description="Cria um novo interesse.")
def create_interesse(request, data: InteresseIn):
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", [])
    projetos = payload.pop("projetos", [])
    try:
        with transaction.atomic():
            interesse = Interesse.objects.create(**payload)
            interesse.tecnologias.set(tecnologias)
            interesse.projetos.set(projetos)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, interesse


@api.get("interesses/{interesse_id}/", response={200: InteresseOut, 404: ErrorSchema}, tags=["Interesses"],
         description="Obtem um interesse pelo id.")
def get_interesse(request, interesse_id: int):
    qs = Interesse.objects.prefetch_related("tecnologias", "projetos")
    return 200, get_object_or_404(qs, id=interesse_id)


@api.put("interesses/{interesse_id}/", response={200: InteresseOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Interesses"], description="Substitui os dados de um interesse.")
def update_interesse(request, interesse_id: int, data: InteresseIn):
    interesse = get_object_or_404(Interesse, id=interesse_id)
    payload = data.dict()
    tecnologias = payload.pop("tecnologias", None)
    projetos = payload.pop("projetos", None)
    try:
        with transaction.atomic():
            for attr, value in payload.items():
                setattr(interesse, attr, value)
            interesse.save()
            if tecnologias is not None:
                interesse.tecnologias.set(tecnologias)
            if projetos is not None:
                interesse.projetos.set(projetos)
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, interesse


@api.delete("interesses/{interesse_id}/", response={204: None, 404: ErrorSchema}, tags=["Interesses"],
            description="Apaga um interesse.")
def delete_interesse(request, interesse_id: int):
    interesse = get_object_or_404(Interesse, id=interesse_id)
    interesse.delete()
    return 204, None


# ===========================================================================
# 11. MakingOf
# ===========================================================================
@api.get("makingof/", response={200: List[MakingOfOut]}, tags=["Making Of"],
         description="Lista registos de making of. Filtros: titulo, tipo, entidade_relacionada. Ordenacao: sort. Paginacao: limit, offset.")
def list_makingof(request, titulo: str = None, tipo: str = None, entidade_relacionada: str = None,
                  sort: str = None, limit: int = 50, offset: int = 0):
    qs = MakingOf.objects.all()
    if titulo:
        qs = qs.filter(titulo__icontains=titulo)
    if tipo:
        qs = qs.filter(tipo=tipo)
    if entidade_relacionada:
        qs = qs.filter(entidade_relacionada__icontains=entidade_relacionada)
    if sort in ("data_registo", "-data_registo", "titulo", "-titulo"):
        qs = qs.order_by(sort)
    return 200, qs[offset:offset + limit]


@api.post("makingof/", response={201: MakingOfOut, 400: ErrorSchema}, tags=["Making Of"],
          description="Cria um novo registo de making of.")
def create_makingof(request, data: MakingOfIn):
    try:
        registo = MakingOf.objects.create(**data.dict())
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 201, registo


@api.get("makingof/{makingof_id}/", response={200: MakingOfOut, 404: ErrorSchema}, tags=["Making Of"],
         description="Obtem um registo de making of pelo id.")
def get_makingof(request, makingof_id: int):
    return 200, get_object_or_404(MakingOf, id=makingof_id)


@api.put("makingof/{makingof_id}/", response={200: MakingOfOut, 400: ErrorSchema, 404: ErrorSchema},
         tags=["Making Of"], description="Substitui os dados de um registo de making of.")
def update_makingof(request, makingof_id: int, data: MakingOfIn):
    registo = get_object_or_404(MakingOf, id=makingof_id)
    try:
        for attr, value in data.dict().items():
            setattr(registo, attr, value)
        registo.save()
    except IntegrityError as exc:
        return 400, {"detail": f"Dados invalidos: {exc}"}
    return 200, registo


@api.delete("makingof/{makingof_id}/", response={204: None, 404: ErrorSchema}, tags=["Making Of"],
            description="Apaga um registo de making of.")
def delete_makingof(request, makingof_id: int):
    registo = get_object_or_404(MakingOf, id=makingof_id)
    registo.delete()
    return 204, None
