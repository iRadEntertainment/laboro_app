#==============================#
#      UTILITA' (per app)      #
#==============================#

extends Node

#--------------- operazioni File --------------
func leggi_contenuto_file(perc):
	var file=File.new()
	file.open(perc, File.READ)
	var contenuto = file.get_as_text()
	file.close()
	return contenuto

func salva_file_con_nuovo_contenuto(cartella, nome_file, contenuto):
	var dir = Directory.new()
	if not dir.dir_exists(cartella):
		dir.make_dir(cartella)
		print( str("UTL_FILE: Cartella '",cartella,"' non trovata. Creata nuova cartella") )
	var file=File.new()
	file.open((cartella+nome_file), File.WRITE)
	file.store_string(contenuto)
	file.close()
	print( str("UTL_FILE: File ",nome_file," salvato") )

func elimina_file(perc):
	var dir = Directory.new()
	dir.remove(perc)
	print( str("UTL_FILE: File ",perc," eliminato") )

func controllo_file_esist(perc):
	var file = Directory.new()
	var result = file.file_exists(perc)
	if not result:
		print( str("UTL_FILE: File ",perc," non trovato") )
	return result


#--------------- operazioni .FODT e .PDF --------------
func crea_fodt_da_templ(perc_templ_fodt, perc_dir_salv, nome_nuovo_fodt, da_sostituire, da_immettere):
	if not controllo_file_esist(perc_templ_fodt):
		return
	var fodt_contenuto = leggi_contenuto_file(perc_templ_fodt)
	yield(get_tree(),"idle_frame")
	
	if da_sostituire.size() != da_immettere.size():
		print( str("UTL_FODT: array da_sostituire (size= ",da_sostituire.size(),") e da_immettere (size= ",da_immettere.size() ,") diversi!") )
		return
	
	for i in range( da_sostituire.size() ):
		fodt_contenuto = fodt_contenuto.replacen( da_sostituire[i], da_immettere[i] )
	
	
	salva_file_con_nuovo_contenuto(perc_dir_salv, nome_nuovo_fodt, fodt_contenuto)


func converti_in_pdf_soffice(glob_dir_salva, glob_nome_fodt):
	var uscita_cmd = []
	OS.execute("soffice",["--headless", "--convert-to","pdf", "--outdir", glob_dir_salva, glob_nome_fodt],true,uscita_cmd)
	print( str("GENERA PDF: uscita_cmd -> " , uscita_cmd) )


#---------------------- UTILITA' ---------------------------
func richiama_attenzione(quale_nodo):
	var inst_attenzione = load("res://finestre/attnz.tscn").instance()
	quale_nodo.add_child(inst_attenzione)

func rendi_decimale2str(num):
	var convertito = float(round(float(num)*10))/10
	if   convertito == 0:              convertito = " - "
	elif (int(convertito*10))%10 != 0: convertito = str(convertito)+"0"
	else:                              convertito = str(convertito)+".00"
	return convertito

func arr_min_max(arr):
	var arr_sort = []
	for val in arr:
		arr_sort.push_back(val)
	arr_sort.sort()
	return Vector2(arr_sort[0], arr_sort[arr_sort.size()-1])

func n_base():
	var nodo = null
	return nodo