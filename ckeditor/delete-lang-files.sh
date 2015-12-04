#!/bin/bash

# Delete recursively all the foreign language files that ckeditor comes with.
#
# @author: "Austin Maddox" <austin@maddoxbox.com>

if [ $# -lt 1 ]; then
    echo "Usage: ./delete-lang-files.sh (dryrun|production)"
    exit 0
fi

ACTION=$1

# Build array of languages.
LANGUAGES=(
    'af'
    'ar'
    'bg'
    'bn'
    'bs'
    'ca'
    'cs'
    'cy'
    'da'
    'de'
    'el'
    'eo'
    'es'
    'et'
    'eu'
    'fa'
    'fi'
    'fo'
    'fr'
    'fr-ca'
    'gl'
    'gu'
    'he'
    'hi'
    'hr'
    'hu'
    'id'
    'is'
    'it'
    'ja'
    'ka'
    'km'
    'ko'
    'ku'
    'lt'
    'lv'
    'mk'
    'mn'
    'ms'
    'nb'
    'nl'
    'no'
    'pl'
    'pt'
    'pt-br'
    'ro'
    'ru'
    'si'
    'sk'
    'sl'
    'sq'
    'sr'
    'sr-latn'
    'sv'
    'th'
    'tr'
    'tt'
    'ug'
    'uk'
    'vi'
    'zh'
    'zh-cn'
)

echo "Performing deletion of ${#LANGS[@]} language files..."

for ((i = 0; i < ${#LANGUAGES[@]}; i++))
do
    echo "[$i]" ${LANGUAGES[$i]}
    if [ "$ACTION" = "production" ]
        then
        find . -name "${LANGUAGES[$i]}.js" -delete
    else
        find . -name "${LANGUAGES[$i]}.js"

        # Testing/debug mechanism for jumping out early.
        if [ "$i" -ge "4" ]
            then
                echo "Bail out of the loop"
                exit 1;
        fi
    fi
done

echo "...Done."
