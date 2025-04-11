#!/bin/bash

echo "Introduce el primer número:"
read num1

echo "Introduce el segundo número:"
read num2

echo "Introduce el tercer número:"
read num3

# Realizar el cálculo
result=$((num1 + num2 + num3))

# Mostrar el resultado
echo
echo "El resultado de la suma es: $result"
