



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_sectionneurTools "sectionneurTools" width:522 height:232
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
	fn redimensionner		=(
		if rdo_applyTo.state  == 1 then
			roll_sectionneurTools.width = 175
		else 
			roll_sectionneurTools.width = 522
	)
	fn actualiser = (
		
		lbx_sections.items		= 	for section in m_prt.get_sections() collect section.name
		chk_ombres.checked 	= 	m_prt.get_ombresUse ()
		rdo_applyTo.state 		=	m_prt.get_mode ()
		btn_appliquer.checked 	= 	m_prt.est_actif ()
		
	)
	
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		redimensionner ()
		
		actualiser ()
		
	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------

	
	
	on btn_section_nvNode picked obj do	(
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
				m_prt.set_ombresUse	 state
	on rdo_applyTo changed state do	(
				m_prt.set_mode	 state
				redimensionner ()
			)
	on btn_appliquer changed state do	(
			case state of (
				true:		m_prt.activer 		()
				false: 	m_prt.desactiver 	()
			)
		)
) ---- fin rollout -------------



struct 		str_sectionneur_tools (
			
	private
		
		---- Fenetre ----
		dialog			= roll_sectionneurTools ,		---- le rollout ----
		dialog_pos 		= [100,100],
		dialog_taille 	= [dialog.width, dialog.height ],
		
		---- calque temporarire pour les objets des ombres --------------
		calque_temp,
		calque_temp_nom	=	"000 - Section - Ombres -TEMP",
		
	
	public
		fn cleanner_import	_nodes	=(
			local compteur = 0
			progressStart "Clean import" 

			format "Clean import: %\n" geometry.count

			for obj in _nodes  where classof obj == Editable_mesh or   classof obj == Editable_Poly  or  classof obj == PolyMeshObject  do (
				format "clean: %\n" obj.name
				format "	classof obj : %\n" (classof obj )
				
			-- 	if   classof obj == Editable_mesh or  classof obj == PolyMeshObject  do	(
				
				
				convertToPoly obj
				local numVerts = polyop.getNumVerts obj
				if numVerts > 0 do (
					obj.weldThreshold = .1
					polyop.weldVertsByThreshold obj #{1..polyop.getNumVerts obj} 
					obj.autoSmoothThreshold 	=	12
					polyop.autoSmooth obj		
				)
				
				
				--- Progress bar ---------------------------
				compteur += 1
				progress_val 			= compteur  / geometry.count * 100
				progressUpdate 	progress_val

			)
			-- )


			progressend ()

		)
	
		
		---- fenetre ------------------------------------------------------------------------------
		fn ouvrir =(			
			createDialog dialog 	pos:					dialog_pos
			dialog.m_prt	 	= this
			dialog.initialiser ()
		),		
		fn fermer  =(	
			dialog_pos = getDialogPos dialog
			try destroydialog dialog catch ()
		)
		
)
