
plugin material sectionneur_material
name:"Sectionneur"
classID:#(645137,457691)
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





















