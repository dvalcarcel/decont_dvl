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


# Si el tercer argumento es "yes", lo descargamos y descomprimimos el archivo descargado:
if [ "$3" == "yes" ] 
then
    echo "Downloading the contaminants fasta file"
    wget $1 -P $2
    echo "Uncompressing the file"
    file=$(basename "$1")
    gunzip $2/$file
    echo "Done"
else
    echo "Downloading the contaminants fasta file"
    wget $1 -P $2
    echo "Done"
fi

# Si el cuarto argumento es una palabra, filtramos las secuencias que contengan ese palabra en su header para eliminarlas,
# mientras que si es "another", mostramos las dos primeras secuencias:
if [ "$4" == "another" ]
then
    echo "Showing the first two sequences"
    file_fasta=$(basename "$1" .gz)
    head -n 4 "$2"/*.fasta
else
    echo "Filtering sequences with the word $4 in their header"
    file_fasta=$(basename "$1" .gz)
    seqkit grep -v -r -i -p "$4" "$2"/$file_fasta -o "$2"/$file_fasta.filtered.fasta
    echo "Done"
fi