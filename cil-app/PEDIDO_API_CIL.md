# Pedido de Acesso à API - Aplicação Móvel CIL

## Introdução

Estamos a desenvolver uma aplicação móvel oficial para a **Comunidade Islâmica de Lisboa (CIL)**.

**Programador:** Tamim Mohamed Ali
**Tecnologia:** Flutter/Dart

---

## O Que Já Sabemos (Análise do Website)

Através da análise do website, já conseguimos identificar:

### Informações Técnicas
| Item | Valor |
|------|-------|
| **Plataforma** | Wix |
| **URL do Site** | https://www.comunidadeislamica.pt |
| **ID do Site (Wix)** | f6dd4b75-923b-46a3-95da-9bf7e9b0295b |
| **Email de Contacto** | secretaria@cil.org.pt |
| **Sistema de Pagamento** | PayPal |

### Aplicações Wix Instaladas
- **Wix Blog** - Para notícias (já funciona via RSS)
- **Wix Events** - Para eventos
- **Wix Forms** - Para formulários
- **Wix Members** - Para área de membros

### Páginas do Website
| Página | URL |
|--------|-----|
| Início | /home |
| Notícias | /noticias |
| Eventos | /events-1 |
| Contactos | /contactos |
| Donativos | /donate |
| Adesão | /associado |
| Casamento | /marcação-de-casamento |
| Ação Social | /acao-social |
| Reserva de Salão | /reserva-de-salão |
| Pavilhão Desportivo | /pavilhao-desportivo |
| Sobre o Islão | /sobre-o-islão |

### Redes Sociais
- **Facebook:** facebook.com/comunidadeislamica.pt
- **Instagram:** instagram.com/comunidadeislamica.pt
- **YouTube:** youtube.com/mesquitacentraldelisboa

### Feed RSS (Já Funciona!)
- **URL:** https://www.comunidadeislamica.pt/blog-feed.xml
- **Estado:** A aplicação já consegue mostrar as notícias através deste feed

---

## O Que Ainda Precisamos

Para a aplicação funcionar completamente com dados do website, precisamos de **acesso à API do Wix**. Isto requer:

### 1. Chave de API do Wix (API Key)

Para gerar uma chave de API:
1. Aceder ao painel de administração do Wix
2. Ir a **Settings > Advanced > API Keys**
3. Criar uma nova API Key com as seguintes permissões:
   - `Wix Events` - Para ler eventos
   - `Wix Forms` - Para submeter formulários
   - `Wix Members` - Para autenticação de utilizadores
   - `Wix Blog` - Para ler artigos (opcional, já temos RSS)

### 2. Account ID e Site ID

Estes IDs são necessários para fazer pedidos à API:
- **Account ID:** Disponível em Settings > Account Settings
- **Site ID:** f6dd4b75-923b-46a3-95da-9bf7e9b0295b (já temos)

### 3. OAuth App (Para Login de Membros)

Se quiserem que os membros possam fazer login na app:
1. Aceder a **Settings > Headless Settings**
2. Criar um novo **OAuth App**
3. Fornecer o **Client ID** e **Client Secret**

---

## Perguntas Simples

Se preferirem, podem simplesmente responder:

### Acesso Administrativo
- [ ] Podem criar uma API Key no painel Wix?
- [ ] Podem partilhar o Account ID?
- [ ] Querem que os membros façam login na app?

### Sistema de Eventos
- [ ] Os eventos são geridos pelo Wix Events?
- [ ] Querem que os utilizadores se inscrevam nos eventos pela app?

### Donativos
- [ ] Usam PayPal para donativos? (parece que sim)
- [ ] Têm outro sistema de pagamento (MB Way, Multibanco)?

### Formulários
- [ ] Os formulários de Adesão/Casamento/Contacto são do Wix Forms?
- [ ] Onde são guardados os dados submetidos?

---

## Alternativas Se Não For Possível

Se não conseguirem dar acesso à API do Wix, podemos:

### Opção A: WebView (Solução Actual)
A aplicação abre as páginas do website directamente. Os utilizadores vêem o website dentro da app.
- **Vantagem:** Funciona imediatamente
- **Desvantagem:** Não é uma experiência nativa

### Opção B: Backend Separado (Firebase)
Criamos uma base de dados separada só para a aplicação.
- **Vantagem:** Funciona completamente
- **Desvantagem:** Os dados NÃO ficam sincronizados com o website

### Opção C: API Pública do Wix
Se tiverem um plano Wix Premium, podem ter acesso à API.
- **Vantagem:** Dados sincronizados com o website
- **Desvantagem:** Requer plano pago e configuração

---

## Próximos Passos

1. **Responsável técnico da CIL** acede ao painel Wix
2. Gera uma **API Key** com as permissões necessárias
3. Envia os dados para: [contacto do programador]
4. Nós integramos a API na aplicação

---

## Estado Actual da Aplicação

| Funcionalidade | Estado | Notas |
|----------------|--------|-------|
| Horários de Oração | Funciona | Usa API Aladhan |
| Notícias | Funciona | Usa RSS Feed do website |
| Eventos | WebView | Precisa de API |
| Donativos | WebView | Precisa de API |
| Adesão | WebView | Precisa de API |
| Casamento | WebView | Precisa de API |
| Contactos | WebView | Precisa de API |
| Login de Membros | Não implementado | Precisa de OAuth |

---

## Contacto

**Programador:** Tamim Mohamed Ali
**Projecto:** Aplicação Móvel CIL
**Tecnologia:** Flutter/Dart

---

*Documento gerado automaticamente - Projecto CIL App*
