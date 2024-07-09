#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP520 ºAutor ³ Jonathan Schmidt Alvesº Data ³09/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 520 (Baixas Receber)    º±±
±±º          ³ Pode ser usado tambem no 527 (oposto).                     º±±
±±º          ³ LP: 520: CONTAS A RECEBER - BAIXAS DE TITULOS EM CARTEIRA  º±±
±±º          ³ LP: 527: CONTAS A RECEBER - CANC DE BAIXAS DE TITULOS      º±±
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
±±º          ³ Tabelas posicionadas: SE1                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP520(cPrc, cSeq, cHis, lRat)
Local xRet := Nil
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local nTamCT1Cod := TamSX3("CT1_CONTA")[1]
Local nTamCTTCod := TamSX3("CTT_CUSTO")[1]
Local nTamCTDCod := TamSX3("CTD_ITEM")[1]
Local nTamCT2His := TamSX3("CT2_HIST")[1]
Local nTamSEDCod := TamSX3("ED_CODIGO")[1]
Local nPerc := 1 // Padrao mult por 1 mesmo
Default cHis := ""
Default lRat := .F. // .F.=Trata o LP 500 (sem rateio) .T.=Trata o LP ??? (com rateio)
ConOut("INTLP520: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP520: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP520: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO: " + SE1->E1_PREFIXO + "/" + SE1->E1_NUM + "/" + SE1->E1_PARCELA + "/" + SE1->E1_TIPO)
If cPrc == "VLR" // Valor
	If cSeq == "001" //
		If !(SE5->E5_TIPO $ "TX /MAN/")
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "002" // RECEITA DE DESCONTO OBTIDOS
		xRet := SE5->E5_VLDESCO
	ElseIf cSeq == "003" // MULTA (MULTA MORATORIA E JUROS)
		xRet := SE5->E5_VLMULTA
	ElseIf cSeq == "004" // JUROS (MULTA MORATORIA E JUROS)
		xRet := SE5->E5_VLJUROS
	ElseIf cSeq == "009" // MANUAIS
		If SE5->E5_TIPO == "MAN"
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "030" // CORRECAO MONETARIA
		xRet := Abs(SE5->E5_VLCORRE)
	ElseIf cSeq >= "031" .And. cSeq <= "042" // Variacao Cambial Nao Realizada para Ganho/Perda (031=Mes Janeiro ate 042=Dezembro)

		/*
		cMesPrc := StrZero(Val(cSeq) - 30,2) // "01"=Janeiro "02"=Fevereiro "12"=Dezembro etc
		If Left(DtoS(SE5->E5_DATA),4) + cMesPrc < Left(DtoS(SE5->E5_DATA),06)
			//            LoadsSE5(       Periodo para carregamento SE5, "R"=Receb "P"=Pagar,   Data Limite SE5)
			xRet := Abs(u_LoadsSE5(Left(DtoS(SE5->E5_DATA),4) + cMesPrc,      SE5->E5_RECPAG, SE5->E5_DATA - 1 ))
		EndIf
		*/

		dPerPrc := FirstDay(SE5->E5_DATA) // Primeiro dia do mes em questao			// 22/11/2019	->  01/11/2019
		For _w := 1 To (Val(cSeq) - 30) // Rodo n vezes
			dPerPrc := FirstDay(dPerPrc - 1) // Primeiro dia do mes anterior		// 01/11/2019 - 1 = 31/10/2019 = 01/10/2019
		Next
		
		cPerPrc := Left(DtoS(dPerPrc),6) // cMesPrc := StrZero(Val(cSeq) - 30,2) // "01"=Janeiro "02"=Fevereiro "12"=Dezembro etc
		If .T. // Left(DtoS(SE5->E5_DATA),4) + cMesPrc < Left(DtoS(SE5->E5_DATA),06)
			//            LoadsSE5(       Periodo para carregamento SE5, "R"=Receb "P"=Pagar,  Data Limite SE5)
			//xRet := Abs(u_LoadsSE5(Left(DtoS(SE5->E5_DATA),4) + cMesPrc,      SE5->E5_RECPAG, SE5->E5_DATA - 1))
			
			//            LoadsSE5(Periodo para carregamento SE5, "R"=Receb "P"=Pagar,  Data Limite SE5)
			xRet := Abs(u_LoadsSE5(                      cPerPrc,      SE5->E5_RECPAG, SE5->E5_DATA - 1))
			
		EndIf
		
	EndIf
ElseIf cPrc == "DEB" // Conta Debito
	xRet := Space(nTamCT1Cod)
	If cSeq == "001" // BAIXA DE TITULOS A PAGAR
		xRet := SA6->A6_CONTA
	ElseIf cSeq == "009" // MANUAIS
		xRet := SA6->A6_CONTA
	ElseIf cSeq == "030" // CORRECAO MONETARIA
		If SE5->E5_VLCORRE > 0 // Perda Cambial
			xRet := SA1->A1_CONTA
		Else // Ganho cambial
			xRet := "5510030003"
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			// Positivo: // Debito 5510030003 Credito 5510030005 ??? Conferir
			If QRYSE5->E5_VALOR > 0 // Esse SE5 eh o posicionado na query
				xRet = "5510030004"
			Else
				// Negativo: Debito 5510030004 Credito 5510030006 ??? Conferir
				xRet = "5510030003"
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/002/003/004/" // BAIXA DE TITULOS A RECEBER
		xRet := SA1->A1_CONTA
	ElseIf cSeq == "002" // RECEITA DE DESCONTO OBTIDOS
		xRet := "5510010002"
	ElseIf cSeq == "003" // MULTA
		xRet := "5510020006"
	ElseIf cSeq == "004" // JUROS
		xRet := "5510020006"
	ElseIf cSeq $ "009/" // BAIXA DE TITULOS MANUAIS
		xRet := SA1->A1_CONTA
	ElseIf cSeq $ "030/" // VARIACAO CAMBIAL
		If SE5->E5_VLCORRE < 0 // Perda Cambial
			xRet := SA1->A1_CONTA
		Else // Ganho cambial
			xRet := "5510030006"
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			// Positivo: Debito 5510030003 Credito 5510030005
			If QRYSE5->E5_VALOR > 0 // Esse SE5 eh o posicionado na query
				xRet = "5510030005"
			Else
				// Negativo: Debito 5510030004 Credito 5510030006
				xRet = "5510030006"
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/"
		xRet := "RECEB: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
	ElseIf cSeq $ "009/" // MANUAIS
		xRet := "RECEB: " + SE1->E1_NUM + " " + AllTrim(SE1->E1_HIST)
	ElseIf cSeq $ "030/"
		If SE5->E5_VLCORRE < 0 // Perda Cambial
			xRet := "PERDA CAMBIAL: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
		ElseIf SE5->E5_VLCORRE > 0 // Ganho Cambial
			xRet := "GANHO CAMBIAL: " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR > 0
				xRet := "GANHO CAMBIAL REAL " + SubStr(QRYSE5->E5_DATA,5,2) + "/" + Left(QRYSE5->E5_DATA,4) + " " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)
			Else
				xRet := "PERDA CAMBIAL REAL " + SubStr(QRYSE5->E5_DATA,5,2) + "/" + Left(QRYSE5->E5_DATA,4) + " " + SE1->E1_NUM + " " + AllTrim(SA1->A1_NOME)			
			EndIf
		EndIf
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
	If cSeq $ "001/002/003/004/"
		xRet := SA1->A1_ITEMCTA
	ElseIf cSeq $ "009/" // Manuais
		xRet := SA1->A1_ITEMCTA
	ElseIf cSeq $ "030/" // Ganho/Perda cambial
		If SE5->E5_VLCORRE > 0 // Perda Cambial
			xRet := SA1->A1_ITEMCTA
		Else
			xRet := SA1->A1_ITEMCTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR < 0 // Ganho Cambial
				xRet := SA1->A1_ITEMCTA
			Else
				xRet := SA1->A1_ITEMCTA
			EndIf
		EndIf
	EndIf
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/002/003/004/"
		xRet := SA1->A1_ITEMCTA
	ElseIf cSeq $ "009/" // Manuais
		xRet := SA1->A1_ITEMCTA
	ElseIf cSeq $ "030/" // Ganho/Perda cambial
		If SE5->E5_VLCORRE < 0 // Ganho Cambial
			xRet := SA1->A1_ITEMCTA
		Else
			xRet := SA1->A1_ITEMCTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR < 0 // Ganho Cambial
				xRet := SA1->A1_ITEMCTA
			Else
				xRet := SA1->A1_ITEMCTA
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSE1)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP520: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP520: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet