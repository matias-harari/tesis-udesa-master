*matching_teams.do

*** Script para corregir errores en el encoding de equipos y hacer el merge entre partidos y tansferencias. Correr desde el master.

	* I. Identificar equipos de las Big Five
	* Nota: 211 equipos que estuvieron en alguna de las grandes ligas entre 2000 y 2021
	clear	
	import delimited "$input/matching/jugadores_link_all.csv", encoding(ASCII)
	keep team
	groups team, order(h) select (10)
	rename team rival
	sort rival
	quietly by 	rival 	: gen dup = cond(_N==1,0,_n)
	keep if dup == 1
	drop dup
	compress
	sa "$input/matching/teams_big_five.dta" , replace

	* II. Corregir equipos de scrapping de Games y dejar solo partidos de la Big Five
	* II.1 Identificar todos los equipos de base_final_r
	clear
	use "$input/matching/base_final_r.dta"
	keep rival
	sort rival
	bysort rival: egen sum_rival = count(rival)
	quietly by 	rival 	: gen dup = cond(_N==1,0,_n)
	keep if dup == 1
	drop dup
	export delim using "$input/matching/all_teams_from_games.csv", replace
	
	* II.2 Match manual entre nombres de equipos de I y nombres de equipos de II.1 (150 equipos aprox)
	merge 1:1 rival using "$input/matching/teams_big_five.dta" , keep(matched using)
	* Nota: Uso el output de la línea anterior para editar el archivo matching_teams.csv y hacer el match de manera manual. Dos equipos no fueron identificados.
	clear
	import delimited "$input/matching/matching_teams.csv", encoding(UTF-8) varnames(1)	
	drop manual_matched
	drop if rival == ""
	sa "$input/matching/matching_teams.dta" , replace 
	sort rival 
	
	* II.3 Subset para dejar solamente obs. de jugadores de equipos de la Big Five	
	* Nota: Droppeo la variable Ex que había creado en R, el objetivo es hacerlo en Stata
	clear
	use "$input/matching/base_final_r.dta"
	merge m:1 rival using "$input/matching/matching_teams.dta", keep(matched) nogen
	replace transfer_days = game_date - transfer_date
	sort 			id_player game_date transfer_days
	quietly by 	id_player game_date 	: gen dup = cond(_N==1,0,_n)
	keep if dup < 2
	drop dup
	drop rival ex transfer_date transfer_days 
	rename team rival
	compress
	sa "$input/matching/base_final_matching.dta", replace
	
	* II.4 Contar observaciones por equipo para asegurarse que no haya nada raro	
	keep rival
	sort rival
	bysort rival: egen sum_rival = count(rival)
	quietly by 	rival 	: gen dup = cond(_N==1,0,_n)
	keep if dup == 1
	drop dup
	sort sum_rival
	
	* III. Corregir equipos de scrapping de Ex 
	* III.1 Identificar todos los equipos de ex_base.csv
	clear
	import delimited "$input/matching/ex_base.csv", varnames(1) encoding(ASCII)  bindquote(strict) clear
	rename ex_clean rival	
	keep rival
	bysort rival: egen sum_rival = count(rival)
	sort sum_rival
	sort rival
	quietly by 	rival 	: gen dup = cond(_N==1,0,_n)
	keep if dup == 1
	drop dup
	compress
	export delim using "$input/matching/all_teams_from_ex.csv", replace
	
	* III. 2 Subset para dejar solamente obs. de jugadores de equipos de la Big Five	
	clear
	import delimited "$input/matching/ex_base.csv", encoding(UTF-8) varnames(1)
	rename ex_clean rival	
	recast str200 rival
	merge m:1 rival using "$input/matching/matching_teams.dta", keep(matched using)
	compress
	keep team rival _merge
	bysort rival: egen sum_rival = count(rival)
	sort sum_rival
	sort rival
	quietly by 	rival 	: gen dup = cond(_N==1,0,_n)
	keep if dup < 2
	drop dup
	
	* III.3 Match manual para 17 nombres de equipos que no matchean con nombres de equipos de II
	* Nota: Uso el output para editar el archivo matching_ex_teams.csv y hacer el match de manera manual
	clear
	import delimited "$input/matching/matching_ex.csv", encoding(UTF-8) varnames(1)	
	keep rival team
	sort rival 
	sa "$input/matching/matching_teams_ex.dta" , replace 

	clear
	import delimited "$input/matching/ex_base.csv", encoding(UTF-8) varnames(1)
	replace player = ustrlower( ustrregexra( ustrnormalize( player, "nfd" ) , "\p{Mark}", "" )  )
	rename ex_clean rival	
	recast str200 rival
	merge m:1 rival using "$input/matching/matching_teams_ex.dta", keep(matched using) nogen
	drop rival
	rename team rival
	
	* III.4  Ediciones adicionales a Ex
	gen transfer_date_2 = date(transfer_date, "MDY")
	drop transfer_date  season mv
	rename transfer_date_2 transfer_date
	format transfer_date %td
	*drop if player == "NA" | player == ""
	sa "$input/matching/base_final_ex.dta", replace
	
	* IV. Matching Ex y Games
	* IV.1 Eliminar jugadores que no tiene id_player de transfermrkt (en realidad son problemas de encoding, pero solo 4 jugadores)

	use "$input/matching/base_final_ex.dta", replace
	drop if id_player == "as_olivera" | id_player == "iosmanovic" | id_player == "_bocic" | id_player == "ivkovic" 
	destring id_player, replace
	sa "$input/matching/base_final_ex.dta", replace
	
	* V.2 Merge Ex & Games
	clear
	use "$input/matching/base_final_matching.dta", replace
	merge m:m id_player rival using "$input/matching/base_final_ex.dta", keep(master matched)
	gen		ex = 1 if  _merge == 3 & game_date > transfer_date
	replace	ex = 0 if  ex == .
	drop _merge
	
	compress
	sa "$input/base_final_stata.dta" , replace
	
	* V. Auxiliar. Código para generar base con primera transferencia de cada jugador. Usada en mecanismos
	* V. 1 Creo first_team.dta
	clear
	use "$input/matching/base_final_ex.dta"
	rename transfer_date first_transfer_date
	sort rival first_transfer_date
	collapse (min) first_transfer_date (first) rival, by(id_player)
	compress
	sa "$input/first_team.dta", replace
	
	* V. 2 Lo mergeo a la base final
	clear
	use "$input/base_final_stata.dta" 
	merge m:1 id_player rival using "$input/first_team.dta", keep(master matched)
	gen playing_against_first_ex = 1 if _merge == 3
	replace playing_against_first_ex = 0 if playing_against_first_ex == .
	drop _merge
	compress
	sa "$input/base_final_stata.dta" , replace
	
	* VI. Borro archivos temporales
	rm "$input/matching/all_teams_from_ex.csv"
	rm "$input/matching/all_teams_from_games.csv"
	rm "$input/matching/base_final_ex.dta"
	rm "$input/matching/base_final_matching.dta"
	rm "$input/matching/matching_teams.dta"
	rm "$input/matching/matching_teams_ex.dta"
	rm "$input/matching/teams_big_five.dta"