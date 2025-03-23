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
#mkdir -p $2 #Nos aseguramos de que exista el directorio donde se guardarán los archivos descargados:
#output_url="$2"/*.fastq.gz #Definimos el nombre del archivo de salida.
#if [ -e "$output_url" ]
#then
    #echo "The file already exists"
    #exit 1
#else
    #echo "Downloading urls from $1 into directory $2"
    #wget -P $2 -i $1 #Descargamos las urls ($1) sin utilizar el bucle for y lo guardamos en la ruta que me indique el segundo argumento.
    #echo "Done"
#fi 

if [ "$#" -eq 2 ] #Si el número de argumentos es 2, ejecuta el siguiente código:
then
    mkdir -p "$2" #Nos aseguramos de que exista el directorio donde se guardarán los archivos descargados:
    # Leer cada URL del archivo data/urls
    while read -r url #Leemos cada url del archivo data/urls
    do
        # Definimos el nombre del archivo desde la URL (por ejemplo, C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz)
        filename=""$2"/$(basename "$url")"
        # Verificamos si el archivo ya existe en el directorio de destino
        if [ -e "$filename" ] 
        then
            echo -e "\nThe file $filename exists. Skipping download.\n"
        else
            # Descargar el archivo si no existe
            echo -e "\nDownloading url from "$url" into directory "$2"\n"
            wget -P "$2" "$url"
            echo -e "\nDownload successful: $filename\n"
        fi
    done < "$1"
elif [ "$#" -eq 4 ] #Si el número de argumentos es 4, ejecuta el siguiente código:
then
    mkdir -p "$2" #Nos aseguramos de que exista el directorio donde se guardarán los archivos descargados.
    file_contaminants=$(basename "$1") #Defino primero el nombre del archivo para asegurarme de que es un archivo comprimido:
    if [ -e "$2/$file_contaminants" ] #Si el archivo ya existe en el directorio de destino, muestro un mensaje de advertencia.
    then
        echo -e "\nThe file $2/$file_contaminants exists. Skipping download.\n"
    else
        echo -e "\nDownloading url from "$1" into directory "$2"\n"
        wget -P "$2" "$1" #Descargamos el archivo contaminants.fasta.gz en la ruta que me indique el segundo argumento.
    fi
    if [[ "$3" == "yes" && "$file_contaminants" == *.gz ]] #Si el tercer argumento es "yes" y el archivo está comprimido, lo descomprimimos:
    then
        echo -e "\nUncompressing the file\n"
        gunzip "$2/$file_contaminants" #Descomprimimos el archivo en la ruta que me indique el segundo argumento.
        echo "Done"
    else
        echo -e "\nThe file is not going to be uncompressed\n"
    fi
    # Si el cuarto argumento es una palabra, filtramos las secuencias que contengan ese palabra en su header para eliminarlas:
    if [ -n "$4" ]
    then
        echo -e "\nFiltering sequences with the word "$4" in their header\n"
        file_fasta=$(basename "$1" .gz) #Defino el nombre del archivo fasta, para asegurarme de que está descomprimido.
        seqkit grep -v -r -i -n -p "$4" "$2/$file_fasta" -o "$2/${file_fasta%.fasta}_filtered.fasta" #Filtro el fasta y guardo el archivo filtrado con otro nombre.
        #Utilizo seqkit para filtrar las secuencias que contengan la palabra en su header, y guardo el archivo filtrado en la misma ruta que el archivo original.
        #Para ello uso grep con las siguientes opciones:
        # -v: Invierte la selección, es decir, selecciona las secuencias que no contengan la palabra.
        # -r: Usa expresiones regulares.
        # -i: Ignora mayúsculas y minúsculas.
        # -n: Muestra el nombre de la secuencia.
        # -p: Patrón a buscar.
        echo -e "\nDone\n"
    else
        echo -e "\nThe sequences are not going to be filtered\n"
    fi
else
    echo -e "\nError: You must provide either 2 or 4 arguments"
    echo -e "Usage: bash download.sh <url_file> <output_dir> [Uncompress: yes/no] [word to filter the fasta file]\n"
    exit 1
fi
 


# Si el tercer argumento es "yes" y el archivo está comprimido, lo descomprimimos:

#Defino primero el nombre del archivo para asegurarme de que es un archivo comprimido:
#file=$(basename "$1")

#if [[ "$3" == "yes" && "$file" == *.gz ]]
#then
    #echo "Uncompressing the file"
    #gunzip $2/$file #Descomprimimos el archivo en la ruta que me indique el segundo argumento.
    #echo "Done"
#else
    #echo "The file is not going to be uncompressed"
    
#fi

# Si el cuarto argumento es una palabra, filtramos las secuencias que contengan ese palabra en su header para eliminarlas:
#if [ -n "$4" ]
#then
    #echo "Filtering sequences with the word $4 in their header"
    #file_fasta=$(basename "$1" .gz) #Defino el nombre del archivo fasta, para asegurarme de que está descomprimido.
    #seqkit grep -v -r -i -n -p "$4" "$2/$file_fasta" -o "$2/${file_fasta%.fasta}_filtered.fasta" #Filtro el fasta y guardo el archivo filtrado con otro nombre.
    #Utilizo seqkit para filtrar las secuencias que contengan la palabra en su header, y guardo el archivo filtrado en la misma ruta que el archivo original.
    #Para ello uso grep con las siguientes opciones:
    # -v: Invierte la selección, es decir, selecciona las secuencias que no contengan la palabra.
    # -r: Usa expresiones regulares.
    # -i: Ignora mayúsculas y minúsculas.
    # -n: Muestra el nombre de la secuencia.
    # -p: Patrón a buscar.
    #echo "Done"
#else
    #echo "The sequences are not going to be filtered"
#fi