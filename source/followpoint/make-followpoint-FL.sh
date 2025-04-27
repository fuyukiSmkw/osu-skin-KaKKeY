#!/bin/bash

# How many frames are there in each fade in animation
FADE_IN_ANIMATION_FRAMES=5
# Which frame does the fade in anim. starts
FADE_IN_START_AT_FRAME=22
# How many frames are there in each fade out animation
FADE_OUT_ANIMATION_FRAMES=5
# Which frame does the fade out anim. starts
FADE_OUT_START_AT_FRAME=54
# How many frames in total
TOTAL_FRAMES=60
# Animation temp filename
TMP_PREFIX="tmp-"
TMP_SUFFIX=".png"
# Output filename: prefix+"[frame no.]"[+"@2x"]+suffix
OUT_PREFIX="export/FL/followpoint-"
OUT_SUFFIX=".png"
# DPI
NORMAL_DPI=96
DOUBLE_DPI=192
# SVG template
SVG_TEMPLATE_FILE="template-FL.svg"
# Export command
CMD1x="inkscape --pipe --export-dpi=$NORMAL_DPI --export-type=png --export-filename"
CMD2x="inkscape --pipe --export-dpi=$DOUBLE_DPI --export-type=png --export-filename"
SED_PREFIX='s/stroke-opacity:1/stroke-opacity:'
SED_SUFFIX='/g'

svg_template=$(cat "$SVG_TEMPLATE_FILE")
# Usage: GEN_xxx_FILENAME $middle_name
GEN_TMP_FILENAME() {
    echo "$TMP_PREFIX""$1""$TMP_SUFFIX"
}
GEN_OUT_FILENAME() {
    echo "$OUT_PREFIX""$1""$OUT_SUFFIX"
}
# Usage: EXPORTER $opacity $middle_name
EXPORTER() {
    echo exporting "$(GEN_TMP_FILENAME "$2")"
    echo "$svg_template" | sed "$SED_PREFIX""$1""$SED_SUFFIX" | $CMD1x "$(GEN_TMP_FILENAME "$2")"
    echo exporting "$(GEN_TMP_FILENAME "$2""@2x")"
    echo "$svg_template" | sed "$SED_PREFIX""$1""$SED_SUFFIX" | $CMD2x "$(GEN_TMP_FILENAME "$2""@2x")"
}
# Usage: CLEANER
CLEANER() {
    rm "$TMP_PREFIX"*"$TMP_SUFFIX"
}


# Step 1. Make animated pngs
# make void
EXPORTER 0.0 void
# make full
EXPORTER 1.0 full
# make fade in anim
opacity_inc=$(echo "1.0 / $FADE_IN_ANIMATION_FRAMES" | bc -l)
opacity=0.0
for ((i=1; i<FADE_IN_ANIMATION_FRAMES-1; i++)); do
    opacity=$(echo "$opacity + $opacity_inc" | bc -l)
    EXPORTER "$opacity" "in-""$i"
done
# make fade out anim
opacity_dec=$(echo "1.0 / $FADE_OUT_ANIMATION_FRAMES" | bc -l)
opacity=1.0
for ((i=1; i<FADE_OUT_ANIMATION_FRAMES-1; i++)); do
    opacity=$(echo "$opacity - $opacity_dec" | bc -l)
    EXPORTER "$opacity" "out-""$i"
done

# Step 2. Copy and rename
# Order: void, in-1234, full, out-1234, void
i=0
# void
for ((; i<=FADE_IN_START_AT_FRAME; i++)); do
    echo copying to "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME void)" "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "void@2x")" "$(GEN_OUT_FILENAME "$i""@2x")"
done
# fade in
echo fade in anim starts at "$(GEN_OUT_FILENAME $((i-1)) )"
for ((j=1; j<FADE_IN_ANIMATION_FRAMES-1; j++,i++)); do
    echo copying to "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "in-""$j")" "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "in-""$j""@2x")" "$(GEN_OUT_FILENAME "$i""@2x")"
done
echo fade in anim ends at "$(GEN_OUT_FILENAME $i)"
# full
for ((; i<=FADE_OUT_START_AT_FRAME; i++)); do
    echo copying to "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME full)" "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "full@2x")" "$(GEN_OUT_FILENAME "$i""@2x")"
done
# fade out
echo fade out anim starts at "$(GEN_OUT_FILENAME $((i-1)))"
for ((j=1; j<FADE_OUT_ANIMATION_FRAMES-1; j++,i++)); do
    echo copying to "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "out-""$j")" "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "out-""$j""@2x")" "$(GEN_OUT_FILENAME "$i""@2x")"
done
echo fade out anim ends at "$(GEN_OUT_FILENAME $i)"
# void
for ((; i<TOTAL_FRAMES; i++)); do
    echo copying to "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME void)" "$(GEN_OUT_FILENAME $i)"
    cp "$(GEN_TMP_FILENAME "void@2x")" "$(GEN_OUT_FILENAME "$i""@2x")"
done

# Step 3. Clean up all tmp files
CLEANER

