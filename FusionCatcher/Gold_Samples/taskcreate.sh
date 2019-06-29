#!/bin/bash

cat "~/Desktop/goldcells.txt" | while read fullpath; do

sample_name="${fullpath##*/}"
sample_name="${sample_name%*}"
url="$fullpath"
filep="$fullpath"
filename="${sample_name//./_}"
uid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

echo "$sample_name"
echo "$url"
echo "$filename"


task=$(cat <<EOF 
[{
  "id": "$uid",
  "displayName": "displayName",
  "commandLine": "/bin/bash -c 'unzip data_com.zip; rm data_com.zip; /opt/fusioncatcher/bin/fusioncatcher -d data/human_v90 -i ${sample_name}_1.fastq.gz,${sample_name}_2.fastq.gz -o $sample_name'",
  "resourceFiles": [
    {
      "httpUrl": "https://ccle.blob.core.windows.net/goldstand/data_com.zip",
      "filePath": "data_com.zip",
      "blobSource":"https://ccle.blob.core.windows.net/goldstand/data_com.zip"
    },

    {
      "httpUrl": "$url/${sample_name}_1.fastq.gz",
      "filePath": "${sample_name}_1.fastq.gz",
      "blobSource":"$url/${sample_name}_1.fastq.gz"
    },

   {
      "httpUrl": "$url/${sample_name}_2.fastq.gz",
      "filePath": "${sample_name}_2.fastq.gz",
      "blobSource":"$url/${sample_name}_2.fastq.gz"
    }
  ],
"outputFiles": [
    {
      "filePattern": "$sample_name/*",
      "destination":{
        "container":{
          "containerUrl": "https://ccle.blob.core.windows.net/goldstandresults?st=2019-02-21T23%3A02%3A00Z&se=2019-04-24T00%3A02%3A00Z&sp=rwl&sv=2018-03-28&sr=c&sig=riIeVOW51b4OEqj1GliCCDu8xKCcfjgGGTKsz0yKqao%3D",
          "path": "$sample_name"
        }

      },

      "uploadOptions":{
        "uploadCondition": "taskcompletion"
      }

    }
  ],

  "userIdentity": {
  "autoUser": {
  "elevationLevel": "admin"

            }
    }
}]
EOF
) 

echo "$task" >> ~/Desktop/json/$filename.json

cd ~/Desktop/json/

az batch task create \
    --job-id job1 \
    --json-file $filename.json


done



