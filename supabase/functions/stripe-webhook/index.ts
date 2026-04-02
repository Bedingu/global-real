// deno-lint-ignore-file no-explicit-any
import Stripe from "npm:stripe@14.0.0";
import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY")!;
const STRIPE_WEBHOOK_SECRET = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const stripe = new Stripe(STRIPE_SECRET_KEY, { apiVersion: "2023-10-16" });
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  const body = await req.text();
  const sig = req.headers.get("stripe-signature");

  let event;

  try {
    event = stripe.webhooks.constructEvent(body, sig!, STRIPE_WEBHOOK_SECRET);
  } catch (err: any) {
    console.error("[WEBHOOK] Invalid signature:", err.message);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  console.log("🔔 Stripe Event:", event.type);

  const data = event.data.object as any;

  switch (event.type) {
    case "checkout.session.completed": {
      console.log("➡ checkout.session.completed");

      const session = data;
      const subscriptionId = session.subscription;
      const customerId = session.customer;
      const userId = session.metadata?.user_id; // <-- usamos metadata do checkout!

      if (!userId) {
        console.warn("⚠ session.metadata.user_id ausente!");
        break;
      }

      // Atualizaremos assim que o subscription.created chegar
      await supabase.from("profiles")
        .update({ stripe_customer_id: customerId })
        .eq("id", userId);

      break;
    }

    case "customer.subscription.created":
    case "customer.subscription.updated": {
      console.log(`➡ ${event.type}`);

      const subscription = data;
      const customerId = subscription.customer;
      const subscriptionId = subscription.id;
      const priceId = subscription.items.data[0].price.id;
      const status = subscription.status;

      // 🚀 Buscar user pelo customer
      const { data: userRow } = await supabase
        .from("profiles")
        .select("id")
        .eq("stripe_customer_id", customerId)
        .single();

      if (!userRow) {
        console.warn("⚠ Nenhum user encontrado para o customer:", customerId);
        break;
      }

      await supabase.from("subscriptions").upsert({
        user_id: userRow.id,
        stripe_subscription_id: subscriptionId,
        stripe_customer_id: customerId,
        stripe_price_id: priceId,
        status,
        current_period_end: subscription.current_period_end
          ? new Date(subscription.current_period_end * 1000).toISOString()
          : null,
        updated_at: new Date().toISOString(),
      });

      await supabase.from("profiles")
        .update({ subscription_status: status })
        .eq("id", userRow.id);

      break;
    }

    case "customer.subscription.deleted": {
      console.log("➡ customer.subscription.deleted");

      const subscription = data;

      await supabase.from("subscriptions")
        .update({
          status: "canceled",
          updated_at: new Date().toISOString(),
        })
        .eq("stripe_subscription_id", subscription.id);

      await supabase.from("profiles")
        .update({ subscription_status: "canceled" })
        .eq("stripe_customer_id", subscription.customer);

      break;
    }

    case "invoice.paid":
      console.log("➡ invoice.paid (renovação OK)");
      break;

    case "invoice.payment_failed":
      console.warn("➡ invoice.payment_failed (falha no pagamento)");
      break;

    default:
      console.log("➡ Evento ignorado:", event.type);
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
