#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP596 �Autor � Jonathan Schmidt Alves� Data �23/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 596 (Compensacao Receb) ���
���          � Pode ser usado tambem no 588 (oposto).                     ���
���          � LP: 596: CONTAS A RECEB - COMPENSACAO CONTAS A RECEBER     ���
���          � LP: 588: CONTAS A RECEB - CANCELAMENTO COMPENSACAO TITULOS ���
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
���          � Tabelas posicionadas: SE1/SE5                              ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function INTLP596(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 500 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP596: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP596: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP596: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + "/" + SE1->E1_TIPO)
If cPrc == "VLR" // Valor
	If cSeq == "001" // Sequencial unico
		xRet := SE5->E5_VALOR
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // Sequencial unico
		xRet := SED->ED_CODIGO	
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // Sequencial unico
		xRet := SA1->A1_CONTA
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq == "001"
		xRet := "ADTO: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
	EndIf
	If !Empty(cHis) // EST. (Estorno)
		xRet := RTrim(cHis) + " " + xRet
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
ElseIf cPrc == "CCD" // Centro Custo Debito
	xRet := Space(nTamCTTCod)
ElseIf cPrc == "CCC" // Centro Custo Credito
	xRet := Space(nTamCTTCod)
ElseIf cPrc == "ITD" // Item Contabil Debito
	xRet := Space(nTamCTDCod)
	If cSeq == "001"
		xRet := SA1->A1_ITEMCTA
	EndIf
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq == "001"
		xRet := SA1->A1_ITEMCTA
	EndIf
EndIf
RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP596: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP596: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet