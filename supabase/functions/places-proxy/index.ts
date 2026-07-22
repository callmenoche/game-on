// Proxies Google Places/Geocoding REST calls server-side.
//
// Google's legacy Places API (maps.googleapis.com/maps/api/place/*, /geocode/*)
// never returns Access-Control-Allow-Origin headers, so it can't be called
// directly from a browser (Flutter web). It also rejects HTTP-referrer-restricted
// keys outright. Routing through this function sidesteps both issues: the key
// lives only as a server-side secret (GOOGLE_PLACES_SERVER_KEY, unrestricted —
// safe since it's never shipped to any client) and this function sets its own
// CORS headers on the response.

const GOOGLE_BASE = 'https://maps.googleapis.com/maps/api'

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  const key = Deno.env.get('GOOGLE_PLACES_SERVER_KEY')
  if (!key) {
    return new Response(JSON.stringify({ error: 'missing GOOGLE_PLACES_SERVER_KEY' }), {
      status: 500,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    })
  }

  const url = new URL(req.url)
  const action = url.searchParams.get('action')

  let googleUrl: string
  switch (action) {
    case 'autocomplete': {
      const input = url.searchParams.get('input') ?? ''
      const sessiontoken = url.searchParams.get('sessiontoken') ?? ''
      const params = new URLSearchParams({ input, sessiontoken, key })
      googleUrl = `${GOOGLE_BASE}/place/autocomplete/json?${params}`
      break
    }
    case 'details': {
      const placeId = url.searchParams.get('place_id') ?? ''
      const sessiontoken = url.searchParams.get('sessiontoken') ?? ''
      const params = new URLSearchParams({
        place_id: placeId,
        fields: 'name,geometry',
        sessiontoken,
        key,
      })
      googleUrl = `${GOOGLE_BASE}/place/details/json?${params}`
      break
    }
    case 'geocode': {
      const latlng = url.searchParams.get('latlng') ?? ''
      const params = new URLSearchParams({ latlng, key })
      googleUrl = `${GOOGLE_BASE}/geocode/json?${params}`
      break
    }
    default:
      return new Response(JSON.stringify({ error: 'unknown action' }), {
        status: 400,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      })
  }

  const res = await fetch(googleUrl)
  const body = await res.text()
  return new Response(body, {
    status: res.status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  })
})
