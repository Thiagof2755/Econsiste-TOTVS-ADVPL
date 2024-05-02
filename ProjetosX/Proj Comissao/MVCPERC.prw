#include "TOTVS.CH"
#include "FWMVCDEF.CH"


/* Font para o Protheus para um Comissionamento Escalonado
 */

/*/{Protheus.doc} MVCPERC
********************MVCSZ9MODELO3************************

/*/
User Function MVCPERC()
	Local aArea := GetArea()
	Local oBrowse
	oBrowse:= FwmBrowse():New()
	oBrowse:SetAlias("SZ9")
	oBrowse:SetDescription("Cadastro de Comissão")
	oBrowse:Activate()
	RestArea(aArea)

Return

/*/{Protheus.doc} ModelDef
********************MVCSZ9MODELO3************************
/*/
Static Function ModelDef()
	Local oModel :=  Nil
	Local bLinePos := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| fValGridCB8(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}


	Local oStPaiZ9 := FWFormStruct(1,"SZ9") //Cria uma estrutura para o cabeçalho
	Local oStFilhoZ8 := FWFormStruct(1,"SZ8") //Cria uma estrutura para o grid

	oStFilhoZ8:SetProperty('Z8_CFIM',  MODEL_FIELD_VALID,  FWBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(MVCPERC,fValVlr)") )                                         //Campo Obrigatório


	oModel := MPFormModel():New("MVCPERCC",,,,) /* MPFORMMODEL():New(< cID >, < bPre >, < bPost >, < bCommit >, < bCancel >)-> NIL */
	oStFilhoZ8:SetProperty("Z8_CODVEN",MODEL_FIELD_OBRIGAT,.F.) //Define o campo como NÃO obrigatório
	oModel:AddFields("SZ9MASTER",,oStPaiZ9) //Adiciona o cabeçalho
	oModel:AddGrid("SZ8DETAL","SZ9MASTER",oStFilhoZ8,  ,bLinePos) //Adiciona o grid
	oModel:SetRelation("SZ8DETAL", {{"Z8_FILIAL", "FwXFilial('SZ9')"}, {"Z8_CODVEN", "Z9_CODVEN"}})//Relaciona o grid com o cabeçalho
	oModel:SetPrimaryKey({"Z8_FILIAL","Z8_CODVEN","Z8_PERC"})//Chave primária
	oModel:GetModel("SZ8DETAL"):SetUniqueLine({"Z8_PERC"})//Combinação de campos que nao podem se repetir
	oModel:SetDescription("Comissao") //Atribuindo a descrição ao modelo de dados
	oModel:GetModel("SZ8DETAL"):SetDescription("Itens") //Atribuindo a descrição ao modelo de dados
	oModel:GetModel("SZ9MASTER"):SetDescription("Cabecalho") //Atribuindo a descrição ao modelo de dados

Return oModel

/*/{Protheus.doc} ViewDef
********************MVCSZ9MODELO3************************
/*/
Static Function ViewDef()

	Local oView := Nil
	Local oModel := FWLoadModel("MVCPERC")
	Local oStPaiZ9 := FWFormStruct(2,"SZ9")
	Local oStFilhoZ8 := FWFormStruct(2,"SZ8")
	oStFilhoZ8:RemoveField("Z8_CODVEN")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewZ3",oStPaiZ9,"SZ9MASTER")
	oView:AddGrid("ViewZ4",oStFilhoZ8,"SZ8DETAL")
	// Criando os Box
	oView:CreateHorizontalBox("CABEC",30)
	oView:CreateHorizontalBox("GRID",70)
	oView:SetCloseOnOk({||.T.})//Fecha a tela ao clicar no botão OK
	//Amarro os campos ao Box
	oView:SetOwnerView("ViewZ3","CABEC")//Cabeçalho
	oView:SetOwnerView("ViewZ4","GRID")//Grid
	oView:EnableTitleView("ViewZ3","Vendedor")//Cabeçalho
	oView:EnableTitleView("ViewZ4","Percentual")//Grid

Return  oView

/*/{Protheus.doc} MenuDef
********************MenuDef************************
/*/
Static Function MenuDef()
	local aRotina     := FWMVCMenu("MVCPERC")
Return aRotina

/*/{Protheus.doc} VldVen
********************VldVen************************
/*/
User Function VldVen(CodVenD)

	local cAlias := GetNextAlias()

	Local lRet := .T.

	BeginSql Alias cAlias // mesmo intervalo de tempo
        SELECT Z9_CODVEN   FROM %table:SZ9% 
                WHERE Z9_CODVEN = %exp:CodVenD%
				AND %notDel%
	EndSql

	While (cAlias)->(! Eof())
		IF (cAlias)->(Z9_CODVEN) == CodVenD
			MsgInfo("Vendedor ja possui Regra de Comissão. Verifique!")
			Return .T.
		ENDIF
		(cAlias)->(DbSkip())
	EndDo

Return  lRet

/*/{Protheus.doc} VldDT
********************VldDT************************
/*/
User Function VldDT(INI , FIM) // VALIDA DATA INICIAL E FINAL

	Local lRet := .T.

	IF !EMPTY(FIM) .AND. INI > FIM

		MsgInfo(" Inicial maior que Final. Verifique!")
		lRet := .F.
	ENDIF
	IF lRet .and. INI == FIM
		MsgInfo(" Inicial igual a Final. Verifique!")
		lRet := .F.
	ENDIF
Return lRet

/*/{Protheus.doc} VldEdT
********************VldEdT************************
/*/
User Function VldEdT(INI) // mes e ano inicial menor que o atual  porem acesso adm pode

	Local lRet := .T.

	Local xConteud := GetNewPar("MV_X_ADM",,)

	Local aArea     := FWGetArea()
	Local dData
	//Busca a data de hoje
	dData := Date()

	IF INI < dData .AND. !EMPTY(INI)  //mes e ano inicial menor que o atual
		lRet := .F.
		MsgStop("Mes e ano inicial menor que o atual. Verifique Com Administrador!")
	ENDIF
	//verifica se o acesso e administrador
	IF __cUserId $ xConteud
		lRet := .T.
	ENDIF
	FWRestArea(aArea)
Return lRet


/*/{Protheus.doc} VldPos
********************VldPos************************
/*/
User Function VldPos(CodVenD, INI, FIM) // VALIDAÇÕES POSITIVAS PARA NA PERMITIR OUTRO CADASTRO NO INTERAVALO DE TEMPO
	Local lRet := .T.
	Local cAlias := GetNextAlias()
	// Local oModel 		:= FWModelActive()
	LOCAL nRecSZ9 := SZ9->(RECNO())

	IF !Altera
		nRecSZ9 := 0
	ENDIF

		BeginSql Alias cAlias
			SELECT Z9_CODVEN FROM %table:SZ9% 
			WHERE Z9_CODVEN = %exp:CodVenD% 
			AND %notDel% 
			AND R_E_C_N_O_ != %exp:nRecSZ9%
				AND ((%exp:INI% BETWEEN Z9_DTINI AND Z9_DTFIM)
				OR  (%exp:FIM% BETWEEN Z9_DTINI AND Z9_DTFIM))

		EndSql

		If !Empty((cAlias)->(Z9_CODVEN))
			MsgInfo("Já existe um cadastro para este vendedor no intervalo de tempo especificado.")
			lRet := .F.
		EndIf
	

Return  lRet


/*/{Protheus.doc} fValGridCB8
Função de pre-validação da edição de linha CB8Detail
/*/
Static Function fValGridCB8(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet := .T.

	Local nI := 0
	Local nLinAtu := oGridModel:nLine

	IF !oGridModel:IsDeleted()
		nVlrIniAtual := oGridModel:GetValue("Z8_CINI")

		for nI := 1 to oGridModel:Length()
			if nI < nLinAtu
				oGridModel:GoLine(nI)
				if !oGridModel:IsDeleted()
					if nVlrIniAtual <= oGridModel:GetValue("Z8_CFIM")
						MsgStop("Valor informado na Faixa Inicial ("+cValtoChar(nVlrIniAtual)+") é menor que o valor final ("+cValtoChar(oGridModel:GetValue("Z8_CFIM"))+") da linha ";
							+cValtoChar(nI)+". Verifique!")
						lRet := .F.
						exit
					endif

				endif
			ENDIF
		Next
		oGridModel:GoLine(nLinAtu)
	ENDIF


Return lRet

/*/{Protheus.doc} Calculo
Função de pre-validação da edição de linha CB8Detail

/*/
static function Calculo( oModel, nTotalAtual, xValor, lSomando )
	local nRet := 0
	Local oModelGrid	:= oModel:GetModel("SZHDETAIL")
	Local nI := 0
	Local nLinAtu := oModelGrid:nLine
	if lSomando
		for nI := 1 to oModelGrid:Length()
			oModelGrid:GoLine(nI)
			if !oModelGrid:IsDeleted() .and. oModelGrid:GetValue("ZH_AGREGA")
				nRet += oModelGrid:GetValue("ZH_QUANT")
			endif
		Next
		oModelGrid:GoLine(nLinAtu)
	else
		nRet := nTotalAtual
	endif

Return  nRet


/*/{Protheus.doc} fValVlr
Função de validação da edição de linha CB8Detail
/*/
Static Function fValVlr()
	local lRet := .t.
	Local oModel 		:= FWModelActive()
	Local oModelGrid := oModel:GetModel('SZ8DETAL')
	Local nVlrIni := oModelGrid:GetValue('Z8_CINI')
	Local nVlrFim := oModelGrid:GetValue('Z8_CFIM')

	lRet := u_VldDT(nVlrIni , nVlrFim)

return lRet
