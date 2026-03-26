import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const code = url.searchParams.get('code') ?? ''
  const matchId = url.searchParams.get('match') ?? ''

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!
  )
  const { data: match } = await supabase
    .from('matches')
    .select('sport_type, location_name, date_time')
    .eq('id', matchId)
    .single()

  const deepLink = `io.supabase.gameon://claim?code=${code}&match=${matchId}`
  const appStore = 'https://apps.apple.com/app/idXXXXXXXXX'   // TODO: fill in
  const playStore = 'https://play.google.com/store/apps/details?id=com.gameon.app' // TODO

  const sportLabel = match?.sport_type ?? 'a match'
  const location = match?.location_name ?? ''
  const dateStr = match?.date_time
    ? new Date(match.date_time).toLocaleDateString(undefined, {
        weekday: 'short',
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
      })
    : ''

  const html = /* html */`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Join GameOn Match</title>
  <style>
    body { font-family: -apple-system, sans-serif; background: #0F1923; color: #fff;
           display: flex; flex-direction: column; align-items: center; justify-content: center;
           min-height: 100vh; margin: 0; padding: 24px; box-sizing: border-box; text-align: center; }
    h2 { font-size: 24px; margin-bottom: 4px; }
    .meta { opacity: .6; font-size: 15px; margin-bottom: 32px; }
    .btn { display: block; width: 100%; max-width: 320px; padding: 16px;
           border-radius: 12px; font-weight: 700; font-size: 16px; text-decoration: none;
           margin-bottom: 12px; cursor: pointer; border: none; }
    .primary { background: #FDBA30; color: #0F1923; }
    .secondary { background: rgba(255,255,255,.1); color: #fff; }
    .code { font-size: 28px; letter-spacing: 6px; font-weight: 900; color: #FDBA30;
            background: rgba(253,186,48,.1); border-radius: 12px; padding: 16px 24px;
            margin: 16px 0; }
    .hint { opacity: .45; font-size: 13px; }
    #no-app { display: none; margin-top: 32px; width: 100%; align-items: center; flex-direction: column; }
  </style>
  <script>
    function openApp() {
      window.location.href = "${deepLink}";
      // If the app didn't open within 1.5 s, show the store fallback
      setTimeout(function() {
        document.getElementById('no-app').style.display = 'flex';
      }, 1500);
    }
  </script>
</head>
<body>
  <h2>&#x1F3AE; You're invited!</h2>
  <p class="meta">${sportLabel}${location ? ' &middot; ' + location : ''}${dateStr ? ' &middot; ' + dateStr : ''}</p>
  <button class="btn primary" onclick="openApp()">Open in GameOn</button>
  <div id="no-app">
    <p>Don't have the app yet?</p>
    <a class="btn primary" href="${appStore}">&#x1F4F1; App Store</a>
    <a class="btn secondary" href="${playStore}">&#x25B6; Google Play</a>
    <p class="hint" style="margin-top:24px">Already installed? Open the app and enter:</p>
    <div class="code">${code}</div>
    <p class="hint">Go to the match &rarr; tap Claim &rarr; paste this code</p>
  </div>
</body>
</html>`

  return new Response(html, {
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  })
})
