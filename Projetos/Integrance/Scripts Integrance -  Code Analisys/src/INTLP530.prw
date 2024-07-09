#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ INTLP530 ºAutor ³ Jonathan Schmidt Alvesº Data ³08/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Customizacao para tratamento do LP 530 (Baixas Pagar)      º±±
±±º          ³ Pode ser usado tambem no ??? (oposto).                     º±±
±±º          ³ LP: 530: CONTAS A PAGAR - BAIXA DE TITULOS                 º±±
±±º          ³ LP: 531: CONTAS A PAGAR - CANCELAMENTO DE BAIXAS DE TITULOSº±±
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
±±º          ³ Tabelas posicionadas: SE2/SE5                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function INTLP530(cPrc, cSeq, cHis, lRat)
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
ConOut("INTLP530: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
ConOut("INTLP530: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Prc: " + cPrc + " Seq: " + cSeq)
ConOut("INTLP530: " + DtoC(Date()) + " " + Time() + " " + cUserName + " E2_PREFIXO/E2_NUM/E2_PARCELA/E2_TIPO: " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + "/" + SE2->E2_PARCELA + "/" + SE2->E2_TIPO)
If cPrc == "VLR" // Valor
	xRet := 0
	If cSeq == "001" // BAIXA DE TITULOS A PAGAR
		If !(SE5->E5_TIPO $ "TX /FOL/IMP/MAN/EMP/")
			xRet := SE5->E5_VALOR - SE5->E5_VLDESCO - SE5->E5_VLMULTA - SE5->E5_VLJUROS // Alterado 25/05/2019
		EndIf
	ElseIf cSeq == "002" // RECEITA DE DESCONTO OBTIDOS
		xRet := SE5->E5_VLDESCO
	ElseIf cSeq == "003" // MULTA (MULTA MORATORIA E JUROS)
		xRet := SE5->E5_VLMULTA
	ElseIf cSeq == "004" // JUROS (MULTA MORATORIA E JUROS)
		xRet := SE5->E5_VLJUROS
	ElseIf cSeq == "005" // FOLHA PGTO
		If SE5->E5_TIPO == "FOL"
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "006" // IMPOSTO
		If SE5->E5_TIPO == "IMP"
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "007" // EMPRESTIMOS
		If SE5->E5_TIPO == "EMP"
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "009" // MANUAIS
		If SE5->E5_TIPO == "MAN"
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "011" // PROV PIS
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("PIS",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "012" // PROV COFINS
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("COFINS",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "013" // PROV CSLL
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("CSLL",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "021" // PROV ISS
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("ISS",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "022" // PROV IRRF
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("IRF",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "023" // PROV INSS
		If SE5->E5_TIPO == "TX " .And. SE5->E5_NATUREZ == PadR("INSS",nTamSEDCod)
			xRet := SE5->E5_VALOR
		EndIf
	ElseIf cSeq == "030" // CORRECAO MONETARIA
		xRet := Abs(SE5->E5_VLCORRE)
		
	ElseIf cSeq >= "031" .And. cSeq <= "042" // Variacao Cambial Nao Realizada para Ganho/Perda (031=Mes Janeiro ate 042=Dezembro)
		
		dPerPrc := FirstDay(SE5->E5_DATA) // Primeiro dia do mes em questao
		For _w := 1 To (Val(cSeq) - 30) // Rodo n vezes
			dPerPrc := FirstDay(dPerPrc - 1) // Primeiro dia do mes anterior
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
		If SE5->E5_TIPO == "INJ" // Alteracao 20/09/2019 (Jonathan/Renato)
			If SE5->E5_FILIAL == "1010" // Petrofer
				xRet := "2210010007"
			Else
				xRet := "2110120004"
			EndIf
		ElseIf SE5->E5_TIPO == "EMP" // Alteracao 20/09/2019 (Jonathan/Renato)
			If SE5->E5_FILIAL == "1010" // Petrofer
				xRet := "2210010005"
			Else // Outras empresas
				xRet := "2110120001"
			EndIf
		Else
			xRet := SA2->A2_CONTA
		EndIf
	ElseIf cSeq == "002" // RECEITA DE DESCONTO OBTIDOS
		xRet := SA2->A2_CONTA // "5510010002" // Alterado 23/05/2019
	ElseIf cSeq == "003" // MULTA
		xRet := "5510020006"
	ElseIf cSeq == "004" // JUROS
		xRet := "5510020006"
	ElseIf cSeq == "005" // FOLHA PGTO
		xRet := SED->ED_CONTA
	ElseIf cSeq == "006" // IMPOSTO
		xRet := SED->ED_CONTA
	ElseIf cSeq == "007" // EMPRESTIMOS
		xRet := SED->ED_CONTA
	ElseIf cSeq == "009" // MANUAIS
		xRet := SA2->A2_CONTA
	ElseIf cSeq == "011/012/013/" // PIS COFINS CSLL
		xRet := "2110090002"
	ElseIf cSeq == "021" // ISS
		xRet := "2110090003"
	ElseIf cSeq == "022" // IRRF
		xRet := "2110090001"
		If "MATA100" $ SE2->E2_ORIGEM // Titulo teve origem no Compras
			// Posiciono no titulo pai pelo E2_TITPAI
			aAreaSE2 := SE2->(GetArea())
			SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_FORNECE + E2_LOJA
			If !Empty(SE2->E2_TITPAI) .And. SE2->(DbSeek( SE2->E2_FILIAL + RTRim(SE2->E2_TITPAI) ))
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
				If SF1->(DbSeek(SE2->E2_FILIAL + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA + "N"))
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1)) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
					If SD1->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
						If "NFS" $ SF1->F1_ESPECIE // IRRF S/ SERVICOS TOMADOS
							xRet := "2110090001"
						Else // Se nao for NFS... vamos avaliar o tipo do primeiro produto da nota
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
							If SB1->(DbSeek(SD1->D1_FILIAL + SD1->D1_COD))
								If !Empty(SB1->B1_GRUPO) // Grupo do produto preenchido
									DbSelectArea("SBM") // Grupos de Produtos
									SBM->(DbSetOrder(1)) // BM_FILIAL + BM_GRUPO
									If SBM->(DbSeek(xFilial("SBM") + SB1->B1_GRUPO))
										If Left(SB1->B1_GRUPO,3) == "ALU" // Alugueis
											xRet := "2110090005"
										EndIf
									EndIf
								Else // Grupo do produto nao preenchido
									If SB1->B1_TIPO $ "AL" // Alugueis
										xRet := "2110090005"
									ElseIf SB1->B1_TIPO $ "SV" // Servicos
										xRet := "2110090001"
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			RestArea(aAreaSE2)
		EndIf
	ElseIf cSeq == "023" // INSS
		xRet := "2110090004"
	ElseIf cSeq == "030" // CORRECAO MONETARIA
		If SE5->E5_VLCORRE > 0 // Perda Cambial
			xRet := "5510030003"
		Else // Ganho cambial
			xRet := SA2->A2_CONTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			// Positivo: Debito 5510030003 Credito 5510030005
			If QRYSE5->E5_VALOR > 0 // Esse SE5 eh o posicionado na query
				xRet = "5510030003"
			Else // Negativo: Debito 5510030004 Credito 5510030006
				xRet = "5510030004"
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "CRD" // Conta Credito
	xRet := Space(nTamCT1Cod)
	If cSeq $ "001/002/003/004/011/012/013/021/022/023/" // BAIXA DE TITULOS A PAGAR
		xRet := SA6->A6_CONTA
	ElseIf cSeq == "002" // DESCONTO
		xRet := "5510010002"
	ElseIf cSeq == "005" // FOLHA PGTO
		xRet := SA6->A6_CONTA
	ElseIf cSeq == "006" // IMPOSTO
		xRet := SA6->A6_CONTA
	ElseIf cSeq == "007" // EMPRESTIMOS
		xRet := SA6->A6_CONTA
	ElseIf cSeq $ "009/" // BAIXA DE TITULOS MANUAIS
		xRet := SA6->A6_CONTA
	ElseIf cSeq $ "030/" // VARIACAO CAMBIAL
		If SE5->E5_VLCORRE < 0 // Ganho Cambial
			xRet := "5510030006"
		Else // Ganho cambial
			xRet := SA2->A2_CONTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			// Positivo: Debito 5510030003 Credito 5510030005
			If QRYSE5->E5_VALOR > 0 // Esse SE5 eh o posicionado na query
				xRet = "5510030005"
			Else // Negativo: Debito 5510030004 Credito 5510030006
				xRet = "5510030006"
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCT1Cod) // Tamanho das contas
ElseIf cPrc == "HIS" // Historico
	xRet := Space(nTamCT2His)
	If cSeq $ "001/002/003/004/011/012/013/021/022/023/"
		xRet := "PGTO: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
	ElseIf cSeq $ "005/" // FOLHA PGTO
		xRet := "PGTO FOLHA: " + SE2->E2_NUM + " " + AllTrim(SE2->E2_HIST)
	ElseIf cSeq $ "006/" // IMPOSTO
		xRet := "PGTO IMP: " + SE2->E2_NUM + " " + AllTrim(SE2->E2_HIST)
	ElseIf cSeq $ "007/" // EMPRESTIMOS
		xRet := "EMPRESTIMO: " + SE2->E2_NUM + " " + AllTrim(SE2->E2_HIST)
	ElseIf cSeq $ "009/" // MANUAIS
		xRet := "PGTO: " + SE2->E2_NUM + " " + AllTrim(SE2->E2_HIST)
	ElseIf cSeq $ "030/"
		If SE5->E5_VLCORRE > 0 // Perda Cambial
			xRet := "PERDA CAMBIAL: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
		ElseIf SE5->E5_VLCORRE < 0 // Ganho Cambial
			xRet := "GANHO CAMBIAL: " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR > 0
				xRet := "PERDA CAMBIAL REAL " + SubStr(QRYSE5->E5_DATA,5,2) + "/" + Left(QRYSE5->E5_DATA,4) + " " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
			Else
				xRet := "GANHO CAMBIAL REAL " + SubStr(QRYSE5->E5_DATA,5,2) + "/" + Left(QRYSE5->E5_DATA,4) + " " + SE2->E2_NUM + " " + AllTrim(SA2->A2_NOME)
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
		
		If RTrim(CTK->CTK_DEBITO) $ "2210010007/2110120004/2210010005/2110120001/2110110020/" + "2110020001/"
			xRet := SA2->A2_ITEMCTA
		ElseIf RTrim(CTK->CTK_CREDIT) $ "2210010007/2110120004/2210010005/2110120001/2110110020/" + "2110020001/" // Se a conta for fornecedores nacionais ou despesas a reembolsar... so assim deixar item contabil
			xRet := SA2->A2_ITEMCTA
		
		ElseIf RTrim(CTK->CTK_DEBITO) $ "2110030002" // Fornecedores Intercompany
			xRet := SA2->A2_ITEMCTA
		ElseIf RTrim(CTK->CTK_CREDIT) $ "2110030002" // Fornecedores Intercompany
			xRet := SA2->A2_ITEMCTA
		EndIf
		
	ElseIf cSeq $ "005/" // FOLHA PGTO
		xRet := Space(nTamCTDCod) // Folha nao tem item contabil
	ElseIf cSeq $ "006/" // IMPOSTO
		xRet := Space(nTamCTDCod) // Imposto nao tem item contabil
	ElseIf cSeq $ "007/" // EMPRESTIMOS
		xRet := SA2->A2_ITEMCTA
	ElseIf cSeq $ "009/" // MANUAIS
		xRet := SA2->A2_ITEMCTA
	ElseIf cSeq $ "030/" // Ganho/Perda cambial
		If SE5->E5_VLCORRE < 0 // Ganho Cambial
			xRet := SA2->A2_ITEMCTA
		Else
			xRet := SA2->A2_ITEMCTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR < 0 // Ganho Cambial
				xRet := SA2->A2_ITEMCTA
			Else
				xRet := SA2->A2_ITEMCTA
			EndIf
		EndIf
	EndIf
	xRet := PadR(xRet,nTamCTDCod)
ElseIf cPrc == "ITC" // Item Contabil Credito
	xRet := Space(nTamCTDCod)
	If cSeq $ "001/002/003/004/"
		
		If RTrim(CTK->CTK_DEBITO) $ "2210010007/2110120004/2210010005/2110120001/2110110020/" + "2110020001/"
			xRet := SA2->A2_ITEMCTA
		ElseIf RTrim(CTK->CTK_CREDIT) $ "2210010007/2110120004/2210010005/2110120001/2110110020/" + "2110020001/" // Se a conta for fornecedores nacionais ou despesas a reembolsar... so assim deixar item contabil
			xRet := SA2->A2_ITEMCTA
			
		ElseIf RTrim(CTK->CTK_DEBITO) $ "2110030002" // Fornecedores Intercompany
			xRet := SA2->A2_ITEMCTA
		ElseIf RTrim(CTK->CTK_CREDIT) $ "2110030002" // Fornecedores Intercompany
			xRet := SA2->A2_ITEMCTA
		EndIf
		
	ElseIf cSeq $ "005/" // FOLHA PGTO
		xRet := Space(nTamCTDCod) // Folha nao tem item contabil
	ElseIf cSeq $ "006/" // IMPOSTO
		xRet := Space(nTamCTDCod) // Imposto nao tem item contabil
	ElseIf cSeq $ "006/" // EMPRESTIMOS
		xRet := Space(nTamCTDCod) // Emprestimos nao tem item contabil credito
	ElseIf cSeq $ "009/" // TITULOS MANUAIS
		xRet := Space(nTamCTDCod) // Titulos Manuais nao tem item contabil
	ElseIf cSeq $ "030/" // Ganho/Perda cambial
		If SE5->E5_VLCORRE > 0 // Perda Cambial
			xRet := SA2->A2_ITEMCTA
		Else
			xRet := SA2->A2_ITEMCTA
		EndIf
	ElseIf cSeq >= "031" .And. cSeq <= "042"
		If Select("QRYSE5") > 0 .And. QRYSE5->(!EOF())
			If QRYSE5->E5_VALOR < 0 // Ganho Cambial
				xRet := SA2->A2_ITEMCTA
			Else
				xRet := SA2->A2_ITEMCTA
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSE2)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
ConOut("INTLP530: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Retorno: " + Iif(cPrc == "VLR", cValToChar(xRet), xRet))
ConOut("INTLP530: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LoadsSE5 ºAutor ³ Jonathan Schmidt Alves ºData³ 20/09/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtencao de todos os movimentos SE5 de Variacao Monetaria  º±±
±±º          ³ conforme o titulo posicionado no LanPad para obtencao de   º±±
±±º          ³ todos os valores mensais processados de variacao cambial.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Parametros recebidos:                                      º±±
±±º          ³ cPeriod: Periodo de processamento. Ex: "201909"            º±±
±±º          ³ cRecPag: R=Receber P=Pagar                                 º±±
±±º          ³ dLimite: Data limite processamento (evitar o ultimo SE5).  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Retorno da funcao:                                         º±±
±±º          ³ nVlrSE5: Valor carregado no periodo (positivo ou negativo) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function LoadsSE5(cPeriod, cRecPag, dLimite)
Local nVlrSE5 := 0
Local cQrySE5 := ""
Local nRecsSE5 := 0
Local _cSqlSE5 := RetSqlName("SE5")
Local nFields := At(cRecPag,"RP")
Local aFields := { { "SE1->E1_FILIAL", "SE2->E2_FILIAL" }, { "SE1->E1_PREFIXO", "SE2->E2_PREFIXO" }, { "SE1->E1_NUM", "SE2->E2_NUM" },;
{ "SE1->E1_PARCELA", "SE2->E2_PARCELA" }, { "SE1->E1_TIPO", "SE2->E2_TIPO" }, { "SE1->E1_CLIENTE", "SE2->E2_FORNECE" }, { "SE1->E1_LOJA", "SE2->E2_LOJA" } }
cQrySE5 := "SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_VALOR, E5_MOTBX, E5_ORIGEM "
cQrySE5 += "FROM " + _cSqlSE5 + " WHERE "
cQrySE5 += "E5_FILIAL = '" + &(aFields[01,nFields]) + "' AND "					// Filial conforme
cQrySE5 += "E5_PREFIXO = '" + &(aFields[02,nFields]) + "' AND "					// Prefixo conforme
cQrySE5 += "E5_NUMERO = '" + &(aFields[03,nFields]) + "' AND "					// Numero conforme
cQrySE5 += "E5_PARCELA = '" + &(aFields[04,nFields]) + "' AND "					// Parcela conforme
cQrySE5 += "E5_TIPO = '" + &(aFields[05,nFields]) + "' AND "					// Tipo conforme
cQrySE5 += "E5_CLIFOR = '" + &(aFields[06,nFields]) + "' AND "					// Fornecedor conforme
cQrySE5 += "E5_LOJA = '" + &(aFields[07,nFields]) + "' AND "					// Loja conforme
cQrySE5 += "E5_MOTBX = 'VM ' AND "												// Motivo de baixa
cQrySE5 += "E5_RECPAG = '" + cRecPag + "' AND "									// RecPag conforme
cQrySE5 += "E5_ORIGEM = 'FINA350 ' AND "					  					// Origem FINA350=Variacao Monetaria
cQrySE5 += "E5_DATA >= '" + DtoS(FirstDay(StoD(cPeriod + "01"))) + "' AND "		// Data inicial conforme
cQrySE5 += "E5_DATA <= '" + DtoS(LastDay(StoD(cPeriod + "01"))) + "' AND "		// Data final conforme
cQrySE5 += "E5_DATA < '" + DtoS(dLimite) + "' AND "								// Data limite
cQrySE5 += "D_E_L_E_T_ = ' '"													// Nao apagado
If Select("QRYSE5") > 0
	QRYSE5->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySE5),"QRYSE5",.T.,.F.)
Count To nRecsSE5
If nRecsSE5 > 0 // Registros encontrados (deve encontrar apenas 1 registro mesmo)
	QRYSE5->(DbGotop())
	While QRYSE5->(!EOF())
		nVlrSE5 += QRYSE5->E5_VALOR // Somatorio de valores (do mesmo periodo (porem, a query retorna apenas 1 registro no periodo))
		QRYSE5->(DbSkip())
	End
	QRYSE5->(DbGotop())
Else // Nao achou nada
	QRYSE5->(DbCloseArea())
EndIf
Return nVlrSE5