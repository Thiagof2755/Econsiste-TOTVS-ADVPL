//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} ECGENA03
Fun��o para executar queries SQL em bases Protheus
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
User Function ECGENA03()

	Local aArea
	Local cEmpAux := "99"
	Local cFilAux := "01"
	Local cUsrAux := "rafael.barale"
	Local cPswAux := "eco@2024"
	Private lProgInic := .F.

	//Se vier direto do programa inicial, prepara o ambiente
	If Select("SX2") == 0
		RPCSetEnv(cEmpAux, cFilAux, cUsrAux, cPswAux, "", "")
		lContinua := .T.
		lProgInic := .T.

		//Sen�o, se vier de dentro do SIGAMDI / SIGAADV, verifica se � admin
	Else
		//lContinua := FWIsAdmin()
	EndIf
	aArea := GetArea()

	//Se deu tudo certo, abre a tela
	If lContinua
		fMontaTela()
	Else
		MsgStop("Somente usu�rios admin podem acessar a rotina!", "Aten��o")
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Fun��o que realiza a montagem da tela
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fMontaTela()
	Local nLinObj := 0
	Local nLargBtn := 60
	//Blocos de c�digo chamados pelos bot�es
	Local bExecutar := {|| fZeraLog(), fExecutar() }
	Local bAbrir    := {|| fZeraLog(), fAbrir() }
	Local bSalvar   := {|| fZeraLog(), fSalvar() }
	Local bFechar   := {|| oDlgSQL:End() }
	Local bExportar := {|| fZeraLog(), fExportar() }
	Local bIndentar := {|| fZeraLog(), fIndentar() }
	Local bSelect   := {|| fZeraLog(), fGerSelect() }
	//Local bUpdate   := {|| fZeraLog(), fGerUpdate() }
	//Local bAjuda    := {|| fZeraLog(), fAjuda() }
	//Local bCampos   := {|| fZeraLog(), fConsSX3()}
	//Fontes
	Private cFontPad    := "Tahoma"
	Private oFontBtn    := TFont():New(cFontPad, , -14)
	Private oFontBtnN   := TFont():New(cFontPad, , -14, , .T.)
	Private oFontMod    := TFont():New(cFontPad, , -38)
	Private oFontSub    := TFont():New(cFontPad, , -20)
	Private oFontSubN   := TFont():New(cFontPad, , -20, , .T.)
	//Caminho do arquivo que guarda a �ltima execu��o de query
	Private cUltPasta := GetTempPath()
	Private cLastQry  := GetTempPath() + "ztisql.txt"
	//Objetos da Janela
	Private lCentered
	Private oBtnExe
	Private oBtnAbr
	Private oBtnSal
	Private oBtnFec
	Private oBtnExp
	Private oBtnInd
	Private oBtnSel
	Private oBtnUpd
	Private oSayModulo, cSayModulo := 'CFG'
	Private oSayTitulo, cSayTitulo := 'Execucao de Queries SQL'
	Private oSaySubTit, cSaySubTit := ''
	Private oDlgSQL
	Private oPanSQL
	Private oPanResult
	Private oEditSQL, cEditSQL := "Digite aqui sua query (F3 para selecionar campos do Dicion�rio)..."
	Private oSayLog, cSayLog
	//Tamanho da janela
	Private aTamanho
	Private nJanLarg
	Private nJanAltu
	Private nJanAltMei
	//Resultados da query
	Private oEditResult
	Private oMResult
	Private aHeadResu  := {}
	Private lEmExecucao := .F.
	Private cAliasResu  := ""

	//Se vier do programa inicial, a dimens�o ser� diferente
	If lProgInic
		aTamanho  := GetScreenRes()
		nJanLarg  := aTamanho[1]
		nJanAltu  := aTamanho[2] - 80
		lCentered := .F.
	Else
		aTamanho  := MsAdvSize()
		nJanLarg  := aTamanho[5]
		nJanAltu  := aTamanho[6]
		lCentered := .T.
	EndIf
	nJanAltMei := nJanAltu/4

	//Se existir o arquivo, busca o conte�do
	If File(cLastQry)
		oFile   := FwFileReader():New(cLastQry)
		If oFile:Open()
			//Busca o conte�do do arquivo
			cArqConteu := oFile:FullRead()
			cEditSQL   := cArqConteu
			oFile:Close()
		EndIf
	EndIf

	//Define os atalhos do F3 e F5
	//SetKey(VK_F3, bCampos)
	SetKey(VK_F5, bExecutar)

	//Cria a janela
	oDlgSQL := TDialog():New(0, 0, nJanAltu, nJanLarg, cSayTitulo, , , , , CLR_BLACK, RGB(250, 250, 250), , , .T.)

	oDlgSQL:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.

	//T�tulos e SubT�tulos
	oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oDlgSQL, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
	oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oDlgSQL, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
	oSaySubTit := TSay():New(014, 045, {|| cSaySubTit}, oDlgSQL, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

	//Bot�es
	oBtnExe := TButton():New(001, (nJanLarg/2) - (nLargBtn * 5), "[F5] Executar",      oDlgSQL, bExecutar, nLargBtn*2, 012, , oFontBtnN, , .T., , , , , , )
	oBtnAbr := TButton():New(001, (nJanLarg/2) - (nLargBtn * 3), "Abrir .sql",         oDlgSQL, bAbrir,    nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	oBtnSal := TButton():New(001, (nJanLarg/2) - (nLargBtn * 2), "Salvar .sql",        oDlgSQL, bSalvar,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	oBtnFec := TButton():New(001, (nJanLarg/2) - (nLargBtn * 1), "Fechar",             oDlgSQL, bFechar,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	//oBtnAju := TButton():New(015, (nJanLarg/2) - (nLargBtn * 5), "Ajuda / Help",       oDlgSQL, bAjuda,    nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	oBtnExp := TButton():New(015, (nJanLarg/2) - (nLargBtn * 4), "Export. Resultado",  oDlgSQL, bExportar, nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	oBtnInd := TButton():New(015, (nJanLarg/2) - (nLargBtn * 3), "Indentar Query",     oDlgSQL, bIndentar, nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	oBtnSel := TButton():New(015, (nJanLarg/2) - (nLargBtn * 2), "Gerar Select",       oDlgSQL, bSelect,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )
	//oBtnUpd := TButton():New(015, (nJanLarg/2) - (nLargBtn * 1), "Gerar Update",       oDlgSQL, bUpdate,   nLargBtn,   012, , oFontBtn,  , .T., , , , , , )

	//Observa��o
	nLinObj := 028
	oSayObs := TSay():New(nLinObj, 003, {|| "Para executar queries: ou 1 = Selecione o texto e aperte F5, ou 2 = Aperte F5 que ir� executar todo o texto digitado"}, oDlgSQL, "", oFontBtn, , , , .T., RGB(150, 150, 150), , (nJanLarg/2) - 6, 10, , , , , , .F., , )

	//Cria o editor de consulta SQL
	nLinObj := 038
	oPanSQL := tPanel():New(nLinObj, 3, "", oDlgSQL, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 3, nJanAltMei - 26)
	oEditSQL := TSimpleEditor():Create(oPanSQL)
	oEditSQL:lAutoIndent := .T.
	oEditSQL:TextFamily("Consolas")
	oEditSQL:nWidth := oPanSQL:nWidth
	oEditSQL:nHeight := oPanSQL:nHeight
	oEditSQL:TextFormat(2) //1=Html; 2=Plain Text
	oEditSQL:TextSize(11)
	oEditSQL:Load(cEditSQL)
	oEditSQL:Refresh()

	//Cria o Painel que conter� o resultado
	nLinObj := nJanAltMei + 12
	oPanResult := tPanel():New(nLinObj, 3, "", oDlgSQL, , , , RGB(000,000,000), RGB(200,200,200), (nJanLarg/2) - 3, (nJanAltu/2) - nLinObj - 10)

	//Log dos erros
	nLinObj := (nJanAltu/2) - 10
	oSayLog := TSay():New(nLinObj, 003, {|| cSayLog}, oDlgSQL, "", oFontBtn, , , , .T., RGB(254, 0, 0), , (nJanLarg/2) - 6, 10, , , , , , .F., , )

	//Ativa e exibe a janela
	oDlgSQL:Activate(, , , lCentered, {|| .T.}, , )
Return

/*/{Protheus.doc} fExecutar
Fun��o que executa a instru��o SQL
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fExecutar()
	Local cComeco   := ""
	Local cTextoSel := oEditSQL:RetTextSel()
	Local lContinua := .T.
	Local cTexto    := oEditSQL:RetText()

	//Se estiver em execu��o, avisa que n�o � poss�vel
	If lEmExecucao
		cSayLog := "Existe uma query em execu��o na mem�ria, aguarde o t�rmino!"
		oSayLog:Refresh()
		MsgStop(cSayLog, "Aten��o")

		//Sen�o executa a query
	Else
		lEmExecucao := .T.
		//Se existir texto selecionado
		If ! Empty(cTextoSel)
			//Substitui o caractere interroga��o por espa�o vazio (-enter- e -tab-)
			cTextoSel := StrTran(cTextoSel, "?", '')

			//Sen�o, ser� todo o texto digitado
		Else
			cTextoSel := cTexto
		EndIf

		//Grava o texto na tempor�ria do S.O.
		fSalvArq(cLastQry)

		//Se houver texto selecionado
		If ! Empty(cTextoSel)

			//Busca o come�o da query, at� o primeiro espa�o
			cComeco := Alltrim(Upper(cTextoSel))
			cComeco := SubStr(cComeco, 1, At(' ', cComeco))

			//Se a query for um Select
			If "SELECT" $ cComeco
				//Se n�o tiver WHERE nem TOP
				If ! "WHERE" $ Upper(cTextoSel) .And. ! "TOP " $ Upper(cTextoSel)
					lContinua := MsgYesNo("N�o foi encontrado os comandos WHERE e TOP na query, isso pode causar uma lentid�o na busca, deseja continuar?", "Executar SELECT")
				EndIf

				//Se for continuar, chama a execu��o da query
				If lContinua
					RptStatus({|| fSelecionar(cTextoSel)}, "Processando", "Buscando Registros...")
				EndIf

				//Se for uma manipula��o
			ElseIf "UPDATE" $ cComeco .Or. "INSERT" $ cComeco .Or. "DELETE" $ cComeco
				lContinua := MsgYesNo("Comandos de manipula��o de dados podem ser prejudiciais para integridade de dados na base, voc� deseja continuar?", "Aten��o")

				//Se for continuar, chama a execu��o da query
				If lContinua
					RptStatus({|| fManipular(cTextoSel)}, "Processando", "Atualizando Registros...")
				EndIf

				//Sen�o, n�o encontrou
			Else
				cSayLog := "Comando n�o reconhecido!"
				oSayLog:Refresh()
				MsgStop(cSayLog, "Aten��o")
			EndIf
		Else
			cSayLog := "Selecione o texto da query que ser� executada"
			oSayLog:Refresh()
			MsgInfo(cSayLog, "Aten��o")
		EndIf

		lEmExecucao := .F.
	EndIf

Return

/*/{Protheus.doc} fAbrir
Fun��o para abrir um arquivo
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fAbrir()
	Local aArea   := GetArea()
	Local cDirIni := cUltPasta
	Local cTipArq := "Arquivos query (*.sql) | Arquivos texto (*.txt)"
	Local cTitulo := "Selecione um arquivo"
	Local lSalvar := .F.
	Local cArqSel := ""
	Local oFile
	Local cArqConteu := ""

	//Chama a fun��o para buscar arquivos
	cArqSel := tFileDialog(;
		cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
	cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
	,;         // Compatibilidade
	cDirIni,;  // Diret�rio inicial da busca de arquivos
	lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
	;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
	)

	//Se o arquivo existir
	If ! Empty(cArqSel) .And. File(cArqSel)

		//Tenta abrir o arquivo
		oFile   := FwFileReader():New(cArqSel)
		If oFile:Open()
			//Busca o conte�do do arquivo
			cArqConteu  := oFile:FullRead()
			oEditSQL:Load(cArqConteu)
			oEditSQL:Refresh()
			oFile:Close()

			cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
		Else
			cSayLog := "N�o foi poss�vel abrir o arquivo"
			oSayLog:Refresh()
			MsgStop(cSayLog, "Aten��o")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} fSalvar
Fun��o para salvar um arquivo acionado pelo bot�o
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fSalvar()
	Local aArea   := GetArea()
	Local cDirIni := cUltPasta
	Local cTipArq := "Arquivos query (*.sql) | Arquivos texto (*.txt)"
	Local cTitulo := "Digite um nome do arquivo e selecione o local"
	Local lSalvar := .T.
	Local cArqSel := ""

	//Chama a fun��o para buscar arquivos
	cArqSel := tFileDialog(;
		cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
	cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
	,;         // Compatibilidade
	cDirIni,;  // Diret�rio inicial da busca de arquivos
	lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
	;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
	)

	//Se o arquivo existir
	If ! Empty(cArqSel)
		//Salva o arquivo
		fSalvArq(cArqSel)

		//Atualiza a �ltima pasta
		cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} fSalvArq
Fun��o que salva o arquivo em uma pasta
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fSalvArq(cArquivo)
	Local oFWriter
	Local cTexto   := oEditSQL:RetText()

	//Grava o arquivo com o conte�do textual
	oFWriter := FWFileWriter():New(cArquivo, .T.)
	oFWriter:Create()
	oFWriter:Write(cTexto)
	oFWriter:Close()
Return

/*/{Protheus.doc} fConsSX3
Fun��o para abrir a lista de campos do dicion�rio
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

/* Static Function fConsSX3()
    Local lOk     := .F.
    Local aCampos := {}
    Local cTexto  := ""
    Local nAtual
    
    //Chama a consulta
    lOk := u_zConsSX3()

    //Se a consulta for confirmada
    If lOk
        //Se existir o retorno
        If ! Empty(__cRetorn)
            __cRetorn := Alltrim(__cRetorn)
            aCampos := StrTokArr(__cRetorn, ",")

            //Percorre os campos
            For nAtual := 1 To Len(aCampos)
                If ! Empty(aCampos[nAtual])
                    cTexto += "    " + aCampos[nAtual] + "," + CRLF
                EndIf
            Next

            //Atualiza o texto, com o que j� existia
            cEditSQL := cTexto + CRLF + oEditSQL:RetText()
            oEditSQL:Load(cEditSQL)
            oEditSQL:Refresh()
        EndIf
    EndIf
Return */

/*/{Protheus.doc} fGerSelect
Fun��o que gera uma query SQL
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fGerSelect()
    Local aPergs   := {}
    Local cTabela  := Space(20)
    Local cCampos  := Space(100)
    Local nLinhas  := 0
    Local nOrden   := 1
    Local cQuery   := ""
    
    //Adiciona os par�metros
    aAdd(aPergs, {1, "Tabela",                          cTabela, "@!",     ".T.",        "", ".T.", 070, .T.})
    aAdd(aPergs, {1, "Campos (separados por v�rgula)",  cCampos, "@!",     ".T.",        "", ".T.", 110, .F.})
    aAdd(aPergs, {1, "N�mero de Linhas (SQL Server)",   nLinhas, "@E 999", "Positivo()", "", ".T.", 040, .F.})
    aAdd(aPergs, {2, "Ordena��o",                       nOrden,  {"1=Sem Ordena��o", "2=RecNo Decrescente", "3=RecNo Crescente"},   090, ".T.", .F.})
    
    //Se a pergunta foi confirmada
    If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
        cTabela := Alltrim(MV_PAR01)
        cCampos := Alltrim(MV_PAR02)
        nLinhas := MV_PAR03
        nOrden  := Val(cValToChar(MV_PAR04))

        //Monta a query
        cQuery := " SELECT " + CRLF

        //Se houver quantidade de linhas
        If nLinhas > 0
            cQuery += " TOP " + cValToChar(nLinhas) + " " + CRLF
        EndIf

        //Se houver campos
        If ! Empty(cCampos)
            cQuery += "     " + cCampos + " " + CRLF
        Else
            cQuery += "     * " + CRLF
        EndIf

        //Agora monta o from
        cQuery += " FROM " + CRLF

        //Se o alias tiver s� 3 no tamanho, busca com RetSQLName
        If Len(cTabela) == 3
            cQuery += "     " + RetSQLName(cTabela) + " T " + CRLF

        //Sen�o, ser� o nome da tabela inteira
        Else
            cQuery += "     " + cTabela + " " + CRLF
        EndIf

        //Agora por �ltimo, monta o WHERE default
        cQuery += " WHERE " + CRLF
        
        //Se a tabela for de 3 caracteres, filtra o campo de filial
        If Len(cTabela) == 3
            cQuery += "     " + IIf(SubStr(cTabela, 1, 1) == "S", SubStr(cTabela, 2), cTabela) + "_FILIAL = '" + FWxFilial(cTabela) + "' AND " + CRLF
        EndIf

        //Filtro de campo deletado
        cQuery += "     T.D_E_L_E_T_ = '' " + CRLF

        //Se a ordena��o for diferente da padr�o
        If nOrden != 1
            cQuery += " ORDER BY " + CRLF

            //Se for decrescente
            If nOrden == 2
                cQuery += "     T.R_E_C_N_O_ DESC " + CRLF

            //Se for crescente
            ElseIf nOrden == 3
                cQuery += "     T.R_E_C_N_O_ ASC " + CRLF
            EndIf
        EndIf

        //Atualiza o texto, com o que j� existia
        cEditSQL := cQuery + CRLF + oEditSQL:RetText()
        oEditSQL:Load(cEditSQL)
        oEditSQL:Refresh()
    EndIf
Return

/*/{Protheus.doc} fAjuda
Fun��o que abre a p�gina online de help
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
/* 
Static Function fAjuda()
    
    Local cLink := ""

    //Abre o link no navegador padr�o
    ShellExecute("Open", cLink, "", "", 1)

Return */

/*/{Protheus.doc} fManipular
Executa uma query de manipula��o na base de dados
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fManipular(cQuery)
    Local nStatus   := 0
    Local cMensagem := ""
    Local cInicio   := Time()
    Local cTermino  := ""

    SetRegua(2)

    //Se a grid existe, exclui ela
    If Type("oMResult") != "U"
        oMResult := Nil
        FreeObj(oMResult)
    EndIf

    //Se o label existe, exclui ele
    If Type("oEditResult") != "U"
        oEditResult := Nil
        FreeObj(oEditResult)
    EndIf

    //Agora ir� executar a query
    IncRegua()
    nStatus  := TCSQLExec(cQuery)
    cTermino := Time()

    //Se houve erro
    If (nStatus < 0)
        cMensagem := "Erro na execu��o da query: " + CRLF + CRLF
        cMensagem += TCSQLError()
    Else
        cMensagem := "Comando executado com sucesso!"
    EndIf

    //Cria o label avisando do resultado
    oEditResult := TSimpleEditor():Create(oPanResult)
    oEditResult:lAutoIndent := .T.
    oEditResult:TextFamily("Consolas")
    oEditResult:nWidth := oPanResult:nWidth
    oEditResult:nHeight := oPanResult:nHeight
    oEditResult:TextFormat(2) //1=Html; 2=Plain Text
    oEditResult:TextSize(09)
    oEditResult:Load(cMensagem)
    oEditResult:Refresh()
    oEditResult:lReadOnly := .T.

    //Atualiza o log com o tempo total
    fAtuLog(cInicio, cTermino, 0)
Return

/*/{Protheus.doc} fZeraLog
Fun��o acionada para zerar o log do rodap�
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fZeraLog()
    cSayLog := ""
    oSayLog:Refresh()
Return

/*/{Protheus.doc} fAtuLog
Fun��o para atualizar o log com o tempo de execu��o da query
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
Static Function fAtuLog(cInicio, cTermino, nQtdLinhas)

    cSayLog := "Inicio: " + cInicio
    cSayLog += " | Termino: " + cTermino
    cSayLog += " | Tempo Total: " + ElapTime(cInicio, cTermino)
    If nQtdLinhas != 0
        cSayLog += " | Quantidade de Linhas: " + cValToChar(nQtdLinhas)
    EndIf
    oSayLog:Refresh()
Return

/*/{Protheus.doc} fGerUpdate
Fun��o que gera uma query SQL de atualiza��o (update)
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
Static Function fGerUpdate()

    Local aPergs     := {}
    Local cTabela    := Space(20)
    Local cCampo     := Space(20)
    Local cConteud   := Space(100)
    Local cQuery     := ""
    Local cTipoCampo := ""
    
    //Adiciona os par�metros
    aAdd(aPergs, {1, "Tabela",                                        cTabela,  "@!",     ".T.",        "", ".T.", 070, .T.})
    aAdd(aPergs, {1, "Campo",                                         cCampo,   "@!",     ".T.",        "", ".T.", 100, .T.})
    aAdd(aPergs, {1, "Conte�do",                                      cConteud, "",       ".T.",        "", ".T.", 100, .T.})
    
    //Se a pergunta foi confirmada
    If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
        cTabela   := Alltrim(MV_PAR01)
        cCampo    := Alltrim(MV_PAR02)
        cConteud  := Alltrim(MV_PAR03)

        //Monta a query
        cQuery := " UPDATE " + CRLF

        //Se o alias tiver s� 3 no tamanho, busca com RetSQLName
        If Len(cTabela) == 3
            cQuery += "     " + RetSQLName(cTabela) + " " + CRLF

        //Sen�o, ser� o nome da tabela inteira
        Else
            cQuery += "     " + cTabela + " " + CRLF
        EndIf

        //Agora monta a atualiza��o
        cQuery += " SET " + CRLF
        cQuery += "     " + cCampo + " = "

        //Se o campo existe no dicion�rio
        If GetSX3Cache(cCampo, "X3_TITULO") != ""
            //Busca o tipo do campo
            cTipoCampo := GetSX3Cache(cCampo, "X3_TIPO")

            //Se for data
            If cTipoCampo == 'D'
                //Se o conte�do tiver barra
                If "/" $ cConteud
                    cConteud := dToS(cToD(cConteud))
                EndIf
            EndIf

            //Se o tipo do campo for caractere ou data
            If cTipoCampo $ 'C,D'
                //Se o conte�do j� tiver ap�strofo
                If "'" $ cConteud
                    cQuery += cConteud
                Else
                    cQuery += "'" + cConteud + "'"
                EndIf

            //Sen�o, atualiza com conte�do default
            Else
                cQuery += cConteud
            EndIf

        //Sen�o, pega exatamente como o usu�rio digitou
        Else
            cQuery += cConteud
        EndIf
        cQuery += " " + CRLF

        //Agora por �ltimo, monta o WHERE default
        cQuery += " WHERE " + CRLF
        
        //Se a tabela for de 3 caracteres, filtra o campo de filial
        If Len(cTabela) == 3
            cQuery += "     " + IIf(SubStr(cTabela, 1, 1) == "S", SubStr(cTabela, 2), cTabela) + "_FILIAL = '" + FWxFilial(cTabela) + "' AND " + CRLF
        EndIf

        //Filtro de campo deletado
        cQuery += "     D_E_L_E_T_ = '' " + CRLF

        //Atualiza o texto, com o que j� existia
        cEditSQL := cQuery + CRLF + oEditSQL:RetText()
        oEditSQL:Load(cEditSQL)
        oEditSQL:Refresh()
    EndIf
Return

/*/{Protheus.doc} fSelecionar
Executa uma query de sele��o na base de dados
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
Static Function fSelecionar(cQuery)
   
    Local nStatus   := 0
    Local cMensagem := ""
    Local cInicio   := Time()
    Local cTermino  := ""
    Local aEstrut   := {}
    Local nCampo    := 0
    Local cCampo
    Local cTitulo
    Local cMascara
    Local nQtdLinhas := 0
    Local cAliasGrid := GetNextAlias()

    SetRegua(3)

    //Se tiver aberto o alias, fecha ele
    If Select(cAliasGrid) > 0
        (cAliasGrid)->(DbCloseArea())
    EndIf
    cAliasResu := cAliasGrid

    //Se a grid existe, exclui ela
    If Type("oMResult") != "U"
        oMResult := Nil
        FreeObj(oMResult)
    EndIf

    //Se o label existe, exclui ele
    If Type("oEditResult") != "U"
        oEditResult := Nil
        FreeObj(oEditResult)
    EndIf

    //Agora ir� executar a query
    IncRegua()
    nStatus  := TCSQLExec(cQuery)
    cTermino := Time()

    //Se houve erro
    If (nStatus < 0)
        cMensagem := "Erro na execu��o da query de SELECT: " + CRLF + CRLF
        cMensagem += TCSQLError()

        //Cria o label avisando do resultado
        oEditResult := TSimpleEditor():Create(oPanResult)
        oEditResult:lAutoIndent := .T.
        oEditResult:TextFamily("Consolas")
        oEditResult:nWidth := oPanResult:nWidth
        oEditResult:nHeight := oPanResult:nHeight
        oEditResult:TextFormat(2) //1=Html; 2=Plain Text
        oEditResult:TextSize(09)
        oEditResult:Load(cMensagem)
        oEditResult:Refresh()
        oEditResult:lReadOnly := .T.
    Else

        //Executa a query
        IncRegua()
        TCQuery cQuery New Alias "TMP_SQL"
        Count To nQtdLinhas
        TMP_SQL->(DbGoTop())
        cTermino := Time()
        
        //Percorre a estrutura e retira campos reservados
        aEstrutTmp   := TMP_SQL->(DbStruct())
        aEstrut      := {}
        For nCampo := 1 To Len(aEstrutTmp)
            cCampo := Alltrim(aEstrutTmp[nCampo][1])

            //Se o campo n�o for um reservado, adiciona na estrutura que ser� usada na grid
            If ! cCampo $ "R_E_C_N_O_ , R_E_C_D_E_L_ , D_E_L_E_T_"
                aAdd(aEstrut, aClone(aEstrutTmp[nCampo]))
            EndIf
        Next

        //Percorre a estrutura, para montar o cabe�alho da grid
        aHeadResu := {}
        For nCampo := 1 To Len(aEstrut)
            cCampo := aEstrut[nCampo][1]

            //Se o campo existir no dicion�rio, busca o t�tulo e a m�scara dele
            If GetSX3Cache(cCampo, "X3_TITULO") != ""
                cTitulo  := Alltrim(GetSX3Cache(cCampo, "X3_TITULO")) + " (" + Alltrim(cCampo) + ")"
                cMascara := GetSX3Cache(cCampo, "X3_PICTURE")
            Else
                cTitulo  := cCampo
                cMascara := ""
            EndIf

            //Adiciona no cabe�alho que ser� usado na grid
            aAdd(aHeadResu, {cCampo, , cTitulo, cMascara})
        Next

        //Cria a tempor�ria que vai ser usada na grid
        oTempTable := FWTemporaryTable():New(cAliasGrid)
        oTempTable:SetFields(aEstrut)
		oTempTable:Create()

        //Agora copia os dados da query para a tempor�ria
        DbSelectArea(cAliasGrid)
        Append From TMP_SQL
        TMP_SQL->(DbCloseArea())
        (cAliasGrid)->(DbGoTop())

        //Cria a grid
        oMResult := MsSelect():New(cAliasGrid, /*cCampo*/, /*cCpo*/, aHeadResu, /*lInv*/, /*cMar*/, {0, 0, oPanResult:nHeight / 2, oPanResult:nWidth / 2}, /*cTopFun*/, /*cBotFun*/, oPanResult)
        oMResult:oBrowse:SetCSS(u_zCSSGrid())
        oMResult:oBrowse:Refresh()
    EndIf

    //Atualiza o log com o tempo total
    fAtuLog(cInicio, cTermino, nQtdLinhas)
Return

/*/{Protheus.doc} fExportar
Fun��o para exportar o resultado da query para arquivo
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fExportar()

    Local aArea     := GetArea()
    Local cDirIni   := cUltPasta
    Local cTipArq   := "Planilha do Excel em XML (*.xml)"
    Local cTitulo   := "Selecione um local para gerar"
    Local lSalvar   := .T.
    Local cArqSel   := ""
    Local cExtensao := ""
    Local cPasta    := ""
    Local cArquivo  := ""
    Private cDelim  := ""
 
    //Se tiver grid
    If Type("oMResult") != "U"
        //Chama a fun��o para buscar arquivos
        cArqSel := tFileDialog(;
            cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
            cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
            ,;         // Compatibilidade
            cDirIni,;  // Diret�rio inicial da busca de arquivos
            lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
            ;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
        )

        //Se o arquivo existir
        If ! Empty(cArqSel)
            //Pega a extens�o do arquivo
            cExtensao := Alltrim(Upper(cArqSel))
            cExtensao := SubStr(cExtensao, RAt(".", cExtensao) + 1)

            //Separa a pasta do arquivo
            cPasta   := SubStr(cArqSel, 1, RAt('\', cArqSel))
            cArquivo := StrTran(cArqSel, cPasta, '')

            //Se for texto
            /*If cExtensao == "TXT"
                DbSelectArea(cAliasResu)
                (cAliasResu)->(DbGoTop())

                //Realiza a exporta��o
                Copy To (cPasta + cArquivo) DELIMITED WITH (cDelim)

                //Abre o arquivo
                ShellExecute("OPEN", cArquivo, "", cPasta, 1)
                */

	//Sen�o, se for planilha do Excel antiga
	If cExtensao == "XML"
		RptStatus({|| fExcel(cArqSel, 1)}, "Exportando", "Gerando Excel...")

		//Sen�o, se for planilha do Excel
	ElseIf cExtensao == "XLSX"
		RptStatus({|| fExcel(cArqSel, 2)}, "Exportando", "Gerando Excel...")

		//Abre o arquivo
		ShellExecute("OPEN", cArquivo, "", cPasta, 1)
	EndIf

	cUltPasta := SubStr(cArqSel, 1, RAt("\", cArqSel))
EndIf

Else
	cSayLog := "Para acionar a exporta��o, execute um SELECT"
	oSayLog:Refresh()
	MsgStop(cSayLog, "Aten��o")
EndIf

RestArea(aArea)
Return

/*/{Protheus.doc} fExcel
Fun��o para o Excel da tabela tempor�ria
@type  Function
@author 
@since 19/12/2020
@version P12
/*/

Static Function fExcel(cArquivo, nTipo)
	Local oFWMsExcel
	Local cWorkSheet := "zTiSQL"
	Local cTitulo    := "Exportacao de dados"
	Local nTotal := 0
	Local nCampo
	Local aLinha

	//Define o tamanho da r�gua
	DbSelectArea(cAliasResu)
	(cAliasResu)->(DbGoTop())
	Count To nTotal
	SetRegua(nTotal)
	(cAliasResu)->(DbGoTop())

	//Cria a planilha do excel
	If nTipo == 1
		oFWMsExcel := FwMsExcel():New()
	ElseIf nTipo == 2
		oFWMsExcel := FwMsExcelXlsx():New()
	EndIf

	//Criando a aba da planilha
	oFWMsExcel:AddworkSheet(cWorkSheet)

	//Criando a Tabela e as colunas
	oFWMsExcel:AddTable(cWorkSheet, cTitulo)
	For nCampo := 1 To Len(aHeadResu)
		//Pega o tipo do campo
		nTipo  := 1 //General
		nAlign := 1 //Left
		If GetSX3Cache(aHeadResu[nCampo][1], "X3_TIPO") == "N"
			nTipo  := 2 //Number
			nAlign := 3 //Right
		EndIf

		//Adiciona a coluna
		oFWMsExcel:AddColumn(cWorkSheet, cTitulo, aHeadResu[nCampo][3], nAlign, nTipo, .F.)
	Next

	//Percorrendo os dados da query
	While !((cAliasResu)->(EoF()))

		//Incrementando a regua
		IncRegua()

		//Cria uma nova linha
		aLinha := {}
		For nCampo := 1 To Len(aHeadResu)
			aAdd(aLinha, (cAliasResu)->(&(aHeadResu[nCampo][1])))
		Next

		//Adicionando uma nova linha
		oFWMsExcel:AddRow(cWorkSheet, cTitulo, aClone(aLinha))

		(cAliasResu)->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	oFWMsExcel:DeActivate()

	//Se for em XML, for�a abrir pelo Excel
	If nTipo == 1
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()
		oExcel:WorkBooks:Open(cArquivo)
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	EndIf
Return

/*/{Protheus.doc} fIndentar
Fun��o para abrir uma URL com a query para indenta��o
@type  Function
@author 
@since 19/12/2020
@version P12
/*/
Static Function fIndentar()

	Local cTextoSel := oEditSQL:RetTextSel()
	Local cLink     := "https://www.freeformatter.com/sql-formatter.html?sqlString="

	//Se tiver vazio o texto selecionado, mostra a mensagem
	If Empty(cTextoSel)
		cSayLog := "Selecione o texto para que seja poss�vel indentar!"
		oSayLog:Refresh()
		MsgStop(cSayLog, "Aten��o")
	Else
		//Substitui o caractere interroga��o por espa�o vazio (-enter- e -tab-)
		cTextoSel := StrTran(cTextoSel, "?", '')

		//No link, ser� enviado a query
		cLink += cTextoSel
		ShellExecute("Open", cLink, "", "", 1)
	EndIf
Return

/*/{Protheus.doc} zCSSGrid
Altera o tamanho do texto usado nas grids antigas (MsNewGetDados e MsSelect)
@type  Function
@author 
@since 18/08/2021
@version P12
@param nTamFonte, Numeric, Tamanho da fonte em pixels na grid
/*/
User Function zCSSGrid(nTamFonte)
	Local cCSSGrid := ""
	Default nTamFonte := 14

	cCSSGrid += "QHeaderView::section {" + CRLF
	cCSSGrid += "	background-color: #6E7D81;" + CRLF
	cCSSGrid += "	border: 1px solid #646769;" + CRLF
	cCSSGrid += "	border-bottom-color: #4B4B4B;" + CRLF
	cCSSGrid += "	border-right-color: #3F4548;" + CRLF
	cCSSGrid += "	border-left-color: #90989D;" + CRLF
	cCSSGrid += "	color: #FFFFFF;" + CRLF
	cCSSGrid += "	font-family: arial;" + CRLF
	cCSSGrid += "	height: 27px;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QHeaderView::section:pressed {" + CRLF
	cCSSGrid += "	background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #485154, stop: 1 #6D7C80);" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QTableView {" + CRLF
	cCSSGrid += "	selection-background-color: #1C9DBD;" + CRLF
	cCSSGrid += "	selection-color: #FFFFFF;" + CRLF
	cCSSGrid += "	alternate-background-color: #B2CBE7;" + CRLF
	cCSSGrid += "	background: #FFFFFF;" + CRLF
	cCSSGrid += "	color: #000000;" + CRLF
	cCSSGrid += "	font-size: " + cValToChar(nTamFonte) + "px;" + CRLF
	//cCSSGrid += "	border: 1px solid #C5C9CA;" + CRLF
	//cCSSGrid += "	border-top: 0px;" + CRLF
	//cCSSGrid += "	border-left: 0px;" + CRLF
	//cCSSGrid += "	border-right: 0px;" + CRLF
	cCSSGrid += "	border: none;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar:horizontal {" + CRLF
	cCSSGrid += "	background-color: #F2F2F2;" + CRLF
	cCSSGrid += "	border: 1px solid #C5C9CA;" + CRLF
	cCSSGrid += "	margin: 0 15px 0px 16px;" + CRLF
	cCSSGrid += "	max-height: 16px;" + CRLF
	cCSSGrid += "	min-height: 16px;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-page:horizontal," + CRLF
	cCSSGrid += "QScrollBar::sub-page:horizontal {" + CRLF
	cCSSGrid += "	background: #F2F2F2;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::handle:horizontal {" + CRLF
	cCSSGrid += "	background-color: #B2B2B2;" + CRLF
	cCSSGrid += "	border: 3px solid #F2F2F2;" + CRLF
	cCSSGrid += "	border-radius: 7px;" + CRLF
	cCSSGrid += "	min-width: 20px;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:horizontal {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_hrz_btn_rgt_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "	border: 1px solid black;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:horizontal:pressed {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_hrz_btn_rgt_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:horizontal {" + CRLF
	cCSSGrid += "	border-top-width: 2px;" + CRLF
	cCSSGrid += "	border-right-width: 2px;" + CRLF
	cCSSGrid += "	border-bottom-width: 2px;" + CRLF
	cCSSGrid += "	border-left-width: 2px;" + CRLF
	cCSSGrid += "	width: 13px;" + CRLF
	cCSSGrid += "	subcontrol-position: right;" + CRLF
	cCSSGrid += "	subcontrol-origin: margin;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:horizontal {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_hrz_btn_lft_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:horizontal:pressed {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_hrz_btn_lft_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:horizontal {" + CRLF
	cCSSGrid += "	border-top-width: 2px;" + CRLF
	cCSSGrid += "	border-right-width: 2px;" + CRLF
	cCSSGrid += "	border-bottom-width: 2px;" + CRLF
	cCSSGrid += "	border-left-width: 2px;" + CRLF
	cCSSGrid += "	width: 13px;" + CRLF
	cCSSGrid += "	subcontrol-position: left;" + CRLF
	cCSSGrid += "	subcontrol-origin: margin;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar:vertical {" + CRLF
	cCSSGrid += "	background-color: #F2F2F2;" + CRLF
	cCSSGrid += "	border-top-width: 0px;" + CRLF
	cCSSGrid += "	border-right-width: 0px;" + CRLF
	cCSSGrid += "	border-bottom-width: 0px;" + CRLF
	cCSSGrid += "	border-left-width: 0px;" + CRLF
	cCSSGrid += "	margin: 15px 0px 16px 0px;" + CRLF
	cCSSGrid += "	max-width: 16px;" + CRLF
	cCSSGrid += "	min-width: 16px;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-page:vertical," + CRLF
	cCSSGrid += "QScrollBar::sub-page:vertical {" + CRLF
	cCSSGrid += "	background: #F2F2F2;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::handle:vertical {" + CRLF
	cCSSGrid += "	background-color: #B2B2B2;" + CRLF
	cCSSGrid += "	border: 3px solid #F2F2F2;" + CRLF
	cCSSGrid += "	border-radius: 7px;" + CRLF
	cCSSGrid += "	min-height: 20px;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:vertical {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_vrt_btn_btm_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:vertical:pressed {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_vrt_btn_btm_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::add-line:vertical {" + CRLF
	cCSSGrid += "	border-top-width: 2px;" + CRLF
	cCSSGrid += "	border-right-width: 2px;" + CRLF
	cCSSGrid += "	border-bottom-width: 2px;" + CRLF
	cCSSGrid += "	border-left-width: 2px;" + CRLF
	cCSSGrid += "	height: 13px;" + CRLF
	cCSSGrid += "	subcontrol-position: bottom;" + CRLF
	cCSSGrid += "	subcontrol-origin: margin;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:vertical {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_vrt_btn_top_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:vertical:pressed {" + CRLF
	cCSSGrid += "	border-image: url(rpo:fwskin_scroll_vrt_btn_top_nml.png) 2 2 2 2 stretch;" + CRLF
	cCSSGrid += "}" + CRLF
	cCSSGrid += "" + CRLF
	cCSSGrid += "QScrollBar::sub-line:vertical {" + CRLF
	cCSSGrid += "	border-top-width: 2px;" + CRLF
	cCSSGrid += "	border-right-width: 2px;" + CRLF
	cCSSGrid += "	border-bottom-width: 2px;" + CRLF
	cCSSGrid += "	border-left-width: 2px;" + CRLF
	cCSSGrid += "	height: 13px;" + CRLF
	cCSSGrid += "	subcontrol-position: top;" + CRLF
	cCSSGrid += "	subcontrol-origin: margin;" + CRLF
	cCSSGrid += "}" + CRLF
Return cCSSGrid
