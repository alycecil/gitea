#!/bin/bash

echo "arg1 github token"
echo "arg2 gitea token"
echo "if youre not me youll need to edit this to point at you, its not that smart."

sudo apt update && sudo apt install -y git jq curl sed

GITHUB_USERNAME=alycecil
GITHUB_TOKEN=$1
GITHUB_ORGANISATION=alycecil

GITEA_USERNAME=admin
GITEA_TOKEN=$2
GITEA_DOMAIN=localhost:3000
GITEA_REPO_OWNER=alices_github


PAGE=1
length=1

while [ 0 -lt "$length" ];
do
#GET_CURL=$(curl -H 'Accept: application/vnd.github.v3+json' -u $GITHUB_USERNAME:$GITHUB_TOKEN -s "https://api.github.com/orgs/$GITHUB_ORGANISATION/repos?per_page=200&type=all")
GET_CURL=$(curl -H 'Accept: application/vnd.github.v3+json' -u $GITHUB_USERNAME:$GITHUB_TOKEN -s "https://api.github.com/users/$GITHUB_ORGANISATION/repos?per_page=100&type=all&page=${PAGE}")

echo $GET_CURL

GET_REPOS=$(echo $GET_CURL | jq -r '.[].html_url')

length=$(echo $GET_CURL | jq '. | length')

echo page=${PAGE} length=$length

for URL in $GET_REPOS; do

    REPO_NAME=$(echo $URL | sed "s|https://github.com/$GITHUB_ORGANISATION/||g" | sed -r 's|.+/||g')

    echo "Found $REPO_NAME, importing..."

    PAYLOAD="{  \
    \"auth_username\": \"$GITHUB_USERNAME\", \
    \"auth_password\": \"$GITHUB_TOKEN\", \
    \"clone_addr\": \"$URL\", \
    \"mirror\": false, \
    \"private\": true, \
    \"repo_name\": \"$REPO_NAME\", \
    \"repo_owner\": \"$GITEA_REPO_OWNER\", \
    \"service\": \"git\", \
    \"uid\": 0, \
    \"lfs\": true, \
    \"releases\": true, \
    \"issues\": true, \
    \"labels\": true, \
    \"wiki\": true \
    }"

    echo PAYLOAD=${PAYLOAD}

    curl -X POST "https://$GITEA_DOMAIN/api/v1/repos/migrate" -u $GITEA_USERNAME:$GITEA_TOKEN -H  "accept: application/json" -H  "Content-Type: application/json" -d "${PAYLOAD}"

#       exit 1

done

(( PAGE++ ))

done




