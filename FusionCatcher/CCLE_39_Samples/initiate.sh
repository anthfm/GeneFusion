#!/bin/bash


az batch account create \
    --name genef \
    --storage-account gray \
    --resource-group rgUHN_Research_BHKLab \
    --location centralus

az batch account login \
    --name genef \
    --resource-group rgUHN_Research_BHKLab \
    --shared-key-auth


az batch pool create \
    --json-file pool.json



az batch job create \
    --id jobtestd5 \
    --pool-id poolfusion


az batch task create \
    --job-id jobtestd5 \
    --json-file G28055_KU812_1.json


