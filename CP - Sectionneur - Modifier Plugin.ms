plugin modifier sectionneur_modifier
name:"Sectionneur"
classID:#(685325,452281)
extends:edit_poly 
replaceUI:true 
invisible:true
version:1
(
	parameters main rollout:params
	(
		
	)
	rollout params "Sectionneur Parameters" width:162 height:29
	(
	------------  UI	----------------------------------------------------------------------------------		
		checkbutton 'btn_appliquer' "Activer coupe" pos:[48,4] width:106 height:20 align:#left
	
		button 'btn_editeur' "Editeur" pos:[5,4] width:44 height:20 align:#left
	)
)




















