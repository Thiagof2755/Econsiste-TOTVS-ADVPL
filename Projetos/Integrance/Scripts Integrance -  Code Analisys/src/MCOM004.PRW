#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FILEIO.CH"

#DEFINE cModel   'MODELMVC'
#DEFINE cMaster  'MASTER'
#DEFINE cCadastro 'AtualiZação dos Produtos' 
#DEFINE cMDesc    'Dados do Produto' 
#DEFINE cMAlias   'SB1'
#DEFINE aMPKey     LoadPrimary() 

/**************************************************************************************************
{Protheus.doc} STFIN001
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
user function MCOM004()

	local _nVarLen 		:= SetVarNameLen( 100 )
    local oBrowse       := BrowseDef()

	SetVarNameLen( _nVarLen )

return fwFreeObj( oBrowse )	
/**************************************************************************************************
{Protheus.doc} BrowseDef
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
static function BrowseDef()

	local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias( cMAlias )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetMenuDef( 'MCOM004' )
	oBrowse:Activate()
	
return oBrowse
/**************************************************************************************************
{Protheus.doc} MenuDef
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
static function MenuDef()
	
	local aRotina := {}

	Add Option aRotina Title 'Visualizar' 	                Action 'VIEWDEF.MCOM004'  	Operation MODEL_OPERATION_VIEW 		Access 0
	Add Option aRotina Title 'Incluir'                      Action 'VIEWDEF.MCOM004' 	Operation MODEL_OPERATION_INSERT 	Access 0
    Add Option aRotina Title 'Alterar'                      Action 'VIEWDEF.MCOM004' 	Operation MODEL_OPERATION_UPDATE 	Access 0

return aRotina
/**************************************************************************************************
{Protheus.doc} ModelDef
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
static function ModelDef()

	local oMaster   := FWFormStruct( 1 , cMAlias ) 
	local oModel    := MPFormModel():New( cModel ) 

	//-------------------------------+
    // Master         			     |
    //-------------------------------+
	oModel:AddFields( cMaster , /*cOwner*/, oMaster )
	oModel:GetModel( cMaster ):SetDescription( cMDesc )  
	oModel:SetPrimaryKey( aMPKey )
	
return oModel
/**************************************************************************************************
{Protheus.doc} ViewDef
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
static function ViewDef()

	local oMaster	:= FWFormStruct( 2 , cMAlias )
	local oView		:= FWFormView():New()	
    local cTop      := 'SUPERIOR'

	oView:SetModel( FWLoadModel( 'MCOM004' ) )
	
	oView:CreateHorizontalBox( cTop     , 100 )

    //Master
	oView:AddField( 		cMaster , oMaster , cMaster	)
	oView:SetOwnerView( 	cMaster , cTop 			    )
	oView:EnableTitleView( 	cMaster , cMDesc            )
	oView:SetCloseOnOk( { || .T. } )
	oView:SetProgressBar(.T.)

return oView
/**************************************************************************************************
{Protheus.doc} LoadPrimary
@description	Rotina para lançamento das antecipacao dos abatimentos da comissão
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		17/04/2023
**************************************************************************************************/
static function LoadPrimary()
    local aRet := { 'B1_FILIAL', 'B1_COD' }
return aRet
