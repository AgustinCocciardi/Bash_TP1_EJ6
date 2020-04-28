#!/bin/bash

#Funcion que muestra la ayuda
function ayuda(){
    echo "Este script se ha creado con la finalidad de sumar nùmeros fraccionarios dentro de un archivo"
    echo "Este realizará la suma de todos los números fraccionarios del archivo, y luego mostrar por pantalla y guardar en un archivo el resultado"
    echo "La ejecución del script se hace de la siguiente forma:"
    echo "./TP1EJ6.sh -f archivo_de_numeros"
    echo "La ruta del archivo de numeros puede ser absoluta o relativa"
	exit 0
} 

#Funcion que usaré para calcular el comun multiplo entre dos numeros
function comun_multiplo (){
    num1=$1
    num2=$2
    if [ $num1 -gt $num2 ]; then
        mayor=$num1
    else
        mayor=$num2
    fi

    valor1=$(($mayor%$num1))
    valor2=$(($mayor%$num2))
    while [ $valor1 -ne 0 -o $valor2 -ne 0 ]
    do
        let "mayor++"
        valor1=$(($mayor%$num1))
        valor2=$(($mayor%$num2))
    done
    return $mayor
}

#Funcion que usaré para calcular el comun divisor entre dos numeros
function comun_divisor (){
    num1=$1
    num2=$2
    while [ $num1 -ne $num2 ]
    do
        if [ $num1 -gt $num2 ]; then
            num1=$(($num1-$num2))
        else
            num2=$(($num2-$num1))
        fi
    done
    return $num1
}

if [ $1 = "-h" -o $1 = "-?" -o $1 = "-help" ]; then
    ayuda
fi

if [ $# -ne 2 ]; then
    echo "La cantidad de parámetros no es correcta. Escriba './TP1EJ6.sh -h', './TP1EJ6.sh -?', o './TP1EJ6.sh -help' (sin comillas) para recibir ayuda"
    exit 1
fi

if  [ $1 != "-f" ];then
    echo "El primer parámetro debe ser '-f'"
    exit 2
fi

if [ ! -f "$2" ];then
    echo "El archivo que pasó por parámetro no existe"
    exit 3
fi

#Según el enunciado, un archivo vacío es válido. Así que no procesaré si me llega uno
if [ ! -s "$2" ];then
    echo "Archivo vacío"
    echo "El resultado de la fracción es: "
    echo "" > salida.out
    exit 4
fi

#Con esto salvo rutas relativas
archivo="$2"

#Declaro arrays asociativos para manejar
declare -a array
declare -A arrayDefinitivo
a=0

#Guardo la linea del archivo en una variable llamada array
while IFS= read -r line
do
    array[$i]+=$line
    let "i++"
done < $archivo

#Recorreré la variable
for i in ${array[@]}
do
     #Voy a separar la línea usando el delimitador de las comas. Cada número se guarda en una posiciòn de este nuevoArray
     IFS=', ' read -r -a nuevoArray <<< "$i"
     for i in ${nuevoArray[@]}  #Recorro cada uno de los números
     do
            if [[ $i =~ ":" ]]; then                                    #Reviso si hay dos puntos, lo que indica un numero mixto
                IFS=': ' read -r -a numberArray <<< "$i"                #Me quedo con el número que esté delante de los dos puntos
                IFS='/ ' read -r -a auxiliar <<< "${numberArray[1]}"    #Divido el número fraccionario en dos
                numerador=${auxiliar[1]}
                numerador=$((${numberArray[0]}*$numerador))
                numerador=$((${auxiliar[0]}+$numerador))
                e="$numerador/${auxiliar[1]}"
                arrayDefinitivo[$a]+=$e                                 #Después de hacer las cuentas necesarias, guardo el resultado en un arrayDefinitivo
            else
                arrayDefinitivo[$a]+=$i                                 #Si entré acá, entonces el número no es mixto y lo guardo directamente
            fi
            let "a++"
     done
done

#Empiezo a calcular el denominador
denominador=1
for i in ${arrayDefinitivo[@]}
do
    IFS='/ ' read -r -a nuevoArray <<< "$i"             #Divido cada nùmero del arrayDefinitivo
    comun_multiplo $denominador ${nuevoArray[1]}        #Llamo a la función comun_multiplo usando el valor anterior de la variable denominador y el denominador del número que saquè del array
    denominador=$mayor                                  #Guardo el resultado de la funciòn en la variable denominador
done

#Empiezo a calcular el numerador
numerador=0
for i in ${arrayDefinitivo[@]}
do
    IFS='/ ' read -r -a nuevoArray <<< "$i"                         #Divido cada número del arrayDefinitivo
    auxiliar=$(($denominador/${nuevoArray[1]}*${nuevoArray[0]}))    #Uso la variable auxiliar para hacer las cuentas necesarias
    numerador=$(($numerador+$auxiliar))                             #Acumulo los valores que voy obteniendo
done

#YA TERMINARON LAS CUENTAS. HASTA AHORA YA OBTUVE LOS VALORES DEL NUMERADOR Y EL DENOMINADOR

#Si el numerador es 0, el resultado general es 0. Así que guardo eso en el resultado y ya no sigo procesando
if [ $numerador -eq 0 ]; then
    echo "El resultado es: $numerador"
    echo "El resultado es: $numerador" > salida.out
    exit 85
fi

#El enunciado pide simplificar el resultado a su mínima expresión. Pero eso no se puede hacer si el numerador es negativo. 
negativo=0
if [ $numerador -lt 0 ];then            #Reviso si el numerador es negativo
    numerador=$(($numerador*(-1)))      #Si lo es, lo multiplico por -1 para hacerlo positivo
    negativo=1                          #Activo esta bandera para saber que tengo que cambiar su valor otra vez
fi

#Encuentro el comùn divisor para poder reducirlo hasta su última expresión
comun_divisor $numerador $denominador
cmdv=$?

#Reduzco el numerador y el denominador a su mìnima expresión
numerador=$(($numerador/$cmdv))
denominador=$(($denominador/$cmdv))

if [ $negativo -eq 1 ]; then
    numerador=$(($numerador*(-1)))          #Si el numerador original me dio negativo, lo multiplico por -1 para volverlo negativo otra vez
fi

if [ $denominador -eq 1 ];then                                      #Si el denominador es 1, solo guardo el numerador
    echo "El resultado es: $numerador"
    echo "El resultado es: $numerador" > salida.out
else
    echo "El resultado es: $numerador/$denominador"                     #Si el denominador no es 1, guardo ambos valores
    echo "El resultado es: $numerador/$denominador" > salida.out
fi