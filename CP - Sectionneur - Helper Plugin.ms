plugin Helper Sectionneur_helper
name:"Sectionneur"
classID:#(5038941, 155178)
category:"Standard"
extends:dummy
invisible:true
replaceUI:true
(
		local lastSize, meshObj
		parameters pblock rollout:params
		(
			nds_aCouper		type:#nodeTab 		tabSize:0  		tabSizeVariable:true
			nds_sections		type:#nodeTab 		tabSize:0  		tabSizeVariable:true
			actif					type:#boolean			default:false
			touteLaScene 		type:#boolean			default:true
		)
		rollout params "HelperTest Parameters" width:162 height:32
		(
			button 'btn_edition' "Editer" pos:[59,7] width:44 height:21 align:#left
			on btn_edition pressed  do
				Sectionneur.ouvrir ()
		)
	
	
		fn get_ndsAcouper  		= for nd in nds_aCouper collect nd
		fn get_ndsSections  	= for nd in nds_sections collect nd
		
		fn set_ndsAcouper  	_nds	= nds_aCouper = for nd in _nds collect nd
		fn set_ndsSections  _nds	= nds_sections = for nd in _nds collect nd
		
		fn set_actif	_val	= actif = _val
		fn get_actif			= actif
		
		fn set_touteLaScene	_val	= touteLaScene = _val
		fn get_touteLaScene			= touteLaScene
		
		tool create
		(
			on mousePoint click do
			(
				nodeTM.translation = gridPoint;#stop
			)
		)
	
)













