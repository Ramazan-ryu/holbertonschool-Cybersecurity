# Rules of engagement — passive collection only

This engagement is **strictly passive**. You are an observer of already-published
information. The following rules are mandatory.

## Allowed
- Browsing the Helix website and every source it links to.
- Viewing page source, reading public JavaScript, CSS and text files
  (`robots.txt`, `sitemap.xml`, `humans.txt`, `security.txt`).
- Downloading published documents and inspecting their **metadata**
  (`exiftool`, `pdfinfo`).
- Reading the simulated certificate-transparency, passive-DNS, registry, press,
  careers, social, profile, developer and archive sources provided in the lab.
- Cross-referencing facts across sources and recording your reasoning.

## Not allowed
- **No port scanning** (e.g. `nmap`) of the lab or any host.
- **No service enumeration** or banner-grabbing beyond reading published pages.
- **No brute force** of logins, directories, files or parameters.
- **No endpoint exploitation**, injection, or any attempt to make a service
  behave abnormally.
- **No live DNS interrogation** of the target to “discover” records — use the
  passive sources provided. (The findings are all retrievable passively.)
- **No social engineering** of real people; everyone here is fictional anyway.

## Documentation standard
Every finding must be recorded with:
- the **exact source** (URL/route, file, or metadata field),
- the **value** you concluded,
- a one-line **justification**, and
- where relevant, the **cross-reference** that confirmed it and the
  look-alike/outdated alternative you ruled out.

If you cannot point to a source, you do not have a finding — you have a guess.

## A note on discipline
Some results are deliberately misleading: a domain that merely *looks* like
Helix’s, a person who merely *shares a name* with a Helix employee, a document
*written by an outside agency*, a developer account with *no corroboration*, and
a vendor Helix *no longer* works with. Distinguishing these is part of the
exercise. When two sources disagree, prefer the more authoritative one and write
down why.
