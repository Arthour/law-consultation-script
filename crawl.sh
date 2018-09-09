#!/bin/bash
#parameters for the RIS API

#parsing the law.html from RIS
function save_law {
  temp_law_filename=$1
  temp_law_url=$2

  echo 'get data from '$temp_law_url
  curl -o $temp_law_filename".html" $temp_law_url
  echo 'save data to '$temp_law_filename

  echo 'convert html to text'
  maxWidth=$(echo "2^(32-1)-1" | bc) #max width of cli for the html2text converter
  html2text -width $maxWidth -o $temp_law_filename".txt" $temp_law_filename".html"

  echo -e 'done '$temp_law_filename
}

for line in $(seq 0 242); do
  sample_line=$(cat ./data/bills/sample-1-diff.csv | sed -n $line"p")
  echo $sample_line

  mkdir -p "./data/bills/"$(echo $sample_line | csvtool -t ';' col 2 -)"/"

  #Begut
  #get the URL of the consultation bills HTML
  Begut_url=$(echo $sample_line | csvtool -t ';' col 3 -)
  Begut_filename="./data/bills/"$(echo $sample_line | csvtool -t ';' col 2 -)"/Begut"
  save_law $Begut_filename $Begut_url
  echo -e 'saved '$Begut_url' in '$Begut_filename

  #RegV
  #get the URL of the council bills HTML
  Regv_url=$(echo $sample_line | csvtool -t ';' col 4 -)
  Regv_filename="./data/bills/"$(echo $sample_line | csvtool -t ';' col 2 -)"/RegV"
  save_law $Regv_filename $Regv_url
  echo -e 'saved '$Regv_url' in '$Regv_filename

  diff -w -B $Begut_filename".txt" $Regv_filename".txt" > ./data/bills/test.diff
  diffstat -s ./data/bills/test.diff >> ./data/bills/diffstat.csv

  sleep 1s
done
