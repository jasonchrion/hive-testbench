create database if not exists ${DB};
use ${DB};

drop table if exists lineitem;

create table lineitem 
(L_ORDERKEY BIGINT,
 L_PARTKEY BIGINT,
 L_SUPPKEY BIGINT,
 L_LINENUMBER INT,
 L_QUANTITY DOUBLE,
 L_EXTENDEDPRICE DOUBLE,
 L_DISCOUNT DOUBLE,
 L_TAX DOUBLE,
 L_RETURNFLAG STRING,
 L_LINESTATUS STRING,
 L_COMMITDATE DATE,
 L_RECEIPTDATE DATE,
 L_SHIPINSTRUCT STRING,
 L_SHIPMODE STRING,
 L_COMMENT STRING)
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}',
 hoodie.embed.timeline.server=false,
 hoodie.metadata.enable=false
)
partitioned by (L_SHIPDATE DATE)
;

INSERT OVERWRITE TABLE lineitem 
select 
 L_ORDERKEY ,
 L_PARTKEY ,
 L_SUPPKEY ,
 L_LINENUMBER ,
 L_QUANTITY ,
 L_EXTENDEDPRICE ,
 L_DISCOUNT ,
 L_TAX ,
 L_RETURNFLAG ,
 L_LINESTATUS ,
 L_COMMITDATE ,
 L_RECEIPTDATE ,
 L_SHIPINSTRUCT ,
 L_SHIPMODE ,
 L_COMMENT ,
 L_SHIPDATE
from ${SOURCE}.lineitem
;

