# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

#genomefile=$(basename "$1")

#Vamos a comprobar si ya existen los 9 archivos generados por STAR en el directorio $2. Si no existen, ejecutamos el comando STAR para generarlos.
star_index_count=$(ls res/contaminants_idx | wc -l) #Contamos el número de archivos en el directorio res/contaminants_idx.

if [ $star_index_count -eq 9 ] #Si el número de archivos es 9, mostramos un mensaje de advertencia.
then
    echo "The STAR index already exists. Skipping index generation."
    exit 1
else
    echo "Running STAR index..."
    mkdir -p $2 #Creamos el directorio de salida si no existe.
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $2 \
    --genomeFastaFiles $1 --genomeSAindexNbases 9 #Ejecutamos el comando STAR para generar los archivos del índice.
fi

