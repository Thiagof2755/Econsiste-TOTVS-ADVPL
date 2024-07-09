#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � CargaSC6 �Autor  � Cristiam Rossi     � Data �  25/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Carga aCols tabela SC6 - Itens de Pedido de Vendas         ���
���          � *parte XML Sa�da - ECCO*                                   ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function CargaSC6()
Local aArea := GetArea()
Local nI
If !isInCallStack("U_GETCHVSNF")		// n�o foi chamado pelo customiza��o de XML
	Return .T.
EndIf
If Len(aChvInfo) == 0					// n�o temos dados do XML
	Return .T.
EndIf
aTail(aCols[1]) := .F.			// marco como linha n�o deletada
aNovo := aClone(aCols[1]) 		// cria c�pia da primeira linha
aSize(aCols, 0)					// zero o aCols

/*
Estrutura do aChvInfo:

aChvInfo[01] := "N"									// Tipo
aChvInfo[02] := " "									// Formul�rio Pr�prio
aChvInfo[03] := subStr(cChave,26,09)				// Documento
aChvInfo[04] := subStr(cChave,23,03)				// S�rie
aChvInfo[05] := CtoD("  /  /  ")					// Emiss�o
aChvInfo[06] := Space( Len( SA2->A2_COD ) )			// Fornecedor
aChvInfo[07] := Space( Len( SA2->A2_LOJA ) )		// Loja
aChvInfo[08] := "SPED "					  			// Esp�cie
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
	n := nI
	xxx := u_fXMLcpo("C6_ITEM"   , StrZero(nI, 2))
	xxx := u_fXMLcpo("C6_PRODUTO", SB1->B1_COD)
	GdFieldPut("C6_UM"    , SB1->B1_UM)
	GdFieldPut("C6_DESCRI", SB1->B1_DESC)
	xxx := u_fXMLcpo("C6_QTDVEN" , aChvInfo[20][nI][8])
	
	if aChvInfo[30,04] == 0 //Desconto do cabe�alho: = zero, aplico nos itens
		nPrcUnit := aChvInfo[20][nI][9]
		nPrcTot := (aChvInfo[20][nI][9] * aChvInfo[20][nI][8]) - aChvInfo[20][nI][11]
		xxx := u_fXMLcpo("C6_PRCVEN" , nPrcTot / aChvInfo[20][nI][8])
		xxx := u_fXMLcpo("C6_VALDESC", aChvInfo[20][nI][11])
	else
		xxx := u_fXMLcpo("C6_PRCVEN" , aChvInfo[20][nI][9])
		xxx := u_fXMLcpo("C6_VALDESC", 0)
	endif
	// xxx := u_fXMLcpo("C6_PRCVEN" , aChvInfo[20][nI][9])
	
	xxx := u_fXMLcpo("C6_QTDLIB" , aChvInfo[20][nI][8])
	SF4->(DbGoto(aChvInfo[20][nI][13][5])) // Recno SF4
	If SF4->(Recno()) == aChvInfo[20][nI][13][5]
		xxx := u_fXMLcpo("C6_TES"    , SF4->F4_CODIGO)
		xxx := u_fXMLcpo("C6_CLASFIS", CodSitTri())
	EndIf
	xxx := u_fXMLcpo("C6_LOCAL"  , SB1->B1_LOCPAD)
	If aChvInfo[20][nI][13][6] > 0 // � servi�o
		xxx := u_fXMLcpo( "C6_ALIQISS", aChvInfo[20][nI][13][6])
		xxx := u_fXMLcpo( "C6_CODISS" , aChvInfo[21])
	EndIf
Next
n := 1
RestArea(aArea)
Return .T.
