# Reposicionamento do App — Análise (Instruções × Código atual)

> Documento de trabalho para o Gustavo. Cruza o PDF **"Instruções de Desenvolvimento — Reposicionamento do App / Global Real Estate" (v4, 18/08/2026)** com o que já existe nos dois projetos Flutter no disco.
> Objetivo: mostrar, seção por seção do PDF, o que **já dá pra reaproveitar**, o que **só precisa de ajuste/configuração** e o que precisa ser **construído do zero**.

---

## 0. Descoberta que muda o plano: são DOIS projetos, não um

O PDF fala de um "app atual" (`globalreal-crm-app.web.app`) e de um "CRM em produção" auditado. No disco, isso está dividido em **dois codebases Flutter separados**:

| Projeto | O que é | Papel no reposicionamento |
|---|---|---|
| **`global_real`** (este workspace) | App do investidor / vitrine pública + hub "Sócio Investidor" (educação, simulações Private, STR, catálogo, leads, parceria). | É o **app-produto** que o PDF quer levar pra iOS+Android. Vitrine, Academia, associados e investidor final devem viver aqui. |
| **`global_crm`** (`c:\Users\bedin\global_crm`) | CRM imobiliário multi-tenant completo: Roleta, Funil editável, Integrações, Portais, Chaves, Meu site, Aluguéis (faturas/repasses/contratos), Pessoas, Propostas, Relatórios, Atividades, WhatsApp, Webhooks. | É o **"CRM atual"** que o Leandro auditou. É aqui que estão a Roleta e o Funil "que já existem e só precisam de config" (seção 2 do PDF). |

**Implicação central:** o PDF trata os dois como se fossem um só app. Na prática, o reposicionamento exige decidir a **relação entre os dois projetos**:
- **Opção A — Unificar:** trazer os módulos operacionais (Roleta, Funil, Integrações) do `global_crm` pra dentro do `global_real`, que vira o app único nativo. Mais trabalho, mas entrega o "tudo dentro do app" que o PDF pede.
- **Opção B — Manter separados:** `global_real` é o app público/associado (nativo), `global_crm` continua sendo o back-office web do time de SP. Os dois falam com o mesmo Supabase.

> **Isso é a primeira decisão de arquitetura a alinhar** — está fora do checklist do Leandro, mas afeta quase todo o resto. Minha recomendação preliminar (ver seção final) é a Opção B no curto prazo, porque o funil/roleta do PDF descreve trabalho do **time interno de SP**, não do associado remoto.

Nota boa: o próprio `global_real` **já é Flutter**, então a recomendação cross-platform da seção 1 do PDF (React Native/Flutter) já está atendida. Não há duas bases nativas pra unificar — a base cross-platform já existe.

---

## 1. Objetivo / proposta de valor (dois pilares independentes)

**O que o PDF pede:** dois produtos independentes no app — (1) **Academia** (vídeo-aulas, vendida a qualquer um) e (2) **Seja associado** (acesso ao portfólio, entrada por aplicação + videoconferência). Não podem ser acoplados. App **nativo iOS+Android**, sem site externo; vitrine vira área do app.

| Item | Situação no código | Veredito |
|---|---|---|
| Base cross-platform (Flutter) | `global_real` já é Flutter (`pubspec.yaml`) | ✅ Já atendido |
| App nativo iOS+Android | Projeto tem `android/` e config de splash iOS+Android; hoje roda também como web (`kIsWeb` em várias telas) | 🟡 Existe base; falta focar/publicar nas stores e remover dependências de web |
| Academia como produto independente | Só existe CRUD admin de vídeos (`admin_videos_page.dart` → tabela `education_content`). Sem player, sem venda, sem trilha de aluno | 🔴 Construir (ver seção 4) |
| "Seja associado" como fluxo próprio | Não existe. Só uma tela estática "Proposta de Parceria" com **CTA vazio** (`private_page.dart`, `_buildPartnershipView`, `onTap: () {}`) | 🔴 Construir (ver seção 4) |
| Não acoplar Academia × associado | N/A hoje (nenhum dos dois existe de verdade) | ⚪ Cuidar no design |

---

## 2. "Já existe no CRM — só configurar" (Roleta e Funil)

**O que o PDF pede:** cadastrar roleta (só Varejo, com campo de associado de origem), renomear as 5 etapas do funil para Contato → Diagnóstico → Apresentação → Proposta, e ativar as integrações Facebook Leads Ads + WhatsApp Business.

Aqui está o ponto onde os dois projetos divergem. **Depende de qual funil o Leandro auditou.**

### No `global_crm` (o CRM "de verdade"):
| Recurso pedido | Onde está | Veredito |
|---|---|---|
| Roleta de leads | `crm_lead_roulette_page.dart`, `crm_new_roulette_page.dart`, `crm_roulette_settings_page.dart`, `crm_roulette_history_page.dart` | ✅ Existe — só configurar (nenhuma roleta cadastrada, como o PDF diz) |
| Funil editável (nome/cor/estagnação) | `crm_edit_funnel_page.dart`, `crm_opportunities_page.dart`, `crm_opportunity_settings_page.dart` | ✅ Existe — só renomear/reorganizar etapas |
| Integrações (Facebook/WhatsApp/Zapier/Webhooks) | `crm_integrations_page.dart`, `crm_whatsapp_page.dart`, `crm_system_webhooks_page.dart` | 🟡 Telas existem; **ativar e conectar** de fato (hoje "Inativo") |

### No `global_real` (o app):
| Recurso | Onde está | Veredito |
|---|---|---|
| Funil de vendas | `lead_funnel_page.dart` — Kanban de **4 etapas FIXAS** (`new`/`contacted`/`qualified`/`closed`), **hardcoded** | 🟡 Não é configurável. Se o funil tiver que viver aqui, precisa virar dinâmico |
| Atribuição de lead | `chat_service.dart` → `assignLead` é **manual** (master escolhe assessor) | 🔴 Não há roleta/distribuição automática |
| Origem do lead (associado) | Não há campo de associado de origem em `market_leads` | 🔴 Construir |
| Ingestão Meta/WhatsApp | Só texto de marketing no paywall; **nenhum webhook/ingestão real**. Botão WhatsApp é só `wa.me` outbound | 🔴 Construir (ou usar o do CRM) |

> **Conclusão da seção 2:** o "só configurar" do PDF é verdade **no `global_crm`**. No `global_real` esses recursos ou não existem ou são versões simplificadas. A decisão da seção 0 define onde esse trabalho acontece.

---

## 3. "Sair do menu / repensar" (Aluguéis, Portais, Chaves, Meu site, Banco de terrenos)

**O que o PDF pede:** tirar/decidir sobre módulos que não batem com "vender investimento".

Detalhe importante: **esses módulos não existem no `global_real`** — só no `global_crm`. Então "tirar do menu" é uma ação **no CRM**, não no app.

| Módulo | Onde está | Ação do PDF | Nota |
|---|---|---|---|
| Aluguéis (contratos/faturas/repasses) | `global_crm`: `crm_rentals_billing/contracts/invoices/transfers/analysis`, `crm_rental_costs_page` | Decidir antes (só mantém se for operar Airbnb pós-venda) | Decisão de modelo — Leandro |
| Portais (OLX/ZAP) | `global_crm`: `crm_portals_page.dart` | Tirar do menu principal (no máximo restrito ao Varejo) | Alerta regulatório p/ Private |
| Chaves | `global_crm`: `crm_keys_page.dart` | Secundário (só se houver escritório físico) | — |
| Meu site | `global_crm`: `crm_mysite_page.dart`, `crm_digital_card_page.dart`, `crm_domain_settings_page` | Sai do escopo de vitrine (vira só site institucional) | Vitrine agora é área do app (seção 4) |
| Banco de terrenos | Não encontrado em nenhum dos dois | Removido | Já não existe — nada a fazer |

Em `global_real` há um resquício: `crm_service.dart` conta registros de `crm_rentals/crm_contracts/crm_keys`, mas **não é usado por nenhuma tela** (código órfão). Pode ser removido do app na limpeza.

---

## 4. "Construir do zero" (o coração do reposicionamento)

### 4.1 Gestão de associados e qualificação — PRIORIDADE ALTA
**PDF:** formulário "quero ser associado", videoconferência obrigatória, status do candidato (aplicação → vídeo agendada → aprovado/reprovado), campo de comissão combinada (texto manual, admin), origem do lead por associado, painel do associado.

| Sub-item | Situação | Veredito |
|---|---|---|
| Formulário de aplicação | Não existe (só "Proposta de Parceria" estática, CTA vazio) | 🔴 Construir |
| Videoconferência de qualificação | Não existe. No CRM há `crm_visit_schedule_page` (agenda de visitas) e `crm_activities` (tipo Reunião) — reaproveitável como base de agendamento | 🟡 Adaptar do CRM ou integrar ferramenta |
| Status do candidato | Não existe | 🔴 Construir (máquina de estados simples) |
| Campo de comissão combinada | Não existe. **PDF é enfático: só texto/número manual, admin, nunca calculado** | 🔴 Construir (campo simples) |
| Origem do lead por associado | Não existe em `market_leads` | 🔴 Construir |
| Painel do associado | Não existe | 🔴 Construir |

### 4.2 Academia de vídeo-aulas — PRIORIDADE ALTA
**PDF:** biblioteca em duas trilhas (Varejo/Private), player, venda avulsa (qualquer um compra), progresso do aluno, certificação. Não acoplar a associados.

| Sub-item | Situação | Veredito |
|---|---|---|
| Modelo de dados de conteúdo | `education_content` já existe (title, description, category, video_url, thumbnail, duração, status, publish_at) via `admin_videos_page` | ✅ Reaproveitar a base |
| Player de vídeo | `video_player` + `chewie` **estão no pubspec mas não são usados** | 🟡 Plugar (dependência já lá) |
| Trilhas Varejo/Private | Hoje `category` é livre (Mercado Imobiliário, etc.) | 🟡 Ajustar taxonomia p/ 2 trilhas |
| Venda/pagamento avulso | Stripe (`payment_service.dart`) só faz **assinatura Premium** | 🟡 Estender p/ compra de curso (produto avulso) |
| Progresso do aluno | Não existe (há só o evento de scoring `watchVideo` definido, sem tela) | 🔴 Construir |
| Certificação | Não existe (`qr_flutter` no pubspec pode servir p/ certificado verificável) | 🔴 Construir |

> A Academia é o item com **maior alavancagem de reaproveitamento**: modelo de dados, player (dep. instalada) e Stripe já existem. É construção incremental, não do zero total.

### 4.3 Vitrine pública dentro do app — PRIORIDADE MÉDIA
**PDF:** área "Explorar" pré-login, seleção curada do Varejo (foto/região/tipo/faixa de rentabilidade), sem endereço exato; conversão pede cadastro e vira lead; duas portas ("Quero investir" / "Quero ser associado"); Private não aparece na área pública.

| Sub-item | Situação | Veredito |
|---|---|---|
| Navegação pré-login | `public_home_page.dart` — landing pública existe | ✅ Base existe |
| Catálogo curado sem login | Home mostra destaques/lançamentos de marketing; **catálogo real exige login** | 🟡 Expor catálogo curado pré-login |
| Faixa de rentabilidade estimada | Campos `yield/avg_daily_rate/occupancy` já existem em `developments` | ✅ Dados prontos |
| Conversão → lead | Signup cria **usuário** (email/senha), **não cria lead** com telefone/interesse | 🔴 Construir captura de lead público |
| Duas portas (investir / associado) | Não existe | 🔴 Construir |
| Esconder Private da vitrine | N/A (nada público hoje) | ⚪ Cuidar no design (regulatório) |

### 4.4 Rentabilidade + AirDNA — PRIORIDADE MÉDIA
**PDF:** cap rate, payback, yield por endereço; integração AirDNA (ocupação); premissas (ADR, condomínio, IPTU, taxa de adm, vacância); tipo de item "cota de fundo/SCP"; usar a aba "Chaves API" das Integrações.

| Sub-item | Situação | Veredito |
|---|---|---|
| Motores de cálculo (IRR/ROI/payback/NPV) | `private_simulation_engine.dart` + `irr_calculator.dart` — **completos e auditáveis** | ✅ Reaproveitar (ativo forte) |
| STR Analytics (ADR/ocupação/heatmap/comp sets) | `str_analytics_page.dart` — UI completa mas **100% mockada com `math.Random`** | 🟡 Trocar mock por dados reais |
| Integração AirDNA | **Não existe** (o "inspirado no AirDNA" é só visual) | 🔴 Construir integração real |
| Premissas (condomínio/IPTU/vacância) | Parcial: `condo_fee_monthly`, `management_fee_pct`, `cleaning_fee` já em `developments`; falta IPTU/vacância explícitos | 🟡 Completar campos |
| Cap rate por endereço | Não calculado (há yield, não cap rate) | 🔴 Adicionar métrica |
| Tipo "cota de fundo/SCP" no catálogo | Catálogo é orientado a imóvel físico (bedrooms/bathrooms/endereço) | 🔴 Adicionar tipo de item Private |
| Aba "Chaves API" | Existe no `global_crm` (`crm_integrations_page`), **não** no `global_real` | 🟡 Depende da seção 0 |

---

## 5. Pontos de atenção do PDF (mapeados ao código)

- **Alerta regulatório CVM (cotas SCP):** decisão jurídica, não de código. No código, afeta a regra "Private não aparece na vitrine pública" (4.3) e "Portais no máximo Varejo" (3). É uma regra de **visibilidade** a implementar com cuidado.
- **Zapier nativo p/ prototipar:** existe no `global_crm` (Integrações). Sustenta prototipar AirDNA via Zapier antes de codar integração própria — reduz risco da tarefa 4.4.
- **Custo/limites AirDNA:** decisão de negócio antes de codar 4.4. É API paga.
- **Ficha App Store/Play Store:** trabalho de publicação, não de código de feature; mas depende de focar o `global_real` como app nativo (seção 1).

---

## 6. Síntese — o que reaproveitar, ajustar e construir

**✅ Reaproveitar quase direto (ativos fortes já prontos):**
- Base Flutter cross-platform (atende a recomendação do PDF).
- Motores de simulação Private (IRR/ROI/payback/NPV) — auditáveis e completos.
- Catálogo `developments` com campos de rentabilidade (yield/ADR/ocupação/fees).
- Modelo `education_content` + `video_player`/`chewie` já no pubspec (base da Academia).
- Stripe Checkout (base p/ venda da Academia).
- No `global_crm`: Roleta e Funil editável prontos (o "só configurar" do PDF).

**🟡 Ajustar / completar:**
- Funil do app: de 4 etapas fixas → configurável (ou usar o do CRM).
- STR Analytics: trocar dados mockados por reais + AirDNA.
- Academia: plugar player, taxonomia de trilhas, progresso, venda avulsa.
- Vitrine: expor catálogo curado pré-login + captura de lead.
- Ativar de fato as integrações Facebook/WhatsApp (hoje "Inativo").

**🔴 Construir do zero:**
- Gestão de associados + qualificação (formulário, status, comissão manual, painel).
- Ingestão real de leads Meta/WhatsApp (se ficar no app).
- Integração AirDNA.
- Certificação da Academia.
- Duas portas de entrada na vitrine (investir / associar).

**Decisões a alinhar antes de codar (além do checklist do Leandro):**
1. **Arquitetura (seção 0):** unificar os dois projetos ou manter `global_real` (app) + `global_crm` (back-office)?
2. Onde vive o funil operacional do Varejo — no app do associado ou no CRM do time de SP?
3. AirDNA: prototipar via Zapier primeiro (recomendado pelo próprio PDF)?

---

*Base: PDF v4 (18/08/2026) + auditoria de código de `global_real` e `global_crm`. Próximo documento: backlog priorizado (`reposicionamento_backlog.md`).*
