#!/bin/bash
# Skrypt ma za zadanie przenosić bazę danych z głównej bazy do bazy testowej. 

# Nazwy Baz danych w systemie
glowna="PROD"
testowa="TEST"
# Sprawdzenie dzisiejszej daty
timestamp=`date +"%d-%m-%Y %H:%M:%S"`
date=`date +"%d-%m-%Y"`
# Ilość przechowywanych baz w folderze tymczasowym
days=14

# Plik z logami skryptu
LOG=/var/log/migrate_databases.log


echo "Raport przenoszenia bazy danych ($date)" >> $LOG

echo "Rodzpoczęcie działania skryptu. ($timestamp)" >> $LOG



# Zamykanie wszystkich połączeń firebirda
/etc/init.d/xinetd stop
sleep 10
    echo "Zamknięcie wszystkich aktywnych procesów firebirda" >> $LOG
    killall fb_inet_server &>/dev/null
    echo "Zamknięcie wszystkich pozostałych procesów firebirda" >> $LOG
sleep 60
    killall -9 fb_inet_server &>/dev/null
    echo "Pomyślnie zamknięto wszystkie procesy firebird ($timestamp) " >> $LOG
sleep 10

# Przenoszenie bazy testowej do zapasowego folderu 
echo "Przenoszenie bazy testowej do zapasowego folderu ($timestamp)"  >> $LOG
cp -r /data01/db/"$testowa"_____DD.ib /hdd/migrate_databases/"$testowa"_____DD.ib_$date
cp -r /data01/db/"$testowa".ib /hdd/migrate_databases/"$testowa".ib_$date

# Usunięcie starych baz danych z forlderu tymczasowego
echo "Usuwanie baz w folderze tymczasowym starszych niż X dni ($timestamp)" >> $LOG

find "/hdd/migrate_databases/" -mtime +$days -name '"$testowa"_____DD.ib*' -type f -delete
find "/hdd/migrate_databases/" -mtime +$days -name '"$testowa".ib*' -type f  -delete

sleep 10
echo "Pomyślnie zamknięto wszystkie procesy firebird ($timestamp)" >> $LOG


# Przenoszenie głównej bazy danych do bazy TESTOWEJ
echo "Przenoszenie głównej bazy danych do bazy TESTOWEJ ($timestamp)"
cp -r /data01/db/"$glowna"____DD.ib /data01/db/"$testowa"_____DD.ib
cp -r /data01/db/"$glowna".ib /data01/db/"$testowa".ib
chown firebird.firebird /data01/db/"$testowa".ib

sleep 10
echo "Pomyślnie zamknięto wszystkie procesy firebird ($timestamp)" >> $LOG
echo "Pomyślnie przeniesiono bazę danych... ($timestamp)" >> $LOG
echo "Uruchomienie Xintet ($timestamp)" >> $LOG

/etc/init.d/xinetd restart

echo "Pomyślnie przeniesiono bazę główną do bazy testowej ($timestamp)" >> $LOG
