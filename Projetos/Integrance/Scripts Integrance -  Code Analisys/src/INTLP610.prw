#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP610 ºAutor ³ Jonathan Schmidt Alvesº Data ³17/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 610 (Geracao de Notas   º±±
±±º          ³ de Saida por Item). Pode ser usado tambem no 630 (oposto). º±±
±±º          ³ LP: 610: DOCUMENTO DE SAIDA - INCLUSAO DOCS ITENS          º±±
±±º          ³ LP: 630: DOCUMENTO DE SAIDA - EXCLUSAO DE DOCS ITENS       º±±
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
±±º          ³ Tabelas posicionadas: SF2/SD2                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP610(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 650 (sem rateio) .T.=Trata o LP 651 (com rateio)
ConOut("INTLP610: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP610: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP610: " + DtoC(Date()) + " " + Time() + " " + cUserName + " D2_DOC/D2_SERIE/D2_CF: " + SD2->D2_DOC + "/" + SD2->D2_SERIE + "/" + SD2->D2_CF)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // ICMS S/VENDAS
		If AllTrim(SD2->D2_CF) $ "5101/5401/5403/5102/5116/" /*910/*/ + "5123/" + "6101/6401/6403/6102/6116/" /*910/*/ + "6123/"
			xRet := SD2->D2_VALICM
		EndIf
	ElseIf cSeq == "002" // PIS S/ FATURAMENTO
		If AllTrim(SD2->D2_CF) $ "5101/5401/5403/5102/5116/5933/5123/" + "6101/6401/6403/6102/6116/6933/6123/"
			xRet := SD2->D2_VALIMP6
		EndIf
	ElseIf cSeq == "003" // REVENDA DE MERCADORIA
		If AllTrim(SD2->D2_CF) $ "5102/5119/5405/5403/5120/5123/" + "6102/6119/6405/6403/6120/6123/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_DESCON
		EndIf
	ElseIf cSeq == "004" // COFINS S/ FATURAMENTO
		If AllTrim(SD2->D2_CF) $ "5101/5401/5403/5102/5933/5123/" + "6101/6401/6403/6102/6933/6123/"
			xRet := SD2->D2_VALIMP5
		EndIf
	ElseIf cSeq == "005" // ICMS RETIDO
		If AllTrim(SD2->D2_CF) $ "5401/5403/" + "6401/6403/"
			xRet := SD2->D2_ICMSRET
		EndIf
	ElseIf cSeq == "006" // ICMS INTEREST UF DEST. FINAL
		If AllTrim(SD2->D2_CF) $ "5108/" + "6108/"
			xRet := SD2->D2_DIFAL
		EndIf
	ElseIf cSeq == "007" // VENDA DE MATERIAIS INDUSTRIALIZADO
		If AllTrim(SD2->D2_CF) $ "5101/" + "5109/" + "5401/5111/5116/" + "6101/" + "6109/" + "6401/6111/6116/"// Incluida 109 em 25/07/2019 (Jonathan/Wesley)
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_DESCON
		EndIf
	ElseIf cSeq == "008" // DEVOLUÇÃO DE MAT CONSUMO
		If AllTrim(SD2->D2_CF) $ "5556/5413/" + "6556/6413/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI
		EndIf
	ElseIf cSeq == "009" // DEVOLUÇÃO DE ATIVO IMOBILIZADO
		If AllTrim(SD2->D2_CF) $ "5551/5401/5412/" + "6551/6401/6412/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALICM
		EndIf
	ElseIf cSeq == "010" // DEVOLUÇÃO DE COMPRA INDUSTRIALIZAÇÃO
		If AllTrim(SD2->D2_CF) $ "5201/5401/5410/" + "6201/6401/6410/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_ICMSRET
		EndIf
	ElseIf cSeq == "011" // REMESSA DE VENDA DE FATURAMENTO ANTECIPA	-> Verificar sequencia de "11" -> "011" (corrigir)
		If AllTrim(SD2->D2_CF) $ "5116/5117/" + "6116/6117/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI
		EndIf
	ElseIf cSeq == "018" // DEVOLUÇÃO DE COMPRA P/ COMERCIALIZAÇÃO
		If AllTrim(SD2->D2_CF) $ "5202/5411/" + "6202/6411/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_ICMSRET
		EndIf
	ElseIf cSeq == "025" // ICMS S/DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5201/5410/" + "6201/6410/"
			xRet := SD2->D2_VALICM
		EndIf
	ElseIf cSeq == "026" // PIS S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5201/5410/5411/5412/" + "6201/6410/6411/6412/"
			xRet := SD2->D2_VALIMP6
		EndIf
	ElseIf cSeq == "027" // COFINS S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5201/5410/5411/5412/" + "6201/6410/6411/6412/"
			xRet := SD2->D2_VALIMP5
		EndIf
	ElseIf cSeq == "028" // IPI À RECOLHER
		If AllTrim(SD2->D2_CF) $ "5101/5102/5403/" + "6101/6102/6403/"
			xRet := SD2->D2_VALIPI
		EndIf
	ElseIf cSeq == "029" // ICMS S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5202/5411/" + "6202/6411/"
			xRet := SD2->D2_VALICM
		EndIf
	ElseIf cSeq == "030" // PIS S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5202/5411/" + "6202/6411/"
			xRet := SD2->D2_VALIMP6
		EndIf
	ElseIf cSeq == "031" // COFINS S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5202/5411/" + "6202/6411/"
			xRet := SD2->D2_VALIMP5
		EndIf
	ElseIf cSeq == "032" // IPI S/ DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5202/5411/" + "6202/6411/"
			xRet := SD2->D2_VALIPI
		EndIf
	ElseIf cSeq == "033" // ICMS ST SOBRE DEVOLUÇÃO
		If AllTrim(SD2->D2_CF) $ "5411/5413/" + "6411/6413/"
			xRet := SD2->D2_ICMSRET
		EndIf
		
	ElseIf cSeq == "034" // EXPORTAÇÃO DE MERCADORIA
		If AllTrim(SD2->D2_CF) $ "7101/7102/"
			xRet := SD2->D2_TOTAL + SD2->D2_VALIPI
		EndIf
		
	ElseIf cSeq == "035" // SERVIÇOS PRESTADOS
		If AllTrim(SD2->D2_CF) $ "5933/6933/7949/"
			xRet := SD2->D2_TOTAL
		EndIf
	ElseIf cSeq == "036" // ISS SOBRE SERVIÇOS PRESTADOS
		If AllTrim(SD2->D2_CF) $ "5933/" + "6933/"
			xRet := SD2->D2_VALISS
		EndIf
	ElseIf cSeq == "037" // ICMS SOBRE DESPESAS
		If AllTrim(SD2->D2_CF) $ "5910/5911/5912/5917/5927/5949/" + "6910/6911/6912/6917/6927/6949/"
			xRet := SD2->D2_VALICM
		EndIf
	ElseIf cSeq == "038" // IPI SOBRE REMESSA
		If AllTrim(SD2->D2_CF) $ "5910/5911/5912/5917/5927/5949/" + "6910/6911/6912/6917/6927/6949/"
			xRet := SD2->D2_VALIPI
		EndIf
	ElseIf cSeq == "040" // VENDA DE SUCATA
		If AllTrim(SD2->D2_TES) $ "52U" // "510" Alterado em 06/08/2019 // "579/" Alterado em 05/06/2019
			xRet := SD2->D2_TOTAL
		EndIf
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001"
		xRet := "3120010003"
	ElseIf cSeq == "002"
		xRet := "3120010004"
	ElseIf cSeq == "003"
		xRet := "1120010001"
	ElseIf cSeq == "004"
		xRet := "3120010005"
	ElseIf cSeq == "005"
		xRet := "3120010002"
	ElseIf cSeq == "006"
		xRet := "3120010003"
	ElseIf cSeq == "007"
		xRet := "1120010001"
	ElseIf cSeq == "008"
		xRet := "2110020001"
	ElseIf cSeq == "009"
		xRet := "2110020001"
	ElseIf cSeq == "010"
		xRet := "2110020001"
	ElseIf cSeq == "011"
		xRet := "2110150002"
	ElseIf cSeq == "018"
		xRet :=	"2110020001"
	ElseIf cSeq == "025"
		xRet :=	"4310020001"
	ElseIf cSeq == "026"
		xRet :=	"4310010001"
	ElseIf cSeq == "027"
		xRet :=	"4310010001"
	ElseIf cSeq == "028"
		xRet :=	"3120010001"
	ElseIf cSeq == "029"
		xRet :=	"4110020001"
	ElseIf cSeq == "030"
		xRet :=	"4110010001"
	ElseIf cSeq == "031"
		xRet :=	"4110010001"
	ElseIf cSeq == "032"
		xRet :=	"4110020002"
	ElseIf cSeq == "033"
		xRet :=	"3120010011"

	ElseIf cSeq == "034" // Exportacao
		xRet := SA1->A1_CONTA

	ElseIf cSeq == "035"
		xRet :=	"1120010001"
	ElseIf cSeq == "036"
		xRet :=	"3120010006"
	ElseIf cSeq == "037" // ICMS S DESPESAS
		xRet :=	"5260010006"
	ElseIf cSeq == "038" // IPI S REMESSA
		xRet :=	"5260010010"
	ElseIf cSeq == "040" // SUCATA
		xRet := "1120010001"
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // 3120010003
		xRet := "2110080001"
	ElseIf cSeq == "002"
		xRet := "2110080004"
	ElseIf cSeq == "003"
		xRet := "3110010003"
	ElseIf cSeq == "004"
		xRet := "2110080005"
	ElseIf cSeq == "005"
		xRet := "2110080002"
	ElseIf cSeq == "006"
		xRet := "2110080015"
	ElseIf cSeq == "007"
		xRet := "3110010001"
	ElseIf cSeq == "008"
		xRet := "1140010080"
	ElseIf cSeq == "009"
		xRet := "1230010099"
	ElseIf cSeq == "010"
		xRet := "4310010002"
	ElseIf cSeq == "011"
		xRet := "3110010001"
	ElseIf cSeq == "018"
		xRet :=	"4110010007"
	ElseIf cSeq == "025"
		xRet :=	"2110080001"
	ElseIf cSeq == "026"
		xRet :=	"2110080004"
	ElseIf cSeq == "027"
		xRet :=	"2110080005"
	ElseIf cSeq == "028"
		xRet :=	"2110080006"
	ElseIf cSeq == "029"
		xRet :=	"2110080001"
	ElseIf cSeq == "030"
		xRet :=	"2110080004"
	ElseIf cSeq == "031"
		xRet :=	"2110080005"
	ElseIf cSeq == "032"
		xRet :=	"2110080006"
	ElseIf cSeq == "033"
		xRet :=	"2110080002"
		
	ElseIf cSeq == "034"
		If AllTrim(SD2->D2_CF) $ "7101/"
			xRet :=	"3110030001" // VENDA DE PRODUTOS - EXTERIOR
		ElseIf AllTrim(SD2->D2_CF) $ "7102/"
			xRet := "3110030003" // VENDA DE MERCADORIAS - EXTERIOR
		EndIf
		
	ElseIf cSeq == "035"
		xRet :=	"3110020001"
	ElseIf cSeq == "036"
		xRet :=	"2110080003"
	ElseIf cSeq == "037" // ICMS S DESPESAS
		xRet :=	"2110080001"
	ElseIf cSeq == "038" // IPI S REMESSA
		xRet :=	"2110080006"
	ElseIf cSeq == "040" // VENDA DE SUCATA
		xRet := "3110010005"
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/002/003/004/005/006/007/008/009/010/011/018/025/026/027/028/029/030/031/032/033/034/035/036/" + "037/038/" + "040/"
		xRet := "NF." + AllTrim(SD2->D2_DOC) + " " + AllTrim(SA1->A1_NREDUZ)
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
	If cSeq $ "003/007/008/009/010/011/035/040/"
		xRet := SA1->A1_ITEMCTA
	ElseIf cSeq $ "018/" // Devolucao (ajustar no processo)
		xRet := SA1->A1_ITEMCTA
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "003/007/008/009/010/011/018/035/040/"
		xRet := "999999"
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
EndIf
ConOut("INTLP610: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP610: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet