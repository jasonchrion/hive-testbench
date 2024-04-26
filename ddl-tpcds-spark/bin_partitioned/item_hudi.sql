create database if not exists ${DB};
use ${DB};

drop table if exists item;

create table item
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
as select * from ${SOURCE}.item
CLUSTER BY i_item_sk
;
