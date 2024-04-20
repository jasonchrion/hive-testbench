create database if not exists ${DB};
use ${DB};

drop table if exists warehouse;

create table warehouse
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.warehouse;
