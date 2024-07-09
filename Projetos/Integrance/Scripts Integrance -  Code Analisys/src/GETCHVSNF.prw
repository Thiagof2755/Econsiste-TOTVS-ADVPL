#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ GETCHVSNF ºAutor ³ Cristiam Rossi     º Data ³  24/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Diálogo p/ obter Chave NF-e de Saída e chamar MATA410      º±±
±±º          ³ *parte XML Saída - ECCO*                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRevisao   ³                Jonathan Schmidt Alves º Data ³  29/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ITUP / ECCO                                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GETCHVSNF(xPar1, xPar2, xPar3, xPar4, xPar5)
Local oDlg
Local oChave
Local cChave := Space(50)
Local oFont
Local xRet := .T.
Local xDtBase := dDatabase
Local oButton
Local cArqTrab := ""
Private lQuiet := .F.
Private oPanel
Private oSay
Private cFile
Private cProblema := ""
Private cPathXml := u_PEchvNFE("PATHXML")
Private aChvInfo := {}
Private _tipoNF := ""
Private _vLayout := "" // usado só para Prefeitura de SP
Private cNatNFE := GetMv("MV_XNATNFE")
Private cNatSSN := GetMv("MV_XNATSSN")
Private cNatISS := GetMv("MV_XNATISS")
Private cNatSRT := GetMv("MV_XNATSRT")
Private lImpAut := .F.
Default xPar4 := ""
Default xPar5 := ""
If xPar4 != "LOTE"
	u_CriaTrab(@cArqTrab)
	DEFINE FONT oFont NAME "MonoAs" SIZE 0, -16 BOLD
	DEFINE MSDIALOG oDlg FROM 0,0 TO 125, 400 TITLE "Saída XML" PIXEL
	@005,005 Say "Informe Chave da NF (nome do arquivo):" of oDlg Pixel
	@015,005 Get oChave Var cChave Picture Replicate("X",50) Size 160, 10 Valid iif( fValChv( cChave ), oDlg:End(), nil ) of oDlg Pixel
	@190,300 BUTTON "Nada" SIZE 040,015 OF oDlg PIXEL		// apenas para permitir a mudança de foco no objeto
	@014,168 BUTTON oButton Prompt "Buscar" SIZE 30,13 OF oDlg PIXEL ACTION iif( fVincArq( @cChave ), iif( fValChv( cChave ), oDlg:End(), nil ), nil)
	oPanel := TPanel():New(30, 00, "", oDlg, NIL, .T.,, nil, nil, oDlg:nWidth/2-1, 30)
	tGroup():New(02,04,oPanel:nHeight/2-4, oPanel:nWidth/2-4,"Informações:",oPanel,,,.T.)
	oSay := tSay():New(12,7,{|| cProblema},oPanel,,oFont,,,,.T.,CLR_RED,,oPanel:nWidth/2-7,10)
	ACTIVATE MSDIALOG oDlg CENTERED on init oButton:Click()
Else
	lQuiet := .T.
	fValChv(xPar5)
EndIf
If Len(aChvInfo) > 0
	If _tipoNF == "_CA"
		If lQuiet .Or. MsgNoYes("Deseja continuar com o cancelamento da NF " + aChvInfo[03] + "/" + aChvInfo[04] + "?", "XML Automático")
			If u_CancelNF(.F.)
				If lQuiet	// é lote!
					//Conout("NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!")
					U_LogAlteracoes( "GETCHVSNF" , "NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!")
				Else
					Aviso("NF de Cancelamento", "NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!", {"OK"}, 2)
				EndIf
				u_fMoverArq()
			EndIf
		EndIf
	Else
		If .T. // SuperGetMV("IT_XGERPV",, .F.) // Parametro sempre considerar geracao de Ped Venda e Nota via MaPvlnfs e SE1 conforme a TES
			If lQuiet .Or. lImpAut // é lote ou NF automatica
				xRet := incPV(aChvInfo[3], aChvInfo[4]) // inclusão via Execauto
			Else
				xRet := A410Inclui("SC5", SC5->(Recno()), 3) == 1 // chama Inclusão Pedido de Venda
			EndIf
			If xRet // pedido incluso, vamos faturar
				xRet := u_FatPV(SC5->C5_NUM, aChvInfo[3], aChvInfo[4])
				If !xRet
					MsgStop("Ocorreu falha no faturamento da NF:" + aChvInfo[3] + "/" + aChvInfo[4], "")
				Else
					If SF2->F2_DOC == aChvInfo[3] .and. SF2->F2_SERIE == aChvInfo[4] .and. SF2->F2_CLIENTE == aChvInfo[6] .and. SF2->F2_LOJA == aChvInfo[7]
						// foi cadastrado o XML de Entrada!
						u_fMoverArq()
					EndIf
				EndIf
			EndIf
		Else
			If lQuiet .Or. lImpAut // é lote ou NF automatica
				xRet := IncNfSai()
			Else
				xRet := u_ITXMLMAN() //A920NFSAI("SD2", 0, 3) == 1
			EndIf
			If xRet
				u_fMoverArq()
			EndIf
		EndIf
	EndIf
EndIf
dDatabase := xDtBase
DelClassIntf() // Exclui todas classes de interface da thread
If xPar4 != "LOTE"
	u_killTrab(cArqTrab)
EndIf
Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³fVincArq  ºAutor  ³Cristiam Rossi      º Data ³  22/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Vincula arquivo+localização completa para importação       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO Contabilidade                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fVincArq( cChave )
Local cCmpArq := ""
Local cFolder := ""
cCmpArq := cGetFile('Arquivos (*.xml)|*.xml|Arquivos (*.txt)|*.txt|}' , 'Selecione o Arquivo a ser importado, formatos XML ou TXT',1, getMV("MV_XARQXML"),.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
If Empty(cCmpArq)
	Return .F.
EndIf
cChave := fNomArq(cCmpArq, "\")	// Retorna o nome do arquivo
cFolder := left(cCmpArq, Len(cCmpArq) - Len(cChave))
PutMV("MV_XARQXML", left(cCmpArq, Len(cCmpArq) - Len(cChave)))
Processa({|| aRet := u_PreLoad(cFolder, @cChave, .F. )}, "Aguarde, carregando arquivos da pasta", "Iniciando processo...")
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³fNomArq   ºAutor  ³Cristiam Rossi      º Data ³  22/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna parte do nome do arquivo digitalizado              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fNomArq(cPar, cToken)
Local nPos  := 0
If (nPos := Rat(cToken, StrTran(cPar,"/","\"))) != 0
	cFile := SubStr(cPar, nPos+1)
EndIf
Return cFile

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ fValChv  ºAutor  ³ Cristiam Rossi     º Data ³  09/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação Chave informada (bipada)                         º±±
±±º          ³ Importação XML NF de Entrada                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO Contabilidade                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fValChv(cParamCHV)
Local cChave    := AllTrim(Upper(cParamCHV))
Local cExtensao := ".xml"
Local cXml      := ""
Local aNotas    := {}
Local xTemp
Local lChkDANFE := .F.
Private oXML
Private _cCgcEmi  := ""
Private _cCgcDes  := ""
Private lOpConsFin	:= .F.
If Empty(cChave)
	Return .F.
EndIf
cPathXml := GetMv("MV_XARQXML")
lChkDANFE := u_PesqDANFE(cChave, cPathXml) // Pesquisa Chave
If lChkDANFE
	_tipoNF := "D" // DANFE
	cXml    := XMLTRB->XML
	cFile   := lower( cPathXml + XMLTRB->ARQUIVO )
Else
	cFile   := ""
	If Right(cChave, 4) == ".XML" .Or. Right(cChave, 4) == ".TXT"
		cExtensao := ""
	EndIf
	If File(cPathXml + cChave + cExtensao)
		cFile := Lower(cPathXml + cChave + cExtensao)
	EndIf
	If Empty(cFile)
		If Right( cChave, 4 ) == ".XML"
			If File( cPathXml + strTran( cChave, ".XML", "-procNfe.xml") )
				cFile := lower( cPathXml + strTran(cChave, ".XML","-procNfe.xml") )
			EndIf
		ElseIf cExtensao == ".xml"
			if File( cPathXml + cChave + "-procNfe.xml" )
				cFile := lower( cPathXml + cChave + "-procNfe.xml" )
			EndIf
		ElseIf File( cPathXml + cChave + ".txt" )
			cFile := lower( cPathXml + cChave + ".txt" )
		EndIf
	EndIf
	if Empty(cFile)
		if !lQuiet
			cProblema := "Arquivo não encontrado!"
			oSay:Refresh()
		endif
		return .F.
	endif
	if  ".txt" $ cFile										// Prefeitura
		_tipoNF := "P"
	else
		cXml := U_LeXml( cFile )	  							// Lê XML e retorna conteúdo
		if Empty( cXml )
			if ! lQuiet
				cProblema := "Arquivo XML vazio ou corrompido!"
				oSay:Refresh()
			endif
			aSize( aChvInfo, 0 )
			return .F.
		endif
		If "www.ginfes.com.br" $ lower( cXml )		// Ginfes
			_tipoNF := "G"
		ElseIf "<cteproc" $ lower( cXml )			// CT-e
			_tipoNF := "CTE"
		ElseIf "cancelamento registrado" $ lower( cXml )		// NF - CANCELADA
			_tipoNF := "_CA"
		Else
			_tipoNF := "D"							// DANFE
		EndIf
	endif
endif
if Empty( _tipoNF )
	if ! lQuiet
		cProblema := "formato não identificado!"
		oSay:Refresh()
	endif
	return .F.
endif
// carregar array aChvInfo
// C T - e
if _tipoNF == "CTE"
	aSize(aChvInfo, 30)
	aFill(aChvInfo, "")
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[03] := subStr(cChave,26,09)				// Documento
	aChvInfo[04] := subStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space(Len(SA1->A1_COD))				// Cliente
	aChvInfo[07] := Space(Len(SA1->A1_LOJA))			// Loja
	aChvInfo[08] := "CTE  "					  			// Espécie
	aChvInfo[09] := Space(Len(SA1->A1_EST))				// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[12] := 1									// Finalidade da DANFE - 19/12/2016 - Cristiam
	aChvInfo[15] := u_c2oXML(cXml)						// Carrega XML no Objeto
	If ValType(aChvInfo[15]) != "O"
		If !lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		return .F.
	endif
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT") != "U"	// Numero do Documento
		aChvInfo[03] := replicate("0", 9) + alltrim( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT )
		aChvInfo[03] := right( aChvInfo[03], 9 )
	endif
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT") != "U"	// Série do Documento
		aChvInfo[04] := padr( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT, 3 )
	endif
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_ID:TEXT") != "U"	// Chave CT-e
		aChvInfo[11] := substr(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_ID:TEXT, 4)
	endif
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") != "U"
		xTemp := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
		if xTemp != SM0->M0_CGC
			// DESCOMENTAR NO CLIENTE
			if !lQuiet
				cProblema := "Documento não é pra este CNPJ!"
				oSay:Refresh()
			endif
			aSize(aChvInfo, 0)
			Return .F.
		Endif
	Endif
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dEmi:TEXT , "-", "" ) )
		dDatabase    := aChvInfo[05]
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dhEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( Left( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, 10 ), "-", "" ) )
	EndIf
	If u_TrataSE4()				// Cond.Pagto (default: 000 - a Vista )
		aChvInfo[10] := SE4->E4_CODIGO
	Else
		If !lQuiet
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		return .F.
	EndIf
	cCNPJ := Space(14)
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatário
		cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
	EndIf
	If Empty(AllTrim(cCNPJ))
		If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT") != "U"
			cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT
		EndIf
	EndIf
	SA1->(DbSetOrder(3))
	If SA1->(!DbSeek( xFilial("SA1") + cCNPJ))
		If !u_criarSA1("CTE")
			If !lQuiet
				cProblema := "Não foi possível criar Cliente!"
				oSay:Refresh()
			EndIf
			aSize( aChvInfo, 0 )
			Return .F.
		EndIf
	EndIf
	aChvInfo[06] := SA1->A1_COD				// Cliente
	aChvInfo[07] := SA1->A1_LOJA			// Loja
	aChvInfo[09] := SA1->A1_EST				// UF
	If lChkExist() // Checar existencia da NF se existir informar e bloquear
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	if !u_TrataSB1()		// Tratamento Produtos e Impostos
		If !lQuiet
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	CargaImp()			// carrega Tag Impostos total do XML
EndIf
// D A N F E
if _tipoNF == "D"
	aSize(aChvInfo, 30)
	aFill(aChvInfo, "")
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := "S"									// Formulário Próprio
	aChvInfo[03] := SubStr(cChave,26,09)				// Documento
	aChvInfo[04] := SubStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space(Len(SA1->A1_COD))				// Cliente
	aChvInfo[07] := Space(Len(SA1->A1_LOJA))			// Loja
	aChvInfo[08] := "SPED "					  			// Espécie
	aChvInfo[09] := Space(Len(SA1->A1_EST))				// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[11] := Left(cChave,44)						// Chave DANFE
	aChvInfo[12] := 1									// Finalidade da DANFE (compatibilização) - 19/12/2016 - Cristiam
	aChvInfo[15] := u_c2oXML(cXml)						// Carrega XML no Objeto
	If ValType(aChvInfo[15]) != "O"
		If !lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	
	//TODO: Analisar o uso
	/*
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_tpNF:TEXT") != "U"	// Tipo do Documento
	If (aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_tpNF:TEXT != "1")
	If ! lQuiet
	cProblema := "Documento Não é Saída!"
	oSay:Refresh()
	EndIf
	aSize( aChvInfo, 0 )
	Return .F.
	EndIf
	EndIf
	*/
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT") != "U" // Numero do Documento
		aChvInfo[03] := Replicate("0",09) + AllTrim(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT)
		aChvInfo[03] := Right(aChvInfo[03],09)
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT") != "U" // Série do Documento
		aChvInfo[04] := PadR(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT,03)
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_ID:TEXT") != "U" // Chave DANFE
		aChvInfo[11] := substr(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,04)
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT") != "U" // CNPJ Emitente
		xTemp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
		If xTemp != SM0->M0_CGC
			// DESCOMENTAR NO CLIENTE
			If !lQuiet
				cProblema := "Documento não é deste CNPJ!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo,0)
			Return .F.
		EndIf
		_cCgcEmi := xTemp
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:TEXT") != "U" // Emissão
		aChvInfo[05] := StoD(StrTran(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:TEXT,"-",""))
		dDatabase := aChvInfo[05]
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:TEXT") != "U" // Emissão
		aChvInfo[05] := StoD(StrTran(Left(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:TEXT,10),"-",""))
		dDatabase := aChvInfo[05]
	EndIf
	If u_TrataSE4() // Cond.Pagto (default: 000 - a Vista )
		aChvInfo[10] := SE4->E4_CODIGO
	Else
		If !lQuiet
			oSay:Refresh()
		EndIf
		aSize(aChvInfo,0)
		Return .F.
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") != "U" // CNPJ Destinatário
		cCNPJ := PadR(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT,14)
	Else
		cCNPJ := Space(14)
	EndIf
	If Empty(AllTrim(cCNPJ))
		If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT") != "U"
			cCNPJ := PadR(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT,11)
		Else
			cCNPJ := Space(11)
		EndIf
	EndIf
	_cCgcDes := cCNPJ
	SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
	If SA1->(!DbSeek(xFilial("SA1") + cCNPJ,.F.))
		If !u_CriarSA1()
			If !lQuiet
				cProblema := "Não foi possível criar Cliente!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo,0)
			Return .F.
		EndIf
	EndIf
	aChvInfo[06] := SA1->A1_COD				// Cliente
	aChvInfo[07] := SA1->A1_LOJA			// Loja
	aChvInfo[09] := SA1->A1_EST				// UF
	If lChkExist() // Checar existencia da NF se existir informar e bloquear
		aSize(aChvInfo,0)
		Return .F.
	EndIf
	// Indica se é operação com consumidor final
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_INDFINAL:TEXT") != "U"
		lOpConsFin := AllTrim(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_INDFINAL:TEXT) == "1"
	Else
		lOpConsFin := .F.
	EndIf
	If !u_TrataSB1() // Tratamento Produtos e Impostos
		If !lQuiet
			oSay:Refresh()
		EndIf
		aSize(aChvInfo,0)
		Return .F.
	EndIf
	CargaImp() // carrega Tag Impostos total do XML
EndIf
// G I N F E S
If _tipoNF == "G"
	aSize( aChvInfo, 0 )
	/*
	cXml := U_LeXml( cFile )	  							// Lê XML e retorna conteúdo
	if Empty( cXml )
	cProblema := "Arquivo XML vazio ou corrompido!"
	oSay:Refresh()
	return .F.
	endif
	*/
	if !("www.ginfes.com.br" $ lower(cXml))
		if ! lQuiet
			cProblema := "Arquivo não é do formato GINFES!"
		EndIf
		Return .F.
	EndIf
	oXML := u_c2oXML(cXml) // Carrega XML no Objeto
	If ValType(oXML) != "O"
		If !lQuiet
			cProblema := "Arquivo XML corrompido!"
		EndIf
		Return .F.
	EndIf
	if Type("oXml:_NS2_NFSE:_NS2_NFSE") != "U"
		aNotas := iif( Type("oXml:_NS2_NFSE:_NS2_NFSE") == "A", oXml:_NS2_NFSE:_NS2_NFSE, { oXml:_NS2_NFSE:_NS2_NFSE } )
	EndIf
	if Len( aNotas ) == 0
		if ! lQuiet
			cProblema := "Não encontrada NFS-e no arquivo!"
		EndIf
		Return .F.
	EndIf
	NFServico(aNotas) // chama a inclusão das NF de Serviço
	aSize(aChvInfo, 0)
	cProblema := ""
	cChave := Space(50)
EndIf
// P R E F E I T U R A
If _tipoNF == "P"
	aSize(aChvInfo, 0)
	aNotas := u_LeTXT(cFile) // Lê XML e retorna conteúdo
	If Len(aNotas) == 0
		If !lQuiet
			cProblema := "Arquivo TXT vazio ou corrompido!"
		EndIf
		Return .F.
	EndIf
	NFServico( aNotas )		// chama a inclusão das NF de Serviço
	aSize( aChvInfo, 0 )
	cProblema := ""
	cChave := Space(50)
EndIf

// C A N C E L A M E N T O
If _tipoNF == "_CA"
	aSize(aChvInfo, 30)
	aFill(aChvInfo, "")
	aChvInfo[01] := "_CA"								// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[03] := SubStr(cChave,26,09)				// Documento
	aChvInfo[04] := SubStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space(Len(SA1->A1_COD))				// Cliente
	aChvInfo[07] := Space(Len(SA1->A1_LOJA))			// Loja
	aChvInfo[08] := "SPED "					  			// Espécie
	aChvInfo[09] := Space(Len(SA1->A1_EST))				// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[11] := Left(cChave, 44)					// Chave DANFE
	aChvInfo[12] := 1									// Finalidade da DANFE (compatibilização) - 19/12/2016 - Cristiam
	aChvInfo[15] := u_c2oXML(cXml)						// Carrega XML no Objeto
	If ValType(aChvInfo[15]) != "O"
		If !lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	If Type("aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT") != "U"
		aChvInfo[11] := aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT // Chave DANFE
		aChvInfo[03] := SubStr(aChvInfo[11],26,09) // Numero do Documento
		aChvInfo[04] := SubStr(aChvInfo[11],23,03) // Série do Documento
	EndIf
	If Type("aChvInfo[15]:_procEventoNFe:_evento:_infEvento:_CNPJ:TEXT") != "U"	// CNPJ Emitente
		xTemp := aChvInfo[15]:_procEventoNFe:_evento:_infEvento:_CNPJ:TEXT
		If xTemp != SM0->M0_CGC // Cnpj nao confere
			If !lQuiet
				cProblema := "Documento não é deste CNPJ!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
	EndIf
	If Type("aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD(StrTran(Left(aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT, 10), "-", ""))
		dDatabase := aChvInfo[05]
	EndIf
	If Type("aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CNPJDEST:TEXT") != "U"	// CNPJ Destinatário
		cCNPJ := PadR(aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CNPJDEST:TEXT,14)
	Else
		cCNPJ := Space(14)
	EndIf
	If Empty(cCNPJ)
		If Type("aChvInfo[15]:_procEventoNFe:_retEvento:_infEvento:_CPFDest:TEXT") != "U"	// CPF Destinatário
			cCNPJ := PadR(aChvInfo[15]:_procEventoNFe:_retEvento:_infEvento:_CPFDest:TEXT,11)
		Else
			cCNPJ := Space(11)
		EndIf
	EndIf
	If !lChkExist() // checar existencia da NF se não existir informar e bloquear
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + aChvInfo[06] + aChvInfo[07]))
		If AllTrim(cCNPJ) != AllTrim(SA1->A1_CGC)
			If !lQuiet
				cProblema := "Cliente não confere com a NF!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
	Else
		If !lQuiet
			cProblema := "Cliente não Cadastrado!"
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	aChvInfo[06] := SA1->A1_COD				// Cliente
	aChvInfo[07] := SA1->A1_LOJA			// Loja
	aChvInfo[09] := SA1->A1_EST				// UF
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NFServico ºAutor  ³Cristiam Rossi      º Data ³  19/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratativa NF Serviço e diálogo das inclusões               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML automatizado                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function NFServico(aNotas)
Local _nX
Local xTemp := ""
Local cMsg
Local nGravou := 0
Private aNFS := {}
For _nX := 1 To Len(aNotas)
	cProblema := ""
	aSize(aChvInfo, 30)
	aFill(aChvInfo, "")
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[06] := Space(Len(SA1->A1_COD))				// Fornecedor
	aChvInfo[07] := Space(Len(SA1->A1_LOJA))			// Loja
	aChvInfo[08] := "RPS  "					  			// Espécie
	aChvInfo[09] := Space(Len(SA1->A1_EST))				// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[12] := 1									// Finalidade da DANFE (compatibilização) - 19/12/2016 - Cristiam
	If _tipoNF == "P"
		aNFS := aNotas[_nX]
		aChvInfo[03] := Right(Replicate("0",9) + AllTrim(SubStr(aNFS,2,8)), Len(SF2->F2_DOC)) // Documento
		aChvInfo[04] := PadR(Alltrim(SubStr(aNFS,37,5)), Len(SF2->F2_SERIE)) // Série
		aChvInfo[05] := StoD(SubStr(aNFS,10,10)) // Emissão
		xTemp := SubStr(aNFS,519,14) // CNPJ Tomador
	Else // GINFES
		aNFS := aNotas[_nX]
		If U_ztipo("aNFS:_NS3_IDENTIFICACAONFSE:_NS3_NUMERO:TEXT") != "U"
			aChvInfo[03] := Right(Replicate("0",9) + aNFS:_NS3_IDENTIFICACAONFSE:_NS3_NUMERO:TEXT,9) // Documento
		EndIf
		If U_ztipo("aNFS:_NS3_IDENTIFICACAONFSE:_NS3_SERIE:TEXT") != "U"
			aChvInfo[04] := PadR(Right(Replicate("0",3) + aNFS:_NS3_IDENTIFICACAONFSE:_NS3_SERIE:TEXT,3), Len(SF2->F2_SERIE)) // Série
		Else
			aChvInfo[04] := Space(3)
		EndIf
		If U_ztipo("aNFS:_NS3_DATAEMISSAO:TEXT") != "U"
			aChvInfo[05] := StoD(StrTran(Left(aNFS:_NS3_DATAEMISSAO:TEXT, 10), "-", "")) // Emissão
		Else
			aChvInfo[05] := CtoD("")
		EndIf
		If U_ztipo("aNFS:_NS3_PrestadorServico:_NS3_IdentificacaoPrestador:_NS3_CNPJ:TEXT") != "U"	// CNPJ Destinatário
			xTemp := aNFS:_NS3_PrestadorServico:_NS3_IdentificacaoPrestador:_NS3_CNPJ:TEXT
		EndIf
	EndIf
	If xTemp != SM0->M0_CGC
		// DESCOMENTAR NO CLIENTE
		If !lQuiet
			cProblema := "A "+Alltrim(Str(_nX)) + " NFS-e de N: " + aChvInfo[03] + " não é para o cliente"
			MsAguarde({|| Sleep(3000)}, "", cProblema, .T.)
		EndIf
		Loop
	EndIf
	If _tipoNF == "P"
		cCNPJ := AllTrim(SubStr(aNFS,71,14)) // Emissor / Prestador
		If Empty(cCNPJ)
			If !lQuiet
				// cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" Tomador não encontrado no arquivo!"
				cProblema := "Tomador não encontrado! NFS-e de N: " + aChvInfo[03]
				MsAguarde({|| Sleep(3000)}, "", cProblema, .T.)
			EndIf
			Loop
		EndIf
	Else // GINFES
		If U_ztipo("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT") != "U"	// CNPJ Destinatário
			cCNPJ := PadR(aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT, 14)
		EndIf
		If U_ztipo("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CPF:TEXT") != "U"	// CNPJ Destinatário
			cCNPJ := PadR(aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CPF:TEXT, 14)
		EndIf
		If Empty(cCNPJ)
			if !lQuiet
				// cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" Tomador não encontrado no arquivo!"
				cProblema := "Tomador não encontrado! NFS-e de N: "+aChvInfo[03]
				MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
			EndIf
			Loop
		EndIf
	EndIf
	SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
	If SA1->(!DbSeek(xFilial("SA1") + cCNPJ))
		If !u_CriarSA1()
			If !lQuiet
				cProblema := "A " + Alltrim(Str(_nX)) + " NFS-e de N: " + aChvInfo[03] + " não criou Cliente!"
				MsAguarde({|| Sleep(3000)}, "", cProblema, .T.)
			EndIf
			Loop
		EndIf
	EndIf
	aChvInfo[06] := SA1->A1_COD				// Cliente
	aChvInfo[07] := SA1->A1_LOJA			// Loja
	aChvInfo[09] := SA1->A1_EST				// UF
	If lChkExist() // checar existencia da NF se existir informar e bloquear
		If !lQuiet
			cProblema := "A " + Alltrim(Str(_nX)) + " NFS-e de N: " + aChvInfo[03] + " já existe!"
			MsAguarde({|| Sleep(3000)}, "", cProblema, .T.)
		EndIf
		Loop
	EndIf
	If !lQuiet
		cMsg := "Nota " + Alltrim(Str(_nX)) + " / " + Alltrim(Str(Len(aNotas))) + CRLF
		cMsg += "Nº: " + Alltrim(aChvInfo[03])
		If !Empty(aChvInfo[04])
			cMsg += " / " + AllTrim(aChvInfo[04])
		endif
		cMsg += " - Emissão: "+ DtoC(aChvInfo[05]) + CRLF
		cMsg += "Emissor: "+ SA1->A1_NOME + CRLF
		If Len(alltrim(cCNPJ)) == 14
			cMsg += "CNPJ: " + Transform(cCNPJ, "@R 99.999.999/9999-99")
		Else
			cMsg += "CPF: " + Transform(cCNPJ, "@R 999.999.999-99")
		EndIf
		cMsg += CRLF + CRLF + "Efetuar importação?"
		If Aviso("Nota de Serviço", cMsg, {"Sim", "Não"},2) != 1
			Exit
		EndIf
	EndIf
	If !u_TrataSB1() // Tratamento Produtos e Impostos
		MsAguarde({|| Sleep(3000)}, "", cProblema, .T.)
		Loop
	EndIf
	CargaImp()			// carrega Tag Impostos total do XML
	
	// NFS-e mata103
	If Len(aChvInfo) > 0
		dDatabase := aChvInfo[05]
		If lQuiet
			xRet := incPV(aChvInfo[3], aChvInfo[4]) // inclusão via Execauto
		Else
			xRet := A410Inclui("SC5", SC5->(Recno()), 3) == 1 // chama Inclusão Pedido de Venda
		EndIf
		If xRet
			xRet := u_FatPV(SC5->C5_NUM, aChvInfo[3], aChvInfo[4], aChvInfo[08])
			If !xRet
				If !lQuiet
					MsgStop("Ocorreu falha no faturamento da NF:" + aChvInfo[3] + "/" + aChvInfo[4], "")
				EndIf
			Else
				If SF2->F2_DOC == aChvInfo[3] .And. SF2->F2_SERIE == aChvInfo[4] .And. SF2->F2_CLIENTE == aChvInfo[6] .And. SF2->F2_LOJA == aChvInfo[7]
					nGravou++ // foi cadastrado o XML de Entrada!
				EndIf
			EndIf
		EndIf
	EndIf
Next
If nGravou > 0
	If !lQuiet
		If nGravou < Len(aNotas) .And. Aviso("Importação NF Serviço", "Nem todos os documentos foram importados, deseja mover o arquivo para a pasta lidos?", {"Ok", "Não"}) != 1
			Return
		EndIf
	EndIf
	u_fMoverArq(cFile)
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³lChkExist ºAutor  ³Cristiam Rossi      º Data ³  18/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a NF já existe na base                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML automatizado                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function lChkExist()
Local lExist := .F.
Local cQuery := ""
Local cTmpAlias	:= ""
If _tipoNF == "_CA" // Cancelamento
	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SF2") + " SF2 " + CRLF
	cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' " + CRLF
	//cQuery += "	AND SF2.F2_CHVNFE = '" + aChvInfo[11] + "' " + CRLF
	If Type("aChvInfo[15]:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT") == "C"
		cQuery += "	AND SF2.F2_CHVNFE = '" + aChvInfo[15]:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT + "' " + CRLF
	Else
		cQuery += "	AND SF2.F2_CHVNFE = '" + aChvInfo[15]:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT + "' " + CRLF
	EndIf
	cQuery += "	AND SF2.D_E_L_E_T_ = ' ' "
	cTmpAlias := GetNextAlias()
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cTmpAlias,.F.,.T.)
	lExist := !(cTmpAlias)->(EOF())
	If lExist
		aChvInfo[03] := (cTmpAlias)->F2_DOC
		aChvInfo[04] := (cTmpAlias)->F2_SERIE
		aChvInfo[06] := (cTmpAlias)->F2_CLIENTE
		aChvInfo[07] := (cTmpAlias)->F2_LOJA
	Else
		If !lQuiet
			cProblema := "Documento não cadastrado!"
			oSay:Refresh()
		EndIf
	EndIf
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
Else
	SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE + ...
	lExist := SF2->(DbSeek(xFilial("SF2") + aChvInfo[03] + aChvInfo[04]))
	If lExist
		If !lQuiet
			cProblema := "Documento cadastrado!"
			oSay:Refresh()
		EndIf
		If Type("nJaLidos") == "N"
			nJaLidos++
		EndIf
		u_fMoverArq( cFile )
		// aSize( aChvInfo, 0 )
	EndIf
EndIf
Return lExist

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³criarSA1  ºAutor  ³ Cristiam Rossi     º Data ³  24/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criação de Clientes - SA1                                  º±±
±±º          ³ com informações do XML                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO Contabilidade - XML                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CriarSA1(cTipo)
Local lSXE := .F.
Local cConta := GetMv("MV_XCTACLI")
Local nI
Default cTipo := "N"
BEGIN SEQUENCE
DbSelectArea("SA1")
RegToMemory("SA1")
M->A1_FILIAL := xFilial("SA1")
If Empty(M->A1_COD)
	lSXE := .T.
	M->A1_COD := u_tstSXE("SA1","A1_COD") // Garante que o Numerador não exista na base
	M->A1_LOJA := StrZero(1, Len(SA1->A1_LOJA))
EndIf
// DANFE
If _tipoNF == "D"
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT") != "U"
		M->A1_NOME := U_xSoDigit( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT )
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_xFant:TEXT") != "U"
		M->A1_NREDUZ := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_xFant:TEXT
	Else
		M->A1_NREDUZ := M->A1_NOME
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatário
		M->A1_CGC := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT") != "U"	// CPF Destinatário
		M->A1_CGC := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT") != "U"
		M->A1_INSCR := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xLgr:TEXT") != "U"
		M->A1_END := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xLgr:TEXT
		If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_nro:TEXT") != "U" .And. !Empty(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_nro:TEXT)
			M->A1_END += ", " + aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_nro:TEXT
		EndIf
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xBairro:TEXT") != "U"
		M->A1_BAIRRO := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xBairro:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_cMun:TEXT") != "U"
		M->A1_COD_MUN := Right( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_cMun:TEXT, 5)
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xMun:TEXT") != "U"
		M->A1_MUN := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xMun:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT") != "U"
		M->A1_EST := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT") != "U"
		M->A1_CEP := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xPais:TEXT") != "U"
		M->A1_PAIS := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xPais:TEXT
	EndIf
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_fone:TEXT") != "U"
		M->A1_DDD := Left(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_fone:TEXT, 2)
		M->A1_TEL := SubStr(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_fone:TEXT, 3)
	EndIf
EndIf
// CT-e
If _tipoNF == "CTE"
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_xNome:TEXT") != "U"
		M->A1_NOME := u_xSoDigit(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_xNome:TEXT)
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_xFant:TEXT") != "U"
		M->A1_NREDUZ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_xFant:TEXT
	Else
		M->A1_NREDUZ := M->A1_NOME
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") != "U" // CNPJ Destinatário
		M->A1_CGC := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT") != "U" // CNPJ Destinatário
		M->A1_CGC := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_IE:TEXT") != "U"
		M->A1_INSCR := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_IE:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xLgr:TEXT") != "U"
		M->A1_END := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xLgr:TEXT
		If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_nro:TEXT") != "U" .And. !Empty(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_nro:TEXT)
			M->A1_END += ", " + aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_nro:TEXT
		EndIf
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xBairro:TEXT") != "U"
		M->A1_BAIRRO := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xBairro:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_cMun:TEXT") != "U"
		M->A1_COD_MUN := Right(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_cMun:TEXT, 5)
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xMun:TEXT") != "U"
		M->A1_MUN := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xMun:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT") != "U"
		M->A1_EST := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT") != "U"
		M->A1_CEP := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_CEP:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xPais:TEXT") != "U"
		M->A1_PAIS := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_xPais:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_fone:TEXT") != "U"
		M->A1_DDD := Left(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_fone:TEXT, 2)
		M->A1_TEL := SubStr(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST:_fone:TEXT, 3)
	EndIf
EndIf
// GINFES
If _tipoNF == "G"
	If cTipo == "D" // Devolução - usa Prestador
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_RAZAOSOCIAL:TEXT") != "U"
			M->A1_NOME := u_xSoDigit(aNFS:_NS3_PRESTADORSERVICO:_NS3_RAZAOSOCIAL:TEXT)
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_NOMEFANTASIA:TEXT") != "U"
			M->A1_NREDUZ := aNFS:_NS3_PRESTADORSERVICO:_NS3_NOMEFANTASIA:TEXT
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT") != "U"
			M->A1_CGC := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_INSCRICAOMUNICIPAL:TEXT") != "U"
			M->A1_INSCRM := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_INSCRICAOMUNICIPAL:TEXT
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT") != "U"
			M->A1_END := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT
			If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT") != "U"
				M->A1_END += ", " + aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT
			EndIf
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT") != "U"
			M->A1_BAIRRO := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT") != "U"
			M->A1_COD_MUN := Right(aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT, 5)
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT") != "U"
			M->A1_EST := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT
		EndIf
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT") != "U"
			M->A1_CEP := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT
		EndIf
		CC2->(DbSetOrder(1))
		If CC2->(DbSeek(xFilial("CC2") + M->A1_EST + M->A1_COD_MUN))
			M->A1_MUN := CC2->CC2_MUN
		EndIf
		M->A1_PAIS := "105"
		If Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT") != "U"
			// M->A1_DDD :=
			M->A1_TEL := aNFS:_NS3_PRESTADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT
		EndIf
		If Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U"
			M->A1_SIMPNAC := aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT // 1=SIM; 2=NAO
		EndIf
	Else		// Normal - usa Tomador
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_RAZAOSOCIAL:TEXT") != "U"
			M->A1_NOME := u_xSoDigit(aNFS:_NS3_TOMADORSERVICO:_NS3_RAZAOSOCIAL:TEXT)
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_NOMEFANTASIA:TEXT") != "U"
			M->A1_NREDUZ := aNFS:_NS3_TOMADORSERVICO:_NS3_NOMEFANTASIA:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT") != "U"
			M->A1_CGC := aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CPF:TEXT") != "U"
			M->A1_CGC := aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CPF:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_INSCRICAOMUNICIPAL:TEXT") != "U"
			M->A1_INSCRM := aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_INSCRICAOMUNICIPAL:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT") != "U"
			M->A1_END := aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT
			If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT") != "U"
				M->A1_END += ", " + aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT
			EndIf
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT") != "U"
			M->A1_BAIRRO := aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT") != "U"
			M->A1_COD_MUN := Right(aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT, 5)
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT") != "U"
			M->A1_EST := aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT
		EndIf
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT") != "U"
			M->A1_CEP := aNFS:_NS3_TOMADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT
		EndIf
		CC2->(DbSetOrder(1)) // CC2_FILIAL + CC2_EST + CC2_CODMUN
		If CC2->(DbSeek(xFilial("CC2") + M->A1_EST + M->A1_COD_MUN))
			M->A1_MUN := CC2->CC2_MUN
		EndIf
		M->A1_PAIS := "105"
		If Type("aNFS:_NS3_TOMADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT") != "U"
			// M->A1_DDD :=
			M->A1_TEL := aNFS:_NS3_TOMADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT
		EndIf
		If Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U"
			M->A1_SIMPNAC := aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT // 1=SIM; 2=NAO
		EndIf
	EndIf
EndIf
// Prefeitura
If _tipoNF == "P"
	M->A1_NOME    := Upper(NoAcento(AllTrim( u_xSoDigit(AllTrim(SubStr(aNFS, 85, 75))) )))
	M->A1_NREDUZ  := Upper(NoAcento(AllTrim( M->A1_NOME )))
	M->A1_CGC     := AllTrim(SubStr(aNFS, 71, 14))
	M->A1_INSCRM  := SubStr(aNFS, 62, 8)
	M->A1_END     := Upper(NoAcento( AllTrim(SubStr(aNFS, 160, 3)) ))
	M->A1_END     += Upper(NoAcento( Iif(Empty(M->A1_END), "", " ") + AllTrim(SubStr(aNFS, 163, 50)) ))
	M->A1_END     += ", " + AllTrim(SubStr(aNFS, 213, 10))
	M->A1_COMPLEM := Upper( AllTrim(SubStr(aNFS, 223, 30)) )
	M->A1_BAIRRO  := Upper(NoAcento( AllTrim(SubStr(aNFS, 253, 30)) ))
	M->A1_MUN     := Upper(NoAcento( AllTrim(SubStr(aNFS, 283, 50)) ))
	M->A1_EST     := SubStr(aNFS, 333, 2)
	M->A1_CEP     := SubStr(aNFS, 335, 8)
	CC2->(DbSetOrder(3)) // CC2_FILIAL + CC2_EST + CC2_CODMUN
	If CC2->(DbSeek(xFilial("CC2") + M->A1_EST + M->A1_MUN))
		M->A1_COD_MUN := CC2->CC2_CODMUN
	EndIf
	M->A1_PAIS    := "105"
	M->A1_EMAIL   := SubStr(aNFS, 343, 75)
	M->A1_SIMPNAC := Iif(SubStr(aNFS, 418, 1 ) > "0", "1", "2")
EndIf
M->A1_PESSOA := Iif(Len(M->A1_CGC) > 11, "J", "F")
M->A1_TIPO   := Iif(M->A1_PESSOA == "F", "F", "R")
/*
If empty(M->A1_INSCRM)
M->A1_TIPO := "F"
EndIf
*/
M->A1_CONTA	:= cConta
M->A1_COND	:= "000"
If M->A1_EST != "EX"
	M->A1_PAIS    := "105"
	M->A1_CODPAIS := "01058"
EndIf
RecLock("SA1",.T.)
For nI := 1 To FCount()
	FieldPut(nI, &("M->" + FieldName(nI)))
Next
SA1->(MsUnlock())

u_M030INC() // Chamada o P.E. de inclusao para incluir/alterar o Item Contabil (CTD)
// u_AddItCtb("C" + SA1->A1_COD, SA1->A1_NOME, "1") // "1"=Receita

END SEQUENCE
If lSXE
	If Left(M->A1_NOME, Min(Len(M->A1_NOME), Len(SA1->A1_NOME))) == Left(SA1->A1_NOME, Min(Len(M->A1_NOME), Len(SA1->A1_NOME)))
		ConfirmSX8()
	Else
		RollBackSx8()
	EndIf
EndIf
Return Left(M->A1_NOME, Min(Len(M->A1_NOME), Len(SA1->A1_NOME))) == Left(SA1->A1_NOME, Min(Len(M->A1_NOME), Len(SA1->A1_NOME)))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ CargaImp ºAutor  ³ Cristiam Rossi     º Data ³  17/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga dos Impostos Total do XML                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO Contabilidade XML                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CargaImp()
Local nFrete  := 0
Local nSeguro := 0
Local nOutros := 0
Local nDescon := 0
Local nProd   := 0
Local nNF     := 0
Local nSubst  := 0
Local cRecIss := "1"
Local cNatX   := ""		// Natureza para Serviços
If _tipoNF == "D"
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vFrete:TEXT") != "U"
		nFrete := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vFrete:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vSeg:TEXT") != "U"
		nSeguro := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vSeg:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vOutro:TEXT") != "U"
		nOutros := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vOutro:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vDesc:TEXT") != "U"
		nDescon := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vDesc:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vProd:TEXT") != "U"
		nProd := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vProd:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vNF:TEXT") != "U"
		nNF := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vNF:TEXT )
	endif
	if Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vTotTrib:TEXT") != "U"
		nSubst := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vTotTrib:TEXT )
	endif
	cNatX := cNatNFE		// Natureza para DANFE
	// S E R V I Ç O S
elseif _tipoNF == "G"		// GINFES
	if Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT") != "U"
		nProd := aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT
	EndIf
	if Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_ISSRETIDO:TEXT") != "U"
		cRecIss := aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_ISSRETIDO:TEXT
	EndIf
	nNF   := nProd
	If Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U" .and. aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT == "1"
		cNatX := cNatSSN
	Else
		cNatX := cNatISS
	EndIf
	if Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORPIS:TEXT") != "U" .or. Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORCOFINS:TEXT") != "U" .or. ;
		Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORINSS:TEXT") != "U" .or. Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORIR:TEXT") != "U" .or. Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORCSLL:TEXT") != "U"
		cNatX := cNatSRT
	EndIf
ElseIf _tipoNF == "CTE"
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT") != "U"			// CT-e
		nProd := Val( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT )
		nNF   := nProd
	endif
	cNatX := cNatNFE		// Natureza para DANFE
else		// Prefeitura
	nProd := Val( subStr( aNFS, 448, 15 ) ) / 100
	nNF   := nProd
	if subStr( aNFS, 418, 1 ) > "0"
		cNatX := cNatSSN
	else
		cNatX := cNatISS
	endif
	if _vLayout == "004"
		if val( subStr( aNFS, 1037, 15 ) ) > 0 .or. ;		// PIS
			val( subStr( aNFS, 1052, 15 ) ) > 0 .or. ;		// COFINS
			val( subStr( aNFS, 1067, 15 ) ) > 0 .or. ;		// INSS
			val( subStr( aNFS, 1082, 15 ) ) > 0 .or. ;		// IR
			val( subStr( aNFS, 1097, 15 ) ) > 0				// CSSL
			cNatX := cNatSRT
		EndIf
	EndIf
EndIf
aChvInfo[30] := { nFrete, nSeguro, nOutros, nDescon, nProd, nNF, nSubst, cRecIss }
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1") + aChvInfo[06] + aChvInfo[07]))
	RecLock("SA1",.F.)
	SA1->A1_NATUREZ := cNatX		// Natureza serviços
	MsUnlock()
EndIf
Return

Static Function incPV(cDOC, cSERIE)
Local aArea       := getArea()
Local lRet        := .F.
Local cNumSC5     := ""
Local nX
Local cTesSAIDA
Local aCamposSC5  := {}
Local aCAMPOSSC6  := {}
Local lMsErroAuto
Local aItens
SF2->( dbSetOrder(1) )		// checar se a NF já existe!
If SF2->( dbSeek( xFilial("SF2")+cDOC+cSERIE ) )
	Return .F.
EndIf
While .T.
	cNumSC5 := GetSxeNum("SC5","C5_NUM")
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
	If SC5->(DbSeek(xFilial("SC5") + cNumSC5))
		ConfirmSX8()
	Else
		Exit
	EndIf
End
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1") + aChvInfo[06] + aChvInfo[07]))
_nTempFrete := 0
For nX := 1 to len( aChvInfo[20] )
	_nTempFrete += If(valtype(aChvInfo[20][nX][14])=="N",aChvInfo[20][nX][14],val(aChvInfo[20][nX][14]))
Next
aCamposSC5 :=  {{"C5_FILIAL"	, xFilial("SC5")	, Nil },;
{"C5_NUM"		, cNumSC5			, Nil },;
{"C5_TIPO"		, 'N'				, Nil },;
{"C5_EMISSAO"	, aChvInfo[05]		, Nil },;
{"C5_CLIENTE"	, SA1->A1_COD		, Nil },;
{"C5_LOJACLI"	, SA1->A1_LOJA		, Nil },;
{"C5_FRETE"     , _nTempFrete       , NIL },;
{"C5_CONDPAG"	, aChvInfo[10]		, Nil } }
if !Empty( aChvInfo[21] )	// é serviço
	aadd( aCamposSC5, {"C5_NATUREZ", SA1->A1_NATUREZ, .F.} )
	aadd( aCamposSC5, {"C5_ESTPRES", SA1->A1_EST    , .F.} )
	aadd( aCamposSC5, {"C5_MUNPRES", SA1->A1_COD_MUN, .F.} )
	aadd( aCamposSC5, {"C5_RECISS" , "1"            , .F.} )
EndIf
_cSomaX := "00"
For nX := 1 to len( aChvInfo[20] )
	SB1->( dbGoto( aChvInfo[20][nX][1] ) )		// Recno SB1
	xTmp := U_fBuscaUM( SB1->B1_UM )	// Valida Unidade de Medida
	if xTmp != SB1->B1_UM
		RecLock("SB1", .F.)
		SB1->B1_UM := xTmp
		msUnlock()
	EndIf
	//conout("Item: " + StrZero(nX, 3) + " - Prod: " + SB1->B1_DESC)
	U_LogAlteracoes( "incPV" ,"Item: " + StrZero(nX, 3) + " - Prod: " + SB1->B1_DESC)
	cTesSaida := Space( len( SF4->F4_CODIGO ) )
	SF4->( dbGoto( aChvInfo[20][nX][13][5] ) )		// Recno SF4
	if SF4->( RECNO() ) == aChvInfo[20][nX][13][5]
		cTesSaida := SF4->F4_CODIGO
	EndIf
	// _cSomaX := soma1(alltrim(_cSomaX),2)
	zCnvSoma1(_cSomaX)
	_cSomaX := nValConv
	aItens :=  {{ "C6_ITEM"		, _cSomaX			, Nil },; // Itens
	{ "C6_FILIAL"	, xFilial("SC6") 		  		, Nil },; // Filial
	{ "C6_NUM"		, cNumSC5		 			  	, Nil },; // Numero do Pedido
	{ "C6_PRODUTO"	, SB1->B1_COD	 			   	, Nil },; // Material
	{ "C6_DESCRI"	, SB1->B1_DESC					, Nil },; // Descrição do Produto
	{ "C6_UM"		, SB1->B1_UM					, Nil },; // Unidade de medida
	{ "C6_QTDVEN"	, aChvInfo[20][nX][8] 	 		, Nil },; // Quantidade
	;// { "C6_PRCVEN"	, aChvInfo[20][nX][9]			, Nil },; // Preco de Venda / Valor Frete
	{ "C6_PRCVEN"	, (aChvInfo[20][nX][10] - aChvInfo[20][nX][11]) / aChvInfo[20][nX][8]			, Nil },; // Preco Unitário / Valor Frete
	{ "C6_PRUNIT"	, aChvInfo[20][nX][9]			, Nil },; // Preco Unitário / Valor Frete
	;// { "C6_VALOR"    , aChvInfo[20][nX][10]			, Nil },; // Valor total do item
	{ "C6_VALOR"    , aChvInfo[20][nX][10] - aChvInfo[20][nX][11]			, Nil },; // Valor total do item
	{ "C6_TES"		, cTesSaida		 			 	, Nil },; // TES
	{ "C6_LOCAL"	, SB1->B1_LOCPAD  			 	, Nil },; // Armazem padrao
	{ "C6_ENTREG"	, dDataBase		 	 		 	, Nil },; // Data da entrega
	{ "C6_QTDLIB"	, aChvInfo[20][nX][8]      	 	, Nil },; // Quantidade liberada
	{ "C6_DESCONT"	, 0              			 	, Nil },; // Percentual de Desconto
	{ "C6_VALDESC"	, aChvInfo[20][nX][11]		 	, Nil },; // Percentual de Desconto
	{ "C6_COMIS1"	, 0              			 	, Nil },; // Comissao Vendedor
	{ "C6_CLI"		, SA1->A1_COD     			 	, Nil },; // Cliente
	{ "C6_LOJA"		, SA1->A1_LOJA    	 		 	, Nil }}
	if aChvInfo[20][nX][13][6] > 0		// é serviço
		aadd( aItens, { "C6_ALIQISS", aChvInfo[20][nX][13][6]	, Nil } )
		aadd( aItens, { "C6_CODISS" , aChvInfo[21]				, Nil } )
	EndIf
	Aadd(aCamposSC6, aClone(aItens))
Next
If Len(aCamposSC5) > 0 .And. Len(aCamposSC6) > 0
	//conout("Gerando Pedido")
	U_LogAlteracoes( "incPV" ,"Gerando Pedido")
	incproc("Aguarde... Gerando Pedido de Venda...")
	MsExecAuto({|x,y,z| Mata410(x,y,z) }, aCamposSC5, aCamposSC6, 3)
	If SC5->C5_NUM != cNumSC5
		MostraErro()
		RollBackSX8()
		lRet := .F.
	Else
		ConfirmSX8()
		//conout("Pedido de Venda: " + cNumSC5)
		U_LogAlteracoes( "incPV" ,"Pedido de Venda: " + cNumSC5)
		lRet := .T.
	EndIf
EndIf
RestArea(aArea)
Return lRet

/*/{Protheus.doc} IncNfSai
Inclui automaticamente uma nota fiscal de saída manual.
@type function
@author Douglas Telles
@since 27/09/2017
@version 1.0
@return lRet, Indica se foi incluido a NF..
/*/
Static Function IncNfSai()
Local lRet		:= .T.
Local lPis      := .F.
Local lCofins   := .F.
Local aArea		:= GetArea()
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local cDoc		:= aChvInfo[03]
Local cSerie	:= aChvInfo[04]
Local cCliente	:= aChvInfo[06]
Local cLoja		:= aChvInfo[07]
Local aItens	:= {}
Local aLinha	:= {}
Local aCabec	:= {}
Local nAliqCOF	:= 0
Local nAliqPIS	:= 0
Local nX		:= 0
LOCAL _nX		:= 0
Local oImp		:= Nil
Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.
SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + ...
If SF2->(DbSeek(xFilial("SF2") + cDoc + cSerie)) // Checar se a NF já existe
	Return .T.
EndIf
SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
aAdd(aCabec, { "F2_TIPO"		, aChvInfo[01]	})
aAdd(aCabec, { "F2_FORMUL"		, aChvInfo[02]	})
aAdd(aCabec, { "F2_DOC"			, cDoc			})
aAdd(aCabec, { "F2_SERIE"		, cSerie		})
aAdd(aCabec, { "F2_EMISSAO"		, aChvInfo[05]	})
aAdd(aCabec, { "F2_CLIENTE"		, SA1->A1_COD	})
aAdd(aCabec, { "F2_TIPOCLI"		, SA1->A1_TIPO	})
aAdd(aCabec, { "F2_LOJA"		, SA1->A1_LOJA	})
aAdd(aCabec, { "F2_ESPECIE"		, aChvInfo[08]	})
aAdd(aCabec, { "F2_COND"		, aChvInfo[10]	})
aAdd(aCabec, { "F2_CHVNFE"    	, aChvInfo[11]  })
//	aAdd(aCabec,{"F2_DESCONT"	, 0})
//	aAdd(aCabec,{"F2_VALBRUT"	,135})
//	aAdd(aCabec,{"F2_VALFAT"	,135})
//	aAdd(aCabec,{"F2_FRETE"		,0})
//	aAdd(aCabec,{"F2_SEGURO"	,0})
//	aAdd(aCabec,{"F2_DESPESA"	,0})
//	aAdd(aCabec,{"F2_PREFIXO"	,"1"})
//	aAdd(aCabec,{"F2_HORA"		, Time()})
_nXFrete := 0
_nXDesc  := 0
For nX := 1 To Len(aChvInfo[20])
	_nXFrete += Iif(ValType(aChvInfo[20][nX][14]) == "N", aChvInfo[20][nX][14], Val(aChvInfo[20][nX][14]))
	_nXDesc  += aChvInfo[20][nX][11]
Next
aadd(aCabec, { "F2_DESCONT",	_nXDesc })
aadd(aCabec, { "F2_FRETE",		_nXFrete })
aadd(aCabec, { "F2_SEGURO",		aChvInfo[30,02] })
aadd(aCabec, { "F2_DESPESA",	aChvInfo[30,03] })
_cLinha := "00"
For nX := 1 To Len(aChvInfo[20])
	SB1->(DbGoto(aChvInfo[20][nX][1]))
	aLinha		:= {}
	nAliqCOF	:= 0
	nAliqPIS	:= 0
	lPis        := .F.
	lCofins     := .F.
	_cLinha		:= Soma1(_cLinha)
	//Aadd(aLinha,{"D2_ITEM"	, StrZero(nX, TamSx3("D2_ITEM")[1])	, Nil })
	aAdd(aLinha, { "D2_ITEM"	, _cLinha							, Nil })
	aAdd(aLinha, { "D2_COD"		, SB1->B1_COD						, Nil })
	// aAdd(aLinha,{"D2_LOCAL"	, SB1->B1_LOCPAD					, Nil })
	aAdd(aLinha, { "D2_QUANT"	, aChvInfo[20][nX][8]				, Nil })
	aAdd(aLinha, { "D2_PRCVEN"	, aChvInfo[20][nX][9]				, Nil })
	aAdd(aLinha, { "D2_TOTAL"	, aChvInfo[20][nX][10]				, Nil })
	aAdd(aLinha, { "D2_DESC"	, aChvInfo[20][nX][11]				, Nil })
	SF4->(DbGoto(aChvInfo[20][nX][13][5]))
	If SF4->(Recno()) == aChvInfo[20][nX][13][5]
		aAdd(aLinha, { "D2_TES"	, SF4->F4_CODIGO					, Nil })
		aAdd(aLinha, { "D2_CF"	, SF4->F4_CF						, Nil })
		If SF4->F4_PISCRED == "2" // Credita Pis e Cofins
			Do Case
				Case SF4->F4_PISCOF == "3" // Ambos
					lPis    := .T.
					lCofins := .T.
					If aChvInfo[20][nX][13][18] == 0 // Cofins
						aChvInfo[20][nX][13][13] := zSuperGet("MV_TXCOFIN",.f.,aChvInfo[20][nX][13][13])	// Aliquota Cofins
						aChvInfo[20][nX][13][16] := aChvInfo[20][nX][10]									// Base Cofins
						aChvInfo[20][nX][13][18] := NoRound((aChvInfo[20][nX][13][16] * aChvInfo[20][nX][13][13])/100, SD2->(GetSx3Cache("D2_VALIMP5","X3_DECIMAL")))	// Valor Cofins
					EndIf
					If aChvInfo[20][nX][13][19] == 0 // Pis
						aChvInfo[20][nX][13][12] := zSuperGet("MV_TXPIS",.f.,aChvInfo[20][nX][13][12])	// Aliquota Pis
						aChvInfo[20][nX][13][14] := aChvInfo[20][nX][10]									// Base Pis
						aChvInfo[20][nX][13][19] := NoRound((aChvInfo[20][nX][13][14] * aChvInfo[20][nX][13][12])/100, SD2->(GetSx3Cache("D2_VALIMP6","X3_DECIMAL")))	// Valor Pis
					EndIf
				Case SF4->F4_PISCOF == "1" // Pis
					lPis    := .T.
					If aChvInfo[20][nX][13][19] == 0 // Pis
						aChvInfo[20][nX][13][12] := zSuperGet("MV_TXPIS",.f.,aChvInfo[20][nX][13][12])	// Aliquota Pis
						aChvInfo[20][nX][13][14] := aChvInfo[20][nX][10]									// Base Pis
						aChvInfo[20][nX][13][19] := NoRound((aChvInfo[20][nX][13][14] * aChvInfo[20][nX][13][12])/100, SD2->(GetSx3Cache("D2_VALIMP6","X3_DECIMAL")))	// Valor Pis
					EndIf
				Case SF4->F4_PISCOF == "2" // Cofins
					lCofins := .T.
					If aChvInfo[20][nX][13][18] == 0 // Cofins
						aChvInfo[20][nX][13][13] := zSuperGet("MV_TXCOFIN",.f.,aChvInfo[20][nX][13][13])	// Aliquota Cofins
						aChvInfo[20][nX][13][16] := aChvInfo[20][nX][10]									// Base Cofins
						aChvInfo[20][nX][13][18] := NoRound((aChvInfo[20][nX][13][16] * aChvInfo[20][nX][13][13])/100, SD2->(GetSx3Cache("D2_VALIMP5","X3_DECIMAL")))	// Valor Cofins
					EndIf
			EndCase
		EndIf
		//			If SF4->(FieldPos("F4_XCODDES")) > 0
		//				Aadd(aLinha,{"D1_CLASFIS", SF4->(F4_XCODDES + F4_SITTRIB), Nil})
		//			EndIf
		If SF4->(FieldPos("F4_XCONTA")) > 0
			If !Empty(SF4->F4_XCONTA)
				aAdd(aLinha, { "D2_CONTA", SF4->F4_XCONTA, Nil })
			EndIf
		EndIf
	EndIf
	If aChvInfo[20][nX][13][1][4] > 0
		aAdd(aLinha, { "D2_ICMSRET"	, aChvInfo[20][nX][13][1][3], Nil })
	Else
		aAdd(aLinha, { "D2_ICMSRET"	, 0							, Nil })
	EndIf
	//		Aadd(aLinha,{"D1_VALDESC"	, aChvInfo[20][nX][11]		, Nil})
	aAdd(aLinha, { "D2_BRICMS"	, aChvInfo[20][nX][13][1][4]		, Nil })
	aAdd(aLinha, { "D2_PICM"	, aChvInfo[20][nX][13][1][5]		, Nil })
	aAdd(aLinha, { "D2_VALICM"	, aChvInfo[20][nX][13][1][7]		, Nil }) // Douglas 01/11/2018
	aAdd(aLinha, { "D2_IPI"		, aChvInfo[20][nX][13][7]			, Nil })
	aAdd(aLinha, { "D2_VALIPI"	, aChvInfo[20][nX][13][11]			, Nil }) // Douglas 01/11/2018
	aAdd(aLinha, { "D2_VALFRE"	, Iif(valtype(aChvInfo[20][nX][14]) == "N", aChvInfo[20][nX][14], Val(aChvInfo[20][nX][14])), Nil })
	If U_ztipo("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO") != "U"
		oImp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO
	Else
		If U_ztipo("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET[nX]:_IMPOSTO") != "U"
			oImp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET[nX]:_IMPOSTO
		EndIF
		If U_ztipo("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IMP") != "U"
			oImp := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IMP
		EndIF
	EndIf
	If U_ztipo("oImp:_PIS") != "U"
		If U_ztipo("oImp:_PIS:_PISNT:_PPIS:TEXT") != "U"
			nAliqPIS := Val(oImp:_PIS:_PISNT:_PPIS:TEXT)
		EndIf
		If U_ztipo("oImp:_PIS:_PISALIQ:_PPIS:TEXT") != "U"
			nAliqPIS := Val(oImp:_PIS:_PISALIQ:_PPIS:TEXT)
		EndIf
	EndIf
	If nAliqPIS == 0 .and. lPis
		nAliqPIS := zSuperGet("MV_TXPIS",.f.,nAliqPIS)
	EndIf
	If U_ztipo("oImp:_COFINS") != "U"
		If U_ztipo("oImp:_COFINS:_COFINSNT:_PCOFINS:TEXT") != "U"
			nAliqCOF := Val(oImp:_COFINS:_COFINSNT:_PCOFINS:TEXT)
		EndIf
		If U_ztipo("oImp:_COFINS:_COFINSALIQ:_PCOFINS:TEXT") != "U"
			nAliqCOF := Val(oImp:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
		EndIf
	EndIf
	If nAliqCOF == 0 .and. lCofins
		nAliqCOF := zSuperGet("MV_TXCOFIN",.f.,nAliqCOF)
	EndIf
	aAdd(aLinha,{ "D2_ALIQIMP5"	, nAliqCOF	, Nil })
	aAdd(aLinha,{ "D2_ALIQIMP6"	, nAliqPIS	, Nil })
	aAdd(aItens,aLinha)
Next
MsExecAuto({|x,y,z| Mata920(x,y,z) }, aCabec, aItens, 3) // Inclusao
If lMsErroAuto // Falha no ExecAuto
	aChvInfo := {}
	lRet := .F.
	If !lQuiet
		MostraErro()
	EndIf
Else
	_nXBasRet := 0
	_nXICMSRe := 0
	SF3->(DbSetOrder(5))
	If SF3->(DbSeek(xFilial("SF3") + cSerie + cDoc + cCliente + cLoja))
		While SF3->(!EOF()) .And. SF3->F3_FILIAL == xFilial("SF3") .And. SF3->F3_SERIE == cSerie .And. SF3->F3_NFISCAL == cDoc .And. SF3->F3_CLIEFOR == cCliente .And. SF3->F3_LOJA == cLoja
			SF3->(RecLock("SF3",.F.))
			SF3->F3_VALCONT := 0
			SF3->(MsUnlock())
			SF3->(dbSkip())
		End
	EndIf
	_cLinha := "00"
	For _nX := 1 To Len(aChvInfo[20])
		_cLinha := soma1(_cLinha)
		SB1->(DbGoto(aChvInfo[20][_nX][1]))
		SD2->(DbSetOrder(3)) // D2_FILIAL + D2_DOC + D2_SERIE + D2_CLI + D2_LOJA + D2_COD + D2_ITEM
		If SD2->(DbSeek(xFilial("SD2") + cDoc + cSerie + cCliente + cLoja + SB1->B1_COD + _cLinha))
			SD2->(RecLock("SD2",.F.))
			SD2->D2_BRICMS  := aChvInfo[20][_nX][13][1][4]
			SD2->D2_ICMSRET := Iif(aChvInfo[20][_nX][13][1][4] > 0, aChvInfo[20][_nX][13][1][3], 0)
			SD2->D2_ALQIMP5 := aChvInfo[20][_nX][13][13]
			SD2->D2_ALQIMP6 := aChvInfo[20][_nX][13][12]
			SD2->D2_BASIMP5 := aChvInfo[20][_nX][13][16]
			SD2->D2_BASIMP6 := aChvInfo[20][_nX][13][14]
			SD2->D2_VALIMP5 := aChvInfo[20][_nX][13][18]
			SD2->D2_VALIMP6 := aChvInfo[20][_nX][13][19]
			SD2->D2_BRICMS	:= aChvInfo[20][_nX][13][1][4]
			SD2->D2_ORIGLAN	:= "" // Douglas 01/11/2018
			If aChvInfo[20][_nX][13][1][4] > 0
				SD2->D2_ICMSRET	:= aChvInfo[20][_nX][13][1][3]
			Else
				SD2->D2_ICMSRET	:= 0
			EndIf
			SD2->(MsUnlock())
			_nXBasRet += aChvInfo[20][_nX][13][1][4]
			_nXICMSRe += IIF(aChvInfo[20][_nX][13][1][4] > 0, aChvInfo[20][_nX][13][1][3], 0)
			SFT->(dbSetOrder(1)) // FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
			If SFT->(DbSeek(xFilial("SFT") + "S" + cSerie + cDoc + cCliente + cLoja + _cLinha + "  " + SB1->B1_COD))
				SFT->(RecLock("SFT",.F.))
				SFT->FT_BASERET := aChvInfo[20][_nX][13][1][4]
				SFT->FT_ICMSRET := Iif(aChvInfo[20][_nX][13][1][4] > 0, aChvInfo[20][_nX][13][1][3], 0)
				SFT->FT_ALIQCOF := aChvInfo[20][_nX][13][13]
				SFT->FT_ALIQPIS := aChvInfo[20][_nX][13][12]
				SFT->FT_BASECOF := aChvInfo[20][_nX][13][16]
				SFT->FT_BASEPIS := aChvInfo[20][_nX][13][14]
				SFT->FT_VALCOF  := aChvInfo[20][_nX][13][18]
				SFT->FT_VALPIS  := aChvInfo[20][_nX][13][19]
				//SFT->FT_VALCONT := SFT->(FT_BASEICM + FT_VALIPI + FT_ICMSRET)
				SFT->FT_VALCONT := SD2->(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_VALFRE)
				SFT->FT_TOTAL	:= SFT->FT_VALCONT
				SFT->FT_CHVNFE  := aChvInfo[11]
				SFT->(MsUnlock())
				SF3->(DbSetOrder(5)) // F3_FILIAL + F3_SERIE + F3_NFISCAL + F3_CLIEFOR + F3_LOJA + F3_IDENTFT
				If SF3->(DbSeek(xFilial("SF3") + cSerie + cDoc + cCliente + cLoja + SFT->FT_IDENTF3))
					If _nXBasRet > 0 .Or. _nXICMSRe > 0
						SF3->(RecLock("SF3"),.F.)
						SF3->F3_BASERET := _nXBasRet
						SF3->F3_ICMSRET := _nXICMSRe
						SF3->(MsUnlock())
					EndIf
					SF3->(RecLock("SF3"),.F.)
					SF3->F3_VALCONT += SFT->FT_VALCONT
					SF3->F3_CHVNFE  := aChvInfo[11]
					SF3->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next
	If !lQuiet
		Aviso("NF Automática", "NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cadastrada com sucesso!", {"OK"}, 2)
	EndIf
EndIf
RestArea(aAreaSA1)
RestArea(aAreaSF2)
RestArea(aArea)
Return lRet

/*/ zCnvSoma1_Função de conversão do Soma1
    param cValor, character, Valor do Soma1
    return nValConv, Valor convertido
/*/
Static Function zCnvSoma1(cValor)
    Local aArea    := GetArea()
    Local nValConv := 0
    Local cAtual   := ""
    Default cValor := "0"
     
    //Definindo o atual como 0
    cAtual := StrZero(0, Len(cValor))
    cAtual := StrTran(cAtual, '0', '9')
     
    //Enquanto o valor atual for diferente do parâmetro
    While cAtual != cValor
        nValConv++
        cAtual := Soma1(cAtual)
    EndDo
     
    RestArea(aArea)
Return nValConv
