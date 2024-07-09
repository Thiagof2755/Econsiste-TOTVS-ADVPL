#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP650 ºAutor ³ Jonathan Schmidt Alvesº Data ³17/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 650 (Entrada de Notas   º±±
±±º          ³ por Item). Pode ser usado tambem no 655 (oposto).          º±±
±±º          ³ LP: 650: DOCUMENTO DE ENTRADA - INCLUSAO DOCS ITENS        º±±
±±º          ³ LP: 655: DOCUMENTO DE ENTRADA - EXCLUSAO DE DOCS ITENS     º±±
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
±±º          ³ Tabelas posicionadas: SF1/SD1                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP650(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 650 (sem rateio) .T.=Trata o LP 651 (com rateio)
ConOut("INTLP650: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP650: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP650: " + DtoC(Date()) + " " + Time() + " " + cUserName + " D1_DOC/D1_SERIE/D1_CF: " + SD1->D1_DOC + "/" + SD1->D1_SERIE + "/" + SD1->D1_CF)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // NOTA FISCAL DE ENTRADA DE INSUMOS
		If AllTrim(SD1->D1_CF) $ "1101/"
			xRet := SD1->D1_BASEICM
		EndIf
	ElseIf cSeq == "002" // CRÉDITO DE ICMS DE ENTRADA DE INSUMOS
		If AllTrim(SD1->D1_CF) $ "1101/2101/"
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "003" // CREDITO IPI S/ NF DE INSUMO
		If AllTrim(SD1->D1_CF) $ "1101/" + "2101/" // (Jonathan incluido 2101 em 28/01/2020)
			xRet := SD1->D1_VALIPI
		EndIf
	ElseIf cSeq == "004" // ENTRADAS - MAT. PRIMA UTILIZADO NO PROD
		If AllTrim(SD1->D1_CF) $ "1101/1401/2101/2401/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
		EndIf
	ElseIf cSeq == "005" // ICMS S/ ENTRADAS - MAT. PRIMA
		If AllTrim(SD1->D1_CF) $ "3101/"
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "007" // IPI S/ ENTRADAS  - MATÉRIA PRIMA
		If AllTrim(SD1->D1_CF) $ "3101/"
			xRet := SD1->D1_VALIPI
		EndIf
	ElseIf cSeq == "008" // ENTRADAS - MERCADORIA P/ REVENDA
		If AllTrim(SD1->D1_CF) $ "1102/1403/2102/2403/1118/2118/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA + SD1->D1_ICMSRET // Incluido ICMSRET 24/05/2019 Jonathan (remoto)
		EndIf
	ElseIf cSeq == "009" // ICMS S/ ENTRADA - COMPRA P/ REVENDA
		If AllTrim(SD1->D1_CF) $ "1102/2112/1118/2118/"
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "010" // IPI S/ COMPRAS P/ REVENDA
		If AllTrim(SD1->D1_CF) $ "1102/" + "2102/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIPI
		EndIf
	ElseIf cSeq == "011" // COMPRA DE ATIVO IMOBILIZADO
		If AllTrim(SubStr(SD1->D1_CF,2,3)) $ "551/406/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
		EndIf
	ElseIf cSeq == "012" // COMPRA MAT. P/  USO E CONSUMO
		If AllTrim(SD1->D1_CF) $ "1556/1407/2556/2407/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
		EndIf
	ElseIf cSeq == "013" // DEVOLUÇÃO DE VENDAS
		If AllTrim(SD1->D1_CF) $ "1201/2201/" + "1219/2219/" + "1919/2919/"
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "014" // ICMS S/ DEVOLUÇÃO DE PROD. IND.
		If AllTrim(SD1->D1_CF) $ "1201/2201/"
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "015" // PIS S/ DEVOLUÇÃO PROD IND
		If AllTrim(SD1->D1_CF) $ "1201/2201/"
			xRet := SD1->D1_VALIMP6
		EndIf
	ElseIf cSeq == "016" // COFINS S/ DEVOLUÇÃO VENDA PROD IND.
		If AllTrim(SD1->D1_CF) $ "1201/2201/"
			xRet := SD1->D1_VALIMP5
		EndIf
	ElseIf cSeq == "017" // IPI S/ DEV. DE VENDA PROD. IND.
		If AllTrim(SD1->D1_CF) $ "1201/" + "2201/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_BASEIPI
		EndIf
	ElseIf cSeq == "018" // ICMS SOBRE CIAP
		If AllTrim(SD1->D1_CF) $ "1604/" + "2604/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "019" // DEVOLUÇÃO MERCADORIA P/ REVENDA
		If AllTrim(SD1->D1_CF) $ "1202/2202/" + "1411/2411/"
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "020" // ICMS S/ DEVOLUÇÃO DE VENDA
		If AllTrim(SD1->D1_CF) $ "1202/2202/"
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "021" // PIS S/ DEVOLUÇÕES VENDA DE MER.REV
		If AllTrim(SD1->D1_CF) $ "1202/2202/"
			xRet := SD1->D1_VALIMP6
		EndIf
	ElseIf cSeq == "022" // COFINS S/ DEVOLUÇÃO VENDA MERC REV
		If AllTrim(SD1->D1_CF) $ "1202/2202/"
			xRet := SD1->D1_VALIMP5
		EndIf
	ElseIf cSeq == "023" // IPI S/ DEVOLUÇÃO DE MERC. REV.
		If AllTrim(SD1->D1_CF) $ "1202/2202/"
			xRet := SD1->D1_BASEIPI
		EndIf
	ElseIf cSeq == "024" // DESPESAS TELEFONE E CENTRO DE CUSTO
		If AllTrim(SD1->D1_CF) $ "1302/1303/" + "2302/2303/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "025" // DESPESAS COM FRETES
		If AllTrim(SD1->D1_CF) $ "1352/2352/" + "1353/" + "2353/" // Jonathan (incluido CFOP 2353) (28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "026" // ICMS S/ SERVIÇOS TOMADOS DE FRETES
		If AllTrim(SD1->D1_CF) $ "1352/1353/" + "2352/2353/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "027" // REMESSA P/ INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1901/" + "2901/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "028" // SERVIÇOS TOMADOS
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
		EndIf
	ElseIf cSeq == "029" // RETORNO INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1902/" + "2902/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "030" // SERVIÇOS DE INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1124/2124/"
			xRet := SD1->D1_TOTAL + SD1->D1_VALIPI + SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA
		EndIf
	ElseIf cSeq == "031" // CREDITO DE ICMS S/ SERVIÇOS INDUSTRIAL.
		If AllTrim(SD1->D1_CF) $ "1124/" + "2124/" // Jonathan 28/01/2020 (Bruna chamado)
			xRet := SD1->D1_VALICM
		EndIf
	ElseIf cSeq == "032" // ISS SOBRE SERVIÇOS TOMADOS
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALISS
		EndIf
	ElseIf cSeq == "033" // IPI S/ SERVIÇOS INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1124/" + "2124/" // Jonathan 28/01/2020 (Bruna chamado)
			xRet := SD1->D1_VALIPI
		EndIf
	ElseIf cSeq == "034" // COMPRA DE ENERGIA ELETRICA
		If AllTrim(SD1->D1_CF) $ "1252/1253/" + "2252/2253/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "035" // PIS S/ INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1101/2101/3101/4101/1124/2124/" + "3124/4124/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP6
		EndIf
	ElseIf cSeq == "036" // INSS RETIDO
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALINS
		EndIf
	ElseIf cSeq == "037" // COFINS S/ INDUSTRIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1101/2101/3101/4101/1124/2124/" + "3124/4124/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP5
		EndIf
	ElseIf cSeq == "038" // PIS S/ COMERCIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1102/2102/1352/2352/1118/2118/3102/1403/2403/" + "4102/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP6
		EndIf
	ElseIf cSeq == "039" // COFINS S/ COMERCIALIZAÇÃO
		If AllTrim(SD1->D1_CF) $ "1102/2102/1352/2352/1118/2118/3102/1403/2403/" + "4103/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP5
		EndIf
	ElseIf cSeq == "040" // DESPESAS COM COMPRA DE COMBUSTÍVEL
		If AllTrim(SD1->D1_CF) $ "1653/" + "2653/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_TOTAL
		EndIf
	ElseIf cSeq == "041" // PIS SOBRE DE ENERGIA ELÉTRICA
		If AllTrim(SD1->D1_CF) $ "1252/1253/" + "2252/2253/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP6
		EndIf
	ElseIf cSeq == "042" // COFINS SOBRE DE ENERGIA ELÉTRICA
		If AllTrim(SD1->D1_CF) $ "1252/1253/" + "2252/2253/" // (Jonathan incluido em 28/01/2020)
			xRet := SD1->D1_VALIMP5
		EndIf
	ElseIf cSeq == "044" // DESPESAS COM FRETES SOBRE VENDAS
		If AllTrim(SD2->D2_TES) $ "019/020/"
			xRet := SD2->D2_TOTAL
		EndIf
	ElseIf cSeq == "045" // DESCONTO INCONDICIONAL
		xRet := SD1->D1_VALDESC
	ElseIf cSeq == "046" // PIS RETIDOS SOBRE NFS
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALPIS
		EndIf
	ElseIf cSeq == "047" // COFINS RETIDO SOBRE SERVIÇOS TOMADOS
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALCOF
		EndIf
	ElseIf cSeq == "048" // CSLL SOBRE SERVIÇOS TOMADOS
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALCSL
		EndIf
	ElseIf cSeq == "049" // IRRF RETIDO
		If AllTrim(SD1->D1_CF) $ "1933/2933/"
			xRet := SD1->D1_VALIRR
		EndIf
	ElseIf cSeq == "050" // FATURAS
		If AllTrim(SD1->D1_CF) $ "000"
			If SD1->D1_TES == "033" // Apenas na TES 033
				xRet := SD1->D1_TOTAL
			EndIf
		EndIf
	ElseIf cSeq == "051" // ALUGUEL
		If AllTrim(SD1->D1_CF) $ "000"
			If SD1->D1_TES == "041" // Apenas na TES 041
				xRet := SD1->D1_TOTAL
			EndIf
		EndIf		
	ElseIf cSeq == "052" // IRRF SOBRE ALUGUEL
		If AllTrim(SD1->D1_CF) $ "000"
			If SD1->D1_TES == "041" // Apenas na TES 041
				xRet := SD1->D1_VALIRR // SD1->D1_IRRF
			EndIf
		EndIf
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001"
		xRet := "4340010007"
	ElseIf cSeq == "002"
		xRet := "1130020001"
	ElseIf cSeq == "003"
		xRet := "1130020033"
	ElseIf cSeq == "004"
		xRet := "4310010002"
	ElseIf cSeq == "005"
		xRet := "1130020001"
	ElseIf cSeq == "007"
		xRet := "1130020033"
	ElseIf cSeq == "008"
		xRet := "4110010007"
	ElseIf cSeq == "009"
		xRet := "1130020001"
	ElseIf cSeq == "010"
		xRet := "1130020033"
	ElseIf cSeq == "011"
		xRet := "1230010001"
	ElseIf cSeq == "012"
		xRet := SD1->D1_CONTA
	ElseIf cSeq == "013"
		xRet := "3110010002" // Devolucao
	ElseIf cSeq == "014"
		xRet := "1130020001"
	ElseIf cSeq == "015"
		xRet := "1130020024"
	ElseIf cSeq == "016"
		xRet := "1130020025"
	ElseIf cSeq == "017"
		xRet := "1130020033"
	ElseIf cSeq == "018"
		xRet := "1130020001"
	ElseIf cSeq == "019" // DEVOLUÇÃO MERCADORIA P/ REVENDA
		xRet := "3110010004"
	ElseIf cSeq == "020"
		xRet := "1130020001"
	ElseIf cSeq == "021"
		xRet := "1130020024"
	ElseIf cSeq == "022"
		xRet := "1130020025"
	ElseIf cSeq == "023"
		xRet := "1130020033"
	ElseIf cSeq == "024"
		xRet := "5220010004"
	ElseIf cSeq == "025"
		xRet := SD1->D1_CONTA
	ElseIf cSeq == "026"
		xRet := "1130020001"
	ElseIf cSeq == "027"
		xRet := "1140010013"
	ElseIf cSeq == "028"
		xRet := SD1->D1_CONTA
	ElseIf cSeq == "029"
		xRet := "1140010011"
	ElseIf cSeq == "030"
		xRet := "4310010001"
	ElseIf cSeq == "031"
		xRet := "1130020001"
	ElseIf cSeq == "032"
		xRet := "2110020001"
	ElseIf cSeq == "033"
		xRet := "1130020033"
	ElseIf cSeq == "034"
		xRet := "5220010008"
	ElseIf cSeq == "035"
		xRet := "1130020024"
	ElseIf cSeq == "036"
		xRet := "2110020001"
	ElseIf cSeq == "037"
		xRet := "1130020025"
	ElseIf cSeq == "038"
		xRet := "1130020024"
	ElseIf cSeq == "039"
		xRet := "1130020025"
	ElseIf cSeq == "040"
		xRet := "5240010001"
	ElseIf cSeq == "041"
		xRet := "1130020024"
	ElseIf cSeq == "042"
		xRet := "1130020025"
	ElseIf cSeq == "044"
		xRet := "5140010008"
	ElseIf cSeq == "045"
		xRet := SA2->A2_CONTA // "2110020001"
	ElseIf cSeq == "046"
		xRet := "2110020001"
	ElseIf cSeq == "047"
		xRet := "2110020001"
	ElseIf cSeq == "048"
		xRet := "2110020001"
	ElseIf cSeq == "049" // IRRF
		xRet := "2110020001"
	ElseIf cSeq == "050"
		xRet := SD1->D1_CONTA
	ElseIf cSeq == "051"
		xRet := SD1->D1_CONTA
	ElseIf cSeq == "052"
		xRet := SA2->A2_CONTA
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001"
		xRet := "2110020001"
	ElseIf cSeq == "002"
		xRet := "4310020001"
	ElseIf cSeq == "003"
		xRet := "4310020002"
	ElseIf cSeq == "004"
		xRet := "2110020001"
	ElseIf cSeq == "005"
		xRet := "4310020001"
	ElseIf cSeq == "007"
		xRet := "4310020002"
	ElseIf cSeq == "008"
		xRet := "2110020001"
	ElseIf cSeq == "009"
		xRet := "4110020001"
	ElseIf cSeq == "010"
		xRet := "4110020002"
	ElseIf cSeq == "011"
		xRet := "2110020001"
	ElseIf cSeq == "012"
		xRet := "2110020001"
	ElseIf cSeq == "013"
		xRet := "1120010001"
	ElseIf cSeq == "014"
		xRet := "3120010012"
	ElseIf cSeq == "015"
		xRet := "3120010013"
	ElseIf cSeq == "016"
		xRet := "3120010014"
	ElseIf cSeq == "017"
		xRet := "3120010010"
	ElseIf cSeq == "018"
		xRet := "1130020032"
	ElseIf cSeq == "019"
		xRet := "1120010001"
	ElseIf cSeq == "020"
		xRet := "3120010012"
	ElseIf cSeq == "021"
		xRet := "3120010013"
	ElseIf cSeq == "022"
		xRet := "3120010014"
	ElseIf cSeq == "023"
		xRet := "3120010010"
	ElseIf cSeq == "024"
		xRet := SA2->A2_CONTA
	ElseIf cSeq == "025"
		xRet := "2110020001"
	ElseIf cSeq == "026"
		xRet := "5260010006"
	ElseIf cSeq == "027"
		xRet := "1140010007"
	ElseIf cSeq == "028"
		xRet := "2110020001"
	ElseIf cSeq == "029"
		xRet := "1140010013"
	ElseIf cSeq == "030"
		xRet := "2110020001"
	ElseIf cSeq == "031"
		xRet := "4310020001"
	ElseIf cSeq == "032"
		xRet := "2110090003"
	ElseIf cSeq == "033"
		xRet := "4310020002"
	ElseIf cSeq == "034"
		xRet := "2110020001"
	ElseIf cSeq == "035"
		xRet := "4310020004"
	ElseIf cSeq == "036"
		xRet := "2110090004"
	ElseIf cSeq == "037"
		xRet := "4310020003"
	ElseIf cSeq == "038" // PIS S/ COMERCIALIZAÇÃO
		If SD1->D1_TES $ "007"
			If "16.02 - VENDAS" $ SB1->B1_COD
				xRet := "5260010007"
			Else
				xRet := "4110020004"
			EndIf
		ElseIf SD1->D1_TES $ "002"
			xRet := "5260010007"
		EndIf
	ElseIf cSeq == "039" // COFINS S/ COMERCIALIZAÇÃO
		If SD1->D1_TES $ "007"
			If "16.02 - VENDAS" $ SB1->B1_COD
				xRet := "5260010008"
			Else
				xRet := "4110020003"
			EndIf
		ElseIf SD1->D1_TES $ "002"
			xRet := "5260010008"
		EndIf
	ElseIf cSeq == "040"
		xRet := "2110020001"
	ElseIf cSeq == "041"
		xRet := "5260010007"
	ElseIf cSeq == "042"
		xRet := "5260010008"
	ElseIf cSeq == "044"
		xRet := "2110020001"
	ElseIf cSeq == "045"
		xRet := "5510010002" // "5510020002" // "3120030001" // Alterado em 10/07/2019 (Conta diferente) // Alterado em 25/07/2019 (Jonathan)
	ElseIf cSeq == "046"
		xRet := "2110090002"
	ElseIf cSeq == "047"
		xRet := "2110090002"
	ElseIf cSeq == "048"
		xRet := "2110090002"
	ElseIf cSeq == "049"
		xRet := "2110090001"
	ElseIf cSeq == "050" // Faturas
		xRet := SA2->A2_CONTA // "2110020001" (Alterado 26/06/2019)
	ElseIf cSeq == "051" // Aluguel a pagar
		xRet := SA2->A2_CONTA // "2110110001" (Alterado 30/05/2019)
	ElseIf cSeq == "052" // IRRF Aluguel 
		xRet := "2110090005" // Aluguel a Pagar
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq == "001"
		xRet := "NF DE ENTRADA - INSUMOS: " + AllTrim(SD1->D1_DOC) + "  FORN. : " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "002/003/004/" + "005/" + "007/008/009/010/011/012/013/014/015/016/017/018/019/020/021/022/023/" + "027/029/" + "030/031/033/035/" + "037/038/039/040/" + "045/"
		xRet := "NF : " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "024/"
		xRet := "NFST: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "025/026/044/"
		xRet := "CTE: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "028/"
		xRet := "NFS: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "032/036/046/047/048/049/"
		xRet := "NFS: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "034/"
		xRet := "NFCEE: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "041/042/"
		xRet := "NFCEE: " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "050/"
		xRet := "FAT : " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
	ElseIf cSeq $ "051/052/"
		xRet := "ALG : " + AllTrim(SD1->D1_DOC) + " FORN.: " + SubStr(SA2->A2_NOME,1,20)
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
	If cSeq $ "001/004/008/011/012/019/024/025/028/030/034/040/044/050/"
		xRet := "999999"
	ElseIf cSeq $ "013/032/036/045/046/047/048/049/"
		xRet := SA2->A2_ITEMCTA
	ElseIf cSeq $ "051/052/" // Aluguel
		// Sem item contabil
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/"
		xRet := "F" + AllTrim(SD1->D1_FORNECE)
	ElseIf cSeq $ "004/008/011/012/024/025/028/030/034/040/044/050/"
		xRet := SA2->A2_ITEMCTA
	ElseIf cSeq $ "013/032/036/046/047/048/049/"
		xRet := "999999"
	ElseIf cSeq $ "019/"
		xRet := SA2->A2_ITEMCTA
	ElseIf cSeq $ "051/052/" // Aluguel
		// Sem item contabil
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
EndIf
ConOut("INTLP650: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP650: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet