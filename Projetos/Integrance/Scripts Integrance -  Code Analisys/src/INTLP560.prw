#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP560 �Autor � Jonathan Schmidt Alves� Data �09/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 560 (Transf Origem)     ���
���          � Pode ser usado tambem no ??? (oposto).                     ���
���          � LP: 560: MOVIMENTO BANCARIO - TRANSF SAIDA BANCO ORIGEM    ���
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

User Function INTLP560(cPrc, cSeq, cHis, lRat)
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
ConOut("INTLP560: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP560: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP560: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E5_DATA/E5_NATUREZ/E5_VALOR: " + DtoC(SE5->E5_DATA) + "/" + SE5->E5_NATUREZ + "/" + TransForm(SE5->E5_VALOR,"@E 999,999,999.99"))
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // MOV BANCARIO ORIGEM
		xRet := SE5->E5_VALOR
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO ORIGEM
		DbSelectArea("SED")
		SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
		If SED->(DbSeek(xFilial("SED") + SE5->E5_NATUREZ))
			If !Empty(SED->ED_CONTA)
				xRet := SED->ED_CONTA
			EndIf
		EndIf
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // MOV BANCARIO ORIGEM
		xRet := SA6->A6_CONTA
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001"
		xRet := "TRANSF ORIGEM: " + AllTrim(SE5->E5_HISTOR)
	EndIf
	If !Empty(cHis) // EST. (Estorno)
		xRet := RTrim(cHis) + " " + xRet
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
EndIf
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP560: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP560: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet