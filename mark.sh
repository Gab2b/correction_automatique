note=0

if [[ ! -f readme.txt ]]; then
    echo "Erreur : readme.txt manquant"
    exit 1
fi

prenom=$(awk '{print $1}' readme.txt)
nom=$(awk '{print $2}' readme.txt)

make > /dev/null 2>&1

if [[ -x factorielle ]]; then
    note=$((note + 2))
    echo "Compilation réussie"
else
    echo "Compilation échouée. Note = 0"
    echo "'$nom','$prenom',$note" >> note.csv
    exit 0
fi

reponses="1 2 6 24 120 720 5040 40320 362880 3628800"
i=1
verification=true

for element in $reponses; do
    sortie=$(./factorielle "$i")

    if [[ "$sortie" == "$element" ]]; then
        echo "Factorielle de $i correcte"
    else
        verification=false
    fi

    i=$((i + 1))
done

if $verification; then
    note=$((note + 5))
fi

output=$(./factorielle 0)
if [[ "$output" == "1" ]]; then
    note=$((note + 3))
    echo "Factorielle de 0 prise en compte"
fi

output=$(./factorielle)
if [[ "$output" == "Erreur: Mauvais nombre de parametres" ]]; then
    note=$((note + 4))
    echo "Mauvais nombre de paramètres pris en compte"
fi

output=$(./factorielle -3)
if [[ "$output" == "Erreur: nombre negatif" ]]; then
    note=$((note + 4))
    echo "Nombres négatifs pris en compte"
fi

if grep -q "int factorielle( int number )" main.c; then
    note=$((note + 2))
    echo  "Fonction Factorielle présente"
fi

if [[ ! -f header.h ]]; then
    note=$((note - 2))
    echo "Malus : Header absent"
fi

if grep -E '.{81,}' main.c header.h > /dev/null 2>&1; then
    note=$((note - 2))
    echo "Malus : Ligne de + de 80 caractères"
fi

if grep -Pq '^( +)[^ ]' main.c | grep -Pv '^((  )+)[^ ]'; then
  note=$((note - 2))
  echo "Malus : Code mal indenté"
fi

make clean > /dev/null 2>&1
if [[ -f factorielle ]]; then
    note=$((note - 2))
    echo "Malus : Pas de fichier Factorielle"
fi

if (( note < 0 )); then
    note=0
fi

csv_file="note.csv"

if [[ ! -f $csv_file ]]; then
    echo "Nom,Prénom,Note" > "$csv_file"
fi

echo "'$nom','$prenom',$note" >> "$csv_file"
