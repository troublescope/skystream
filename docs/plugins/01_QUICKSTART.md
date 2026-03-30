# Plugin Quickstart

This quickstart is for building a working SkyStream plugin with the runtime used by this app.

## 1. Minimal file layout

```text
my-plugin/
  plugin.json
  plugin.js
```

## 2. Create `plugin.json`

```json
{
  "packageName": "com.example.demo",
  "name": "Demo Plugin",
  "version": 1,
  "baseUrl": "https://example.com",
  "authors": ["YourName"],
  "description": "Demo provider",
  "categories": ["movie"],
  "languages": ["en"]
}
```

Notes:
- `packageName` is required.
- `version` should increase on updates.
- `baseUrl` should be used from `manifest.baseUrl` in JS, not hardcoded domains.

## 3. Create `plugin.js`

```javascript
(function () {
  async function getHome() {
    return {
      Trending: [
        new MultimediaItem({
          title: "Demo Item",
          url: `${manifest.baseUrl}/item/1`,
          posterUrl: `${manifest.baseUrl}/poster.jpg`,
          type: "movie"
        })
      ]
    };
  }

  async function search(query) {
    return [
      new MultimediaItem({
        title: `Result: ${query}`,
        url: `${manifest.baseUrl}/search/${encodeURIComponent(query)}`,
        posterUrl: "",
        type: "movie"
      })
    ];
  }

  async function load(url) {
    return new MultimediaItem({
      title: "Loaded Detail",
      url,
      posterUrl: "",
      type: "movie",
      description: "Detail page data"
    });
  }

  async function loadStreams(url) {
    return [
      new StreamResult({
        url: "https://example-cdn.com/video.m3u8",
        source: "CDN",
        headers: {
          Referer: manifest.baseUrl
        }
      })
    ];
  }

  globalThis.getHome = getHome;
  globalThis.search = search;
  globalThis.load = load;
  globalThis.loadStreams = loadStreams;
})();
```

## 4. Package as `.sky`

A `.sky` is a zip file containing at least:
- `plugin.json`
- `plugin.js`

The app installer reads `plugin.json` and extracts files to its plugin storage.

## 5. Install and test in app

1. Open SkyStream.
2. Go to `Settings -> Extensions`.
3. Install from repository or plugin file.
4. Run search/home/details playback paths.

## 6. Fast local dev with asset plugin (optional)

This app supports loading asset plugins for development (`assets/plugins/*.json` + matching `.js`) when dev toggle is enabled.

Use this for rapid iteration before packaging `.sky`.
