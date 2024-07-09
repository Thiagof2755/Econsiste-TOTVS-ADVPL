#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP599 �Autor � Jonathan Schmidt Alves� Data �09/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 598 (Variacao Monetaria ���
���          � Pagar) Pode ser usado tambem no 59B (oposto).              ���
���          � LP: 599: VARIACAO MONETARIA - CONTAS A PAGAR               ���
���          � LP: 59B: ESTORNO DA VARIACAO MONETARIA - CONTAS A PAGAR    ���
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
���          � Tabelas posicionadas: SE2                                  ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function INTLP599(cPrc, cSeq, cHis, lRat)
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
ConOut("INTLP599: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP599: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP599: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E2_PREFIXO/E2_NUM/E2_PARCELA/E2_TIPO: " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + "/" + SE2->E2_PARCELA + "/" + SE2->E2_TIPO)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // VARIACAO PAGAR
		xRet := Abs(VALOR) // Variavel privada com a variacao pagar
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // BAIXA DE TITULOS A PAGAR
		If VALOR > 0
			xRet := "5510030005"
		Else
			// Alteracao Jonathan/Renato 19/09/2019
			// xRet := SA2->A2_CONTA
			If SE2->E2_PREFIXO == "INJ" // Invoice de Juros
				If SE2->E2_FILIAL == "1010" // Petrofer
					xRet := "2210010007"
				Else // Outras empresas
					xRet := "2110120004"
				EndIf
			ElseIf SE2->E2_PREFIXO == "EMP" // Emprestimo
				If SE2->E2_FILIAL == "1010" // Petrofer
					xRet := "2210010005"
				Else // Outras empresas
					xRet := "2110120001"
				EndIf
			Else
				xRet := SA2->A2_CONTA
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // BAIXA DE TITULOS A PAGAR
		If VALOR > 0
			// Alteracao Jonathan/Renato 19/09/2019
			// xRet := SA2->A2_CONTA
			If SE2->E2_PREFIXO == "INJ" // Invoice de Juros
				If SE2->E2_FILIAL == "1010" // Petrofer
					xRet := "2210010007"
				Else // Outras empresas
					xRet := "2110120004"
				EndIf
			ElseIf SE2->E2_PREFIXO == "EMP" // Emprestimo
				If SE2->E2_FILIAL == "1010" // Petrofer
					xRet := "2210010005"
				Else // Outras empresas
					xRet := "2110120001"
				EndIf
			Else
				xRet := SA2->A2_CONTA
			EndIf
		Else
			xRet := "5510030004"
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/"
		If VALOR > 0
			xRet := "VARIACAO CAMBIAL PASSIVA: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
		Else
			xRet := "VARIACAO MONETARIA ATIVA: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
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
			xRet := SA2->A2_ITEMCTA
		Else
			xRet := SA2->A2_ITEMCTA
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		If VALOR > 0
			xRet := SA2->A2_ITEMCTA
		Else
			xRet := SA2->A2_ITEMCTA
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
EndIf
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP599: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP599: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet