#!/usr/local/bin/bash

STAPLERS="1 2"

case $1 in
   config)
	echo graph_title Stapler Usage by day
	echo graph_vlabel Movements

	for i in $STAPLERS; do
		echo ST${i}_Holen_200.label Stapler ${i} Retrieve
		echo ST${i}_Holen_404.label Stapler ${i} Failed retrieve
		echo ST${i}_Holen_fehler.label Stapler ${i} Fehler meldung
	done
	exit 0;;
esac

#create a temporary cache, so its more efficient
TEMPFILE=`mktemp /tmp/staplr-XXXXXX`

#echo $TEMPFILE

TODAY=`date "+%d/%b/%Y:"`

for i in $STAPLERS; do 
    grep $TODAY /var/log/httpd-access.log | grep /intern/mypl/beleg/stapler/${i}/ > $TEMPFILE

    echo -n ST${i}_Holen_200.value
    grep /intern/mypl/beleg/stapler/${i}/holen/ $TEMPFILE | grep HTTP/1.1\"\ 200 | wc -l

    echo -n ST${i}_Holen_404.value
    grep /intern/mypl/beleg/stapler/${i}/holen/ $TEMPFILE | grep HTTP/1.1\"\ 404 | wc -l

    echo -n ST${i}_Holen_fehler.value
    grep /intern/mypl/beleg/stapler/${i}/fehler $TEMPFILE | grep HTTP/1.1\"\ 200 | wc -l


done

#cleanup
rm $TEMPFILE
