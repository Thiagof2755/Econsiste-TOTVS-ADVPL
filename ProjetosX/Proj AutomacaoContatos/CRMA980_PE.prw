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



Return oView


Static Function MenuDef()
	local aRotina     := FWMVCMenu("CRMA980_PE")

Return aRotina


Static Function loadGrid(oGridModel, lCopy)

	Local aLoad := {}
	local cChave := padr("SA1",tamsx3("AC8_ENTIDA")[1])+xFilial("SA1")+Padr(SA1->(A1_COD+A1_LOJA),tamsx3("AC8_CODENT")[1])
	local nI := 0
	local aCols := Array(Len(oGridModel:aHeader))

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


		aAdd(aLoad,{0,aCols})
		AC8->(dbskip())
	END

Return aLoad

Static Function fTeste(oModelBkp)
	Local cAlias 		:= GetNextAlias()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local cQuery         := ""
	local cValor
	Local CODCONT
	Local CODENT
	


	dbselectarea("SA1")
	CODENT  := (SA1->A1_COD+SA1->A1_LOJA)

	cQuery += 'SELECT * FROM '+RetSqlName("AC8")+' '
	cQuery += "WHERE AC8_CODENT = '"+CODENT+"' "
	cQuery += "AND D_E_L_E_T_= ' ' "

	MpSysOpenQuery(cQuery,cAlias)

	CommitPrincipal:= FwFormCommit(oModelBkp)


			dbselectarea("AC8")
			AC8->(DbGotop())

		While AC8->(!EOF())
			Reclock("AC8",.F.)

			CODCONT := oModelGrid:GetValue('U5_CODCONT')
			
				(cAlias)->(DbGoTop())

					While (cAlias)->(!EOF()) // Para cada linha e verifica se o campo existe
						if (cAlias)->(AC8_CODCON) == CODCONT .OR. (cAlias)->(AC8_CODCON) == ''
							cValor := 1 // Encontrou
						ENDIF
					(cAlias)->(dbskip())
					End *


					if cValor <> 1 // Se o campo não existe
						AC8->AC8_ENTIDA := "SA1"
						AC8->AC8_CODENT := CODENT
						AC8->AC8_CODCON := CODCONT
					ENDIF
					cValor := 0 //
			AC8->(MSuNLOCK())

			AC8->(DbSkip())
		End *

return .T.

Static Function GetModel()

	local oStru 		:= FwFormModelStruct():New()
	Local aGatilhos 	:= {}
	Local nAtual


	// Adiciona um campo à estrutura
	oStru:AddField( 'Nome',;       // cTitulo: Título do campo
	'Nome',;       // cTooltip: Tooltip do campo
	'U5_CONTAT',;     // cIdField: ID do campo
	'C',;          // cTipo: Tipo do campo (Caracter)
	64,;           // nTamanho: Tamanho do campo
	0,;            // nDecimal: Decimal do campo (0 por padrão)
	,;             // bValid: Bloco de código de validação do campo
	,;             // bWhen: Bloco de código de validação when do campo
	,;             // aValues: Lista de valores permitidos para o campo
	.T.,;          // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
	,;             // bInit: Bloco de código de inicialização do campo
	,;             // lKey: Indica se é um campo chave (verdadeiro/falso)
	,;             // lNoUpd: Indica se o campo não pode ser atualizado
	,;             // lVirtual: Indica se o campo é virtual
	,;             // cValid: Valid do usuário em formato texto
	)

	oStru:AddField( 'Telefone Cel ',;       // cTitulo: Título do campo
	'Telefone Cel',;       // cTooltip: Tooltip do campo
	'U5_CELULAR',;     // cIdField: ID do campo
	'C',;             // cTipo: Tipo do campo (Caracter)
	15,;              // nTamanho: Tamanho do campo
	0,;               // nDecimal: Decimal do campo (0 por padrão)
	,;                // bValid: Bloco de código de validação do campo
	,;                // bWhen: Bloco de código de validação when do campo
	,;                // aValues: Lista de valores permitidos para o campo
	.T.,;             // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
	,;                // bInit: Bloco de código de inicialização do campo
	,;                // lKey: Indica se é um campo chave (verdadeiro/falso)
	,;                // lNoUpd: Indica se o campo não pode ser atualizado
	,;                // lVirtual: Indica se o campo é virtual
	,;                // cValid: Valid do usuário em formato texto
	)

	oStru:AddField( 'GmailEmail',;    // cTitulo: Título do campo
	'GmailEmail',;   // cTooltip: Tooltip do campo
	'U5_EMAIL',;      // cIdField: ID do campo
	'C',;             // cTipo: Tipo do campo (Caracter)
	50,;              // nTamanho: Tamanho do campo
	0,;               // nDecimal: Decimal do campo (0 por padrão)
	,;                // bValid: Bloco de código de validação do campo
	,;                // bWhen: Bloco de código de validação when do campo
	,;                // aValues: Lista de valores permitidos para o campo
	.F.,;             // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
	,;                // bInit: Bloco de código de inicialização do campo
	,;                // lKey: Indica se é um campo chave (verdadeiro/falso)
	,;                // lNoUpd: Indica se o campo não pode ser atualizado
	,;                // lVirtual: Indica se o campo é virtual
	,;                // cValid: Valid do usuário em formato texto
	)
	oStru:AddField( 'Cod Contato',;    // cTitulo: Título do campo
	'Cod Contato',;   // cTooltip: Tooltip do campo
	'U5_CODCONT',;      // cIdField: ID do campo
	'C',;             // cTipo: Tipo do campo (Caracter)
	50,;              // nTamanho: Tamanho do campo
	0,;               // nDecimal: Decimal do campo (0 por padrão)
	,;                // bValid: Bloco de código de validação do campo
	,;                // bWhen: Bloco de código de validação when do campo
	,;                // aValues: Lista de valores permitidos para o campo
	.F.,;             // lObrigat: Indica se o campo é obrigatório (.T. para verdadeiro)
	,;                // bInit: Bloco de código de inicialização do campo
	,;                // lKey: Indica se é um campo chave (verdadeiro/falso)
	,;                // lNoUpd: Indica se o campo não pode ser atualizado
	,;                // lVirtual: Indica se o campo é virtual
	,;                // cValid: Valid do usuário em formato texto
	)


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


	// Adiciona um campo à estrutura

	oStru:AddField("U5_CONTAT",;                // [01]  C   Nome do Campo
	"02",;                      // [02]  C   Ordem
	"Nome",;                    // [03]  C   Titulo do campo
	"Nome",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStru:AddField("U5_CELULAR",;                // [01]  C   Nome do Campo
	"01",;                      // [02]  C   Ordem
	"Celular",;                  // [03]  C   Titulo do campo
	"Celular",;                  // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@R",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStru:AddField("U5_EMAIL",;                // [01]  C   Nome do Campo
	"03",;                      // [02]  C   Ordem
	"E-mail",;                  // [03]  C   Titulo do campo
	"E-mail",;                  // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@!",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStru:AddField("U5_CODCONT",;                // [01]  C   Nome do Campo
	"04",;                      // [02]  C   Ordem
	"Cod Contato",;                  // [03]  C   Titulo do campo
	"Cod Contato",;                  // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@R",;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.F.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo



return oStru

