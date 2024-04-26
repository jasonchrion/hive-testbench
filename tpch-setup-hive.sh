#!/bin/bash

function usage {
  echo "Usage: tpch-setup.sh scale_factor [temp_directory]"
  exit 1
}

function runcommand {
  if [ "X$DEBUG_SCRIPT" != "X" ]; then
    $1
  else
    $1 2>/dev/null
  fi
}

if [ ! -f tpch-gen/target/tpch-gen-1.0.jar ]; then
  echo "Please build the data generator with ./tpch-build.sh first"
  exit 1
fi

# Tables in the TPC-H schema.
TABLES="part partsupp supplier customer orders lineitem nation region"

# Get the parameters.
SCALE=$1
DIR=$2
BUCKETS=13
if [ "X$DEBUG_SCRIPT" != "X" ]; then
  set -x
fi

# Sanity checking.
if [ X"$SCALE" = "X" ]; then
  usage
fi
if [ X"$DIR" = "X" ]; then
  DIR=/tmp/tpch-generate
fi
if [ $SCALE -eq 1 ]; then
  echo "Scale factor must be greater than 1"
  exit 1
fi

# Do the actual data load.
hdfs dfs -mkdir -p ${DIR}
hdfs dfs -ls ${DIR}/${SCALE} > /dev/null
if [ $? -ne 0 ]; then
  echo "Generating data at scale factor $SCALE."
  (cd tpch-gen; hadoop jar target/*.jar -d ${DIR}/${SCALE}/ -s ${SCALE})
fi
hdfs dfs -ls ${DIR}/${SCALE} > /dev/null
if [ $? -ne 0 ]; then
  echo "Data generation failed, exiting."
  exit 1
fi

hadoop fs -chmod -R 777  ${DIR}/${SCALE}

echo "TPC-H text data generation complete."

#ENGINE="beeline -n root -u 'jdbc:hive2://localhost:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2?tez.queue.name=default' "
ENGINE="beeline -n root -u 'jdbc:hive2://localhost:10000?tez.queue.name=default' "

# Create the text/flat tables as external tables. These will be later be converted to ORCFile.
echo "Loading text data into external tables."
runcommand "$ENGINE -i settings/load-flat.sql -f ddl-tpch-hive/text/alltables.sql --hivevar DB=tpch_text_${SCALE} --hivevar LOCATION=${DIR}/${SCALE}"

# Create the optimized tables.
if [ "X$FORMAT" = "X" ]; then
  FORMAT=orc
fi

LOAD_FILE="load_${FORMAT}_${SCALE}.mk"
SILENCE="2> /dev/null 1> /dev/null" 
if [ "X$DEBUG_SCRIPT" != "X" ]; then
  SILENCE=""
fi

echo -e "all: ${TABLES}" > $LOAD_FILE

i=1
total=8
DATABASE=tpch_${FORMAT}_${SCALE}
MAX_REDUCERS=2600 # ~7 years of data
REDUCERS=$((test ${SCALE} -gt ${MAX_REDUCERS} && echo ${MAX_REDUCERS}) || echo ${SCALE})

for t in ${TABLES}
do
  tbl=$t;
  if [ "X$ICEBERG" != "X" ]; then
    tbl=$t"_iceberg"
  fi
  COMMAND="$ENGINE -i settings/load-partitioned.sql -f ddl-tpch-hive/bin_partitioned/${tbl}.sql \
    --hivevar DB=${DATABASE} \
    --hivevar SCALE=${SCALE} \
    --hivevar SOURCE=tpch_text_${SCALE} \
    --hivevar BUCKETS=${BUCKETS} \
    --hivevar REDUCERS=${REDUCERS} \
    --hivevar FILE=${FORMAT}"
  echo -e "${t}:\n\t@$COMMAND $SILENCE && echo 'Optimizing table $t ($i/$total).'" >> $LOAD_FILE
  i=`expr $i + 1`
done

make -j 1 -f $LOAD_FILE

echo "Analyzing table"
runcommand "$ENGINE -f ddl-tpch-hive/bin_partitioned/analyze.sql --hivevar DB=${DATABASE} --hivevar REDUCERS=${REDUCERS}"

echo "Data loaded into database ${DATABASE}."
