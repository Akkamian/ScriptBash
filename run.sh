#!/bin/bash
echo "Hello, this is my run script!"
DATE=$(date --iso-8601=seconds)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PATH_TO_FILE="${SCRIPT_DIR}/"

echo "Bash script starting at: $DATE"
echo
echo "Script full path: '${PATH_TO_FILE}run.sh'"
echo

cd "${PATH_TO_FILE}"

if [ ! -d "temp" ]; then
    mkdir temp
fi

while IFS= read -r line; do
    url=$(echo "$line" | tr -d '\r' | xargs)

    # extrait le nom de fichier depuis l'url
    filename=$(basename "$url")

    echo "> Downloading $url ..."
    curl -s -o "temp/$filename" -D "temp/$filename.headers" "$url"
    echo "Done"
    echo

done < "${PATH_TO_FILE}urls.txt"

if [ ! -d "Downloads" ]; then
    mkdir Downloads
fi

# copier les fichiers
echo "> Copying JSON files from '<TEMPORARY>' to '<DOWNLOAD>'…"
cp temp/*.json Downloads/
echo "Done"
echo

# compliler les headers dans un nouveau fichier unique
echo "> Compiling HTTP response headers from '<TEMPORARY>' to '<DOWNLOAD>'…"
> Downloads/headers.txt

for header_file in temp/*.headers; do
    echo "### $(basename "$header_file"): " >> Downloads/headers.txt
    cat "$header_file" >> Downloads/headers.txt
    echo "" >> Downloads/headers.txt
done

echo "Done"
echo


if [ ! -d "Archives" ]; then
    mkdir Archives
fi

# Créer le nom de l'archive avec la date et l'heure actuelles
ARCHIVE_NAME="D$(date --iso-8601=seconds | tr ':' '-').tar.gz"

echo "> Compressing all files in '<DOWNLOAD>' to '<ARCHIVES>'…"

# Compresser le dossier Downloads
tar -czf "Archives/$ARCHIVE_NAME" Downloads/
echo "Done (archive file name: $ARCHIVE_NAME)"
echo

# Afficher la date de fin du script
END_DATE=$(date --iso-8601=seconds)
echo "> Bash script ending at: $END_DATE"
echo

echo "Bye!"