#!/bin/bash

SRC_FORMAT="tif"
FORMAT="jpg"
PATTERN="_[0-9]\.${FORMAT}"
SUB_PATTERN=".${FORMAT}"

function convert_images {
    for f in ${DATASET}/*.${SRC_FORMAT}; do
        echo "Converting $f"
        FILENAME=$(basename "$f" .${SRC_FORMAT}).${FORMAT}
        convert "$f" "${DATASET}/${FILENAME}"
    done
}


function build_dataset {
    for f in ${DATASET}/*.${FORMAT}; do
        FILENAME=$(basename $f)
        if [[ $f =~ $PATTERN ]]; then
            FILE="${FILENAME/${PATTERN}/${SUB_PATTERN}}"
            CAMERA=${BASH_REMATCH[0]:1:1}
            OUTDIR=${OUTPUT}/Camera${CAMERA}/images
            mkdir -p ${OUTDIR}
            if $CONVERT; then
                echo "Moving image ${FILENAME} to ${OUTDIR}"
                mv $f ${OUTDIR}/$FILE
            else
                echo "Copying image ${FILENAME} to ${OUTDIR}"
                cp $f ${OUTDIR}/${FILE}
            fi
            
        else
            echo "Pattern ${PATTERN} not detected in ${FILENAME}"
        fi
    done
}


# Parse arguments
CONVERT=false
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

# Check required arguments
if [ -z ${DATASET} ]; then
    echo "Dataset path is required"
    exit 0
fi

if [ -z ${OUTPUT} ]; then
    echo "Output path is required"
    exit 0
fi

# Start processing

if [[ ${CONVERT} = true ]]; then
    convert_images
fi

build_dataset

exit 0