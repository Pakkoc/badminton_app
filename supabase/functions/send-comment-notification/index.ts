import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

/**
 * Webhook payload from Supabase Database Webhook (notifications INSERT).
 */
interface WebhookPayload {
  type: "INSERT";
  table: string;
  schema: string;
  record: NotificationRecord;
  old_record: null;
}

interface NotificationRecord {
  id: string;
  user_id: string;
  type: string;
  title: string;
  body: string;
  order_id: string | null;
  post_id: string | null;
  is_read: boolean;
  created_at: string;
}

// --- FCM v1 OAuth2 헬퍼 ---

function base64url(data: string | ArrayBuffer): string {
  const str =
    typeof data === "string"
      ? btoa(data)
      : btoa(String.fromCharCode(...new Uint8Array(data as ArrayBuffer)));
  return str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function getAccessToken(
  clientEmail: string,
  privateKeyPem: string,
): Promise<string> {
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
  return access_token as string;
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
              channel_id: "comment_notification",
              sound: "default",
            },
          },
        },
      }),
    },
  );

  if (res.ok) {
    console.log("FCM v1 comment push sent successfully");
    return true;
  } else {
    const err = await res.text();
    console.error("FCM v1 comment push failed:", err);
    return false;
  }
}

// --- 메인 핸들러 ---

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const { record } = payload;

    // 댓글 알림 유형만 처리
    const commentTypes = ["comment_on_post", "reply_on_comment"];
    if (!commentTypes.includes(record.type)) {
      return new Response(
        JSON.stringify({ message: "not a comment notification, skipping" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // Supabase admin client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 수신자 FCM 토큰 조회
    const { data: user, error: userError } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("id", record.user_id)
      .single();

    if (userError || !user) {
      console.error("User lookup failed:", userError);
      return new Response(
        JSON.stringify({ error: "user not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    if (!user.fcm_token) {
      console.warn(`User ${record.user_id} has no fcm_token, skipping push`);
      return new Response(
        JSON.stringify({ message: "no fcm_token, skipping" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // FCM 데이터 페이로드 구성
    const fcmData: Record<string, string> = {
      type: record.type,
      notification_id: record.id,
    };
    if (record.post_id) {
      fcmData["post_id"] = record.post_id;
    }

    // FCM v1 푸시 전송
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
    const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY");

    if (!projectId || !clientEmail || !privateKey) {
      console.warn("Firebase credentials not configured");
      return new Response(
        JSON.stringify({ error: "Firebase credentials missing" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    let fcmSuccess = false;
    try {
      const accessToken = await getAccessToken(clientEmail, privateKey);
      fcmSuccess = await sendFcmV1(
        projectId,
        accessToken,
        user.fcm_token,
        record.title,
        record.body,
        fcmData,
      );
    } catch (e) {
      console.error("FCM v1 error:", e);
    }

    return new Response(
      JSON.stringify({
        message: "comment notification processed",
        fcm_sent: fcmSuccess,
        type: record.type,
        user_id: record.user_id,
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
