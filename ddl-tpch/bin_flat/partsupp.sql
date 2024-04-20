create database if not exists ${DB};
use ${DB};

drop table if exists partsupp;

create table partsupp
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.partsupp
cluster by PS_SUPPKEY
;
