/*
===========================================================
HEALTHBANE YARA ARSENAL
Task: 10-yara_arsenal.yar
===========================================================
*/

rule HEALTHBANE_Email_Headers
{
    meta:
        author = "HEALTHBANE Detection Lab"
        description = "Detects PHPMailer-based phishing emails with healthcare/invoice/portal lure"
        date = "2026-04-14"
        reference = "HEALTHBANE campaign"
        threat_level = "high"
        confidence = "high"

    strings:
        /* PHPMailer variants (IMPORTANT: include version-specific patterns) */
        $mailer1 = "PHPMailer" nocase
        $mailer2 = "PHPMailer-" nocase
        $mailer3 = "PHPMailer 6.6.0" nocase
        $mailer4 = "PHPMailer-6.6.0" nocase

        /* Email urgency signals */
        $urgent1 = "URGENT" nocase
        $urgent2 = "FINAL NOTICE" nocase

        /* Priority header */
        $priority = "X-Priority: 1"

        /* Healthcare / business lure keywords */
        $health1 = "health" nocase
        $health2 = "benefits" nocase
        $health3 = "portal" nocase
        $health4 = "invoice" nocase

        /* Lookalike sender domains */
        $look1 = "@meddefense-" nocase
        $look2 = "@medequip-" nocase
        $look3 = "@healthcare" nocase

    condition:
        (1 of ($mailer*)) and
        $priority and
        (1 of ($urgent*)) and
        (1 of ($health*)) and
        (1 of ($look*))
}


rule HEALTHBANE_Document_Metadata
{
    meta:
        author = "HEALTHBANE Detection Lab"
        description = "Detects wkhtmltopdf phishing PDFs with credential harvesting structure"
        date = "2026-04-14"
        reference = "HEALTHBANE campaign"
        threat_level = "high"
        confidence = "high"

    strings:
        $pdf = "%PDF" nocase

        /* PDF generation tooling */
        $tool1 = "wkhtmltopdf" nocase
        $tool2 = "Invoice System" nocase

        /* Credential harvesting paths */
        $path1 = "/verify" nocase
        $path2 = "/login" nocase
        $path3 = "/portal" nocase
        $path4 = "/enroll" nocase
        $path5 = "/invoices" nocase

        /* URL parameters */
        $param1 = "token=" nocase
        $param2 = "id=" nocase

        /* lure content */
        $lure1 = "invoice" nocase
        $lure2 = "payment" nocase
        $lure3 = "staff portal" nocase

    condition:
        $pdf and
        (1 of ($tool*)) and
        (2 of ($path*)) and
        (1 of ($param*)) and
        (1 of ($lure*))
}


rule HEALTHBANE_Campaign_Composite
{
    meta:
        author = "HEALTHBANE Detection Lab"
        description = "Composite detection for multi-stage campaign behavior"
        date = "2026-04-14"
        reference = "HEALTHBANE campaign"
        threat_level = "critical"
        confidence = "high"

    strings:
        $phish1 = "verify your account" nocase
        $phish2 = "staff portal" nocase
        $phish3 = "invoice" nocase

        $mailer = "PHPMailer" nocase
        $pdf = "%PDF" nocase
        $wk = "wkhtmltopdf" nocase

        $url1 = "meddefense-" nocase
        $url2 = "medequip-" nocase
        $url3 = "/verify/" nocase
        $url4 = "/login" nocase

    condition:
        (
            (2 of ($phish*)) and
            (
                (1 of ($mailer, $wk)) or
                ($pdf and 1 of ($url*))
            )
        )
}


/*
===========================================================
TEST EXPECTATIONS

TRUE POSITIVES:
- healthbane_email_01.eml
- healthbane_email_02.eml
- phishing_sample.pdf
- healthbane_lure_02.pdf

TRUE NEGATIVES:
- benign_newsletter.eml
- clean_invoice.pdf
- benign_invoice.pdf
===========================================================
*/
