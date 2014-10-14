#!/bin/bash

pdf=/tmp/p.pdf
txt=/tmp/p.txt
sql=/tmp/p.sql

# Bolivia

function dl_sql {
rm $pdf
rm $txt
wget http://computo2014.oep.org.bo/nal/p${1}.PDF -O $pdf
/usr/bin/pdftotext -raw $pdf $txt

num=$(tail -n 5 $txt | grep '[[:digit:]]\+ de [[:digit:]]\+');
porc=$(tail -n 5 $txt | grep '[[:digit:],]\+%');
fecha=$(tail -n 5 $txt | grep -o '[[:digit:]]\+/[[:digit:]]\+/[[:digit:]]\+ [[:digit:]]\+:[[:digit:]]\+:[[:digit:]]\+');
observacion=$(printf "Conteo parcial: %s (%s) a la fecha: %s" "${porc}" "${num}" "${fecha}");

cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/MAS-IPSP%/SELECT f_insert_resultado_2014_plurinacional_votos(25, '${2}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_plurinacional_votos | sed "s@);@,'$observacion');@" >> $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/PDC%/SELECT f_insert_resultado_2014_plurinacional_votos(43, '${2}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_plurinacional_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/PVB-IEP%/SELECT f_insert_resultado_2014_plurinacional_votos(87, '${2}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_plurinacional_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/UD%/SELECT f_insert_resultado_2014_plurinacional_votos(88, '${2}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_plurinacional_votos | sed "s@);@,'$observacion');@" >>  $sql
cat $txt | sed 's/ [0-9\.,]*\%/\%/' | sed 's/MSM%/SELECT f_insert_resultado_2014_plurinacional_votos(86, '${2}', %/' | sed 's/%[0-9]*/&);/' | sed 's/%//'  | grep f_insert_resultado_2014_plurinacional_votos | sed "s@);@,'$observacion');@" >>  $sql
}

rm $sql
# Bolivia
dl_sql 0 1
# Chuquisaca
dl_sql 1 10
# La Paz
dl_sql 2 2
# Cochabamba
dl_sql 3 3
# Oruro
dl_sql 4 4
# Potosí
dl_sql 5 5
# Tarija
dl_sql 6 6
# Santa Cruz
dl_sql 7 7
# Beni
dl_sql 8 8
# Pando
dl_sql 9 9
