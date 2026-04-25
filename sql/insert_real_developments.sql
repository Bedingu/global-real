-- =============================================
-- Limpar empreendimentos mock e inserir os reais
-- Dados extraídos dos CSVs da Vitacon (jan/2026)
-- =============================================

DELETE FROM public.developments WHERE hub = 'saopaulo';

INSERT INTO public.developments (
  hub, empreendimentos, "localização", data_de_entrega, tipo,
  metragem, "dormitório", bedrooms, bathrooms, max_guests,
  occupancy_rate, avg_daily_rate, cleaning_fee, condo_fee_monthly,
  management_fee_pct, listing_count, demand_drivers, localizacao_maps,
  nearest_subway_name, nearest_subway_distance_m,
  available_units, capex, price_per_m2, "yield",
  a_partir_de, "até", amenities
) VALUES
-- 1. Maestro Cardim II
(
  'saopaulo',
  'Maestro Cardim II',
  'Rua Cardim, Liberdade, São Paulo, SP',
  '2030-03-31',
  'Apartamento',
  '89,85 m²', '2', 2, 1, 4,
  1.0, 22000, 0, 0,
  0, 0, '{"Metrô Vergueiro","Liberdade","Aclimação"}',
  'Rua Cardim, Liberdade, São Paulo',
  'Vergueiro', 500,
  10, 1000000, 11130, 1.0,
  '200000', '1000000',
  '{"parking": true, "pool": true, "air_conditioning": true, "pet_friendly": false}'
),
-- 2. Vitacon Venâncio 943
(
  'saopaulo',
  'Vitacon Venâncio 943',
  'Rua Venâncio Aires, 943, Perdizes, São Paulo, SP',
  '2029-11-30',
  'Apartamento',
  '79,28 m²', '1', 1, 1, 2,
  1.0, 20000, 0, 0,
  0, 0, '{"Perdizes","Pompeia","PUC-SP"}',
  'Rua Venâncio Aires, 943, Perdizes, São Paulo',
  'Palmeiras-Barra Funda', 800,
  10, 1000000, 12614, 1.0,
  '200000', '1000000',
  '{"parking": true, "pool": true, "air_conditioning": true, "pet_friendly": false}'
),
-- 3. Senior Living Albert Einstein
(
  'saopaulo',
  'Senior Living Albert Einstein',
  'Higienópolis, São Paulo, SP',
  '2029-08-31',
  'Apartamento',
  '59,17 m²', '1', 1, 1, 2,
  1.0, 30000, 0, 0,
  0, 0, '{"Higienópolis","Albert Einstein","Mackenzie","Pacaembu"}',
  'Higienópolis, São Paulo',
  'Higienópolis-Mackenzie', 300,
  10, 1000000, 16900, 1.0,
  '200000', '1000000',
  '{"parking": true, "pool": true, "air_conditioning": true, "pet_friendly": true, "senior_living": true}'
),
-- 4. Vitacon Alameda Barros 886
(
  'saopaulo',
  'Vitacon Al Barros 886',
  'Alameda Barros, 886, Santa Cecília, São Paulo, SP',
  '2029-09-30',
  'Apartamento',
  '100,84 m²', '2', 2, 2, 4,
  1.0, 24000, 0, 0,
  0, 0, '{"Santa Cecília","Higienópolis","Consolação"}',
  'Alameda Barros, 886, Santa Cecília, São Paulo',
  'Santa Cecília', 400,
  10, 1200000, 11900, 1.0,
  '200000', '1200000',
  '{"parking": true, "pool": true, "air_conditioning": true, "pet_friendly": false}'
),
-- 5. Vitacon Nove de Julho
(
  'saopaulo',
  'Vitacon Nove de Julho',
  'Bela Vista, São Paulo, SP',
  '2030-04-30',
  'Studio',
  '18,35 m²', '1', 1, 1, 2,
  0.8, 20000, 0, 0,
  0, 0, '{"Bela Vista","Sírio-Libanês","FGV","Av. Paulista","Estação 14-Bis"}',
  'Rua Nove de Julho, Bela Vista, São Paulo',
  '14-Bis (Linha Laranja)', 100,
  10, 200000, 10900, 0.8,
  '200000', '500000',
  '{"parking": false, "pool": false, "air_conditioning": true, "pet_friendly": true, "coworking": true, "fitness": true, "podcast_studio": true, "laundry": true, "concierge": true}'
);
