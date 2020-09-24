#!/bin/bash
set -x
set -e
set -o pipefail

URL=$1
BRANCH=$2
DEPLOY_CONFIG=$3
BUNDLE=$4
DRAFTS=$5
SRC=$(pwd)
TEMP=$(mktemp -d -t jgd-XXX)
trap "rm -rf ${TEMP}" EXIT

echo -e "\nBuilding Jekyll site:"
rm -rf _site

if [ -r ${DEPLOY_CONFIG} ]; then
  ${BUNDLE} jekyll build --config _config.yml,${DEPLOY_CONFIG} ${DRAFTS}
else
  ${BUNDLE} jekyll build ${DRAFTS}
fi

if [ ! -e _site ]; then
  echo -e "\nJekyll didn't generate anything in _site!"
  exit -1
fi

CLONE=${TEMP}/clone
echo -e "Cloning Github repository:"
git clone -b "${BRANCH}" "${URL}" "${CLONE}"
cd ${CLONE}

echo -e "\nDeploying into ${BRANCH} branch:"
rm -rf *
cp -R ../../_site/* .
rm -f README.md
git add .
git commit -am "new version $(date)" --allow-empty
git push origin ${BRANCH} 2>&1 | sed 's|'$URL'|[skipped]|g'

echo -e "\nCleaning up:"
rm -rf "${CLONE}"
rm -rf "${SITE}"