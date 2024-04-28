create database if not exists ${DB};
use ${DB};

drop table if exists supplier;

create table supplier
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.supplier
cluster by s_nationkey, s_suppkey
;
