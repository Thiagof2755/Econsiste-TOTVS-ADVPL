#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP598 �Autor � Jonathan Schmidt Alves� Data �09/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 598 (Variacao Monetaria ���
���          � Receber) Pode ser usado tambem no 59A (oposto).            ���
���          � LP: 598: VARIACAO MONETARIA - CONTAS A RECEBER             ���
���          � LP: 59A: ESTORNO DA VARIACAO MONETARIA - CONTAS A RECEBER  ���
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
���          � Tabelas posicionadas: SE1                                  ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function INTLP598(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSE1 := SE2->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 530 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP598: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP598: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP598: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + "/" + SE1->E1_TIPO)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // VARIACAO RECEBER
		xRet := Abs(VALOR) // Variavel privada com a variacao receber
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // BAIXA DE TITULOS A RECEBER
		If VALOR > 0
			xRet := SA1->A1_CONTA
			
		Else
			xRet := "5510030005"

		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // BAIXA DE TITULOS A RECEBER
		If VALOR > 0
			xRet := "5510030004"
			
		Else
			xRet := SA1->A1_CONTA

		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/"
		If VALOR > 0
			xRet := "VARIACAO MONETARIA ATIVA: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
						
		Else
			xRet := "VARIACAO CAMBIAL PASSIVA: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)

		EndIf
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
	If cSeq $ "001/"
		If VALOR < 0
			xRet := SA1->A1_ITEMCTA
		Else
			xRet := SA1->A1_ITEMCTA
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		If VALOR > 0
			xRet := SA1->A1_ITEMCTA
		Else
			xRet := SA1->A1_ITEMCTA
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
EndIf
RestArea(aAreaSE1)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP598: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP598: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet