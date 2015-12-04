#!/bin/bash

# Shell script to export production databases and import them into staging databases.
# @author: "Austin Maddox" <amaddox@wps-inc.com>

if [ $# -lt 8 ]
then
    echo "Usage: refresh.sh source_host source_user source_password source_database target_host target_user target_password target_database"
    exit 0
fi

SOURCE_HOST=$1
SOURCE_USER=$2
SOURCE_PASSWORD=$3
SOURCE_DATABASE=$4

TARGET_HOST=$5
TARGET_USER=$6
TARGET_PASSWORD=$7
TARGET_DATABASE=$8

FILE=${SOURCE_DATABASE}.sql

DATA_EXCLUDED_TABLES=(
    accesslog
    cache
    cache_block
    cache_bootstrap
    cache_entity_node
    cache_field
    cache_filter
    cache_form
    cache_image
    cache_libraries
    cache_menu
    cache_page
    cache_path
    cache_token
    cache_update
    cache_views
    cache_views_data
    flood
    search_config_exclude
    search_dataset
    search_node_links
    search_total
    semaphore
    sessions
    watchdog
)

DATA_EXCLUDED_TABLES_STRING=''
for TABLE in "${DATA_EXCLUDED_TABLES[@]}"
do :
   DATA_EXCLUDED_TABLES_STRING+=" --ignore-table=${SOURCE_DATABASE}.${TABLE}"
done

# Export the database to file.
echo "Dumping structure..."
mysqldump --host=${SOURCE_HOST} --user=${SOURCE_USER} --password=${SOURCE_PASSWORD} --disable-keys --no-data --single-transaction ${SOURCE_DATABASE} > ${FILE}
echo "Finished dumping database structure."

echo "Dumping content..."
mysqldump --host=${SOURCE_HOST} --user=${SOURCE_USER} --password=${SOURCE_PASSWORD} --disable-keys --no-create-info --single-transaction ${DATA_EXCLUDED_TABLES_STRING} ${SOURCE_DATABASE} >> ${FILE}
echo "Finished dumping database content."

# Import the exported database file into the database.
echo "Importing the file..."
mysql --host=${TARGET_HOST} --user=${TARGET_USER} --password=${TARGET_PASSWORD} --database=${TARGET_DATABASE} --port=3306 --protocol=tcp --default-character-set=utf8 < ${FILE}
echo "Finished importing the file."
