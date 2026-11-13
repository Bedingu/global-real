// Módulo compartilhado: envio de push (FCM V1) para todos os dispositivos
// registrados na tabela push_tokens.
//
// Usa os secrets FCM_PRIVATE_KEY (já configurado no projeto).

const FCM_CLIENT_EMAIL = "firebase-adminsdk-fbsvc@globalreal-app.iam.gserviceaccount.com";
const FCM_PROJECT_ID = "globalreal-app";

function b64url(input: string): string {
  return btoa(input).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

// Gera um access token OAuth2 do Google a partir da service account.
async function getAccessToken(privateKeyPem: string): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000);
    const header = { alg: "RS256", typ: "JWT" };
    const payload = {
      iss: FCM_CLIENT_EMAIL,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    };

    const signInput = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;

    const pemContent = privateKeyPem
      .replace(/\\n/g, "\n")
      .replace(/-----BEGIN PRIVATE KEY-----/, "")
      .replace(/-----END PRIVATE KEY-----/, "")
      .replace(/\s/g, "");
    const binaryKey = Uint8Array.from(atob(pemContent), (c) => c.charCodeAt(0));

    const key = await crypto.subtle.importKey(
      "pkcs8",
      binaryKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"],
    );

    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      new TextEncoder().encode(signInput),
    );
    const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

    const res = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signInput}.${sigB64}`,
    });
    const data = await res.json();
    if (!data.access_token) {
      console.error("❌ FCM: não obteve access token:", data);
    }
    return data.access_token || null;
  } catch (e) {
    console.error("❌ FCM: erro ao gerar access token:", e);
    return null;
  }
}

export interface PushResult {
  tokens: number;
  sent: number;
  failed: number;
  error?: string;
}

// deno-lint-ignore no-explicit-any
export async function sendPushToAll(supabase: any, title: string, body: string): Promise<PushResult> {
  const result: PushResult = { tokens: 0, sent: 0, failed: 0 };
  try {
    const privateKey = Deno.env.get("FCM_PRIVATE_KEY") || "";
    if (!privateKey) {
      result.error = "FCM_PRIVATE_KEY não configurado";
      return result;
    }

    const accessToken = await getAccessToken(privateKey);
    if (!accessToken) {
      result.error = "não foi possível autenticar no FCM";
      return result;
    }

    const { data: tokens } = await supabase.from("push_tokens").select("token");
    result.tokens = tokens?.length ?? 0;
    if (!tokens || tokens.length === 0) {
      result.error = "nenhum token registrado em push_tokens";
      return result;
    }

    for (const { token } of tokens) {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body },
              data: { route: "/leads", type: "new_lead" },
            },
          }),
        },
      );
      if (res.ok) {
        result.sent++;
      } else {
        result.failed++;
        console.error("❌ FCM: falha ao enviar:", res.status, await res.text());
      }
    }
    return result;
  } catch (e) {
    console.error("❌ FCM: erro ao enviar push:", e);
    result.error = String(e);
    return result;
  }
}
