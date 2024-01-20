export function turboFetch(url, method, body) {
    let headers = {
        'Content-Type': 'application/json',
        'Accept': "text/vnd.turbo-stream.html",
    }
    const token = document.querySelector(
      'meta[name="csrf-token"]'
    );

    if (token) {
        headers['X-CSRF-Token'] = token.textContent;
    }

    return fetch(url, {
        method: method,
        headers: headers,
        credentials: 'same-origin',
        body: JSON.stringify(body),
      })
}