export function turboFetch (url, method, body) {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'text/vnd.turbo-stream.html'
  }
  const token = document.querySelector(
    'meta[name="csrf-token"]'
  )

  if (token) {
    headers['X-CSRF-Token'] = token.getAttribute('content')
  }

  return fetch(url, {
    method,
    headers,
    credentials: 'same-origin',
    body: JSON.stringify(body)
  })
}
