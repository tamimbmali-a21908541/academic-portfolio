# Making Of

## 1. Fotos do caderno

Desenhei tudo no caderno antes de começar a programar.

- DER primeira versao: `media/makingof/der_v1.jpeg`
- DER versao final: `media/makingof/der_v2.jpeg`
- DER versao 3 (Graphviz): `media/makingof/der_v3.png`
- Apontamentos dos modelos: `media/makingof/apontamentos_modelos.jpeg`
- Apontamentos das relacoes: `media/makingof/apontamentos_relacoes.jpeg`
- Erros que tive: `media/makingof/erros_correcoes.jpeg`
- Uso de IA: `media/makingof/uso_ia.jpeg`

---

## 2. Decisoes que tomei

### Licenciatura
- Pus `codigo_curso` unico porque preciso dele para ir buscar dados a API da Lusofona.
- Meti `ano_inicio` e `ano_conclusao` para saber quando comecei e quando acabo o curso.

### Unidades Curriculares
- Fiz ManyToMany com `docentes` porque uma UC tem varios professores e um professor da varias UCs.
- Criei uma entidade `Docente` em vez de por so o nome em texto, assim posso meter o link da pagina do professor.

### Projetos
- Meti `link_github` como campo proprio porque o GitHub e muito importante para mostrar em entrevistas.
- Relacao ManyToMany com `Tecnologia` porque um projeto usa varias tecnologias.

### Tecnologias
- Antes tinha `tipo` com choices. Agora `tipo` e `ForeignKey` para a entidade `TipoTecnologia` (pedida no enunciado da Ficha 6).
- 5 tipos: Frontend, Backend, Base de Dados, Storage, Outros.
- Meti `nivel_interesse` de 1 a 5 para dizer quais gosto mais.

### TFCs
- Pus `classificacao_interesse` de 1 a 5 para classificar se o TFC me interessa ou nao.
- Meti `tags` como texto separado por virgulas para ser facil procurar. Tem o meu TFC com o orientador Prof. Rui Santos.

### Competencias
- Pus `nivel` com choices (basico, intermedio, avancado, especialista) como se faz nos CVs.
- Meti `categoria` para separar competencias tecnicas das soft skills.

### Formacoes
- Pus `em_curso` como BooleanField para dizer se ainda estou a fazer a formacao.
- Ordenei por data para as mais recentes aparecerem primeiro.

### MakingOf
- Meti `tipo` com choices para separar decisoes, erros, evolucao, etc.
- Pus `entidade_relacionada` para dizer a que entidade o registo se refere.

### Interesse (entidade extra)
- Esta entidade nao esta no enunciado. Criei para poder registar as areas que me interessam tipo web, mobile, etc. Assim o portfolio fica mais completo.
- Tem ManyToMany com Tecnologia e Projeto para ligar os interesses ao resto.

---

## 3. Evolucao do modelo

### Versao 1 (comecei com 5 entidades)
- Licenciatura, UC, Tecnologia, Projeto, TFC
- 2 FK + 1 M2M
- Foto: `media/makingof/der_v1.jpeg`

### Versao 2 (10 entidades)
- Juntei: Docente, Competencia, Formacao, MakingOf, Interesse
- Tambem meti mais campos na UC que vi na API da Lusofona (descricao, objetivos, programa)
- 2 FK + 7 M2M, 3 entidades independentes
- Foto: `media/makingof/der_v2.jpeg`

### Versao 3 (Ficha 6 — 2026-04-25)
- Juntei a entidade `TipoTecnologia` (5 tipos: Frontend, Backend, Base de Dados, Storage, Outros).
- O campo `Tecnologia.tipo` deixou de ser string e passou a ser `ForeignKey`.
- Total agora: 11 entidades, 3 FK + 7 M2M.
- DER feito automaticamente com Graphviz, usando [`ULHT-PW/diagrama-entidade-relacao`](https://github.com/ULHT-PW/diagrama-entidade-relacao).
- Foto: `media/makingof/der_v3.png`

---

## 4. Erros que tive e como corrigi

| Erro | O que fiz | Entidade |
|------|-----------|----------|
| Na UC so tinha nome, codigo e ects. Quando fui buscar dados a API vi que havia mais campos | Meti descricao, objetivos e programa como TextField e mudei o script load_courses.py | UnidadeCurricular |
| Tinha o nome do docente como texto na UC | Criei entidade Docente separada com ManyToMany para poder reutilizar e meter links | Docente/UC |
| No TFC nao tinha maneira de dizer se gostava ou nao | Meti classificacao_interesse de 1 a 5 | TFC |
| No Projeto faltavam campos importantes | Meti conceitos_aplicados, video_demo, link_deploy e participantes | Projeto |
| Esqueci-me de `enctype="multipart/form-data"` no form. A imagem nao chegava ao servidor | Pus `enctype` no `<form>` e `request.FILES` na view | Projeto/Tecnologia |

---

## 5. Uso de IA

Usei o Google Gemini so para tirar duvidas rapidas de sintaxe Django.

O que fiz eu:
- Pensei nos modelos e desenhei o DER no caderno
- Escrevi o models.py, admin.py e os scripts todos
- Meti os dados dos meus projetos reais
- Fiz esta documentacao e os diagramas

O que perguntei a IA:
- Como usar validators e choices no Django
- Diferenca entre TextField e CharField
- Como configurar o MEDIA_ROOT
