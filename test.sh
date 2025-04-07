clear
echo -en "\rhello"
echo
for i in {1..10}
do
  echo -ne "\rHello $i"
  sleep 1
done
