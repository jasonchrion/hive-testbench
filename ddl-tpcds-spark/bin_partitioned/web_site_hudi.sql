create database if not exists ${DB};
use ${DB};

drop table if exists web_site;

create table web_site
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.web_site;
