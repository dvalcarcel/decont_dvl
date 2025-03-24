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


if [ "$#" -eq 2 ] #Si el número de argumentos es 2, ejecuta el siguiente código:
then
    mkdir -p "$2" #Nos aseguramos de que exista el directorio donde se guardarán los archivos descargados:
    if [ -e "$2/urls" ] #Si el archivo urls ya existe en el directorio de destino, mostramos un mensaje de advertencia.
    then
        echo -e "\nThe file $2/urls exists. Skipping download.\n" #Si el archivo ya existe en el directorio de destino, mostramos un mensaje de advertencia.
    else
        echo -e "\nDownloading url file into directory "$2"\n"
        wget -P "$2" "https://raw.githubusercontent.com/dvalcarcel/decont_dvl/refs/heads/master/data/urls" #Descargamos el archivo urls del github en la ruta que me indique el segundo argumento.
        echo -e "\nDownload successful: $2/urls\n"
    fi
    # Leer cada URL del archivo data/urls
    while read -r url #Leemos cada url del archivo data/urls
    do
        # Definimos el nombre del archivo desde la URL (por ejemplo, C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz)
        filename=""$2"/$(basename "$url")"
        # Verificamos si el archivo ya existe en el directorio de destino
        if [ -e "$filename" ] 
        then
            echo -e "\nThe file $filename exists. Skipping download.\n" #Si el archivo ya existe, mostramos un mensaje de advertencia.
        else
            # Descargar el archivo si no existe
            echo -e "\nDownloading url from "$url" into directory "$2"\n"
            wget -P "$2" "$url" #Descargamos el archivo en la ruta que me indique el segundo argumento.
            echo -e "\nDownload successful: $filename\n"
            expected_fasta_md5=$(wget -qO- "$url.md5" | awk '{print $1}') #Obtenemos el md5 esperado del archivo fasta sin descargarlo.
            #Con wget -qO- obtenemos el hash .md5 sin descargarlo y con awk '{print $1}' obtenemos el md5 esperado.
            calculated_fasta_md5=$(md5sum "$filename" | awk '{print $1}') #Calculamos el md5 del archivo fasta descargado.
            if [ "$expected_fasta_md5" == "$calculated_fasta_md5" ] #Comparamos el md5 esperado con el md5 calculado.
            then
                echo "The md5sum of $filename is correct" #Si el md5 es correcto, mostramos un mensaje.
            else
                echo "The md5sum of $filename is incorrect"
            fi
        fi
    done < "$1" #Esto me permite pasarle al while como entrada el archivo data/urls para que lo pueda leer línea por línea.
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
        expected_contaminants_md5=$(wget -qO- "$1.md5" | awk '{print $1}') #Obtenemos el md5 esperado del archivo contaminants.fasta.gz sin descargarlo.
        calculated_contaminants_md5=$(md5sum "$2/$file_contaminants" | awk '{print $1}') #Calculamos el md5 del archivo contaminants.fasta.gz descargado.
        if [ "$expected_contaminants_md5" == "$calculated_contaminants_md5" ] #Comparamos el md5 esperado con el md5 calculado.
        then
            echo "The md5sum of $file_contaminants is correct" #Si el md5 es correcto, mostramos un mensaje.
        else
            echo "The md5sum of $file_contaminants is incorrect"
        fi
    fi
    if [[ "$3" == "yes" && "$file_contaminants" == *.gz ]] #Además, si el tercer argumento es "yes" y el archivo está comprimido, lo descomprimimos:
    then
        echo -e "\nUncompressing the file\n"
        gunzip -k "$2/$file_contaminants" #Descomprimimos el archivo en la ruta que me indique el segundo argumento y mantenemos el archivo comprimido original.
        echo "Done"
    else
        echo -e "\nThe file is not going to be uncompressed\n" #Si no tenemos el argumento yes como tercer argumento y el archivo no está comprimido, mostramos un mensaje.
    fi
    # Si el cuarto argumento es una palabra, filtramos las secuencias que contengan ese palabra en su header para eliminarlas:
    if [ -n "$4" ]
    then
        echo -e "\nFiltering sequences with the word "$4" in their header"
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
        echo -e "\nThe sequences are not going to be filtered\n" #Si no tenemos el cuarto argumento, mostramos un mensaje.
    fi
else
    echo -e "\nError: You must provide either 2 or 4 arguments" #Si el número de argumentos no es 2 ni 4, mostramos un mensaje de error.
    echo -e "Usage: bash download.sh <url_file> <output_dir> [Uncompress: yes/no] [word to filter the fasta file]\n" #Mostramos cómo se debe usar el script.
    exit 1
fi
 

