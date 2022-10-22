*clean_data.do

*** Script para limpiar datos en base al archivo base_final_r.dta. Correr desde el master.

* I Abro output del web scrapping en R
	* Nota: Este archivo fue previamente procesado en R	
	clear
	use "$input/base_final_stata.dta"
	set seed 1234
	
* II Destring de variables existentes
	replace position = "3" if position == "Attack"
	replace position = "2" if position == "Center"
	replace position = "1" if position == "Defense"
	destring position, replace
	drop if position == .
	
	replace venue = "1" if venue == "H"
	replace venue = "0" if venue == "A"
	destring venue, replace
	
	gen red_card_1 = red_card + yellow_red_card
	drop red_card
	gen red_card = red_card_1
	drop red_card_1
	
	encode rival, gen(rival_encode)
	drop rival
	
* III Borarr observaciones
* III.1 Elimino observaciones con NA en infromación de posición del rival y fecha
	drop if rival_pos == .
	drop if matchday == .
	tab matchday, mis
	tab rival_pos 
	
* III.2 Elimino observaciones duplicadas  (mismo jugador y partido)
	* Nota:	Estos valores repetidos se deben a que el merge fue m:m entre partidos y transferencias, de forma que si un jugador se fue más de una vez de un mismo club tendrá dos observaciones distintas, cada una con una fecha de transferencia distinta. El criterio que utilizo a continuación es dejar la fecha de transferencia más reciente. La variable transfer_days tenía ceros para los jugadores que no eran ex. Los paso a missing values 
	gen transfer_days = game_date - transfer_date
	sort 			id_player game_date transfer_days
	quietly by 	id_player game_date 	: gen dup = cond(_N==1,0,_n)
	keep if dup < 2
	drop dup
	
* IV Creo nuevas variables
	* Nota:	Las variables restantes ya fueron generadas en R
	* IV.1 Performance
	gen asists_d = asists
	replace asists_d = 1 if asists_d > 1
	
	gen			points = 3	 if goals_team_a	> 		goals_team_h
	replace  	points = 1	 if goals_team_h	==	goals_team_a
	replace  	points = 0	 if points == .
	
	gen 	   		win = 1 if points == 3
	replace 	win = 0 if win     == .
	
	* IV.2 Edad	
	gen age_years = int(age/365)
	gen age_when_ex = age - (game_date - transfer_date)
	gen age_years_when_ex = int(age_when_ex/365)
	drop age_when_ex
	
	* IV.3 Efecto según días desde la transferencia
	label define transferlab 0 "No Transferido" 60 "60 o menos" 365 "60-365" 366 "Más de 365"
	gen		season_transfer = 0     if ex == 0
	replace season_transfer = 60    if transfer_days <= 60 & ex == 1
	replace season_transfer = 365  if transfer_days > 60 & transfer_days <= 365 & ex == 1
	replace season_transfer = 366  if transfer_days > 365  & ex == 1
	label values season_transfer transferlab
	
* V Efectos fijos
* 	Nota: Creo grupos para efectos fijos por jugador, equipo y tiempo
	egen Grupos_m = group(id_player year month)
    egen Grupos_y = group(id_player year)
	egen Equipos_m = group(rival_encode year month)
    egen Equipos_y = group(rival_encode year)
    egen id_month = group(year month)

* V. Creo variables para subsets de la base
	bysort Grupos_m: egen mean_ex = mean(ex)
	bysort Grupos_m: egen mean_goal = mean(goal)
	bysort Grupos_m: egen sum_games = count(game_date)
	
	bysort Grupos_y: egen mean_ex_y = mean(ex)
	bysort Grupos_y: egen mean_goal_y = mean(goal)
	bysort Grupos_y: egen sum_games_y = count(game_date)
	
	bysort id_player: egen mean_ex_all = mean(ex)
	bysort id_player: egen mean_goal_all = mean(goal)
	bysort id_player: egen sum_games_all = count(game_date)
	
* VI Etiquetas
	label variable player_goals 						"Goles" 
	label variable game_date						"Fecha del partido"	
	label variable transfer_date						"Fecha de transferencia"			
	label variable asists_d 							"Asistencia"
	label variable asists								"Asistencias"
	label variable ex									"Ex" 
	label variable goal									"Gol" 
	label variable mins_played 						"Minutos"
	label variable position 							"Posición" 
	label variable id_player 							"ID de Transfermrkt del Jugador" 
	label variable player 								"Jugador" 
	label variable age_years 						"Edad" 
	label variable season_transfer 				"Tipo de Ex"
	label variable age_years_when_ex 			"Edad al ser transferido" 
	label variable yellow_card 						"Amarilla" 
	label variable red_card 							"Roja" 
	label variable year 									"Año" 
	label variable month								"Mes"
	label variable points 								"Puntos"
	label variable playing_against_first_ex		"Primer Equipo"
	label variable first_transfer_date 				"Primera fecha de transferencia"
	label variable win   								"Victoria"
	label variable rival_pos 							"Posición Rival"
	label variable rival_encode                      "Rival"
	label variable matchday 							"Fecha Torneo"	
	label variable venue 								"Localía"
	label variable points 								"Puntos"
	label variable transfer_days					"Días desde la transferencia"				
	label variable Grupos_m 						"Jugador-Mes"
	label variable Grupos_y 							"Jugador-Año"
	label variable Equipos_m 						"Rival-Mes"
	label variable Equipos_y							"Rival-Año"
	label variable mean_ex 							"Promedio de Ex en el mes para el jugador"
	label variable mean_goal 						"Promedio de Gol en el mes para el jugador"
	label variable sum_games 						"Partidos jugados en el mes por el jugador"
	label variable mean_ex_y 						"Promedio de Ex en el año para el jugador"
	label variable mean_goal_y 					"Promedio de Gol en el año para el jugador"
	label variable sum_games_y 					"Partidos jugados en el año por el jugador"
	
* VII Ordeno, comprimo y exporto
	drop yellow_red_card born market_value goals_team_a goals_team_h
	sort id_player game_date
	order id_player player game_date ex transfer_date transfer_days season_transfer playing_against_first_ex first_transfer_date goal player_goals asists_d asists win points mins_played yellow_card red_card position matchday venue rival_encode rival_pos age age_years age_years_when_ex
	compress
	sa "$input/base_final.dta", replace
	
	
/*
DEPRECIADO
	bysort id_player: egen first_transfer_date = min(transfer_date)
	sort 		first_transfer_date
	format 	first_transfer_date %td
	
	gen		 dummy_after_first_transf = 1 if game_date > first_transfer_date
	replace	 dummy_after_first_transf = 0 if dummy_after_first_transf == .
	
	sort id_player game_date
	bysort id_player: gen mean_goal_all = sum(goal[_n-1])/sum(goal[_n-1]<.)
	
	gen		 dummy_goal_all		= 1 if mean_goal_all 		>	0
	replace	 dummy_goal_all		= 0 if dummy_goal_all 	!= 1
		