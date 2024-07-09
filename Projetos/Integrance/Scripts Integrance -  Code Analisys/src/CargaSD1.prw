#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ CargaSD1 ºAutor  ³ Cristiam Rossi     º Data ³  29/07/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação variável cNFiscal e campo F1_DOC                 º±±
±±º          ³ *parte XML Entrada - ECCO*                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRevisao   ³                Jonathan Schmidt Alves º Data ³  30/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ITUP / ECCO                                                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CargaSD1(cParam)
Local aArea := GetArea()
Static bBkpFocus := {|| .T. }
// ConOut("CargaSD1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...") Alterado para: FWLogMsg
U_LogAlteracoes("CargaSD1","Iniciando...")

If Type("oGetDados:oBrowse") == "U"		// não está dentro da NF de Entrada
	Return .T.
EndIf
If !isInCallStack("U_GETCHVNFE")		// não foi chamado pelo customização de XML
	Return .T.
EndIf
If Len(aChvInfo) == 0					// não temos dados do XML
	Return .T.
EndIf
If Empty(cParam)
	bBkpFocus := oGetDados:oBrowse:bGotFocus
	If !Eval(bBkpFocus)
		Return .F.
	EndIf
	oGetDados:oBrowse:bGotFocus := {|| u_CARGASD1("Verif XML") }
Else
	oGetDados:oBrowse:bGotFocus := bBkpFocus
	MsAguarde({|| Preenche()}, "Importação XML Entrada", "Carregando itens, favor aguarde...", .F.)
EndIf
// ConOut("CargaSD1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!") Alterado para: FWLogMsg
U_LogAlteracoes("CargaSD1","Concluido!")

Return .T.

Static Function Preenche()
Local nI
Local aNovo
Local cChvRef := ""
Local aAreaCF := GetArea()
Local _cQuery := ""
Local cCF := ""
aTail(aCols[1]) := .F.			// marco como linha não deletada
aNovo := aClone(aCols[1])	 	// cria cópia da primeira linha
aSize(aCols, 0)					// zero o aCols
//ConOut("Preenche: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("Preenche","Iniciando...")

/*
Estrutura do aChvInfo:

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
aChvInfo[11] := Alltrim( cChave )					// Chave DANFE

aChvInfo[15] := cXML2oXML( cXml )					// Carrega XML no Objeto

aChvInfo[20] := aClone( aProds )					// Produtos

Estrutura aChvInfo[20] - Produtos
{ nRecnoB1, xProd, xCodBar, xDescri, xNCM, xCFOP, xUM, xQtd, xVunit, xVtotal, xVdesc, xCEST, aClone(aImpost) }

Estrutura aChvInfo[20][nItem][13] - Impostos
{ {"0","  "}, "  ", "  ", "  ", 0 }
ICMS: {origem, cst},
IPI: cst,
PIS: cst,
COFINS: cst,
TES: record

*/

For nI := 1 To Len(aChvInfo[20])
	aAdd(aCols, aClone(aNovo))
	SB1->(DbGoto(aChvInfo[20][nI][1])) // Recno SB1
	N := nI
	//User Function fXMLcpo( cCampo, xValor, laCols, lValid, lGatilho )
	SF4->( dbGoto(aChvInfo[20][nI][13][5])) // Recno SF4
	If SF4->(Recno()) == aChvInfo[20][nI][13][5]
		u_fXMLcpo("D1_TES"    , SF4->F4_CODIGO)
		u_fXMLcpo("D1_CLASFIS", SF4->F4_XCODDES + SF4->F4_SITTRIB)
		//if SD1->( fieldPos( "D1_CONTA" ) ) > 0 .and. ! empty( SF4->F4_XCONTA )
		//	U_fXMLcpo( "D1_CONTA"  , SF4->F4_XCONTA )
		//endif
		cCF := SF4->F4_CF
	EndIf
	u_fXMLcpo("D1_ITEM"   , StrZero(nI,4), Nil,.F.,.F.)
	u_fXMLcpo("D1_COD"    , SB1->B1_COD)
	u_fXMLcpo("D1_LOCAL"  , SB1->B1_LOCPAD)
	u_fXMLcpo("D1_QUANT"  , aChvInfo[20][nI][8])
	
	// Forcar o valor unitario = 0 quanto estiver zerado
	_nVlrUnitX := aChvInfo[20][nI][9]
	_nVlrTotaX := aChvInfo[20][nI][10]
	_nQuantidX := If(aChvInfo[20][nI][8] > 0, aChvInfo[20][nI][8], 1)
	//If _nVlrUnitX == 0 .and. SuperGetMV("IT_ACEITA0",,"S") == "S"
	//	_nVlrUnitX := val("0."+replicate("0",tamsx3("D1_VUNIT")[2]-1)+"1")
	//	_nTempX := round(_nVlrUnitX * _nQuantidX,2)
	//	While _nTempX == 0
	//		_nVlrUnitX += val("0."+replicate("0",tamsx3("D1_VUNIT")[2]-1)+"1")
	//		_nTempX := round(_nVlrUnitX * _nQuantidX,2)
	//	EndDo
	//	_nVlrTotaX := _nTempX
	//EndIf
	u_fXMLcpo("D1_VUNIT"  , _nVlrUnitX)
	u_fXMLcpo("D1_TOTAL"  , _nVlrTotaX)
	If cTipo == "D"
		//If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") != "U"
		If U_ztipo("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT") != "U"
			cChvRef := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT
			u_fXMLcpo("D1_NFORI"  , SubStr(cChvRef, 26, 9))
			u_fXMLcpo("D1_SERIORI", SubStr(cChvRef, 23, 3))
		EndIf
	EndIf
	aAreaCF := GetArea()
	// dbSelectArea("C_F")
	_cQuery := "SELECT COUNT(*) CONTA "
	_cQuery += "FROM " + RetSqlName("C_F") + " WHERE "
	_cQuery += "D_E_L_E_T_ = '' AND "
	_cQuery += "C_F_LISTA LIKE '%" + Alltrim(cCF) + "%' "
	If Select("TTCFO") > 0
		TTCFO->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TTCFO",.T.,.F.)
	If TTCFO->(!EOF()) .And. TTCFO->CONTA > 1
		MsgAlert("Existe mais de uma conta para o CFOP " + cCF + ". Favor selecionar a conta contabil!","Preenche")
	Else
		_cQuery := "SELECT C_F_CONTA AS CONTAC "
		_cQuery += "FROM " + RetSqlName("C_F") + " WHERE "
		_cQuery += "D_E_L_E_T_ = '' AND "
		_cQuery += "C_F_LISTA LIKE '%" + AllTrim(cCF) + "%' "
		If Select("TCFO") > 0
			TCFO->(DbCloseArea())
		EndIf
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TCFO",.T.,.F.)
		If TCFO->(!EOF())
			u_fXMLcpo( "D1_CONTA"  , TCFO->CONTAC )
		Else
			MsgAlert("Não existe conta contabil cadastrada para este CFOP. Favor selecionar a conta contabil!","Preenche")
		Endif
	Endif
	RestArea(aAreaCF)
	u_fXMLcpo("D1_VALDESC" , aChvInfo[20][nI][11])
	u_fXMLcpo("D1_BRICMS"  , aChvInfo[20][nI][13][1][4])
	u_fXMLcpo("D1_ICMSRET" , Iif(aChvInfo[20][nI][13][1][4] > 0, aChvInfo[20][nI][13][1][3], 0))
	u_fXMLcpo("D1_PICM"    , aChvInfo[20][nI][13][1][5])
	u_fXMLcpo("D1_IPI"     , aChvInfo[20][nI][13][7])
	u_fXMLcpo("D1_VALIPI"	, aChvInfo[20][nI][13][11]) // Douglas 01/11/2018
	u_fXMLcpo("D1_VALICM"	, aChvInfo[20][nI][13][1][7]) // Douglas 01/11/2018
	u_fXMLcpo("D1_BASEICM"	, aChvInfo[20][nI][13][1][6]) // Douglas 20/02/2019
	If MaFisFound("NF")
		MaFisAlt("IT_VALSOL", Iif(aChvInfo[20][nI][13][1][4] > 0, aChvInfo[20][nI][13][1][3], 0), nI)
	EndIf
Next
If Type("aNfeDanfe") != "U"
	aNfeDanfe[13] := aChvInfo[11] // Chave da DANFE
EndIf
n := 1
Eval(bRefresh)
Eval(bGdRefresh)
If MaFisFound("NF")
	// aChvInfo[30] := { cFrete, cSeguro, cOutros, cDesc, cProd, cNF, cSubst }
	MaFisAlt("NF_FRETE"   , aChvInfo[30][1],Nil)
	MaFisAlt("NF_SEGURO"  , aChvInfo[30][2],Nil)
	MaFisAlt("NF_DESPESA" , aChvInfo[30][3],Nil)
EndIf
//ConOut("Preenche: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("Preenche","Concluido!")
Return
