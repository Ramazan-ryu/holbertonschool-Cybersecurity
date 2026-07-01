# Engagement brief — Helix Maritime Insurance

**Classification:** Training engagement (fictional target)
**Module:** `passive_recon`
**Deliverable repository path:** `passive_recon/7x00_quiet_hunter`

## Scenario

You have been engaged to produce a **passive footprint assessment** of Helix
Maritime Insurance, a specialist marine insurer headquartered in Rotterdam. Your
client wants to understand what an outside observer can learn about the company,
its technology and its people **without ever touching their systems intrusively**
— purely from published, observable sources.

Helix is fictional and every identifier in this lab (domains, IPs, people, phone
numbers, documents) is reserved for training. The documentation-safe domain is
`helix-maritime.example` and addresses fall in `198.51.100.0/24` and
`203.0.113.0/24`.

## Your objectives

Work through the ten collection areas below. Each area asks you to recover a
small number of concrete facts. Record every fact with the **exact source** you
found it in, and note where you had to **combine two or more sources** to reach
a conclusion.

1. **DNS & subdomains** — forgotten/legacy hosts, mail infrastructure, and what
   the domain’s mail records reveal about third-party services.
2. **Website source archaeology** — what the page source, public scripts and
   response headers disclose about how the site is built and maintained.
3. **Document metadata** — what the published PDFs carry in their metadata.
4. **Web archive** — how the company looked before, and what changed.
5. **Press & communications** — what executives and communiqués mention in passing.
6. **Corporate registry** — the authoritative legal record of the company.
7. **Job postings** — what hiring tells you about internal technology and people.
8. **Corporate social** — what the brand’s own feed and photos give away.
9. **Employee profiles** — triangulating identities across several platforms.
10. **Technology synthesis** — conclusions that only hold up when several earlier
    sources agree.

## Output

For each area, complete the matching note template in
`source_notes_templates/`. A good submission states **what** you concluded,
**where** the evidence is, and **why** you trust it over any look-alike or
outdated alternative.

## Rules

See `passive_recon_rules.md`. In short: **observe, do not interact intrusively.**
