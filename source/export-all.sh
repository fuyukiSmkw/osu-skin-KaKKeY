#!/bin/bash

# Usage: INK $dpi $in_filename $out_filename
INK() {
    echo inkscape --export-dpi=$1 --export-type=png --export-filename="$3" $2
    inkscape --export-dpi=$1 --export-type=png --export-filename="$3" $2
}

dirname() {
    if [[ $1 == */* ]]; then
        echo ${1##*/}
    else
        echo "."
    fi
}

# Usage: exporter file.svg
exporter() {
    INK 96 "$1" "${1%.*}.png"
    if [ ! -f "`dirname "$1"`/.no@2x" ]; then
        INK 192 "$1" "${1%.*}@2x.png"
    fi
}

process_dir() {
    local original_dir="$PWD"
    local target_dir="$1"

    if ! cd "$target_dir"; then
        return 1
    fi

    if [[ -d "export" ]]; then
        cd "$original_dir"
        return
    fi

    shopt -s nullglob
    local svg_files=( *.svg )
    for svg in "${svg_files[@]}"; do
        exporter "$svg"
    done

    local subdirs=( */ )
    for subdir in "${subdirs[@]}"; do
        subdir="${subdir%/}"
        if [[ -d "$subdir" && ! -L "$subdir" ]]; then
            process_dir "$subdir"
        fi
    done

    cd "$original_dir"
}

process_dir "."
