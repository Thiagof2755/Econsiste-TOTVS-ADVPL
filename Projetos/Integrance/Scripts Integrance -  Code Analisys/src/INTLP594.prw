#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP594 �Autor � Jonathan Schmidt Alves� Data �30/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 594 (Compensacao entre  ���
���          � Carteiras). Pode ser usado tambem no ??? (oposto).         ���
���          � LP: 594: Contas Pagar/Receber - Compensacao Carteiras      ���
���          � LP: ???: Contas Pagar/Receber - Exc Compensacao Carteiras  ���
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
���          � Tabelas posicionadas: SE1/SE2/SE5                          ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function INTLP594(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 594 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP594: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP594: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // NOTA FISCAL DE ENTRADA DE INSUMOS
		xRet := 0
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001"
		xRet := Space(nTamCT1Cod)
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001"
		xRet := Space(nTamCT1Cod)
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq == "001"

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
	If cSeq $ "001/"
		
	EndIf
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		
	EndIf
EndIf
ConOut("INTLP594: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP594: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet