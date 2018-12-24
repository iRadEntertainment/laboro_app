#=====================
#        DATI        #
#=====================

extends Node

var fl_debug_mode = false
var fl_dati_caricati = false

#------------ rif --------------
onready var main            = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var fin_turni       = main.get_node("barra_centro/fin_turni")
onready var fin_rubrica     = main.get_node("barra_centro/fin_rubrica")
onready var fin_preventivo  = main.get_node("barra_centro/fin_preventivo")
onready var cnt_lista_prev  = main.get_node("barra_centro/fin_preventivo/cnt_lista_prev")
onready var fin_contabilita = main.get_node("barra_centro/fin_contabilita")
onready var fin_settaggi    = main.get_node("fin_settaggi")
onready var fin_orologio    = main.get_node("barra_centro/fin_orologio")

#------------- main --------------
var perc_user_dir  = str(OS.get_system_dir(0),"/laboro_app/")
var perc_file_conf = str(perc_user_dir,"laboro_config.cfg")
#var perc_file_conf = "user://laboro_config.cfg"
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

var settimana_corr
var settimana_succ
var settimana_prec
var ultimo_avvio_gio
var ultimo_avvio_set

#--------- settaggi ------------
var versione        = "1.0"
var fl_fullscreen   = false
var fl_low_process  = true
var fl_orologio     = false
var fl_mostra_fin   = 0
var bak_manuale     = ""
var fl_soffice_inst = false
var fl_cont_vis     = false setget _set_contabilita_visibile
var fl_cont_init    = false
var arrotonda       = 0.05

#---------- fin_turni ------------
var scheda_pass = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
var scheda_corr = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
var scheda_pros = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]

#---------- fin_rubrica ----------
var lista_nomi   = []
var diz_contatti = {}

#--------- fin_preventivo --------
var diz_preventivi_prezzi_default = {"tipo"      :[ ["creazione",1.6],["riparazione",1],["produzione",1.4],["creazione partecipata",1.8] ],
									"difficolta" :[ ["facile",15],["media",20],["difficile",25] ],
									"metalli"    :[ ["argento",0.4],["oro",35],["rame",0.006] ],
									"pacchetti"  :[ ["economy - orecchini",3],["economy - bracciale",7],["economy - anello",3] ],
									"pietre"     :[ ["pietra di prova",15.3] ],
									"IVA"        : 22,
									"perc_gen"   : 30}

var lista_preventivi      = []
var diz_preventivi_prezzi = diz_preventivi_prezzi_default
var fl_contatto_agg       = true
var fl_contatto_esist     = false
var fl_genera_pdf         = true


var   glob_dir_prev   = perc_user_dir+"preventivi/"
const perc_fodt_templ = "res://file_template/template-preventivo.fodt"


#--------- fin_contabilita --------
var diz_contabilita         = []
var lista_date_cont         = []

#================================== READY =================================
func _ready():
	primo_avvio()
	data_e_settimana()
	esegui_backup()
	carica_dati("tutto")
	aggiorna_ultimo_avvio()

func primo_avvio():
	var dir = Directory.new()
	if not dir.dir_exists(perc_user_dir):
		print(str("PRIMO AVVIO: ",perc_user_dir," cartella non presente"))
		dir.open(OS.get_system_dir(0))
		dir.make_dir("Laboro_app")
	#check versione
	

func carica_dati(dicosa):
	if dicosa == "tutto" and not Directory.new().file_exists(perc_file_conf):
		print("CARICAMENTO FALLITO: file di config non presente")
		print("CHECK PRIMO AVVIO: genero file di default")
		salva_dati("tutto")
	var file_config = ConfigFile.new()
	file_config.load(perc_file_conf)
	
	if dicosa in ["settaggi", "tutto"]:
		print("CARICAMENTO: settaggi")
		fl_fullscreen   = file_config.get_value("settaggi","fl_fullscreen",false)
		fl_low_process  = file_config.get_value("settaggi","fl_low_process",true)
		fl_orologio     = file_config.get_value("settaggi","fl_orologio",true)
		fl_mostra_fin   = file_config.get_value("settaggi","fl_mostra_fin",0)
		bak_manuale     = file_config.get_value("settaggi","bak_manuale","")
		fl_soffice_inst = file_config.get_value("settaggi","fl_soffice_inst",false)
		fl_cont_vis     = file_config.get_value("settaggi","fl_cont_vis",false)
		arrotonda       = file_config.get_value("settaggi","arrotonda",0.05)
		
		_set_contabilita_visibile(fl_cont_vis)
	if dicosa in ["ultimo_avvio", "tutto"]:
		print("CARICAMENTO: ultimo_avvio")
		ultimo_avvio_gio = file_config.get_value("date_avvio","ultimo_avvio_gio",str(giorno)+" "+mese+" "+str(anno))
		ultimo_avvio_set = file_config.get_value("date_avvio","ultimo_avvio_set",settimana_corr)
	if dicosa in ["turni", "tutto"]:
		print("CARICAMENTO: turni")
		var scheda_vuota = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
		scheda_pass = file_config.get_value("schede_turni","scheda_pass",scheda_vuota)
		scheda_corr = file_config.get_value("schede_turni","scheda_corr",scheda_vuota)
		scheda_pros = file_config.get_value("schede_turni","scheda_pros",scheda_vuota)
	if dicosa in ["rubrica", "tutto"]:
		print("CARICAMENTO: rubrica")
		lista_nomi   = file_config.get_value("rubrica","lista_nomi",[])
		diz_contatti = file_config.get_value("rubrica","diz_contatti",{})
	if dicosa in ["preventivi", "preventivi_prezzi", "tutto"]:
		print("CARICAMENTO: preventivi")
#		diz_preventivi_prezzi_default = {"tipo"      :[ ["creazione",1.6],["riparazione",1],["produzione",1.4],["creazione partecipata",1.8] ],
#										"difficolta" :[ ["facile",15],["media",20],["difficile",25] ],
#										"metalli"    :[ ["argento",0.4],["oro",35],["rame",0.006] ],
#										"pacchetti"  :[ ["economy - orecchini",3],["economy - bracciale",7],["economy - anello",3] ],
#										"pietre"     :[ ["pietra di prova",15.3] ],
#										"IVA"        : 22}
		lista_preventivi      = file_config.get_value("preventivi","lista_preventivi",[])
		diz_preventivi_prezzi = file_config.get_value("preventivi","diz_preventivi_prezzi",diz_preventivi_prezzi_default)
		
		for chiave in diz_preventivi_prezzi_default.keys():
			if not diz_preventivi_prezzi.has(chiave):
				diz_preventivi_prezzi[chiave] = diz_preventivi_prezzi_default[chiave]
		
		for chiave in diz_preventivi_prezzi.keys():
			if typeof(diz_preventivi_prezzi[chiave]) != TYPE_INT:
				if diz_preventivi_prezzi[chiave] == null or diz_preventivi_prezzi[chiave].empty():
					diz_preventivi_prezzi[chiave] = diz_preventivi_prezzi_default[chiave]
	if dicosa in ["contabilita", "tutto"]:
		print("CARICAMENTO: contabilita")
		diz_contabilita         = file_config.get_value("contabilita","diz_contabilita",[])
		lista_date_cont         = file_config.get_value("contabilita","lista_date_cont",[])
	

func salva_dati(dicosa):
	var file_config = ConfigFile.new()
	if Directory.new().file_exists(perc_file_conf): file_config.load(perc_file_conf)
	
	if dicosa in ["settaggi", "tutto"]:
		print("SALVATAGGIO: settaggi")
		file_config.set_value("settaggi","fl_fullscreen",fl_fullscreen)
		file_config.set_value("settaggi","fl_low_process",fl_low_process)
		file_config.set_value("settaggi","fl_orologio",fl_orologio)
		file_config.set_value("settaggi","fl_mostra_fin",fl_mostra_fin)
		file_config.set_value("settaggi","bak_manuale",bak_manuale)
		file_config.set_value("settaggi","fl_soffice_inst",fl_soffice_inst)
		file_config.set_value("settaggi","fl_cont_vis",fl_cont_init)
		file_config.set_value("settaggi","arrotonda",arrotonda)
	if dicosa in ["ultimo_avvio"]:   #, "tutto"]:
		print("SALVATAGGIO: ultimo_avvio")
		file_config.set_value("date_avvio","ultimo_avvio_gio",ultimo_avvio_gio)
		file_config.set_value("date_avvio","ultimo_avvio_set",ultimo_avvio_set)
	if dicosa in ["turni", "tutto"]:
		print("SALVATAGGIO: turni")
		file_config.set_value("schede_turni","scheda_pass",scheda_pass)
		file_config.set_value("schede_turni","scheda_corr",scheda_corr)
		file_config.set_value("schede_turni","scheda_pros",scheda_pros)
	if dicosa in ["rubrica", "tutto"]:
		print("SALVATAGGIO: rubrica")
		file_config.set_value("rubrica","lista_nomi",lista_nomi)
		file_config.set_value("rubrica","diz_contatti",diz_contatti)
	if dicosa in ["preventivi_prezzi", "tutto"]:
		print("SALVATAGGIO: preventivi_prezzi")
		file_config.set_value("preventivi","diz_preventivi_prezzi",diz_preventivi_prezzi)
	if dicosa in ["preventivi_lista", "tutto"]:
		print("SALVATAGGIO: preventivi_lista")
		file_config.set_value("preventivi","lista_preventivi",lista_preventivi)
	if dicosa in ["contabilita", "tutto"]:
		print("SALVATAGGIO: preventivi_lista")
		file_config.set_value("contabilita","diz_contabilita",diz_contabilita)
		file_config.set_value("contabilita","lista_date_cont",lista_date_cont)
	file_config.save(perc_file_conf)
#	print(str("SALVATAGGIO: Completato in - ",perc_file_conf))

func data_e_settimana():
#	variabili
	var inz_sett_g
	var inz_sett_m
	var fin_sett_g
	var fin_sett_m
	var succ_inz_sett_g
	var succ_inz_sett_m
	var succ_fin_sett_g
	var succ_fin_sett_m
	var prec_inz_sett_g
	var prec_inz_sett_m
	var prec_fin_sett_g
	var prec_fin_sett_m
	
	var sec_24h = 60*60*24
	var sec_7gg = sec_24h * 7
	var sec_unix = OS.get_unix_time()
	var gio_sett = OS.get_date()["weekday"]
	if gio_sett == 0: gio_sett = 7
	gio_sett -= 1
#	definizione settimana corrente, precedente e successiva
	prec_inz_sett_g = OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h)-sec_7gg)["day"]
	prec_inz_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h)-sec_7gg)["month"]-1]
	prec_fin_sett_g = OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h)-sec_7gg)["day"]
	prec_fin_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h)-sec_7gg)["month"]-1]
	
	inz_sett_g = OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h))["day"]
	inz_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h))["month"]-1]
	fin_sett_g = OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h))["day"]
	fin_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h))["month"]-1]
	
	succ_inz_sett_g = OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h)+sec_7gg)["day"]
	succ_inz_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix-(gio_sett*sec_24h)+sec_7gg)["month"]-1]
	succ_fin_sett_g = OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h)+sec_7gg)["day"]
	succ_fin_sett_m = nomi_mesi_cor[OS.get_datetime_from_unix_time(sec_unix+((6-gio_sett)*sec_24h)+sec_7gg)["month"]-1]
	
	if prec_inz_sett_m == prec_fin_sett_m:
		settimana_prec = "dal "+str(prec_inz_sett_g)+" al "+str(prec_fin_sett_g)+" "+prec_inz_sett_m
	else: settimana_prec = "dal "+str(prec_inz_sett_g)+" "+prec_inz_sett_m+" al "+str(prec_fin_sett_g)+" "+prec_fin_sett_m
	
	if inz_sett_m == fin_sett_m:
		settimana_corr = "dal "+str(inz_sett_g)+" al "+str(fin_sett_g)+" "+inz_sett_m
	else: settimana_corr = "dal "+str(inz_sett_g)+" "+inz_sett_m+" al "+str(fin_sett_g)+" "+fin_sett_m
	
	if succ_inz_sett_m == succ_fin_sett_m:
		settimana_succ = "dal "+str(succ_inz_sett_g)+" al "+str(succ_fin_sett_g)+" "+succ_inz_sett_m
	else: settimana_succ = "dal "+str(succ_inz_sett_g)+" "+succ_inz_sett_m+" al "+str(succ_fin_sett_g)+" "+succ_fin_sett_m

func aggiorna_ultimo_avvio():
	ultimo_avvio_gio = str(giorno)+" "+mese+" "+str(anno)
	ultimo_avvio_set = settimana_corr
	salva_dati("ultimo_avvio")

func esegui_backup(tipo = "pre-apertura"):
	if not Directory.new().file_exists(perc_file_conf):
		print("RIPRISTINO: Nessun file di config presente")
		return
	
	var file_config = ConfigFile.new()
	if   tipo == "pre-apertura":
		print("RIPRISTINO: Salvataggio backup pre-apertura")
		file_config.load(perc_file_conf)
		file_config.save(perc_file_conf+".bak")
	elif tipo == "manuale":
		print("RIPRISTINO: Salvataggio backup manuale")
		bak_manuale = str(giorno)+"_"+mese_c
		salva_dati("settaggi")
		file_config.load(perc_file_conf)
		file_config.save(perc_file_conf+"_"+bak_manuale+".bak")

func ripristina_backup(quale = "pre-apertura"):
	print("RIPRISTINO: " + quale)
	var file_config = ConfigFile.new()
	if quale == "pre-apertura":
		if Directory.new().file_exists(perc_file_conf+".bak"):
			file_config.load(perc_file_conf+".bak")
			file_config.save(perc_file_conf)
			carica_dati("tutto")
		else: print("Nessun back-up presente")

func _set_contabilita_visibile(val):
	fl_cont_vis = val
	main.get_node("barra_sotto/v_box_btns/btn_contabilita").visible = val
	if !val and fin_contabilita.visible: yield(get_tree(),"idle_frame") ; main.mostra_fin(0)
	
	var opt_bnt_fin = fin_settaggi.get_node("v_box_tgg/avvia_fin/opt_btn")
	var opt_compila = ["turni","rubrica","preventivo"]
	opt_bnt_fin.clear()
	for opz in opt_compila: opt_bnt_fin.add_item(opz)
	if val:
		opt_bnt_fin.add_item("contabilità") ; opt_bnt_fin.select(fl_mostra_fin)
	elif fl_mostra_fin == 3:
		opt_bnt_fin.select(0)
	else:
		opt_bnt_fin.select(fl_mostra_fin)

func lista_nomi_aggiornata(): #quando la lista nomi viene aggiornata si fa l'update sulle liste popup
	print("LISTA NOMI: aggiornata nei popup")
	fin_contabilita.get_node("barra_sopra/nuova_voce/cliente").compila_lista()
	fin_preventivo.get_node("cnt_nuovo_prev/riga_contatto/nome").compila_lista()