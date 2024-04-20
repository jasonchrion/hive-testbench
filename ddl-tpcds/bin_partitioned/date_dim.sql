create database if not exists ${DB};
use ${DB};

drop table if exists date_dim;

create table date_dim
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.date_dim;
