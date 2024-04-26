create database if not exists ${DB};
use ${DB};

drop table if exists customer;

create table customer
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.customer
cluster by C_MKTSEGMENT
;

