#!/bin/bash
echo ""
echo "=== YARA TESTING SUMMARY ==="

RULES=("9-yara_phishing_pdf.yar" "10-yara_arsenal.yar")
SAMPLES="4x02/samples"

for rule in "${RULES[@]}"; do

    TP=0
    TN=0
    FP=0
    FN=0

    for file in "$SAMPLES"/*; do

        name=$(basename "$file")

        match=$(yara "$rule" "$file" 2>/dev/null)

        # Expected logic from manifest
        if [[ "$name" == phishing_sample.pdf ||
              "$name" == healthbane_lure_02.pdf ||
              "$name" == healthbane_email_01.eml ||
              "$name" == healthbane_email_02.eml ||
              "$name" == healthbane_email_03.eml ]]; then
            expected="POS"
        else
            expected="NEG"
        fi

        if [[ -n "$match" ]]; then
            if [[ "$expected" == "POS" ]]; then
                ((TP++))
            else
                ((FP++))
            fi
        else
            if [[ "$expected" == "NEG" ]]; then
                ((TN++))
            else
                ((FN++))
            fi
        fi
    done

    # safe division
    if (( TP + FN > 0 )); then
        detection_rate=$(( TP * 100 / (TP + FN) ))
    else
        detection_rate=0
    fi

    if (( FP + TN > 0 )); then
        false_positive_rate=$(( FP * 100 / (FP + TN) ))
    else
        false_positive_rate=0
    fi

    if (( TP + FP > 0 )); then
        precision=$(( TP * 100 / (TP + FP) ))
    else
        precision=0
    fi

    echo ""
    echo "Rule: $rule"
    echo "TP: $TP | TN: $TN | FP: $FP | FN: $FN"
    echo "Detection rate: ${detection_rate}%"
    echo "False positive rate: ${false_positive_rate}%"
    echo "precision: ${precision}%"

    if (( FN == 0 && FP == 0 )); then
        rec="DEPLOY"
    elif (( FP > 0 )); then
        rec="TUNE"
    else
        rec="MONITOR"
    fi

    echo "Recommendation: $rec"
done
