

/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	Section :
	Permet de decouper un scene pour par exemple rendre un plan 3D ou une coupe 3D.
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [25/06/2018] -----------------------------------------------------------------------------
	- Mise en place globale
########################################################################################################################*/


/* 
delete $Sectionneur_helper*
 */

if Sectionneur != undefined do Sectionneur.fermer () 



-- global Sectionneur	


filein	 "$userScripts\\cp-Sectionneur\\cp - Sectionneur - Material Plugin.ms" 
filein	 "$userScripts\\cp-Sectionneur\\cp - Sectionneur - Helper Plugin.ms" 



------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
(	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Debug.ms"  )
------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------





------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_sectionneur "sectionneur" width:340 height:223
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	local nds_exclude 	= #()
	local nds_include 	= #()		
	
	
	
	------------  UI	----------------------------------------------------------------------------------		
	listbox 'lbx_sections' "" pos:[10,23] width:156 height:7 align:#left
	pickbutton 'btn_section_nvNode' "+" pos:[134,7] width:16 height:16 align:#left
-- 	button 'btn_section_nvlleBox' "Box" pos:[9,7] width:34 height:16 align:#left
	button 'btn_section_supprimer' "-" pos:[149,7] width:16 height:16 align:#left
	checkbox 'chk_ombres' "Ombres" pos:[19,148] width:67 height:15 checked:true align:#left
	multiListBox 'lbx_include' "" pos:[175,23] width:156 height:14 align:#left
	checkbutton 'btn_on' "ON" pos:[9,185] width:30 height:30 highlightColor:(color 255 255 0) toolTip:"Applique le materiaux de découpe." align:#left
	label 'lbl_include' "Objets à couper :" pos:[175,7] width:86 height:14 align:#left
	button 'btn_ajouter_ndACouper' "+" pos:[302,7] width:16 height:16 align:#left
	label 'lblsections' "Découpeurs:" pos:[12,7] width:61 height:14 align:#left
	button 'btn_creer_fichierCoupe' "Creer fichier Coupe" pos:[38,185] width:114 height:30 align:#left
	button 'btn_retirer_ndACouper' "-" pos:[317,7] width:16 height:16 align:#left
	button 'btn_option_fichierCoupe' "+" pos:[151,185] width:16 height:30 align:#left
	GroupBox 'grpOptions' "Options" pos:[10,133] width:155 height:48 align:#left
	checkbox 'chk_touteLaScene' "Appliquer à toute la scène" pos:[10,119] width:156 height:15 checked:true align:#left
	checkbox 'chk_planDeCoupe' "Plan de coupe" pos:[19,163] width:88 height:15 checked:true align:#left
	colorPicker 'cp_planDeCoupe' "" pos:[144,163] width:15 height:15 align:#left
	
	
	
	------------  Fonctions	----------------------------------------------------------------------------------	
	fn redimensionner		=(
		if m_prt.get_touteLaScene () then
			roll_sectionneur.width = 175
		else 
			roll_sectionneur.width = 341
	)
	fn actualiser = (
		
		lbx_sections.items		= 	for section in m_prt.get_sections() collect section.name
		chk_ombres.checked 	= 	m_prt.get_ombresUse ()
-- 		rdo_applyTo.state 		=	m_prt.get_mode ()
		chk_touteLaScene.checked = m_prt.get_touteLaScene () 
		btn_on.checked 	= 	m_prt.est_actif ()
		
		nds_include					=	m_prt.get_nds_aCouper ()
		lbx_include.items 			=	for obj in nds_include where obj != undefined collect obj.name
		
	)
	
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		redimensionner ()
		actualiser ()
		
	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------	
	
	on lbx_sections doubleClicked sel do
		select (m_prt.get_sections() ) [ sel ]
	on btn_section_nvNode picked obj do
	(
			m_prt.ajouter_section	obj
			actualiser ()	
		)
	on btn_section_supprimer pressed do
	(
			m_prt.retirer_section	lbx_sections.selection
			actualiser ()	
		)
	on chk_ombres changed state do
		m_prt.set_ombresUse	 state
	on btn_on changed state do
	(
				case state of (
					true:		m_prt.activer 		()
					false: 	m_prt.desactiver 	()
				)
			)
	on btn_ajouter_ndACouper pressed do
	(
						m_prt.ajouter_ndAcouper	(selection as array )
						actualiser ()	
		)
	on btn_creer_fichierCoupe pressed do
	(
		m_prt.creer_fichierCoupe	()
	)
	on btn_retirer_ndACouper pressed do
	(
						m_prt.ajouter_ndAcouper	(selection as array )
						actualiser ()	
		)
	on btn_option_fichierCoupe pressed do
	(
		m_prt.creer_fichierCoupe	()
	)
	on chk_touteLaScene changed state do (
		m_prt.set_touteLaScene	 state
		redimensionner ()
	)
	on chk_planDeCoupe changed state do
		m_prt.set_ombresUse	 state
)



------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_sectionneur (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	
			try if m_debug  do ::debuger 	_txt	prefix:"Sectionneur "	  	var:var	 param:param		catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	
	
	------------  Membres	----------------------------------------------------------------------------------
	private
		--- si la coupe est active ----------------
		actif 				= 	false,
		effectif			=	false,
		
-- 		mode				=	1,		---- ( 1: Scene, 2: nodes, 3: layers, 4: Xrefs	)
		touteLaScene	=	true,
		ombres_use	=	true,
		
		---- Materiau / map pour la découpe --------------
		distMap 			= CoronaDistance (),
		invisMat 		= CoronaMtl (),
		materiaux_decoupe =#(),
		
		
		--- sections -----
		sections 		=	#(),
		
		--- nodes a couper -------------
		nds_aCouper 	=	#(),
		hlp_sectionneur = undefined,
		
	private
		
		---- Fenetre ----
		dialog			= roll_sectionneur ,		---- le rollout ----
		dialog_pos 		= [100,100],
		dialog_taille 	= [dialog.width, dialog.height ],
		
		---- calque temporarire pour les objets des ombres --------------
		calque_temp,
		calque_temp_nom	=	"000 - Section - Ombres -TEMP",
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
	private
		
		------ Helper Sectionneur -------------------
		fn maj_hlp_sectionneur =(
			
			hlp_sectionneur.set_touteLaScene		touteLaScene
			hlp_sectionneur.set_actif					actif
			hlp_sectionneur.set_ndsSections		sections
			hlp_sectionneur.set_ndsAcouper			nds_aCouper
			
		),
		fn maj_FROM_sectionneur 		_nd	=(
			
			touteLaScene	=	_nd.get_touteLaScene		()		
			actif				=	_nd.get_actif 		()
			nds_aCouper	=	_nd.get_ndsAcouper ()
			sections			=	_nd.get_ndsSections ()
		),
		fn get_sectionneur_helper	=(
			
			
			local sectionneur_hlp = undefined
			local instances_hlp	=	getclassinstances  Sectionneur_helper 
			
			if instances_hlp.count > 1 then 
				for i = instances_hlp.count to 2 by -1 do 
					deleteItem 	instances_hlp
			else if instances_hlp.count == 0  then 
				sectionneur_hlp = Sectionneur_helper ()
			else
				sectionneur_hlp = instances_hlp[1]
			
			maj_FROM_sectionneur 	sectionneur_hlp
			
			sectionneur_hlp
		),
		
		
		------------------  Accessions ------------------------------------------
	private		
		fn get_nodesACouper_fromScene	 =(
			for obj in geometry		where 	 est_porteur_matACouper	obj	collect 	obj		
		),
		
	public
		fn get_nds_aCouper 		= 	for nd in nds_aCouper collect nd,	
		fn est_actif					=	actif,
		fn get_sections				=	for sect in sections collect sect,
		fn set_touteLaScene	_touteLaScene		= 	(
			touteLaScene = _touteLaScene
			maj_hlp_sectionneur()
		),
		fn get_touteLaScene		= 	touteLaScene,
		fn get_ombresUse			=	ombres_use,
		fn set_ombresUse	_val	= with redraw off 	(
			ombres_use = _val
			materiaux_decoupe.shadows = ombres_use
		),
		fn get_blendMat 				=  (
			
			local blendMat 			=	Blend ()			
			blendMat.map2			=	invisMat
			blendMat.mask			=	distMap
			
			blendMat
		),
		fn get_objects_byMat 	_mat =(
			for obj in geometry where obj.material == _mat	collect obj
		),
		
		
		------ divers tests ---------------------------------------
		fn estValide_prMatSection		_nd =(
			result = true
			
			if not _nd.renderByLayer	and not _nd.renderable 			then	result = false
			else if _nd.renderByLayer	and not _nd.layer.renderable 	then	result = false			
			else if est_section obj 													do	result = false
			
			result
		),
		fn est_porteur_matACouper		_node	=(
			local result	=	false
			case classOf _node.material of (
					Multimaterial:	(
						for i = 1 to _node.material.materialList.count	 do 
							if classof _node.material.materialList[i] == sectionneur_material do
							result = true
					)
					Blend:	(
						if classof _node.material.map1 == sectionneur_material do
							result = true
						if classof _node.material.map2 == sectionneur_material do
							result = true
					)
					DoubleSided:	(
						if classof _node.material.material1 == sectionneur_material do
							result = true
						if classof nd.material.material2 == sectionneur_material do
							result = true
					)
					sectionneur_material:			result = true
				) -- fin case -----
			result
		),
		fn est_aCouper 		_node 	=(
			if findItem	nds_aCouper 	_node != 0 then true else false
		),
		fn est_section		_node =(
			local result = false
			if findItem sections 	_node != 0 then result = true
			result
		),		
		
		
		
		
		
		
		
	---------- Materiau Section	----------------------------------------------------------------------------------------------------------------
	private
		------- Divers ---------------------------------
		fn preparer_materiau_section	 =(
			
			--- la map de distance ---------------
			distMap						=	CoronaDistance		name:"Section - DistMap"
			distMap.colorNear		=	black
			distMap.colorFar			=	black
			distMap.colorInside		=	white
			distMap.useInside		=	true
			distMap.distanceNear	=	0.
			distMap.distanceFar		=	0.
			
			--- le materiau invisible -------
			invisMat 					=	CoronaMtl	name:"Section - Invisible"
			invisMat.levelOpacity	=	0
			
		),
		fn retirer_materiau_section		_node	=(
			
			
			case classOf _node.material of (
				Multimaterial:	(
					for i = 1 to _node.material.materialList.count	 do 
						if classof _node.material.materialList[i] == sectionneur_material do
							_node.material.materialList[i]		= _node.material.materialList[i].'Base material'
				)
				Blend:	(
					if classof _node.material.map1 == sectionneur_material do
						_node.material.map1					= 	_node.material.map1.'Base material'
					if classof _node.material.map2 == sectionneur_material do
						_node.material.map2					= 	_node.material.map2.'Base material'
				)
				DoubleSided:	(
					if classof _node.material.material1 == sectionneur_material do
						_node.material.material1					= 	_node.material.material1.'Base material'
					if classof nd.material.material2 == sectionneur_material do
						_node.material.material2					= 	_node.material.material2.'Base material'
				)
				sectionneur_material:			_node.material	=	 _node.material.'Base material'
				Sectionneur_undefined_mat:	_node.material	=	 undefined
			) -- fin case -----
			
		),		
		fn get_matSection_fromMat		_mat	=(
			
			local result
			
			case classOf _mat of (
				Multimaterial:	(
					local multiMat	=	copy _mat
					
					for i = 1 to _mat.materialList.count	 do (
						--- on applique le materiau Section -------------
						local mat_section 				= 	sectionneur_material ()
						mat_section.nds_sections		=	get_sections ()
						mat_section.'Base material' 	=	_mat.materialList[i]
						multiMat.materialList[i]			= 	mat_section
						append materiaux_decoupe 	mat_section
					)
					result = multiMat
				)
				Blend:			(
					local blendMat	=	Blend ()
					
					--- on applique le materiau Section -------------
					local mat_section 				= 	sectionneur_material ()		
						mat_section.nds_sections		=	get_sections ()		
					mat_section.'Base material' 	=	_mat.map1
					blendMat.map1					= 	mat_section
						append materiaux_decoupe 	mat_section
				
					--- on applique le materiau Section -------------
					local mat_section 				= 	sectionneur_material ()		
						mat_section.nds_sections		=	get_sections ()		
					mat_section.'Base material' 	=	_mat.map2
					blendMat.map2					= 	mat_section
						append materiaux_decoupe 	mat_section
					
					result = blendMat
				)
				DoubleSided:	(
					local dbleSideMat	=	DoubleSided ()
					
					--- on applique le materiau Section -------------
					local mat_section 				= 	sectionneur_material ()		
						mat_section.nds_sections		=	get_sections ()		
					mat_section.'Base material' 	=	_mat.material1
					dbleSideMat.material1			= 	mat_section
						append materiaux_decoupe 	mat_section
				
					--- on applique le materiau Section -------------
					local mat_section 				= 	sectionneur_material ()		
						mat_section.nds_sections		=	get_sections ()		
					mat_section.'Base material' 	=	_mat.material2
					dbleSideMat.material2			= 	mat_section
						append materiaux_decoupe 	mat_section
					
					result 								= dbleSideMat
					
				)
				default:			(
					--- on applique le materiau Section -------------
					local mat_section 				= sectionneur_material ()		
						mat_section.nds_sections		=	get_sections ()		
					mat_section.'Base material' 	=	copy _mat
					mat_section.'Base material'.name	=	_mat.name
					result 								= mat_section
					append materiaux_decoupe 	mat_section
				)
			)
			result
		),
		
		------- Appliquer / retirer ---------------------------------
		fn appliquer_matSection =  with undo off with redraw off (
			
			debug "appliquer_matSection"
			
			--- Progress bar ---------------------------
			local tmp1 = timeStamp ()
			local compteur = 0.
			progressStart ( "Creation des texture de decoupe" )
			
			
			----- Analyses ----------------------------------------
			materiaux_decoupe 			= #()
			local mats_aRemplacer		=	#()
			local nds_sansMat			=	#()
			for obj in geometry	where not est_section obj do (
				if  obj.material != undefined then
					appendIfUnique	mats_aRemplacer		obj.material
				else
					append nds_sansMat	obj
			)
			
			
			local tmp2 = timeStamp ()
			debug ("---	Analyses  	" +  (  ( tmp2 - tmp1 ) / 1000.0)	as string  + " s." )
			
			----- objets sans materiaux ----------------------------
			if nds_sansMat.count > 0 do (
				local appliquer_mat	=	queryBox	"Il y a des objects sans materiaux dans la scene.\nLes objets onts besoin d'un materiaux pour être coupé.\nVoulez-voux appliquer_matSection un materiaux Corona de base ?"
				if appliquer_mat do (
					debug "appliquer_matSection MATERIAUX de base."
				)
			)
			
			
			
			local tmp3 = timeStamp ()
			debug ("---	objets sans materiaux   	" +  (  ( tmp3 - tmp2 ) / 1000.0)	as string  + " s." )
			
			
			
			---- on regarde quelles nodes ca concerne pour determiner à quel nodes on applique ------------------
			local nodes_aCouper =#()
			
			
			case touteLaScene of(
				true: ( ------------------------------------- SCENE -------------------------------------
-- 						local mats = for mat in sceneMaterials collect mat
					
						debug "mats_aRemplacer" var:mats_aRemplacer		param:#name
					
						for mat in mats_aRemplacer	do (
							
							--- Progress bar ---------------------------
							compteur += 1.
							progressUpdate 	( compteur  / mats_aRemplacer.count * 100 )
							
-- 							debug "\ncompteur"	var:compteur
-- 							debug "( compteur  / mats.count * 100 )" var:( compteur  / mats_aRemplacer.count * 100 )
							
							local mat_section 		= get_matSection_fromMat 	mat
							replaceinstances		mat		mat_section
							
						)
						
					
					
				) --- fin 1		: scene-----------------------------
				
				
				
				
				
				
				false:	( ------------------------------------- NODES -------------------------------------
					nodes_aCouper = get_nds_aCouper ()
					
					local nodes_aTraiter = for nd in  nodes_aCouper collect nd
					
					
					---- on fait  des listes  d'objets regroupés par materiaux ----------------
					while nodes_aTraiter.count>0	 /* and compteur < 200 */  do (
						
						
						--- Progress bar ---------------------------
						compteur += 1
						local progress_val 	= ( ( nodes_aCouper.count as float ) - ( nodes_aTraiter.count  as float ) ) 
						progress_val 			= progress_val  / nodes_aCouper.count * 100
						progressUpdate 	progress_val
						
						
						
						local nd 			= nodes_aTraiter[	1	]
						if nd != undefined do (
							if  nd.material  != undefined then (
								
								---- DEBUG IF TRUE -------------------
								if false then (
			-- <Sectionneur >	---	total  	69.782 s.
									nd.material	=	get_matSection_fromMat 	nd.material
									deleteItem nodes_aTraiter 1
								) else (
								---- DEBUG BACK -------------------
									local ids_aSupprimer 	= #{}
									local	objs_memeMat 	= for i = 1 to nodes_aTraiter.count where   nodes_aTraiter[i] != undefined  	and  nodes_aTraiter[i].material == nd.material  	collect  ( ids_aSupprimer[i] = true; nodes_aTraiter[i] )
				-- 					replaceInstances 
									
									local mat_section 		= get_matSection_fromMat 	nd.material
			-- 						replaceinstances	nd.material	mat_section
									objs_memeMat.material = mat_section
									
									for i = (ids_aSupprimer as array).count to 1 by -1 do 
										deleteItem nodes_aTraiter 	( ( ids_aSupprimer) as array)[i]
								)
								
							) else (	
								
								
								local mat_section 	= get_matSection_fromMat 	( Sectionneur_undefined_mat 	name:"Sectionneur_undefined_mat"		color:nd.wirecolor )
								nd.material 			= mat_section
								
								deleteItem nodes_aTraiter 1
								
							)
						)
					)
					
				)
				3: (--- Xrefs ---
					
				)
			)
			
			
			---- TRICK pour cleaner le scenesMaterials :		on sauvegarde un fichier vide -----------
			saveNodes #() (getdir #temp + "\\back.bak") quiet:on
			
			
			
			
			
			
			local tmp4 = timeStamp ()
			debug ("---	appliquer_matSection les mats  	" +  (  ( tmp4 - tmp3 ) / 1000.0)	as string  + " s." )
			
			progressEnd() 
			
			debug "fin appliquer_matSection"
			debug ("---	total  	" +  (  ( tmp4 - tmp1 ) / 1000.0)	as string  + " s." )

			
-- 			debug ("---	part 1  	" +  (  ( tmp2 - tmp1 ) / 1000.0)	as string  )
-- 			debug ("---	part 2  	" +  (  ( tmp3 - tmp2 ) / 1000.0)	as string  )
-- 			debug ("---	total  	" +  (  ( tmp3 - tmp1 ) / 1000.0)	as string  )
			
			
		),		
		fn retirer_matSection =(
			
			debug "retirer_matSection"
			
			--- Progress bar ---------------------------
			local compteur = 0.
			progressStart ( "Suppression des texture de decoupe" )
			
			for nd in geometry do (
				
				--- Progress bar ---------------------------
				compteur += 1.
				progress_val 		= compteur  / geometry.count * 100
				progressUpdate 	progress_val
				
				retirer_materiau_section 	nd
				
			)
			progressEnd() 
		),
		
		
		
		
		
	------------  Interface	----------------------------------------------------------------------------------------------------------------
	public
		--- Sections -------------------
		fn ajouter_section			_node 	= if _node != hlp_sectionneur	do	(
			
			---- on retire les node deleted -------------
			local id_deleted =#()
			for i = 1 to sections.count do
				if isDeleted sections[i]  do
					append id_deleted  i
			for i = id_deleted.count to 1 by -1 do
				deleteItem sections  id_deleted[i]
			
			-- on le retire des nodes a couper si besoin --------
			if est_aCouper _node do
				this.retirer_ndAcouper	_node
			
			---- on so'ccupe de notre section ----------
			_node.material = undefined
			_node.displayByLayer  	= false
			_node.renderByLayer  	= false
			_node.boxMode 			= true
			_node.renderable  		= false
			
			
			---- on l'applique au distance map  ----------
			appendIfUnique  sections		_node
			distMap.nodes = sections
			
			maj_hlp_sectionneur ()
			
		),
		fn retirer_section		id_aSuppr	 =(
			if id_aSuppr != 0 do
				deleteItem	sections	id_aSuppr
			
			maj_hlp_sectionneur ()
			
		),
		
		--- Noeud cibles   -------------------
		fn ajouter_ndAcouper		_nodes	=(
			
			
			if classof _nodes != array do
				_nodes = #(_nodes)
			for nd in _nodes where superclassof nd == GeometryClass and 	not est_section nd	do (
				
				-- on le retire des nodes a couper si besoin --------
				if est_section	 nd do
					this.retirer_section	_node
				
				appendIfUnique	nds_aCouper	nd
				
			)
			
			maj_hlp_sectionneur ()
			
		),
		fn retirer_ndAcouper		_node =(
			local id_aSuppr = findItem	nds_aCouper 	_node
			if id_aSuppr != 0 do
				deleteItem	nds_aCouper	id_aSuppr
			
			maj_hlp_sectionneur ()
			
		),
		
		
		
		------  Activater / desactiver ----------------------------------------------------------------------
	public
		fn desactiver =(
			actif = false
			maj_hlp_sectionneur()
			retirer_matSection ()
		),
		fn activer 	=(
			actif = true
			maj_hlp_sectionneur()
			appliquer_matSection ()
		),
		
		
		
		----- fichier ----------
		fn creer_fichierCoupe 		=(
			
			if maxFileName == undefined then (
				messagebox "enregistrer votre fichier d'abord !"
				
			) else with  undo off with redraw off  (
				
				--- ?  Faire un hold ? ----------
				
				----- Activer la coupe si besoin -----------------------
				local actifBack = actif
				if not actifBack do activer ()
				
				----- Enregistrer le fichier  -----------------------
				local nom_fichierCoupe	=	maxFilePath + getFilenameFile  maxFileName + " - Coupe.max"
				saveMaxFile 	nom_fichierCoupe		useNewFile:false		clearNeedSaveFlag:false		quiet:true
				
				
				--- ? et donc un fetch ici ?  sinon on desactive tout ----------				
				----- Desactiver la coupe si besoin -----------------------
				if not actifBack do desactiver ()		
				actif	= actifBack
				
			)  
			
		),
		
		
		
		
		---- fenetre ------------------------------------------------------------------------------
		fn ouvrir =(			
			
-- 			nds_aCouper = get_nodesACouper_fromScene ()
			
			hlp_sectionneur	=	get_sectionneur_helper ()
			maj_FROM_sectionneur		hlp_sectionneur
			
			createDialog dialog 	pos:					dialog_pos
			dialog.m_prt	 	= this
			dialog.initialiser ()
		),		
		fn fermer  =(	
			dialog_pos = getDialogPos dialog
			try destroydialog dialog catch ()
		),
		
		 ------------  Evenements	----------------------------------------------------------------------------------
		on create do (
			preparer_materiau_section ()
		)
		
) --- fin struct ----------------------------------



---- declaration du manager de scetions ----------------
Sectionneur		=	str_sectionneur ()




