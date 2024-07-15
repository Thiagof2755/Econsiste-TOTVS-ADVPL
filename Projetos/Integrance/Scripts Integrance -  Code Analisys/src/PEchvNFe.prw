#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PEchvNFE  ºAutor  ³Microsiga           º Data ³  08/09/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para encapsular tratamentos evitando manutenções    º±±
±±º          ³ acidentais                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//@history 25/05/2022, Johny Wendel Fabritech,inclussão da validação sobre o array aChvInfo[20].


User Function PEchvNFe( cPar1, xPar2, xPar3, xPar4 )
	Local cPE   := Alltrim( Upper( cPar1 ) )
	Local xRet  := nil
	Local _nOld := 1
	Local xI
	Local nX 

	If cPE == "MTA103MNU"		// adição das rotinas XML e Lote XML
		aadd( aRotina, {"Importação XML"     ,"U_GETCHVNFE", 0, 3} )
		aadd( aRotina, {"Importação Lote XML","U_GETLOTNF" , 0, 3} )

	ElseIf cPE == "MA410MNU"		// adição das rotinas XML e Lote XML
		aadd( aRotina, {"Importação XML"     ,"U_GETCHVSNF", 0, 3} )
		aadd( aRotina, {"Importação Lote XML","U_GETLOTNF" , 0, 3} )

	ElseIf cPE == "MT103NFE"		// preenche Cabeçalho NFe
		if isInCallStack("U_GETCHVNFE") .and. len( aChvInfo ) > 0	// temos dados do XML
			cTipo     := aChvInfo[01]
			cFormul   := aChvInfo[02]
			cNFiscal  := aChvInfo[03]
			cSerie    := aChvInfo[04]
			dDEmissao := aChvInfo[05]
			cA100For  := aChvInfo[06]
			cLoja     := aChvInfo[07]
			cEspecie  := aChvInfo[08]
			cUfOrig   := aChvInfo[09]
			cCondicao := aChvInfo[10]

			// Frank Zwarg Fuga em 30/03/17
			//If month(dDEmissao) <> month(dDataBase)
			//	dDEmissao := ctod("01/"+alltrim(str(month(dDataBase)))+"/"+alltrim(str(year(dDataBase))))
			//EndIf

		endif

	ElseIf cPE == "M410INIC"		// preenche Cabeçalho PV
		if isInCallStack("U_GETCHVSNF") .and. len( aChvInfo ) > 0	// temos dados do XML
			// aChvInfo[30] := { nFrete, nSeguro, nOutros, nDescon, nProd, nNF, nSubst, cRecIss }
			//				fXMLcpo( cCampo, xValor, laCols )
			U_fXMLcpo( "C5_EMISSAO", aChvInfo[05], .F. )
			U_fXMLcpo( "C5_CLIENTE", aChvInfo[06], .F. )
			U_fXMLcpo( "C5_LOJACLI", aChvInfo[07], .F. )
			U_fXMLcpo( "C5_CONDPAG", aChvInfo[10], .F. )

			_nTempFrete := 0
			For nX := 1 to len( aChvInfo[20] )
				_nTempFrete += If(valtype(aChvInfo[20][nX][14])=="N",aChvInfo[20][nX][14],val(aChvInfo[20][nX][14]))
			Next
			If _nTempFrete > 0
				U_fXMLcpo( "C5_FRETE", _nTempFrete, .F. )
			ElseIf aChvInfo[30,01] > 0 // Jonathan 10/07/2019
				U_fXMLcpo( "C5_FRETE", aChvInfo[30,01], .F. )
			EndIf

			// Jonathan 10/07/2019
			U_fXMLcpo( "C5_SEGURO", aChvInfo[30,02], .F. )
			U_fXMLcpo( "C5_DESPESA", aChvInfo[30,03], .F. )
			U_fXMLcpo( "C5_DESCONT", aChvInfo[30,04], .F. )

			if !Empty( aChvInfo[21] )	// é serviço
				U_fXMLcpo( "C5_NATUREZ", SA1->A1_NATUREZ, .F. )
				U_fXMLcpo( "C5_ESTPRES", SA1->A1_EST    , .F. )
				U_fXMLcpo( "C5_MUNPRES", SA1->A1_COD_MUN, .F. )

				cRecIss := "1"
				If len(aChvInfo[30]) == 8
					cRecIss := aChvInfo[30,8]
				EndIf

				U_fXMLcpo( "C5_RECISS" , cRecIss, .F. )
			endif

			U_CargaSC6()		// carrega aCols
		endif

	ElseIf cPE == "MT100LOK"		// preenche campo de retenção do ICMS

		_nOld := N

		if isInCallStack("U_GETCHVNFE") .and. len( aChvInfo ) > 0	// temos dados do XML
			If MaFisFound("NF")
				for xI := 1 to len( aCols )
					N := xI

					If GdFieldGet("D1_ICMSRET") == 0
						gdFieldPut("D1_ICMSRET", aChvInfo[20][xI][13][1][3], xI)
						gdFieldPut("D1_BRICMS" , aChvInfo[20][xI][13][1][4], xI)
					EndIf

					//						if ! gdDeleted( xI )
					//							MaFisAlt("IT_VALSOL", aChvInfo[20][xI][13][1][3], xI)
					//						endif
				next
			endif
		endif

		N := _nOld

		Eval(bRefresh)
		Eval(bGdRefresh)

		xRet := .T.

	ElseIf cPE == "MT100AG"		// Produto X Fornecedor
		ProdXfor()

	ElseIf cPE == "PATHXML"		// Retorna caminho dos XMLs
		xRet := ChkPath()

	ElseIf cPE == "MA920BUT"		// preenche Cabeçalho PV
		xRet := Nil
		xRet := {}

		If IsInCallStack("U_GETCHVSNF")
			AAdd(xRet,{"Carregar Dados", {|| U_CargaSD2()}, "CARGA", "CARGA"})
			SetKey(VK_F5, {|| U_CargaSD2()})
		EndIf
	EndIf

Return xRet


//-----------------------------------------
Static Function ChkPath( cParam )
	Local   aArea    := getArea()
	Local   aAreaSX3 := SX3->( getArea() )
	Local   cPath    := ""
	Local   cParam01  := "MV_XARQXML"
	Local   cParam02  := "MV_XCTAFOR"
	Local   cParam03  := "MV_XLOCPAD"
	Local   cParam04  := "MV_XNATNFE"
	Local   cParam05  := "MV_XNATSSN"
	Local   cParam06  := "MV_XNATISS"
	Local   cParam07  := "MV_XNATSRT"
	Local   cParam08  := "MV_XSERVIC"
	Local   cParam09  := "MV_XTESSSN"
	Local   cParam10  := "MV_XTESSFM"
	Local   cParam11  := "MV_XTESSDM"
	Local   cParam12  := "MV_XCTACLI"
	Local   cParam13  := "MV_XTSSSSN"
	Local   cParam14  := "MV_XTSSSFM"
	Local   cParam15  := "MV_XTSSSDM"
	Local   cParam16  := "MV_XCTAPRD"
	Local   cParam17  := "MV_XPRDCTE"
	Local   aSX6      := {}
	Local   aEstrut   := {"X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
	Local   nI, nJ
	Default cParam    := ""

	SX3->( dbSetOrder(2) )
	if SX3->( dbSeek( "F1_DOC" ) )
		if ! "U_CARGASD1" $ Upper( SX3->X3_VALID )
			RecLock("SX3", .F.)
			SX3->X3_VALID := alltrim(SX3->X3_VALID) + iif( Empty(SX3->X3_VALID),'','.and.') + 'iif(ExistBlock("CARGASD1"),U_CARGASD1(),.T.)'
			MsUnlock()
		endif
	endif

	restArea( aAreaSX3 )

	aAdd(aSX6,{ xFilial("SX6"), cParam01, "C", "Pasta de leitura dos arquivos XML", "Pasta de leitura dos arquivos XML", "Pasta de leitura dos arquivos XML", "", "", "", "", "", "", cPath   , cPath   , cPath   , "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam02, "C", "Conta Contabil cad.Fornecedor XML", "Conta Contabil cad.Fornecedor XML", "Conta Contabil cad.Fornecedor XML", "", "", "", "", "", "", ""      , ""      , ""      , "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam03, "C", "Local Padrao cad. Produtos XML"   , "Local Padrao cad. Produtos XML"   , "Local Padrao cad. Produtos XML"   , "", "", "", "", "", "", "01"    , "01"    , "01"    , "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam04, "C", "Natureza XML DANFE Entrada"       , "Natureza XML DANFE Entrada"       , "Natureza XML DANFE Entrada"       , "", "", "", "", "", "", "20001" , "20001" , "20001" , "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam05, "C", "Natureza XML RPS Simples Nacional", "Natureza XML RPS Simples Nacional", "Natureza XML RPS Simples Nacional", "", "", "", "", "", "", "20002" , "20002" , "20002" , "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam06, "C", "Natureza XML RPS c/ ISS"          , "Natureza XML RPS c/ ISS"          , "Natureza XML RPS c/ ISS"          , "", "", "", "", "", "", "20003" , "20003" , "20003" , "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam07, "C", "Natureza XML RPS retencoes divers", "Natureza XML RPS retencoes divers", "Natureza XML RPS retencoes divers", "", "", "", "", "", "", "20004" , "20004" , "20004" , "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam08, "C", "Cod.Produto de Servico XML"       , "Cod.Produto de Servico XML"       , "Cod.Produto de Servico XML"       , "", "", "", "", "", "", "SERV0001", "SERV0001", "SERV0001", "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam09, "C", "TES Servico XML Simples Nacional" , "TES Servico XML Simples Nacional" , "TES Servico XML Simples Nacional" , "", "", "", "", "", "", "005", "005", "005", "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam10, "C", "TES Servico XML Fora do Municipio", "TES Servico XML Fora do Municipio", "TES Servico XML Fora do Municipio", "", "", "", "", "", "", "004", "004", "004", "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam11, "C", "TES Servico XML Dentro Municipio" , "TES Servico XML Dentro Municipio" , "TES Servico XML Dentro Municipio" , "", "", "", "", "", "", "002", "002", "002", "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam12, "C", "Conta Contabil cad.Clientes XML"  , "Conta Contabil cad.Clientes XML"  , "Conta Contabil cad.Clientes XML"  , "", "", "", "", "", "", ""   , ""   , ""   , "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam13, "C", "TES Servico XML Saida Simples"    , "TES Servico XML Saida Simples"    , "TES Servico XML Saida Simples"    , "", "", "", "", "", "", "505", "505", "505", "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam14, "C", "TES Servico XML Saida F. Munic."  , "TES Servico XML Saida F. Munic."  , "TES Servico XML Saida F. Munic."  , "", "", "", "", "", "", "506", "506", "506", "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam15, "C", "TES Servico XML Saida Dentro Mun.", "TES Servico XML Saida Dentro Mun.", "TES Servico XML Saida Dentro Mun.", "", "", "", "", "", "", "507", "507", "507", "U", "N"})
	aAdd(aSX6,{ xFilial("SX6"), cParam16, "C", "Conta Contabil cad.Produtos XML"  , "Conta Contabil cad.Produtos XML"  , "Conta Contabil cad.Produtos XML"  , "", "", "", "", "", "", ""   , ""   , ""   , "U", "N"})

	aAdd(aSX6,{ xFilial("SX6"), cParam17, "C", "Cod.Produto de CT-e"              , "Cod.Produto de CT-e"              , "Cod.Produto de CT-e"              , "", "", "", "", "", "", "CTE", "CTE", "CTE", "U", "N"})

	dbSelectArea("SX6")
	dbSetOrder(1)
	For nI := 1 To Len(aSX6)
		If !dbSeek( aSX6[nI,1]+aSX6[nI,2] ) .And. !dbSeek( cFilAnt+aSX6[nI,2] )	// caso não encontre... cria

			RecLock("SX6", .T.)
			For nJ := 1 To Len( aSX6[nI] )
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI, nJ] )
			Next

			MsUnLock()
		else
			xTmp := padR( Alltrim( SX6->X6_CONTEUD ), len( SX6->X6_CONTEUD ) )
			aSX6[nI, aScan( aEstrut, "X6_CONTEUD") ] := xTmp
		EndIf
	Next

	cPath := getMV( cParam01 )

	if Empty( cPath )
		//		msgAlert("Favor configurar o parâmetro "+cParam01)
	else
		if right( cPath, 1) != "\"
			cPath := cPath + "\"
		endif
	endif

	if Empty( getMV( cParam02 ) )
		if ! lQuiet
			msgAlert("Favor configurar o parâmetro "+cParam02)
		endif
	endif

	SB1->( dbSetOrder(1) )
	if ! SB1->( dbSeek( xFilial("SB1") + getMV("MV_XSERVIC") ) )
		RecLock("SB1", .T.)
		SB1->B1_FILIAL  := xFilial("SB1")
		SB1->B1_COD     := "SERV0001"
		SB1->B1_DESC    := "SERVICO CONTRATADO COM RET"
		SB1->B1_TIPO    := "BN"
		SB1->B1_UM      := "UN"
		SB1->B1_LOCPAD  := "01"
		SB1->B1_TIPCONV := "M"
		SB1->B1_MCUSTD  := "1"
		SB1->B1_APROPRI := "D"
		SB1->B1_TIPODEC := "N"
		SB1->B1_ORIGEM  := "0"
		SB1->B1_RASTRO  := "N"
		SB1->B1_UREV    := dDatabase
		SB1->B1_DATREF  := dDatabase
		SB1->B1_MRP     := "S"
		SB1->B1_IRRF    := "S"
		SB1->B1_LOCALIZ := "N"
		SB1->B1_CONTRAT := "N"
		SB1->B1_IMPORT  := "N"
		SB1->B1_ANUENTE := "2"
		SB1->B1_TIPOCQ  := "M"
		SB1->B1_SOLICIT := "N"
		SB1->B1_AGREGCU := "2"
		SB1->B1_DESPIMP := "N"
		SB1->B1_INSS    := "S"
		SB1->B1_FLAGSUG := "1"
		SB1->B1_CLASSVE := "1"
		SB1->B1_MIDIA   := "2"
		SB1->B1_QTDSER  := "1"
		SB1->B1_ATIVO   := "S"
		SB1->B1_CPOTENC := "2"
		SB1->B1_USAFEFO := "1"
		SB1->B1_PIS     := "1"
		SB1->B1_ESCRIPI := "3"
		SB1->B1_MSBLQL  := "2"
		SB1->B1_PRODSBP := "P"
		SB1->B1_RETOPER := "2"
		SB1->B1_CSLL    := "1"
		SB1->B1_COFINS  := "1"
		SB1->B1_FETHAB  := "N"
		SB1->B1_RICM65  := "2"
		SB1->B1_PRN944I := "2"
		SB1->B1_CARGAE  := "2"
		SB1->B1_GARANT  := "2"
		MsUnlock()
	endif

	restArea( aArea )

	if ! Empty( cParam )
		return aClone( aSX6 )
	endif
return cPath


//---------------------------------------------
User Function GetMVsNF()
	Local   oDlg
	Local   oGetD
	Local   aAlter   := {}
	Local   aHeader  := {}
	Local   aCols    := {}
	Local   nI
	Local   aTmp
	Local   lOk      := .F.
	Local   aEstrut  := {"X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}

	Local   nPosVar  := aScan( aEstrut, "X6_VAR"     )
	Local   nPosTipo := aScan( aEstrut, "X6_TIPO"    )
	Local   nPosDes1 := aScan( aEstrut, "X6_DESCRIC" )
	Local   nPosDes2 := aScan( aEstrut, "X6_DESC1"   )
	Local   nPosDes3 := aScan( aEstrut, "X6_DESC2"   )
	Local   nPosCont := aScan( aEstrut, "X6_CONTEUD" )

	Private lQuiet   := .F.
	Private _aSX6    := ChkPath( "ATUALIZ MV" )

	aadd( aAlter, "X6_CONTEUD" )

	aadd( aHeader, { "Parâmetro", "X6_VAR"    , "@!",  10, 0, /*validação*/, /*usado*/, "C" } )
	aadd( aHeader, { "Tipo"     , "X6_TIPO"   , "@!",  01, 0, /*validação*/, /*usado*/, "C" } )
	aadd( aHeader, { "Descrição", "X6_DESCRIC", "@!", 100, 0, /*validação*/, /*usado*/, "C" } )
	aadd( aHeader, { "Conteúdo" , "X6_CONTEUD", "@X", 250, 0, /*validação*/, /*usado*/, "C" } )

	for nI := 1 to len( _aSX6 )
		aTmp := {}


		aadd( aTmp, _aSX6[nI][nPosVar]  )
		aadd( aTmp, _aSX6[nI][nPosTipo] )

		xTmp := Alltrim(_aSX6[nI][nPosDes1]) + Alltrim(_aSX6[nI][nPosDes2]) + Alltrim(_aSX6[nI][nPosDes3])
		aadd( aTmp, xTmp )

		aadd( aTmp, _aSX6[nI][nPosCont] )

		aadd( aTmp, .F.)

		aadd( aCols, aClone(aTmp) )
	next

	DEFINE MSDIALOG oDlg TITLE "Parâmetros customizados da rotina" FROM 0,0 TO 550,1000 PIXEL

	oGetD := MsNewGetDados():New( 30, 2, 260, 500, 2 , /*cLinhaOk*/, /*cTudoOk*/, /*CIniCpos*/, aAlter,,,,, "AllwaysTrue()", oDlg, aHeader, aCols )

	ACTIVATE MSDIALOG oDlg CENTERED on Init EnchoiceBar( oDlg,{|| lOk := .T., oDlg:End() },{|| oDlg:End() } )

	if lOk		// gravar
		for nI := 1 to len( aCols )
			PUTMV( aCols[nI][1], oGetD:aCols[nI][4] )
		next
	endif

Return nil


//------------------------ Verifica e Cria produto x fornecedor
Static Function ProdXfor()
	Local nI		:= 0
	Local nJ		:= 0
	Local lExist	:= .F.
	Local cCodPro	:= ""
	Local cTES		:= ""

	If valtype(aChvInfo[20]) <> U //Validação sobre o array
		For nI := 1 To Len( aChvInfo[20] )
			N := nI

			If !(GdDeleted())
				cCodPro := GdFieldGet("D1_COD")
				cTES	:= GdFieldGet("D1_TES")

				If cTipo $ "D/B"
					DbSelectArea("SA7")
					SA7->(DbSetOrder(1)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
					lExist := SA7->(DbSeek(xFilial("SA7") + cA100For + cLoja + cCodPro))
					RegToMemory("SA7", !(lExist))

					If !(lExist)
						M->A7_FILIAL	:= xFilial("SA7")
						M->A7_CLIENTE	:= cA100For
						M->A7_LOJA		:= cLoja
						M->A7_PRODUTO	:= cCodPro
						M->A7_CODCLI	:= cCodPro
					EndIf

					If SA7->(FieldPos("A7_XULTTES")) > 0
						M->A7_XULTTES := cTES
					EndIf

					RecLock("SA7", !(lExist))
					For nJ := 1 To SA7->(FCount())
						FieldPut(nJ, &("M->" + FieldName(nJ)))
					Next nJ
					MsUnlock()
				else
					DbSelectArea("SA5")
					SA5->(DbSetOrder(1)) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
					lExist := SA5->(DbSeek(xFilial("SA5") + cA100For + cLoja + cCodPro))

					RegToMemory("SA5", !(lExist))

					If !(lExist)
						M->A5_FILIAL	:= xFilial("SA5")
						M->A5_FORNECE	:= cA100For
						M->A5_LOJA		:= cLoja
						M->A5_NOMEFOR	:= Posicione("SA2", 1, xFilial("SA2") + cA100For + cLoja, "A2_NOME")
						M->A5_PRODUTO	:= cCodPro
						M->A5_NOMPROD	:= Posicione("SB1", 1, xFilial("SB1") + cCodPro, "B1_DESC")
						M->A5_CODPRF	:= cCodPro
					EndIf

					If SA5->(FieldPos("A5_XULTTES")) > 0
						M->A5_XULTTES := cTES
					EndIf

					RecLock("SA5", !(lExist))
					For nJ := 1 To SA5->(FCount())
						FieldPut(nJ, &("M->" + FieldName(nJ)))
					Next nJ
					MsUnlock()
				EndIf
			EndIf
		Next nI
	EndIf


Return Nil
