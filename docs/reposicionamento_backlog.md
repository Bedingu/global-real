# Reposicionamento do App — Backlog priorizado

> Backlog derivado do PDF v4 (18/08/2026) cruzado com o código real. Complementa `reposicionamento_analise.md`.
> Prioridades seguem o PDF: **Associados** e **Academia** são ALTA; **Vitrine** e **Rentabilidade/AirDNA** são MÉDIA.
> Legenda de reaproveitamento: ✅ pronto · 🟡 ajustar · 🔴 do zero. Esforço: P (dias), M (1–2 semanas), G (3+ semanas), estimativas grosseiras a refinar.

---

## Épico 0 — Decisão de arquitetura e fundação (BLOQUEADOR)

Precisa acontecer antes dos épicos de feature, porque define onde cada coisa é construída.

| # | Tarefa | Reap. | Esf. | Depende |
|---|---|---|---|---|
| 0.1 | Decidir: unificar `global_real` + `global_crm` num app só, ou manter app (real) + back-office (crm) com o mesmo Supabase | — | P | Alinhamento Gustavo + Leandro |
| 0.2 | Definir onde vive o funil operacional do Varejo (app do associado × CRM do time de SP) | — | P | 0.1 |
| 0.3 | Focar `global_real` como app nativo: revisar/reduzir caminhos `kIsWeb`, validar build iOS + Android | 🟡 | M | 0.1 |
| 0.4 | Limpeza: remover código órfão `crm_service.dart` do `global_real` (conta tabelas `crm_*` sem UI) | 🟡 | P | 0.1 |

---

## Épico 1 — Gestão de Associados e Qualificação — PRIORIDADE ALTA

Motor do pilar 2 do PDF. Hoje só existe uma tela estática "Proposta de Parceria" com CTA vazio (`private_page.dart`).

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 1.1 | Modelo de dados `associates` no Supabase (candidato: nome, contato, tipo corretor/imobiliária, status) | 🔴 | P | Máquina de estados: aplicação recebida → vídeo agendada → aprovado/reprovado |
| 1.2 | Tela/formulário "Quero ser associado" (aplicação inicial) | 🔴 | M | Substitui o CTA vazio de `_buildPartnershipView` |
| 1.3 | Agendamento da videoconferência obrigatória de qualificação | 🟡 | M | Reaproveitar `crm_activities`/`crm_visit_schedule_page` do CRM, ou integrar ferramenta externa |
| 1.4 | Campo "comissão combinada" por associado (texto/número **manual**, só admin) | 🔴 | P | ⚠️ PDF é enfático: **nunca calcular/publicar** — só registro manual pós-qualificação |
| 1.5 | Atribuição de origem/associado em cada lead de Varejo (campo em `market_leads`) | 🔴 | P | Liga o negócio ao associado mesmo o time de SP fechando |
| 1.6 | Painel do associado: status dos negócios em andamento | 🔴 | M | Varejo = time de SP; Private = próprio associado |
| 1.7 | Rastrear as 2 formas de entrada no Varejo (carteira própria × campanha cooperada Meta) | 🔴 | P | Private não tem campanha |

**Decisões pendentes (checklist do Leandro):** quem conduz a videoconferência; se a comissão combinada é visível ao associado ou só admin.

---

## Épico 2 — Academia de Vídeo-aulas — PRIORIDADE ALTA

Pilar 1. Produto independente, vendido a qualquer pessoa. **Não acoplar a associados.**
Maior alavancagem de reaproveitamento: modelo de dados + player (dep. instalada) + Stripe já existem.

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 2.1 | Reorganizar `education_content` em 2 trilhas: Varejo e Private | 🟡 | P | Hoje `category` é livre |
| 2.2 | Player de vídeo do aluno (plugar `video_player`+`chewie`, já no pubspec, hoje não usados) | 🟡 | M | Falta a tela de consumo (só existe o CRUD admin) |
| 2.3 | Biblioteca/curso navegável para o aluno | 🔴 | M | `education_content` só é lido pela tela admin hoje |
| 2.4 | Progresso do aluno por aula/curso | 🔴 | M | Existe evento de scoring `watchVideo` definido mas sem tela |
| 2.5 | Venda avulsa de acesso (estender Stripe além da assinatura Premium) | 🟡 | M | `payment_service.dart` só faz assinatura hoje |
| 2.6 | Teste + certificação ao fim de cada trilha (`qr_flutter` p/ certificado verificável) | 🔴 | M | `qr_flutter` já está no pubspec |
| 2.7 | Garantir desacoplamento: comprar/assistir Academia **não** exige ser associado | 🟡 | P | Regra de acesso separada do épico 1 |

**Decisão pendente:** Academia com pagamento dentro do app ou plataforma externa com o app só reconhecendo certificado.

---

## Épico 3 — Configuração da Roleta e do Funil — (config, baixo código)

O "só configurar" do PDF. Onde é feito depende do Épico 0. No `global_crm` a base já existe; no `global_real` o funil é fixo.

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 3.1 | Cadastrar a roleta de Varejo no CRM (distribuição p/ corretores internos de SP) | ✅ | P | `crm_new_roulette_page`/`crm_roulette_settings_page` prontos; nenhuma roleta cadastrada ainda |
| 3.2 | Renomear/reorganizar etapas do funil → Contato → Diagnóstico → Apresentação → Proposta | ✅ | P | `crm_edit_funnel_page` no CRM (editável). No app seria 3.4 |
| 3.3 | Ativar integrações Facebook Leads Ads + WhatsApp Business (hoje "Inativo") | 🟡 | M | `crm_integrations_page`/`crm_whatsapp_page` existem; falta conectar de fato |
| 3.4 | (Se funil ficar no app) tornar as 4 etapas fixas de `lead_funnel_page.dart` configuráveis | 🟡 | M | Só se Épico 0 colocar o funil no `global_real` |
| 3.5 | Marcar no funil o corte associado (Contato/Diagnóstico) × time SP (Apresentação+) | 🔴 | P | Confirmar se é permissão nativa ou campo customizado |

---

## Épico 4 — Vitrine pública dentro do app — PRIORIDADE MÉDIA

Área "Explorar" pré-login. Base existe em `public_home_page.dart`, mas catálogo real exige login e signup não cria lead.

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 4.1 | Expor catálogo curado do Varejo pré-login (foto/região/tipo/faixa de rentabilidade, sem endereço exato) | 🟡 | M | Dados já em `developments` (`yield`/`avg_daily_rate`); falta seleção curada e visão pública |
| 4.2 | Captura de lead público (nome/telefone/interesse → `market_leads`) | 🔴 | M | Signup atual só cria usuário Supabase, não lead |
| 4.3 | Ponto de conversão: ao pedir detalhe completo/rentabilidade específica → cadastro → vira lead → funil | 🟡 | M | Encaixa no funil existente (roleta → time SP) |
| 4.4 | Duas portas: "Quero investir" (lead investidor) × "Quero ser associado" (→ Épico 1) | 🔴 | P | — |
| 4.5 | Esconder Private/SCP da área pública (regra de visibilidade regulatória) | 🔴 | P | Mesma cautela da seção 5 do PDF |

---

## Épico 5 — Rentabilidade + Integração AirDNA — PRIORIDADE MÉDIA

Motores de cálculo já são um ativo forte; o gargalo é dado real (STR hoje é mock) e a integração paga.

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 5.1 | Prototipar AirDNA via Zapier (validar fluxo antes de codar) | 🟡 | P | Recomendado pelo próprio PDF; Zapier existe no CRM |
| 5.2 | Integração real com API do AirDNA (ocupação por região) | 🔴 | G | API paga — orçar custo/limites antes (seção 5 PDF) |
| 5.3 | Substituir dados mockados de `str_analytics_page.dart` por reais | 🟡 | M | Hoje tudo é `math.Random`/listas hardcoded |
| 5.4 | Completar premissas: IPTU e vacância (condomínio/adm/limpeza já em `developments`) | 🟡 | P | "sem isso o número fica bonito e errado" (PDF) |
| 5.5 | Adicionar métrica cap rate por endereço (hoje há yield, não cap rate) | 🟡 | P | Reusa motores existentes |
| 5.6 | Tipo de item de catálogo "cota de fundo/SCP" (fundo, valor da cota, rentabilidade-alvo, prazo) | 🔴 | M | Catálogo hoje é orientado a imóvel físico |
| 5.7 | Usar aba "Chaves API" das Integrações para a chave do AirDNA | 🟡 | P | Existe no CRM (`crm_integrations_page`); no app depende do Épico 0 |

---

## Épico 6 — Higiene do menu do CRM — (decisão + config)

Ações no `global_crm` (esses módulos não existem no `global_real`). Dependem de decisão de modelo com o Leandro.

| # | Tarefa | Reap. | Esf. | Notas |
|---|---|---|---|---|
| 6.1 | Decidir destino de Aluguéis (só mantém se operar Airbnb pós-venda) | — | P | `crm_rentals_*` |
| 6.2 | Tirar Portais do menu principal (ou restringir ao Varejo) | 🟡 | P | `crm_portals_page` — alerta regulatório p/ Private |
| 6.3 | Rebaixar Chaves para secundário | 🟡 | P | `crm_keys_page` |
| 6.4 | Redefinir "Meu site" como site institucional (sai do papel de vitrine) | 🟡 | P | `crm_mysite_page` |
| 6.5 | Confirmar que Banco de terrenos está removido | ✅ | P | Não existe em nenhum projeto |

---

## Sequência sugerida (ondas)

1. **Onda 0 — Fundação:** Épico 0 completo + Épico 3.1/3.2 (config rápida de roleta/funil no CRM, valor imediato sem código).
2. **Onda 1 — Pilares (ALTA):** Épico 1 (Associados) e Épico 2 (Academia) em paralelo — são os dois produtos centrais do reposicionamento.
3. **Onda 2 — Captação:** Épico 4 (Vitrine + captura de lead) + Épico 3.3 (ativar Meta/WhatsApp), fechando o funil de entrada.
4. **Onda 3 — Diferencial analítico:** Épico 5 (Rentabilidade real + AirDNA), começando por 5.1 (Zapier) para reduzir risco.
5. **Contínuo:** Épico 6 conforme decisões de modelo saírem com o Leandro.

---

## Checklist de decisões antes de codar (consolidado)

Do PDF (Leandro) + arquitetura (Gustavo):
- [ ] Unificar os dois projetos ou manter app + back-office? (Épico 0.1)
- [ ] Funil do Varejo vive no app ou no CRM? (0.2)
- [ ] Quem conduz a videoconferência de qualificação?
- [ ] Comissão combinada visível ao associado ou só admin?
- [ ] Academia: pagamento no app ou plataforma externa + certificado?
- [ ] Global vai operar aluguel por temporada dos imóveis vendidos?
- [ ] Portais: restritos ao Varejo ou fora do menu?
- [ ] Funil no Varejo: associado vê etapas do time de SP ou só status resumido?
- [ ] Quais empreendimentos entram na vitrine curada e com que frequência?
- [ ] AirDNA: prototipar via Zapier primeiro? Orçamento aprovado?

---

*Base: PDF v4 (18/08/2026) + auditoria de `global_real` e `global_crm`. Ver `reposicionamento_analise.md` para o cruzamento detalhado.*
