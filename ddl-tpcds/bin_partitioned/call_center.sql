create database if not exists ${DB};
use ${DB};

drop table if exists call_center;

create table call_center
${ICEBERG} stored as ${FILE}
as select * from ${SOURCE}.call_center;
