/// POST /functions/v1/create_post
/// Body:
/// {
///   title?: string,
///   subtitle?: string,
///   description?: string,
///   cluster_id?: string | null,
///   media: Array<{ type: "image"|"video", mime: string, ext: string, base64: string }>
/// }
///
/// Flow:
/// 1) insert public.posts (user_id = auth.uid())
/// 2) upload each media to Storage bucket `post_media` at: posts/{post_id}/{media_id}.{ext}
/// 3) insert public.post_media rows with url (public URL), type, sort_order
/// <reference path="../deno.d.ts" />
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { requireSupabaseUser } from "../_shared/supabase.ts";

function badRequest(message: string) {
  return new Response(JSON.stringify({ error: message }), {
    status: 400,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function jsonOk(data: unknown) {
  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function toBytes(base64: string): Uint8Array {
  const cleaned = base64.includes(",") ? base64.split(",").pop()! : base64;
  const bin = atob(cleaned);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  try {
    if (req.method !== "POST") {
      return new Response("Method not allowed", { status: 405, headers: corsHeaders });
    }

    const authCtx = await requireSupabaseUser(req);
    if (!authCtx.ok) {
      return new Response(authCtx.body, {
        status: authCtx.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const { supabase, user } = authCtx;

    const body = await req.json().catch(() => null);
    if (!body || typeof body !== "object") return badRequest("Invalid JSON body");

    const title = typeof (body as any).title === "string" ? (body as any).title : null;
    const subtitle = typeof (body as any).subtitle === "string" ? (body as any).subtitle : null;
    const description =
      typeof (body as any).description === "string" ? (body as any).description : null;
    const cluster_id =
      (body as any).cluster_id === null || typeof (body as any).cluster_id === "string"
        ? (body as any).cluster_id
        : undefined;

    const media = Array.isArray((body as any).media) ? (body as any).media : null;
    if (!media || media.length === 0) return badRequest("media[] is required");
    if (media.length > 10) return badRequest("Too many media items (max 10)");

    // 1) create post row
    const { data: postRow, error: postErr } = await supabase
      .from("posts")
      .insert({
        user_id: user.id,
        title,
        subtitle,
        description,
        cluster_id: cluster_id === undefined ? null : cluster_id,
      })
      .select("id")
      .single();

    if (postErr || !postRow?.id) {
      return badRequest(postErr?.message ?? "Failed to create post");
    }

    const postId = postRow.id as string;
    const uploaded: Array<{ id: string; path: string; url: string; type: string; sort_order: number }> =
      [];

    // 2) upload media
    for (let i = 0; i < media.length; i++) {
      const m = media[i] ?? {};
      const type = String(m.type ?? "").trim();
      const mime = String(m.mime ?? "").trim();
      const extRaw = String(m.ext ?? "").trim().toLowerCase();
      const ext = extRaw.replace(/[^a-z0-9]/g, "");
      const base64 = String(m.base64 ?? "");

      if (type !== "image" && type !== "video") return badRequest(`media[${i}].type invalid`);
      if (!mime) return badRequest(`media[${i}].mime required`);
      if (!ext) return badRequest(`media[${i}].ext required`);
      if (!base64) return badRequest(`media[${i}].base64 required`);

      const mediaId = crypto.randomUUID();
      const path = `posts/${postId}/${mediaId}.${ext}`;
      const bytes = toBytes(base64);

      const { error: upErr } = await supabase.storage
        .from("post_media")
        .upload(path, bytes, { contentType: mime, upsert: true });

      if (upErr) {
        return badRequest(`upload failed: ${upErr.message}`);
      }

      const { data: pub } = supabase.storage.from("post_media").getPublicUrl(path);
      uploaded.push({ id: mediaId, path, url: pub.publicUrl, type, sort_order: i });
    }

    // 3) insert post_media rows
    const { error: pmErr } = await supabase.from("post_media").insert(
      uploaded.map((u) => ({
        post_id: postId,
        url: u.url,
        type: u.type,
        sort_order: u.sort_order,
      })),
    );
    if (pmErr) {
      return badRequest(pmErr.message);
    }

    return jsonOk({
      ok: true,
      post_id: postId,
      media: uploaded.map((u) => ({ url: u.url, type: u.type, sort_order: u.sort_order })),
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

