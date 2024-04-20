create database if not exists ${DB};
use ${DB};

drop table if exists orders;

create table orders
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.orders
cluster by o_orderdate
;
