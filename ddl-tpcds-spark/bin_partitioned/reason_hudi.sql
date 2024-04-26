create database if not exists ${DB};
use ${DB};

drop table if exists reason;

create table reason
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.reason;
