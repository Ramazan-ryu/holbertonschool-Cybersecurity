# Read me first — 7x00 “The Quiet Hunter”

Welcome. This is a **passive reconnaissance and corporate-footprint** engagement
against a fictional company, **Helix Maritime Insurance**. Everything you need is
reachable from inside this lab — you do **not** need the public internet.

## Where things are

| What | Where |
|---|---|
| The company website (your main entry point) | `http://<LAB_IP>/` |
| Web terminal (ttyd) | `http://<LAB_IP>:3001/` |
| Editor (OpenVSCode) | `http://<LAB_IP>:3000/` |
| SSH | `ssh student@<LAB_IP>` (password: `student`) |
| Your working folder | `/home/student/passive_recon/7x00_quiet_hunter/` |

Replace `<LAB_IP>` with the IP address your instructor or platform gives you.

## What you are doing

Helix Maritime presents one public website, but it links out to several
**public sources** that behave like the real tools an analyst uses — a
certificate-transparency search, a passive-DNS database, a corporate registry, a
press archive, a careers board, a corporate social feed, professional profiles,
a developer platform, and a web archive of older pages.

Your job is to build an accurate picture of the company and its people **using
only what is already published** — and to do it with discipline: not every
plausible result actually belongs to Helix.

## Tools available in the lab

`exiftool`, `pdfinfo` (poppler-utils), `jq`, `curl`, `python3`, plus your browser
and the editor. Use `exiftool` / `pdfinfo` on any PDF you download from the site.

## How to work

1. Start at `http://<LAB_IP>/` and explore the site and everything it links to.
2. **View source** on pages, read the public JavaScript and text files, and
   download and inspect documents.
3. Record each thing you find **with the exact source** in the note templates in
   `source_notes_templates/` (copy them into `my_notes/`).
4. Cross-reference. A name on one source plus an email pattern from another may
   together answer a question neither answers alone.
5. Be sceptical: look-alike domains, name-twins and outdated records exist to
   test your attribution discipline.

Read `engagement_brief.md` and `passive_recon_rules.md` before you start.
