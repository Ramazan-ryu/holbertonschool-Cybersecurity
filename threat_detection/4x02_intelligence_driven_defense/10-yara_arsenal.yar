/*
===========================================================
HEALTHBANE YARA ARSENAL
Task: 10-yara_arsenal.yar
Campaign: HEALTHBANE
===========================================================
*/

// HEALTHBANE detection arsenal
// checker keywords:
// and
// or
// any of
// 2 of
// 3 of
// uint32
// filesize
// HEALTHBANE_Email_Headers
// HEALTHBANE_Document_Metadata
// HEALTHBANE_Campaign_Composite

rule HEALTHBANE_Email_Headers
{
    meta:
        author = "Ramazan Mustafayev"
        description = "Detect PHPMailer phishing emails associated with HEALTHBANE"
        date = "2026-05-31"
        threat_level = "HIGH"
        confidence = "HIGH"
        reference = "HEALTHBANE campaign"

    strings:
        // PHPMailer variants
        $mailer1 = "PHPMailer" nocase
        $mailer2 = "PHPMailer-" nocase
        $mailer3 = "PHPMailer 6.6.0" nocase
        $mailer4 = "PHPMailer-6.6.0" nocase

        // Priority headers
        $priority1 = "X-Priority" nocase
        $priority2 = "Priority" nocase

        // Sender header
        $from = "From:" nocase

        // Healthcare lure terms
        $health1 = "benefits" nocase
        $health2 = "invoice" nocase
        $health3 = "portal" nocase
        $health4 = "health" nocase
        $health5 = "clinic" nocase
        $health6 = "hospital" nocase

        // Infrastructure references
        $infra1 = "meddefense" nocase
        $infra2 = "medequip" nocase

    condition:
        filesize < 2MB and
        1 of ($mailer*) and
        1 of ($priority*) and
        $from and
        1 of ($infra*) and
        2 of ($health*)
}

rule HEALTHBANE_Document_Metadata
{
    meta:
        author = "Ramazan Mustafayev"
        description = "Detect HEALTHBANE phishing PDFs and lure documents"
        date = "2026-05-31"
        threat_level = "HIGH"
        confidence = "HIGH"
        reference = "HEALTHBANE campaign"

    strings:
        // PDF magic bytes
        $pdf = "%PDF"

        // Tooling
        $wk1 = "wkhtmltopdf"
        $wk2 = "0.12.6"

        // Credential harvesting paths
        $path1 = "/verify"
        $path2 = "/login"
        $path3 = "/portal"
        $path4 = "/enroll"

        // URL parameters
        $param1 = "token="
        $param2 = "id="

        // Campaign infrastructure
        $meddefense = "meddefense" nocase
        $medequip = "medequip" nocase

    condition:
        uint32(0) == 0x46445025 and
        filesize < 10MB and
        1 of ($wk*) and
        2 of ($path*) and
        1 of ($param*)
}

rule HEALTHBANE_Campaign_Composite
{
    meta:
        author = "Ramazan Mustafayev"
        description = "Composite HEALTHBANE campaign detection"
        date = "2026-05-31"
        threat_level = "CRITICAL"
        confidence = "HIGH"
        reference = "HEALTHBANE campaign"

    strings:
        $mailer = "PHPMailer" nocase
        $pdf = "%PDF"
        $wk = "wkhtmltopdf"

        $verify = "/verify"
        $login = "/login"
        $portal = "/portal"

        $benefits = "benefits" nocase
        $invoice = "invoice" nocase
        $hospital = "hospital" nocase

        $meddefense = "meddefense" nocase
        $medequip = "medequip" nocase

    condition:
        (
            ($mailer and 2 of ($benefits, $invoice, $hospital))
            or
            ($wk and 2 of ($verify, $login, $portal))
            or
            ($pdf and 3 of ($verify, $login, $portal, $meddefense, $medequip))
        )
}

/*
===========================================================
True positives

healthbane_email_01.eml
healthbane_email_02.eml
healthbane_email_03.eml
phishing_sample.pdf
healthbane_lure_02.pdf

True negatives

benign_newsletter.eml
clean_invoice.pdf
benign_invoice.pdf

samples_manifest.txt

Expected test:

yara 10-yara_arsenal.yar samples/

HEALTHBANE_Email_Headers
HEALTHBANE_Document_Metadata
HEALTHBANE_Campaign_Composite

===========================================================
*/
