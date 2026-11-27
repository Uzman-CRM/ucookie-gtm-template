# UCookie CMP - Google Tag Manager template

Tag template for the [UCookie](https://ucookie.com.tr) cookie consent platform (CMP). It integrates the UCookie banner with Google Consent Mode v2 inside Google Tag Manager (web containers).

## What it does

On every page the tag:

1. Sets the Consent Mode **default** state: `ad_storage`, `ad_user_data`, `ad_personalization`, `analytics_storage`, `functionality_storage` and `personalization_storage` are `denied`; `security_storage` is `granted`. `wait_for_update` is applied (default 500 ms).
2. Optionally sets **region-specific defaults** (one `setDefaultConsentState` call per table row).
3. Sets `ads_data_redaction` and `url_passthrough` as configured.
4. For a **returning visitor**, reads the last decision UCookie stored in `localStorage` (key `ucookie`), validates it (not expired, category data present) and calls `updateConsentState` immediately. A missing or malformed value is ignored silently and the defaults stay.
5. Sets `window.__ucookieGtm = true` so the widget knows the template owns the default state and does not push its own, then loads the widget script.

After the visitor makes a choice, the widget itself sends the Consent Mode `update` (and repeats it on each page load with a valid stored consent). GTM honours those updates.

Category to signal mapping:

| UCookie category tag | Consent Mode signals |
| --- | --- |
| `targeting` | `ad_storage`, `ad_user_data`, `ad_personalization` |
| `tracking` | `analytics_storage` |
| `functionality` | `functionality_storage`, `personalization_storage` |
| always | `security_storage` granted |

## Fields

| Field | Description |
| --- | --- |
| Widget script URL | Default `https://fe.v2.ucookie.com.tr/ucookie.js`. Must be https on `ucookie.com.tr`. The site is resolved from the page origin; no site id is needed. |
| wait_for_update (ms) | Time Google tags wait for a consent update. Default 500. |
| Redact ads data | Sets `ads_data_redaction` (applied while ad_storage is denied). Default on. |
| Pass through ad click info in URLs | Sets `url_passthrough`. Default off. |
| Region-specific defaults | Optional table: comma separated region codes (for example `US-CA,TR`) plus granted/denied per signal. |

## Install

1. In your web container go to **Templates > Tag Templates > Search Gallery** and add **UCookie CMP** (or import `template.tpl` through the template editor menu).
2. Go to **Tags > New**, choose the **UCookie CMP** tag type and adjust the fields if needed.
3. Set the trigger to **Consent Initialization - All Pages**. This is required so the default state is set before any other tag fires.
4. Save, preview and publish.

Do **not** also paste the inline UCookie bootstrap snippet into the page. The template loads the widget itself; having both would load it twice.

## Basic vs Advanced Consent Mode

- **Advanced mode:** leave your Google tags (GA4, Google Ads, Floodlight) as they are. They load immediately and respect the consent state; while consent is denied they send cookieless pings, and send full data after the visitor grants consent.
- **Basic mode:** open each Google tag, go to **Advanced Settings > Consent Settings** and choose **Require additional consent for tag to fire**. Add `ad_storage` (Google Ads, Floodlight) and/or `analytics_storage` (GA4). The tags then do not fire at all until consent is granted.

Non-Google tags should use the same Consent Settings so they respect the visitor's choice.

## Permissions

The template requests access to: the seven Consent Mode types (read and write), `ads_data_redaction`, `url_passthrough` and `developer_id.*` data layer keys, injecting scripts from `https://fe.v2.ucookie.com.tr/*` and `https://*.ucookie.com.tr/*`, the global `__ucookieGtm` (read and write; `setInWindow` needs both), local storage key `ucookie` (read) and debug logging.

## Submitting to the Community Template Gallery

1. Copy the contents of this folder (`template.tpl`, `metadata.yaml`, `LICENSE`, `README.md`) to the **root** of a public GitHub repository.
2. Edit `metadata.yaml`: set `homepage` and `documentation` to real URLs.
3. Commit and push. Copy the full **commit sha** of that commit (`git rev-parse HEAD`).
4. Put that sha in `metadata.yaml` under `versions[0].sha`. The sha must point to a commit that contains the final `template.tpl`. Commit and push again; because the sha refers to the earlier commit, use the sha of the commit that last changed `template.tpl`, not the one that edits `metadata.yaml`.
5. Open the [Community Template Gallery](https://tagmanager.google.com/gallery/) and submit the repository through the gallery's **Submit a template** flow (or by pull request to the gallery repository, as described in Google's documentation at <https://developers.google.com/tag-platform/tag-manager/templates/gallery>).
6. To release an update: change `template.tpl`, push, then add a new entry at the top of `versions` with the new commit sha and `changeNotes`.

## License

Apache License 2.0. See [LICENSE](LICENSE).
