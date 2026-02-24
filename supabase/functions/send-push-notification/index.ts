import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface WebhookPayload {
  type: "UPDATE";
  table: string;
  schema: string;
  record: Record<string, unknown>;
  old_record: Record<string, unknown>;
}

interface StatusConfig {
  type: string;
  title: string;
  bodyTemplate: string;
}

const STATUS_TRANSITIONS: Record<string, StatusConfig> = {
  "received->in_progress": {
    type: "status_change",
    title: "작업 시작",
    bodyTemplate: "{shopName}에서 거트 작업이 시작되었습니다",
  },
  "in_progress->completed": {
    type: "completion",
    title: "작업 완료",
    bodyTemplate: "{shopName}에서 거트 작업이 완료되었습니다",
  },
};

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const { old_record, record } = payload;

    // 상태가 변경되지 않았으면 무시
    if (old_record.status === record.status) {
      return new Response(
        JSON.stringify({ message: "no status change" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const transitionKey = `${old_record.status}->${record.status}`;
    const config = STATUS_TRANSITIONS[transitionKey];

    // 지원하지 않는 상태 변경이면 무시
    if (!config) {
      return new Response(
        JSON.stringify({ message: `unsupported transition: ${transitionKey}` }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // Supabase admin client (service_role key)
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 1. member → user_id 조회
    const { data: member, error: memberError } = await supabase
      .from("members")
      .select("user_id")
      .eq("id", record.member_id)
      .single();

    if (memberError || !member) {
      console.error("Member lookup failed:", memberError);
      return new Response(
        JSON.stringify({ error: "member not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    // member에 user_id가 연결되어 있지 않으면 푸시 불가
    if (!member.user_id) {
      return new Response(
        JSON.stringify({ message: "member has no linked user" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // 2. user → fcm_token 조회
    const { data: user, error: userError } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("id", member.user_id)
      .single();

    if (userError || !user) {
      console.error("User lookup failed:", userError);
      return new Response(
        JSON.stringify({ error: "user not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    // 3. shop 이름 조회
    const { data: shop, error: shopError } = await supabase
      .from("shops")
      .select("name")
      .eq("id", record.shop_id)
      .single();

    if (shopError || !shop) {
      console.error("Shop lookup failed:", shopError);
      return new Response(
        JSON.stringify({ error: "shop not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    const title = config.title;
    const body = config.bodyTemplate.replace("{shopName}", shop.name);

    // 4. FCM 푸시 알림 전송
    let fcmSuccess = false;
    if (user.fcm_token) {
      const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
      if (fcmServerKey) {
        const fcmResponse = await fetch(
          "https://fcm.googleapis.com/fcm/send",
          {
            method: "POST",
            headers: {
              "Authorization": `key=${fcmServerKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              to: user.fcm_token,
              notification: { title, body },
              data: {
                order_id: record.id as string,
                type: config.type,
              },
            }),
          },
        );

        if (fcmResponse.ok) {
          fcmSuccess = true;
          console.log("FCM push sent successfully");
        } else {
          const fcmError = await fcmResponse.text();
          console.error("FCM push failed:", fcmError);
        }
      } else {
        console.warn("FCM_SERVER_KEY not configured");
      }
    } else {
      console.warn("User has no fcm_token");
    }

    // 5. notifications 테이블에 알림 기록 INSERT
    const { error: notifError } = await supabase
      .from("notifications")
      .insert({
        user_id: member.user_id,
        type: config.type,
        title,
        body,
        order_id: record.id as string,
      });

    if (notifError) {
      console.error("Notification insert failed:", notifError);
      return new Response(
        JSON.stringify({ error: "notification insert failed" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({
        message: "notification processed",
        fcm_sent: fcmSuccess,
        transition: transitionKey,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "internal server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
