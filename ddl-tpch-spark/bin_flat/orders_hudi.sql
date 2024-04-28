create database if not exists ${DB};
use ${DB};

drop table if exists orders;

create table orders
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.orders
cluster by O_ORDERDATE
;
