#======================
#     VAR_GLOBALI     #
#======================

extends Node

signal tutte_var_global_caricate

#------------ rif --------------
onready var n_main = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var fin_turni       = n_main.get_node("barra_centro/fin_turni")
onready var fin_rubrica     = n_main.get_node("barra_centro/fin_rubrica")
onready var fin_preventivo  = n_main.get_node("barra_centro/fin_preventivo")
onready var fin_contabilita = n_main.get_node("barra_centro/fin_contabilita")
onready var fin_settaggi    = n_main.get_node("fin_settaggi")
onready var fin_orologio    = n_main.get_node("barra_centro/fin_orologio")

#------------- main --------------
var perc_file_conf = "user://laboro_config.cfg"
signal ultimo_avvio_caricato

var nomi_settimana = ["Domenica","Lunedì","Martedì","Mercoledì","Giovedì","Venerdì","Sabato"]
var nomi_sett_cor  = ["Dom","Lun","Mar","Mer","Gio","Ven","Sab"]
var nomi_mesi      = ["Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno","Luglio","Agosto","Settembre","Ottobre","Novembre","Dicembre"]
var nomi_mesi_cor  = ["Gen","Feb","Mar","Apr","Mag","Giu","Lug","Ago","Set","Ott","Nov","Dic"]

onready var giorno     = OS.get_date()["day"]
onready var gior_set   = nomi_settimana[OS.get_date()["weekday"]]
onready var gior_set_c = nomi_sett_cor [OS.get_date()["weekday"]]
onready var mese       = nomi_mesi     [OS.get_date()["month"]-1]
onready var mese_c     = nomi_mesi_cor [OS.get_date()["month"]-1]
onready var anno       = OS.get_date()["year"]

#--------- settaggi ------------
var fl_fullscreen  = false
var fl_low_process = true
var fl_orologio    = false
var fl_mostra_fin  = 0


#---------- fin_turni ------------
var scheda_pass = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
var scheda_corr = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
var scheda_pros = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]

#--------- fin_preventivo --------
var fl_aggiungi_a_rubrica = true
var fl_esistente = false

func _ready():
	carica_dati("tutto")
	emit_signal("tutte_var_global_caricate")

func carica_dati(dicosa):
	if not Directory.new().file_exists(perc_file_conf):
		print("file di config non presente")
		return
	
	var file_config = ConfigFile.new()
	file_config.load(perc_file_conf)
	
	if dicosa in ["settaggi" , "tutto"]:
		fl_fullscreen  = file_config.get_value("settaggi","fullscreen",false)
		fl_low_process = file_config.get_value("settaggi","low_process",true)
		fl_orologio    = file_config.get_value("settaggi","orologio",true)
		fl_mostra_fin  = file_config.get_value("settaggi","mostra_fin",0)
		
		if fl_fullscreen:  OS.set_window_fullscreen(true)
		if fl_low_process: OS.set_low_processor_usage_mode(true)
		
		var tutte_le_fin = [fin_turni,fin_orologio,fin_rubrica,fin_preventivo,fin_contabilita]
		for finestra in tutte_le_fin:    finestra.hide()
		
		if   fl_orologio:        fin_orologio.show()
		if   fl_mostra_fin == 0: fin_turni.show()
		elif fl_mostra_fin == 1: fin_preventivo.show()
		elif fl_mostra_fin == 2: fin_rubrica.show()
		elif fl_mostra_fin == 3: fin_contabilita.show()
	
	if dicosa in ["turni" , "tutto"]:
		var scheda_vuota = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
		if Directory.new().file_exists(perc_file_conf):
			var file_esist = ConfigFile.new()
			file_esist.load(perc_file_conf)
			scheda_pass = file_esist.get_value("schede_turni","scheda_pass",scheda_vuota)
			scheda_corr = file_esist.get_value("schede_turni","scheda_corr",scheda_vuota)
			scheda_pros = file_esist.get_value("schede_turni","scheda_pros",scheda_vuota)
	
	
	