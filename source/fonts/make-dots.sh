#!/bin/bash

# Output filename: prefix+"default"/"score"/"combo"+middle+"$what"+suffix
OUT_PREFIX="export/dot/"
OUT_MIDDLE="-"
OUT_SUFFIX=".png"
# what
# WHAT="0 1 2 3 4 5 6 7 8 9 comma dot percent x"
WHAT="0 1 2 3 4 5 6 7 8 9"
CATEGORY_SOURCE=("dot/0.svg")
CATEGORY=(dot)
DPI=(96)



# Usage: GEN_IN_FILENAME $category_id $what
GEN_IN_FILENAME() {
#     echo "${CATEGORY_SOURCE_PREFIX[$1]}""$2""${CATEGORY_SOURCE_SUFFIX[$1]}"
    echo "${CATEGORY_SOURCE[$1]}"
}
# Usage: GEN_OUT_FILENAME $category_id $what
GEN_OUT_FILENAME() {
    echo "$OUT_PREFIX""${CATEGORY[$1]}""$OUT_MIDDLE""$2""$OUT_SUFFIX"
}
# Usage: INK $dpi $in_filename $out_filename
INK() {
    inkscape --export-dpi=$1 --export-type=png --export-filename="$3" $2
}
# Usage: EXPORTER $category $what $dpi
# Usage: EXPORTER $category_id $what
EXPORTER() {
    infile="$(GEN_IN_FILENAME "$1" "$2")"
    outfile="$(GEN_OUT_FILENAME "$1" "$2")"
    outfile2x="$(GEN_OUT_FILENAME "$1" "$2""@2x")"
    echo exporting "$outfile"
    INK ${DPI[$1]} "$infile" "$outfile"
    echo exporting "$outfile2x"
    INK $((${DPI[$1]} * 2)) "$infile" "$outfile2x"
}

# Export numbers
for ((i=0; i<${#CATEGORY[@]}; i++)); do
    echo Exporting numbers for ${CATEGORY[$i]} from ${CATEGORY_SOURCE_PREFIX[$i]}, dpi ${DPI[$i]}
    for j in $WHAT; do
        EXPORTER $i "$j"
    done
done


