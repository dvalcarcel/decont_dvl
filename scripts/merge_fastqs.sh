# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

#En primer lugar, creamos el directorio de salida si no existe y definimos los nombres de los archivos fastq.gz que vamos a concatenar:
mkdir -p $2
file_name_1=$(ls "$1"/"$3"*.fastq.gz | cut -d "/" -f2 | sort | head -n 1) #Obtenemos el nombre del primer archivo fastq.gz del directorio data que contenga el id de la muestra.
file_name_2=$(ls "$1"/"$3"*.fastq.gz | cut -d "/" -f2 | sort | tail -n 1) #Obtenemos el nombre del último archivo fastq.gz del directorio data que contenga el id de la muestra.

if [ -n "$2/$3.merged.fastq.gz" ] #Si el archivo ya existe, mostramos un mensaje de advertencia.
then
    echo -e "\nThe file "$2/$3.merged.fastq.gz" already exists. Skipping merge.\n"
    exit 1
else
    echo "Merging files $file_name_1 and $file_name_2"
    cat "$1/$file_name_1" $1/$file_name_2 > "$2/$3.merged.fastq.gz" #Concatenamos los dos archivos fastq.gz en un solo archivo con el nombre de la muestra y lo guardamos en el directorio de salida.
    echo "Merge successful: $2/$3.merged.fastq.gz"
fi


