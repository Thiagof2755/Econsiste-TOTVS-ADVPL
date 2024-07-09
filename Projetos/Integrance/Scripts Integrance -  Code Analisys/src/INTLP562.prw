#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP562 ºAutor ³ Jonathan Schmidt Alvesº Data ³08/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 563 (Mov Bco Pagar)     º±±
±±º          ³ Pode ser usado tambem no ??? (oposto).                     º±±
±±º          ³ LP: 562: MOVIMENTO BANCARIO - INCLUSAO DE MOVIMENTO PAGAR  º±±
±±º          ³ LP: 564: MOVIMENTO BANCARIO - CANCELAMENTO MOVIMENTO PAGAR º±±
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
±±º          ³ Tabelas posicionadas: SE2/SE5                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP562(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 562 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP562: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP562: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP562: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E5_DATA/E5_NATUREZ/E5_VALOR: " + DtoC(SE5->E5_DATA) + "/" + SE5->E5_NATUREZ + "/" + TransForm(SE5->E5_VALOR,"@E 999,999,999.99"))
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // MOV BANCARIO PAGAR
		xRet := SE5->E5_VALOR
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO PAGAR
		xRet := SED->ED_CONTA
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO PAGAR
		xRet := SA6->A6_CONTA
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001"
		xRet := "NOV BCO PAGAR: " + AllTrim(SE5->E5_HISTOR)
	EndIf
	If !Empty(cHis) // EST. (Estorno)
		xRet := RTrim(cHis) + " " + xRet
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
ElseIf cPrc == "ITD" // Item Contabil Debito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		If !Empty(SE5->E5_CLIFOR) // Se tem fornecedor preenchido... uso o Item Contabil do SA2
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
			If SA2->(DbSeek(xFilial("SA2") + SE5->E5_CLIFOR + SE5->E5_LOJA))
				xRet := SA2->A2_ITEMCTA
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSE5)
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP562: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP562: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet