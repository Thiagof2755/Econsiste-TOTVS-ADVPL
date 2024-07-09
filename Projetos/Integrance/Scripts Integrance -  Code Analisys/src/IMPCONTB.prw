#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "PRTOPDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ IMPCONTB ºAutor ³Jonathan Schmidt Alvesº Data ³ 20/03/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa de importacao de lancamentos contabeis (CT2)      º±±
±±º          ³ a partir de arquivo .CSV utilizando ExecAuto no CTBA102    º±±
±±º          ³ O programa faz diversas validacoes antes de iniciar processº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IQA                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function IMPCONTB()
Private cArqRet := ""
Private aCampos := {}
Private cCodUsr := __CUSERID // RetCodUsr()
Private lReturn := .T.
Private nImport := 0
nImport := Aviso("Qual o tipo do arquivo a importar?","Contabil ou FolhaRM",{"CONTABIL","FOLHARM"})
If nImport == 1 // CONTABIL
	aCampos := {{"Data","CTB_DATA","cData"},{"Lote","CTB_LOTE","cLote"},{"SubLote","CTB_SUBLOTE","cSubLote"},{"Doc","CTB_DOC","cDoc"},{"Linha","CTB_LINHA","cLinha"},{"Debito","CTB_DEBITO","cDebito"},{"Credito","CTB_CREDITO","cCredito"},{"Valor","CTB_VALOR","cValor"},{"Historico","CTB_HIST","cHistorico"},{"CCD","CTB_CCD","cCCD"},{"CCC","CTB_CCC","cCCC"},{"ItemD","CTB_ITEMD","cItemD"},{"ItemC","CTB_ITEMC","cItemC"},{"ClasseDeb","CTB_CLVLDB","cClasseDeb"},{"ClasseCrd","CTB_CLVLCR","cClasseCrd"}}
ElseIf nImport == 2 // FOLHA RM
	aCampos := {{"Filial","CT2_FILIAL","cFili"},{"Data","CT2_DATA","cData"},{"Lote","CT2_LOTE","cLote"},{"SubLote","CT2_SUBLOTE","cSubLote"},{"Doc","CT2_DOC","cDoc"},{"Linha","CT2_LINHA","cLinha"},{"Debito","CT2_DEBITO","cDebito"},{"Credito","CT2_CREDIT","cCredito"},{"Historico","CT2_HISTORICO","cHistorico"},{"Valor","CT2_VALOR","cValor"},{"CCD","CT2_CENTROCUSTO","cCusto"}}
Else
	Return
EndIf
cArqRet := fAbrir()
If !Empty(cArqRet)
	If !File(cArqRet)
		MsgStop("Arquivo nao encontrado!" + Chr(13) + Chr(10) + ;
		"Verifique o caminho e o nome do arquivo!","IMPCONTB")
		MsgAlert("A importacao nao foi realizada!","IMPCONTB")
		Return
	EndIf
Else
	MsgStop("Arquivo deve ser informado!","IMPCONTB")
	MsgAlert("A importacao nao foi realizada!","IMPCONTB")
	Return
EndIf
Processa({|lEnd| fReading() },"Validando o arquivo para importacao...","Validacao do arquivo",.F.)
If lReturn
	MsgInfo("Importacao realizada com sucesso!","IMPCONTB")
Else
	MsgAlert("Importacao nao foi realizada!","IMPCONTB")
EndIf
If Select("TRB") > 0
	TRB->(DbcloseArea())
EndIf
Return

Static Function fAbrir()
Local cType := "Arquivo CSV.  | *.CSV|"
Local cArq := ""
cArq := cGetFile(cType, OemToAnsi("Selecione o arquivo para importar"),0,,.T.,GETF_LOCALHARD + GETF_LOCALFLOPPY)
If Empty(cArq)
	cArqRet := ""
	cDiv1 := ""
	cDiv2 := ""
Else
	cArqRet := cArq
EndIf
Return cArqRet

Static Function fReading()
Local nTamFile, nTamLin, cBuffer, nBtLidos
Local cEOL := Chr(13) + Chr(10)
Local nHdlRet
Local nHdlDV1
Local nHdlDV2
Local aItem := {}
Local aLancs := {}
Local nTamCT1 := TamSX3("CT1_CONTA")[1]
Local nTamCTT := TamSX3("CTT_CUSTO")[1]
Local nTamCTD := TamSX3("CTD_ITEM")[1]
Local nTamCTH := TamSX3("CTH_CLVL")[1]

Local nZerosCC := 4 // 7 // pode ser 7 ou 6, Quantidade de caracteres esperada no Centro de Custo (preenchera com zeros quando faltar)
Local nZerosIT := 4 // Quantidade de caracteres esperada no Item Contabil (preenchera com zeros quando faltar)
Local nZerosCL := 6 // Quantidade de caracteres esperada na Classe de Valor (preenchera com zeros quando faltar)

FT_FUse(cArqRet)

// Validacao 02: Cabecalho do arquivo
FT_FGOTOP()
cBuffer := FT_FREADLN()
If Right(AllTrim(cBuffer),1) <> ";"
	cBuffer += ";"
EndIf
nColsCabec := 0
While At(";",cBuffer) > 0
	cBuffer := SubStr(cBuffer,At(";",cBuffer) + 1,Len(cBuffer) - At(";",cBuffer) + 1)
	nColsCabec++
End

// Validacao 01: Quantidade de linhas do arquivo
FT_FGOTOP()
FT_FSkip() // Pular o cabecalho
nTotLines := 0
While !FT_FEOF()
	nTotLines++
	FT_FSkip()
End
If nTotLines <= 1
	MsgStop("Nao ha linhas de dados no arquivo de importacao!","IMPCONTB")
	lReturn := .F.
	Return
ElseIf nTotLines > 999
	MsgStop("Quantidade maxima de linhas: 999" + Chr(13) + Chr(10) + ;
	"Quantidade de linhas do arquivo: " + cValToChar(nTotLines))
	lReturn := .F.
	Return
EndIf

ProcRegua(nTotLines * 2) // Numero de registros a processar
nLinha := 1
nLine := 0
FT_FGOTOP()
FT_FSkip()
dDataPrev := CtoD("  /  /  ")
nDebs := 0
nCreds := 0
While (!FT_FEOF())
	nLine++
	cBuffer := FT_FREADLN()
	If Right(AllTrim(cBuffer),1) <> ";"
		cBuffer += ";"
	EndIf
	If nImport == 1 // Importacao Contabil eu coloco 1 ponto e virgula a mais nas linhas de dados
		cBuffer += ";"
	EndIf
	If !Empty(cBuffer)
		IncProc('Processando ...' + cValToChar(nLine) + " / " + cValToChar(nTotLines))
	Else
		nResposta := Aviso("A linha " + cValToChar(nLine) + " / " + cValToChar(nTotLines) + " esta vazia!" + Chr(13) + Chr(10) + ;
		"O que deseja fazer?",{"Continuar","Interromper"})
		If nResposta == 2 // Interromper
			lReturn := .F.
			Return
		Else // Continuar
			FT_FSKIP()
			Loop
		EndIf
	EndIf
	// Validacao 02: Colunas das linhas e cabecalho
	nCols := 0
	For n := 1 To Len(cBuffer)
		If SubStr(cBuffer,n,1) == ";"
			nCols++
		EndIf
	Next
	If nCols <> Len(aCampos)
		If nImport == 1 // Importacao Contabil
			nCols--
		ElseIf nImport == 2 // Importacao Folha que nao bateu, incremento 1 pois deve ser arq contabil
			nCols++
		EndIf
		MsgStop("ERRO: Qtd invalida de colunas na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
		"Esperadas " + cValToChar(Len(aCampos)) + " Encontradas: " + cValToChar(nCols),"IMPCONTB")
		lReturn := .F.
		If Len(aCampos) == 15 .And. nCols == 11 .Or. nCols == 12 // Esperava 15 campos e vieram 11 apenas
			If MsgYesNo("Esta parecendo um arquivo FOLHARM, sera que nao?" + Chr(13) + Chr(10) + ;
				"Vamos tentar pra ver se o programa aceita?","IMPCONTB")
				aCampos := {{"Filial","CT2_FILIAL","cFili"},{"Data","CT2_DATA","cData"},{"Lote","CT2_LOTE","cLote"},{"SubLote","CT2_SUBLOTE","cSubLote"},{"Doc","CT2_DOC","cDoc"},{"Linha","CT2_LINHA","cLinha"},{"Debito","CT2_DEBITO","cDebito"},{"Credito","CT2_CREDIT","cCredito"},{"Historico","CT2_HISTORICO","cHistorico"},{"Valor","CT2_VALOR","cValor"},{"CCD","CT2_CENTROCUSTO","cCusto"}}
				nImport := 2
				
				cBuffer := FT_FREADLN()
				If Right(AllTrim(cBuffer),1) <> ";"
					cBuffer += ";"
				EndIf
				If nImport == 1 // Importacao Contabil eu coloco 1 ponto e virgula a mais nas linhas de dados
					cBuffer += ";"
				EndIf
				nCols := 0
				For n := 1 To Len(cBuffer)
					If SubStr(cBuffer,n,1) == ";"
						nCols++
					EndIf
				Next
			Else
				lReturn := .F.
				Return
			EndIf
		ElseIf Len(aCampos) == 11 .And. nCols == 14 .Or. nCols == 15 // Esperava 11 campos e vieram 15
			If MsgYesNo("Esta parecendo um arquivo CONTABIL, sera que nao?" + Chr(13) + Chr(10) + ;
				"Vamos tentar pra ver se o programa aceita?","IMPCONTB")
				aCampos := {{"Data","CTB_DATA","cData"},{"Lote","CTB_LOTE","cLote"},{"SubLote","CTB_SUBLOTE","cSubLote"},{"Doc","CTB_DOC","cDoc"},{"Linha","CTB_LINHA","cLinha"},{"Debito","CTB_DEBITO","cDebito"},{"Credito","CTB_CREDITO","cCredito"},{"Valor","CTB_VALOR","cValor"},{"Historico","CTB_HIST","cHistorico"},{"CCD","CTB_CCD","cCCD"},{"CCC","CTB_CCC","cCCC"},{"ItemD","CTB_ITEMD","cItemD"},{"ItemC","CTB_ITEMC","cItemC"},{"ClasseDeb","CTB_CLVLDB","cClasseDeb"},{"ClasseCrd","CTB_CLVLCR","cClasseCrd"}}
				nImport := 1
				
				cBuffer := FT_FREADLN()
				If Right(AllTrim(cBuffer),1) <> ";"
					cBuffer += ";"
				EndIf
				If nImport == 1 // Importacao Contabil eu coloco 1 ponto e virgula a mais nas linhas de dados
					cBuffer += ";"
				EndIf
				
				nCols := 0
				For n := 1 To Len(cBuffer)
					If SubStr(cBuffer,n,1) == ";"
						nCols++
					EndIf
				Next
				
			Else
				lReturn := .F.
				Return
			EndIf
		EndIf
	EndIf
	If nCols <> nColsCabec
		MsgStop("ERRO: O cabecalho tem " + cValToChar(nColsCabec) + " colunas!" + Chr(13) + Chr(10) + ;
		"A linha " + cValToChar(nLine) + " tem " + cValToChar(nCols) + " colunas!","IMPCONTB")
		lReturn := .F.
		Return
	EndIf
	
	nPos := 1
	While At(";",cBuffer) > 0
		cLinhaOk := SubStr(cBuffer,1,At(";",cBuffer) - 1)
		cLinhaOk := StrTran(cLinhaOk,Chr(160),Chr(32)) // Alteracao quando houver CHR160
		&(aCampos[nPos,3]) := cLinhaOk // Macrosubstituicao
		cBuffer := SubStr(cBuffer,At(";",cBuffer) + 1,Len(cBuffer) - At(";",cBuffer) + 1)
		nPos++
	End
	
	If nImport == 2 // Importacao Folha RM (nao existem as variaveis cCCD e cCCC)
		cCCD := ""
		cCCC := ""
	EndIf
	
	// Ajustes dos Centros de Custo quanto a zeros
	If nZerosCC > 0
		If !Empty(cCCD)
			cCCD := Replicate("0",nZerosCC - Len(AllTrim(cCCD))) + AllTrim(cCCD)
		EndIf
		If nImport == 1 .And. !Empty(cCCC) // So verifico CCC se for importacao Contabil (1=Contabil 2=FolhaRM)
			cCCC := Replicate("0",nZerosCC - Len(AllTrim(cCCC))) + AllTrim(cCCC)
		Else
			cCCC := ""
		EndIf
	EndIf
	
	// Ajustes dos Itens Contabeis quanto a zeros
	If nZerosIT > 0 .And. nImport == 1 // So verifico importacao Contabil
		If !Empty(cItemD)
			cItemD := Replicate("0",nZerosIT - Len(AllTrim(cItemD))) + AllTrim(cItemD)
		EndIf
		If !Empty(cItemC)
			cItemC := Replicate("0",nZerosIT - Len(AllTrim(cItemC))) + AllTrim(cItemC)
		EndIf
	Else
		cItemD := ""
		cItemC := ""
	EndIf
	
	// Ajustes das Classes de Valor quanto a zeros
	If nZerosCL > 0 .And. nImport == 1 // So verifico importacao contabil
		If !Empty(cClasseDeb)
			cClasseDeb := Replicate("0",nZerosCL - Len(AllTrim(cClasseDeb))) + AllTrim(cClasseDeb)
		EndIf
		If !Empty(cClasseCrd)
			cClasseCrd := Replicate("0",nZerosCL - Len(AllTrim(cClasseCrd))) + AllTrim(cClasseCrd)
		EndIf
	Else
		cClasseDeb := ""
		cClasseCrd := ""
	EndIf
	
	// Validacao da data com data contabil e calendario
	dData := CtoD(cData)
	If ValType(zGetMv("MV_DATAFIS")) == "D"
		dDataFis := zGetMv("MV_DATAFIS")
	ElseIf ValType(zGetMv("MV_DATAFIS")) == "D"
		dDataFis := DtoS(zGetMv("MV_DATAFIS"))
		If dDataFis == CtoD("")
			MsgStop("Problema no parametro MV_DATAFIS" + Chr(13) + Chr(10) + ;
			"Parametro possui data invalida!")
			lReturn := .F.
			Return
		EndIf
	Else
		MsgStop("Problema no parametro MV_DATAFIS" + Chr(13) + Chr(10) + ;
		"Parametro esta com tipo de dado invalido!")
		lReturn := .F.
		Return
	EndIf
	If dData == CtoD("")
		MsgStop("Data invalida na linha " + cValToChar(nLine))
		lReturn := .F.
		Return
//	ElseIf dData < dDataFis
//		MsgStop("Data menor que MV_DATAFIS na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
//		"Data: " + DtoC(dData) + " Verifique o parametro!")
//		lReturn := .F.
//		Return // Erro da Dulcineide
	Else
		DbSelectArea("CTG") // Calendario Contabil
		DbSetOrder(1) // FILIAL + CALEND + EXEC + PERIODO
		CTG->(DbGotop())
		nCalend := 0
		While CTG->(!EOF())
			If CTG->CTG_DTINI <= dData .And. CTG->CTG_DTFIM >= dData // Encontrou periodo
				If CTG->CTG_STATUS == "1" // Aberto
					nCalend := 1 // Aberto
					Exit
				Else
					nCalend := 2 // Localizado mas nao esta aberto
				EndIf
			EndIf
			CTG->(DbSkip())
		End
		If nCalend == 0
			MsgStop("O Calendario contabil (CTG) nao foi encontrado " + Chr(13) + Chr(10) + ;
			"para o periodo do lancamento na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + "Data: " + DtoC(dData))
			lReturn := .F.
			Return
		ElseIf nCalend == 2
			MsgStop("O Calendario contabil (CTG) esta bloqueado " + Chr(13) + Chr(10) + ;
			"para o periodo do lancamento na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
			"Data: " + DtoC(dData))
			lReturn := .F.
			Return
		EndIf
		
		// Validacao do Calendario com a Moeda Contabil
		lCalendOK := .F.
		lMoedaOK := .F.
		DbSelectArea("CTE")
		DbSetOrder(1)
		CTE->(DbGotop())
		While CTE->(!EOF())
			If CTE->CTE_CALEND == CTG->CTG_CALEND // Existe Moeda amarrada ao calendario
				lCalendOK := .T.
				If CTE->CTE_MOEDA == "01" // Real
					lMoedaOK := .T.
				EndIf
				Exit
			EndIf
			CTE->(DbSkip())
		End
		If !lCalendOK
			MsgStop("Calendario Contabil nao esta amarrado a uma moeda contabil!","IMPCONTB")
			lReturn := .F.
			Return
		ElseIf !lMoedaOK
			MsgStop("Moeda amarrada ao calendario " + CTG->CTG_CALEND + " deve ser '01'=Real!" + Chr(13) + Chr(10) + ;
			"Moeda amarrada: " + CTE->CTE_MOEDA,"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
		
		If dDataPrev <> dData .And. dDataPrev <> CtoD("  /  /  ") // Data diferente, vemos valor Debs e Creds
			If nDebs <> nCreds
				MsgStop("Validacao concluida com totais invalidos!" + Chr(13) + Chr(10) + ;
				"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
				"Creditos: " + cValToChar(nCreds),"IMPCONTB")
				// lReturn := .F. // ALTERACAO TEMPORARIA 01/03/2014
				// Return // ALTERACAO TEMPORARIA 01/03/2014
			Else
		   //		MsgInfo("Data " + DtoC(dDataPrev) + " com totais validos!" + Chr(13) + Chr(10) + ;
			//	"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
			//	"Creditos: " + cValToChar(nCreds),"IMPCONTB")
				nLinha := 1
				nDebs := 0
				nCreds := 0
			EndIf
		EndIf
		dDataPrev := dData
	EndIf
	
	// Validacao do Lote
	If Len(AllTrim(cLote)) > 6
		MsgStop("Tamanho do campo Lote deve ser no maximo 6 caracteres na linha " + cValToChar(nLine))
		lReturn := .F.
		Return
	ElseIf ztipo(AllTrim(cLote)) <> "N" .And. !Empty(cLote)
		MsgStop("'Lote' deve ser um numero na linha " + cValToChar(nLine))
		lReturn := .F.
		Return
	Else // Lote esta de acordo
		If Empty(cLote)
			If nLine == 1 // Primeira linha de dados (Linha 1 eh do cabecalho)
				cLoteAll := cCodUsr
				MsgInfo("Nao foi preenchido o campo 'Lote' no arquivo!" + Chr(13) + Chr(10) + ;
				"Sera usado o cod. do usuario protheus " + cLote + " como 'Lote'")
				cLote := cCodUsr
			ElseIf nLine > 2
				cLote := cLoteAll
			EndIf
		Else
			If nLine == 1 // Primeira linha de dados (Linha 1 eh do cabecalho), mas a planilha tem lote preenchido
				cLote := Replicate("0",6 - Len(AllTrim(cLote))) + AllTrim(cLote)
				// MsgInfo("Foi preenchido o campo 'Lote' na primeira linha!" + Chr(13) + Chr(10) + ;
				// "O 'Lote' " + cLote + " sera usado em todas as linhas!")
				cLoteAll := cLote
			Else
				cLote := cLoteAll
			EndIf
		EndIf
	EndIf
	
	// Validacao do SubLote
	// (Nao ha validacao neste sublote, apenas '001'
	cSubLote := "001"
	
	If Len(AllTrim(cDoc)) > 6
		MsgStop("Tamanho do campo Doc deve ser no maximo 6 caracteres na linha " + cValToChar(nLine))
		lReturn := .F.
		Return
	ElseIf ztipo(AllTrim(cDoc)) <> "N" .And. !Empty(cDoc)
		MsgStop("'Doc' deve ser um numero na linha " + cValToChar(nLine))
		lReturn := .F.
		Return
	Else // Lote esta valido
		// Validacao do Documento
		If Empty(cDoc)
			If nLine == 1 .Or. (nDebs == 0 .And. nCreds == 0) // Primeira linha de dados (Linha 1 eh do cabecalho) ou nova data
				cDocAll := "999001"
				cDoc := cDocAll
				
				If !DOCOK(cDoc,dData,cLoteAll)
					While !DOCOK(cDoc,dData,cLoteAll) .And. cDoc < "999999"
						cDoc := Soma1(cDoc,6)
					End
					If cDoc == "999999"
						MsgStop("Nao ha numero de documento valido na data " + DtoC(dData) + "!" + Chr(13) + Chr(10) + ;
						"Nao foi possivel validar o processo!")
						lReturn := .F.
						Return
					EndIf
					cDocAll := cDoc
				EndIf
				
				MsgInfo("Nao foi preenchido o campo 'Doc' no arquivo!" + Chr(13) + Chr(10) + ;
				"Sera usado o documento " + cDoc + " como 'Doc'")
			Else
				cDoc := cDocAll
			EndIf
		Else
			If nLine == 1 .Or. (nDebs == 0 .And. nCreds == 0) // Primeira linha de dados (Linha 1 eh do cabecalho), mas a planilha tem doc preenchido ou nova data
				cDoc := Replicate("0",6 - Len(AllTrim(cDoc))) + AllTrim(cDoc)
				If !DOCOK(cDoc,dData,cLoteAll)
					MsgInfo("'Doc' digitado na data " + DtoC(dData) + " ja existe e nao pode ser usado!" + Chr(13) + Chr(10) + ;
					"Doc sera recalculado...","IMPCONTB")
					While !DOCOK(cDoc,dData,cLoteAll) .And. cDoc < "999999"
						cDoc := Soma1(cDoc,6)
					End
					If cDoc == "999999"
						MsgStop("Nao ha numero de documento valido na data " + DtoC(dData) + "!" + Chr(13) + Chr(10) + ;
						"Nao foi possivel validar o processo!")
						lReturn := .F.
						Return
					EndIf
					MsgInfo("Foi recalculado o 'Doc' para " + cDoc + " e este sera usado na data " + DtoC(dData) + "!")
				Else
//					MsgInfo("Foi preenchido o campo 'Doc' na primeira linha!" + Chr(13) + Chr(10) + ;
//					"O 'Doc' " + cDoc + " sera usado na data " + DtoC(dData) + "!")
				EndIf
				cDocAll := cDoc
			Else
				cDoc := cDocAll
			EndIf
		EndIf
	EndIf
	
	// Validacao da filial do arquivo quando em importacao FolhaRM
	If nImport == 2 .And. nLine == 1 // Primeira linha em importacao FolhaRM (VERIFICAR EMPRESA / FILIAL)
		If !MsgYesNo("Importacao sera feita na empresa " + SM0->M0_NOME + " " + SM0->M0_FILIAL + Chr(13) + Chr(10) + ;
			"Confirma?","IMPCONTB")
			lReturn := .F.
			Return
		EndIf
		/*
		If cFili == "20" .And. cEmpAnt == "02" // Arquivo da Grancarga
		If !MsgYesNo("Empresa do arquivo: 02=Grancarga" + Chr(13) + Chr(10) + ;
		"Empresa logada: 02=Grancarga" + Chr(13) + Chr(10) + ;
		"Confirma?","IMPCONTB")
		lReturn := .F.
		Return
		EndIf
		ElseIf cFili == "10" .And. cEmpAnt == "01" // Arquivo da Irga
		If !MsgYesNo("Empresa do arquivo: 02=Grancarga" + Chr(13) + Chr(10) + ;
		"Empresa logada: 02=Grancarga" + Chr(13) + Chr(10) + ;
		"Confirma?","IMPCONTB")
		lReturn := .F.
		Return
		EndIf
		Else
		MsgStop("Empresa do arquivo nao confere com empresa logada!" + Chr(13) + Chr(10) + ;
		"Verifique o campo FILIAL","IMPCONTB")
		lReturn := .F.
		Return
		EndIf
		*/
	EndIf
	
	// Validacao da Linha
	// (Nao ha validacao nesta linha, segue sequencia
	If !Empty(cLinha)
		If nLine == 1
			MsgInfo("A 'Linha' do lancamento foi digitada mas nao sera considerada no processo!" + Chr(13) + Chr(10) + ;
			"A linha sequencial conforme quantidade de linhas sera utilizada!")
		EndIf
	EndIf
	cLinha := StrZero(nLinha++,3)
	
	// Validacao do Valor
	cValor := StrTran(cValor,".","")
	If ztipo(StrTran(cValor,",",".")) <> "N"
		MsgStop("Valor deve ser numerico na linha " + cValToChar(nLine),"IMPCT2")
		lReturn := .F.
		Return
	Else
		nValor := Val(StrTran(cValor,",","."))
		If nValor <= 0
			MsgStop("Valor deve ser maior que 0 na linha " + cValToChar(nLine),"IMPCT2")
			lReturn := .F.
		EndIf
	EndIf
	
	// Validacao das contas
	If Empty(cDebito) .And. Empty(cCredito)
		MsgStop("Contas Debito e Credito nao preenchidas na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
		"Deve haver pelo menos uma dela preenchida!","IMPCONTB")
		lReturn := .F.
		Return
	EndIf
	If AllTrim(cDebito) == AllTrim(cCredito)
		MsgStop("Contas Debito e Credito nao podem ser iguais linha " + cValToChar(nLine),"IMPCONTB")
		lReturn := .F.
		Return
	EndIf
	
	// Validacao da Conta Debito
	If !Empty(cDebito)
		cDebito := PadR(AllTrim(cDebito),nTamCT1)
		nConta := CONTAOK(cDebito)
		If nConta == 2 // Nao Encontrada
			MsgStop("A conta debito " + cDebito + " nao encontrada no CT1 na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nConta == 3 // Bloqueada
			MsgStop("A conta debito " + AllTrim(CT1->CT1_CONTA) + " esta bloqueada no CT1 na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nConta == 4 // Conta Sintetica
			MsgStop("A conta debito " + AllTrim(CT1->CT1_CONTA) + " e uma conta sintetica no CT1 na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		Else
			nDebs += nValor
		EndIf
		
		// Correcao para centros de custo quando na importacao de folha RM
		If nImport == 2
			If Left(cDebito,1) <> "3" // Conta Debito nao eh 3
				cCCD := ""
			Else
				cCCD := cCusto
				cCCD := Replicate("0",nZerosCC - Len(AllTrim(cCCD))) + AllTrim(cCCD)
			EndIf
		EndIf
		
		// Amarracoes da contas debito com Ccusto, Item Contabil e Classe de Valor
		If CT1->CT1_CCOBRG == "1" // Centro de Custo Obrigario
			If Empty(cCCD)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com C.Custo nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter centro de custo digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ITOBRG == "1" // Item Contabil Obrigatorio
			If Empty(cItemD)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com Item Contabil nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter item contabil digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_CLOBRG == "1" // Classe de Valor Obrigatoria
			If Empty(cClasseDeb)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com Classe de Valor nao preenchida na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter classe de valor digitada obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACCUST == "2" // Centro de Custo nao aceito
			If !Empty(cCCD)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com C.Custo digitado na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita centro de custo digitado!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACITEM == "2" // Item Contabil Obrigatorio
			If !Empty(cItemD)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com Item Contabil digitado na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita item contabil digitado!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACCLVL == "2" // Classe de Valor Obrigatoria
			If !Empty(cClasseDeb)
				MsgStop("Conta Deb " + AllTrim(CT1->CT1_CONTA) + " com Classe de Valor digitada na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita classe de valor digitada!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		EndIf
	Else
		// Conta Debito nao digitada
	EndIf
	
	// Validacao da Conta Credito
	If !Empty(cCredito)
		cCredito := PadR(AllTrim(cCredito),nTamCT1)
		nConta := CONTAOK(cCredito)
		If nConta == 2 // Nao Encontrada
			MsgStop("A conta credito " + cCredito + " nao encontrada no CT1 (Plano de Contas) na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nConta == 3 // Bloqueada
			MsgStop("A conta credito " + AllTrim(CT1->CT1_CONTA) + " esta bloqueada no CT1 (Plano de Contas) na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nConta == 4 // Conta Sintetica
			MsgStop("A conta credito " + AllTrim(CT1->CT1_CONTA) + " e uma conta sintetica no CT1 na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		Else
			nCreds += nValor
		EndIf
		
		// Correcao para centros de custo quando na importacao de folha RM
		If nImport == 2
			If Left(cCredito,1) <> "3" // Conta credito nao eh 3
				cCCC := ""
			Else
				cCCC := cCusto
				cCCC := Replicate("0",nZerosCC - Len(AllTrim(cCCC))) + AllTrim(cCCC)
			EndIf
		EndIf
		
		// Amarracoes da contas debito com Ccusto, Item Contabil e Classe de Valor
		If CT1->CT1_CCOBRG == "1" // Centro de Custo Obrigario
			If Empty(cCCC)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com C.Custo nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter centro de custo digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ITOBRG == "1" // Item Contabil Obrigatorio
			If Empty(cItemC)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com Item Contabil nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter item contabil digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_CLOBRG == "1" // Classe de Valor Obrigatoria
			If Empty(cClasseCrd)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com Classe de Valor nao preenchida na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta deve ter classe de valor digitada obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACCUST == "2" // Centro de Custo nao aceito
			If !Empty(cCCC)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com C.Custo digitado! na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita centro de custo digitado!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACITEM == "2" // Item Contabil Obrigatorio
			If !Empty(cItemC)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com Item Contabil digitado na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita item contabil digitado!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CT1->CT1_ACCLVL == "2" // Classe de Valor Obrigatoria
			If !Empty(cClasseCrd)
				MsgStop("Conta Crd " + AllTrim(CT1->CT1_CONTA) + " com Classe de Valor digitada na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Esta conta nao aceita classe de valor digitada!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		EndIf
	Else
		// Conta Credito nao digitada
	EndIf
	
	// Validacao do Historico
	If ValType(cHistorico) <> "C"
		MsgStop("Historico deve ser caractere na linha " + cValToChar(nLine),"IMPCONTB")
		lReturn := .F.
		Return
	ElseIf Empty(cHistorico)
		MsgStop("Historico nao pode estar vazio na linha " + cValToChar(nLine),"IMPCONTB")
		lReturn := .F.
		Return
	Else
		cHistorico := Upper(fTAcento(cHistorico))
	EndIf
	
	// Validacao do CCD
	If !Empty(cCCD)
		cCCDOrig := AllTrim(cCCD)
		cCCD := PadR(AllTrim(cCCD),nTamCTT)
		nCusto := CCUSTOOK(cCCD,dData)
		
		// Alteracao: Nao achou com 7 caracteres no Centro de Custo, verificar entao com 6 caracteres
		If nCusto == 2 // Nao encontrado
			cCCD := PadR(StrZero(Val(cCCD),6),nTamCTT)
			nCusto := CCUSTOOK(cCCD,dData)
		EndIf
		// Fim da alteracao
		
		If nCusto == 2 // Nao encontrado
			cCCD := PadR(AllTrim(cCCD),6)
			MsgStop("Centro de Custo debito " + cCCDOrig + " nao encontrado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nCusto == 3 // Bloqueado
			MsgStop("Centro de Custo debito " + cCCDOrig + " bloqueado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nCusto == 4 // Bloqueado no periodo
			MsgStop("Centro de Custo debito " + cCCDOrig + " bloqueado no periodo na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
		
		If CTT->CTT_ITOBRG == "1" // Item Contabil Obrigatorio
			If Empty(cItemD)
				MsgStop("Ccusto Deb " + AllTrim(CTT->CTT_CUSTO) + " com Item Contabil nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Este Ccusto deve ter item contabil digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CTT->CTT_CLOBRG == "1" // Classe de Valor Obrigatoria
			If Empty(cClasseDeb)
				MsgStop("Ccusto Deb " + AllTrim(CTT->CTT_CUSTO) + " com Classe de Valor nao preenchida na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Este Ccusto deve ter classe de valor digitada obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		EndIf
		
		// VERIFICACAO NOVA (AMARRACAO CONTA DEBITO COM CENTRO DE CUSTO DEBITO)
		CONTAOK(cDebito)
		If !Empty(CT1->CT1_RGNV1) .And. !Empty(CTT->CTT_CRGNV1) .And. CT1->CT1_RGNV1 <> CTT->CTT_CRGNV1
			MsgStop("Amarracao debito incorreta na Linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
			"Conta: " + cDebito + Chr(13) + Chr(10) + ;
			"Ccusto: " + CTT->CTT_CUSTO)
			lReturn := .F.
			Return
		EndIf
		
	EndIf
	
	// Validacao do CCC
	If !Empty(cCCC) // So verifico importacao Contabil
		cCCCOrig := AllTrim(cCCC)
		cCCC := PadR(AllTrim(cCCC),nTamCTT)
		nCusto := CCUSTOOK(cCCC,dData)
		
		// Alteracao: Nao achou com 7 caracteres no Centro de Custo, verificar entao com 6 caracteres
		If nCusto == 2 // Nao encontrado
			cCCC := PadR(StrZero(Val(cCCC),6),nTamCTT)
			nCusto := CCUSTOOK(cCCC,dData)
		EndIf
		// Fim da alteracao
		
		If nCusto == 2 // Nao encontrado
			MsgStop("Centro de Custo credito " + cCCCOrig + " nao encontrado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nCusto == 3 // Bloqueado
			MsgStop("Centro de Custo credito " + cCCCOrig + " bloqueado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		ElseIf nCusto == 4 // Bloqueado no periodo
			MsgStop("Centro de Custo credito " + cCCCOrig + " bloqueado no periodo na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
		
		If CTT->CTT_ITOBRG == "1" // Item Contabil Obrigatorio	A
			If Empty(cItemC)
				MsgStop("Ccusto Crd " + AllTrim(CTT->CTT_CUSTO) + " com Item Contabil nao preenchido na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Este Ccusto deve ter item contabil digitado obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		ElseIf CTT->CTT_CLOBRG == "1" // Classe de Valor Obrigatoria
			If Empty(cClasseCrd)
				MsgStop("Ccusto Crd " + AllTrim(CTT->CTT_CUSTO) + " com Classe de Valor nao preenchida na linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
				"Este Ccusto deve ter classe de valor digitada obrigatoriamente!","IMPCONTB")
				lReturn := .F.
				Return
			EndIf
		EndIf
		
		// AMARRACAO NOVA 2
		CONTAOK(cCredito)
		If !Empty(CT1->CT1_RGNV1) .And. !Empty(CTT->CTT_CRGNV1) .And. CT1->CT1_RGNV1 <> CTT->CTT_CRGNV1
			MsgStop("Amarracao debito incorreta na Linha " + cValToChar(nLine) + Chr(13) + Chr(10) + ;
			"Conta: " + cCredito + Chr(13) + Chr(10) + ;
			"Ccusto: " + CTT->CTT_CUSTO)
			lReturn := .F.
			Return
		EndIf
		
	EndIf
	
	// Validacao do Item Contabil Debito
	If nImport == 1 .And. !Empty(cItemD) // So verifico importacao Contabil
		cItemD := PadR(AllTrim(cItemD),nTamCTD)
		nItem := ITEMOK(cItemD)
		If nItem == 2 // Nao encontrado
			MsgStop("Item contabil debito " + cItemD + " nao encontrado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
	EndIf
	
	// Validacao do Item Contabil Credito
	If nImport == 1 .And. !Empty(cItemC) // So verifico importacao contabil
		cItemC := PadR(AllTrim(cItemC),nTamCTD)
		nItem := ITEMOK(cItemC)
		If nItem == 2 // Nao encontrado
			MsgStop("Item contabil credito " + cItemC + " nao encontrado na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
	EndIf
	
	// Validacao da Classe Valor Debito
	If nImport == 1 .And. !Empty(cClasseDeb) // So verifico importacao contabil
		cClasseDeb := PadR(AllTrim(cClasseDeb),nTamCTH)
		nClasse := CLASSEOK(cClasseDeb)
		If nClasse == 2 // Nao encontrado
			MsgStop("Classe contabil debito " + cClasseDeb + " nao encontrada na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
	EndIf
	
	// Validacao da Classe Valor Credito
	If nImport == 1 .And. !Empty(cClasseCrd) // So verifico importacao contabil
		cClasseCrd := PadR(AllTrim(cClasseCrd),nTamCTH)
		nClasse := CLASSEOK(cClasseCrd)
		If nClasse == 2 // Nao encontrado
			MsgStop("Classe contabil credito " + cClasseCrd + " nao encontrada na linha " + cValToChar(nLine),"IMPCONTB")
			lReturn := .F.
			Return
		EndIf
	EndIf
	
	IncProc('Processando ...' + cValToChar(nLine) + " / " + cValToChar(nTotLines))
	aAdd(aLancs, {dData,cLote,cSubLote,cDoc,cLinha,nValor,cDebito,cCredito,cHistorico,cCCD,cCCC,cItemD,cItemC,cClasseDeb,cClasseCrd})
	FT_FSkip()
End
If nDebs <> nCreds
	MsgInfo("Validacao concluida com totais invalidos!" + Chr(13) + Chr(10) + ;
	"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
	"Creditos: " + cValToChar(nCreds),"IMPCT2")
	//lReturn := .F.  // ALTERACAO TEMPORARIA 01/03/2014
	//Return  // ALTERACAO TEMPORARIA 01/03/2014
EndIf
If !MsgYesNo("Data " + DtoC(dData) + " com totais validos! Prossegue?" + Chr(13) + Chr(10) + ;
	"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
	"Creditos: " + cValToChar(nCreds),"IMPCONTB")
	lReturn := .F.
	Return
Else // Inicio do processamento, tela de lancamentos
	aProc := XIMPTELA(aLancs)
	If Len(aProc) == 0 // Nao houve itens selecionados para processamento
		//ConOut("Processo: MsExecAuto CTBA102 - Cancelado: " + Time())
		U_LogAlteracoes("CTBA102","Processo: MsExecAuto - Cancelado")
		MsgAlert("A importacao nao foi concluida pois nao foi selecionado nenhum lancamento!","IMPCONTB")
		lReturn := .F.
		Return
	Else
		If !MsgYesNo("Confirma marcados?")
			lReturn := .F.
			Return
		Else
			// Validar debitos/creditos por data sequencial antes de iniciar
		EndIf
	EndIf
EndIf

aItens := {}
nDebs := 0
nCreds := 0
aLancs := aProc // Alteracao
dData := CtoD("  /  /  ")
ProcRegua(Len(aLancs))
For n := 1 To Len(aLancs)
	IncProc()
	If aLancs[n,1] <> dData // If TRB->CT2_DATA <> dData
		If Len(aItens) > 0
			If nDebs <> nCreds
				MsgStop("Erro nos totais Debito x Credito" + ;
				"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
				"Creditos: " + cValToChar(nCreds))
			Else
				lMsErroAuto := .F.
				lMsHelpauto := .T.
				MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
				If lMserroAuto
					MostraErro()
				EndIf
				aItens := {}
				nDebs := 0
				nCreds := 0
			EndIf
		EndIf
		aCab := { {'DDATALANC' 		,aLancs[n,1]			,NIL},; // DATA
		{'CLOTE'					,aLancs[n,2]			,NIL},; // LOTE
		{'CSUBLOTE'			   		,aLancs[n,3]			,NIL},; // SUBLOTE
		{'CDOC'				   		,aLancs[n,4]			,NIL},; // DOC
		{'CPADRAO'			   		,''						,NIL},;
		{'NTOTINF'			  		,0						,NIL},;
		{'NTOTINFLOT'		  		,0						,NIL} }
	EndIf
	
	// aAdd(aLancs, {dData,cLote,cSubLote,cDoc,cLinha,nValor,cDebito,cCredito,cHistorico,cCCD,cCCC,cItemD,cItemC,cClasseDeb,cClasseCrd})
	dData := aLancs[n,1]
	nValor := aLancs[n,6]
	cDebito := aLancs[n,7]
	cCredit := aLancs[n,8]
	cHistorico := aLancs[n,9]
	cCCD := aLancs[n,10]
	cCCC := aLancs[n,11]
	cItemD := aLancs[n,12]
	cItemC := aLancs[n,13]
	cClasseDeb := aLancs[n,14]
	cClasseCrd := aLancs[n,15]
	If !Empty(cDebito) .And. !Empty(cCredit)
		cDC := "3"
	ElseIf !Empty(cDebito)
		cDC := "1"
	Else
		cDC := "2"
	EndIf
	If !Empty(cDebito)
		nDebs += nValor
	EndIf
	If !Empty(cCredit)
		nCreds += nValor
	EndIf
	nLinhaLc := StrZero(Len(aItens) + 1,3)
	aAdd(aItens,{{"CT2_MOEDLC"	, "01"	   				, NIL},;
	{"CT2_LINHA"				, nLinhaLc				, NIL},;
	{"CT2_DC"					, cDC					, NIL},;
	{"CT2_DEBITO"  				, cDebito				, NIL},;
	{"CT2_CREDIT"  				, cCredit				, NIL},;
	{"CT2_VALOR"   				, nValor				, NIL},;
	{"CT2_ORIGEM"  				, "IMPCONTB " + DtoC(dDatabase)	, NIL},;
	{"CT2_HP"	  				, ""					, NIL},;
	{"CT2_HIST"	  				, cHistorico			, NIL},;
	{"CT2_CCD"	  				, cCCD					, NIL},;
	{"CT2_CCC"	  				, cCCC					, NIL},;
	{"CT2_ITEMD"	  			, cItemD				, NIL},;
	{"CT2_ITEMC"	  			, cItemC				, NIL},;
	{"CT2_CLVDB"	  			, cClasseDeb			, NIL},;
	{"CT2_CLVCR"	  			, cClasseCrd			, NIL}})
Next
If Len(aItens) > 0

	lMsErroAuto := .F.
	lMsHelpauto := .T.
	MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
	If lMserroAuto
		MostraErro()
	EndIf
		
EndIf
//EndIf
Return

//Static Function DOCOK(cDocumento,dDataChk)
Static Function DOCOK(cDocumento,dDataChk,cLote)
Local lRet := .T.
DbSelectArea("CT2")
DbSetOrder(1) // FILIAL + DATA + LOTE + SUBLOTE + DOC
If CT2->(DbSeek(xFilial("CT2") + DtoS(dDataChk) + cLote + "001"))
	While CT2->(!EOF()) .And. CT2->CT2_DATA == dDataChk
		If cLote == CT2->CT2_LOTE .And. cDocumento == CT2->CT2_DOC
			lRet := .F.
			Exit
		EndIf
		CT2->(DbSkip())
	End
EndIf
Return lRet

Static Function CONTAOK(cConta)
Local nOK := 1 // Conta ok
DbSelectArea("CT1")
DbSetOrder(1)
DbGotop()
If CT1->(!DbSeek(xFilial("CT1") + cConta))
	nOK := 2 // Nao encontrada
ElseIf CT1->CT1_BLOQ == "1" // Bloqueada
	nOK := 3 // Bloqueada
ElseIf CT1->CT1_CLASSE <> "2" // Sintetica
	nOK := 4 // Conta Sintetica
EndIf
Return nOK

Static Function CCUSTOOK(cCusto,dData)
Local nRet := 1
DbSelectArea("CTT")
DbSetOrder(1)
If !CTT->(DbSeek(xFilial("CTT") + cCusto)) // Nao encontrado
	nRet := 2
ElseIf CTT->CTT_BLOQ == "1"
	nRet := 3
ElseIf CTT->CTT_DTBLIN >= dData .And. dData <= CTT->CTT_DTBLFI
	nRet := 4
EndIf
Return nRet

Static Function ITEMOK(cItem)
Local nRet := 1
DbSelectArea("CTD")
DbSetOrder(1)
If !CTD->(DbSeek(xFilial("CTD") + cItem))
	nRet := 2
EndIf
Return nRet

Static Function CLASSEOK(cClasse)
Local nRet := 1
DbSelectArea("CTH")
DbSetOrder(1)
If !CTH->(DbSeek(xFilial("CTH") + cClasse))
	nRet := 2
EndIf
Return nRet

Static Function XIMPTELA(aLancament) // Data, Lote, Sublote, Doc, Linha, Debito, Credito, Valor, CCD, CCC, ITEMD, ITEMC, CLASSEDEB, CLASSECRD // {cForn,cLoja,cProd,cCond,cContato,nQuant,cCodICS,nValor,cTes}
Private oOk         := LoadBitmap(GetResources(),"LBOK")
Private oNo   	    := LoadBitmap(GetResources(),"LBNO")
Private oBmp		:= Nil
Private oDialog 	:= Nil
Private lMarcados	:= .F.
Private lTodos		:= .F.
Private oLbx		:= {}
Private cCadastro	:= "Confirmacao da importacao"
Private aLst		:= {}
Private lRet	    := .T.
Private lPermitido  := .T.
For l := 1 To Len(aLancament)
	cFil := cFilAnt
	cData := aLancament[l,1]
	cLote := aLancament[l,2]
	cSubLote := aLancament[l,3]
	cDoc := aLancament[l,4]
	cLinha := aLancament[l,5]
	cValor := ChkValor(aLancament[l,6])
	cDebito := aLancament[l,7]
	cCredito := aLancament[l,8]
	cHist := aLancament[l,9]
	cCCD := aLancament[l,10]
	cCCC := aLancament[l,11]
	cItemD := aLancament[l,12]
	cItemC := aLancament[l,13]
	cClasseDeb := aLancament[l,14]
	cClasseCrd := aLancament[l,15]
	aAdd(aLst, {.T., cFil, cData, cLote, cSubLote, cDoc, cLinha, cDebito, cCredito, cValor, cCCD, cCCC, cItemD, cItemC, cClasseDeb, cClasseCrd })
Next
lLoop := .T.
lOk := .F.
While lLoop
	Define MsDialog oDialog FROM 178,181 To 573,1010 Title "Confirmacao" Pixel
	@003,003 ListBox oLbx Fields HEADER "", "Fil","Data","Lote","SubLote","Doc","Linha","Debito","Credito","Valor","Ccusto Deb","Ccusto Crd","ItemD","ItemC","ClasseDeb","ClasseCrd" ColSizes 010,010,020,025,024,016,018,015,018,015,018,018,015,015,015,015 Size 410,183 Of oDialog Pixel On DBLCLICK (MarcarREGI(.F.))
	oLbx:SetArray(aLst)
	oLbx:bLine := { || { If(aLst[oLbx:nAt,01],oOk,oNo), aLst[oLbx:nAt,02], aLst[oLbx:nAt,03], aLst[oLbx:nAt,04], aLst[oLbx:nAt,05], aLst[oLbx:nAt,06], aLst[oLbx:nAt,07], aLst[oLbx:nAt,08], aLst[oLbx:nAt,09], aLst[oLbx:nAt,10], aLst[oLbx:nAt,11], aLst[oLbx:nAt,12], aLst[oLbx:nAt,13], aLst[oLbx:nAt,14], aLst[oLbx:nAt,15], aLst[oLbx:nAt,16] } }
	oLbx:nFreeze := 1
	@000,000 BitMap oBmp RESNAME "PROJETOAP" Of oDialog Size 000,180 NOBORDER When .F. Pixel
	@188,170 Button "OK" Size 037,012 Pixel Of oDialog Action (Processa({|| lOk := XIMPOK(), Iif(lOK,oDialog:End(),cTeste:="") },"Aguarde... Processando."))
	@188,220 Button "Inverte Sel" Size 037,012 Pixel Of oDialog Action MARCKALL()
	@188,270 Button "Cancelar" Size 037,012 Pixel Of oDialog Action (lOk := .T., aLst := {},oDialog:End())
	Activate MsDialog oDialog Centered
	If lOk = .T.
		lLoop = .F.
	Else
		lOk = .F.
	EndIf
End
aLancOK := {}
For n := 1 To Len(aLst)
	If aLst[n,1]
		aAdd(aLancOK,aLancament[n])
	EndIf
Next
Return aLancOK

Static Function XIMPOK()
Local lRet := .F.
For n := 1 To Len(aLst)
	If aLst[n,1]
		lRet := .T.
		Exit
	EndIf
Next
If !lRet
	If MsgYesNo("Nenhum lancamento foi selecionado!" + Chr(13) + Chr(10) + "Nenhum registro sera incluido no sistema, continua?","IMPCONTB")
		lRet := .T.
	EndIf
EndIf
If !lPermitido
	MsgStop("Nao sera permitida a importacao pois ha diferenca entre Debs e Creds!" + Chr(13) + Chr(10) + ;
	"Verifique os debitos e creditos nos lancamentos nas datas!","IMPCONTB")
	lRet := .F.
Else
	dDate := CtoD("")
	nDebs := 0
	nCreds := 0
	For n := 1 To Len(aLst)
		If aLst[n,1]
			If aLst[n,3] <> dDate
				If nDebs <> nCreds
					MsgStop("Total de Debitos <> Creditos no dia " + DtoC(dDate) + Chr(13) + Chr(10) + ;
					"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
					"Creditos: " + cValToChar(nCreds),"IMPCONTB")
					lPermitido := .F.
				EndIf
			EndIf
			dDate := aLst[n,3]
			If !Empty(aLst[n,8]) // Conta debito
				nDebs := Val(aLst[n,10])
			EndIf
			If !Empty(aLst[n,9]) // Conta credito
				nCreds := Val(aLst[n,10])
			EndIf
		EndIf
	Next
EndIf
Return lRet

Static Function MarcarREGI()
Local dDate := CtoD("")
Local nDebs := 0
Local nCreds := 0
aLst[oLbx:nAt,1] := !aLst[oLbx:nAt,1]
oLbx:Refresh(.T.)
oDialog:Refresh(.T.)
oBmp:Refresh(.T.)
lPermitido := .T.
For n := 1 To Len(aLst)
	If aLst[n,1]
		If aLst[n,3] <> dDate
			If nDebs <> nCreds
				MsgStop("Total de Debitos <> Creditos no dia " + DtoC(dDate) + Chr(13) + Chr(10) + ;
				"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
				"Creditos: " + cValToChar(nCreds),"IMPCONTB")
				lPermitido := .F.
			EndIf
		EndIf
		dDate := aLst[n,3]
		If !Empty(aLst[n,8]) // Conta debito
			nDebs += Val(aLst[n,10])
		EndIf
		If !Empty(aLst[n,9]) // Conta credito
			nCreds += Val(aLst[n,10])
		EndIf
	EndIf
Next
If nDebs <> nCreds
	MsgStop("Total de Debitos <> Creditos no dia " + DtoC(dDate) + Chr(13) + Chr(10) + ;
	"Debitos: " + cValToChar(nDebs) + Chr(13) + Chr(10) + ;
	"Creditos: " + cValToChar(nCreds),"IMPCONTB")
	lPermitido := .F.
EndIf
Return

Static Function ChkValor(nValorOK)
Local cValorOK := cValToChar(nValorOK)
If At(".",cValorOK) == 0
	cValorOK += ".00"
ElseIf Len(cValorOK) - At(".",cValorOK) == 1
	cValorOK += "0"
EndIf
Return Replicate(" ",17 - (Len(cValorOK) * 2)) + cValorOK

Static Function MARCKALL()
For n := 1 To Len(aLst)
	If aLst[n,1]
		aLst[n,1] := .F.
	Else
		aLst[n,1] := .T.
	EndIf
Next
Return
