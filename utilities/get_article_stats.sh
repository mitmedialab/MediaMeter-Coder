echo " ===== Total Articles ===="
echo "select count(*) from articles;" | mysql -u usworld usworld_dev

echo " ===== Non-Blacklisted Articles ===="
echo "select count(*) from articles WHERE blacklist_tag IS NULL;" | mysql -u usworld usworld_dev

echo " ===== Articles Per Source Per Year ===="
echo "select count(*), source, YEAR(pub_date) from articles WHERE blacklist_tag IS NULL GROUP BY source, YEAR(pub_date) ORDER BY source, YEAR(pub_date);" | mysql -u usworld usworld_dev
echo " ===== Articles Per Source Per Day ===="
echo "select count(*), source, pub_date from articles WHERE blacklist_tag IS NULL GROUP BY source, pub_date ORDER BY source, pub_date;" | mysql -u usworld usworld_dev

echo " ===== Blacklisted Articles Per Source Per Day ===="
echo "select count(*), source, pub_date from articles WHERE blacklist_tag IS NOT NULL GROUP BY source, pub_date ORDER BY source, pub_date;" | mysql -u usworld usworld_dev
