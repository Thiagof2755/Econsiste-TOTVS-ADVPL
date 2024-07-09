#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP563 �Autor � Jonathan Schmidt Alves� Data �09/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 563 (Mov Bco Receber)   ���
���          � Pode ser usado tambem no ??? (oposto).                     ���
���          � LP: 563: MOVIMENTO BANCARIO - INCLUSAO DE MOVIMENTO RECEB  ���
���          � LP: 565: MOVIMENTO BANCARIO - CANCELAMENTO MOVIMENTO RECEB ���
�������������������������������������������������������������������������͹��
���          � Parametros:                                                ���
���          � 01) cPrc: Processo                                         ���
���          �               VLR=Valor                                    ���
���          �               DEB=Conta Contabil Debito                    ���
���          �               CRD=Conta Contabil Credito                   ���
���          �               HIS=Historico                                ���
���          �               CCD=Centro Custo Debito                      ���
���          �               CCC=Centro Custo Credito                     ���
���          �               ITD=Item Contabil Debito                     ���
���          �               ITC=Item Contabil Credito                    ���
�������������������������������������������������������������������������͹��
���          � 02) cSeq: Sequencial: Todos                                ���
�������������������������������������������������������������������������͹��
���          � 03) cHis: Historico adicional (para estornos)              ���
�������������������������������������������������������������������������͹��
���          � 04) lRat: Com rateio ou sem rateio                         ���
�������������������������������������������������������������������������͹��
���          � Tabelas posicionadas: SE2/SE5                              ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function INTLP563(cPrc, cSeq, cHis, lRat)
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
Default lRat := .F. // .F.=Trata o LP 563 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP563: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP563: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP563: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E5_DATA/E5_NATUREZ/E5_VALOR: " + DtoC(SE5->E5_DATA) + "/" + SE5->E5_NATUREZ + "/" + TransForm(SE5->E5_VALOR,"@E 999,999,999.99"))
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // MOV BANCARIO RECEBER
		xRet := SE5->E5_VALOR
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO RECEBER
		xRet := SA6->A6_CONTA
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO PAGAR
		xRet := SED->ED_CONTA
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001"
		xRet := "NOV BCO REND: " + AllTrim(SE5->E5_HISTOR)
	EndIf
	If !Empty(cHis) // EST. (Estorno)
		xRet := RTrim(cHis) + " " + xRet
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		If !Empty(SE5->E5_CLIFOR) // Se tem cliente preenchido... uso o Item Contabil do SA1
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
			If SA1->(DbSeek(xFilial("SA1") + SE5->E5_CLIFOR + SE5->E5_LOJA))
				xRet := SA1->A1_ITEMCTA
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP563: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP563: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet