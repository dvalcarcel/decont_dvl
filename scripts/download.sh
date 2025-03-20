# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output



# En primer lugar, descargamos los archivos fastq.gz del archivo url, siendo $1 la url y $2 el directorio donde se guardará:

echo "Downloading $1"
wget $1 -P $2
echo "Done"


# Si el tercer argumento es "yes" y el archivo está comprimido, lo descomprimimos:

#Defino primero el nombre del archivo para asegurarme de que es un archivo comprimido:
file=$(basename "$1")

if [[ "$3" == "yes" && "$file" == *.gz ]]
then
    echo "Uncompressing the file"
    gunzip $2/$file #Descomprimimos el archivo en la ruta que me indique el segundo argumento.
    echo "Done"
else
    echo "The file is not going to be uncompressed"
    
fi

# Si el cuarto argumento es una palabra, filtramos las secuencias que contengan ese palabra en su header para eliminarlas:
if [ -n "$4" ]
then
    echo "Filtering sequences with the word $4 in their header"
    file_fasta=$(basename "$1" .gz) #Defino el nombre del archivo fasta, para asegurarme de que está descomprimido.
    seqkit grep -v -r -i -n -p "$4" "$2/$file_fasta" -o "$2/$file_fasta.filtered.fasta"
    #Utilizo seqkit para filtrar las secuencias que contengan la palabra en su header, y guardo el archivo filtrado en la misma ruta que el archivo original.
    #Para ello uso grep con las siguientes opciones:
    # -v: Invierte la selección, es decir, selecciona las secuencias que no contengan la palabra.
    # -r: Usa expresiones regulares.
    # -i: Ignora mayúsculas y minúsculas.
    # -n: Muestra el nombre de la secuencia.
    # -p: Patrón a buscar.
    echo "Done"
else
    echo "The sequences are not going to be filtered"
fi