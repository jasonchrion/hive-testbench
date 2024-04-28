create database if not exists ${DB};
use ${DB};

drop table if exists lineitem;

create table lineitem
stored as ${FILE}
select * from ${SOURCE}.lineitem
cluster by L_SHIPDATE
;
