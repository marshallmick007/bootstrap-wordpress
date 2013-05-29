#!/bin/bash

WORDPRESS_ZIP="latest.zip"

DIR="`pwd`/www"
LOGS="`pwd`/logs"
echo $DIR

DBUSER='webuser'
DBPASS='password'

WHOAMI=$(basename `pwd`)
MYSQL=/Applications/MAMP/Library/bin/mysql

# Make the logs folder for NGINX
if [[ ! -d "${LOGS}" ]] ; then
  mkdir "${LOGS}"
fi

# try to download and extract wordpress if the 'www' folder does not exist
if [[ -d "${DIR}" || -L "${DIR}" ]] ; then
  echo "Wordpress is already installed here... skipping"
else
  if [[ -f "${WORDPRESS_ZIP}" ]] ; then
    rm ${WORDPRESS_ZIP}
  fi
  wget https://wordpress.org/latest.zip
  unzip latest.zip
  mv wordpress www
fi

# If there is no wp-config.php file, then lets try to create a DB
if [[ ! -f "${DIR}/wp-config.php" ]] ; then
  DBNAME="${WHOAMI/./_}_wp"
  echo "Looking for MySql database ${DBNAME}..."
  DBEXISTS=`${MYSQL} -u root -p -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${DBNAME}'" 2>&1`
  if [[ -z "${DBEXISTS}" ]] ; then
    Q1="CREATE DATABASE IF NOT EXISTS ${DBNAME};"
    Q2="GRANT ALL ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"

    ${MYSQL} -u root -p -e "${SQL}"
    
    sed -e "s/username_here/${DBUSER}/g" -e "s/password_here/${DBPASS}/g" \
      -e "s/database_name_here/${DBNAME}/g" "${DIR}/wp-config-sample.php" > "${DIR}/wp-config.php"
  else
    echo "database exists, need to create 'wp-config.php by hand'"
  fi

fi

# TODO: extract a sample underscor.es theme to www/wp-content/themes

