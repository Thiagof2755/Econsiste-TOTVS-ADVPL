#Include "TOTVS.ch"

/*/{Protheus.doc} User Function WWESTM04
Fun��o que realiza a leitura de um XLS convertendo ele para CSV para importar os dados (como se fosse um CSV)
@type  Function
@author Atilio
@since 01/09/2022
@obs Pessoal, essa fun��o � um paliativo de exemplo, para ler um XLS transformando ele em CSV
    Caso voc� queira se aprofundar, ou ver uma classe que vai al�m, com op��o de leitura e
    escrita, eu recomendo que voc� conhe�a a YExcel, que � um projeto excelente do Saulo Martins
    + Link para download: https://github.com/saulogm/advpl-excel/blob/master/src/YEXCEL.prw
    + Link de exemplo:    https://github.com/saulogm/advpl-excel/blob/master/exemplo/tstyexcel.prw
    + Documenta��o:       https://github.com/saulogm/advpl-excel

    Adequa��es feitas por econsiste
    Para realizar o execauto na tabela de invent�rio SB7

/*/

User Function WWESTM0copy4()
	Local aArea     := FWGetArea()
	Local cDirIni   := GetTempPath()
	Local cTipArq   := 'Arquivos Excel (*.xlsx) | Arquivos Excel 97-2003 (*.xls)'
	Local cTitulo   := 'Sele��o de Arquivos para Processamento'
	Local lSalvar   := .F.
	Local cArqSel   := ''
	Private cArqCSV := ""

	//Se n�o estiver sendo executado via job
	If ! IsBlind()

		//Chama a fun��o para buscar arquivos
		cArqSel := tFileDialog(;
			cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
		cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
		,;         // Compatibilidade
		cDirIni,;  // Diret�rio inicial da busca de arquivos
		lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
		;          // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
		)

		//Se tiver o arquivo selecionado e ele existir
		If ! Empty(cArqSel) .And. File(cArqSel)
			//Faz a convers�o de XLS para CSV
			cArqCSV := fXLStoCSV(cArqSel)
			// cArqCSV := cArqSel

			//Se o arquivo XLS existir
			If File(cArqCSV)
				Processa({|| fImporta(cArqCSV) }, 'Importando...')
			else
				MSGSTOP( "Nao conseguiu gerar o arquivo", "ERROR" )
			EndIf
		EndIf
	EndIf

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fImporta
Fun��o que processa o arquivo e realiza a importa��o para o sistema
@author Daniel Atilio
@since 16/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fImporta(cArqSel)
	Local cDirTmp    := GetTempPath()
	Local cArqLog    := 'importacao_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
	Local nTotLinhas := 0
	Local cLinAtu    := ''
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local cLog       := ''
	Local aCampos    := {}
	Local i := 0
	local cChavCab := ''
	Local aCabec   := {}
	Local aItens   := {}
	Local aItem    := {}

	Private cSeparador := ','

	//Abre as tabelas que ser�o usadas
	// DbSelectArea(cAliasImp)
	// (cAliasImp)->(DbSetOrder(1))
	// (cAliasImp)->(DbGoTop())

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	//Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se n�o for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da r�gua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//M�todo GoTop n�o funciona (dependendo da vers�o da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSel)
			oArquivo:Open()

			//Iniciando controle de transa��o
			Begin Transaction

				//Enquanto tiver linhas
				While (oArquivo:HasLine())

					//Incrementa na tela a mensagem
					nLinhaAtu++
					IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')

					cLinAtu := oArquivo:GetLine()
					//Pegando a linha atual e transformando em array
					aLinha  := Separa(cLinAtu, cSeparador)
					//Campos do excel
					if nLinhaAtu == 2
						aCampos := {}
						aCampos := Array(Len(aLinha))
						For i := 1 to len(aLinha)
							aCampos[i] := SubStr(aLinha[i],At("/", aLinha[i])+1,Len(aLinha[i]))
						Next
					endif

					if nLinhaAtu > 2
						//Se houver posi��es no array
						If Len(aLinha) > 0
							//Preenchendo cabe�alho
							if cChavCab != aLinha[1]+aLinha[2]+aLinha[3]
								if !Empty(cChavCab)
									//Realiza o execauto
									fExecAuto(@cLog,nLinhaAtu,aVetor)
									//Limpa os Arrays
									aItens := {}
									aCabec := {}
								endif

								cChavCab := aLinha[1]+aLinha[2]+aLinha[3]

								aCabec := {}
								for i := 1 to len(aLinha)
									if "AIA" $ aCampos[i]
										if Tamsx3(aCampos[i])[3]=="N"
											aAdd(aCabec, {aCampos[i],Val(aLinha[i]) , Nil})
										elseif Tamsx3(aCampos[i])[3]=="D"
											//Quando salva em csv, est� em formato americano mm/dd/aaaa
											aDt := Separa(aLinha[i], "/")
											cMes := Padl(aDt[1],2,"0")
											cDia := Padl(aDt[2],2,"0")
											cAno := aDt[3]
											aAdd(aCabec, {aCampos[i],stod(cAno+cMes+cDia) , Nil})
										else
											aAdd(aCabec, {aCampos[i],aLinha[i] , Nil})
										endif
										// aAdd(aCabec, {aCampos[i], aLinha[i], Nil})
									endif
								Next
							endif

							aItem := {}
							for i := 1 to len(aLinha)
								if "AIB" $ aCampos[i]
									if Tamsx3(aCampos[i])[3]=="N"
										aAdd(aItem, {aCampos[i],Val(aLinha[i]) , Nil})
									elseif Tamsx3(aCampos[i])[3]=="D"
										//Quando salva em csv, est� em formato americano mm/dd/aaaa
										aDt := Separa(aLinha[i], "/")
										cMes := Padl(aDt[1],2,"0")
										cDia := Padl(aDt[2],2,"0")
										cAno := aDt[3]
										aAdd(aItem, {aCampos[i],stod(cAno+cMes+cDia) , Nil})
									else
										aAdd(aItem, {aCampos[i],aLinha[i] , Nil})
									endif
								endif
							Next

							aAdd(aItens,aItem)
						EndIf
					EndIf
				EndDo
				if !Empty(aItens)
					fExecAuto(@cLog,nLinhaAtu,aVetor)
				endif
			End Transaction

			//Se tiver log, mostra ele
			If ! Empty(cLog)
				MemoWrite(cDirTmp + cArqLog, cLog)
				ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
			EndIf

		Else
			MsgStop('Arquivo n�o tem conte�do!', 'Aten��o')
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		MsgStop('Arquivo n�o pode ser aberto!', 'Aten��o')
	EndIf

Return

Static Function fExecAuto(cLog,nLinhaAtu,aVetor)

	Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local nLinhaErro := 0
	Local aLogErro   := {}
	//Vari�veis do ExecAuto
	Private aDados         := {}
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

	//Vari�veis da Importa��o
	Private cAliasImp  := 'AIA_AIB'

	lMsErroAuto := .F.
	// MSExecAuto({|x,y,z|COMA010(x,y,z)},4,aCab,aItens)
  /*
  aVetor	:= {}
  aVetor 	:= {{"B7_FILIAL", 	xFilial("SB7"),				Nil},;
        {"B7_COD",		(cAliasTMP)->B8_PRODUTO,	Nil},; // Deve ter o tamanho exato do campo B7_COD, pois faz parte da chave do indice 1 da SB7
        {"B7_LOCAL",	(cAliasTMP)->B8_LOCAL,		Nil},; // Deve ter o tamanho exato do campo B7_LOCAL, pois faz parte da chave do indice 1 da SB7
        {"B7_DOC",		AllTrim(cNroDoc),			Nil},;
        {"B7_QUANT",	0,							Nil},;
        {"B7_ESCOLHA",	"S",						Nil},;
        {"B7_DATA",		dDataBase,						Nil} } // Deve ter o tamanho exato do campo B7_DATA, pois faz parte da chave do indice 1 da SB7
            
  */
	MSExecAuto({|x,y,z| mata270(x,y,z)},aVetor,.T.,3)

	//Se houve erro, gera o log
	If lMsErroAuto
		cPastaErro := '\x_logs\'
		cNomeErro  := 'erro_' + cAliasImp + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'

		//Se a pasta de erro n�o existir, cria ela
		If ! ExistDir(cPastaErro)
			MakeDir(cPastaErro)
		EndIf

		//Pegando log do ExecAuto, percorrendo e incrementando o texto
		aLogErro := GetAutoGRLog()
		For nLinhaErro := 1 To Len(aLogErro)
			cTextoErro += aLogErro[nLinhaErro] + CRLF
		Next

		//Criando o arquivo txt e incrementa o log
		MemoWrite(cPastaErro + cNomeErro, cTextoErro)
		cLog += '- Falha ao incluir registro, linha [' + cValToChar(nLinhaAtu) + '], arquivo de log em ' + cPastaErro + cNomeErro + CRLF
		cLog += cTextoErro
	Else
		cLog += '+ Sucesso no Execauto na linha ' + cValToChar(nLinhaAtu) + ';' + CRLF
	EndIf

Return

//Essa fun��o foi baseada como refer�ncia no seguinte link: https://stackoverflow.com/questions/1858195/convert-xls-to-csv-on-command-line
Static Function fXLStoCSV(cArqXLS)
	Local cArqCSV    := ""
	Local cDirTemp   := GetTempPath()
	Local cArqScript := cDirTemp + "XlsToCsv.vbs"
	Local cScript    := ""
	Local cDrive     := ""
	Local cDiretorio := ""
	Local cNome      := ""
	Local cExtensao  := ""

	//Monta o Script para converter
	cScript := 'if WScript.Arguments.Count < 2 Then' + CRLF
	cScript += '    WScript.Echo "Error! Please specify the source path and the destination. Usage: XlsToCsv SourcePath.xls Destination.csv"' + CRLF
	cScript += '    Wscript.Quit' + CRLF
	cScript += 'End If' + CRLF
	cScript += 'Dim oExcel' + CRLF
	cScript += 'Set oExcel = CreateObject("Excel.Application")' + CRLF
	cScript += 'Dim oBook' + CRLF
	cScript += 'Set oBook = oExcel.Workbooks.Open(Wscript.Arguments.Item(0))' + CRLF
	cScript += 'oBook.SaveAs WScript.Arguments.Item(1), 6' + CRLF
	cScript += 'oBook.Close False' + CRLF
	cScript += 'oExcel.Quit' + CRLF
	MemoWrite(cArqScript, cScript)

	//Pega os detalhes do arquivo original em XLS
	SplitPath(cArqXLS, @cDrive, @cDiretorio, @cNome, @cExtensao)

	//Monta o nome do CSV, conforme os detalhes do XLS
	cArqCSV := cDrive + cDiretorio + cNome + ".csv"

	//Se existir o arquivo no servidor, apaga
	if file(cArqCSV)
		FERASE(cArqCSV)
	endif

	//Executa a convers�o, exemplo:
	//   c:\totvs\Testes\XlsToCsv.vbs "C:\Users\danat\Downloads\tste2.xls" "C:\Users\danat\Downloads\tst2_csv.csv"
	ShellExecute("OPEN", cArqScript, ' "' + cArqXLS + '" "' + cArqCSV + '"', cDirTemp, 0 )

	// Aguarda 3 segundos para criacao do arquivo
	sleep(3000)

Return cArqCSV
