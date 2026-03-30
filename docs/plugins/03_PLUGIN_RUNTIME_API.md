# Plugin Runtime API Reference

This reference reflects helpers exposed by SkyStream's JS engine.

## Required plugin entry functions

Expose these functions from `plugin.js`:
- `getHome()` -> `Record<string, MultimediaItem[]>`
- `search(query)` -> `MultimediaItem[]`
- `load(url)` -> `MultimediaItem`
- `loadStreams(url)` -> `StreamResult[]`

## HTTP helpers

- `http_get(url, headers?, cb?)`
- `http_post(url, headers?, body?, cb?)`

These return objects containing:
- `status` / `statusCode`
- `body`
- `headers`

## Storage and settings helpers

- `getPreference(key)`
- `setPreference(key, value)`
- `registerSettings(schema)`

`registerSettings(schema)` persists settings schema for plugin UI.

## SDK helpers

- `solveCaptcha(siteKey, url?)` -> Promise<string>
- `crypto.decryptAES(data, key, iv)` -> Promise<string>

## DOM helpers

- `parseHtml(html)` -> Promise<Document-like object>
- `new JSDOM(html)` + `await dom.waitForInit()`
- Node methods: `querySelector`, `querySelectorAll`, `getAttribute`, `textContent`, `innerHTML`

## Timer helpers

- `setTimeout`, `clearTimeout`
- `setInterval`, `clearInterval`

## Built-in classes

- `MultimediaItem`
- `Episode`
- `StreamResult`
- `Actor`
- `Trailer`
- `NextAiring`

## Stream URL special formats

In `loadStreams`, `url` supports special schemes:

- `magic_m3u8:<base64 m3u8 text>`
- `MAGIC_PROXY_v1<base64 real_url>`
- `MAGIC_PROXY:<base64 real_url>`
- `MAGIC_PROXY_v2<base64 json config>`

The app converts them to local proxy URLs for playback/header injection.

## Example: fetch + parse + stream

```javascript
async function loadStreams(url) {
  const res = await http_get(url, { Referer: manifest.baseUrl });
  const doc = await parseHtml(res.body || String(res));
  const src = doc.querySelector("video source")?.getAttribute("src");

  if (!src) return [];

  return [
    new StreamResult({
      url: src.startsWith("http") ? src : new URL(src, manifest.baseUrl).toString(),
      source: "Auto",
      headers: { Referer: manifest.baseUrl }
    })
  ];
}
```
