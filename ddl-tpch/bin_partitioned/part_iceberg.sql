create database if not exists ${DB};
use ${DB};

drop table if exists part;

create table part
stored by iceberg
stored as ${FILE}
as select * from ${SOURCE}.part
cluster by p_brand
;
