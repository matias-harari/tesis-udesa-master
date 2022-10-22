*0_master.do

global main "/home/matias/Documents/Research/UDESA/10.Tesis/tesis_harari/"

global output "$main/output"
global input "$main/input"
global programs"$main/programs"

cd "$output/data"
clear

* 0. matching_teams.do
	* Nota: cript para corregir errores en el encoding de equipos y hacer el merge entre partidos y tansferencias. 
	do "$programs/matching_teams.do"

* I. clean_data.do
	* Nota: Script para limpiar datos en base al archivo base_final_r.dta. 
	do "$programs/clean_data.do"

* II. subsets.do
	* Nota: Script para generar subsets con distintas especificaciones del modelo. 
	do "$programs/subsets.do"

* III. descript.do
	* Nota: Script para generar gráficos descriptivos y tabla de diferencias. 
	do "$programs/descript.do"

* IV. modelos.do
	* Nota: Script para correr modelos 
	do "$programs/modelos.do"
	
	

