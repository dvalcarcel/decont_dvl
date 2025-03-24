
# Este script se encarga de eliminar los directorios generados por el script de
# pipeline.sh. Se pueden pasar como argumentos los directorios a eliminar.
# Si no se pasan argumentos, se eliminan todos los directorios generados.

# Definimos los directorios a eliminar según los argumentos proporcionados
DATA_DIR="data"
RESOURCES_DIR="res"
OUTPUT_DIR="out"
LOGS_DIR="log"

# Si no se pasan argumentos, eliminamos todo
if [ "$#" -eq 0 ] 
then
    echo "No arguments provided. Removing all generated files and directories from $DATA_DIR, $RESOURCES_DIR, $OUTPUT_DIR, $LOGS_DIR"
    rm -rf "$DATA_DIR" "$RESOURCES_DIR" "$OUTPUT_DIR" "$LOGS_DIR" #Eliminamos los directorios data, res, out y logs. Con -r eliminamos de forma recursiva y con -f forzamos la eliminación sin preguntar.
    echo "Cleanup complete."
    exit 0 #Salimos del script.
fi

# Eliminamos solo los directorios especificados
for arg in "$@" #Hacemos un bucle for para recorrer los argumentos pasados al script. 
do 
    case "$arg" in #Usamos case para comparar el argumento con los casos posibles.
        data) #Si el argumento es data, eliminamos el directorio data.
            echo "Removing data directory..."
            rm -rf "$DATA_DIR"
            ;;
        res)  #Si el argumento es res, eliminamos el directorio res.
            echo "Removing res directory..."
            rm -rf "$RESOURCES_DIR"
            ;;
        out) #Si el argumento es out, eliminamos el directorio out.
            echo "Removing out directory..."
            rm -rf "$OUTPUT_DIR"
            ;;
        log) #Si el argumento es log, eliminamos el directorio logs.
            echo "Removing log directory..."
            rm -rf "$LOGS_DIR"
            ;;
        *) #Si el argumento no es ninguno de los anteriores, mostramos un mensaje de error.
            echo "Invalid argument: $arg. Allowed arguments: data, res, out, log."
            exit 1
            ;;
    esac #Cerramos el case.
done

echo "Cleanup complete."
