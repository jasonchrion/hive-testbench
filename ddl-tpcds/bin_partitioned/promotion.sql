create database if not exists ${DB};
use ${DB};

drop table if exists promotion;

create table promotion
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.promotion;
