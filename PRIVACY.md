# Privacy policy

Last updated: October 27, 2026. Applies to Brisa Desktop 0.1.0 and later.

**In short:** Brisa has no accounts and no servers of its own, and it sends nothing to its maintainers. It connects
to the sites you visit and to the search engine you choose, and it keeps your data on your computer.

## What Brisa stores on your computer

- Bookmarks you add.
- Browsing history, if *Save browsing history* is on. It is used for address-bar suggestions. You can turn it off or clear it.
- Your open tabs, if *Restore tabs on launch* is on. Private tabs are never saved.
- Your settings, the sites where you turned tracker blocking off, and your download folder choice.
- Cookies, cache and site data kept by the browser engine for the sites you visit.

Brisa keeps its own data under `~/.local/share/Brisa` and `~/.config/Brisa`, and the engine's cache under
`~/.cache/Brisa`. Removing those folders removes everything. Downloaded files stay in the folder you chose.

Private tabs use a separate profile that is kept in memory only and discarded when Brisa quits.

## What leaves your computer

- **Requests to websites.** Opening a page contacts that site and the other servers the page loads things from
  (images, scripts, ads), except those the tracker blocker stops. Those servers see your IP address and normal
  browser details, and may set cookies. Brisa sends Do Not Track and Global Privacy Control signals unless you turn
  that off, but sites may ignore them.
- **Searches.** Text you submit in the address bar goes to the search engine you picked (Google by default).
  Suggestions as you type are computed on your computer and are not sent anywhere.
- **Downloads** come from the server that hosts the file.

## What Brisa does not do

- No analytics, crash reports, advertising or tracking of any kind inside the app.
- No accounts, no sign-in and no sync.
- No selling or sharing of data. Brisa has no data to share.
- Websites that ask for your camera, microphone or location are always refused.

## Your choices and deleting data

In Settings > Privacy and security you can clear browsing data (history, cookies and site data, cache, download
list), turn off history, change tracker blocking and manage the sites without it, and clear data when Brisa quits.
Bookmarks can be removed from the Bookmarks list.

## Children

Brisa is a general-purpose browser and is not aimed at children.

## Changes and contact

Changes to this policy appear in the repository history. For questions, open an issue on GitHub. For security
problems, use private vulnerability reporting (see SECURITY.md).
