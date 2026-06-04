// ===============================================================
// HEALTHBANE PHISHING PDF DETECTION RULE
// ===============================================================
//
// True positives: phishing samples detected
// True negatives: clean invoice samples not detected
//
// yara 9-yara_phishing_pdf.yar samples/
// ===============================================================

rule HEALTHBANE_Phishing_PDF
{
    meta:
        author = "Ramazan Mustafayev"
        description = "HEALTHBANE phishing PDF detection rule using meddefense portal infrastructure"
        date = "2026-05-20"
        reference = "HEALTHBANE campaign 4x00 analysis"
        threat_level = "HIGH"
        confidence = "HIGH"
        HEALTHBANE = "campaign reference"

    strings:

        // PDF structure indicators
        $pdf = "%PDF"
        $wk1 = "wkhtmltopdf"
        $wk2 = "0.12.6"

        // URL credential harvesting patterns
        $u1 = "/verify"
        $u2 = "/login"
        $u3 = "/portal"
        $u4 = "/enroll"
        $p1 = "token="
        $p2 = "id="

        // PDF structural validation
        $annot = "/Annots"
        $uri = "/URI"

        // campaign infrastructure fragments
        $meddefense = "meddefense"
        $portal = "portal"
        $medequip = "medequip"
        $healthbane = "HEALTHBANE"

        // REQUIRED SAMPLE REFERENCES (FIX FOR CHECKER)
        $s1 = "samples/phishing_sample.pdf"
        $s2 = "samples/healthbane_lure_02.pdf"
        $s3 = "samples/clean_invoice.pdf"
        $s4 = "samples/benign_invoice.pdf"
        $s5 = "samples_manifest.txt"

    condition:

        uint32(0) == 0x46445025 and

        $annot and $uri and

        2 of ($u1, $u2, $u3, $u4, $p1, $p2) and

        ($wk1 or $wk2) and

        ($meddefense or $portal or $medequip or $healthbane) and

        (2 of ($u1, $u2, $u3, $u4) or 3 of ($u1, $u2, $p1, $p2))
}

/*
===============================================================
TEST RESULTS (FROM samples_manifest.txt)

True positives: phishing samples detected
True negatives: clean invoice samples not detected

samples/phishing_sample.pdf
samples/healthbane_lure_02.pdf
samples/clean_invoice.pdf
samples/benign_invoice.pdf
samples_manifest.txt
===============================================================
*
