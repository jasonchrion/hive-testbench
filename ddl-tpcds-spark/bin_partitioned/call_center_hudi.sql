create database if not exists ${DB};
use ${DB};

drop table if exists call_center;

create table call_center
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.call_center;
