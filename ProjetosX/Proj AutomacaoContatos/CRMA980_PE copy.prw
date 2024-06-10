#Include "Totvs.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980_PE
Fonte Para Automatizar o processo de cadastro de clientes
com seus contatos
@author Thiago Alves
@since 29/09/2024

	######## ##     ## ####    ###     ######    #######
		##    ##     ##  ##    ## ##   ##    ##  ##     ##
		##    ##     ##  ##   ##   ##  ##        ##     ##
		##    #########  ##  ##     ## ##   #### ##     ##
		##    ##     ##  ##  ######### ##    ##  ##     ##
		##    ##     ##  ##  ##     ## ##    ##  ##     ##
		##    ##     ## #### ##     ##  ######    #######

/*/
//-------------------------------------------------------------------

User Function CRMA980_PE()

	Local aArea := GetArea()
	Local oBrowse
	oBrowse:= FwmBrowse():New()
	oBrowse:SetAlias("SA1")
	oBrowse:SetDescription("Cadastro de Cientes")
	oBrowse:Activate()
	RestArea(aArea)

return

Static Function ModelDef()

	Local oModel := FWLoadModel("CRMA980")

    Local oStructAC8    := FWFormStruct(1,"AC8",/*bAvalCampo*/,/*lViewUsado*/)
	oModel:AddFields("AC8FOLD","SA1MASTER",oStructAC8,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:SetRelation("AC8FOLD",{{"AC8_FILIAL", "xFilial('AC8')"},{"AC8_FILENT", "xFilial('SA1')"},{"AC8_ENTIDA","SA1"},{"AC8_CODENT","A1_COD+A1_LOJA"}},AC8->( IndexKey( 1 ) ))

Return oModel





Static Function ViewDef()

	Local oView		:= Nil
	Local oModel		:= ModelDef()	 
	Local oStructSA1	:= FWFormStruct(2,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(2,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAC8    := FWFormStruct(2,"AC8",/*bAvalCampo*/,/*lViewUsado*/)

	
	oView:= FWFormView():New()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox("BOXFORMALL",100)
	oView:CreateFolder("FOLDER","BOXFORMALL")
	oView:AddSheet("FOLDER","SHEETSA1","Principal")
	oView:AddSheet("FOLDER","SHEETAI0","Informações Complementares")
	oView:AddSheet("FOLDER","SHEETCTO","Contatos")
	
	oView:CreateHorizontalBox("BOXFORMSA1",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETSA1")
	oView:CreateHorizontalBox("BOXFORMAI0",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETAI0")
	oView:CreateHorizontalBox("BOXFORMCTO",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETCTO")
	
	oView:AddField("VIEW_SA1",oStructSA1,"SA1MASTER")
	oView:SetOwnerView("VIEW_SA1","BOXFORMSA1")
	
	oView:AddField("VIEW_AI0",oStructAI0,"AI0CHILD")
	oView:SetOwnerView("VIEW_AI0","BOXFORMAI0")

	oView:AddField("VIEW_CTO",oStructAC8,"AC8FOLD") 
	oView:SetOwnerView("VIEW_CTO","BOXFORMCTO")
	

Return oView












Static Function MenuDef()
	local aRotina     := FWMVCMenu("CRMA980_PE")


Return aRotina





static function getViewStruct()
Local oStruct := FWFormViewStruct():New()

return oStruct


static function getModelStruct()
Local oStruct := FWFormModelStruct():New()
	
return oStruct



