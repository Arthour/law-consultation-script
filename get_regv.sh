#!/bin/bash
#parmeters for the RIS API
Regv_par='?Applikation=Regv&BeschlussdatumVon=2013-10-29&BeschlussdatumBis=2017-11-08&DokumenteProSeite=OneHundred'

mkdir -p ./data/regv/

#Get the 5 Datasets includet in the research object
for ii in $(seq 1 5); do

  #RIS API request for all
  curl -o './data/regv/Regv_data-'$ii'.json' 'https://data.bka.gv.at/ris/api/v2.5/bundesgesetzblaetter'$Regv_par'&Seitennummer='$ii

  #Parse 1 of 100 Datasets
  for i in $(seq 0 99); do
    echo 'read and write Dataset number '$i' of side '$ii

    #read all the titeles and uris of all the bills in the last legislativ periode
    Regv_name="$(cat './data/regv/Regv_data-'$ii'.json' | jq '.OgdSearchResult.OgdDocumentResults.OgdDocumentReference['$i'].Data.Metadaten.Bundesgesetzblaetter.Titel')"
    echo $Regv_name
    Regv_url_all="$(cat './data/regv/Regv_data-'$ii'.json' | jq '.OgdSearchResult.OgdDocumentResults.OgdDocumentReference['$i'].Data.Metadaten.Allgemein.DokumentUrl')"
    echo $Regv_url_all
    Regv_url_html="$(cat './data/regv/Regv_data-'$ii'.json' | jq '.OgdSearchResult.OgdDocumentResults.OgdDocumentReference['$i'].Data.Dokumentliste.ContentReference[0].Urls.ContentUrl[1].Url')"
    echo $Regv_url_html

    #write csv file
    echo $Regv_name";"$Regv_url_all";"$Regv_url_html >> ./data/regv/RegV_sample.csv

  done

done
