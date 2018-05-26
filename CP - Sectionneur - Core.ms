

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


if Sectionneur != undefined do Sectionneur.fermer () 



------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
(	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Debug.ms"  )
------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------




----- le  plugin material  ---------------------------
(	include	 "$userScripts\\cp-Sectionneur\\cp - Sectionneur - Material Plugin.ms" 	)



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_sectionneur "sectionneur" width:522 height:232
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	
	
	------------  UI	----------------------------------------------------------------------------------		
	listbox 'lbx_sections' "" pos:[10,23] width:156 height:7 align:#left
	pickbutton 'btn_section_nvNode' "Node" pos:[43,7] width:34 height:16 align:#left
	button 'btn_section_nvlleBox' "Box" pos:[9,7] width:34 height:16 align:#left
	pickbutton 'btn_section_supprimer' "Suppr." pos:[131,7] width:34 height:16 align:#left
	checkbox 'chk_ombres' "Ombres" pos:[9,121] width:117 height:15 checked:true align:#left
	radiobuttons 'rdo_applyTo' "Apply to :" pos:[9,139] width:108 height:46 labels:#("Scene", "Nodes", "Layers", "XRef") columns:2 align:#left
	checkbutton 'btn_appliquer' "Appliquer Sections" pos:[9,189] width:156 height:34 align:#left
	listbox 'lbx_exclude' "" pos:[181,23] width:156 height:15 align:#left
	listbox 'lbx_include' "" pos:[354,23] width:156 height:15 align:#left
	button 'btn_to_include' ">" pos:[338,25] width:16 height:16 align:#left
	button 'btn_to_exclude' "<" pos:[338,40] width:16 height:16 align:#left
	label 'lbl_exclude' "Exclude" pos:[181,7] width:44 height:14 align:#left
	label 'lbl_include' "Include" pos:[354,7] width:44 height:14 align:#left
	button 'btn_selection_to_include' "+" pos:[338,65] width:16 height:16 align:#left
	
	
	
	------------  Fonctions	----------------------------------------------------------------------------------	
	
	fn actualiser = (
		lbx_sections.items		= for section in m_prt.sections collect section.name
		chk_ombres.checked 	= m_prt.ombres_use
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------

	
	
	on btn_section_nvNode picked obj do
	(
		m_prt.ajouter_section	obj
		actualiser ()
	)
	on btn_section_nvlleBox pressed do
		(
		
	)
	on btn_section_supprimer picked obj do
	(
		
		)
	on chk_ombres changed state do
	(
		m_prt.ombres_use = state
	)
	on rdo_applyTo changed stat do
	(
		m_prt.appliquerA	= stat
		)
	on btn_appliquer changed state do
	(
			case state of (
				true:		m_prt.appliquer 		()
				false: 	m_prt.retirer_tout 	()
			)
		)
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
		
		actif 		= false,
		
		---- Fenetre ----
		dialog			= roll_sectionneur ,		---- le rollout ----
		dialog_pos 		= [100,100],
		dialog_taille 	= [roll_sectionneur.width, roll_sectionneur.height ],
		
	public
		---- Materiau / map pour la découpe --------------
		distMap 			= CoronaDistance (),
		invisMat 		= CoronaMtl (),
		
		--- sections -----
		sections 		=	#(),
		appliquerA		=	1,		---- ( 1: Scene, 2: nodes, 3: layers, 4: Xrefs	)
		
		--- Ombre---------
		ombres_use		=	true,
		ombres_nodes		=	#(),
		
		------------  Fonctions	----------------------------------------------------------------------------------
	private
	
		----------------- Ecouteurs	----------------------
		fn activer_prePost_rendu =(
			
			---- PRERENDU	-----------
			callbacks.removescripts 	id:	#sectionneur_preRender
			callbacks.removescripts 	id:#sectionneur_postRenderProxy
			gc()
			
			
			global terrains_asProxy =#()
			local		txt_pre ="with redraw off (\n"
						txt_pre +="	format\"sectionneur_preRender : %\\n\"	Sectionneur \n"
						txt_pre +="	Sectionneur.creer_ombres_objets ()\n	"
						txt_pre +=")"
			callbacks.addscript 	#preRender 	txt_pre 		id:#sectionneur_preRender



			---- post rendu	-----------
			local		txt_post ="with redraw off (\n"
						txt_post +="	format\"sectionneur_postRenderProxy: %\\n\"	Sectionneur 	\n	"
						txt_post +="	Sectionneur.supprimer_ombres_objets ()\n	"
						txt_post +=")"
			callbacks.addscript 	#postRender 	txt_post 		id:#sectionneur_postRenderProxy

		),
		
		
		
	
	
	
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
			invisMat 						=	CoronaMtl	name:"Section - Invisible"
			invisMat.levelOpacity		=	0
			
		),
		
		fn est_section		_node =(
			local result = false
			if findItem sections 	_node != 0 then result = true
			result
		),
		
		fn est_ombre		_node =(
			local result = false
			if findItem ombres_nodes 	_node != 0 then result = true
			result
		),
		
-- 	public		
		
		------------  Interface	----------------------------------------------------------------------------------
	public
		fn ajouter_section	_node =(
			appendIfUnique  sections		_node
			distMap.nodes = sections
		),
		fn retirer_matSection		_node	=(
			
			
			case classOf _node.material of (
				Multimaterial:	(
					for i = 1 to _node.material.materialList.count	 do 
						if classof _node.material.materialList[i] == sectionneur_material do
							_node.material.materialList[i]		= _node.material.materialList[i].'Base material'
				)
				Blend:	(
					_node.material.map1					= 	_node.material.map1.'Base material'
					_node.material.map2					= 	_node.material.map2.'Base material'
				)
				DoubleSided:	(
					if classof _node.material.material1 == sectionneur_material do
						_node.material.material1					= 	_node.material.material1.'Base material'
					if classof nd.material.material2 == sectionneur_material do
						_node.material.material2					= 	_node.material.material2.'Base material'
				)
				sectionneur_material:	_node.material	=	 _node.material.'Base material'
			) -- fin case -----
			
		),
		fn retirer_tout =(
			
			actif = false
			
			for nd in geometry do 
				retirer_matSection 	nd
		),
		
		
		fn appliquer 	=(
			debug "appliquer"
			actif = true
			
			---- on regarde quelles nodes ca concerne ------------------
			local nodes_aCouper =#()
			case appliquerA of(
				1: ( --- Scene ---
					nodes_aCouper = for obj in geometry where  not est_section obj	and not est_ombre obj collect obj	
				)
				2:	( --- nodes ---
				
				)
				3: ( --- layers ---
					
				)
				4: ( --- Xrefs ---
					
				)
			)
			
			
			progressStart ( "Creation des texture" )
			
			local compteur = 0
			---- on applique le mat de decoupe ------------------
			for nd in nodes_aCouper 	do (
				
				compteur += 1
				local pourCent = (compteur as float) / nodes_aCouper.count * 100
				progressUpdate pourCent
				
				--- si le node n'a pas de mat on lui en applique un -------------
				if nd.material == undefined do
					nd.material = CoronaMtl	 colorDiffuse:nd.wirecolor
				
				case classOf nd.material of (
					Multimaterial:	(
						for i = 1 to nd.material.materialList.count	 do (
							--- on applique le materiau Section -------------
							local mat_section 				= 	sectionneur_material ()				
							mat_section.'Base material' 	=	nd.material.materialList[i]
							nd.material.materialList[i]		= 	mat_section
						)
					)
					Blend:			(
						--- on applique le materiau Section -------------
						local mat_section 				= 	sectionneur_material ()				
						mat_section.'Base material' 	=	nd.material.map1
						nd.material.map1					= 	mat_section
					
						--- on applique le materiau Section -------------
						local mat_section 				= 	sectionneur_material ()				
						mat_section.'Base material' 	=	nd.material.map2
						nd.material.map2					= 	mat_section
					)
					DoubleSided:	(
						--- on applique le materiau Section -------------
						local mat_section 				= 	sectionneur_material ()				
						mat_section.'Base material' 	=	nd.material.material1
						nd.material.material1			= 	mat_section
					
						--- on applique le materiau Section -------------
						local mat_section 				= 	sectionneur_material ()				
						mat_section.'Base material' 	=	nd.material.material2
						nd.material.material2			= 	mat_section
					)
					default:			(
						--- on applique le materiau Section -------------
						local mat_section 				= sectionneur_material ()				
						mat_section.'Base material' 	=	nd.material
						nd.material 						= mat_section
					)
				)
				
				
			)
			progressEnd() 
			debug "fin appliquer"
		),
		
		
		fn creer_ombres_objets = 	if actif and ombres_use do (
			
			debug "creer_ombres_objets" var:actif
			
			ombres_nodes= #()
			local nodes_aDupliquer = for obj in geometry where not est_section obj	collect  obj
			for obj in nodes_aDupliquer where obj.renderByLayer	and obj.layer.renderable or obj.renderable	do (
				
				local node_dupl =  instance  obj 
				retirer_matSection   node_dupl
				append ombres_nodes  node_dupl
				node_dupl.renderByLayer		=	false
				node_dupl.primaryVisibility 	= false
				
			)
			
		),
		fn supprimer_ombres_objets =  if actif and ombres_use  do (
			debug "supprimer_ombres_objets"
			delete ombres_nodes 
			ombres_nodes= #()
		),
		
		
		---- fenetre ------------------------------------------------------------------------------
		fn ouvrir =(			
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
			activer_prePost_rendu ()
		)
		
) --- fin struct ----------------------------------



global Sectionneur		=	str_sectionneur ()
-- clearlistener ()
Sectionneur.ouvrir ()

Sectionneur.creer_ombres_objets ()
Sectionneur.supprimer_ombres_objets ()





/* 

struct str_section	(
	
	
	
	
	------------ MEMBRES	-------------------------------------------------------------------------------------------------------------------------
	private
		
		---- constantes	-----------------------------------------
		decallage_decoupe		=	10,
		
		
		---- la scene ---------------------------------------------
		sceneACouper_fichier			=	"",
		sceneACouper_nds				=	#(),
		sceneACouper_mats_noms		=	#(),
		
		
		---- les echantillons de materiau ---------------------------------------------
		echantillons_mats		=	#(),
		echantillons_nds			=	#(),
		
		
		---- parametres de découpe ---------------------------
		decoupe_nds				=	#(),
		decoupe_axe				=	#Z_positif,				------		#X_positif,	#X_negatif,		#Y_positif,	#Y_negatif,		#Z_positif,	#Z_negatif		-------------
		decoupe_ht					=	10.,
		decoupe_couleur			=	color 50 50 255,
		
		--- l'objet de decoupe	---------------------------------
		sectionneur_nd					=	undefined,
		distMap			=	CoronaDistance(),
		sectionneur_matInv			=	CoronaMtl(),
		
-- 		--- l'objet de la section créée	---------------------------------
-- 		section_nd					=	undefined,
-- 		section_mat				= CoronaMtl (),
		
		
	------------ FONCTIONS	-------------------------------------------------------------------------------------------------------------------------	
	private 
		----------------	 divers	------------------------------------------------
		fn 	get_BB_scene 	=	(
			
			local result = #( [1e14,1e14,1e14] , [-1e14,-1e14,-1e14] )
			
			for obj in geometry do (
				local BB_obj	=	nodeGetBoundingBox 	obj (matrix3 1)	
				--- min --
				if BB_obj[1].x	< result[1].x	do	result[1].x	= BB_obj[1].x
				if BB_obj[1].y	< result[1].y	do	result[1].y	= BB_obj[1].y
				if BB_obj[1].z	< result[1].z	do	result[1].z	= BB_obj[1].z
				--- max ---
				if BB_obj[2].x	> result[2].x	do	result[2].x	= BB_obj[2].x
				if BB_obj[2].y	> result[2].y	do	result[2].y	= BB_obj[2].y
				if BB_obj[2].z	> result[2].z	do	result[2].z	= BB_obj[2].z
			)
			
			result
			
		),
		fn		verifier_sauvegarde_necessaire	=(			
			---	renvois true si on continue et false si l'operation est annuler --------------
			local result = true 
			if getSaveRequired() do (
				local demande_sauvegarde = yesNoCancelBox "La scène à été modifée. Enregistrer les modifications?" 
				case  demande_sauvegarde of (
					#cancel:	result = false
					#yes:		saveMaxFile 	(maxFilePath + maxFileName)
				)
			)
			result
		),
		
		
		fn 	nomUnique_mat	mat	=	(
			
			debug "nomUnique_mat" var:mat.name
			
			local mats_noms		= 	for mt in sceneMaterials where mt != mat	collect mt.name 
			debug "	---->  mats_noms" var:mats_noms

			local nom_existe		=	findItem mats_noms		mat.name	!= 0 
			debug "	---->  nom_existe" var:nom_existe
			mats_noms
			if nom_existe do (
				mat.name += "+"	
				nomUnique_mat	mat
			)
		),
		
		fn 	nomUnique_materiauxScene	=(
			for mat in sceneMaterials do
				nomUnique_mat  mat
		),
		
		
		----------------  sectionneur et section	--------------------------------------

		fn 	preparer_sectionneur 	=	(
			
			--- creation de l'objet	----------
			local BB_scene			=	get_BB_scene ()
			local sectionneur_taille		=	point3 ( BB_scene[2].x - BB_scene[1].x + 2*decallage_decoupe )		( BB_scene[2].y - BB_scene[1].y  + 2*decallage_decoupe )			( BB_scene[2].z - BB_scene[1].z  + 2*decallage_decoupe )
			local sectionneur_pos		=	BB_scene[1]	+	point3 (  sectionneur_taille.x/2 )		(  sectionneur_taille.y/2  )		(  sectionneur_taille.z/2  )	-	[ 1,1,1 ] *  decallage_decoupe  
			sectionneur_nd					=	box pos:sectionneur_pos		lengthsegs:1 widthsegs:1 heightsegs:1 	length:sectionneur_taille.y	 width:sectionneur_taille.x	height:sectionneur_taille.z	name:"Decoupe"
			
			---- display viewport de l'objet	----------
			sectionneur_nd.displayByLayer  	= false
			sectionneur_nd.renderByLayer  	= false
			sectionneur_nd.boxMode 			= true
			sectionneur_nd.renderable  		= false
			
			--- positionnement pour la decoupe -------------------
			sectionneur_nd.pos.z	=	decoupe_ht
			
		),
		
		
		----------------  echantillons	--------------------------------------		
		fn 	creer_echantillon_materiau		mat 	=(
			
			debug "creer_echantillon_materiau"
			
			
			debug "mat.name"	var:mat.name
			
			
			if appendIfUnique 	echantillons_mats 	mat		do (
			
				local nbre_echantillons		=	($Echantillon_*).count
				local echantillon_nd 		= plane	length:1. width:1.	pos:[nbre_echantillons,0,0]  lengthsegs:1 widthsegs:1	name:(uniqueName "Echantillon_")
				
				echantillon_nd.material 				= mat
				echantillon_nd.renderByLayer  	= false
				echantillon_nd.renderable  		= false
				hide 	echantillon_nd
				
			)
		),
		fn 	creer_echantillons 	mat	= (
			
			--- si l'objet a un materiau ------------
			if mat != undefined then (
				case classof mat of (
					Multimaterial:		for subMat in mat.materialList do 
												creer_echantillon_materiau 	subMat	
					Blend:			(
											creer_echantillon_materiau 		mat.map1
											creer_echantillon_materiau 		mat.map2
					)
					DoubleSided:	(
											creer_echantillon_materiau 		mat.material1
											creer_echantillon_materiau 		mat.material2
					)
					default:				creer_echantillon_materiau		mat
				)
			) else (
				--- sinon, on doit gerer un materiau si on veut le couper------------
				
			)
		),
		fn 	preparer_echantillons 		=(
			debug "preparer_echantillons"
			
			--- on s'assure qu'il n 'y a pas de noms de materiaux en double -------
			nomUnique_materiauxScene()
			
			
			echantillons_mats		=	#()
			delete $Echantillon_*
			
			for obj in geometry do 
				creer_echantillons 	obj.material
			
		),
		
		
		fn appliquer_decoupe 	_matXref 	=(
			
			debug "appliquer_decoupe ***********************"
			local mat_decoupe	=	blend	name:"Decoupe"
			mat_decoupe.map1	=	_matXref
			mat_decoupe.map2	=	sectionneur_matInv
			mat_decoupe.mask	=	distMap
			
			mat_decoupe
		),
		
		
		----------------  les materiaux des objets découpés		--------------------------------------
		fn 	preparer_materiaux_decoupes	_nds	=(
			--- 
			--- limitation de corona: pour l'instant on ne peut pas mettre un multi sub objects dans un blend, ce qui permetterais de mettre directment le mat Xref d'un multiSub dans le blend et ainsi le garde en reference-
			--- du coup là on est obligé de manipuler les mateiraux eux meme, du coup à chaque modifs de la scene d'origine on devra faire une maj de la decoupe ....
			
			
			
			
			
			--- la map de distance ---------------
			distMap						=	CoronaDistance		name:"Distance opacity"
			distMap.nodes				=	#( sectionneur_nd )
			distMap.colorNear		=	black
			distMap.colorFar			=	black
			distMap.colorInside		=	white
			distMap.useInside		=	true
			distMap.distanceNear	=	0.
			distMap.distanceFar		=	0.
			
			--- le materiau invisible -------
			sectionneur_matInv 						=	CoronaMtl	name:"Invisible"
			sectionneur_matInv.levelOpacity		=	0
			
			
			---- on s'occupe des echantillons	----------------------------------------------------
			--- les echantillons ------------
			echantillons_nds			=	$Echantillon_*			
			select echantillons_nds
			for echantillon in echantillons_nds do (
				
				-- on cherche les objets de la scene portant le meme materiau	----------
				local objs_mm_mat	=	for obj in _nds where  obj.material == echantillon.material collect obj
				
				local mat_origine_nom = echantillon.material.name
				
				--- on applique la decoupa au materiau xref	----------
				echantillon.material 		= appliquer_decoupe		echantillon.material
				
				--- on applique le materiaux aux objets	----------
				for obj in objs_mm_mat do
					obj.material = echantillon.material 
				
			
			)
			
			--- on applique dans les materaux composés -----------
			
			
			mat_xref_multi = 	for  mat	in 	sceneMaterials	where  mat != undefined and classof mat == XRef_Material and  classof 	mat.overrideMaterial == Multimaterial collect mat
			
			
			
			for mat_Xref in mat_xref_multi do (
				
-- 				if mat_Xref != undefined and classof mat_Xref == XRef_Material  then (
					local mat_origine  = mat_Xref.overrideMaterial	
					case classof  mat_origine of (
						Multimaterial:		(
							
							-- on cherche les objets de la scene portant le meme materiau	----------
							local objs_mm_multiMat	=	for obj in _nds where  obj.material == mat_Xref collect obj
			
							local nv_multiMat = Multimaterial 	numsubs:mat_origine.numsubs
							
							for i = 1 to   mat_origine.materialList.count do (
								
								local submat = mat_origine.materialList[i]
								local trouve = false
								for  j = 1 to echantillons_nds.count  do (
									local echantillon_mat = echantillons_nds[j].material
									if submat.name == echantillon_mat.map1.name do  (
										nv_multiMat[i]	=	echantillon_mat
										trouve = true
									)
								)
								
								if not trouve do
									nv_multiMat[i]	 = mat_origine[i]
								
							)
							
-- 							obj.material = nv_multiMat
							
							--- on applique le materiaux aux objets	----------
							for obj in objs_mm_multiMat do
								obj.material = nv_multiMat
							
						)
						Blend:			(
	-- 											creer_echantillon_materiau 		mat.map1
	-- 											creer_echantillon_materiau 		mat.map2
						)
						DoubleSided:	(
	-- 											creer_echantillon_materiau 		mat.material1
	-- 											creer_echantillon_materiau 		mat.material2
						)
						default:			()	--	obj.material = appliquer_decoupe		mat_Xref
					)
				) 
			
			
			
			
			
			
		),
	
		
		
		----------------  la scene d'origne	--------------------------------------
		fn 	preparer_sceneACouper	=(
			
			
			-------------- On s'occupe des infos necessaires ----------------------------------------
			---- les infos de la scene à couper	-------------
			sceneACouper_nds_noms		=		getMAXFileObjectNames 	sceneACouper_fichier
			
			--- on reset la scene -----------------------------------------------------
			resetMaxFile	#noPrompt
			
			--- on import les Xrefs objects	-------------------------------------
			xrefs.addNewXRefObject 	sceneACouper_fichier	sceneACouper_nds_noms		 dupMtlNameAction:#prompt
			
			---- les infos de la découpe	-------------
			decoupe_nds						=		geometry as array
			
		
		),
		
		
		
		fn 	preparer_noeudsADecouper	=	(
			--- si besoin on reference tout pour garder la partie coupé en invisible au rendu (mais projetant des ombres --------
			
			---- on applique à chaque objet un edit_poly et on coupe la partie en trop -------------------
			for obj in geometry do (
				local mod_decoupe	=	edit_poly ()
				addmodifier	 obj	mod_decoupe
			)
			
			
			
		),
		
		
		
		
	------------ INTERFACE	-------------------------------------------------------------------------------------------------------------------------
	public
		fn 	couper	=(
			
			---- les echantillons des materieux --------------
			---- a sauvegarde ailleurs que dans le fichier d'origne !!! -------------
			
			debug " PAR LA # 1"
			preparer_echantillons  ()
			
			debug " PAR LA # 2"
			sceneACouper_fichier			=		maxFilePath + ( getFilenameFile   maxFileName ) + " - DEBUG.max"	
			
			debug " PAR LA # 3"
			----	/!\		on sauvegarde	(pour avoir les echantiomllons)	/!\		----------------
			saveMaxFile 	sceneACouper_fichier
			
			debug " PAR LA # 4"
-- 			-------------- On bascule dans la scene de découpe	 ----------------------------------------
			preparer_sceneACouper ()
			
			debug " PAR LA # 5"
			--- DEBUG pour y voir quelque chose dans la scene -----------
			renderpresets.LoadAll	0 	"C:\\Users\\kris\\Documents\\3dsMax\\renderpresets\\caf.rps"
			max zoomext sel
			--- DEBUG pour y voir quelque chose dans la scene -----------
			
			
			debug " PAR LA # 6"
			
			---- on prepare les noeuds à decoupr	--------------
			
			debug "preparer_sceneACouper"
			
			--- creation du double pour occultation par decoupés ------------------
			local nds_sources = for obj in geometry where obj != sectionneur_nd collect obj
			for nd_src in nds_sources do (
				if nd_src.renderable and not nd_src.isNodeHidden  do (
					local  nd_dest 				= instance	nd_src
					nd_dest.renderByLayer  	= false
					nd_dest.primaryVisibility 	= false
				)
			)
			
			debug " PAR LA # 7"
			preparer_sectionneur ()
			
			debug " PAR LA # 8"
			preparer_materiaux_decoupes 		nds_sources
			
			debug " PAR LA # 9"
		)
	
)
 */






















/*
-------------------------------  XREF	--------------------------------
show objXRefMgr 
xrefs.addNewXRefObject "C:\\Users\\kris\\Documents\\3dsMax\\scenes\\boolean - distance map.max"

maxfilename
"boolean - distance map.max"
sceneName = maxFilePath + maxFileName



------------- MATERIAUX -----------------------------------------------------------------
Xrefmat = $.material
coromat = Xrefmat.overrideMaterial


------- xref mat ------------------------
XRef_Material
enableOverride
overrideMaterial 
srcFileName
srcItemName : string
xrefRecord : Interface
unresolved : bool
nested : bool
retargetable


------- opacité ------------------
CoronaMtl
texmapOpacity
colorOpacity
levelOpacity
texmapOnOpacity
mapamountOpacity
legacyColoredOpacity
opacityCutout



------ distance map ---------------
CoronaDistance
nodes
colorNear
colorFar
colorInside
distanceNear
distanceFar





 MAT CORONA ---
   .colorDiffuse : RGB color
  .colorReflect (colorReflection) : RGB color
  .colorRefract (colorRefraction) : RGB color
  .colorOpacity : RGB color
  .colorTranslucency : RGB color
  .colorSelfIllum (colorSelfIllumination) : RGB color
  .levelDiffuse : float
  .levelReflect : float
  .levelRefract : float
  .levelOpacity : float
  .levelTranslucency : float
  .levelSelfIllum (multiplierSelfIllumination) : float
  .texmapDiffuse : texturemap
  .texmapReflect : texturemap
  .texmapReflectGlossiness : texturemap
  .texmapRefract : texturemap
  .texmapRefractGlossiness : texturemap
  .texmapOpacity : texturemap
  .texmapBump : texturemap
  .texmapTranslucency : texturemap
  .texmapReflectAnisotropy : texturemap
  .texmapReflectAnisotropyRotation : texturemap
  .texmapIor : texturemap
  .texmapFresnelIor : texturemap
  .texmapDisplace (texmapDisplacement) : texturemap
  .texmapReflectBgOverride : texturemap
  .texmapRefractBgOverride : texturemap
  .texmapSelfIllum (texmapSelfIllumination) : texturemap
  .texmapOnDiffuse : boolean
  .texmapOnReflect : boolean
  .texmapOnRefract : boolean
  .texmapOnReflectGlossiness : boolean
  .texmapOnRefractGlossiness : boolean
  .texmapOnOpacity : boolean
  .texmapOnBump : boolean
  .texmapOnTranslucency : boolean
  .texmapOnAnisotropy (texmapOnReflectAnisotropy) : boolean
  .texmapOnAnisotropyRotation (texmapOnReflectAnisotropyRotation) : boolean
  .texmapOnIor : boolean
  .texmapOnFresnelIor : boolean
  .texmapOnDisplacement : boolean
  .texmapOnReflectBgOverride : boolean
  .texmapOnRefractBgOverride : boolean
  .texmapOnSelfIllum (texmapOnSelfIllumination) : boolean
  .mapamountDiffuse : float
  .mapamountReflect : float
  .mapamountRefract : float
  .mapamountReflectGlossiness : float
  .mapamountRefractGlossiness : float
  .mapamountOpacity : float
  .mapamountBump : float
  .mapamountTranslucency : float
  .mapamountAnisotropy (mapamountReflectAnisotropy) : float
  .mapamountAnisotropyRotation (mapamountReflectAnisotropyRotation) : float
  .mapamountIor : float
  .mapamountFresnelIor : float
  .mapamountSelfIllum (mapamountSelfIllumination) : float
  .reflectGlossiness : float
  .refractGlossiness : float
  .fresnelIor : float
  .ior : float
  .absorptionDistance (absorptionDistnace) : worldUnits
  .absorptionColor : RGB color
  .bsdf : integer
  .anisotropy (reflectAnisotropy) : float
  .anisotropyRotation (reflectAnisotropyRotation) : float
  .alphaMode (alphaChannel) : integer
  .gBufferOverride (gBufferIdOverride) : integer
  .displacementMinimum (displacementMinLevel) : worldUnits
  .displacementWaterLevel : float
  .displacementMaximum (displacementMaxLevel) : worldUnits
  .thin (thinNoRefraction) : boolean
  .caustics : boolean
  .texmapTranslucencyFraction : texturemap
  .texmapOnTranslucencyFraction : boolean
  .mapamountTranslucencyFraction : float
  .scatterColor (scatteringColor) : RGB color
  .scatterDirectionality (scatteringDirectionality) : float
  .mapamountAbsorption : float
  .texmapOnAbsorption : boolean
  .texmapAbsorption : texturemap
  .mapamountScatterColor (mapamountScatteringColor) : float
  .texmapOnScatterColor (texmapOnScatteringAlbedo) : boolean
  .texmapScatterColor (texmapScatteringAlbedo) : texturemap
  .visibleInMasks : boolean
  .singleBounceOnly (volumetricSingleBounceOnly) : boolean
  .displacementWaterLevelOn : boolean
  .legacyBrdfNormalization : boolean
  .legacyMode : boolean
  .legacyColoredOpacity : boolean
  .anisotropyOrientationMode : integer
  .anisotropyOrientationUvwChannel : integer
  .pbrMode : boolean
  .opacityCutout (Opacity_cutout_mode) : boolean
  .refractDispersionEnable (enableDispersion) : boolean
  .refractDispersion (dispersion) : float
  .levelSss : float
  .sssScatterColor : RGB color
  .sssRadius : worldUnits
  .texmapOnSssAmount : boolean
  .texmapOnSssRadius : boolean
  .texmapSssAmount : texturemap
  .texmapSssRadius : texturemap
  .mapamountSssAmount : float
  .mapamountSssRadius : float
  .texmapOnSssScatterColor : boolean
  .texmapSssScatterColor : texturemap
  .mapamountSssScatterColor : float
  .materialLibraryId : string
  .mediaMode (Media_scattering_mode) : integer
*/



-- show (XRef_Material())










/*



	-------- depuis le fichier que l'on veut couper :  ------------------------------------------------
	* on a besoin de connaitre (Utilisateur) :
		* 	les objets que l'on veut couper 							----> decoupe_nds )
		* 	la hauteur ou l'on veut couper 								----> ( decoupe_ht )
		* 	la couleur de l'endroit coupé								----> ( decoupe_couleur )
	
	* 	on liste tout les objets de la scene.							----> ( nds_scene )
	* 	on check la sauvegarde du fichier en cour.
	*	on creer un nouveau fichier vide.


	-------- depuis le nouveau fichier ---------------------------------------------------------------
	*	on importe en xref-object tout les objects de la scene.	 <---- ( nds_scene )

	-------- la boite de découpe --------------
	*	on prend la BB de la scene										----> ( BB_scene )
	*	on creer la boite un peu plus grande que ( BB_scene )
	*	on creer le materiau de la boite coupeuse :
			*	creation de la Distance Map : couleurs, objets ( decoupe_nds ), ...


*/







