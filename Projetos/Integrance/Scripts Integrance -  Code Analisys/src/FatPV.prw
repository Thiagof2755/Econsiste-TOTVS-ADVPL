#INCLUDE "TOTVS.CH"
#INCLUDE "PCOTRYEXCEPTION.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ FATPV    ºAutor  ³ Cristiam Rossi     º Data ³  29/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faturamento de PV liberado.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRevisao   ³                Jonathan Schmidt Alves º Data ³  30/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ITUP                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FatPV(cPedido, cDoc, cSerie, cEspecie)
Local lRet := .F.
u_AskYesNo(1200,"Faturando","Preparando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"","","","PROCESSA",.T.,.F.,{|| lRet := FaturaPV(cPedido, cDoc, cSerie, cEspecie) })
Return lRet

Static Function FaturaPV(cPedido, cDoc, cSerie, cEspecie)
Local aAreaAnt := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSE4 := SE4->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aPvlNfs := {}
Local _cNota := ""
Local xParam
Local lMostraCtb
Local lAglutCtb
Local lCtbOnLine
Local lCtbCusto
Local lReajuste
Local nCalAcrs := 1 // Tipo de Acrescimo financeiro
Local nArredPrcLis := 1 // Tipo de arrendondamento
Local lAtuSA7 := .T. // Atualiza Amarracao Cliente x Produto
Local lECF
Local dDataMoe
Default cEspecie := "SPED"
_oMeter:nTotal := 12
Sleep(500)
For _w4 := 1 To 4
	u_AtuAsk09(++nCurrent,"Preparando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"Carregando dados...","",80)
	Sleep(100)
Next
xParam := GetMv("MV_ESPECIE") // Checagem MV_ESPECIE (Série=Espécie NF)
If !(cSerie $ xParam)
	PutMV("MV_ESPECIE", AllTrim(xParam) + Iif(Empty(xParam),"",";") + cSerie + "=" + cEspecie) // Inclui a série na MV_ESPECIE
EndIf
Pergunte("MT460A",.F.)
lMostraCtb	:= Iif(Mv_Par01 == 1,.T.,.F.)
lAglutCtb	:= Iif(Mv_Par02 == 1,.T.,.F.)
lCtbOnLine	:= Iif(Mv_Par03 == 1,.T.,.F.)
lCtbCusto	:= Iif(Mv_Par04 == 1,.T.,.F.)
lReajuste	:= Iif(Mv_Par05 == 1,.T.,.F.)
lECF		:= Iif(Mv_Par16 == 1,.F.,.T.)
dDataMoe	:= Mv_Par21
SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
If SC5->(MsSeek(xFilial("SC5") + cPedido,.F.))
	SC6->(DbSetOrder(1)) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	SC9->(DbSetOrder(1)) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO
	If SC9->(DbSeek(xFilial("SC9") + cPedido))
		While SC9->(!EOF()) .And. SC9->C9_PEDIDO == cPedido
			If !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST != "10"
				RecLock("SC9",.F.)
				SC9->C9_BLEST := ""
				SC9->(MsUnlock())
			EndIf
			If !Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED != "10"
				RecLock("SC9",.F.)
				SC9->C9_BLCRED := ""
				SC9->(MsUnlock())
			EndIf
			If SC6->(DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO))
				SE4->(DbSetOrder(1)) // E4_FILIAL + E4_CODIGO
				SE4->(MsSeek(xFilial("SE4") + SC5->C5_CONDPAG,.F.))
				SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
				SB1->(MsSeek(xFilial("SB1") + SC6->C6_PRODUTO,.F.))
				SB2->(DbSetOrder(1)) // B2_FILIAL + B2_COD + B2_LOCAL
				SB2->(MsSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL,.F.))
				SF4->(DbSetOrder(1)) // F4_FILIAL + F4_CODIGO
				SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES,.F.))
				aAdd(aPvlNfs, { SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_QTDLIB, SC9->C9_PRCVEN, SC9->C9_PRODUTO, .F., SC9->(RecNo()), SC5->(RecNo()), SC6->(RecNo()), SE4->(RecNo()), SB1->(RecNo()), SB2->( RecNo() ), SF4->(RecNo()) })
			EndIf
			SC9->(DbSkip())
		End
	EndIf
EndIf
For _w4 := 1 To 4
	u_AtuAsk09(++nCurrent,"Preparando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"Carregando dados... Concluido!","",80)
	Sleep(100)
Next
If !Empty(aPvlNfs)
	/*
	If SX5->(!DbSeek(xFilial("SX5") + "01" + cSerie))
		RecLock("SX5",.T.)
		SX5->X5_FILIAL	:= xFilial("SX5")
		SX5->X5_TABELA  := "01"
		SX5->X5_CHAVE	:= cSerie
	Else
		RecLock("SX5",.F.)
	EndIf
	SX5->X5_DESCRI  := cDoc
	SX5->X5_DESCSPA := cDoc
	SX5->X5_DESCENG := cDoc
	SX5->(MsUnlock())
	*/
	FwPutSX5(,"01",cSerie, cDoc, cDoc, cDoc)

	For _w4 := 1 To 4
		u_AtuAsk09(++nCurrent,"Gerando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"Processando...","",80,"OK")
		Sleep(050)
	Next
	_cNota := MaPvlNfs(aPvlNfs, cSerie, lMostraCtb, lAglutCtb, lCtbOnLine, lCtbCusto, lReajuste, nCalAcrs, nArredPrcLis, lAtuSA7, lECF,,,,,, dDataMoe)
	If !Empty(aChvInfo[11]) .And. !Empty(_cNota)
		For _w4 := 1 To 4
			u_AtuAsk09(++nCurrent,"Gerando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"Processando... Sucesso!","",80,"OK")
			Sleep(050)
		Next
		RecLock("SF2",.F.)
		SF2->F2_CHVNFE := aChvInfo[11]
		SF2->(MsUnlock())
		SF3->(DbSetOrder(4)) // F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SERIE
		If SF3->(DbSeek(xFilial("SF3") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE))
			RecLock("SF3",.F.)
			SF3->F3_CHVNFE := aChvInfo[11]
			SF3->(MsUnlock())
		EndIf
		SFT->(DbSetOrder(6)) // FT_FILIAL + FT_TIPOMOV + FT_NFISCAL + FT_SERIE
		SFT->(DbSeek(xFilial("SFT") + "S" + SF2->F2_DOC + SF2->F2_SERIE))
		While SFT->(!EOF()) .And. SFT->FT_FILIAL + SFT->FT_TIPOMOV + SFT->FT_NFISCAL + SFT->FT_SERIE == xFilial("SFT") + "S" + SF2->F2_DOC + SF2->F2_SERIE
			RecLock("SFT",.F.)
			SFT->FT_CHVNFE := aChvInfo[11]
			SFT->(MsUnlock())
			SFT->(DbSkip())
		End
	EndIf
	If Empty(_cNota) // Nao foi gerada nota
		For _w4 := 1 To 4
			u_AtuAsk09(++nCurrent,"Gerando a nota fiscal de saida " + cSerie + "/" + cDoc,"Pedido de Venda: " + cPedido,"Processando... Falha!","",80,"UPDERROR")
			Sleep(400)
		Next
	EndIf
EndIf
LibSemX6() // liberacao de Locks na tabela SX6
RestArea(aAreaSF4)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaSE4)
RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAnt)
Return !Empty(_cNota)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LibSemX6  ºAutor  ³Cristiam Rossi      º Data ³  17/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para liberar semaforos presos na tabela SX6         º±±
±±º          ³ a rotina padrao nao solta reclock na tabela SX6 sozinha    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Itup                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LibSemX6()
Local aArea := GetArea()
Local aLockSX6 := SX6->(DbRLockList())
Local nX
For nX := 1 To Len(aLockSX6)
	SX6->(DbGoTo(aLockSX6[nX]))
	SX6->(MsUnLock())
Next
RestArea(aArea)
Return
