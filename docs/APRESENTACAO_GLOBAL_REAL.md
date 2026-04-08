# Global Real — Plataforma de Investimentos Imobiliários com Inteligência Artificial

---

## Visão Geral

O **Global Real** é uma plataforma completa de investimentos imobiliários que conecta investidores, assessores e incorporadoras nos mercados de **São Paulo** e **Florida (EUA)**. Disponível na **Google Play Store**, com versão web e preparado para iOS.

O diferencial competitivo é a integração nativa de **Inteligência Artificial (Claude/Anthropic)** em toda a jornada — da captação do lead até o fechamento do negócio.

---

## Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter (Dart) — Android, iOS, Web |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Edge Functions) |
| IA | Anthropic Claude API (qualificação, recomendação, follow-up) |
| Pagamentos | Stripe (modelo freemium + assinatura premium) |
| Hospedagem Web | Vercel |
| Infraestrutura | Supabase Cloud (sa-east-1, São Paulo) |
| Internacionalização | PT-BR, EN, ES, ZH (4 idiomas) |

---

## Módulos do App

### 1. Catálogo de Empreendimentos

Marketplace de empreendimentos imobiliários com:

- Busca por nome, cidade ou endereço
- Filtros avançados: mercado (SP/Florida), tipo de imóvel, faixa de preço, data de entrega, amenidades, proximidade de metrô, capacidade
- Cards com galeria de imagens, favoritos e detalhes completos
- Conversão de câmbio USD/BRL em tempo real
- Painel "All Filters" lateral para filtragem combinada

**Screenshots**: `Lançamentos.jpg`, `Mercado_Sao_Paulo_Floria.jpg`

---

### 2. Área de Investimentos Premium (Paywall)

Conteúdo exclusivo para assinantes:

- **Catálogo de Investimentos** — produtos de investimento imobiliário com retorno alvo, retorno proposto e investimento mínimo
- **Calculadora de Investimentos** — simulações financeiras com cálculo de ROI, IRR (TIR), payback e projeções
- **Fração Imobiliária** — simulador de frações com semanas, ocupação e receita projetada
- **IPO / FII** — análise de Fundos Imobiliários e IPOs
- **Estoque** — gestão de estoque de unidades disponíveis
- **Vídeos e Insights** — conteúdo educacional em vídeo
- **Investimentos Privados** — cases privados com análise detalhada

**Screenshots**: `Calculadora de Investimentos.jpg`, `Catálogo de Investimentos.jpg`, `Fração Imobiliária_1-4.jpg`, `IPO.jpg`, `Estoque.jpg`, `Investimentos Privados.jpg`, `Videos e Insights.jpg`

---

### 3. Sistema de Leads com IA 🤖

Módulo completo de gestão de leads com inteligência artificial integrada:

#### 3.1 Qualificação Automática por IA
- Quando um lead entra no sistema, a IA (Claude) analisa automaticamente o perfil
- Gera um **score de qualidade** (0-100) e um **resumo em português**
- Sugere uma **mensagem personalizada** para o assessor enviar ao lead
- Tudo acontece via Edge Function + trigger no banco de dados

#### 3.2 Recomendação de Produtos por IA
- A IA cruza o perfil do lead (interesse, budget, mercado) com o **catálogo de investimentos**
- Recomenda até **3 produtos** com score de compatibilidade (match_score)
- Exibe recomendações no chat e na página de detalhes do lead

#### 3.3 Lead Scoring Contínuo
- Sistema de pontuação que combina:
  - **Score IA** (até 50 pontos) — qualificação automática pelo Claude
  - **Score de Interações** (até 50 pontos) — baseado em 17 tipos de evento rastreados
- Eventos rastreados: cadastro, login, visualização de empreendimento, favorito, uso de calculadora, clique WhatsApp, resposta no chat, retorno ao app, compartilhamento, etc.
- Recálculo automático via trigger a cada nova interação
- Página de detalhes com gráfico circular, breakdown por atividade e histórico completo

#### 3.4 Chat em Tempo Real
- Chat entre assessor e lead com **Supabase Realtime**
- Mensagens da IA aparecem com badge diferenciado
- Banner com resumo da IA e produtos recomendados no topo do chat
- Botão de WhatsApp integrado para contato direto

#### 3.5 Automação de Follow-up
- Edge Function que roda a cada **6 horas** via cron job (pg_cron)
- Identifica leads com status "novo" há mais de **24 horas** sem contato
- Claude gera mensagem de follow-up personalizada automaticamente
- Alerta visual vermelho no card do lead quando está sem contato

---

### 4. Funil de Vendas (Kanban) 📊

- Visualização Kanban com 4 estágios: **Novo → Contatado → Qualificado → Fechado**
- **Desktop/Web**: colunas lado a lado com drag-and-drop
- **Mobile**: navegação por tabs
- Protegido por **paywall** (só assinantes premium)

---

### 5. Sistema de Roles (Perfis de Acesso)

| Role | Permissões |
|---|---|
| **Master** | Vê todos os leads de todos os assessores, pode filtrar por assessor, reatribuir leads |
| **Advisor** | Vê apenas seus próprios leads atribuídos |
| **User** | Acesso padrão ao app (investidor/lead) |

- RLS (Row Level Security) no Supabase garante isolamento de dados
- View `advisors_list` para gestão de equipe
- Atribuição e reatribuição de leads pelo master

---

### 6. Monetização

- Modelo **Freemium**: catálogo de empreendimentos gratuito
- **Premium** (assinatura via Stripe): acesso a investimentos, calculadora, fração, Kanban, conteúdo exclusivo
- Paywall modal com planos anual e mensal
- Status de assinatura sincronizado em tempo real via Supabase Realtime

---

## Arquitetura de IA

```
Lead entra no sistema
        │
        ▼
┌─────────────────────────┐
│  Trigger PostgreSQL      │
│  (on INSERT market_leads)│
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Edge Function           │
│  "qualify-lead"          │
│                          │
│  1. Busca dados do lead  │
│  2. Busca catálogo       │
│  3. Busca interações     │
│  4. Envia p/ Claude API  │
│  5. Recebe:              │
│     - Score (0-100)      │
│     - Resumo             │
│     - Msg sugerida       │
│     - Recomendações      │
│  6. Atualiza lead        │
│  7. Insere msg no chat   │
└─────────────────────────┘

        ┌─────────────────┐
        │  Cron (6h)       │
        │  "auto-followup" │
        │                  │
        │  Leads sem       │
        │  contato > 24h   │
        │  → Claude gera   │
        │  follow-up       │
        └─────────────────┘
```

---

## Diferenciais Competitivos

1. **IA nativa na jornada do lead** — não é um chatbot genérico, é qualificação + recomendação + follow-up automático integrados ao fluxo de vendas
2. **Dois mercados em um app** — São Paulo e Florida com câmbio em tempo real
3. **Scoring híbrido** — combina análise de IA com dados comportamentais reais do usuário
4. **Kanban para gestão de vendas** — funil visual com drag-and-drop
5. **Multi-role** — master coordena equipe de assessores com visibilidade total
6. **Multiplataforma** — Android (Play Store), Web, iOS-ready
7. **4 idiomas** — PT-BR, EN, ES, ZH
8. **Automação inteligente** — follow-up automático sem intervenção humana

---

## Números e Infraestrutura

- **Backend**: Supabase Cloud, região sa-east-1 (São Paulo)
- **IA**: Anthropic Claude (claude-sonnet-4-20250514)
- **Tabelas principais**: `market_leads`, `chat_messages`, `lead_interactions`, `scoring_rules`, `investment_catalog`, `developments`, `profiles`
- **Edge Functions**: `qualify-lead`, `auto-followup`
- **Cron Jobs**: follow-up automático a cada 6h
- **RLS**: Row Level Security em todas as tabelas sensíveis
- **Versão atual**: 1.1.0 (build 4)

---

## Roadmap — Próximas Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Match Imobiliário (Tinder de Imóveis)** | Proprietários cadastram imóveis, IA faz match automático com leads interessados |
| **Chatbot IA para Leads** | Autoatendimento com IA que responde perguntas e escala pro assessor |
| **Landing Pages por Empreendimento** | Páginas compartilháveis com tracking de visualização |
| **Dashboard de Performance** | Métricas por assessor: tempo de resposta, conversão, leads atendidos |
| **Formulário Inteligente de Captação** | Qualificação em tempo real durante o preenchimento |

---

## Screenshots

| Tela | Arquivo |
|---|---|
| Mercado SP / Florida | `Mercado_Sao_Paulo_Floria.jpg` |
| Lançamentos | `Lançamentos.jpg` |
| Catálogo de Investimentos | `Catálogo de Investimentos.jpg` |
| Calculadora | `Calculadora de Investimentos.jpg` |
| Fração Imobiliária | `Fração Imobiliária_1.jpg` a `4.jpg` |
| IPO / FII | `IPO.jpg` |
| Estoque | `Estoque.jpg` |
| Investimentos Privados | `Investimentos Privados.jpg` |
| Vídeos e Insights | `Videos e Insights.jpg` |
| Proposta de Parceria | `Proposta_Parceria.jpg` |

---

## Contato

**Global Real — Investimentos Imobiliários**
Plataforma disponível na Google Play Store
