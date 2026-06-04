## Attachment: INV-2026-04891.pdf

- Source email: E5 — Invoice lure (MedEquip Supplies)
- Filename: INV-2026-04891.pdf
- Content type: application/pdf
- Encoding: Base64 (multipart/mixed email attachment)

---

- Available hash evidence:
  - MD5: not available in the provided email evidence batch
  - SHA-256: visible as a truncated indicator string within the final PDF metadata block in the base64 payload (not fully expanded in raw email source)

---

- PDF producer / creator evidence:
  - wkhtmltopdf 0.12.6
  - Indicates automated HTML-to-PDF invoice generation pipeline

---

- Embedded URLs:
  - https://medequip-supplies.net/invoices/pay?id=INV-2026-04891
  - Defanged: medequip-supplies[.]net
  - Also referenced in Email 5 body as primary payment portal
  - Embedded inside PDF URI action object (/URI)

---

- Structural findings:
  - JavaScript: not proven (no script objects or JS streams visible in raw PDF metadata)
  - forms: not proven (no AcroForm structure present in encoded content)
  - embedded executable: not proven (no embedded binaries, OLE objects, or launch actions detected)
  - Attachment functions as a static PDF with clickable URI redirection only

---

- Campaign correlation:
  - The embedded URL inside the PDF is identical to the payment link in the Email 5 body, confirming direct attachment-to-email consistency
  - Email 5 is a targeted invoice pretext aimed at Accounts Payable (Angela Rivera)
  - The same campaign pattern appears in:
    - E2 (portal re-verification urgency)
    - E7 (benefits enrollment deadline pressure)
  - Shared traits across emails:
    - urgency-based deadlines
    - lookalike domains
    - credential or financial workflow targeting
    - PHPMailer-generated message structure in multiple cases
  - This confirms a coordinated phishing campaign targeting healthcare operational and financial systems

---

- Safe reputation-check commands:
  - VirusTotal URL analysis for medequip-supplies.net
  - VirusTotal file hash lookup once full SHA-256 is extracted
  - pdfid INV-2026-04891.pdf (offline structure inspection)
  - pdf-parser INV-2026-04891.pdf (object-level extraction)
  - strings INV-2026-04891.pdf (static artifact review)
  - urlscan.io submission for domain behavior analysis

---

- Risk assessment:
  HIGH — The attachment is a PDF-based invoice phishing artifact used for credential/payment diversion. Risk is confirmed by (1) embedded payment URI matching Email 5 body, (2) wkhtmltopdf-generated invoice structure, and (3) its participation in a broader coordinated phishing campaign (E2/E7) using urgency and lookalike domains to exploit healthcare workflows.
