# Plano de Newsletters — Global Real

## Visão Geral

3 newsletters independentes, cada uma com público e frequência próprios.
Publicadas simultaneamente em: **LinkedIn Newsletter** + **Substack** + **Email**.

---

## Canais de Distribuição

| Canal | Como configurar |
|---|---|
| **LinkedIn Newsletter** | Na page da Global Real Estate → "Escrever artigo" → Criar Newsletter (uma pra cada tema) |
| **Substack** | Criar conta em substack.com → 3 publicações separadas (ou 1 com 3 seções/tags) |
| **Email** | Usar o Substack como plataforma de envio (já tem email embutido) ou integrar com Mailchimp/Resend |

> **Dica**: O Substack já envia por email automaticamente pra quem se inscreve. Então Substack + Email ficam resolvidos num lugar só. O LinkedIn Newsletter é uma cópia manual (cola o conteúdo lá).

---

## Newsletter 1: Global Real Tech 🛠️
**Público**: Desenvolvedores, CTOs, comunidade PropTech
**Frequência**: Quinzenal (2x por mês)
**Tom**: Técnico, direto, com código e diagramas

### Edição #1 — "Como construímos uma plataforma imobiliária com IA do zero"

**Assunto do email**: 🛠️ Flutter + Supabase + Claude AI: a stack por trás do Global Real

```
# Global Real Tech #1
## Como construímos uma plataforma imobiliária com IA do zero

Fala, pessoal! Essa é a primeira edição da Global Real Tech,
onde vou compartilhar os bastidores técnicos da construção
do Global Real — uma plataforma de investimentos imobiliários
com IA integrada.

### A Stack

Quando começamos, a decisão mais importante foi: como entregar
Android, iOS e Web com um time enxuto?

A resposta: Flutter.

Um codebase, três plataformas. Mas Flutter sozinho não resolve
tudo. Aqui está o que usamos:

• **Flutter (Dart)** — Frontend multiplataforma
• **Supabase** — Backend (PostgreSQL + Auth + Realtime + Edge Functions)
• **Anthropic Claude** — IA para qualificação de leads
• **Stripe** — Pagamentos e assinaturas
• **Vercel** — Deploy web

### Por que Supabase e não Firebase?

Três motivos:
1. PostgreSQL nativo — queries complexas, views, triggers, RLS
2. Edge Functions em Deno — serverless sem vendor lock-in
3. Realtime nativo — chat em tempo real sem configuração extra

### A IA que qualifica leads

Quando um lead entra no sistema, um trigger no PostgreSQL
dispara uma Edge Function que:

1. Busca os dados do lead
2. Busca o catálogo de investimentos
3. Busca o histórico de interações
4. Envia tudo pro Claude (Anthropic API)
5. Recebe: score, resumo, mensagem sugerida e recomendações
6. Atualiza o lead e insere a mensagem no chat

Tudo automático. Zero intervenção humana.

O score final é híbrido: até 50 pontos da IA + até 50 pontos
de comportamento real do usuário (17 tipos de evento rastreados).

### Próxima edição

Vou detalhar como implementamos o Lead Scoring contínuo
com triggers no PostgreSQL e como o sistema de roles
(Master/Advisor) funciona com RLS.

Até a próxima! 🚀

---
Global Real Tech — Bastidores técnicos do Global Real
```

### Edição #2 — "Lead Scoring com PostgreSQL Triggers + IA"

**Assunto do email**: 🧠 Como combinamos IA + comportamento real num score de 0 a 100

```
# Global Real Tech #2
## Lead Scoring com PostgreSQL Triggers + IA

Na edição passada, mostrei a stack geral. Hoje vou mergulhar
no sistema de Lead Scoring — um dos módulos mais interessantes.

### O problema

Nem todo lead é igual. Um lead que só se cadastrou é diferente
de um que já usou a calculadora, favoritou empreendimentos
e clicou no WhatsApp do assessor.

### A solução: Score Híbrido

Combinamos duas fontes:

**Score IA (até 50 pontos)**
→ Claude analisa perfil, interesse, budget e histórico
→ Retorna um score de 0-100 que dividimos por 2

**Score de Interações (até 50 pontos)**
→ 17 tipos de evento rastreados
→ Cada evento tem pontuação configurável (tabela scoring_rules)
→ Trigger recalcula automaticamente a cada nova interação

### Como funciona no banco

Tabela `lead_interactions`:
- lead_id, event_type, points, event_data, created_at

Tabela `scoring_rules`:
- event_type, points, description

Function `recalculate_lead_score`:
- Soma pontos das interações (cap 50)
- Soma com score IA (cap 50)
- Atualiza ai_score na tabela market_leads

Trigger: dispara a cada INSERT em lead_interactions.

### No Flutter

O `LeadScoringService` registra eventos silenciosamente.
O assessor nem percebe — mas o score vai subindo conforme
o lead interage com o app.

### Resultado

O assessor abre a lista de leads e sabe exatamente quem
priorizar: 🔥 80+ (quente), ☀️ 60+ (morno), ❄️ 40+ (frio).

Próxima edição: Sistema de Roles com RLS no Supabase.

---
Global Real Tech — Bastidores técnicos do Global Real
```

### Próximas edições planejadas

| # | Tema |
|---|---|
| 3 | Sistema de Roles (Master/Advisor) com RLS no Supabase |
| 4 | Chat em tempo real com Supabase Realtime |
| 5 | Automação de Follow-up com Edge Functions + pg_cron |
| 6 | Deploy multiplataforma: Play Store, App Store e Vercel |
| 7 | Internacionalização com Flutter l10n (4 idiomas) |
| 8 | Match Imobiliário: IA que conecta leads a imóveis |

---

## Newsletter 2: Global Real Invest 📊
**Público**: Investidores, assessores, incorporadoras
**Frequência**: Semanal (1x por semana)
**Tom**: Informativo, dados de mercado, oportunidades

### Edição #1 — "Por que investir em São Paulo e Florida ao mesmo tempo?"

**Assunto do email**: 📊 SP + Florida: a estratégia de dois mercados que investidores estão adotando

```
# Global Real Invest #1
## Por que investir em São Paulo e Florida ao mesmo tempo?

A diversificação geográfica é uma das estratégias mais
inteligentes no mercado imobiliário atual. E dois mercados
se destacam para o investidor brasileiro:

### 🇧🇷 São Paulo

São Paulo concentra o maior mercado imobiliário da América
Latina. Alguns dados:

→ Valorização média de 8-12% ao ano em regiões premium
→ Demanda crescente por short-term rental (Airbnb)
→ Novos empreendimentos com foco em compactos e studios
→ Infraestrutura de metrô em expansão valorizando novas regiões

### 🇺🇸 Florida

Florida é o destino #1 de investidores brasileiros nos EUA:

→ Orlando e Miami entre as cidades mais procuradas
→ Retorno em dólar — proteção cambial natural
→ Mercado de vacation rental consolidado
→ Legislação favorável ao investidor estrangeiro

### A estratégia combinada

Investir nos dois mercados permite:
- Receita em real + dólar
- Proteção contra instabilidade de um único mercado
- Acesso a perfis diferentes de inquilino/comprador
- Diversificação de risco real

### Como o Global Real ajuda

No app, você compara empreendimentos dos dois mercados
lado a lado, com câmbio em tempo real, filtros avançados
e calculadora de investimentos.

Lançamento: 27 de abril.
🔗 https://global-real-rho.vercel.app/download.html

---
Global Real Invest — Oportunidades no mercado imobiliário
```

### Edição #2 — "Fração imobiliária: o modelo que democratiza o investimento"

**Assunto do email**: 🏠 Investir em imóveis a partir de R$ 30 mil? Fração imobiliária explica como

```
# Global Real Invest #2
## Fração imobiliária: o modelo que democratiza o investimento

Você não precisa comprar um imóvel inteiro pra investir
em real estate. A fração imobiliária permite que você
adquira uma parte de um empreendimento e receba receita
proporcional.

### Como funciona

1. Um empreendimento é dividido em frações (ex: 52 semanas)
2. Você compra X semanas
3. Recebe receita proporcional à ocupação
4. Pode usar as semanas ou alugar

### Por que está crescendo

→ Ticket de entrada menor (a partir de R$ 30-50 mil)
→ Gestão profissional do imóvel
→ Sem dor de cabeça de manutenção
→ Modelo já consolidado nos EUA (timeshare evoluído)

### O que analisar antes de investir

- Taxa de ocupação histórica da região
- Gestora do empreendimento (track record)
- Custos de manutenção e administração
- Liquidez: como revender sua fração

### Simule no Global Real

No app, o simulador de fração calcula:
→ Receita projetada por semana
→ Taxa de ocupação estimada
→ Retorno anual por fração
→ Comparativo entre empreendimentos

🔗 https://global-real-rho.vercel.app/download.html

---
Global Real Invest — Oportunidades no mercado imobiliário
```

### Próximas edições planejadas

| # | Tema |
|---|---|
| 3 | ROI, TIR e Payback: o que significam e como calcular |
| 4 | Short-term rental: vale a pena investir em Airbnb? |
| 5 | Mercado imobiliário em 2026: tendências e previsões |
| 6 | Como avaliar um empreendimento antes de investir |
| 7 | Investimento em dólar: proteção cambial para brasileiros |
| 8 | FIIs vs imóvel físico: prós e contras |

---

## Newsletter 3: Global Real Updates 🚀
**Público**: Usuários do app, assessores, leads
**Frequência**: Mensal (1x por mês) ou a cada release
**Tom**: Leve, direto, focado em novidades e dicas de uso

### Edição #1 — "Bem-vindo ao Global Real — o que você pode fazer no app"

**Assunto do email**: 🚀 Global Real está no ar! Veja tudo que você pode fazer

```
# Global Real Updates #1
## Bem-vindo ao Global Real!

O Global Real está oficialmente disponível na Google Play
e App Store. Aqui está tudo que você pode fazer:

### 🏠 Explore empreendimentos

Navegue pelo catálogo de empreendimentos em São Paulo e
Florida. Use filtros por tipo, preço, data de entrega,
amenidades e proximidade de metrô.

### 💰 Simule investimentos

A calculadora mostra ROI, TIR, payback e projeções de
receita com dados reais. Disponível no plano premium.

### 📊 Fração imobiliária

Simule investimentos fracionados: semanas, ocupação,
receita projetada e retorno por fração.

### 🌍 4 idiomas

O app está disponível em português, inglês, espanhol
e mandarim. Mude nas configurações.

### 💱 Câmbio em tempo real

Compare valores em real e dólar com cotação atualizada.

### ⭐ Favoritos

Salve empreendimentos que te interessam e acompanhe.

---

Baixe agora:
🔗 https://global-real-rho.vercel.app/download.html

Dúvidas? Responda este email.

---
Global Real Updates — Novidades e dicas do app
```

### Edição #2 — "Novidades da versão 1.2: IA que encontra o imóvel ideal pra você"

**Assunto do email**: 🆕 Nova versão: Match Imobiliário com IA chegou!

```
# Global Real Updates #2
## Novidades da versão 1.2

Acabamos de lançar uma atualização com funcionalidades
que vão mudar como você encontra oportunidades:

### 🤖 Match Imobiliário

A IA agora cruza seu perfil de investidor com os imóveis
disponíveis e sugere os que mais combinam com você.
É como um "Tinder de imóveis" — mas com dados reais.

### 📈 Melhorias na calculadora

Novos gráficos de projeção e comparativo entre
empreendimentos lado a lado.

### 🔔 Notificações

Receba alertas quando um empreendimento compatível
com seu perfil entrar no catálogo.

---

Atualize o app na Play Store ou App Store.
🔗 https://global-real-rho.vercel.app/download.html

---
Global Real Updates — Novidades e dicas do app
```

### Próximas edições planejadas

| # | Tema |
|---|---|
| 3 | Dica: como usar a calculadora pra comparar investimentos |
| 4 | Novo: Dashboard de performance para assessores |
| 5 | Dica: como funciona o sistema de favoritos e alertas |
| 6 | Novo: Chatbot IA para tirar dúvidas no app |

---

## Resumo das 3 Newsletters

| Newsletter | Público | Frequência | Foco |
|---|---|---|---|
| **Global Real Tech** 🛠️ | Devs, CTOs, PropTech | Quinzenal | Stack, arquitetura, IA, bastidores |
| **Global Real Invest** 📊 | Investidores, assessores | Semanal | Mercado, tendências, oportunidades |
| **Global Real Updates** 🚀 | Usuários do app | Mensal | Novidades, releases, dicas de uso |

## Setup Recomendado

### Substack
1. Criar conta em [substack.com](https://substack.com)
2. Criar 1 publicação: "Global Real"
3. Usar 3 seções (sections): Tech, Invest, Updates
4. Cada seção tem sua lista de inscritos separada
5. O Substack envia por email automaticamente

### LinkedIn Newsletter
1. Na page Global Real Estate → Criar Newsletter
2. Criar 3 newsletters separadas (LinkedIn permite múltiplas)
3. Copiar o conteúdo do Substack e colar no LinkedIn
4. Publicar no mesmo dia

### Fluxo de publicação
1. Escreve no Substack (fonte principal)
2. Publica → email vai automaticamente
3. Cola no LinkedIn Newsletter
4. Posta um resumo no feed do LinkedIn com link pro artigo completo
