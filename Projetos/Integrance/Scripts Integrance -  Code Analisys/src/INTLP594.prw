#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ INTLP594 บAutor ณ Jonathan Schmidt Alvesบ Data ณ30/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Customizacao para tratamento do LP 594 (Compensacao entre  บฑฑ
ฑฑบ          ณ Carteiras). Pode ser usado tambem no ??? (oposto).         บฑฑ
ฑฑบ          ณ LP: 594: Contas Pagar/Receber - Compensacao Carteiras      บฑฑ
ฑฑบ          ณ LP: ???: Contas Pagar/Receber - Exc Compensacao Carteiras  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ Parametros:                                                บฑฑ
ฑฑบ          ณ 01) cPrc: Processo                                         บฑฑ
ฑฑบ          ณ               VLR=Valor                                    บฑฑ
ฑฑบ          ณ               DEB=Conta Contabil Debito                    บฑฑ
ฑฑบ          ณ               CRD=Conta Contabil Credito                   บฑฑ
ฑฑบ          ณ               HIS=Historico                                บฑฑ
ฑฑบ          ณ               CCD=Centro Custo Debito                      บฑฑ
ฑฑบ          ณ               CCC=Centro Custo Credito                     บฑฑ
ฑฑบ          ณ               ITD=Item Contabil Debito                     บฑฑ
ฑฑบ          ณ               ITC=Item Contabil Credito                    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ 02) cSeq: Sequencial: Todos                                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ 03) cHis: Historico adicional (para estornos)              บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ 04) lRat: Com rateio ou sem rateio                         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณ Tabelas posicionadas: SE1/SE2/SE5                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

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