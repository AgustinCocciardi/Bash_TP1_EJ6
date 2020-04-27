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
    echo "El segundo parámetro debe ser '-f'"
    exit 2
fi

if [ ! -f "$2" ];then
    echo "El archivo que pasó por parámetro no existe"
    exit 3
fi

if [ ! -s "$2" ];then
    echo "Archivo vacío"
    echo "El resultado de la fracción es: "
    echo "" > salida.out
    exit 4
fi

archivo="$2"

declare -a array
declare -A arrayDefinitivo
a=0

while IFS= read -r line
do
    array[$i]+=$line
    let "i++"
done < $archivo

for i in ${array[@]}
do
     IFS=', ' read -r -a nuevoArray <<< "$i"
     for i in ${nuevoArray[@]}
     do
            if [[ $i =~ ":" ]]; then
                IFS=': ' read -r -a numberArray <<< "$i"
                IFS='/ ' read -r -a auxiliar <<< "${numberArray[1]}"
                numerador=${auxiliar[1]}
                numerador=$((${numberArray[0]}*$numerador))
                numerador=$((${auxiliar[0]}+$numerador))
                e="$numerador/${auxiliar[1]}"
                arrayDefinitivo[$a]+=$e
            else
                arrayDefinitivo[$a]+=$i
            fi
            let "a++"
     done
done

denominador=1
for i in ${arrayDefinitivo[@]}
do
    IFS='/ ' read -r -a nuevoArray <<< "$i"
    comun_multiplo $denominador ${nuevoArray[1]}
    denominador=$mayor
done

numerador=0
for i in ${arrayDefinitivo[@]}
do
    IFS='/ ' read -r -a nuevoArray <<< "$i"
    auxiliar=$(($denominador/${nuevoArray[1]}*${nuevoArray[0]}))
    numerador=$(($numerador+$auxiliar))
done

if [ $numerador -eq 0 ]; then
    echo "El resultado es: $numerador"
    echo "El resultado es: $numerador" > salida.out
    exit 85
fi

negativo=0
if [ $numerador -lt 0 ];then
    numerador=$(($numerador*(-1)))
    negativo=1
fi

comun_divisor $numerador $denominador
cmdv=$?

numerador=$(($numerador/$cmdv))
denominador=$(($denominador/$cmdv))

if [ $negativo -eq 1 ]; then
    numerador=$(($numerador*(-1)))
fi

if [ $denominador -eq 1 ];then
    echo "El resultado es: $numerador"
    echo "El resultado es: $numerador" > salida.out
else
    echo "El resultado es: $numerador/$denominador"
    echo "El resultado es: $numerador/$denominador" > salida.out
fi