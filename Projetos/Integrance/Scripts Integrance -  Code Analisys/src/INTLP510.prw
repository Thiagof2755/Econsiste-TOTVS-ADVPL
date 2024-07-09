#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP510 ºAutor ³ Jonathan Schmidt Alvesº Data ³08/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 510 (Inclusao Pagar)    º±±
±±º          ³ Pode ser usado tambem no 515 (oposto).                     º±±
±±º          ³ LP: 510: CONTAS A PAGAR - INCLUSAO DE TITULOS              º±±
±±º          ³ LP: 515: CONTAS A PAGAR - CANCELAMENTO DE INCL DE TITULOS  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Parametros:                                                º±±
±±º          ³ 01) cPrc: Processo                                         º±±
±±º          ³               VLR=Valor                                    º±±
±±º          ³               DEB=Conta Contabil Debito                    º±±
±±º          ³               CRD=Conta Contabil Credito                   º±±
±±º          ³               HIS=Historico                                º±±
±±º          ³               CCD=Centro Custo Debito                      º±±
±±º          ³               CCC=Centro Custo Credito                     º±±
±±º          ³               ITD=Item Contabil Debito                     º±±
±±º          ³               ITC=Item Contabil Credito                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 02) cSeq: Sequencial: Todos                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 03) cHis: Historico adicional (para estornos)              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ 04) lRat: Com rateio ou sem rateio                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Tabelas posicionadas: SE2                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP510(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSE2 := SE2->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 530 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP510: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP510: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP510: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E2_PREFIXO/E2_NUM/E2_PARCELA/E2_TIPO: " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + "/" + SE2->E2_PARCELA + "/" + SE2->E2_TIPO)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // INCLUSAO TITULOS A PAGAR INVOICES
		If SE2->E2_TIPO == "INV"
			If SE2->E2_PREFIXO <> "EMP" // Nao pode ser "EMP"=Emprestimo..
				xRet := SE2->E2_VLCRUZ
			EndIf
		EndIf
	ElseIf cSeq == "002" // INCLUSAO TITULOS A PAGAR INVOICES JUROS
		If SE2->E2_TIPO == "INJ"
			xRet := SE2->E2_VLCRUZ
		EndIf
	ElseIf cSeq == "009" // INCLUSAO TITULOS MANUAIS
		If SE2->E2_TIPO == "MAN"
			xRet := SE2->E2_VALOR
		EndIf
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // INCLUSAO TITULOS A PAGAR INVOICES
		xRet := SED->ED_CONTA
	ElseIf cSeq $ "002/" // INCLUSAO TITULOS A PAGAR INVOICES JUROS
		xRet := "5510020011"
	ElseIf cSeq $ "009/" // INCLUSAO TITULOS A PAGAR MANUAIS
		xRet := SED->ED_CONTA
    EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD"
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/009/" // INCLUSAO DE TITULOS A PAGAR
		xRet := SA2->A2_CONTA
	ElseIf cSeq $ "002" // INCLUSAO DE TITULOS A PAGAR INVOICES JUROS
		xRet := "2110120004"
    EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/" // Invoices
		xRet := "INV: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
	ElseIf cSeq $ "002/" // Invoices
		xRet := "INV: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
	ElseIf cSeq $ "009/" // Manuais
		xRet := "MAN: " + SE2->E2_NUM + " " + AllTrim(SE2->E2_HIST)
  	EndIf
	If !Empty(cHis) // EST. (Estorno)
		xRet := RTrim(cHis) + " " + xRet
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
ElseIf cPrc == "CCD" // Centro Custo Debito
	xRet := Space(nTamCTTCod)
	// Nao usado
ElseIf cPrc == "CCC" // Centro Custo Credito
	xRet := Space(nTamCTTCod)
	// Nao usado
ElseIf cPrc == "ITD" // Item Contabil Debito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/002/009/"
		xRet := SA2->A2_ITEMCTA
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/002/009/"
		xRet := SA2->A2_ITEMCTA
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
EndIf
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP510: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP510: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet