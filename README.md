# 🌍 **Global Real — Market Intelligence for Short-Term Rental Investments**

O **Global Real** é um app que ajuda investidores imobiliários a **descobrir, analisar e comparar empreendimentos**, com foco em **rentabilidade, short-term rentals e localização estratégica**.

Ele combina dados de mercado, filtros inteligentes e inteligência de revenue para entregar uma análise realista e totalmente acionável.

---

## 📌 **Principais Features**

### 🔍 **Descoberta e análise**
- Busca por nome, cidade ou endereço
- Dashboard responsivo com cards informativos
- Localização via Google Maps Static API
- Filtros inteligentes por:
  - Capacidade (quartos/banheiros/hóspedes)
  - Ocupação & diárias (ADR)
  - Proximidade a metrô/aeroportos
  - Drivers de demanda do mercado

### 💰 **Inteligência Financeira**
- Cálculo de **Projected Monthly Revenue**
- Cálculo de **Occupancy-adjusted ADR**
- Taxas configuráveis (cleaning, condo, management)
- Currency-aware (BRL ↔ USD)
- Conversão automática USD → BRL

### 🌐 **Mercados suportados**
Atualmente, o app opera com o conceito de **MarketHub**:

| Hub       | Moeda | Base | Locale |
|----------|-------|------|--------|
| São Paulo | BRL   | BRL  | pt_BR  |
| Florida   | USD   | USD  | en_US  |

Cada hub possui:
- filtros padrão próprios
- moeda própria
- comportamento financeiro próprio

### 🎯 **UX & Interações**
- Cards com métricas rápidas
- Badges inteligentes (Novo / Últimas unidades)
- Favoritos com persistência no Supabase
- Dashboard desktop-first / responsivo

---

## 🏗 **Arquitetura do App**

