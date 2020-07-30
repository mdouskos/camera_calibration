#!/bin/bash

CONVERT=false

PATTERN="_[0-9]\."

function convert {
    for f in ${DATASET}/*.tif; do
        echo "Converting $f"
        convert "$f"  "$(basename "$f" .tif).jpg"
    done
}

function build_dataset {
    for f in ${DATASET}/*.jpg; do
        filename=`basename $f`
        if [[ $f =~ $PATTERN ]]; then
            FILE=${filename/${PATTERN}/\.}
            CAMERA=${BASH_REMATCH[0]:1:1}
            OUTDIR=${OUTPUT}/Camera${CAMERA}/images
            # echo ${OUTDIR}
            mkdir -p ${OUTDIR}
            cp $f ${OUTDIR}/$FILE
            echo "Copying image ${filename} to ${OUTDIR}"
        fi
    done
}

while [[ $# -gt 0 ]]; do
key="$1"

POSITIONAL=()
case $key in
    -h| --help)
        echo "Usage: $0 [-c] [-d dataset_path] [-o output_path]"
        exit 0
        ;;
    -d)
        DATASET="$2"
        shift
        shift
        ;;
    -o)
        OUTPUT="$2"
        shift
        shift
        ;;
    -c| --convert)
        CONVERT=true
        shift
        ;;
    *)
        POSITIONAL+=("$1")
        shift
        ;;
esac
done

if [ -z ${DATASET} ]; then
    echo "Dataset path is required"
    exit 0
fi

if [ -z ${OUTPUT} ]; then
    echo "Output path is required"
    exit 0
fi



echo ${DATASET}
build_dataset

if [[ ${CONVERT} = true ]]; then
    convert
fi


