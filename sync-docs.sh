AIRTABLE_TOEN=$1

curl "https://api.airtable.com/v0/appFDFb3CkxWHXrd5/Users?view=All%20participants" -H "Authorization: Bearer ${AIRTABLE_TOEN}" > ./_data/users.json
bundle exec ruby convert-students.ruby > ./_data/students.csv

## curl https://docs.google.com/spreadsheets/d/1cBI0lZsgGoZkdREyhBSgkI6fFSLHLIlSTNW7JCeO3hU/gviz/tq?tqx=out:csv > ./_data/students.csv
curl https://docs.google.com/spreadsheets/d/1Sz6IRJWDhzJLJnlAtrQknTsw470nTe5enPr8k3bXs1Q/gviz/tq?tqx=out:csv > ./_data/homeworks.csv
curl https://docs.google.com/spreadsheets/d/1ycYPofJUu3bQ4hyV6RoNzZydKVEpvqPQtFHHBPs8pvI/gviz/tq?tqx=out:csv > ./_data/homework-reviews.csv
curl https://docs.google.com/spreadsheets/d/1U2TRkH_8oiHnzacwkjzXD-q2XhqvmAIp759iMYxlXKI/gviz/tq?tqx=out:csv > ./_data/students-helps.csv
