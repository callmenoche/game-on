# Activating Universal Links / App Links

The app is code-ready for `https://` guest-claim links (see
`lib/main.dart` `_isClaimLink`) but stays on the custom
`io.supabase.gameon://claim` scheme until a real domain exists — the
placeholders below don't affect anything until then. Steps once a
domain is bought and hosted (Vercel/Netlify/GitHub Pages, all free):

0. **iOS prerequisite — paid Apple Developer Program membership.**
   Apple's free "Personal Team" signing does not support the
   Associated Domains capability at all — even an inert placeholder
   entitlement blocks local device builds (hit this directly: see git
   history around this file for the revert). The
   `com.apple.developer.associated-domains` entitlement was removed
   from `ios/Runner/Runner.entitlements` for that reason. Once
   enrolled in the paid program ($99/year — needed for App Store
   distribution anyway):
   - Re-add to `Runner.entitlements`:
     ```xml
     <key>com.apple.developer.associated-domains</key>
     <array>
       <string>applinks:REPLACE_WITH_YOUR_DOMAIN</string>
     </array>
     ```
   - **Double-check the Team ID.** The paid program is typically a
     *different* Apple Developer Team ID than the free personal team
     (`FH82LCB79J`, baked into
     `docs/well-known-templates/apple-app-site-association` today),
     even under the same Apple ID. Confirm the real one in Xcode →
     Signing & Capabilities, or developer.apple.com/account, and
     update the AASA file's `appIDs` value if it changed.

1. **Host the two verification files** at the domain root, served as
   `application/json` with no redirects:
   - `docs/well-known-templates/apple-app-site-association` →
     `https://<domain>/.well-known/apple-app-site-association`
     (no file extension)
   - `docs/well-known-templates/assetlinks.json` →
     `https://<domain>/.well-known/assetlinks.json`

2. **Get the Android SHA256 fingerprint** from Play Console (App
   integrity → App signing key certificate) once the app is uploaded
   there — Play App Signing re-signs the release build, so the
   fingerprint is Google's, not your local keystore's. Paste it into
   `assetlinks.json` in place of `REPLACE_WITH_SHA256_FROM_PLAY_CONSOLE`.

3. **Replace `REPLACE_WITH_YOUR_DOMAIN`** in three places:
   - `ios/Runner/Runner.entitlements` (`applinks:` entry)
   - `android/app/src/main/AndroidManifest.xml` (the `autoVerify`
     intent-filter's `android:host`)
   - `apple-app-site-association` is already keyed to the real Apple
     Team ID (`FH82LCB79J`) and bundle id — no change needed there.

4. **Update the share text** in
   `lib/screens/match_detail_screen.dart` (`_showShareSheet`) to use
   `https://<domain>/claim?code=...&match=...` instead of (or as well
   as) the custom-scheme link — the https link works even when the
   recipient doesn't have the app installed yet (it opens the landing
   page and can redirect to the store).

5. Rebuild and reinstall — Associated Domains / App Links are only
   re-evaluated on install, not hot reload.

No further Dart changes are needed: `_handleDeepLink` in `main.dart`
already matches both the custom scheme and the future `https` path.
