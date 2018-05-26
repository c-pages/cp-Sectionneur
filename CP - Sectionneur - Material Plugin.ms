/* rollout unnamedRollout "Untitled" width:162 height:260
(
	listbox 'lbx1' "" pos:[10,27] width:136 height:7 align:#left
	pickbutton 'btn1' "+" pos:[14,8] width:16 height:16 align:#left
	pickbutton 'btn2' "-" pos:[130,9] width:16 height:16 align:#left
	checkbox 'chk1' "Ombres" pos:[15,126] width:117 height:21 checked:true align:#left
	radiobuttons 'rdo1' "Apply to" pos:[19,157] width:54 height:46 labels:#("Scene", "list") align:#left
	button 'btn3' "Edit" pos:[73,188] width:81 height:14 align:#left
	button 'btn7' "Appliquer" pos:[24,216] width:124 height:25 align:#left
)

createdialog unnamedRollout
 */
plugin material sectionneur_material
name:"Sectionneur"
classID:#(415514,175374)
extends:Blend	 
replaceUI:true 	
version:1
(
	parameters main rollout:params	(
		'Base material'			type:#material 						ui:btn_baseMat
		
		on 'Base material'	 set _mat do
			delegate.map1 = _mat
	)
	rollout params "Sectionneur Parameters" width:309 height:207
	(
		materialButton 'btn_baseMat' "None" pos:[97,5] width:159 height:16 align:#left
		label 'lbl_baseMat' "Base material:" pos:[21,6] width:72 height:14 align:#left
	)
	
	
	------------- Interface ----------------------------	
	on create do	(
		delegate.map2		=	Sectionneur.invisMat
		delegate.mask		=	Sectionneur.distMap
	)
	
	
)

-- testMat 		= sectionneur_material ()
-- $.material 	= testMat

-- test.set_baseMat  $.material





















