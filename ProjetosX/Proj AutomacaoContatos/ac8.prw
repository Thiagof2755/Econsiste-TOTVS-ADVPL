dbselectarea("SA1")
	CODENT  := (SA1->A1_COD+SA1->A1_LOJA)


	cQueryAC8 += 'SELECT * FROM '+RetSqlName("AC8")+' '
	cQueryAC8 += "WHERE AC8_CODENT = '"+CODENT+"' "
	cQueryAC8 += "AND D_E_L_E_T_= ' ' "

	MpSysOpenQuery(cQueryAC8,cAliasAC8)


	dbselectarea("SA1")
	CODENT  := (SA1->A1_COD+SA1->A1_LOJA)

	dbselectarea("AC8")
	AC8->(DbGotop())

	While AC8->(!EOF())
		Reclock("AC8",.T.)

		CODCONT := oModelGrid:GetValue('U5_CODCONT')

		(cAliasAC8)->(DbGoTop())

		While (cAliasAC8)->(!EOF()) // Para cada linha e verifica se o campo existe
			if (cAliasAC8)->(AC8_CODCON) == CODCONT .OR. (cAliasAC8)->(AC8_CODCON) == ''
				cValor := 1 // Encontrou
			ENDIF
			(cAliasAC8)->(dbskip())
		End *

		if cValor <> 1 // Se o campo não existe
			AC8->AC8_ENTIDA := "SA1"
			AC8->AC8_CODENT := CODENT
			AC8->AC8_CODCON := CODCONT
			//filial := (SA1->A1_COD+SA1->A1_LOJA)

		ENDIF
		cValor := 0 //
		AC8->(MSuNLOCK())

		AC8->(DbSkip())
	End *




Static Function SU5Register()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local nI
	Local Identificador

	dbselectarea("SU5")

	For nI := 1 to len(oModelGrid:AdataModel)
		If Empty(oModelGrid:AdataModel[nI][1][1][4])
			Identificador := NEWNUMCONT()
			Reclock("SU5",.T.)
			SU5->U5_CODCONT := Identificador
			SU5->U5_CONTAT := (oModelGrid:AdataModel[nI][1][1][1])
			SU5->U5_CELULAR := (oModelGrid:AdataModel[nI][1][1][2])
			SU5->U5_EMAIL := (oModelGrid:AdataModel[nI][1][1][3])
			SU5->U5_FILIAL := (xFilial("SU5"))
			SU5->(MSuNLOCK())
			oModel:SetValue("SU5CHILD","U5_CODCONT",Identificador)
		else
			dbsetorder(1)
			dbseek(xFilial("SU5")+oModelGrid:AdataModel[nI][1][1][4])
			Reclock("SU5",.F.)
			SU5->U5_CELULAR := (oModelGrid:AdataModel[nI][1][1][2])
			SU5->U5_EMAIL := (oModelGrid:AdataModel[nI][1][1][3])
			SU5->U5_CONTAT := (oModelGrid:AdataModel[nI][1][1][1])
			SU5->U5_FILIAL := (xFilial("SU5"))
			SU5->(MSuNLOCK())
		Endif

	Next





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

	
	oStru:AddField("U5_CARGO",; // cTitulo: Título do campo
	'Cargo',;   // cTooltip: Tooltip do campo
	'U5_CARGO',;      // cIdField: ID do campo
	'C',;             // cTipo: Tipo do campo (Caracter)
	02,;              // nTamanho: Tamanho do campo
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
	Local oStructMST 	:= FWFormStruct(2,"SU5")



	Local aOpcoes := {"1=Gerente de Pós Vendas", "2=Gerente de Serviço", "3=Gerente de peças", "4=Chefe de Oficina", "5=Comprador", "6=Consultor", "7=Vendedor", "8=Diretor", "9=Titular"}


	// Adiciona um campo à estrutura

	oStru:AddField("U5_CONTAT",;                // [01]  C   Nome do Campo
	"02",;                      // [02]  C   Ordem
	"Nome",;                    // [03]  C   Titulo do campo
	"Nome",;                    // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	"@A",;                      // [07]  C   Picture
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

	oStru:AddField("U5_CARGO",;                // [01]  C   Nome do Campo
	"05",;                      // [02]  C   Ordem
	"Cargo",;                  // [03]  C   Titulo do campo
	"Cargo",;                  // [04]  C   Descricao do campo
	Nil,;                       // [05]  A   Array com Help
	"C",;                       // [06]  C   Tipo do campo
	Nil,;                      // [07]  C   Picture
	Nil,;                       // [08]  B   Bloco de PictTre Var
	Nil,;                       // [09]  C   Consulta F3
	.T.,;                       // [10]  L   Indica se o campo é alteravel
	Nil,;                       // [11]  C   Pasta do campo
	Nil,;                       // [12]  C   Agrupamento do campo
	aOpcoes,;                       // [13]  A   Lista de valores permitido do campo (Combo)
	Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
	Nil,;                       // [15]  C   Inicializador de Browse
	Nil,;                       // [16]  L   Indica se o campo é virtual
	Nil,;                       // [17]  C   Picture Variavel
	Nil)                        // [18]  L   Indica pulo de linha após o campo


return oStru


