#Download all the files specified in data/filenames
for url in $(cat data/urls) #Con un bucle for recorremos el archivo urls que contiene las urls de los archivos a descargar.
do
    bash scripts/download.sh $url data #Ejecutamos el script download.sh con cada una de las urls y el directorio data como directorio.
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear"
#Descargamos el archivo contaminants.fasta.gz como primer argumento, lo guardamos en el directorio res,
#lo descomprimimos al introducir yes como tercer argumento y filtramos el fasta para eliminar los "small nuclear" como cuarto argumento.


# Index the contaminants file
bash scripts/index.sh res/contaminants_filtered.fasta res/contaminants_idx

# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | cut -d "/" -f2 | uniq)
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files

mkdir -p out/trimmed #Creamos el directorio out/trimmed si no existe.
mkdir -p log/cutadapt #Creamos el directorio log/cutadapt si no existe.
for file in out/merged/*.fastq.gz #Hacemos un bucle for para coger las muestras del directorio out/merged.
do
    sid=$(basename "$file" .merged.fastq.gz) #Obtenemos el id de la muestra.
    echo "Running cutadapt for sample $sid"
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
         -o out/trimmed/"$sid.trimmed.fastq.gz" "$file" > log/cutadapt/"$sid.log" 
         #Ejecutamos cutadapt con los merged.fastq.gz, guardamos el resultado en out/trimmed y redireccionamos el log en el directorio log/cutadapt.
done


# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz #Hacemos un bucle for para coger las muestras del directorio out/trimmed.
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename "$fname" .trimmed.fastq.gz) #Obtenemos el id de la muestra.
    echo "Running STAR Alignment for sample $sid"
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx/ \
        --outReadsUnmapped Fastx --readFilesIn $fname \
        --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid/
        #Ejecutamos STAR con los archivos trimmed.fastq.gz y guardamos el resultado en out/star/$sid.
done 

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
