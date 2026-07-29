// Supabase Edge Function: meta-leads-webhook
// Recebe leads do Meta Lead Ads e insere na tabela market_leads
//
// Deploy: supabase functions deploy meta-leads-webhook
// URL: https://pcbwbndrnnqptxdbrqnm.supabase.co/functions/v1/meta-leads-webhook
//
// Configurar no Meta Business:
// 1. Business Settings → Integrations → Leads Access
// 2. Ou via Webhooks: Page → Settings → Webhooks → leadgen

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

// Token de verificação (definir em supabase secrets)
const VERIFY_TOKEN = Deno.env.get('META_VERIFY_TOKEN') || 'globalreal_meta_2026'
const META_ACCESS_TOKEN = Deno.env.get('META_ACCESS_TOKEN') || ''

serve(async (req) => {
  // GET = verificação do webhook pelo Meta
  if (req.method === 'GET') {
    const url = new URL(req.url)
    const mode = url.searchParams.get('hub.mode')
    const token = url.searchParams.get('hub.verify_token')
    const challenge = url.searchParams.get('hub.challenge')

    if (mode === 'subscribe' && token === VERIFY_TOKEN) {
      return new Response(challenge, { status: 200 })
    }
    return new Response('Forbidden', { status: 403 })
  }

  // POST = novo lead recebido
  if (req.method === 'POST') {
    try {
      const body = await req.json()

      // Meta envia um array de entries
      const entries = body.entry || []
      
      for (const entry of entries) {
        const changes = entry.changes || []
        
        for (const change of changes) {
          if (change.field === 'leadgen') {
            const leadgenId = change.value?.leadgen_id
            const formId = change.value?.form_id
            const pageId = change.value?.page_id

            if (leadgenId) {
              // Buscar dados completos do lead na Graph API
              const leadData = await fetchLeadData(leadgenId)
              
              if (leadData) {
                // Inserir na tabela market_leads
                await supabase.from('market_leads').insert({
                  name: leadData.name || 'Lead Meta',
                  email: leadData.email || '',
                  phone: leadData.phone || '',
                  market: 'sao_paulo',
                  interest: leadData.interest || 'Investimento imobiliário',
                  company: leadData.company || '',
                  status: 'new',
                  notes: `Origem: Meta Lead Ads | Form: ${formId} | Page: ${pageId}`,
                  ai_score: 0,
                  ai_summary: 'Lead captado via Meta Ads - aguardando qualificação',
                })

                // Enviar push notification para todos os assessores
                await sendPushToAll(leadData.name || 'Novo lead', leadData.interest || 'Meta Ads')

                console.log(`✅ Lead inserido: ${leadData.name}`)
              }
            }
          }
        }
      }

      return new Response(JSON.stringify({ received: true }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      })
    } catch (error) {
      console.error('❌ Erro ao processar webhook:', error)
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })
    }
  }

  return new Response('Method not allowed', { status: 405 })
})

// Buscar dados do lead na Graph API do Meta
async function fetchLeadData(leadgenId: string) {
  if (!META_ACCESS_TOKEN) {
    console.warn('⚠️ META_ACCESS_TOKEN não configurado, usando dados do webhook')
    return null
  }

  try {
    const response = await fetch(
      `https://graph.facebook.com/v18.0/${leadgenId}?access_token=${META_ACCESS_TOKEN}`
    )
    const data = await response.json()

    if (data.field_data) {
      const fields: Record<string, string> = {}
      for (const field of data.field_data) {
        fields[field.name] = field.values?.[0] || ''
      }

      return {
        name: fields['full_name'] || fields['first_name'] || '',
        email: fields['email'] || '',
        phone: fields['phone_number'] || fields['phone'] || '',
        interest: fields['interest'] || fields['what_are_you_looking_for'] || '',
        company: fields['company_name'] || fields['company'] || '',
      }
    }

    return null
  } catch (error) {
    console.error('Erro ao buscar lead data:', error)
    return null
  }
}


// Enviar push notification para todos os assessores com token registrado
// Usa FCM V1 API com Service Account
async function sendPushToAll(leadName: string, interest: string) {
  try {
    const FCM_PRIVATE_KEY = Deno.env.get('FCM_PRIVATE_KEY') || ''
    if (!FCM_PRIVATE_KEY) {
      console.warn('⚠️ FCM_PRIVATE_KEY não configurado')
      return
    }

    const FCM_CLIENT_EMAIL = 'firebase-adminsdk-fbsvc@globalreal-app.iam.gserviceaccount.com'
    const FCM_PROJECT_ID = 'globalreal-app'

    // Gerar JWT para autenticação
    const accessToken = await getAccessToken(FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY)
    if (!accessToken) {
      console.warn('⚠️ Não foi possível gerar access token')
      return
    }

    // Buscar todos os tokens de push
    const { data: tokens } = await supabase
      .from('push_tokens')
      .select('token')

    if (!tokens || tokens.length === 0) {
      console.log('📲 Nenhum token de push registrado')
      return
    }

    // Enviar para cada token via FCM V1
    for (const { token } of tokens) {
      await fetch(`https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title: '🔥 Novo lead: ' + leadName,
              body: interest,
            },
            data: {
              route: '/leads',
              type: 'new_lead',
            },
          },
        }),
      })
    }

    console.log(`📲 Push enviado para ${tokens.length} dispositivos`)
  } catch (error) {
    console.error('❌ Erro ao enviar push:', error)
  }
}

// Gerar OAuth2 access token usando JWT com Service Account
async function getAccessToken(clientEmail: string, privateKeyPem: string): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000)
    const header = { alg: 'RS256', typ: 'JWT' }
    const payload = {
      iss: clientEmail,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    }

    const encoder = new TextEncoder()
    const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
    const payloadB64 = btoa(JSON.stringify(payload)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
    const signInput = `${headerB64}.${payloadB64}`

    // Importar chave privada
    const pemContent = privateKeyPem.replace(/\\n/g, '\n').replace(/-----BEGIN PRIVATE KEY-----/, '').replace(/-----END PRIVATE KEY-----/, '').replace(/\s/g, '')
    const binaryKey = Uint8Array.from(atob(pemContent), c => c.charCodeAt(0))

    const key = await crypto.subtle.importKey(
      'pkcs8',
      binaryKey,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['sign']
    )

    const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, encoder.encode(signInput))
    const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

    const jwt = `${signInput}.${signatureB64}`

    // Trocar JWT por access token
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    })

    const data = await response.json()
    return data.access_token || null
  } catch (error) {
    console.error('❌ Erro ao gerar access token:', error)
    return null
  }
}
