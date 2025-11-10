#!/bin/bash
# Couleur verte
GREEN="\e[32m"
# Couleur bleue soulignée
BLUE_UNDERLINE="\e[4;34m"
# Réinitialisation (pour revenir à la couleur normale)
RESET="\e[0m"


# Vérifier qu'on a exactement 3 arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <fichier_urls> <dossier_downloads> <dossier_archives>"
    echo "Exemple: $0 urls.txt downloads Archives"
    exit 1
fi

# Récupération des arguments
URLS_FILE=$1
DOWNLOADS_DIR=$2
ARCHIVES_DIR=$3


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

    echo -e "${BLUE_UNDERLINE}> Downloading $url ...${RESET}"
    curl -s -o "temp/$filename" -D "temp/$filename.headers" "$url"
    echo -e "${GREEN}Done${RESET}"
    echo

done < "${PATH_TO_FILE}${URLS_FILE}"

if [ ! -d "${DOWNLOADS_DIR}" ]; then
    mkdir "${DOWNLOADS_DIR}"
fi

# copier les fichiers
echo "> Copying JSON files from 'temp' to '${DOWNLOADS_DIR}'…"
cp temp/*.json "${DOWNLOADS_DIR}/"
echo -e "${GREEN}Done${RESET}"
echo

# compliler les headers dans un nouveau fichier unique
echo "> Compiling HTTP response headers from 'temp' to '${DOWNLOADS_DIR}'…"
> "${DOWNLOADS_DIR}/headers.txt"

for header_file in temp/*.headers; do
    echo "### $(basename "$header_file"): " >> ${DOWNLOADS_DIR}/headers.txt
    cat "$header_file" >> "${DOWNLOADS_DIR}/headers.txt"
    echo "" >> "${DOWNLOADS_DIR}/headers.txt"
done

echo -e "${GREEN}Done${RESET}"
echo


if [ ! -d "${ARCHIVES_DIR}" ]; then
    mkdir "${ARCHIVES_DIR}"
fi

# Créer le nom de l'archive avec la date et l'heure actuelles
ARCHIVE_NAME="D$(date --iso-8601=seconds | tr ':' '-').tar.gz"

echo "> Compressing all files in '${DOWNLOADS_DIR}' to '${ARCHIVES_DIR}'…"

# Compresser le dossier ${DOWNLOADS_DIR}
tar -czf "${ARCHIVES_DIR}/$ARCHIVE_NAME" "${DOWNLOADS_DIR}/"
echo -e "${GREEN}Done (archive file name: $ARCHIVE_NAME)${RESET}"
echo

# Afficher la date de fin du script
END_DATE=$(date --iso-8601=seconds)
echo "> Bash script ending at: $END_DATE"
echo

echo "Bye!"