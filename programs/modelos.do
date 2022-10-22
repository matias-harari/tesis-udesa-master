*lineal.do

*** Script para correr modelos de la base final. Correr desde el master.

clear
clear mata
clear matrix
set maxvar 110000
set maxiter  50
set scheme s1color

clear
use "$input/ley_ex_2.dta"
xtset id_player game_date

*sum if 	rival_encode == 60

**************************************
* Modelo Lineal
**************************************
	
* I. Goles
* I.I. Ex
	* I.I.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_a_2
	est save lin_a_2, replace
	
* I.II. Tipo de Ex
	* I.II.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_b_2
	est save lin_b_2, replace
	
* II. Asistencias
* II.I. Ex
	* II.I.1 Lineal efetos fijos jugador-mes con controles
	 xtreg asists ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_as_a_2
	est save lin_as_a_2, replace
* II.II Tipo de Ex
	*II.II.1 Lineal efetos fijos jugador-mes con controles
	 xtreg asists ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_as_b_2
	est save lin_as_b_2, replace

* III. Puntos
* III.I. Ex
	* II.I.1 Lineal efetos fijos jugador-mes con controles
	 xtreg points ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_pt_a_2
	est save lin_pt_a_2, replace
	
* III.II Tipo de Ex
	*III.II.1 Lineal efetos fijos jugador-mes con controles
	 xtreg points ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_pt_b_2
	est save lin_pt_b_2, replace

* IV. Tabla Principal. 
* Modelo Lineal Goles, Asistencias y Puntos	
* Nota: Correr en la misma sesión (5 min)
outreg2 [lin_a_2 lin_b_2 lin_as_a_2 lin_as_b_2 lin_pt_a_2 lin_pt_b_2] using Tabla_principal, tex(frag) dec(3)  nocons  keep(i.season_transfer ex) stats(coef se pval) eqkeep(player_goals) par(se) bracket(pval)   ctitle("Goles")   addnote("Controles: Fecha, Minutos, Localía y Roja.","Errores estándar entre paréntesis. P-valores entre corchetes. *** p$<$0.01, ** p$<$0.05, * p$<$0.1") label nonotes  replace 

* V. Gráfico Goles
	est use lin_b_2
	est store lin_b_2
   coefplot (lin_e_2, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3))  ), vertical yline(0)  byopts(yrescale) note("Nota: Intervalos de confianza al 95%.", span) xlabel(,angle(90))  keep(60.season_transfer 365.season_transfer 366.season_transfer)  ytitle("{&beta}") 
	graph export m6_2.png, width(2000) as(png) replace
	
 * VI. Robustez límite Goles
	forvalues x = 10(10)180  {
		drop season_transfer
		gen		season_transfer = 0     if ex == 0
		replace season_transfer = 60    if transfer_days <= `x' & ex == 1
		replace season_transfer = 365  if transfer_days > `x' & transfer_days <= 365 & ex == 1
		replace season_transfer = 366  if transfer_days > 365  & ex == 1
		xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
		est save days_`x', replace
	}

forvalues x = 10(10)180 {
	est use days_`x'
	est store days_`x'
	}
coefplot ///
(days_10, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "10")) ///
(days_20, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "20")) ///
(days_30, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "30")) ///
(days_40, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "40")) ///
(days_50, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "50")) ///
(days_60, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "60")) ///
(days_70, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "70")) ///
(days_80, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "80")) ///
(days_90, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "90")) ///
(days_100, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "100")) ///
(days_110, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "110")) ///
(days_120, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "120")) ///
(days_130, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "130")) ///
(days_140, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "140")) ///
(days_150, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "150")) ///
(days_160, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "160")) ///
(days_170, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "170")) ///
(days_180, color(navy%40) ciopts(lcolor(navy%40) lwidth(1.3)) rename(60.season_transfer = "180")) ///
, nolab vertical yline(0)  byopts(yrescale) note("Nota: Intervalos de confianza al 95%.", span)  keep(60.season_transfer) xtitle("Límite Tipo de Ex (Días)")  ytitle("{&beta}", angle(90)) leg(off)
graph export m7_2.png, width(2000) as(png) replace

**************************************
* Modelos Logit/Poisson
**************************************

* I. Goles
	* I.I Ex
	* I.I.1. Logit Ex	
	* I.I.1.1 Logit efetos fijos jugador-mes con controles
	 xtlogit goal ex mins_played i.rival_encode matchday red_card venue , fe i(Grupos_m)	
	 est store logit_a_2
	est save logit_a_2, replace 
	
	* I.I.2. Poisson Ex
	*I.I.2.1Poisson efetos fijos jugador-mes con controles
	 xtpoisson player_goals ex mins_played i.rival_encode matchday red_card venue , fe i(Grupos_m)	
	est store bin_a_2
	est save bin_a_2, replace
	
	* I.I Tipo de Ex
	* I.I.1.1 Logit efetos fijos jugador-mes con controles
	 xtlogit goal ib0.season_transfer mins_played i.rival_encode matchday red_card venue , fe i(Grupos_m)	
	 est store logit_b_2
	est save logit_b_2, replace 
	
	* I.I.2. Poisson Tipo de Ex
	*I.I.2.1 Poisson efetos fijos jugador-mes con controles
	 xtpoisson player_goals ib0.season_transfer mins_played i.rival_encode matchday red_card venue , fe i(Grupos_m)	
	est store bin_b_2
	est save bin_b_2, replace

** Tabla Modelo Logit/Poisson Goles	
outreg2 [logit_a_2 logit_b_2 bin_a_2 bin_b_2] using Tabla_reg_ex_2_logit_goal, tex(frag) dec(3)  nocons  keep(i.season_transfer ex) stats(coef se pval) eqkeep(player_goals) par(se) bracket(pval)   ctitle("Goles")   addnote("Controles: Fecha, Minutos, Localía y Roja.","Errores estándar entre paréntesis. P-valores entre corchetes. *** p$<$0.01, ** p$<$0.05, * p$<$0.1") label nonotes  replace 


**************************************
* Subconjunto alt. 1-mes (lineal)
**************************************	
clear
use "$input/ley_ex_1.dta"
xtset id_player game_date
	
* I. Goles
* I.I. Ex
	* I.I.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_a_1
	est save lin_a_1, replace
	
* I.II. Tipo de Ex
	* I.II.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_b_1
	est save lin_b_1, replace

* Tabla Subconjuntos alt. Goles (Mes)	
outreg2 [lin_a_1 lin_b_1] using Tabla_alternativa, tex(frag) dec(3)  nocons  keep(i.season_transfer ex) stats(coef se pval) eqkeep(player_goals) par(se) bracket(pval)   ctitle("Goles")   addnote("Controles: Fecha, Minutos, Localía y Roja.","Errores estándar entre paréntesis. P-valores entre corchetes. *** p$<$0.01, ** p$<$0.05, * p$<$0.1") label nonotes  replace 	

**************************************
* Subconjunto alt. 3-año (lineal)
**************************************	
clear
use "$input/ley_ex_3.dta"
xtset id_player game_date
	
 *I. Goles
* I.I. Ex
	* I.I.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_a_3
	est save lin_a_3, replace
	
* I.II. Tipo de Ex
	* I.II.1 Lineal efetos fijos jugador-mes con controles
	 xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_m)  vce(cluster id_player)
	est store lin_b_3
	est save lin_b_3, replace
		
* Tabla Subconjuntos alt. Goles (Año)	
outreg2 [lin_a_3 lin_b_3] using Tabla_alternativa, tex(frag) dec(3)  nocons  keep(i.season_transfer ex) stats(coef se pval) eqkeep(player_goals) par(se) bracket(pval)   ctitle("Goles")   addnote("Controles: Fecha, Minutos, Localía y Roja.","Errores estándar entre paréntesis. P-valores entre corchetes. *** p$<$0.01, ** p$<$0.05, * p$<$0.1") label nonotes  append 	
	
	
	
/* NOT USED
***********************
* Goles
* I.I.2 Lineal efetos fijos jugador-año con controles
	xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_y)  vce(cluster id_player)
	est store lin_b_2
	est save lin_b_2, replace
	* I.I.3 Lineal efetos fijos jugador y mes con controles
	xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.id_month i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_c_2
	est save lin_c_2, replace
	* I.I.4 Lineal efetos fijos jugador y año con controles
	 xtreg player_goals ex mins_played  matchday red_card yellow_card venue i.year i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_d_2
	est save lin_d_2, replace
	
* I.II.2 Lineal efetos fijos jugador- año con controles
	xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card  venue i.rival_encode, fe i( Grupos_y)  vce(cluster id_player)
	est store lin_f_2
	est save lin_f_2, replace
	* I.II.3 Lineal efetos fijos jugador y mes con controles
	xtreg player_goals ib0.season_transfer mins_played  matchday red_card yellow_card venue i.id_month i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_g_2
	est save lin_g_2, replace
	* I.II. 4 Lineal efetos fijos jugador y año con controles
	 xtreg player_goals ib0.season_transfer mins_played  red_card yellow_card venue i.year i.rival_encode matchday, fe i(id_player)  vce(cluster id_player)
	est store lin_h_2
	est save lin_h_2, replace
	
**********************
* Asistencias
*II.2 Lineal efetos fijos jugador- año con controles
	xtreg asists ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_y)  vce(cluster id_player)
	est store lin_as_f_2
	est save lin_as_f_2, replace
	*II.3 Lineal efetos fijos jugador y mes con controles
	xtreg asists ib0.season_transfer mins_played  matchday red_card yellow_card venue i.id_month i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_as_g_2
	est save lin_as_g_2, replace
	*II.4 Lineal efetos fijos jugador y año con controles
	 xtreg asists ib0.season_transfer mins_played  matchday red_card yellow_card venue i.year i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_as_h_2
	est save lin_as_h_2, replace
	
***************************
* Puntos/Victorias
	*III.2 Lineal efetos fijos jugador- año con controles
	xtreg points ib0.season_transfer mins_played  matchday red_card yellow_card venue i.rival_encode, fe i( Grupos_y)  vce(cluster id_player)
	est store lin_pt_f_2
	est save lin_pt_f_2, replace
	*III.3 Lineal efetos fijos jugador y mes con controles
	xtreg points ib0.season_transfer mins_played  matchday red_card yellow_card venue i.id_month i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_pt_g_2
	est save lin_pt_g_2, replace
	*III.4 Lineal efetos fijos jugador y año con controles
	 xtreg points ib0.season_transfer mins_played  matchday red_card yellow_card venue i.year i.rival_encode, fe i(id_player)  vce(cluster id_player)
	est store lin_pt_h_2
	est save lin_pt_h_2, replace
	
******************************
* Logit Poisson	
	* I.I.1. Logit Tipo de Ex	
		* I.I.1.1 Logit efetos fijos jugador-año con controles
	 xtlogit goal ex mins_played i.rival_encode matchday red_card venue , fe i(Grupos_y)
	est store logit_a_2
	est save logit_a_2, replace
	* I.I.2.1 Poisson efetos fijos jugador-año con controles
	xtpoisson player_goals ex mins_played i.rival_encode matchday red_card venue , fe i(Grupos_y)
	est store bin_b_2
	est save bin_b_2, replace
	* I.I.1.1 Logit efetos fijos jugador-año con controles
	 xtlogit goal ib0.season_transfer mins_played i.rival_encode matchday red_card venue , fe i(Grupos_y)
	est store logit_c_2
	est save logit_c_2, replace
	* I.I.2.1 Poisson efetos fijos jugador-año con controles
	xtpoisson player_goals ib0.season_transfer mins_played i.rival_encode matchday red_card venue , fe i(Grupos_y)
	est store bin_a_2
	est save bin_a_2, replace