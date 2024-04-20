create database if not exists ${DB};
use ${DB};

drop table if exists customer;

create table customer
${ICEBERG} stored as ${FILE}
TBLPROPERTIES('orc.bloom.filter.columns'='*','orc.compress'='ZLIB')
as select * from ${SOURCE}.customer
cluster by C_MKTSEGMENT
;

