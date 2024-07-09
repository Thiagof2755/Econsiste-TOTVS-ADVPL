#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ CTBCK901 ºAutor ³ Jonathan Schmidt Alves ºData³ 27/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de conferencias contabeis.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function CTBCK901()
Local cQrySF1 := ""

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LoadsSF1 ºAutor ³ Jonathan Schmidt Alves ºData³ 10/07/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carregamentos de notas de entrada.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LoadsSF1(aPars)
Local _cSqlSF1 := RetSqlName("SF1")
Local _cSqlSD1 := RetSqlName("SD1")
Local dEmissDe := aPars[01]
Local dEmissAt := aPars[02]
Local cForneDe := aPars[03]
Local cForneAt := aPars[04]
Local aRecsSF1 := {}
Local nRecsSF1 := 0
DbSelectArea("SF1")
SF1->(DbSetOrder(1)) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
cQrySF1 := "SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO "
cQrySF1 += "FROM " + _cSqlSF1 + " "

cQrySF1 += "LEFT JOIN " + _cSqlSD1 + " SD1 "
cQrySF1 += "ON SD1.D1_FILIAL + SD1.D1_DOC + SD1.D1_SERIE + SD1.D1_FORNECE + SD1.D1_LOJA + SD1.D1_TIPO = SF1.F1_FILIAL + SF1.F1_DOC + SF1.F1_SERIE + SF1.F1_FORNECE + SF1.F1_LOJA + SF1.F1_TIPO"

cQrySF1 += "WHERE "
cQrySF1 += "F1_FILIAL = '" + _cFilSF1 + "' AND "			// Filial conforme
cQrySF1 += "F1_EMISSAO >= '" + DtoS(dEmissDe) + "' AND "	// Emissao de
cQrySF1 += "F1_EMISSAO <= '" + DtoS(dEmissAt) + "' AND "	// Emissao ate
cQrySF1 += "F1_FORNECE >= '" + cForneDe + "' AND "			// Fornecedor de
cQrySF1 += "F1_FORNECE <= '" + cForneAt + "' AND "			// Fornecedor ate
cQrySF1 += "D_E_L_E_T_ = ' '"								// Nao apagado
If Select("QRYSF1") > 0
	QRYSF1->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySF1),"QRYSF1",.T.,.F.)
Count To nRecsSF1
If nRecsSF1 > 0 // Registros encontrados
	QRYSF1->(DbGotop())
	While QRYSF1->(!EOF())
       	aAdd(aRecsSF1, { QRYSF1->F1_FILIAL, QRYSF1->F1_DOC, QRYSF1->F1_SERIE, QRYSF1->F1_FORNECE, QRYSF1->F1_LOJA, QRYSF1->F1_TIPO })
		QRYSF1->(DbSkip())
	End
EndIf
Return