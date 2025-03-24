#Download all the files specified in data/filenames
bash scripts/download.sh data/urls data #Ejecutamos el script download.sh con un wget de una línea (sin usar bucle for) y el directorio data como directorio.


# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"
#Descargamos el archivo contaminants.fasta.gz como primer argumento, lo guardamos en el directorio res,
#lo descomprimimos al introducir yes como tercer argumento y filtramos el fasta para eliminar los "small nuclear" como cuarto argumento.


# Index the contaminants file
bash scripts/index.sh res/contaminants_filtered.fasta res/contaminants_idx #Indexamos el archivo contaminants_filtered.fasta en el directorio res/contaminants_idx.

# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | cut -d "/" -f2 | uniq) #Hacemos un bucle for para coger las muestras del directorio data.
do
    bash scripts/merge_fastqs.sh data out/merged $sid #Para cada muestra, ejecutamos el script merge_fastqs.sh con los archivos fastq.gz de la muestra y los guardamos en out/merged.
done

# TODO: run cutadapt for all merged files

mkdir -p out/trimmed #Creamos el directorio out/trimmed si no existe.
mkdir -p log/cutadapt #Creamos el directorio log/cutadapt si no existe.
for file in out/merged/*.fastq.gz #Hacemos un bucle for para coger las muestras del directorio out/merged.
do
    sid_cutadapt=$(basename "$file" .merged.fastq.gz) #Obtenemos el id de la muestra.
    if [ -e "out/trimmed/$sid_cutadapt.trimmed.fastq.gz" ] #Si el archivo ya existe, mostramos un mensaje de advertencia.
    then
        echo -e "\nThe file out/trimmed/$sid_cutadapt.trimmed.fastq.gz already exists. Skipping cutadapt.\n"
    else
        echo "Running cutadapt for sample $sid_cutadapt"
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
            -o out/trimmed/"$sid_cutadapt.trimmed.fastq.gz" "$file" > log/cutadapt/"$sid_cutadapt.log" 
            #Ejecutamos cutadapt con los merged.fastq.gz, guardamos el resultado en out/trimmed y redireccionamos el log en el directorio log/cutadapt.
    fi
done


# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz #Hacemos un bucle for para coger las muestras del directorio out/trimmed.
do
    # you will need to obtain the sample ID from the filename
    sid_star=$(basename "$fname" .trimmed.fastq.gz) #Obtenemos el id de la muestra.
    if [ -e "out/star/$sid_star/Aligned.out.sam" ] #Si el sam de alineamiento de la muestra existe, mostramos un mensaje de advertencia.
    then
        echo -e "\nThe STAR Alignment for sample $sid_star already exists. Skipping alignment.\n"
    else
        echo "Running STAR Alignment for sample $sid_star"
        mkdir -p out/star/$sid_star #Creamos el directorio out/star/$sid_star si no existe.
        STAR --runThreadN 4 --genomeDir res/contaminants_idx/ \
            --outReadsUnmapped Fastx --readFilesIn $fname \
            --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid_star/
            #Ejecutamos STAR con los archivos trimmed.fastq.gz y guardamos el resultado en out/star/$sid_star.
    fi
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in


#Creamos el archivo log que contendrá la información de los logs de cutadapt y star.
log_file="log/pipeline.log"
echo "Pipeline Log - $(date)" > $log_file #Escribimos la fecha en el archivo log.
echo "===================================" >> $log_file #Añadimos una línea de separación.

#Añadimos la información de cutadapt al archivo log.
echo -e "\n=== Cutadapt Summary Log ===" >> $log_file
for log in log/cutadapt/*.log #Hacemos un bucle para coger los logs de cutadapt de cada muestra.
do
    sid_log=$(basename "$log" .log) #Obtenemos el id de la muestra.
    echo -e "\nSample: $sid_log" >> $log_file #Mostramos que muestra estamos tratando.
    grep "Reads with adapters" $log >> $log_file #Añadimos al archivo log la información de reads with adapters.
    grep "Total basepairs processed" $log >> $log_file #Añadimos al archivo log la información de total basepairs processed.
done

#Añadimos la información de STAR al archivo log.
echo -e "\n=== STAR Alignment Summary Log ===" >> $log_file
for log_final in out/star/*/Log.final.out #Hacemos un bucle for para coger los logs de STAR de cada muestra.
do
    sid_log_final=$(basename $(dirname $log_final)) #Obtenemos el id de la muestra.
    echo -e "\nSample: $sid_log_final" >> $log_file #Mostramos que muestra estamos tratando.
    grep "Uniquely mapped reads %" $log_final >> $log_file #Añadimos al archivo log la información de uniquely mapped reads.
    grep "% of reads mapped to multiple loci" $log_final >> $log_file #Añadimos al archivo log la información de reads mapped to multiple loci.
    grep "% of reads mapped to too many loci" $log_final >> $log_file #Añadimos al archivo log la información de reads mapped to too many loci.
done