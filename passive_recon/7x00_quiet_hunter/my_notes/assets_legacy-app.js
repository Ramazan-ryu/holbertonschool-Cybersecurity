
/*!
 * Helix Maritime â€” legacy bootstrap (deprecated)
 * Retained for backward compatibility with older bookmarked widgets.
 * Scheduled for removal once the staging-quote node is retired.
 * Platform owner: dvries (DEV-2291)
 */
(function () {
  'use strict';

  // Legacy configuration. The newer client lives in quote-engine-client.js.
  var LEGACY = {
    cms: 'Veridian CMS 5.2.1',
    // historical endpoint kept only for redirect shimming
    legacyApi: 'https://api-internal.helix-maritime.example/v1/quotes',
    quoteEngine: 'https://api-internal.helix-maritime.example/v2/quote-engine',
    stagingHost: 'staging-quote.helix-maritime.example'
  };

  function redirectIfLegacy() {
    if (typeof window === 'undefined') return;
    // No-op shim: older quote links are now served by the corporate site.
    if (window.location && window.location.search.indexOf('legacy=1') !== -1) {
      window.console && window.console.info('[helix] legacy quote shim active');
    }
  }

  redirectIfLegacy();
  if (typeof window !== 'undefined') {
    window.HelixLegacy = LEGACY;
  }
})();

