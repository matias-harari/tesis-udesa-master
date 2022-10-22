*script.do


*** Script para generar gráficos descriptivos y tabla de diferencias. Correr desde el master.

* I. 
	clear
	use "$input/base_final.dta"
	groups id_player, order(h) select (10)
	groups rival_encode, order(h) select (10)

	twoway (hist matchday, yla(, format(%5.0f) ang(h))  freq width(1) color(navy%40) ytitle("") xtitle("Fecha del Torneo"))  

* I.1 Gráficos para todas las observaciones
	clear
	use "$input/base_final.dta"
	set scheme s1color
	
	* Partidos por año
	twoway (hist year,start(2000) freq width(1) color(navy%40) yla(, format(%5.0f) ang(h))) (hist year if mean_ex !=0 & mean_goal !=0,start(2000) freq width(1) color(navy%90) yla(, format(%5.0f))), ytitle("") legend(order(1 "N Total" 2 "N con variabilidad en Gol y Ex" )) 
	graph export m1.png, width(2000) as(png) replace

	* Distribución de partidos jugados
	twoway (hist sum_games, yla(, format(%5.0f) ang(h))  freq color(navy%40) ytitle("") xtitle("Partidos en el mes"))
	graph export m4.png, width(2000) as(png) replace

	* Goles y Ex por edad
	keep if age_years > 16 & age_years < 38
	bysort age_years: egen mean_ex_plot = mean(ex)
	bysort age_years: egen mean_goal_plot = mean(goal)
	quietly by  age_years  : gen dup = cond(_N==1,0,_n)
	sort dup
	drop if dup > 1 
	drop dup 
	sort age_years
	twoway (line mean_goal_plot age_years, color(navy%40)) (line mean_ex_plot age_years, color(red%40)), legend(order(1 "Media Gol" 2 "Media Ex")) 
	graph export m2.png, width(2000) as(png) replace

* I.2 Gráficos para jugadores con variabilidad dentro de un mes
	clear
	use "$input/ley_ex_1.dta"
	set scheme s1color
	
	* Distribución de Ex y Goles
	twoway (hist mean_goal if mean_ex !=0 & mean_goal !=0, yla(, format(%5.0f) ang(h)) width(0.1) freq color(navy%40)) (hist mean_ex if mean_ex !=0 & mean_goal !=0, yla(, format(%5.0f) ang(h)) width(0.1) freq color(navy%90)), legend(order(1 "Media Gol" 2 "Media Ex"))  ytitle("")
	graph export m3.png, width(2000) as(png) replace

* II. Tabla de diferencias
	* Subset I
	clear
	use "$input/ley_ex_1.dta"
 
	mat T=J(9,7,.)
	local y 0
	foreach var in player_goals asists points  mins_played yellow_card red_card matchday venue  {
		ttest `var', unequal by(ex)
			local y =`y'+1
			mat T[`y',1]= `r(mu_2)'
			mat T[`y',2]= `r(sd_2)'
			mat T[`y',3]= `r(mu_1)'
			mat T[`y',4]= `r(sd_1)'
			mat T[`y',5]= T[`y',1]-T[`y',3]
			mat T[`y',6]=`r(p)'
			mat T[`y',7]=`r(p)'
		}

	matselrc T T1, c(1 2 3 4)
	matselrc T T2, c(5 6)

	local bc = rowsof(T)
	matrix stars2 = J(`bc',2,0)
	forvalues k = 1/`bc' {
		matrix stars2[`k',1] = ((T[`k',7] <= 0.1 & T[`k',7] >0) + (T[`k',7] <= 0.05 & T[`k',7] >0) + (T[`k',7] <= 0.01 & T[`k',7] >0))
		}
	matrix list stars2

	frmttable using Table_dif_1,  tex statmat(T1) sdec(3) substat(1) rtitles("Goles" \""\ "Asistencias" \""\ "Puntos"\""\"Minutos" \""\ "Amarilla" \""\ "Roja" \""\ "Fecha"\""\ "Localía") ctitles("", "Ex=1", "Ex=0")   replace
	frmttable using Table_dif_1, tex statmat(T2) sdec(3) substat(1) sq annotate(stars2) asymbol(*,**,***) ctitles("Diferencia")  merge frag note("", "*** p$<$0.01, ** p$<$0.05, * p$<$0.1") hline(1100000100000000001)
	
	* Subset II
	clear
	use "$input/ley_ex_2.dta"
 
		mat T=J(9,7,.)
	local y 0
	foreach var in player_goals asists points  mins_played yellow_card red_card matchday venue  {
	ttest `var', unequal by(ex)
			local y =`y'+1
			mat T[`y',1]= `r(mu_2)'
			mat T[`y',2]= `r(sd_2)'
			mat T[`y',3]= `r(mu_1)'
			mat T[`y',4]= `r(sd_1)'
			mat T[`y',5]= T[`y',1]-T[`y',3]
			mat T[`y',6]=`r(p)'
			mat T[`y',7]=`r(p)'
		}

	matselrc T T1, c(1 2 3 4)
	matselrc T T2, c(5 6)

	local bc = rowsof(T)
	matrix stars2 = J(`bc',2,0)
	forvalues k = 1/`bc' {
		matrix stars2[`k',1] = ((T[`k',7] <= 0.1 & T[`k',7] >0) + (T[`k',7] <= 0.05 & T[`k',7] >0) + (T[`k',7] <= 0.01 & T[`k',7] >0))
		}
	matrix list stars2

	frmttable using Table_dif_2,  tex statmat(T1) sdec(3) substat(1) rtitles("Goles" \""\ "Asistencias" \""\ "Puntos"\""\"Minutos" \""\ "Amarilla" \""\ "Roja" \""\ "Fecha"\""\ "Localía") ctitles("", "Ex=1", "Ex=0")   replace
	frmttable using Table_dif_2, tex statmat(T2) sdec(3) substat(1) sq annotate(stars2) asymbol(*,**,***) ctitles("Diferencia")  merge frag note("", "*** p$<$0.01, ** p$<$0.05, * p$<$0.1") hline(1100000100000000001)
	
		* Subset III
	clear
	use "$input/ley_ex_3.dta"
 
	mat T=J(9,7,.)
	local y 0
	foreach var in player_goals asists points  mins_played yellow_card red_card matchday venue  {
		ttest `var', unequal by(ex)
			local y =`y'+1
			mat T[`y',1]= `r(mu_2)'
			mat T[`y',2]= `r(sd_2)'
			mat T[`y',3]= `r(mu_1)'
			mat T[`y',4]= `r(sd_1)'
			mat T[`y',5]= T[`y',1]-T[`y',3]
			mat T[`y',6]=`r(p)'
			mat T[`y',7]=`r(p)'
		}

	matselrc T T1, c(1 2 3 4)
	matselrc T T2, c(5 6)

	local bc = rowsof(T)
	matrix stars2 = J(`bc',2,0)
	forvalues k = 1/`bc' {
		matrix stars2[`k',1] = ((T[`k',7] <= 0.1 & T[`k',7] >0) + (T[`k',7] <= 0.05 & T[`k',7] >0) + (T[`k',7] <= 0.01 & T[`k',7] >0))
		}
	matrix list stars2

	frmttable using Table_dif_3,  tex statmat(T1) sdec(3) substat(1) rtitles("Goles" \""\ "Asistencias" \""\ "Puntos"\""\"Minutos" \""\ "Amarilla" \""\ "Roja" \""\ "Fecha"\""\ "Localía") ctitles("", "Ex=1", "Ex=0")   replace
	frmttable using Table_dif_3, tex statmat(T2) sdec(3) substat(1) sq annotate(stars2) asymbol(*,**,***) ctitles("Diferencia")  merge frag note("", "*** p$<$0.01, ** p$<$0.05, * p$<$0.1") hline(1100000100000000001)
