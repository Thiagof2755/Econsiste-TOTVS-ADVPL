#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ CARGASD2 ºAutor ³ Douglas Telles       º Data ³ 28/09/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação variável c920Tipo e campo F2_TIPO.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRevisao   ³                Jonathan Schmidt Alves º Data ³  30/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CargaSD2(cParam)
Local aArea := GetArea()
Static bBkpFocus := {|| .T. }
/*
If Type("oGetDados:oBrowse") == "U" // não está dentro da NF de Saida
Return .T.
EndIf
*/
If !(IsInCallStack("U_GETCHVSNF")) // não foi chamado pelo customização de XML
	Return .T.
EndIf
If Len(aChvInfo) == 0 // não temos dados do XML
	Return .T.
EndIf
/*
If Empty(cParam)
bBkpFocus := oGetDados:oBrowse:bGotFocus
If !(Eval(bBkpFocus))
Return .F.
EndIf
oGetDados:oBrowse:bGotFocus := { || U_CARGASD2( "Verif XML" ) }
Else
oGetDados:oBrowse:bGotFocus := bBkpFocus
*/
MsAguarde({|| Preenche() }, "Importação XML Saída", "Carregando itens, favor aguarde...", .F.)
//	EndIf
RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ Preenche ºAutor ³ Douglas Telles       º Data ³ 28/09/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche os itens da tela da nota fiscal                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Preenche()
Local nI		:= 0
Local nAliqPIS	:= 0
Local nAliqCOF	:= 0
Local oImp		:= Nil
Local aNovo		:= {}

//aTail(aCols[1]) := .F.			// marco como linha não deletada
//aNovo := aClone( aCols[1] ) 	// cria cópia da primeira linha
//aSize( aCols, 0 )				// zero o aCols

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
c920Tipo	:= aChvInfo[01]
//	cFormul		:= aChvInfo[02]
c920Nota	:= aChvInfo[03]
c920Serie	:= aChvInfo[04]
d920Emis	:= aChvInfo[05]
c920Client	:= aChvInfo[06]
c920Loja	:= aChvInfo[07]
c920Especi	:= aChvInfo[08]
// cUfOrig   := aChvInfo[09]
// cCondicao := aChvInfo[10]

/*
For nI := 1 To Len(aChvInfo[20])
aAdd(aCols, aClone(aNovo))

nAliqCOF := 0
nAliqPIS := 0

SB1->(DbGoto(aChvInfo[20][nI][1])) // Recno SB1

N := nI

//User Function fXMLcpo( cCampo, xValor, laCols, lValid, lGatilho )

U_fXMLcpo( "D2_ITEM"	, StrZero(nI, TamSx3("D2_ITEM")[1]), nil, .F., .F. )
U_fXMLcpo( "D2_COD"		, SB1->B1_COD )
U_fXMLcpo( "D2_LOCAL"	, SB1->B1_LOCPAD )
U_fXMLcpo( "D2_QUANT"	, aChvInfo[20][nI][8]  )
U_fXMLcpo( "D2_PRCVEN"	, aChvInfo[20][nI][9]  )
U_fXMLcpo( "D2_TOTAL"	, aChvInfo[20][nI][10] )

SF4->(DbGoto(aChvInfo[20][nI][13][5])) // Recno SF4
If SF4->(Recno()) == aChvInfo[20][nI][13][5]
U_fXMLcpo("D2_TES"	, SF4->F4_CODIGO )
U_fXMLcpo("D2_CF"	, SF4->F4_CF )

If SF4->(FieldPos("F4_XCONTA")) > 0 .and. !(Empty(SF4->F4_XCONTA))
U_fXMLcpo("D2_CONTA", SF4->F4_XCONTA)
EndIf
EndIf

//		U_fXMLcpo( "D1_VALDESC", aChvInfo[20][nI][11] )

U_fXMLcpo("D2_ICMSRET", IIF(aChvInfo[20][nI][13][1][4] > 0, aChvInfo[20][nI][13][1][3], 0))
U_fXMLcpo("D2_BRICMS" , aChvInfo[20][nI][13][1][4] )
U_fXMLcpo("D2_PICM"   , aChvInfo[20][nI][13][1][5] )
U_fXMLcpo("D2_IPI"    , aChvInfo[20][nI][13][7]    )

If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO") != "U"
oImp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO
Else
oImp := aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_DET[nI]:_IMPOSTO
EndIf

If Type("oImp:_PIS") != "U"
If Type("oImp:_PIS:_PISNT:_PPIS:TEXT") != "U"
nAliqPIS := Val(oImp:_PIS:_PISNT:_PPIS:TEXT)
EndIf

If Type("oImp:_PIS:_PISALIQ:_PPIS:TEXT") != "U"
nAliqPIS := Val(oImp:_PIS:_PISALIQ:_PPIS:TEXT)
EndIf
EndIf

If Type("oImp:_COFINS") != "U"
If Type("oImp:_COFINS:_COFINSNT:_PCOFINS:TEXT") != "U"
nAliqCOF := Val(oImp:_COFINS:_COFINSNT:_PCOFINS:TEXT)
EndIf

If Type("oImp:_COFINS:_COFINSALIQ:_PCOFINS:TEXT") != "U"
nAliqCOF := Val(oImp:_COFINS:_COFINSALIQ:_PCOFINS:TEXT)
EndIf
EndIf

U_fXMLcpo("D2_ALIQIMP5", nAliqCOF)
U_fXMLcpo("D2_ALIQIMP6", nAliqPIS)

If MaFisFound("NF")
MaFisAlt("IT_VALSOL", IIF(aChvInfo[20][nI][13][1][4] > 0, aChvInfo[20][nI][13][1][3], 0), nI)
EndIf
Next nI
*/
If Type("aNfeDanfe") != "U"
	aNfeDanfe[13] := aChvInfo[11] // chave da DANFE
EndIf
n := 1
//Eval(bRefresh)
//Eval(bGdRefresh)
If MaFisFound("NF")
	// aChvInfo[30] := { cFrete, cSeguro, cOutros, cDesc, cProd, cNF, cSubst }
	MaFisAlt("NF_FRETE"   , aChvInfo[30][1],Nil)
	MaFisAlt("NF_SEGURO"  , aChvInfo[30][2],Nil)
	MaFisAlt("NF_DESPESA" , aChvInfo[30][3],Nil)
EndIf
Return