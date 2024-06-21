#Include "Totvs.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFAT09
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

User Function STFAT09()



	Local aArea := GetArea()
	Local oBrowse
	oBrowse:= FwmBrowse():New()
	oBrowse:SetAlias("SA1")
	oBrowse:SetDescription("Cadastro de Cientes")
	oBrowse:Activate()
	RestArea(aArea)

return

Static Function ModelDef()
	Local oModel        := FWLoadModel("CRMA980")
	Local dLoad := {|oFieldModel, lCopy| loadField(oFieldModel, lCopy)}
	Local bLoad         := {|oGridModel, lCopy| loadGrid(oGridModel, lCopy)}
	Local oModelBkp     := FWLoadModel("CRMA980")
	local oStru         := GetModel()
	local oStruMST      := GetModelFields()

	oModel:BCOMMIT      := {|oModelBkp| fTeste(oModelBkp)}

	oModel:AddFields('SU5TOPRF', 'SA1MASTER', oStruMST, , ,dLoad)
	oModel:AddGrid('SU5CHILD', 'SA1MASTER', oStru, , , , , bLoad)
	oModel:SetDescription("Modelo 3 - Clientes X Contatos")
	oModel:GetModel("SU5CHILD"):SetDescription("Contatos")
	oModel:GetModel("SU5TOPRF"):SetDescription("Contato")
	oModel:GetModel("SU5CHILD"):SetOptional(.T.)
	oModel:GetModel("SU5CHILD"):SetUniqueLine({"U5_CELULAR"})
	oModel:GetModel("SU5CHILD"):SetUseOldGrid(.T.)

	oStru:SetProperty('U5_CODCONT', MODEL_FIELD_OBRIGAT, .F.)
	oStruMST:SetProperty('U5_CODCONT', MODEL_FIELD_OBRIGAT, .F.)
	oStruMST:SetProperty("U5_CARGO", MODEL_FIELD_OBRIGAT,.F.)
	oStruMST:SetProperty("U5_CONTAT", MODEL_FIELD_OBRIGAT,.F.)

Return oModel



Static Function ViewDef()


	Local oView		    := Nil
	Local oModel		:= ModelDef()
	Local oStructSA1	:= FWFormStruct(2,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(2,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	local oStru 		:= GetView()
	Local oStruMST 		:= GetView()


	oView:= FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox("BOXFORMALL",100)
	oView:CreateFolder("FOLDER","BOXFORMALL")
	oView:AddSheet("FOLDER","SHEETSA1","Principal")
	oView:AddSheet("FOLDER","SHEETAI0","Informaes Complementares")
	oView:AddSheet("FOLDER","SHEETCTO","Contatos")


	oView:CreateHorizontalBox("BOXFORMSA1",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETSA1")
	oView:CreateHorizontalBox("BOXFORMAI0",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETAI0")
	oView:CreateHorizontalBox("VIEW_TOP",40,/*cIdOwner*/,/*lFixPixel*/,   "FOLDER","SHEETCTO")
	oView:CreateHorizontalBox("VIEW_BTN",20,/*cIdOwner*/,/*lFixPixel*/,   "FOLDER","SHEETCTO")
	oView:CreateHorizontalBox("VIEW_DET",40,/*cIdOwner*/,/*lFixPixel*/,   "FOLDER","SHEETCTO")


	oView:AddField("VIEW_SA1",oStructSA1,"SA1MASTER")
	oView:SetOwnerView("VIEW_SA1","BOXFORMSA1")

	oView:AddField("VIEW_AI0",oStructAI0,"AI0CHILD")
	oView:SetOwnerView("VIEW_AI0","BOXFORMAI0")

	oView:AddGrid("VIEW_SU5",oStru,"SU5CHILD")
	oView:SetOwnerView("VIEW_SU5","VIEW_DET")

	oView:AddField("VIEW_U5MST",oStruMST,"SU5TOPRF")
	oView:SetOwnerView("VIEW_U5MST","VIEW_TOP")

	oView:AddOtherObject("VIEW_OTHER", {|oPanel| tBtn(oPanel)})
	oView:SetOwnerView('VIEW_OTHER' , 'VIEW_BTN')//View do Botão da Grid.

	oStruMST:SetProperty("U5_CODCONT", 	MVC_VIEW_CANCHANGE,.F.)
	oStruMST:SetProperty("U5_CELULAR", 	MVC_VIEW_CANCHANGE,.T.)
	oStruMST:SetProperty("U5_FONE",  	MVC_VIEW_CANCHANGE,.T.)
	oStruMST:SetProperty("U5_CELULAR",  MVC_VIEW_ORDEM,"02")
	oStruMST:SetProperty("U5_DDD",		MVC_VIEW_ORDEM,"01")
	oStru:SetProperty("U5_DDD", 		MVC_VIEW_CANCHANGE,.T.)
	oStruMST:SetProperty("U5_DDD",  	MVC_VIEW_CANCHANGE,.T.)
	oStru:SetProperty("U5_CODCONT", MVC_VIEW_CANCHANGE,.F.)
	oStru:SetProperty("U5_CELULAR", MVC_VIEW_CANCHANGE,.T.)
	oStru:SetProperty("U5_FONE",  	MVC_VIEW_CANCHANGE,.T.)
	oStru:SetProperty("U5_CELULAR", MVC_VIEW_ORDEM,"02")
	oStru:SetProperty("U5_DDD",  	MVC_VIEW_ORDEM,"01")
	oStru:SetProperty("U5_CONTAT", 	MVC_VIEW_ORDEM,"03")
	oStru:SetProperty("U5_CODCONT", MVC_VIEW_ORDEM,"11")
	oStru:SetProperty("U5_CARGO", 	MVC_VIEW_ORDEM,"04")
	oStruMST:removeField("U5_CODCONT")


Return oView


Static Function MenuDef()
	local aRotina     := FWMVCMenu("STFAT09")

Return aRotina


Static Function loadGrid(oGridModel, lCopy)

	Local aLoad := {}
	local cChave := padr("SA1",tamsx3("AC8_ENTIDA")[1])+xFilial("SA1")+Padr(SA1->(A1_COD+A1_LOJA),tamsx3("AC8_CODENT")[1])
	local nI := 0
	local aCols := Array(Len(oGridModel:aHeader))
	local cCampo

	dbselectarea("AC8")
	dbsetorder(2) //AC89902  = AC8_FILIAL, AC8_ENTIDA, AC8_FILENT, AC8_CODENT, AC8_CODCON, R_E_C_N_O_, D_E_L_E_T_
	dbseek(xFilial("AC8")+cChave)
	While AC8->(!EoF()) .and. AC8->(AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT) == xFilial("AC8")+cChave

		dbselectarea("SU5")
		dbsetorder(1)
		dbseek(xFilial("SU5")+AC8->AC8_CODCON)

		For nI := 1 to Len(oGridModel:aHeader)
			// aCols :=  Array(1, Len(oGridModel:aHeader))
			cCampo := oGridModel:aHeader[nI,2]
			if oGridModel:aHeader[nI,10] == "R"
				aCols[nI] := SU5->&cCampo
			else
				cComando := GetSx3Cache(cCampo,"X3_RELACAO")
				aCols[nI] := &cComando
			endif
		Next


		aAdd(aLoad,{0,aClone(aCols)})
		AC8->(dbskip())
	END

Return aLoad
Static Function loadField(oFieldModel, lCopy)
	Local oStruMST   := GetModel()
	Local aLoad      := Array(Len(oStruMST:GetFields()))
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStruMST:GetFields()
	nQtFields := Len(aFields)

	For nField := 1 To nQtFields
		cField := aFields[nField][3]
		cType  := aFields[nField][4]
		nLen   := aFields[nField][5]

		Do Case
		Case cType == "C"
			xValue := Space(nLen)
		Case cType == "N"
			xValue := 0
		Case cType == "L"
			xValue := .F.
		Case cType == "D"
			xValue := CToD("  /  /    ")
		Otherwise
			xValue := Nil
		End Case

		aLoad[nField] := xValue
	Next nField

Return aLoad





Static Function fTeste(oModelBkp)

	CommitPrincipal			:= FwFormCommit(oModelBkp)
	CommitSU5				:= SU5Register()
	CommitAC8				:= AC8Relation()

	if CommitPrincipal .AND. CommitSU5 .AND. CommitAC8 == .T.
		Return .T.
	else
		Return .F.
	endif

return

Static Function AC8Relation()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local oModelSA1     := oModel:GetModel('SA1MASTER')
	Local nI := 0
	local Cargo
	local Gerente
	local Comprador

	dbselectarea("SA1")

	for nI:= 1 to oModelGrid:Length()
		oModelGrid:GoLine(nI)
		Cargo := oModelGrid:GetValue("U5_CARGO")

		if Cargo == "05"
			Comprador := 1
		endif

		If Cargo == "01"
			Gerente := 1
		endif
	Next

	If Gerente == 1 .AND. Comprador == 1
		for nI:= 1 to oModelGrid:Length()
			oModelGrid:GoLine(nI)
			AC8->(dbsetorder(1))
			A1_COD := oModelSA1:GetValue("A1_COD")
			A1_LOJA := oModelSA1:GetValue("A1_LOJA")
			if !AC8->(dbseek(xFilial("AC8")+Padr(AllTrim(oModelGrid:GetValue("U5_CODCONT")),tamsx3("AC8_CODCON")[1])+"SA1"+xFilial("SA1")+Padr(AllTrim(A1_COD+A1_LOJA),tamsx3("AC8_CODENT")[1]) ))  //AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT	Contato + Entidade + Fil.Entidade + Cod.Entidade
			/* Cria novo registro  na tabela AC8*/
				Reclock("AC8",.T.)
				AC8->AC8_ENTIDA := "SA1"
				AC8->AC8_CODENT := Padr(AllTrim(A1_COD+A1_LOJA),tamsx3("AC8_CODENT")[1])
				AC8->AC8_CODCON := Padr(AllTrim(oModelGrid:GetValue("U5_CODCONT")),tamsx3("AC8_CODCON")[1])
				AC8->AC8_FILENT := xFilial("SA1")
				AC8->AC8_FILIAL := xFilial("AC8")
				AC8->(MSuNLOCK())
			/*---------------------------------*/


			elseif oModelGrid:IsDeleted()
			/* Deleta o registro da tabela AC8 se for excluído do grid*/
				Reclock("AC8",.F.)
				AC8->(dbdelete())
				AC8->(MSuNLOCK())
			/*-------------------------------------------------------*/
			endif
		next

	else
		MsgStop( "Necessario selecionar pelo menos um cargo de Gerente e Comprador")
		Return .F.
	endif
Return .T.


Static Function SU5Register()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local nI
	local cCampo
	Local x

	dbselectarea("SU5")
	for nI:= 1 to oModelGrid:Length()
		oModelGrid:GoLine(nI)
		SU5->(dbsetorder(1))
		if !SU5->(dbseek(xFilial("SU5")+oModelGrid:GetValue("U5_CODCONT")))//U5_FILIAL+U5_CODCONT
		/* Cria o registro com base nas informações do grid */
			Identificador := NEWNUMCONT()
			Reclock("SU5",.T.)
			SU5->U5_FILIAL := xFilial("SU5")

			For x := 1 To Len(oModelGrid:aHeader)

				cCampo := ALLTRIM(oModelGrid:aHeader[x][2])

				DO CASE
					CASE cCampo == "U5_CODCONT"
						SU5->U5_CODCONT := Identificador
					OTHERWISE
						SU5->&(cCampo) := oModelGrid:GetValue(cCampo)
				ENDCASE

			Next

			SU5->(MSuNLOCK())

			oModel:SetValue("SU5CHILD","U5_CODCONT",Identificador)
		/* -----------------------------------------------------*/
		Endif
		/* Atualiza o registro com base nas informações do grid */
		Reclock("SU5",.F.)

		For x := 1 To Len(oModelGrid:aHeader)

			cCampo := ALLTRIM(oModelGrid:aHeader[x][2])

			If cCampo == "U5_FILIAL"
				SU5->U5_FILIAL := (xFilial("SU5"))
			else
				SU5->&(cCampo) := oModelGrid:GetValue(cCampo)
			EndIf
		Next

		SU5->(MSuNLOCK())
		/* -----------------------------------------------------*/

	Next



Return .T.

Static Function GetModel()

	local oStru 		:= FwFormModelStruct():New()
	Local oStructSU5 	:= FWFormStruct(1,"SU5")
	Local aGatilhos 	:= {}
	Local nAtual
	Local nI

	// Adiciona um campo à estrutura
	For nI := 2 To Len(oStructSU5:AFIELDS)
		Virtual := oStructSU5:AFIELDS[nI][14]
		If  Virtual == .F.
			oStru:AddField(;
				oStructSU5:AFIELDS[nI][1],;  // cTitulo: Título do campo
			oStructSU5:AFIELDS[nI][2],;  // cTooltip: Tooltip do campo
			oStructSU5:AFIELDS[nI][3],;  // cIdField: ID do campo
			oStructSU5:AFIELDS[nI][4],;  // cTipo: Tipo do campo (Caracter)
			oStructSU5:AFIELDS[nI][5],;  // nTamanho: Tamanho do campo
			oStructSU5:AFIELDS[nI][6],; // nDecimal: Decimal do campo (0 por padrão)
			,;                           // bValid: Bloco de código de validação do campo
			,;                           // bWhen: Bloco de código de validação when do campo
			,;                           // aValues: Lista de valores permitidos para o campo
			oStructSU5:AFIELDS[nI][10],; // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
			,; // bInit: Bloco de código de inicialização do campo
			,;                           // lKey: Indica se é um campo chave (verdadeiro/falso)
			oStructSU5:AFIELDS[nI][13],; // lNoUpd: Indica se o campo não pode ser atualizado
			,;                           // lVirtual: Indica se o campo é virtual
			,;                           // cValid: Valid do usuário em formato texto
			)
		EndIf
	Next

	aAdd(aGatilhos, FWStruTriggger( ;
		"U5_CELULAR",;                               //Campo Origem
	"U5_CONTAT",;                               //Campo Destino
	"u_GAT()",;                                   //Regra de Preenchimento
	.F.,;                                       //Irá Posicionar?
	"",;                                        //Alias de Posicionamento
	0,;                                         //Índice de Posicionamento
	'',;                                        //Chave de Posicionamento
	NIL,;                    					//Condição para execução do gatilho
	"01");                                      //Sequência do gatilho
	)

	//Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStru:AddTrigger( ;
			aGatilhos[nAtual][01],; //Campo Origem
		aGatilhos[nAtual][02],; //Campo Destino
		aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
		aGatilhos[nAtual][04];  //Bloco de código de execução do gatilho
		)
	Next

return oStru


Static Function GetView()
	Local oStru := FWFormViewStruct():New()
	Local oStructSU5 := FWFormStruct(2, "SU5")
	Local nI
	Local aCamposPermitidos := {"U5_CARGO", "U5_CONTAT", "U5_CELULAR", "U5_FONE", "U5_EMAIL", "U5_NIVER", "U5_HOBBIE", "U5_ESPF", "U5_TIMFAV","U5_CODCONT","U5_DDD"}

	// Adiciona um campo à estrutura
	For nI := 1 To Len(oStructSU5:AFIELDS)
		Virtual := oStructSU5:AFIELDS[nI][16]
		nCampo := oStructSU5:AFIELDS[nI][1]

		If !Virtual //== .F.
			If AScan(aCamposPermitidos, nCampo) > 0
				cLista := oStructSU5:AFIELDS[nI][13]
				If nCampo == "U5_CARGO"
					cLista := {"01=Gerente de Pós Vendas", "02=Gerente de Serviço", "03=Gerente de peças", "04=Chefe de Oficina", "05=Comprador", "06=Consultor", "07=Vendedor", "08=Diretor", "09=Titular"}
				EndIf

				oStru:AddField(oStructSU5:AFIELDS[nI][1],;      // [01]  C   Nome do Campo
				oStructSU5:AFIELDS[nI][2],;      // [02]  C   Ordem
				oStructSU5:AFIELDS[nI][3],;      // [03]  C   Titulo do campo
				oStructSU5:AFIELDS[nI][4],;      // [04]  C   Descricao do campo
				Nil,;                            // [05]  A   Array com Help
				oStructSU5:AFIELDS[nI][6],;      // [06]  C   Tipo do campo
				oStructSU5:AFIELDS[nI][7],;      // [07]  C   Picture
				oStructSU5:AFIELDS[nI][8],;                            // [08]  B   Bloco de PictTre Var
				Nil,;                            // [09]  C   Consulta F3
				oStructSU5:AFIELDS[nI][10],;     // [10]  L   Indica se o campo é alteravel
				Nil,;                            // [11]  C   Pasta do campo
				Nil,;                            // [12]  C   Agrupamento do campo
				cLista,;                         // [13]  A   Lista de valores permitido do campo (Combo)
				Nil,;                            // [14]  N   Tamanho maximo da maior opção do combo
				Nil,;                            // [15]  C   Inicializador de Browse
				Nil,;                            // [16]  L   Indica se o campo é virtual
				oStructSU5:AFIELDS[nI][17],;                            // [17]  C   Picture Variavel
				Nil)                             // [18]  L   Indica pulo de linha após o campo
			EndIf
		EndIf
	Next

Return oStru




User Function GAT()
    Local aArea := GetArea()
    Local cNome := " "
    Local cAlias := GetNextAlias()
    Local oModel := FWModelActive()
    Local oModelGrid := oModel:GetModel('SU5CHILD')
    Local cCelular := oModelGrid:GetValue('U5_CELULAR')
    Local cDDD := oModelGrid:GetValue('U5_DDD') 
    local aCols := oModelGrid:aHeader
    local nCampos := {}
    local nI := 0
    Local cQuery := ""
    local cValor

    cQuery += 'SELECT * FROM ' + RetSqlName("SU5") + ''
    cQuery += " WHERE U5_CELULAR = '" + cCelular + "'"
    cQuery += " AND U5_DDD = '" + cDDD + "'" 
    cQuery += " AND D_E_L_E_T_ = ' ' "

    MpSysOpenQuery(cQuery, cAlias)

    if ALLTRIM((cAlias)->(U5_CONTAT)) == ""
        oModel:SetValue("SU5CHILD", "U5_CODCONT", "")
        return cNome
    endif

    FOR nI := 1 TO Len(aCols)
        if aCols[nI, 10] == 'R' .AND. aCols[nI, 8] != 'M'
            AAdd(nCampos, aCols[nI, 2])
        endif
    NEXT

    dbselectarea("SU5")
    IF !(Empty(nCampos))
        FOR nI := 1 TO Len(nCampos)
            cValor := ALLTRIM((cAlias)->&((nCampos[nI])))
            if (nCampos[nI]) == "U5_NIVER"
                cValor := STOD(cValor)
            endif
            oModel:SetValue("SU5CHILD", (nCampos[nI]), cValor)
        NEXT
        SU5->(dbskip())
    ENDIF

    RestArea(aArea)

    cNome := ALLTRIM((cAlias)->(U5_CONTAT))

    Return cNome




Static Function tBtn(oPanel)

	Local cFont := "Arial"
	Local oFontBtn := TFont():New(cFont,,-14,,.T.)

	oBtnT:= TButton():New( 005, 005, "Adicionar",oPanel,{||AddGridd()}, 80,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

Return


Static Function AddGridd()
	Local oModel          := FWModelActive()
	Local oView 		  := FwViewActive()
	Local oModelGrid      := oModel:GetModel('SU5CHILD')
	Local oModelFields    := oModel:GetModel('SU5TOPRF')
	Local aCamposPermitidos := {"U5_CARGO", "U5_CONTAT", "U5_CELULAR", "U5_FONE", "U5_EMAIL", "U5_NIVER", "U5_HOBBIE", "U5_ESPF", "U5_TIMFAV", "U5_CODCONT","U5_DDD"}
	Local nI
	Local Conteudo
	Local nLinha


	if Empty(ALLTRIM(oModelFields:GetValue("U5_CONTAT")))
		MsgStop("Necessário informar o nome do contato")
		return
	endif
	if Empty(ALLTRIM(oModelFields:GetValue("U5_CARGO")))
		MsgStop("Necessário informar o cargo do contato")
		return
	endif



	oModelGrid:GoLine(1)
	if !Empty(ALLTRIM(oModelGrid:GetValue("U5_CONTAT")))
		oModelGrid:AddLine()
	EndIf
	nLinha := oModelGrid:Length()
	oModelGrid:GoLine(nLinha)

	FOR nI := 1 TO Len(aCamposPermitidos)
		Conteudo := oModelFields:GetValue(aCamposPermitidos[nI])
		oModelGrid:LoadValue(aCamposPermitidos[nI], Conteudo)
		oModelFields:LoadValue(aCamposPermitidos[nI], "")
	Next

	oView:Refresh()

Return



User Function GATFIELD()
    Local cNome := " "
    Local cAlias := GetNextAlias()
    Local oModel := FWModelActive()
    Local oModelGrid := oModel:GetModel('SU5TOPRF')
    Local cCelular := oModelGrid:GetValue('U5_CELULAR')
    Local cDDD := oModelGrid:GetValue('U5_DDD') 
    local nI := 0
    Local cQuery := ""
    local cValor
    Local aCamposPermitidos := {"U5_CARGO", "U5_CONTAT", "U5_CELULAR", "U5_FONE", "U5_EMAIL", "U5_NIVER", "U5_HOBBIE", "U5_ESPF", "U5_TIMFAV", "U5_CODCONT", "U5_DDD"}

    cQuery += 'SELECT * FROM ' + RetSqlName("SU5") + ''
    cQuery += " WHERE U5_CELULAR = '" + cCelular + "'"
    cQuery += " AND U5_DDD = '" + cDDD + "'" 
    cQuery += " AND D_E_L_E_T_ = ' ' "

    MpSysOpenQuery(cQuery, cAlias)

    if ALLTRIM((cAlias)->(U5_CONTAT)) == ""
        oModel:SetValue("SU5TOPRF", "U5_CODCONT", "")
        oModel:SetValue("SU5TOPRF", "U5_CELULAR", cCelular)
        return cNome
    endif

    FOR nI := 1 TO Len(aCamposPermitidos)
        cValor := (cAlias)->&((aCamposPermitidos[nI]))
        if (aCamposPermitidos[nI]) == "U5_NIVER"
            cValor := STOD(cValor)
        endif
        oModel:SetValue("SU5TOPRF", (aCamposPermitidos[nI]), cValor)
    NEXT

    cNome := ALLTRIM((cAlias)->(U5_CONTAT))

    Return cNome


Static Function GetModelFields()

	local oStru 		:= FwFormModelStruct():New()
	Local oStructSU5 	:= FWFormStruct(1,"SU5")
	Local aGatilhos 	:= {}
	Local nAtual
	Local nI

	// Adiciona um campo à estrutura
	For nI := 2 To Len(oStructSU5:AFIELDS)
		Virtual := oStructSU5:AFIELDS[nI][14]
		If  Virtual == .F.
			oStru:AddField(;
				oStructSU5:AFIELDS[nI][1],;  // cTitulo: Título do campo
			oStructSU5:AFIELDS[nI][2],;  // cTooltip: Tooltip do campo
			oStructSU5:AFIELDS[nI][3],;  // cIdField: ID do campo
			oStructSU5:AFIELDS[nI][4],;  // cTipo: Tipo do campo (Caracter)
			oStructSU5:AFIELDS[nI][5],;  // nTamanho: Tamanho do campo
			oStructSU5:AFIELDS[nI][6],; // nDecimal: Decimal do campo (0 por padrão)
			,;                           // bValid: Bloco de código de validação do campo
			,;                           // bWhen: Bloco de código de validação when do campo
			,;                           // aValues: Lista de valores permitidos para o campo
			oStructSU5:AFIELDS[nI][10],; // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
			,; // bInit: Bloco de código de inicialização do campo
			,;                           // lKey: Indica se é um campo chave (verdadeiro/falso)
			oStructSU5:AFIELDS[nI][13],; // lNoUpd: Indica se o campo não pode ser atualizado
			,;                           // lVirtual: Indica se o campo é virtual
			,;                           // cValid: Valid do usuário em formato texto
			)
		EndIf
	Next

	aAdd(aGatilhos, FWStruTriggger( ;
		"U5_CELULAR",;                               //Campo Origem
	"U5_CONTAT",;                               //Campo Destino
	"u_GATFIELD()",;                                   //Regra de Preenchimento
	.F.,;                                       //Irá Posicionar?
	"",;                                        //Alias de Posicionamento
	0,;                                         //Índice de Posicionamento
	'',;                                        //Chave de Posicionamento
	NIL,;                    					//Condição para execução do gatilho
	"01");                                      //Sequência do gatilho
	)

	//Percorrendo os gatilhos e adicionando na Struct
	For nAtual := 1 To Len(aGatilhos)
		oStru:AddTrigger( ;
			aGatilhos[nAtual][01],; //Campo Origem
		aGatilhos[nAtual][02],; //Campo Destino
		aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
		aGatilhos[nAtual][04];  //Bloco de código de execução do gatilho
		)
	Next

return oStru
