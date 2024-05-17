#Include "TOTVS.ch"
#Include "Protheus.ch"


/*/{Protheus.doc} WWESTM04
	Fonte responsavel por pegar um arquivo Excel e 
	transformar em CSV para importação para o sistema Protheus
/*/

User Function WWESTM04()
	Local aArea     := FWGetArea()
	Local cDirIni   := GetTempPath()
	Local cTipArq   := 'Arquivos Excel (*.xlsx) | Arquivos Excel 97-2003 (*.xls)'
	Local cTitulo   := 'Seleção de Arquivos para Processamento'
	Local lSalvar   := .F.
	Local cArqSel   := ''
	Private cArqCSV := ""

	//Se não estiver sendo executado via job
	If ! IsBlind()

		//Chama a função para buscar arquivos
		cArqSel := tFileDialog(;
			cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
		cTitulo,;  // Título da Janela para seleção dos arquivos
		,;         // Compatibilidade
		cDirIni,;  // Diretório inicial da busca de arquivos
		lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
		;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
		)

		//Se tiver o arquivo selecionado e ele existir
		If ! Empty(cArqSel) .And. File(cArqSel)
			//Faz a conversão de XLS para CSV
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
Função que processa o arquivo e realiza a importação para o sistema
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
	Local i 		 := 0
	Local x          := 0
	Local aItens     := {}
	Local aVetor     := {}

	Private cSeparador := ','

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	//Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSel)
			oArquivo:Open()

			//Iniciando controle de transação
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

					//Na primeira linha, pega os campos da Tabela e compara pegar o numero que a coluna esta 
					if nLinhaAtu == 1
						aCampos := {}
						cChav := {}
						aCampos := Array(Len(aLinha))
						For i := 1 to len(aLinha)
							aCampos[i] := SubStr(aLinha[i],At("/", aLinha[i])+1,Len(aLinha[i]))
						Next
						i := 1
						For i := 1 to len(aCampos)
							if aCampos[i] == 'CODIGO' .OR. aCampos[i] == 'ARMZ' .OR. aCampos[i] == 'SALDO FISICO'
								aAdd(cChav, i)
							endif
						Next
					endif

					//A partir da segunda linha, pega os valores e monta o vetor pegando os valores coreespondentes ao indices dos campos
					if nLinhaAtu >= 2
						aItens := {}
						aVetor := {}
						aItens := Array(Len(aLinha))
						For x := 1 to len(aLinha)
							aItens[x] := SubStr(aLinha[x],At("/", aLinha[x])+1,Len(aLinha[x]))
						Next
						For x := 1 to len(cChav)
							aAdd(aVetor, aItens[cChav[x]])
						Next
							fExecAuto(@cLog,nLinhaAtu,aVetor)
					endif
				EndDo
			End Transaction

			//Se tiver log, mostra ele
			If ! Empty(cLog)
				MemoWrite(cDirTmp + cArqLog, cLog)
				ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
			EndIf
		Else
			MsgStop('Arquivo não tem conteúdo!', 'Atenção')
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		MsgStop('Arquivo não pode ser aberto!', 'Atenção')
	EndIf

Return

/*/{Protheus.doc} fExecAuto
	Executa o ExecAuto
/*/
Static Function fExecAuto(cLog,nLinhaAtu,aVetor)

	Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local nLinhaErro := 0
	Local aLogErro   := {}
	Local bVetor	 := {}
	//Variáveis do ExecAuto
	Private aDados         := {}
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	//Variáveis da Importação
	Private cAliasImp  := 'AIA_AIB'


	lMsErroAuto := .F.


	bVetor	:= {}
	bVetor 	:= {{"B7_FILIAL", 	xFilial("SB7"),				Nil},;
				{"B7_COD",		aVetor[1],					Nil},; // Deve ter o tamanho exato do campo B7_COD, pois faz parte da chave do indice 1 da SB7
				{"B7_LOCAL",	aVetor[2],					Nil},; // Deve ter o tamanho exato do campo B7_LOCAL, pois faz parte da chave do indice 1 da SB7 //{"B7_DOC",		AllTrim(cNroDoc),			Nil},;
				{"B7_DOC",		"0",			            Nil},;
				{"B7_QUANT",	aVetor[3],					Nil},;
				{"B7_ESCOLHA",	"S",						Nil},;
				{"B7_DATA",		dDataBase,					Nil} } // Deve ter o tamanho exato do campo B7_DATA, pois faz parte da chave do indice 1 da SB7



	MSExecAuto({|x,y,z| mata270(x,y,z)},bVetor,.T.,3)

	//Se houve erro, gera o log
	If lMsErroAuto
		cPastaErro := '\x_logs\'
		cNomeErro  := 'erro_' + cAliasImp + '_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.txt'

		//Se a pasta de erro não existir, cria ela
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

//Essa função foi baseada como referência no seguinte link: https://stackoverflow.com/questions/1858195/convert-xls-to-csv-on-command-line
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

	//Executa a conversão, exemplo:
	//   c:\totvs\Testes\XlsToCsv.vbs "C:\Users\danat\Downloads\tste2.xls" "C:\Users\danat\Downloads\tst2_csv.csv"
	ShellExecute("OPEN", cArqScript, ' "' + cArqXLS + '" "' + cArqCSV + '"', cDirTemp, 0 )

	// Aguarda 3 segundos para criacao do arquivo
	sleep(3000)

Return cArqCSV
