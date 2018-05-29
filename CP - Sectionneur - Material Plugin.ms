
plugin material sectionneur_material
name:"Sectionneur"
classID:#(213452,482753)
extends:CoronaRaySwitchMtl	 
replaceUI:true 	
invisible:true
version:1
(
	

/* 	
.giMtl (globalIlluminationMtl) : material
.reflectMtl (reflectionMtl) : material
.refractMtl (refractionMtl) : material
.directMtl (directlyVisibleMtl) : material
.displacementSource (displacementFrom) : integer
.viewportSource (Material_shown_in_the_viewport) : integer
*/
	local blendMat
	
	parameters main rollout:params	(
		'Base material'		type:#material 						ui:btn_baseMat
		shadows				type:#boolean			default:true 						ui:chk_shadows
		
		on 'Base material'	 set _mat do (
-- 			delegate.directMtl 			= _mat
			delegate.reflectMtl 			= _mat
			delegate.refractMtl 			= _mat
			delegate.directMtl.map1 	= _mat
			if blendMat == undefined do 	blendMat = Sectionneur.get_blendMat ()
			
			if shadows then
				delegate.giMtl	=	_mat
			else
				delegate.giMtl	=	blendMat
		)
		on shadows set state do (
			if shadows then
				delegate.giMtl	=	delegate.reflectMtl 
			else
				delegate.giMtl	=	blendMat
		)
	)
	rollout params "Sectionneur Parameters" width:309 height:207
	(
		materialButton 'btn_baseMat' "None" pos:[97,5] width:202 height:16 align:#left
		label 'lbl_baseMat' "Base material:" pos:[21,6] width:72 height:14 align:#left
		checkbox 'chk_shadows' "Cast shadows" pos:[19,21] width:88 height:14 align:#left
	)
	
	
	------------- Interface ----------------------------	
	on create do	(
		blendMat 					= Sectionneur.get_blendMat ()
		delegate.directMtl		=	blendMat
	)
	
	
)


plugin material Sectionneur_undefined_mat
name:"Sectionneur undefined"
classID:#(104544,520566)
extends:CoronaMtl	 
replaceUI:true 	
invisible:true
version:1
(
	parameters main rollout:params	(
		color			type:#color 		
		on color	 set _col do (
			delegate.colorDiffuse 				= _col
		)
	)
	rollout params "Sectionneur Parameters" width:309 height:207
	(
	)	
)



/* 
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
 */
-- testMat 		= sectionneur_material ()
-- $.material 	= testMat

-- test.set_baseMat  $.material





















