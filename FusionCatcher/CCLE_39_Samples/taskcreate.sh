#!/bin/bash

cat "~/Desktop/intersect.txt" | while read fullpath; do

sample_name="${fullpath##*/}"
sample_name="${sample_name%.*}"
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
  "commandLine": "/bin/bash -c 'docker run --rm -v \$PWD:\$PWD -w \$PWD bhklab/picard-2.17.2 java -jar /usr/bin/picard.jar SamToFastq I=$sample_name.bam F=${sample_name}_1.fastq.gz F2=${sample_name}_2.fastq.gz'",
  "resourceFiles": [
    {
      "httpUrl": "$url",
      "filePath": "$sample_name.bam",
      "blobSource":"$filep"
    }
  ],
"outputFiles": [
    {
      "filePattern": "*.fastq.gz",
      "destination":{
        "container":{
          "containerUrl": "https://ccle.blob.core.windows.net/fusion-39?st=2019-03-02T12%3A32%3A00Z&se=2019-05-24T13%3A32%3A00Z&sp=rwl&sv=2018-03-28&sr=c&sig=DjPx18OeZmGpDgUVEjwF8fvi0Ou1oV3g%2FlLn10%2FYu4Y%3D",
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

echo "$task" >> ~/Desktop/json/$sample_name.json

cd ~/Desktop/json/

az batch task create \
    --job-id job1 \
    --json-file $sample_name.json


done



