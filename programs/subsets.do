*subsets.do

*** Script para generar subsets con distintas especificaciones del modelo. Correr desde el master.
	
	
* I.1 Subset I
	* Nota:	Este subset tiene observaciones de jugadores con variabilidad en gol y ex dentro del mismo mes 
	clear
	use "$input/base_final.dta"

	keep if mean_ex > 0 & mean_goal > 0
	keep if mean_ex < 1 & mean_goal < 1
	compress
	sa "$input/ley_ex_1.dta", replace
	

* I.2 Subset II
	* Nota:	Este subset tiene observaciones de jugadores que ya tuvieron una transferencia y anotaron un gol alguna vez
	clear
	use "$input/base_final.dta"

	keep if mean_ex_all > 0 & mean_goal_all > 0
	keep if mean_ex_all < 1 & mean_goal_all < 1
	
	compress
	sa "$input/ley_ex_2.dta", replace

	
* I.3 Subset III
	* Nota:	Este subset tiene observaciones de jugadores con variabilidad en gol y ex dentro del mismo año 
	clear
	use "$input/base_final.dta"

	keep if mean_ex_y > 0 & mean_goal_y > 0
	keep if mean_ex_y < 1 & mean_goal_y < 1
	
	compress
	sa "$input/ley_ex_3.dta", replace