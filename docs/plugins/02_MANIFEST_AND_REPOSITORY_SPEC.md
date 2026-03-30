# Manifest and Repository Spec

This is the practical schema used by SkyStream code paths.

## Plugin manifest (`plugin.json`)

Required:
- `packageName`: string

Common fields:

| Field | Type | Notes |
|---|---|---|
| `packageName` | string | Required unique plugin ID. |
| `name` | string | Display name in UI. |
| `version` | number | Used for update checks. |
| `url` | string | Source URL (set by repo/asset flow). |
| `baseUrl` | string | Recommended site root, consumed by JS via `manifest.baseUrl`. |
| `authors` | string[] | Authors list. |
| `description` | string | UI description. |
| `iconUrl` | string | Optional plugin icon. |
| `categories` / `types` / `tvTypes` | string[] | Content classes. |
| `languages` / `language` / `lang` | string[] or string | Supported languages. |
| `status` | number | 0 down, 1 ok, 2 slow, 3 beta. |
| `fileSize` | number | Optional package size. |
| `customBaseUrl` | string | Optional user override metadata. |
| `settingsSchema` | array | Saved from runtime `registerSettings`. |

Notes:
- The app accepts alias keys for language and categories.
- If `packageName` is missing for asset plugin parsing, a temporary local value can be generated.

## Repository manifest

A repository JSON should include:
- `name`
- `packageName` (or ID equivalent)
- exactly one of:
  - `pluginLists`: array of URLs returning plugin arrays
  - `repos`: array of nested repository URLs

It may also include direct inline plugins via `plugins`.

### Minimal repository example (plugin list URL)

```json
{
  "name": "Example Repo",
  "packageName": "com.example.repo",
  "pluginLists": [
    "https://example.com/plugins.json"
  ]
}
```

### Minimal inline repository example

```json
{
  "name": "Inline Repo",
  "packageName": "com.example.inline",
  "plugins": [
    {
      "packageName": "com.example.demo",
      "name": "Demo Plugin",
      "version": 1,
      "url": "https://example.com/demo.sky"
    }
  ]
}
```

## Update behavior

- Installed plugin update check is version-based: online `version > installed version`.
- Keep `packageName` stable across releases.
