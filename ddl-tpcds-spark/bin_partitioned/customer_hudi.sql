create database if not exists ${DB};
use ${DB};

drop table if exists customer;

create table customer
using hudi
tblproperties(
 hoodie.table.base.file.format='${FILE}'
)
as select * from ${SOURCE}.customer
CLUSTER BY c_customer_sk
;
