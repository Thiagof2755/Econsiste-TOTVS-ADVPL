#Include "Totvs.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} User Function CRMA980
Novo cadastro de Clientes
/*/

User Function CRMA980()
	Local aArea         := FWGetArea()
	Local aParam        := PARAMIXB
	Local xRet          := .T.
	Local oObj          := Nil
	Local cIdPonto      := ""
	Local cIdModel      := ""


	// Se tiver parametros
	If aParam != Nil

		// Pega informacoes dos parametros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto == "MODELVLDACTIVE" // Na ativação do modelo
			MsgAlert("MODELVLDACTIVE")
			ModelDef(oObj)
			xRet := .T.
		EndIf

		If cIdPonto == 'MODELPRE' //Antes da alteração de qualquer campo do modelo
			MsgAlert( "MODELPRE" )
			ViewDef()
			xRet	:= .T.
		EndIf


	EndIf

	FWRestArea(aArea)
Return xRet


Static Function ModelDef(oModel)
	Local oStructAC8    := FWFormStruct(1,"AC8",/*bAvalCampo*/,/*lViewUsado*/)

	oModel:AddFields("AC8FOLD","SA1MASTER",oStructAC8,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:SetRelation("AC8FOLD",{{"AC8_FILIAL", "xFilial('AC8')"},{"AC8_FILENT", "xFilial('SA1')"},{"AC8_ENTIDA","SA1"},{"AC8_CODENT","A1_COD+A1_LOJA"}},AC8->( IndexKey( 1 ) ))

return



Static Function ViewDef()

	Local oView		 := FwViewActive()
	Local oStructAC8 := FWFormStruct(2,"AC8",/*bAvalCampo*/,/*lViewUsado*/)

	if ValType(oView) == "O"
		if ascan(oView:aViews,{|x| x[1] == "VIEW_CTO"}) <= 0


			oView:AddField("VIEW_CTO",oStructAC8,"CTOCHILD")

			oView:AddSheet("FOLDER","SHEETCTO","Contatos")

			oView:CreateHorizontalBox("BOXFORMCTO",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETCTO")

			oView:SetOwnerView("VIEW_CTO","BOXFORMCTO")
            
		endif

	endif

return
