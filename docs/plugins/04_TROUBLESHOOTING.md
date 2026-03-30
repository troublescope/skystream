# Plugin Troubleshooting

## Plugin installs but does not load

Checklist:
- `.sky` includes `plugin.json` at archive root.
- `.sky` includes `plugin.js`.
- `plugin.json` has valid JSON and `packageName`.

## Home/search returns empty

Checklist:
- Your function returns the correct shape (object for `getHome`, array for `search`).
- `manifest.baseUrl` is valid.
- You are handling upstream status codes and parsing failures.

## Details page fails

Checklist:
- `load(url)` returns a valid `MultimediaItem` object.
- Returned item has stable `url`.
- Optional fields are typed correctly.

## Playback fails

Checklist:
- `loadStreams(url)` returns an array.
- Each stream has a valid `url`.
- Add required request headers (for example `Referer`, `User-Agent`).
- Use `MAGIC_PROXY_*` formats when host requires sticky headers across HLS segments.

## Settings are not visible

Checklist:
- `registerSettings(schema)` is called at runtime.
- Setting IDs are stable.
- Plugin `packageName` is stable (schema is keyed to package).

## Captcha helper does not unlock site

Current runtime returns a placeholder token for `solveCaptcha` bridge in this app build. Treat it as integration API, not guaranteed real solving in all builds.

## Debug tips

- Start with hardcoded known-good item and stream, then replace step-by-step.
- Log intermediate parse outputs in JS while developing.
- Keep plugin functions small and isolate network/parsing helpers.
