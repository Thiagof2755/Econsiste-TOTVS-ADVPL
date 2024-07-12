#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³GETCHVNFE ºAutor  ³ Cristiam Rossi     º Data ³  29/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Diálogo p/ obter Chave NF-e de Entrada e chamar MATA103    º±±
±±º          ³ *parte XML Entrada - ECCO*                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ITUP / ECCO                                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GetChvNfe( xPar1, xPar2, xPar3, xPar4, xPar5 )
Local oDlg
Local oChave
Local cChave    := Space(50)
Local oFont
Local oButton
Local aCabec    := {}
Local aItens    := {}
Local aLinha    := {}
Local nX        := 0
Local cChvRef   := ""
Private cArqTrab	:= "XMLTRB"
Private lQuiet  := .F.
Private oPanel
Private oSay
Private cFile
Private cProblema := ""
Private cPathXml  := u_PEchvNFE("PATHXML")
Private aChvInfo  := {}
Private _tipoNF   := ""
Private _vLayout  := ""		// usado só para Prefeitura de SP
Private cNatNFE   := GETMV("MV_XNATNFE")
Private cNatSSN   := GETMV("MV_XNATSSN")
Private cNatISS   := GETMV("MV_XNATISS")
Private cNatSRT   := GETMV("MV_XNATSRT")
Private lImpAut   := .F.
Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.
Default xPar4     := ""
Default xPar5     := ""
//ConOut("GetChvNfe: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("GetChvNfe"," Iniciando...")
If xPar4 != "LOTE"
	If Select(cArqTrab) == 0
		u_CriaTrab(@cArqTrab)
	EndIf
	DEFINE FONT oFont  NAME "MonoAs" SIZE 0, -16 BOLD
	DEFINE MSDIALOG oDlg FROM 0,0 TO 125, 400 TITLE "Entrada XML" PIXEL
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
	fValChv( xPar5 )
EndIf

/*
if len( aChvInfo ) > 0
// _dOld := dDataBase
If month(dDataBase) <> month(aChvInfo[5])
dDataBase := ctod("01/"+alltrim(str(month(dDataBase)))+"/"+alltrim(str(year(dDataBase))))
Else
dDataBase := aChvInfo[5]
EndIf
EndIf
*/

// dDataBase := aChvInfo[5]

If _tipoNF == "_CA"
	If lQuiet .Or. MsgNoYes("Deseja continuar com o cancelamento da NF " + aChvInfo[03] + "/" + aChvInfo[04] + "?", "XML Automático")
		If u_CancelNF(.T.)
			If lQuiet	// é lote!
				//Conout("NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!")
				U_LogAlteracoes("GetChvNfe","NF" + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!")
			Else
				Aviso("NF de Cancelamento", "NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cancelada com sucesso!", {"OK"}, 2)
			EndIf
			u_fMoverArq()
		EndIf
	EndIf
Else
	If lImpAut
		aAdd(aCabec,{"F1_TIPO"		,aChvInfo[01]})
		aAdd(aCabec,{"F1_FORMUL"	,aChvInfo[02]})
		aAdd(aCabec,{"F1_DOC"		,aChvInfo[03]})
		aAdd(aCabec,{"F1_SERIE"		,aChvInfo[04]})
		aAdd(aCabec,{"F1_EMISSAO"	,aChvInfo[05]})
		aAdd(aCabec,{"F1_FORNECE"	,aChvInfo[06]})
		aAdd(aCabec,{"F1_LOJA"		,aChvInfo[07]})
		aAdd(aCabec,{"F1_ESPECIE"	,aChvInfo[08]})
		aAdd(aCabec,{"F1_EST"		,aChvInfo[09]})
		aAdd(aCabec,{"F1_COND"		,aChvInfo[10]})
		aAdd(aCabec,{"F1_CHVNFE"	,aChvInfo[11]})
		aAdd(aCabec,{"F1_FRETE"		,aChvInfo[30][1]})
		aAdd(aCabec,{"F1_SEGURO"	,aChvInfo[30][2]})
		aAdd(aCabec,{"F1_DESPESA"	,aChvInfo[30][3]})
		For nX := 1 To Len(aChvInfo[20])
			SB1->(DbGoto(aChvInfo[20][nX][1]))
			aLinha := {}
			aAdd(aLinha,{"D1_ITEM"	,StrZero(nX, TamSx3("D1_ITEM")[1])	,Nil})
			aAdd(aLinha,{"D1_COD"	,SB1->B1_COD						,Nil})
			aAdd(aLinha,{"D1_LOCAL"	,SB1->B1_LOCPAD						,Nil})
			aAdd(aLinha,{"D1_QUANT"	,aChvInfo[20][nX][8]				,Nil})
			aAdd(aLinha,{"D1_VUNIT"	,aChvInfo[20][nX][9]				,Nil})
			aAdd(aLinha,{"D1_TOTAL"	,aChvInfo[20][nX][10]				,Nil})
			SF4->(DbGoto(aChvInfo[20][nX][13][5]))
			If SF4->(RECNO()) == aChvInfo[20][nX][13][5]
				aAdd(aLinha,{"D1_TES", SF4->F4_CODIGO, Nil})
				If SF4->(FieldPos("F4_XCODDES")) > 0
					aAdd(aLinha,{"D1_CLASFIS", SF4->(F4_XCODDES + F4_SITTRIB), Nil})
				EndIf
				If SF4->(FieldPos("F4_XCONTA")) > 0
					If !(Empty(SF4->F4_XCONTA))
						aAdd(aLinha,{"D1_CONTA", SF4->F4_XCONTA, Nil})
					EndIf
				EndIf
			EndIf
			If aChvInfo[01] == "D"
				If U_ztipo("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") != "U"
					cChvRef := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT
					aAdd(aLinha,{"D1_NFORI"		, SubStr(cChvRef, 26, 9), Nil})
					aAdd(aLinha,{"D1_SERIORI"	, SubStr(cChvRef, 23, 3), Nil})
				ElseIf U_ztipo("aChvInfo[15]:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") != "U"
					cChvRef := aChvInfo[15]:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT
					aAdd(aLinha,{"D1_NFORI"		, SubStr(cChvRef, 26, 9), Nil})
					aAdd(aLinha,{"D1_SERIORI"	, SubStr(cChvRef, 23, 3), Nil})
				EndIf
			EndIf
			If aChvInfo[20][nX][13][1][4] > 0
				aAdd(aLinha,{"D1_ICMSRET"	, aChvInfo[20][nX][13][1][3], Nil})
			Else
				aAdd(aLinha,{"D1_ICMSRET"	, 0							, Nil})
			EndIf
			aAdd(aLinha,{"D1_VALDESC"	, aChvInfo[20][nX][11]		, Nil})
			aAdd(aLinha,{"D1_BRICMS"	, aChvInfo[20][nX][13][1][4], Nil})
			aAdd(aLinha,{"D1_PICM"		, aChvInfo[20][nX][13][1][5], Nil})
			aAdd(aLinha,{"D1_IPI"		, aChvInfo[20][nX][13][7]	, Nil})
			aAdd(aItens,aLinha)
		Next
		MsExecAuto({|x,y,z| Mata103(x,y,z)}, aCabec, aItens, 3)
		If lMsErroAuto // Falha
			aChvInfo := {}
			If !lQuiet
				MostraErro()
			EndIf
		Else // Sucesso
			If !lQuiet
				Aviso("NF Automática", "NF " + aChvInfo[03] + "/" + aChvInfo[04] + " cadastrada com sucesso!", {"OK"}, 2)
			EndIf
		EndIf
	Else
		A103NFiscal( "SF1", SF1->( Recno() ), 3 )		// chama Inclusão Documento de Entrada
	EndIf
	If Len(aChvInfo) > 0
		If SF1->F1_DOC == aChvInfo[3] .and. SF1->F1_SERIE == aChvInfo[4] .and. SF1->F1_FORNECE == aChvInfo[6] .and. SF1->F1_LOJA == aChvInfo[7]
			// foi cadastrado o XML de Entrada!
			u_fMoverArq()
		EndIf
	EndIf
EndIf
// dDataBase := _dOld
//    endif // Linha incorreta (original)
DelClassIntf()	// Exclui todas classes de interface da thread
If xPar4 != "LOTE"
	u_killTrab(cArqTrab)
EndIf
//ConOut("GetChvNfe: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("GetChvNfe","Concluido!")
Return

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
//ConOut("fVincArq: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("fVincArq","Iniciando...")
cCmpArq := cGetFile('Arquivos (*.xml)|*.xml|Arquivos (*.txt)|*.txt|}' , 'Selecione o Arquivo a ser importado, formatos XML ou TXT',1, getMV("MV_XARQXML"),.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
If Empty(cCmpArq)
	Return .F.
EndIf
cChave  := fNomArq(cCmpArq, "\")	// Retorna o nome do arquivo
cFolder := Left(cCmpArq, Len(cCmpArq) - Len(cChave))
PutMV("MV_XARQXML", cFolder )
Processa({|| aRet := u_PreLoad( cFolder, @cChave, .F. )}, "Aguarde, carregando arquivos da pasta", "Iniciando processo...")
//ConOut("fVincArq: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("fVincArq","Concluido!")
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
cFile := ""
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

Static Function fValChv( cParamCHV )
Local   cChave    := Alltrim( Upper( cParamCHV ) )
Local   cExtensao := ".xml"
Local   cXml      := ""
Local   aNotas    := {}
Local   xTemp
Local   lChkDANFE := .F.
Local 	lExistCad := .F.
Local   cTmpTag   := ""
Private oXML
Private _cCgcEmi  := ""
Private _cCgcDes  := ""
//ConOut("fValChv: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("fValChv","Iniciando...")
if empty( cChave )
	return .F.
endif
cPathXml  := getMV("MV_XARQXML")
lChkDANFE := u_PesqDANFE( cChave, cPathXml )		// Pesquisa Chave
if lChkDANFE
	_tipoNF := "D"									// DANFE
	cXml    := (cArqTrab)->XML
	cFile   := lower( cPathXml + (cArqTrab)->ARQUIVO )
else
	cFile   := ""
	if right( cChave, 4 ) == ".XML" .or. right( cChave, 4 ) == ".TXT"
		cExtensao := ""
	endif
	if File( cPathXml + cChave + cExtensao )
		cFile := lower( cPathXml + cChave + cExtensao )
	endif
	if Empty( cFile )
		if right( cChave, 4 ) == ".XML"
			if File( cPathXml + strTran( cChave, ".XML", "-procNfe.xml") )
				cFile := lower( cPathXml + strTran(cChave, ".XML","-procNfe.xml") )
			endif
		ElseIf cExtensao == ".xml"
			if File( cPathXml + cChave + "-procNfe.xml" )
				cFile := lower( cPathXml + cChave + "-procNfe.xml" )
			endif
		ElseIf File( cPathXml + cChave + ".txt" )
			cFile := lower( cPathXml + cChave + ".txt" )
		EndIf
	EndIf
	if Empty( cFile )
		if ! lQuiet
			cProblema := "Arquivo não encontrado!"
			oSay:Refresh()
		EndIf
		Return .F.
	EndIf
	/*
	if len( Alltrim( cChave ) ) >= 44 .and. ".xml" $ cFile		// DANFE
	_tipoNF := "D"
	elseif ".xml" $ cFile										// Ginfes
	_tipoNF := "G"
	elseif ".txt" $ cFile										// Prefeitura
	_tipoNF := "P"
	endif
	*/
	
	If ".txt" $ cFile										// Prefeitura
		_tipoNF := "P"
	Else
		cXml := u_LeXml(cFile)	  							// Lê XML e retorna conteúdo
		If Empty(cXml)
			If !lQuiet
				cProblema := "Arquivo XML vazio ou corrompido!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
		If "www.ginfes.com.br" $ lower(cXml)	// Ginfes
			_tipoNF := "G"
		ElseIf "<cteproc" $ lower(cXml)	   		// CT-e
			_tipoNF := "CTE"
		ElseIf "<retenvevento" $ lower(cXml) .Or. "<retcancnfe" $ lower(cXml)	// NF - CANCELADA
			_tipoNF := "_CA"
		Else									// DANFE
			_tipoNF := "D"
		EndIf
	EndIf
EndIf
If Empty(_tipoNF)
	If !lQuiet
		cProblema := "formato não identificado!"
		oSay:Refresh()
	EndIf
	Return .F.
EndIf

// carregar array aChvInfo

// C T - e
If _tipoNF == "CTE"
	aSize( aChvInfo, 30 )
	aFill( aChvInfo, "" )
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[03] := subStr(cChave,26,09)				// Documento
	aChvInfo[04] := subStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space( Len( SA2->A2_COD ) )			// Fornecedor
	aChvInfo[07] := Space( Len( SA2->A2_LOJA ) )		// Loja
	aChvInfo[08] := "CTE  "					  			// Espécie
	aChvInfo[09] := Space( Len( SA2->A2_EST ) )			// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[12] := 1									// Finalidade da DANFE - 19/12/2016 - Cristiam
	aChvInfo[15] := U_c2oXML( cXml )					// Carrega XML no Objeto
	If ValType( aChvInfo[15] ) != "O"
		if ! lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		endif
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
	_lcnpjx := .T.
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatário
		xTemp := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
		if xTemp != SM0->M0_CGC
			if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT") != "U"	// CNPJ Remetente
				xTemp := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
				if xTemp != SM0->M0_CGC
					_lcnpjx := .F.
					//if ! lQuiet
					//	cProblema := "Documento não é pra este CNPJ!"
					//	oSay:Refresh()
					//endif
					//aSize( aChvInfo, 0 )
					//return .F.
				EndIf
			Else		// Não é Destinatário e nem Remetente
				_lcnpjx := .F.
				//if ! lQuiet
				//	cProblema := "Documento não é pra este CNPJ!"
				//	oSay:Refresh()
				//endif
				//aSize( aChvInfo, 0 )
				//return .F.
			EndIf
		EndIf
	EndIf
	If !_lcnpjx
		if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT") != "U"	// CNPJ expedidor
			xTemp := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT
			if xTemp != SM0->M0_CGC
				_lcnpjx := .F.
			Else
				_lcnpjx := .T.
			EndIf
		EndIf
	EndIF
	If !_lcnpjx
		if ! lQuiet
			cProblema := "Documento não é pra este CNPJ!"
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		Return .F.
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dEmi:TEXT , "-", "" ) )
		dDatabase    := aChvInfo[05]
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dhEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( Left( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_dhEmi:TEXT, 10 ), "-", "" ) )
	EndIf
	
	// Avaliacao da Chave da NFE no Sefaz (Jonathan 29/01/2020)
	If .F. // Desativado
		cFormul		:= Iif(!Empty(aChvInfo[02]), aChvInfo[02], "N") 	// Formulario proprio (Usado na A103ConsNfeSef)
		cEspecie	:= aChvInfo[08] // Especie da nota		(Usado na A103ConsNfeSef)
		lRetDanfe	:= A103ConsNfeSef( aChvInfo[11] ) // u_A103ConsNfeSef( aChvInfo[11] )
		If !lRetDanfe // Invalido o retorno de Consulta NFe no Sefaz
			if !lQuiet
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
	EndIf
	
	If u_TrataSE4()				// Cond.Pagto (default: 000 - a Vista )
		aChvInfo[10] := SE4->E4_CODIGO
	Else
		if !lQuiet
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		Return .F.
	EndIf
	cCNPJ := Space(14)
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") != "U"
		cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
	EndIf
	SA2->(dbSetOrder(3) )
	If SA2->(!DbSeek( xFilial("SA2") + cCNPJ))
		If !CriarSA2()
			If !lQuiet
				cProblema := "Não foi possível criar Fornecedor!"
				oSay:Refresh()
			EndIf
			aSize( aChvInfo, 0 )
			Return .F.
		EndIf
	EndIf
	aChvInfo[06] := SA2->A2_COD				// Fornecedor
	aChvInfo[07] := SA2->A2_LOJA			// Loja
	aChvInfo[09] := SA2->A2_EST				// UF
	if lChkExist()		// checar existencia da NF se existir informar e bloquear
		aSize( aChvInfo, 0 )
		return .F.
	EndIf
	if !u_TrataSB1()		// Tratamento Produtos e Impostos
		if ! lQuiet
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		return .F.
	EndIf
	CargaImp()			// carrega Tag Impostos total do XML
EndIf

// D A N F E
if _tipoNF == "D"
	nFinNFe := 1	// Normal (default) - Finalidade da NF
	aSize( aChvInfo, 30 )
	aFill( aChvInfo, "" )
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[03] := subStr(cChave,26,09)				// Documento
	aChvInfo[04] := subStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space( Len( SA2->A2_COD ) )			// Fornecedor
	aChvInfo[07] := Space( Len( SA2->A2_LOJA ) )		// Loja
	aChvInfo[08] := "SPED "					  			// Espécie
	aChvInfo[09] := Space( Len( SA2->A2_EST ) )			// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[12] := 1									// Finalidade da DANFE - 19/12/2016 - Cristiam
	//		aChvInfo[11] := Alltrim( cChave )					// Chave DANFE
	/*
	cXml := U_LeXml( cFile )	  						// Lê XML e retorna conteúdo
	if Empty( cXml )
	cProblema := "Arquivo XML vazio ou corrompido!"
	oSay:Refresh()
	aSize( aChvInfo, 0 )
	return .F.
	endif
	*/
	aChvInfo[15] := u_c2oXML(cXml)					// Carrega XML no Objeto
	If ValType(aChvInfo[15]) != "O"
		If !lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		Endif
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	//TODO: Analisar o uso
	/*
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_tpNF:TEXT") != "U"	// Tipo do Documento
	If (aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_tpNF:TEXT != "0")
	If ! lQuiet
	cProblema := "Documento Não é Entrada!"
	oSay:Refresh()
	EndIf
	aSize( aChvInfo, 0 )
	Return .F.
	EndIf
	EndIf
	*/
	If Type("aChvInfo[15]:_NFEPROC:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFEPROC:_NFE"
	ElseIf Type("aChvInfo[15]:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFE"
	Else
		If !lQuiet
			cProblema := "Estrutura inicial do XML não tratada!"
			oSay:Refresh()
		EndIf
		Return .F.
	EndIf
	If Type(cTmpTag + ":_INFNFE:_IDE:_finNFe:TEXT") != "U"	// Finalidade do Documento
		xTemp := &(cTmpTag + ":_INFNFE:_IDE:_finNFe:TEXT")
		If xTemp $ "2;3"
			aChvInfo[01] := "C"
		ElseIf xTemp == "4"
			aChvInfo[01] := "D"
		EndIf
	EndIf
	if Type(cTmpTag + ":_INFNFE:_IDE:_NNF:TEXT") != "U"	// Numero do Documento
		aChvInfo[03] := replicate("0", 9) + alltrim(&(cTmpTag + ":_INFNFE:_IDE:_NNF:TEXT"))
		aChvInfo[03] := right( aChvInfo[03], 9 )
	endif
	if Type(cTmpTag + ":_INFNFE:_IDE:_SERIE:TEXT") != "U"	// Série do Documento
		aChvInfo[04] := padr(&(cTmpTag + ":_INFNFE:_IDE:_SERIE:TEXT"), 3 )
	endif
	if Type(cTmpTag + ":_INFNFE:_ID:TEXT") != "U"	// Chave DANFE
		aChvInfo[11] := substr(&(cTmpTag + ":_INFNFE:_ID:TEXT"), 4)
	endif
	if Type(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatário
		if Type(cTmpTag + ":_INFNFE:_IDE:_finNFe:TEXT") != "U"	// Finalidade NF
			nFinNFe := Val(&(cTmpTag + ":_INFNFE:_IDE:_finNFe:TEXT"))
		EndIf
		If nFinNFe == 4		// devolução / Formulário Próprio
			aChvInfo[12] := 4
			xTemp := &(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT")
			//xTemp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
			If xTemp != SM0->M0_CGC
				aChvInfo[12] := 1
				xTemp := &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT")
			EndIf
		ElseIf nFinNFe == 1
			xTemp := &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT")
			If Type(cTmpTag + ":_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") != "U"
				xTemp := &(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT")
				If (xTemp == SM0->M0_CGC) .And. (xTemp != &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT"))
					nFinNFe			:= 4
					aChvInfo[12]	:= 4
					aChvInfo[01]	:= "D"
				Else
					aChvInfo[12] := 1
					xTemp := &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT")
				EndIf
			EndIf
		Else
			xTemp := &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT")
		EndIf
		If xTemp != SM0->M0_CGC
			// DESCOMENTAR NO CLIENTE
			If !lQuiet
				cProblema := "Documento não é pra este CNPJ!"
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
		_cCgcDes := xTemp
	EndIf
	If Type(cTmpTag + ":_INFNFE:_IDE:_dEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( &(cTmpTag + ":_INFNFE:_IDE:_dEmi:TEXT") , "-", "" ) )
	EndIf
	if Type(cTmpTag + ":_INFNFE:_IDE:_dhEmi:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD( StrTran( Left( &(cTmpTag + ":_INFNFE:_IDE:_dhEmi:TEXT"), 10 ), "-", "" ) )
	EndIf
	if Type(cTmpTag + ":_INFNFE:_IDE:_dhSaiEnt:TEXT") != "U"	// Saída
		aChvInfo[05] := StoD( StrTran( Left( &(cTmpTag + ":_INFNFE:_IDE:_dhSaiEnt:TEXT"), 10 ), "-", "" ) )
	EndIf
	// If (aChvInfo[05] != CtoD("  /  /  "))
	// 	dDatabase := aChvInfo[05]
	// EndIf
	
	// Avaliacao da Chave da NFE no Sefaz (Jonathan 29/01/2020)
	If .F. // Desativado
		cFormul		:= Iif(!Empty(aChvInfo[02]), aChvInfo[02], "N") 	// Formulario proprio (Usado na A103ConsNfeSef)
		cEspecie	:= aChvInfo[08] // Especie da nota		(Usado na A103ConsNfeSef)
		lRetDanfe	:= A103ConsNfeSef( aChvInfo[11] ) // u_A103ConsNfeSef( aChvInfo[11] )
		If !lRetDanfe // Invalido o retorno de Consulta NFe no Sefaz
			If !lQuiet
				oSay:Refresh()
			EndIf
			aSize(aChvInfo, 0)
			Return .F.
		EndIf
	EndIf
	
   	If u_TrataSE4()				// Cond.Pagto (default: 000 - a Vista )
		aChvInfo[10] := SE4->E4_CODIGO
	Else
		if !lQuiet
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	cCNPJ := Space(14)
	If nFinNFe == 4		// devolução / Formulário Próprio
		If Type(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT") != "U"
			cCNPJ := &(cTmpTag + ":_INFNFE:_DEST:_CNPJ:TEXT")
		ElseIf Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") != "U"
			cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
		EndIf
		If AllTrim(cCNPJ) == AllTrim(SM0->M0_CGC)
			If Type(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT") != "U"
				cCNPJ := &(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT")
			ElseIf Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") != "U"
				cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
			EndIf
		EndIf
	Else
		If Type(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT") != "U"
			cCNPJ := &(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT")
		Elseif Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") != "U"
			cCNPJ := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
		EndIf
	EndIf
	// cCNPJ := subStr(cChave,07,14)		// CNPJ Emissor
	if aChvInfo[01] $ "D/B" .or. aChvInfo[12] == 4
		
		SA1->( dbSetOrder(3) )
		if ! SA1->( dbSeek( xFilial("SA1") + cCNPJ) )
			if ! U_criarSA1()
				if ! lQuiet
					cProblema := "Não foi possível criar Cliente!"
					oSay:Refresh()
				endif
				aSize( aChvInfo, 0 )
				return .F.
			endif
		endif
		aChvInfo[06] := SA1->A1_COD				// Cliente
		aChvInfo[07] := SA1->A1_LOJA			// Loja
		aChvInfo[09] := SA1->A1_EST				// UF
	else
		SA2->( dbSetOrder(3) )
		if ! SA2->( dbSeek( xFilial("SA2") + cCNPJ) )
			if ! criarSA2()
				if ! lQuiet
					cProblema := "Não foi possível criar Fornecedor!"
					oSay:Refresh()
				endif
				aSize( aChvInfo, 0 )
				return .F.
			endif
		endif
		aChvInfo[06] := SA2->A2_COD				// Fornecedor
		aChvInfo[07] := SA2->A2_LOJA			// Loja
		aChvInfo[09] := SA2->A2_EST				// UF
	endif
	_cCgcEmi := cCNPJ
	if lChkExist()		// checar existencia da NF se existir informar e bloquear
		aSize( aChvInfo, 0 )
		return .F.
	endif
	if !u_TrataSB1()		// Tratamento Produtos e Impostos
		if !lQuiet
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		Return .F.
	EndIf
	CargaImp()			// carrega Tag Impostos total do XML
EndIf
/*-------------------------------------------------------------
G I N F E S
-------------------------------------------------------------*/
if _tipoNF == "G"
	
	aSize( aChvInfo, 0 )
	/*
	cXml := U_LeXml( cFile )	  							// Lê XML e retorna conteúdo
	if Empty( cXml )
	cProblema := "Arquivo XML vazio ou corrompido!"
	oSay:Refresh()
	return .F.
	endif
	*/
	if ! "www.ginfes.com.br" $ lower( cXml )
		if ! lQuiet
			cProblema := "Arquivo não é do formato GINFES!"
		endif
		return .F.
	endif
	
	oXML := U_c2oXML( cXml )					// Carrega XML no Objeto
	If ValType( oXML ) != "O"
		if ! lQuiet
			cProblema := "Arquivo XML corrompido!"
		endif
		return .F.
	endif
	
	if Type("oXml:_NS2_NFSE:_NS2_NFSE") != "U"
		aNotas := iif( Type("oXml:_NS2_NFSE:_NS2_NFSE") == "A", oXml:_NS2_NFSE:_NS2_NFSE, { oXml:_NS2_NFSE:_NS2_NFSE } )
	endif
	
	if len( aNotas ) == 0
		if ! lQuiet
			cProblema := "Não encontrada NFS-e no arquivo!"
		endif
		return .F.
	endif
	
	NFServico( aNotas )		// chama a inclusão das NF de Serviço
	
	aSize( aChvInfo, 0 )
	cProblema := ""
endif
/*-------------------------------------------------------------
P R E F E I T U R A
-------------------------------------------------------------*/
if _tipoNF == "P"
	
	aSize( aChvInfo, 0 )
	
	aNotas := U_LeTXT( cFile )	  							// Lê XML e retorna conteúdo
	if len( aNotas ) == 0
		if ! lQuiet
			cProblema := "Arquivo TXT vazio ou corrompido!"
		endif
		return .F.
	endif
	
	NFServico( aNotas )		// chama a inclusão das NF de Serviço
	
	aSize( aChvInfo, 0 )
	cProblema := ""
	
endif

/*-------------------------------------------------------------
C A N C E L A M E N T O
-------------------------------------------------------------*/
If _tipoNF == "_CA"
	aSize( aChvInfo, 30 )
	aFill( aChvInfo, "" )
	
	aChvInfo[01] := "_CA"								// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[03] := SubStr(cChave,26,09)				// Documento
	aChvInfo[04] := SubStr(cChave,23,03)				// Série
	aChvInfo[05] := CtoD("  /  /  ")					// Emissão
	aChvInfo[06] := Space( Len( SA2->A2_COD ) )			// Fornecedor
	aChvInfo[07] := Space( Len( SA2->A2_LOJA ) )		// Loja
	aChvInfo[08] := "SPED "					  			// Espécie
	aChvInfo[09] := Space( Len( SA2->A2_EST ) )			// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	
	aChvInfo[11] := Left( cChave, 44 )					// Chave DANFE
	
	aChvInfo[12] := 1									// Finalidade da DANFE (compatibilização) - 19/12/2016 - Cristiam
	
	aChvInfo[15] := U_c2oXML( cXml )					// Carrega XML no Objeto
	If ValType( aChvInfo[15] ) != "O"
		If ! lQuiet
			cProblema := "Arquivo XML corrompido!"
			oSay:Refresh()
		EndIf
		aSize( aChvInfo, 0 )
		
		Return .F.
	EndIf
	
	If Type("aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_chNFE:TEXT") != "U"
		aChvInfo[11] := aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_chNFE:TEXT	// Chave DANFE
		aChvInfo[03] := SubStr(aChvInfo[11],26,09) 	// Numero do Documento
		aChvInfo[04] := SubStr(aChvInfo[11],23,03)	// Série do Documento
	EndIf
	xTemp := SubStr(aChvInfo[11], 7, 14) // CNPJ Emitente
	If xTemp != SM0->M0_CGC
		If ! lQuiet
			cProblema := "Documento não é deste CNPJ!"
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	If Type("aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_dhRegEvento:TEXT") != "U"	// Emissão
		aChvInfo[05] := StoD(StrTran(Left(aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_dhRegEvento:TEXT, 10), "-", ""))
		dDatabase    := aChvInfo[05]
	EndIf
	If Type("aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_CNPJDest:TEXT") != "U"	// CNPJ Destinatário
		cCNPJ := PadR(aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_CNPJDest:TEXT,14)
	Else
		cCNPJ := Space(14)
	EndIf
	If Empty(cCNPJ)
		If Type("aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_CPFDest:TEXT") != "U"	// CPF Destinatário
			cCNPJ := PadR(aChvInfo[15]:_retEnvEvento:_retEvento:_infEvento:_CPFDest:TEXT,11)
		Else
			cCNPJ := Space(11)
		EndIf
	EndIf
	If !(lChkExist())	// checar existencia da NF se não existir informar e bloquear
		aSize( aChvInfo, 0 )
		Return .F.
	EndIf
	If aChvInfo[01] $ "D/B"
		SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
		lExistCad := SA1->(DbSeek(xFilial("SA1") + aChvInfo[06] + aChvInfo[07]))
	Else
		SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
		lExistCad := SA2->(DbSeek(xFilial("SA2") + aChvInfo[06] + aChvInfo[07]))
	EndIf
	If lExistCad
		If AllTrim(cCNPJ) != AllTrim(IIF(aChvInfo[01] $ "D/B", SA1->A1_CGC, SA2->A2_CGC))
			If !lQuiet
				cProblema := IIF(aChvInfo[01] $ "D/B", "Cliente ", "Fornecedor ") + "não confere com a NF!"
				oSay:Refresh()
			EndIf
			aSize( aChvInfo, 0 )
			Return .F.
		EndIf
	Else
		If !lQuiet
			cProblema := IIF(aChvInfo[01] $ "D/B", "Cliente ", "Fornecedor ") + "não Cadastrado!"
			oSay:Refresh()
		EndIf
		aSize(aChvInfo, 0)
		Return .F.
	EndIf
	If aChvInfo[01] $ "D/B"
		aChvInfo[06] := SA1->A1_COD				// Fornecedor
		aChvInfo[07] := SA1->A1_LOJA			// Loja
		aChvInfo[09] := SA1->A1_EST				// UF
	Else
		aChvInfo[06] := SA2->A2_COD				// Fornecedor
		aChvInfo[07] := SA2->A2_LOJA			// Loja
		aChvInfo[09] := SA2->A2_EST				// UF
	EndIf
EndIf
//ConOut("fValChv: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes( "fValChv", "Concluido!" )
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NFServico ºAutor  ³Cristiam Rossi      º Data ³  19/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratativa NF Serviço e diálogo das inclusões               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML automatizado                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function NFServico( aNotas )
Local _nX
Local xTemp := ""
Local cMsg
Local nGravou := 0
Private aNFS := {}
Private lFechar := .F.
//ConOut("NFServico: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes( "NFServico", "Iniciando..." )
For _nX := 1 to len( aNotas )
	/*
	if Aviso("Nota de Serviço", "Notas "+Alltrim(Str(_nX))+" / "+Alltrim(Str( len( aNotas ) ))+", continua?", {"Sim", "Não"}) != 1
	exit
	endif
	*/
	cProblema := ""
	aSize( aChvInfo, 30 )
	aFill( aChvInfo, "" )
	aChvInfo[01] := "N"									// Tipo
	aChvInfo[02] := " "									// Formulário Próprio
	aChvInfo[06] := Space( Len( SA2->A2_COD ) )			// Fornecedor
	aChvInfo[07] := Space( Len( SA2->A2_LOJA ) )		// Loja
	aChvInfo[08] := "RPS  "					  			// Espécie
	aChvInfo[09] := Space( Len( SA2->A2_EST ) )			// UF
	aChvInfo[10] := "000"								// Cond.Pagto (default: a Vista )
	aChvInfo[12] := 1									// Finalidade da DANFE (apenas Compatibilização) - 19/12/2016 - Cristiam
	if _tipoNF == "P"
		aNFS := aNotas[_nX]
		aChvInfo[03] := right( Replicate("0",9)+subStr(aNFS,2,8), len(SF1->F1_DOC) )	// Documento
		aChvInfo[04] := padR(Alltrim( subStr(aNFS,37,5) ), len(SF1->F1_SERIE) )	// Série
		aChvInfo[05] := StoD( subStr(aNFS,10,10) )		// Emissão
		xTemp        := subStr(aNFS,519,14)				// CNPJ Tomador
	Else		// GINFES
		aNFS := aNotas[_nX]
		if U_ztipo("aNFS:_NS3_IDENTIFICACAONFSE:_NS3_NUMERO:TEXT") != "U"
			aChvInfo[03] := right( replicate("0",9)+aNFS:_NS3_IDENTIFICACAONFSE:_NS3_NUMERO:TEXT, len(SF1->F1_DOC) )	// Documento
		endif
		
		if U_ztipo("aNFS:_NS3_IDENTIFICACAONFSE:_NS3_SERIE:TEXT") != "U"
			aChvInfo[04] := padR(right( replicate("0",3)+aNFS:_NS3_IDENTIFICACAONFSE:_NS3_SERIE:TEXT, 3 ), len( SF2->F1_SERIE ) )	// Série
		else
			aChvInfo[04] := space(3)
		EndIf
		if U_ztipo("aNFS:_NS3_DATAEMISSAO:TEXT") != "U"
			aChvInfo[05] := StoD( strTran( left( aNFS:_NS3_DATAEMISSAO:TEXT, 10 ), "-", "") )			// Emissão
		else
			aChvInfo[05] := CtoD("  /  /  ")
		EndIf
		if U_ztipo("aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT") != "U"	// CNPJ Destinatário
			xTemp := aNFS:_NS3_TOMADORSERVICO:_NS3_IDENTIFICACAOTOMADOR:_NS3_CPFCNPJ:_NS3_CNPJ:TEXT
		EndIf
	EndIf
	If xTemp != SM0->M0_CGC
		// DESCOMENTAR NO CLIENTE
		if ! lQuiet
			cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" não é para o cliente"
			MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
			exit
		EndIf
		loop
	EndIf
	If _tipoNF == "P"
		cCNPJ := Alltrim(subStr(aNFS,71,14))				// Emissor / Prestador
		if Empty( cCNPJ )
			if ! lQuiet
				cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" Prestador não encontrado no arquivo!"
				MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
			EndIf
			loop
		EndIf
	Else		// GINFES
		If U_ztipo("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT") != "U"	// CNPJ Emissor
			cCNPJ := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT
		EndIf
		If U_ztipo("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CPF:TEXT") != "U"	// CNPJ Emissor
			cCNPJ := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CPF:TEXT
		EndIf
		If Empty( cCNPJ )
			If !lQuiet
				cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" Prestador não encontrado no arquivo!"
				MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
			EndIf
			Loop
		EndIf
	EndIf
	SA2->( dbSetOrder(3) )
	If SA2->(!DbSeek( xFilial("SA2") + cCNPJ))
		If !CriarSA2()
			If !lQuiet
				cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" não criou Fornecedor!"
				MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
			EndIf
			Loop
		EndIf
	EndIf
	aChvInfo[06] := SA2->A2_COD				// Fornecedor
	aChvInfo[07] := SA2->A2_LOJA			// Loja
	aChvInfo[09] := SA2->A2_EST				// UF
	If lChkExist()		// checar existencia da NF se existir informar e bloquear
		If !lQuiet
			cProblema := "A "+Alltrim(Str(_nX))+" NFS-e de N: "+aChvInfo[03]+" já existe!"
			MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
		EndIf
		Loop
	EndIf
	//		if ! lQuiet
	cMsg := "Nota "+ Alltrim(Str(_nX))+" / "+Alltrim(Str( len( aNotas ) )) + CRLF
	cMsg += "Nº: " + Alltrim(aChvInfo[03])
	If !Empty( aChvInfo[04] )
		cMsg += " / " + Alltrim( aChvInfo[04] )
	EndIf
	cMsg += " - Emissão: "+ DtoC(aChvInfo[05]) + CRLF
	cMsg += "Emissor: "+ SA2->A2_NOME + CRLF
	If Len(alltrim(cCNPJ)) == 14
		cMsg += "CNPJ: "+ Transform(cCNPJ, "@R 99.999.999/9999-99")
	Else
		cMsg += "CPF: " + Transform(cCNPJ, "@R 999.999.999-99")
	EndIf
	cMsg += CRLF + CRLF + "Efetuar importação?"
	if Aviso("Nota de Serviço", cMsg, {"Sim", "Não"},2) != 1
		Exit
	EndIf
	//		endif
	If !u_TrataSB1()		// Tratamento Produtos e Impostos
		If !lQuiet
			MsAguarde({|| sleep(3000)}, "", cProblema, .T. )
		EndIf
		Loop
	EndIf
	// impostos
	CargaImp()			// carrega Tag Impostos total do XML
	// NFS-e mata103
	If len( aChvInfo ) > 0
		A103NFiscal( "SF1", SF1->( Recno() ), 3 )		// chama Inclusão Documento de Entrada
		If Len( aChvInfo ) > 0
			if SF1->F1_DOC == aChvInfo[3] .and. SF1->F1_SERIE == aChvInfo[4] .and. SF1->F1_FORNECE == aChvInfo[6] .and. SF1->F1_LOJA == aChvInfo[7]
				// foi cadastrado o XML de Entrada!
				nGravou++
			EndIf
		EndIf
	EndIf
Next
If nGravou > 0
	If ! lQuiet
		If nGravou < len( aNotas ) .and. aviso("Importação NF Serviço", "Nem todos os documentos foram importados, deseja mover o arquivo para a pasta lidos?", {"Ok", "Não"}) != 1
			Return
		EndIf
	EndIf
	u_fMoverArq(cFile)
EndIf
//ConOut("NFServico: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes( "NFServico", "Concluido!" )
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
Local lExist	:= .F.
Local cQuery	:= ""
Local cTmpAlias	:= ""
//ConOut("lChkExist: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes( "lChkExist", "Iniciando..." )
If _tipoNF == "_CA" // Cancelamento
	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " SF1 " + CRLF
	cQuery += "WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "' " + CRLF
	cQuery += "	AND SF1.F1_CHVNFE = '" + aChvInfo[11] + "' " + CRLF
	cQuery += "	AND SF1.D_E_L_E_T_ <> '*' "
	cTmpAlias := GetNextAlias()
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), cTmpAlias, .F., .T.)
	lExist := !((cTmpAlias)->(Eof()))
	If lExist
		aChvInfo[01] := (cTmpAlias)->F1_TIPO
		aChvInfo[03] := (cTmpAlias)->F1_DOC
		aChvInfo[04] := (cTmpAlias)->F1_SERIE
		aChvInfo[06] := (cTmpAlias)->F1_FORNECE
		aChvInfo[07] := (cTmpAlias)->F1_LOJA
	Else
		If !(lQuiet)
			cProblema := "Documento não cadastrado!"
			oSay:Refresh()
		EndIf
	EndIf
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
Else
	SF1->( dbSetOrder(1) )	// F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->( dbSeek( xFilial("SF1") + aChvInfo[03] + aChvInfo[04] + aChvInfo[06] + aChvInfo[07], .T. ) )
		if ! lQuiet
			cProblema := "Documento cadastrado!"
			oSay:Refresh()
		EndIf
		If Type("nJaLidos") == "N"
			nJaLidos++
		EndIf
		//			aSize( aChvInfo, 0 )
		u_fMoverArq( cFile )
		Return .T.
	EndIf
EndIf
//ConOut("lChkExist: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes( "lChkExist", "Concluido!" )
Return lExist

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ CriarSA2 ºAutor  ³ Cristiam Rossi     º Data ³  09/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criação de Fornecedor - SA2                                º±±
±±º          ³ com informações do XML                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO Contabilidade - XML                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CriarSA2()
Local aArea  := getArea()
Local lSXE   := .F.
Local cConta := GetMV("MV_XCTAFOR")
Local nI
Local cTmpTag := ""
//ConOut("CriarSA2: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes( "CriarSA2", "Iniciando..." )
Begin Sequence
DbSelectArea("SA2")
RegToMemory("SA2")
M->A2_FILIAL  := xFilial("SA2")
If Empty( M->A2_COD )
	lSXE := .T.
	M->A2_COD  := U_tstSXE( "SA2", "A2_COD")		// garante que o Numerador não exista na base
	M->A2_LOJA := StrZero( 1, len( SA2->A2_LOJA ) )
EndIf
// DANFE
If _tipoNF == "D"
	If Type("aChvInfo[15]:_NFEPROC:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFEPROC:_NFE"
	ElseIf Type("aChvInfo[15]:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFE"
	Else
		If !(lQuiet)
			cProblema := "Estrutura inicial do XML não tratada!"
			oSay:Refresh()
		EndIf
		Return .F.
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_xNome:TEXT") != "U"
		M->A2_NOME := Upper(AllTrim(NoAcento( U_xSoDigit(&(cTmpTag + ":_INFNFE:_EMIT:_xNome:TEXT")) )))
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_xFant:TEXT") != "U"
		M->A2_NREDUZ := Upper(AllTrim(NoAcento( &(cTmpTag + ":_INFNFE:_EMIT:_xFant:TEXT") )))
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT") != "U"
		M->A2_CGC := &(cTmpTag + ":_INFNFE:_EMIT:_CNPJ:TEXT")
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_IE:TEXT") != "U"
		M->A2_INSCR := &(cTmpTag + ":_INFNFE:_EMIT:_IE:TEXT")
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xLgr:TEXT") != "U"
		M->A2_END := Upper(AllTrim(NoAcento( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xLgr:TEXT") )))
		If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_nro:TEXT") != "U" .and. ! Empty(&(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_nro:TEXT"))
			M->A2_END += ", " + &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_nro:TEXT")
		EndIf
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xBairro:TEXT") != "U"
		M->A2_BAIRRO := Upper(AllTrim(NoAcento( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xBairro:TEXT") )))
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_cMun:TEXT") != "U"
		M->A2_COD_MUN := Right( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_cMun:TEXT"), 5)
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xMun:TEXT") != "U"
		M->A2_MUN := Upper(AllTrim(NoAcento( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xMun:TEXT") )))
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT") != "U"
		M->A2_EST := &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT")
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT") != "U"
		M->A2_CEP := &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT")
	EndIf
	if Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xPais:TEXT") != "U"
		M->A2_PAIS := &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_xPais:TEXT")
	EndIf
	If Type(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_fone:TEXT") != "U"
		M->A2_DDD     := Left( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_fone:TEXT"), 2 )
		M->A2_TEL     := Substr( &(cTmpTag + ":_INFNFE:_EMIT:_ENDEREMIT:_fone:TEXT"), 3 )
	EndIf
EndIf
// CT-e
If _tipoNF == "CTE"
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_xNome:TEXT") != "U"
		M->A2_NOME := Upper(AllTrim(NoAcento( U_xSoDigit( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_xNome:TEXT ) )))
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_xFant:TEXT") != "U"
		M->A2_NREDUZ := Upper(AllTrim(NoAcento( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_xFant:TEXT )))
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") != "U"
		M->A2_CGC := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT") != "U"
		M->A2_INSCR := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xLgr:TEXT") != "U"
		M->A2_END := Upper(AllTrim(NoAcento( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xLgr:TEXT )))
		If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_nro:TEXT") != "U" .and. ! Empty( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_nro:TEXT )
			M->A2_END += ", " + aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_nro:TEXT
		EndIf
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xBairro:TEXT") != "U"
		M->A2_BAIRRO := Upper(AllTrim(NoAcento( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xBairro:TEXT )))
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_cMun:TEXT") != "U"
		M->A2_COD_MUN := Upper(AllTrim(NoAcento( Right( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_cMun:TEXT, 5) )))
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xMun:TEXT") != "U"
		M->A2_MUN := Upper(AllTrim(NoAcento( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xMun:TEXT )))
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT") != "U"
		M->A2_EST := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CEP:TEXT") != "U"
		M->A2_CEP := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CEP:TEXT
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xPais:TEXT") != "U"
		M->A2_PAIS := aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_xPais:TEXT
	EndIf
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_fone:TEXT") != "U"
		M->A2_DDD     := Left( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_fone:TEXT, 2 )
		M->A2_TEL     := Substr( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_fone:TEXT, 3 )
	EndIf
EndIf
// GINFES
if _tipoNF == "G"
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_RAZAOSOCIAL:TEXT") != "U"
		M->A2_NOME := Upper(AllTrim(NoAcento( U_xSoDigit( aNFS:_NS3_PRESTADORSERVICO:_NS3_RAZAOSOCIAL:TEXT ) )))
	endif
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_NOMEFANTASIA:TEXT") != "U"
		M->A2_NREDUZ := Upper(AllTrim(NoAcento( aNFS:_NS3_PRESTADORSERVICO:_NS3_NOMEFANTASIA:TEXT )))
	endif
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT") != "U"
		M->A2_CGC := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_CNPJ:TEXT
	endif
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_INSCRICAOMUNICIPAL:TEXT") != "U"
		M->A2_INSCRM := aNFS:_NS3_PRESTADORSERVICO:_NS3_IDENTIFICACAOPRESTADOR:_NS3_INSCRICAOMUNICIPAL:TEXT
	endif
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT") != "U"
		M->A2_END := Upper(AllTrim(NoAcento( aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ENDERECO:TEXT )))
		if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT") != "U"
			M->A2_END += ", " + aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_NUMERO:TEXT
		EndIf
	EndIf
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT") != "U"
		M->A2_BAIRRO := Upper(AllTrim(NoAcento( aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_BAIRRO:TEXT )))
	EndIf
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT") != "U"
		M->A2_COD_MUN := Right( aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CIDADE:TEXT, 5)
	EndIf
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT") != "U"
		M->A2_EST := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_ESTADO:TEXT
	EndIf
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT") != "U"
		M->A2_CEP := aNFS:_NS3_PRESTADORSERVICO:_NS3_ENDERECO:_NS3_CEP:TEXT
	EndIf
	CC2->( dbSetOrder(1) )
	if CC2->( dbSeek( xFilial("CC2") + M->A2_EST + M->A2_COD_MUN) )
		M->A2_MUN := CC2->CC2_MUN
	EndIf
	M->A2_PAIS    := "105"
	if Type("aNFS:_NS3_PRESTADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT") != "U"
		//			M->A2_DDD     :=
		M->A2_TEL     := aNFS:_NS3_PRESTADORSERVICO:_NS3_CONTATO:_NS3_TELEFONE:TEXT
	EndIf
	if Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U"
		M->A2_SIMPNAC := aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT		// 1=SIM; 2=NAO
	EndIf
EndIf
// Prefeitura
if _tipoNF == "P"
	M->A2_NOME    := Upper(NoAcento(AllTrim( U_xSoDigit( Alltrim( subStr( aNFS, 85, 75 ) ) ) )))
	M->A2_NREDUZ  := Upper(NoAcento(AllTrim( M->A2_NOME )))
	M->A2_CGC     := Alltrim( subStr( aNFS, 71, 14) )
	M->A2_INSCRM  := subStr( aNFS, 62, 8 )
	M->A2_END     := Upper(NoAcento(Alltrim( SubStr(aNFS, 160, 3) )))
	M->A2_END     += Upper(NoAcento(AllTrim( iif( Empty(M->A2_END), "", " ") + Alltrim( subStr( aNFS, 163, 50 )) )))
	M->A2_END     += ", " + Alltrim( subStr( aNFS, 213, 10 ) )
	M->A2_COMPLEM := Alltrim( subStr( aNFS, 223, 30 ) )
	M->A2_BAIRRO  := Upper(NoAcento(AllTrim( subStr(aNFS, 253, 30) )))
	M->A2_MUN     := Alltrim( subStr( aNFS, 283, 50 ) )
	M->A2_EST     := subStr( aNFS, 333, 2 )
	M->A2_CEP     := subStr( aNFS, 335, 8 )
	CC2->( dbSetOrder(3) )
	if CC2->( dbSeek( xFilial("CC2") + M->A2_EST + M->A2_MUN) )
		M->A2_COD_MUN := CC2->CC2_CODMUN
	endif
	M->A2_PAIS    := "105"
	M->A2_EMAIL   := subStr( aNFS, 343, 75 )
	M->A2_SIMPNAC := iif( subStr( aNFS, 418, 1 ) > "0", "1", "2" )
EndIf
M->A2_TIPO := iif( len( M->A2_CGC ) > 11, "J", "F" )
M->A2_CONTA  := cConta
/*
if empty( M->A2_PAIS )
M->A2_PAIS    := "105"
endif
*/
If M->A2_EST != "EX"
	M->A2_PAIS    := "105"
	M->A2_CODPAIS := "01058"
EndIf
RecLock("SA2", .T.)
For nI := 1 to FCount()
	FieldPut( nI, &("M->"+FieldName(nI)) )
Next
MsUnlock()

u_M020INC(.F.)
// u_addItCtb("F" + SA2->A2_COD, SA2->A2_NOME, "2" /*Despesa*/ )

End Sequence
If lSXE
	If Left(M->A2_NOME, Min( len(M->A2_NOME), len(SA2->A2_NOME) )) == left( SA2->A2_NOME, Min( len(M->A2_NOME), len(SA2->A2_NOME) ))
		ConfirmSX8()
	Else
		RollBackSx8()
	EndIf
EndIf
RestArea(aArea)
//ConOut("CriarSA2: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes( "CriarSA2", "Concluido!" )
Return Left(M->A2_NOME, Min( len(M->A2_NOME), len(SA2->A2_NOME) )) == left( SA2->A2_NOME, Min( len(M->A2_NOME), len(SA2->A2_NOME) ))

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
Local cNatX   := ""		// Natureza para Serviços
Local cTmpTag := ""
//ConOut("CargaImp: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes( "CargaImp", "Iniciando..." )
if _tipoNF == "D"
	If Type("aChvInfo[15]:_NFEPROC:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFEPROC:_NFE"
	ElseIf Type("aChvInfo[15]:_NFE") == "O"
		cTmpTag := "aChvInfo[15]:_NFE"
	Else
		If !(lQuiet)
			cProblema := "Estrutura inicial do XML não tratada!"
			oSay:Refresh()
		EndIf
		Return .F.
	EndIf
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vFrete:TEXT") != "U"
		nFrete := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vFrete:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vSeg:TEXT") != "U"
		nSeguro := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vSeg:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vOutro:TEXT") != "U"
		nOutros := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vOutro:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vDesc:TEXT") != "U"
		nDescon := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vDesc:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vProd:TEXT") != "U"
		nProd := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vProd:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vNF:TEXT") != "U"
		nNF := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vNF:TEXT"))
	endif
	if Type(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vTotTrib:TEXT") != "U"
		nSubst := Val(&(cTmpTag + ":_INFNFE:_total:_ICMSTot:_vTotTrib:TEXT"))
	endif
	cNatX := cNatNFE		// Natureza para DANFE
	// S E R V I Ç O S
ElseIf _tipoNF == "G"		// GINFES
	if Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT") != "U"
		nProd := aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT
	endif
	nNF   := nProd
	if Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U" .and. aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT == "1"
		cNatX := cNatSSN
	else
		cNatX := cNatISS
	EndIf
	if Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORPIS:TEXT") != "U" .or. ;
		Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORCOFINS:TEXT") != "U" .or. ;
		Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORINSS:TEXT") != "U" .or. ;
		Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORIR:TEXT") != "U" .or. ;
		Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORCSLL:TEXT") != "U"
		cNatX := cNatSRT
	endif
ElseIf _tipoNF == "CTE"
	if Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT") != "U"			// CT-e
		nProd := Val( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT )
		nNF   := nProd
	endif
	cNatX := cNatNFE		// Natureza para DANFE
Else		// Prefeitura
	nProd := Val( subStr( aNFS, 448, 15 ) ) / 100
	nNF   := nProd
	If subStr( aNFS, 418, 1 ) > "0"
		cNatX := cNatSSN
	Else
		cNatX := cNatISS
	EndIf
	if _vLayout == "004"
		if val( subStr( aNFS, 1037, 15 ) ) > 0 .or. ;		// PIS
			val( subStr( aNFS, 1052, 15 ) ) > 0 .or. ;		// COFINS
			val( subStr( aNFS, 1067, 15 ) ) > 0 .or. ;		// INSS
			val( subStr( aNFS, 1082, 15 ) ) > 0 .or. ;		// IR
			val( subStr( aNFS, 1097, 15 ) ) > 0				// CSSL
			cNatX := cNatSRT
		endif
	endif
endif
aChvInfo[30] := { nFrete, nSeguro, nOutros, nDescon, nProd, nNF, nSubst }
SA2->( dbSetOrder(1) )
If SA2->(DbSeek( xFilial("SA2") + aChvInfo[06] + aChvInfo[07]))
	RecLock("SA2", .F.)
	SA2->A2_NATUREZ := cNatX		// Natureza serviços
	MsUnlock()
EndIf
//ConOut("CargaImp: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes( "CargaImp", "Concluido!" )
Return

/*/
Log de Alterações
Gera log de alterações no arquivo de log do sistema
@author Túlio Henrique 
@since 28/05/2024
/*/
Static Function U_LogAlteracoes(cFunc,cStatus)

local cinfolog := cFunc + ": " + DtoC(Date()) + " " + Time() + " " + cUserName + " " + cStatus

FWLogMsg(;
        "INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
        ,;          //cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        "logCargaSD1",;//cGroup         - Informe o Id do agrupador de mensagem de Log
        ,;          //cCategory      - Informe o Id da categoria da mensagem
        ,;          //cStep          - Informe o Id do passo da mensagem
        ,;          //cMsgId         - Informe o Id do código da mensagem
        cinfolog,;  //cMessage       - Informe a mensagem de log. Limitada à 10K
        ,;          //nMensure       - Informe a uma unidade de medida da mensagem
        ,;          //nElapseTime    - Informe o tempo decorrido da transação
        ;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
    ) 

return 
