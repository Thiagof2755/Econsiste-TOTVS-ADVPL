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

	Local oModel 			:= FWLoadModel("CRMA980")
	Local bLoad 			:= {|oGridModel, lCopy| loadGrid(oGridModel, lCopy)}
	Local oModelBkp 		:= FWLoadModel("CRMA980")
	local oStru 			:= GetModel()
	oModel:BCOMMIT 			:= {|oModelBkp| fTeste(oModelBkp)}



	oModel:AddGrid( 'SU5CHILD', 'SA1MASTER', oStru, , , , ,bLoad)

	oModel:SetDescription("Modelo 3 - Clientes X Contatos")
	oModel:GetModel("SU5CHILD"):SetDescription("Contatos")
	oModel:GetModel("SU5CHILD"):SetOptional( .T. )
	oModel:GetModel("SU5CHILD"):SetUniqueLine({"U5_CELULAR"})


	oStru:SetProperty('U5_CODCONT',  MODEL_FIELD_OBRIGAT, .F.)

Return oModel


Static Function ViewDef()


	Local oView		    := Nil
	Local oModel		:= ModelDef()
	Local oStructSA1	:= FWFormStruct(2,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(2,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	local oStru 		:= GetView()

	oView:= FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox("BOXFORMALL",100)
	oView:CreateFolder("FOLDER","BOXFORMALL")
	oView:AddSheet("FOLDER","SHEETSA1","Principal")
	oView:AddSheet("FOLDER","SHEETAI0","Informaes Complementares")
	oView:AddSheet("FOLDER","SHEETCTO","Contatos")

	oView:CreateHorizontalBox("BOXFORMSA1",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETSA1")
	oView:CreateHorizontalBox("BOXFORMAI0",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETAI0")
	oView:CreateHorizontalBox("VIEW_TOP",20,/*cIdOwner*/,/*lFixPixel*/,   "FOLDER","SHEETCTO")
	oView:CreateHorizontalBox("VIEW_DET",80,/*cIdOwner*/,/*lFixPixel*/,   "FOLDER","SHEETCTO")


	oView:AddField("VIEW_SA1",oStructSA1,"SA1MASTER")
	oView:SetOwnerView("VIEW_SA1","BOXFORMSA1")

	oView:AddField("VIEW_AI0",oStructAI0,"AI0CHILD")
	oView:SetOwnerView("VIEW_AI0","BOXFORMAI0")

	// oView:AddField("VIEW_AC8",oStructAC8,"AC8MASTER")
	// oView:SetOwnerView("VIEW_AC8","VIEW_TOP")

	oView:AddGrid("VIEW_SU5",oStru,"SU5CHILD")
	oView:SetOwnerView("VIEW_SU5","VIEW_DET")

	oStru:SetProperty("U5_CODCONT",MVC_VIEW_CANCHANGE,.F.)
	oStru:SetProperty("U5_CELULAR",MVC_VIEW_CANCHANGE,.T.)
	oStru:SetProperty("U5_FONE",MVC_VIEW_CANCHANGE,.T.)
	oStru:SetProperty("U5_CELULAR", MVC_VIEW_ORDEM,"01")
	oStru:SetProperty("U5_CONTAT", MVC_VIEW_ORDEM,"02")
	oStru:SetProperty("U5_CARGO", MVC_VIEW_ORDEM,"03")
	oStru:SetProperty("U5_FONE", MVC_VIEW_ORDEM,"04")
	oStru:SetProperty("U5_EMAIL", MVC_VIEW_ORDEM,"05")
	oStru:SetProperty("U5_NIVER", MVC_VIEW_ORDEM,"06")
	oStru:SetProperty("U5_HOBBIE", MVC_VIEW_ORDEM,"07")
	oStru:SetProperty("U5_ESPF", MVC_VIEW_ORDEM,"08")
	oStru:SetProperty("U5_TIMFAV", MVC_VIEW_ORDEM,"09")


Return oView


Static Function MenuDef()
	local aRotina     := FWMVCMenu("CRMA980_PE")

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
	dbselectarea("SU5")
	for nI:= 1 to oModelGrid:Length()
		oModelGrid:GoLine(nI)
		SU5->(dbsetorder(1))
		if !SU5->(dbseek(xFilial("SU5")+oModelGrid:GetValue("U5_CODCONT")))//U5_FILIAL+U5_CODCONT
		/* Cria o registro com base nas informações do grid */
			Identificador := NEWNUMCONT()
			Reclock("SU5",.T.)
			SU5->U5_CODCONT := Identificador
			SU5->U5_CONTAT := (oModelGrid:GetValue("U5_CONTAT"))
			SU5->U5_CELULAR := (oModelGrid:GetValue("U5_CELULAR"))
			SU5->U5_EMAIL := (oModelGrid:GetValue("U5_EMAIL"))
			SU5->U5_FILIAL := (xFilial("SU5"))
			SU5->(MSuNLOCK())
			oModel:SetValue("SU5CHILD","U5_CODCONT",Identificador)
		/* -----------------------------------------------------*/
		Endif
		/* Atualiza o registro com base nas informações do grid */
		Reclock("SU5",.F.)
		SU5->U5_CODCONT := (oModelGrid:GetValue("U5_CODCONT"))
		SU5->U5_CONTAT := (oModelGrid:GetValue("U5_CONTAT"))
		SU5->U5_CELULAR := (oModelGrid:GetValue("U5_CELULAR"))
		SU5->U5_EMAIL := (oModelGrid:GetValue("U5_EMAIL"))
		SU5->U5_FILIAL := (xFilial("SU5"))
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
			oStructSU5:AFIELDS[nI][11],; // bInit: Bloco de código de inicialização do campo
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
	Local oStructSU5 	:= FWFormStruct(2,"SU5")
	Local nI



	// Adiciona um campo à estrutura
	For nI := 1 To Len(oStructSU5:AFIELDS)
		Virtual := oStructSU5:AFIELDS[nI][16]
		nCampo := oStructSU5:AFIELDS[nI][1]
		If  !Virtual //== .F.
			cLista := oStructSU5:AFIELDS[nI][13]
			if nCampo == "U5_CARGO"
				cLista := {"01=Gerente de Pós Vendas", "02=Gerente de Serviço", "03=Gerente de peças", "04=Chefe de Oficina", "05=Comprador", "06=Consultor", "07=Vendedor", "08=Diretor", "09=Titular"}
			endif
			oStru:AddField( oStructSU5:AFIELDS[nI][1],;             // [01]  C   Nome do Campo
			oStructSU5:AFIELDS[nI][2],;                      		// [02]  C   Ordem
			oStructSU5:AFIELDS[nI][3],;                    			// [03]  C   Titulo do campo
			oStructSU5:AFIELDS[nI][4],;                    			// [04]  C   Descricao do campo
			Nil,;                       							// [05]  A   Array com Help
			oStructSU5:AFIELDS[nI][6],;                       		// [06]  C   Tipo do campo
			oStructSU5:AFIELDS[nI][7],;                      		// [07]  C   Picture
			Nil,;                       							// [08]  B   Bloco de PictTre Var
			NiL,;                       							// [09]  C   Consulta F3
			oStructSU5:AFIELDS[nI][10],;                       		// [10]  L   Indica se o campo é alteravel
			Nil,;                       							// [11]  C   Pasta do campo
			Nil,;                       							// [12]  C   Agrupamento do campo
			cLista,;                       							// [13]  A   Lista de valores permitido do campo (Combo)
			Nil,;                       							// [14]  N   Tamanho maximo da maior opção do combo
			Nil,;                       							// [15]  C   Inicializador de Browse
			Nil,;                       							// [16]  L   Indica se o campo é virtual
			Nil,;                      								// [17]  C   Picture Variavel
			Nil)                        							// [18]  L   Indica pulo de linha após o campo
		EndIf //
	Next


return oStru



User Function GAT()
	Local aArea    		:= GetArea()
	Local cNome 		:= " "
	Local cAlias 		:= GetNextAlias()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local cCelular 	    := oModelGrid:GetValue('U5_CELULAR' )
	local aCols         := oModelGrid:aHeader
	local nCampos       := {}
	local nI            := 0
	Local cQuery         := ""
	local cValor

	cQuery += 'SELECT * FROM '+RetSqlName("SU5")+''
	cQuery += " WHERE U5_CELULAR = '"+cCelular+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "


	MpSysOpenQuery(cQuery,cAlias)

	if ALLTRIM((cAlias)->(U5_CONTAT)) == ""
		oModel:SetValue("SU5CHILD","U5_CODCONT","")
		return cNome
	endif

	FOR nI := 1 TO Len(aCols)
		if aCols[nI,10] == 'R' .AND.  aCols[nI,8] != 'M'
			AAdd(nCampos,aCols[nI,2] )
		endif
	NEXT


	dbselectarea("SU5")
	IF !(Empty(nCampos))
		FOR nI := 1 TO Len(nCampos)
			cValor := ALLTRIM((cAlias)->&((nCampos[nI])))
			oModel:SetValue("SU5CHILD",(nCampos[nI]),cValor)
		NEXT
		SU5->(dbskip())
	ENDIF

	RestArea(aArea)

	cNome := ALLTRIM((cAlias)->(U5_CONTAT))


Return cNome

