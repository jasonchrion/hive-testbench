create database if not exists ${DB};
use ${DB};

drop table if exists nation;

create table nation
stored by iceberg
stored as ${FILE}
as select distinct * from ${SOURCE}.nation;
