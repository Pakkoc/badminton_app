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

const ORDER_STATUS_TRANSITIONS: Record<string, StatusConfig> = {
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

const SHOP_STATUS_TRANSITIONS: Record<string, StatusConfig> = {
  "pending->approved": {
    type: "shop_approval",
    title: "샵 등록 승인",
    bodyTemplate:
      "샵 등록이 승인되었습니다! 사장님 모드로 전환할 수 있습니다.",
  },
  "pending->rejected": {
    type: "shop_rejection",
    title: "샵 등록 거절",
    bodyTemplate:
      "샵 등록이 거절되었습니다. 사유: {rejectReason}",
  },
};

// --- FCM v1 OAuth2 헬퍼 ---

function base64url(data: string | ArrayBuffer): string {
  const str =
    typeof data === "string"
      ? btoa(data)
      : btoa(String.fromCharCode(...new Uint8Array(data)));
  return str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function getAccessToken(
  clientEmail: string,
  privateKeyPem: string,
): Promise<string> {
  // PEM → DER
  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binaryDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64url(
    JSON.stringify({
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );

  const signingInput = new TextEncoder().encode(`${header}.${payload}`);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    signingInput,
  );

  const jwt = `${header}.${payload}.${base64url(signature)}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  if (!tokenRes.ok) {
    const err = await tokenRes.text();
    throw new Error(`OAuth2 token exchange failed: ${err}`);
  }

  const { access_token } = await tokenRes.json();
  return access_token;
}

async function sendFcmV1(
  projectId: string,
  accessToken: string,
  deviceToken: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          notification: { title, body },
          data,
          android: {
            priority: "high",
            notification: {
              channel_id: "order_status",
              sound: "default",
            },
          },
        },
      }),
    },
  );

  if (res.ok) {
    console.log("FCM v1 push sent successfully");
    return true;
  } else {
    const err = await res.text();
    console.error("FCM v1 push failed:", err);
    return false;
  }
}

// --- 메인 핸들러 ---

// --- 주문 상태 변경 처리 ---

async function handleOrderStatusChange(
  supabase: ReturnType<typeof createClient>,
  record: Record<string, unknown>,
  config: StatusConfig,
): Promise<{ userId: string; title: string; body: string; data: Record<string, string> }> {
  // 1. member → user_id
  const { data: member, error: memberError } = await supabase
    .from("members")
    .select("user_id")
    .eq("id", record.member_id)
    .single();

  if (memberError || !member) {
    throw new Error(`Member lookup failed: ${JSON.stringify(memberError)}`);
  }

  if (!member.user_id) {
    throw new Error("member has no linked user");
  }

  // shop 이름
  const { data: shop, error: shopError } = await supabase
    .from("shops")
    .select("name")
    .eq("id", record.shop_id)
    .single();

  if (shopError || !shop) {
    throw new Error(`Shop lookup failed: ${JSON.stringify(shopError)}`);
  }

  const title = config.title;
  const body = config.bodyTemplate.replace("{shopName}", shop.name);

  return {
    userId: member.user_id,
    title,
    body,
    data: { order_id: record.id as string, type: config.type },
  };
}

// --- 샵 상태 변경 처리 ---

async function handleShopStatusChange(
  record: Record<string, unknown>,
  config: StatusConfig,
): Promise<{ userId: string; title: string; body: string; data: Record<string, string> }> {
  const title = config.title;
  const body = config.bodyTemplate.replace(
    "{rejectReason}",
    (record.reject_reason as string) ?? "",
  );

  return {
    userId: record.owner_id as string,
    title,
    body,
    data: { shop_id: record.id as string, type: config.type },
  };
}

// --- 메인 핸들러 ---

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const { old_record, record, table } = payload;

    // 상태가 변경되지 않았으면 무시
    if (old_record.status === record.status) {
      return new Response(
        JSON.stringify({ message: "no status change" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const transitionKey = `${old_record.status}->${record.status}`;

    // 테이블에 따라 상태 전환 매핑 선택
    const isShop = table === "shops";
    const config = isShop
      ? SHOP_STATUS_TRANSITIONS[transitionKey]
      : ORDER_STATUS_TRANSITIONS[transitionKey];

    // 지원하지 않는 상태 변경이면 무시
    if (!config) {
      return new Response(
        JSON.stringify({
          message: `unsupported transition: ${transitionKey}`,
        }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // Supabase admin client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 테이블에 따라 알림 데이터 구성
    const { userId, title, body, data } = isShop
      ? await handleShopStatusChange(record, config)
      : await handleOrderStatusChange(supabase, record, config);

    // user → fcm_token
    const { data: user, error: userError } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("id", userId)
      .single();

    if (userError || !user) {
      console.error("User lookup failed:", userError);
      return new Response(
        JSON.stringify({ error: "user not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    // FCM v1 푸시 알림
    let fcmSuccess = false;
    if (user.fcm_token) {
      const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
      const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
      const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY");

      if (projectId && clientEmail && privateKey) {
        try {
          const accessToken = await getAccessToken(clientEmail, privateKey);
          fcmSuccess = await sendFcmV1(
            projectId,
            accessToken,
            user.fcm_token,
            title,
            body,
            data,
          );
        } catch (e) {
          console.error("FCM v1 error:", e);
        }
      } else {
        console.warn("Firebase credentials not configured");
      }
    } else {
      console.warn("User has no fcm_token");
    }

    // notifications 테이블에 알림 기록
    const notifPayload: Record<string, unknown> = {
      user_id: userId,
      type: config.type,
      title,
      body,
    };

    // 주문 관련이면 order_id 추가
    if (!isShop) {
      notifPayload.order_id = record.id as string;
    }

    const { error: notifError } = await supabase
      .from("notifications")
      .insert(notifPayload);

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
        table,
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
