AIRTABLE_TOKEN=$1

#curl "https://api.airtable.com/v0/appFDFb3CkxWHXrd5/Users?view=All%20participants" -H "Authorization: Bearer ${AIRTABLE_TOEN}" > ./_data/users.json
bundle exec ruby fetch-students.ruby $AIRTABLE_TOKEN > ./_data/students.csv
echo "downloaded students"
wc -l ./_data/students.csv
## curl https://docs.google.com/spreadsheets/d/1cBI0lZsgGoZkdREyhBSgkI6fFSLHLIlSTNW7JCeO3hU/gviz/tq?tqx=out:csv > ./_data/students.csv

curl https://docs.google.com/spreadsheets/d/1Sz6IRJWDhzJLJnlAtrQknTsw470nTe5enPr8k3bXs1Q/gviz/tq?tqx=out:csv > ./_data/homeworks.csv
curl https://docs.google.com/spreadsheets/d/1ycYPofJUu3bQ4hyV6RoNzZydKVEpvqPQtFHHBPs8pvI/gviz/tq?tqx=out:csv > ./_data/homework-reviews.csv

curl "https://docs.google.com/spreadsheets/d/1hDvboEzKWpmYxl9VNzXKnY9ph8FBNKyDWOV7JurhlvU/gviz/tq?tqx=out:csv&sheet=kotlin" > ./_data/kotlin-attendees.csv
curl "https://docs.google.com/spreadsheets/d/1hDvboEzKWpmYxl9VNzXKnY9ph8FBNKyDWOV7JurhlvU/gviz/tq?tqx=out:csv&sheet=project" > ./_data/project-attendees.csv
#TODO: add each workshop

curl https://docs.google.com/spreadsheets/d/1U2TRkH_8oiHnzacwkjzXD-q2XhqvmAIp759iMYxlXKI/gviz/tq?tqx=out:csv > ./_data/students-helps.csv