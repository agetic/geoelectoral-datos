#!/bin/bash

pdf=/tmp/uni.pdf
txt=/tmp/uni.txt
sql=/tmp/uni.sql

# Bolivia

function dl_sql_uni {
rm $pdf
rm $txt
wget http://www.oep.org.bo/Computo2014/nal/c${1}.PDF -O $pdf
/usr/bin/pdftotext -raw $pdf $txt

num=$(tail -n 5 $txt | grep '[[:digit:]]\+ de [[:digit:]]\+');
porc=$(tail -n 5 $txt | grep '[[:digit:],]\+%');
fecha=$(tail -n 5 $txt | grep -o '[[:digit:]]\+/[[:digit:]]\+/[[:digit:]]\+ [[:digit:]]\+:[[:digit:]]\+:[[:digit:]]\+');
observacion=$(printf "Conteo parcial: %s (%s) a la fecha: %s" "${porc}" "${num}" "${fecha}");

cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/MAS-IPSP%/SELECT f_insert_resultado_2014_uninominal_votos(25, '${1}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_uninominal_votos | sed "s@);@,'$observacion');@" >> $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/PDC%/SELECT f_insert_resultado_2014_uninominal_votos(43, '${1}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_uninominal_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/PVB-IEP%/SELECT f_insert_resultado_2014_uninominal_votos(87, '${1}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_uninominal_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/UD%/SELECT f_insert_resultado_2014_uninominal_votos(88, '${1}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_uninominal_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/MSM%/SELECT f_insert_resultado_2014_uninominal_votos(86, '${1}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_uninominal_votos | sed "s@);@,'$observacion');@" >>  $sql
}

rm $sql
# Circunscripciones
for i in {1..63}
do
  dl_sql_uni "${i}"
done
