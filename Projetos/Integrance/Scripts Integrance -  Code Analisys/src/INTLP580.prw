#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � INTLP580 �Autor � Jonathan Schmidt Alves� Data �09/05/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Customizacao para tratamento do LP 598 (Aplicacoes/Empres  ���
���          � timos) Pode ser usado tambem no ??? (oposto).              ���
���          � LP: 580: APLICAC�ES - INCLUSAO DE APLICACAO FINANCEIRA     ���
���          � LP: 581: APLICAC�ES - EXCLUSAO APLICACAO FINANCEIRA        ���
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

User Function INTLP580(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSEH := SEH->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 580 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP580: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP580: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP580: " + DtoC(Date()) + " " + Time() + " " + cUserName + " EH_NUMERO/EH_REVISAO/EH_TIPO: " + SEH->EH_NUMERO + "/" + SEH->EH_REVISAO + "/" + SEH->EH_TIPO)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // APLICACOES/EMPRESTIMOS
		xRet := SEH->EH_VLCRUZ
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // APLICACOES/EMPRESTIMOS
		xRet := SA6->A6_CONTA
	EndIf
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/" // APLICACOES/EMPRESTIMOS
		xRet := SED->ED_CONTA
	EndIf
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/"
		If SEH->EH_APLEMP == "EMP" // Emprestimo
			xRet := "EMPRESTIMO: " + SEH->EH_NUMERO
		Else
			xRet := "APLICACAO: " + SEH->EH_NUMERO
		EndIf
	EndIf
	xRet := PadR(xRet, nTamCT2His) // Limita o tamanho conforme o campo
EndIf
RestArea(aAreaSEH)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP580: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP580: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet