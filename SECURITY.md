# Security policy

## Reporting a vulnerability

Please do not open a public issue for security problems. Use GitHub's private
[vulnerability reporting](../../security/advisories/new) for this repository and include the steps to reproduce,
the Brisa version, your distribution and the Qt version shown in Settings > About.

## Scope

Brisa renders pages with Qt WebEngine (Chromium), so engine vulnerabilities are fixed by updating Qt, not Brisa.
Reports about Brisa's own code are in scope: address-bar handling, request interception and blocking, HTTPS-first
logic, download and file handling, the page error screen, and anything that stores or sends user data.

## Design rules

- The interface is QML and never loads or mixes web content. Pages live only in the web view.
- No backend object is exposed to web pages.
- Certificate errors cannot be bypassed. Insecure content is not allowed.
- Private tabs use a separate off-the-record profile.
- No telemetry and no network access other than what the user browses or searches.
