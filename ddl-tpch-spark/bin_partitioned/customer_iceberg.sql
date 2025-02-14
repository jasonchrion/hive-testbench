create database if not exists ${DB};
use ${DB};

drop table if exists customer;

create table customer
using iceberg
tblproperties(
 'write.format.default'='${FILE}'
)
as select * from ${SOURCE}.customer
cluster by C_MKTSEGMENT
;
