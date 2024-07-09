#INCLUDE "PROTHEUS.CH"

// Colunas Excel
// 01: Numero Invoice
// 02: Emissao
// 03: Moeda
// 04: Valor Moeda
// 05: Item Contabil

User Function ImpInvoi()
Local aDado := {}
Local aDados := {}
Private cCodUsr := RetCodUsr()
Private aDadosOk := {}
Private _cFilSE2 := xFilial("SE2")
Private _cFilSA2 := xFilial("SA2")
Private _cFilSED := xFilial("SED")
Private cArqRet := fAbrir() // cArquivo := "C:\TEMP\RETORNOCONCILIA_PAGAMENTO_1443725046558_MOD.CSV" //cArquivo := fAbrir()
If Empty(cArqRet)
	MsgStop("Arquivo nao informado!","ImpInvoi")
	Return
ElseIf !File(cArqRet)
	MsgStop("Arquivo nao encontrado!" + Chr(13) + Chr(10) + ;
	cArqRet,"ImpInvoi")
	Return
Else
	// SplitPath( cArquivo, @cDrive, @cDir, @cFile, @cExten )
EndIf


// PARTE 01: Carregando dados do .CSV
FT_FUse(cArqRet)
FT_FGOTOP()
FT_FSkip() // Pula cabecalho

// PARTE 01: Carregamento dos dados
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + ...
While (!FT_FEOF()) //  .And. Len(aDados) <= 10
	cBuffer := FT_FREADLN()
	While At(";;",cBuffer) > 0
		cBuffer := StrTran(cBuffer,";;"," ; ; ")
	End
	aDado := StrToKarr(cBuffer,";")
	If Len(aDado) == 9 // Sem historico
		aAdd(aDado, "")
	EndIf
	
	// Filial;Num Invoice;Emissao;Moeda;Valor Moeda;TaxaMoeda;Item Contabil
	aAdd(aDados, aClone(aDado)) // Carrego toda a linha em matriz
	
	FT_FSkip() // Pula cabecalho
End
FT_FUse()

// PARTE 02: Preparacao
For w := 1 To Len(aDados)
	cFilial := aDados[w,01]				// Filial
	cPrefix := aDados[w,02] // "INJ"	// Prefixo
	cNumInv := PadR(aDados[w,03],09)	// Numero invoice
	dEmissa := CtoD(aDados[w,04])		// Data de emissao
	If Empty(dEmissa) // Data invalida
		MsgStop("Data nao identificada (falha na conversao)!" + Chr(13) + Chr(10) + ;
		"Data: " + aDados[w,04],"ImpInvoi")
		Return
	EndIf
	If "EUR" $ Upper(aDados[w,05])		// Euros
		nMoeda	:= 4
	ElseIf "DOL" $ Upper(aDados[w,05])	// Dolares
		nMoeda	:= 2
	ElseIf "USD" $ Upper(aDados[w,05])	// Dolares
		nMoeda	:= 2
	Else
		MsgStop("Moeda nao identificada!","ImpInvoi")
		Return
	EndIf
	nVlrInv := Val(StrTran(StrTran(StrTran(StrTran(aDados[w,06],".",""),",","."),"R$",""),"�",""))	// Valor
	cIteCtb := PadR(AllTrim(aDados[w,08]),09)						// Item contabil
	cNature := PadR(aDados[w,09],10)								// Natureza
	cTipInv := "INJ"												// Tipo
	dVencim := CtoD("31/12/2019")									// Vencimento
	cHistor := AllTrim(aDados[w,10])								// Historico
	nTaxMoe := 0
	If SM2->(DbSeek("20190628")) // Obtencao da taxa moeda
		nTaxMoe := &("SM2->M2_MOEDA" + cValToChar(nMoeda)) // Taxa do SM2
	EndIf
	
	If cFilial <> cFilAnt
		MsgStop("Filial do titulo nao confere com a filial logada!" + Chr(13) + Chr(10) + ;
		"Filial do titulo: " + cFilial,"ImpInvoi")
		Return
	EndIf
	
	If Len(RTrim(aDados[w,03])) > 9 // Numero maior que 9
		MsgStop("Numero do titulo ultrapassa o tamanho maximo!" + Chr(13) + Chr(10) + ;
		"Numero: " + aDados[w,03],"ImpInvoi")
		Return
	EndIf
	
	If nTaxMoe == 0 // Taxa nao obtida
		MsgStop("Taxa da Moeda nao identificada!")
		Return
	EndIf
	_cSqlSA2 := RetSqlName("SA2")
	cQrySA2 := "SELECT A2_COD, A2_LOJA, A2_ITEMCTA "
	cQrySA2 += "FROM " + _cSqlSA2 + " WHERE "
	cQrySA2 += "A2_FILIAL = '" + _cFilSA2 + "' AND "		// Filial conforme
	cQrySA2 += "A2_ITEMCTA = '" + cIteCtb + "' AND "		// Item contabil conforme
	cQrySA2 += "D_E_L_E_T_ = ' '"							// Nao apagado
	If Select("QRYSA2") > 0
		QRYSA2->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA2),"QRYSA2",.T.,.F.)
	Count To nRecsSA2
	If nRecsSA2 == 1 // Registro encontrado
		QRYSA2->(DbGotop())
		DbSelectArea("SED")
		SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
		If SED->(DbSeek(_cFilSED + cNature)) // {      01,      02,      03,     04,      05,      06,      07,             08,              09,      10,      11,      12,      13 }
			aAdd(aDadosOk,                      { cPrefix, cNumInv, dEmissa, nMoeda, nVlrInv, cIteCtb, cNature, QRYSA2->A2_COD, QRYSA2->A2_LOJA, cTipInv, dVencim, cHistor, nTaxMoe })
		Else // Natureza nao encontrada
			MsgStop("Natureza nao encontrada no cadastro (SED)!" + Chr(13) + Chr(10) + ;
			"Natureza: " + cNature,"ImpInvoi")
			Return
		EndIf
	Else // Falha na localizacao do Fornecedor pelo Item Contabil
		MsgStop("Foram encontrados " + cValToChar(nRecsSA2) + " fornecedores para o" + Chr(13) + Chr(10) + ;
		"Item Contabil informado: " + cIteCtb + Chr(13) + Chr(10) + ;
		"A importacao nao pode prosseguir!","ImpInvoi")
		Return
	EndIf
	
Next

// PARTE 03: Processamento
If Len(aDadosOk) > 0
	If MsgYesNo("Confirma processamento de " + cValToChar(Len(aDadosOk)) + " registros?")
		For w := 1 To Len(aDadosOk)
			ExeAutE2(aDadosOk[w])
		Next
	EndIf
EndIf
Return

Static Function ExeAutE2(aTitul)
Local aTit := {}
DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
If SA2->(DbSeek(_cFilSA2 + aTitul[08] + aTitul[09]))
	//ConOut("ExeAutE2: " + DtoC(Date()) + " " + Time() + " " + cCodUsr + " " + cUserName + " Preparando variaveis para o ExecAuto FINA050...")
	U_LogAlteracoes("ExeAutE2" , " Preparando variaveis para o ExecAuto FINA050..." )
	//ConOut("ExeAutE2: " + DtoC(Date()) + " " + Time() + " " + cCodUsr + " " + cUserName + " Gerando Titulo a Pagar...","Prefixo/Numero: " + aTitul[01] + "/ " + aTitul[02], "Carregando dados...", "Valor: R$ " + TransForm(aTitul[05],"@E 999,999.99"))
	U_LogAlteracoes("ExeAutE2" , " Gerando Titulo a Pagar..." )
	U_LogAlteracoes("ExeAutE2" , "Prefixo/Numero: " + aTitul[01] + "/ " + aTitul[02] )
	U_LogAlteracoes("ExeAutE2" , "Carregando dados..." )
	U_LogAlteracoes("ExeAutE2" , "Valor: R$ " + TransForm(aTitul[05],"@E 999,999.99") )
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
	aAdd(aTit, { "E2_PREFIXO",		aTitul[01],								Nil })		// Prefixo do titulo
	aAdd(aTit, { "E2_NUM",			aTitul[02],								Nil })		// Numero do titulo
	aAdd(aTit, { "E2_PARCELA",		Space(02),								Nil })		// Parcela do titulo
	aAdd(aTit, { "E2_TIPO",			aTitul[10],								Nil })		// Tipo do titulo
	aAdd(aTit, { "E2_NATUREZ",		aTitul[07],								Nil })		// Natureza do titulo
	aAdd(aTit, { "E2_FORNECE",		aTitul[08],								Nil })		// Fornecedor
	aAdd(aTit, { "E2_LOJA",			aTitul[09],								Nil })		// Loja
	aAdd(aTit, { "E2_EMISSAO",		aTitul[03],								Nil })		// Data de Emissao
	aAdd(aTit, { "E2_MOEDA",		aTitul[04],								Nil })		// Moeda do Titulo
	aAdd(aTit, { "E2_VALOR",		aTitul[05],								Nil })		// Valor Total do Titulo
	aAdd(aTit, { "E2_VENCTO",		aTitul[11],								Nil })		// Vencimento
	aAdd(aTit, { "E2_HIST",			aTitul[12],								Nil })		// Historico
	aAdd(aTit, { "E2_TXMOEDA",		aTitul[13],								Nil })		// Moeda do Titulo
	
	lMsErroAuto := .F.
	lExibeLanc := .F.
	lOnline := .F.
	MsExecAuto({|a,b,c,d,e,f,g|, FINA050(a,b,c,d,e,f,g)}, aTit,,3,, /*aDadosBco*/ Nil, lExibeLanc, lOnline)
	If lMsErroAuto .Or. SE2->E2_NUM <> aTitul[02] // Falha
		//ConOut("ExeAutE2: " + DtoC(Date()) + " " + Time() + " " + cCodUsr + " " + cUserName + " Chamando ExecAuto FINA050... Falha!")
		U_LogAlteracoes("ExeAutE2" , " Chamando ExecAuto FINA050... Falha!" )
		MostraErro()
	Else // Marca como contabilizado
		RecLock("SE2",.F.)
		SE2->E2_LA := "S" // Marca como contabilizado
		SE2->(MsUnlock())
	EndIf
EndIf
Return

User Function MTXMOEDA()
cTst := ""
Return

Static Function fAbrir()
Local cType := "Arquivo | *.*|"
Local cArq := ""
cArq := cGetFile(cType, OemToAnsi("Selecione o arquivo para importar"),0,,.T.,GETF_LOCALHARD + GETF_LOCALFLOPPY)
If Empty(cArq)
	cArqRet := ""
Else
	cArqRet := cArq
EndIf
Return cArqRet
















/*���������������������������������������������������������������������������
���Programa  � ItensSA1 �Autor � Jonathan Schmidt Alves �Data� 11/07/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Reestrutura do item contabil para Clientes.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function ItensSA1()
Local lAjustado := .F.
Private nCntSA1 := 0 // CTD sem SA1 encontrado
Private nCntMlt := 0 // CTD com mais de 1 SA1 encontrado
Private nCntDif := 0
Private nCntIgu := 0 // SA1 igual encontrado conforme o CTD
Private nCntA1E := 0 // SA1 cadastrado com COD + LOJA incorreto
Private nCntCor := 0 // Absolutamente Corretos
Private nCntQsa := 0 // Quase corretos (so faltou a loja)
Private nCntDiv := 0 // Divergentes
Private _cFilCT2 := xFilial("CT2")
Private _cFilCTD := xFilial("CTD")
Private _cFilSA1 := xFilial("SA1")
Private _cSqlSA1 := RetSqlName("SA1")
Private _cSqlCT2 := RetSqlName("CT2")
Private aItens := {}
If !MsgYesNo("ItensSA1 20/11/2019 15:09 hrs","Processar")
	Return
EndIf
//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("ItemRepr" , "Iniciando..." )
DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
DbSelectArea("CTD")
CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
DbSelectArea("CT2")
CT2->(DbSetOrder(1)) // CT2_FILIAL + DtoS(CT2_DATA) + ...
CT2->(DbSeek(_cFilCT2)) // Apenas da filial
While CT2->(!EOF()) .And. CT2->CT2_FILIAL == _cFilCT2
	lAjustado := .F.
	If !Empty(CT2->CT2_ITEMD) .Or. !Empty(CT2->CT2_ITEMC) .And. CT2->CT2_DC $ "3/1/2/" // Item contabil
		If !Empty(CT2->CT2_ITEMD)
			If ASCan(aItens, {|x|, x == CT2->CT2_ITEMD }) == 0 // Se ainda nao foi considerado esse Item Contabil
				If CTD->(DbSeek(_cFilCTD + CT2->CT2_ITEMD))
					If Left(CTD->CTD_ITEM,1) == "C" // Cliente
						lAjustado := ChkReSA1()
					EndIf
				Else
					//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil Debito nao encontrado (CTD): " + CT2->CT2_ITEMD)
					U_LogAlteracoes("ItemRepr" , "Item Contabil Debito nao encontrado (CTD): " + CT2->CT2_ITEMD )
				EndIf
			EndIf
		EndIf
		If !Empty(CT2->CT2_ITEMC)
			If ASCan(aItens, {|x|, x == CT2->CT2_ITEMC }) == 0 // Se ainda nao foi considerado esse Item Contabil
				If CTD->(DbSeek(_cFilCTD + CT2->CT2_ITEMC))
					If Left(CTD->CTD_ITEM,1) == "C" // Cliente
						lAjustado := ChkReSA1()
					EndIf
				Else
					//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil Credit nao encontrado (CTD): " + CT2->CT2_ITEMC)
					U_LogAlteracoes("ItemRepr" , "Item Contabil Credit nao encontrado (CTD): " + CT2->CT2_ITEMC )
				EndIf
			EndIf
		EndIf
		If .F. // lAjustado .And. !MsgYesNo("Continuar?") // Se houve ajuste, pergunto se continua
			Exit
		EndIf
	EndIf
	CT2->(DbSkip())
End
//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("ItemRepr" , "Concluido!" )
MsgInfo("Concluido!")
Return

Static Function ChkReSA1()
Local lProc := .F.
// Ok para processamento (CTD localizado)
nFind := SA1ItFnd(CTD->CTD_ITEM) // Amarracao do CTD com o SA1
aAreaSA1 := SA1->(GetArea())
aAreaCTD := CTD->(GetArea())
If nFind == 0 // Nao encontrado
	//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil nao encontrado (SA1): " + CTD->CTD_ITEM)
	U_LogAlteracoes("ItemRepr" , "Item Contabil nao encontrado (SA1): " + CTD->CTD_ITEM )
	// Solucao:
	If MsgYesNo("Cliente: " + "Nao encontrado! (criar agora)!" + Chr(13) + Chr(10) + ;
		"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
		"Item Contabil com cliente nao encontrado (SA1)!" + Chr(13) + Chr(10) + ;
		"NewCdSA1, BlqCdCTD, NewItSA1, LinkCdSA1(), AtuMvCT1! Processa?")
		NewCdSA1() // 01: Criar fornecedor SA1 novo conforme o CTD posicionado											*** NewCdSA1() *** Ok
		BlqCdCTD() // 02: Bloqueio o CTD em questao																		*** BlqCdCTD() *** Ok
		NewItSA1() // NewCdCTD() // 03: Criar novo CTD em questao para o novo SA1 criado conforme "C" + SA1->A1_COD + SA1->A1_LOJA	*** NewCdCTD() *** Ok
		LnkCdSA1() // 04: Amarrar o CTD com o codigo novo no SA1->A1_ITEMCTA											*** LnkCdSA1() *** Ok
		AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil			*** AtuMvCT2(CTD->CTD_ITEM)
		lProc := .T.
	EndIf
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntSA1++
	EndIf
ElseIf nFind > 1 // Mais de 1 vez
	//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil encontrado mais de uma vez (SA1): " + CTD->CTD_ITEM)
	U_LogAlteracoes("ItemRepr" , "Item Contabil encontrado mais de uma vez (SA1): " + CTD->CTD_ITEM )
	MsgStop("Equipe precisa eliminar a amarracao incorreta, " + Chr(13) + Chr(10) + ;
	"manter apenas 1 amarracao) -> Essa situacao nao mais ocorrera" + Chr(13) + Chr(10) + ;
	"apos correcoes dos cadastros (Integrance)" + Chr(13) + Chr(10) + ;
	"Item Contabil: " + CTD->CTD_ITEM,"ChkReSA1")
	// Solucao: (equipe precisa eliminar a amarracao incorreta, manter apenas 1 amarracao) -> Essa situacao nao mais ocorrera apos correcoes dos cadastros (Integrance)
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntMlt++
	EndIf
ElseIf SA1->A1_ITEMCTA <> CTD->CTD_ITEM // CTD conforme e SA1 amarrado... mas estao diferentes
	// Solucao:
	// Nao identificamos nenhuma ocorrencia
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntDif++
	EndIf
Else // Estao iguais.. vamos ver se batem "C" + SA1->A1_COD + SA1->A1_LOJA com CTD_ITEM
	nCntIgu++
	If Len(AllTrim(SA1->A1_COD)) == 06 .And. Len(AllTrim(SA1->A1_LOJA)) == 2 // Tamanho Cod + Loja clientes corretos...
		If CTD->CTD_ITEM == "C" + SA1->A1_COD + SA1->A1_LOJA // Exatamente igual (correto)
			// MsgInfo("Ja estao corretos!","ChkReSA1")
			// Solucao:
			// Ja esta correto (nenhuma ocorrencia)
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntCor++
			EndIf
		ElseIf CTD->CTD_ITEM == PadR("C" + SA1->A1_COD,9) // Quase correto, faltou so a loja
			// Solucao:
			If MsgYesNo("Cliente: " + SA1->A1_COD + "/" + SA1->A1_LOJA + " " + RTrim(SA1->A1_NREDUZ) + Chr(13) + Chr(10) + ;
				"Cliente Razao Social: " + RTrim(SA1->A1_NOME) + Chr(13) + Chr(10) + ;
				"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
				"Quase correto, faltou loja!" + Chr(13) + Chr(10) + ;
				"BlqCdCTD, NewItSA1, LinkCdSA1(), AtuMvCT1! Processa?")
				BlqCdCTD() // 01: Bloqueio o CTD em questao																						*** BlqCdCTD() *** Ok
				NewItSA1() // 02: Criar novo CTD para o SA1 posicionado conforme "C" + SA1->A1_COD + SA1->A1_LOJA								*** NewCdCTD() *** Ok
				LnkCdSA1() // 03: Amarrar no SA1 posicionado com o CTD posicionado (novo) no campo SA1->A1_ITEMCTA								*** LnkCdSA1() *** Ok
				AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil							*** AtuMvCT2(CTD->CTD_ITEM)
				lProc := .T.
			EndIf
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntQsa++
			EndIf
		Else // Totalmente diferente.. reconstruir
			// Solucao:
			If MsgYesNo("Cliente: " + SA1->A1_COD + "/" + SA1->A1_LOJA + " " + RTrim(SA1->A1_NREDUZ) + Chr(13) + Chr(10) + ;
				"Cliente Razao Social: " + RTrim(SA1->A1_NOME) + Chr(13) + Chr(10) + ;
				"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
				"Totalmente diferente!" + Chr(13) + Chr(10) + ;
				"BlqCdCTD, NewItSA1, LinkCdSA1(), AtuMvCT1! Processa?")
				BlqCdCTD() // 01: Bloqueio o CTD em questao																						*** BlqCdCTD() *** Ok
				NewItSA1() // 02: Criar novo CTD para o SA1 posicionado criado conforme "C" + SA1->A1_COD + SA1->A1_LOJA						*** NewCdCTD() *** Ok
				LnkCdSA1() // 03: Amarrar no SA1 posicionado com o CTD posicionado (novo) no campo SA1->A1_ITEMCTA								*** LnkCdSA1() *** Ok
				AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil							*** AtuMvCT2(CTD->CTD_ITEM)
				lProc := .T.
			EndIf
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntDiv++
			EndIf
		EndIf
	Else // SA1 incorreto (COD + LOJA)
		// MsgStop("SA1 incorreto! (poucas situacoes)!","ChkReSA1")
		nCntA1E++
	EndIf
EndIf
Return lProc // .T.=Algum processamento .F.=Nenhum processamento

Static Function SA1ItFnd(cItemCta) // Procusa SA1 pelo Item Contabil
Local cQrySA1 := ""
Local lFound := .F.
cQrySA1 := "SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME "
cQrySA1 += "FROM " + _cSqlSA1 + " WHERE "
cQrySA1 += "A1_FILIAL = '" + _cFilSA1 + "' AND "		// Filial conforme
cQrySA1 += "A1_ITEMCTA = '" + cItemCta + "' AND "		// Item contabil conforme
cQrySA1 += "D_E_L_E_T_ = ' '"
If Select("QRYSA1") > 0
	QRYSA1->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA1),"QRYSA1",.T.,.F.)
Count To nRecsSA1
If nRecsSA1 > 0 // Registro encontrado
	QRYSA1->(DbGotop())
	SA1->(DbSeek(QRYSA1->A1_FILIAL + QRYSA1->A1_COD + QRYSA1->A1_LOJA))
EndIf
QRYSA1->(DbCloseArea())
Return nRecsSA1 // .T.=Registro unico localizado

Static Function NewCdSA1() // Cria no SA1 conforme CTD posicionado
Local cNextSA1 := Space(06)
cNextSA1 := GetSXENum("SA1")
DbSelectArea("SA1")
SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
While SA1->(DbSeek(_cFilSA1 + cNextSA1))
	ConfirmSX8()
	cNextSA1 := GetSXENum("SA1")
End
RecLock("SA1",.T.)
SA1->A1_FILIAL := _cFilSA1
SA1->A1_COD := cNextSA1
SA1->A1_LOJA := "01"
SA1->A1_NOME := CTD->CTD_DESC01
SA1->A1_NREDUZ := CTD->CTD_DESC01
SA1->(MsUnlock())
ConfirmSX8()
Return

Static Function BlqCdCTD() // Bloqueio o CTD (usado no SA1 e no SA2)
RecLock("CTD",.F.)
CTD->CTD_BLOQ := "1"
CTD->(MsUnlock())
Return

Static Function NewItSA1() // Novo CTD conforme SA1 posicionado
RecLock("CTD",.T.)
CTD->CTD_FILIAL := _cFilCTD
CTD->CTD_ITEM := "C" + SA1->A1_COD + SA1->A1_LOJA
CTD->CTD_DESC01 := SA1->A1_NOME
CTD->CTD_CLASSE := "2"
CTD->CTD_NORMAL := "1"
CTD->CTD_BLOQ := "2"
CTD->CTD_CLOBRG := "2"
CTD->CTD_ACCLVL := "1"
CTD->(MsUnlock())
Return

Static Function LnkCdSA1() // Link do CTD posicionado no SA1 posicionado
RecLock("SA1",.F.)
SA1->A1_OBSERV := SA1->A1_ITEMCTA	// Deixo o item antigo aqui (Backup)
SA1->A1_ITEMCTA := CTD->CTD_ITEM
SA1->(MsUnlock())
Return

Static Function AtuMvCT2(cCTDNew) // Atualizo todo o CT2 (Funcao usada no SA1 e no SA2)
Local cQryCT2 := ""
Local nRecsCT2 := 0
Local aAreaCT2 := CT2->(GetArea())
RestArea(aAreaCTD) // Retorno para o Item Contabil antigo (para localziar no CT2 tudo q vai mudar)
cQryCT2 := "SELECT CT2_ITEMD, CT2_ITEMC, R_E_C_N_O_ "
cQryCT2 += "FROM " + _cSqlCT2 + " WHERE "
cQryCT2 += "CT2_FILIAL = '" + _cFilCT2 + "' AND "			// Filial conforme
cQryCT2 += "(CT2_ITEMD = '" + CTD->CTD_ITEM + "' OR "		// Item Credito conforme
cQryCT2 += "CT2_ITEMC = '" + CTD->CTD_ITEM + "') AND "		// Item Debito conforme
cQryCT2 += "D_E_L_E_T_ = ' '"								// Nao apagados
If Select("QRYCT2") > 0
	QRYCT2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),"QRYCT2",.T.,.F.)
Count To nRecsCT2
If nRecsCT2 > 0 // Registros encontrados CT2
	QRYCT2->(DbGotop())
	While QRYCT2->(!EOF())
		CT2->(DbGoto( QRYCT2->R_E_C_N_O_ ))
		RecLock("CT2",.F.)
		If CT2->CT2_ITEMD == CTD->CTD_ITEM
			CT2->CT2_OBSCNF := "Deb: " + CT2->CT2_ITEMD // Backup do Deb Antigo
			CT2->CT2_ITEMD := cCTDNew // Novo item contabil
		EndIf
		If CT2->CT2_ITEMC == CTD->CTD_ITEM
			CT2->CT2_OBSCNF := RTrim(CT2->CT2_OBSCNF) + " Crd: " + CT2->CT2_ITEMC // Backup do Crd Antigo
			CT2->CT2_ITEMC := cCTDNew // Novo item contabil
		EndIf
		CT2->(MsUnlock())
		QRYCT2->(DbSkip())
	End
EndIf
QRYCT2->(DbCloseArea())
RestArea(aAreaCT2)
Return




/*���������������������������������������������������������������������������
���Programa  � ItensSA2 �Autor � Jonathan Schmidt Alves �Data� 11/07/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Reestrutura do item contabil para Fornecedores.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function ItensSA2()
Local lAjustado := .F.
Private nCntSA2 := 0 // CTD sem SA2 encontrado
Private nCntMlt := 0 // CTD com mais de 1 SA2 encontrado
Private nCntDif := 0
Private nCntIgu := 0 // SA2 igual encontrado conforme o CTD
Private nCntA2E := 0 // SA2 cadastrado com COD + LOJA incorreto
Private nCntCor := 0 // Absolutamente Corretos
Private nCntQsa := 0 // Quase corretos (so faltou a loja)
Private nCntDiv := 0 // Divergentes
Private _cFilCT2 := xFilial("CT2")
Private _cFilCTD := xFilial("CTD")
Private _cFilSA2 := xFilial("SA2")
Private _cSqlSA2 := RetSqlName("SA2")
Private _cSqlCT2 := RetSqlName("CT2")
Private aItens := {}
If !MsgYesNo("ItensSA2: 20/11/2019 14:46 hrs","Processar")
	Return
EndIf
//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("ItemRepr" , "Iniciando..." )
DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
DbSelectArea("CTD")
CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
DbSelectArea("CT2")
CT2->(DbSetOrder(1)) // CT2_FILIAL + DtoS(CT2_DATA) + ...
CT2->(DbSeek(_cFilCT2)) // Apenas da filial
While CT2->(!EOF()) .And. CT2->CT2_FILIAL == _cFilCT2
	lAjustado := .F.
	If !Empty(CT2->CT2_ITEMD) .Or. !Empty(CT2->CT2_ITEMC) .And. CT2->CT2_DC $ "3/1/2/" // Item contabil
		If !Empty(CT2->CT2_ITEMD)
			If ASCan(aItens, {|x|, x == CT2->CT2_ITEMD }) == 0 // Se ainda nao foi considerado esse Item Contabil
				If CTD->(DbSeek(_cFilCTD + CT2->CT2_ITEMD))
					If Left(CTD->CTD_ITEM,1) == "F" // Cliente
						lAjustado := ChkReSA2()
					EndIf
				Else
					//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil Debito nao encontrado (CTD): " + CT2->CT2_ITEMD)
					U_LogAlteracoes("ItemRepr" , "Item Contabil Debito nao encontrado (CTD): " + CT2->CT2_ITEMD )
				EndIf
			EndIf
		EndIf
		If !Empty(CT2->CT2_ITEMC)
			If ASCan(aItens, {|x|, x == CT2->CT2_ITEMC }) == 0 // Se ainda nao foi considerado esse Item Contabil
				If CTD->(DbSeek(_cFilCTD + CT2->CT2_ITEMC))
					If Left(CTD->CTD_ITEM,1) == "F" // Cliente
						lAjustado := ChkReSA2()
					EndIf
				Else
					//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil Credit nao encontrado (CTD): " + CT2->CT2_ITEMC)
					U_LogAlteracoes("ItemRepr" , "Item Contabil Credit nao encontrado (CTD): " + CT2->CT2_ITEMC )
				EndIf
			EndIf
		EndIf
		If .F. // lAjustado .And. !MsgYesNo("Continuar?") // Se houve ajuste, pergunto se continua
			Exit
		EndIf
	EndIf
	CT2->(DbSkip())
End
//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("ItemRepr" , "Concluido!" )
MsgInfo("Concluido!")
Return

Static Function ChkReSA2()
Local lProc := .F.
// Ok para processamento (CTD localizado)
nFind := SA2ItFnd(CTD->CTD_ITEM) // Amarracao do CTD com o SA2
aAreaSA2 := SA2->(GetArea())
aAreaCTD := CTD->(GetArea())
If nFind == 0 // Nao encontrado
	//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil nao encontrado (SA2): " + CTD->CTD_ITEM)
	U_LogAlteracoes("ItemRepr" , "Item Contabil nao encontrado (SA2): " + CTD->CTD_ITEM )
	// Solucao:
	If MsgYesNo("Fornecedor: " + "Nao encontrado! (criar agora)!" + Chr(13) + Chr(10) + ;
		"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
		"Item Contabil com fornecedor nao encontrado (SA2)!" + Chr(13) + Chr(10) + ;
		"NewCdSA2, BlqCdCTD, NewItSA2, LinkCdSA2(), AtuMvCT2! Processa?")
		NewCdSA2() // 01: Criar fornecedor SA2 novo conforme o CTD posicionado											*** NewCdSA2() *** Ok
		BlqCdCTD() // 02: Bloqueio o CTD em questao																		*** BlqCdCTD() *** Ok
		NewItSA2() // 03: Criar novo CTD em questao para o novo SA2 criado conforme "F" + SA2->A2_COD + SA2->A2_LOJA	*** NewCdCTD() *** Ok
		LnkCdSA2() // 04: Amarrar o CTD com o codigo novo no SA2->A2_ITEMCTA											*** LnkCdSA2() *** Ok
		AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil			*** AtuMvCT2(CTD->CTD_ITEM)
		lProc := .T.
	EndIf
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntSA2++
	EndIf
ElseIf nFind > 1 // Mais de 1 vez
	//ConOut("ItemRepr: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Item Contabil encontrado mais de uma vez (SA2): " + CTD->CTD_ITEM)
	U_LogAlteracoes("ItemRepr" , "Item Contabil encontrado mais de uma vez (SA2): " + CTD->CTD_ITEM )
	MsgStop("Equipe precisa eliminar a amarracao incorreta, " + Chr(13) + Chr(10) + ;
	"manter apenas 1 amarracao) -> Essa situacao nao mais ocorrera" + Chr(13) + Chr(10) + ;
	"apos correcoes dos cadastros (Integrance)" + Chr(13) + Chr(10) + ;
	"Item Contabil: " + CTD->CTD_ITEM,"ChkReSA2")
	// Solucao: (equipe precisa eliminar a amarracao incorreta, manter apenas 1 amarracao) -> Essa situacao nao mais ocorrera apos correcoes dos cadastros (Integrance)
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntMlt++
	EndIf
ElseIf SA2->A2_ITEMCTA <> CTD->CTD_ITEM // CTD conforme e SA2 amarrado... mas estao diferentes
	// Solucao:
	// Nao identificamos nenhuma ocorrencia
	If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
		aAdd(aItens, CTD->CTD_ITEM)
		nCntDif++
	EndIf
Else // Estao iguais.. vamos ver se batem "F" + SA2->A2_COD + SA2->A2_LOJA com CTD_ITEM
	nCntIgu++
	If Len(AllTrim(SA2->A2_COD)) == 06 .And. Len(AllTrim(SA2->A2_LOJA)) == 2 // Tamanho Cod + Loja fornecedores corretos...
		If CTD->CTD_ITEM == "F" + SA2->A2_COD + SA2->A2_LOJA // Exatamente igual (correto)
			// MsgInfo("Ja estao corretos!","ChkReSA2")
			// Solucao:
			// Ja esta correto (nenhuma ocorrencia)
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntCor++
			EndIf
		ElseIf CTD->CTD_ITEM == PadR("F" + SA2->A2_COD,9) // Quase correto, faltou so a loja
			// Solucao:
			If MsgYesNo("Fornecedor: " + SA2->A2_COD + "/" + SA2->A2_LOJA + " " + RTrim(SA2->A2_NREDUZ) + Chr(13) + Chr(10) + ;
				"Fornecedor Razao Social: " + RTrim(SA2->A2_NOME) + Chr(13) + Chr(10) + ;
				"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
				"Quase correto, faltou loja!" + Chr(13) + Chr(10) + ;
				"BlqCdCTD, NewItSA2, LinkCdSA2(), AtuMvCT2! Processa?")
				BlqCdCTD() // 01: Bloqueio o CTD em questao																						*** BlqCdCTD() *** Ok
				NewItSA2() // 02: Criar novo CTD para o SA2 posicionado conforme "F" + SA2->A2_COD + SA2->A2_LOJA								*** NewCdCTD() *** Ok
				LnkCdSA2() // 03: Amarrar no SA2 posicionado com o CTD posicionado (novo) no campo SA2->A2_ITEMCTA								*** LnkCdSA2() *** Ok
				AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil							*** AtuMvCT2(CTD->CTD_ITEM)
				lProc := .T.
			EndIf
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntQsa++
			EndIf
		Else // Totalmente diferente.. reconstruir
			// Solucao:
			If MsgYesNo("Fornecedor: " + SA2->A2_COD + "/" + SA2->A2_LOJA + " " + RTrim(SA2->A2_NREDUZ) + Chr(13) + Chr(10) + ;
				"Fornecedor Razao Social: " + RTrim(SA2->A2_NOME) + Chr(13) + Chr(10) + ;
				"ItemCtb: " + CTD->CTD_ITEM + " " + RTrim(CTD->CTD_DESC01) + Chr(13) + Chr(10) + ;
				"Totalmente diferente!" + Chr(13) + Chr(10) + ;
				"BlqCdCTD, NewItSA2, LinkCdSA2(), AtuMvCT2! Processa?")
				BlqCdCTD() // 01: Bloqueio o CTD em questao																						*** BlqCdCTD() *** Ok
				NewItSA2() // 02: Criar novo CTD para o SA2 posicionado criado conforme "F" + SA2->A2_COD + SA2->A2_LOJA						*** NewCdCTD() *** Ok
				LnkCdSA2() // 03: Amarrar no SA2 posicionado com o CTD posicionado (novo) no campo SA2->A2_ITEMCTA								*** LnkCdSA2() *** Ok
				AtuMvCT2(CTD->CTD_ITEM) // 04: Atualizar todo o CT2 com essa item contabil para o novo item contabil							*** AtuMvCT2(CTD->CTD_ITEM)
				lProc := .T.
			EndIf
			If ASCan(aItens, {|x|, x == CTD->CTD_ITEM }) == 0 // Se ainda nao foi considerado
				aAdd(aItens, CTD->CTD_ITEM)
				nCntDiv++
			EndIf
		EndIf
	Else // SA2 incorreto (COD + LOJA)
		// MsgStop("SA2 incorreto! (poucas situacoes)!","ChkReSA2")
		nCntA2E++
	EndIf
EndIf
Return lProc // .T.=Algum processamento .F.=Nenhum processamento

Static Function SA2ItFnd(cItemCta) // Procusa SA2 pelo Item Contabil
Local cQrySA2 := ""
Local lFound := .F.
cQrySA2 := "SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME "
cQrySA2 += "FROM " + _cSqlSA2 + " WHERE "
cQrySA2 += "A2_FILIAL = '" + _cFilSA2 + "' AND "		// Filial conforme
cQrySA2 += "A2_ITEMCTA = '" + cItemCta + "' AND "		// Item contabil conforme
cQrySA2 += "D_E_L_E_T_ = ' '"
If Select("QRYSA2") > 0
	QRYSA2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA2),"QRYSA2",.T.,.F.)
Count To nRecsSA2
If nRecsSA2 > 0 // Registro encontrado
	QRYSA2->(DbGotop())
	SA2->(DbSeek(QRYSA2->A2_FILIAL + QRYSA2->A2_COD + QRYSA2->A2_LOJA))
EndIf
QRYSA2->(DbCloseArea())
Return nRecsSA2 // .T.=Registro unico localizado

Static Function NewCdSA2() // Cria no SA2 conforme CTD posicionado
Local cNextSA2 := Space(06)
cNextSA2 := GetSXENum("SA2")
DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
While SA2->(DbSeek(_cFilSA2 + cNextSA2))
	ConfirmSX8()
	cNextSA2 := GetSXENum("SA2")
End
RecLock("SA2",.T.)
SA2->A2_FILIAL := _cFilSA2
SA2->A2_COD := cNextSA2
SA2->A2_LOJA := "01"
SA2->A2_NOME := CTD->CTD_DESC01
SA2->A2_NREDUZ := CTD->CTD_DESC01
SA2->(MsUnlock())
ConfirmSX8()
Return

Static Function LnkCdSA2() // Link do CTD posicionado no SA2 posicionado
RecLock("SA2",.F.)
SA2->A2_DEPTO := SA2->A2_ITEMCTA	// Deixo o item antigo aqui (Backup)
SA2->A2_ITEMCTA := CTD->CTD_ITEM
SA2->(MsUnlock())
Return

Static Function NewItSA2() // Novo CTD conforme SA2 posicionado
RecLock("CTD",.T.)
CTD->CTD_FILIAL := _cFilCTD
CTD->CTD_ITEM := "F" + SA2->A2_COD + SA2->A2_LOJA
CTD->CTD_DESC01 := SA2->A2_NOME
CTD->CTD_CLASSE := "2"
CTD->CTD_NORMAL := "1"
CTD->CTD_BLOQ := "2"
CTD->CTD_CLOBRG := "2"
CTD->CTD_ACCLVL := "1"
CTD->(MsUnlock())
Return

Static Function CheckSA2()
cQrySA2 := "SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME, R_E_C_N_O_ "
cQrySA2 += "FROM " + _cSqlSA2 + " WHERE "
cQrySA2 += "A2_FILIAL = '" + PadR(Left(CTD->CTD_FILIAL,2),4) + "' AND "		// Filial conforme
cQrySA2 += "A2_ITEMCTA = '" + CTD->CTD_ITEM + "' AND "		// Item contabil conforme
cQrySA2 += "D_E_L_E_T_ = ' '"
If Select("QRYSA2") > 0
	QRYSA2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA2),"QRYSA2",.T.,.F.)
Count To nRecsSA2
If nRecsSA2 == 1
	QRYSA2->(DbGotop())
	SA2->(DbGoto( QRYSA2->R_E_C_N_O_ ))
EndIf
Return nRecsSA2 // Registros encontrados SA2



/*���������������������������������������������������������������������������
���Programa  �GNRC_TMP  �Autor  �Microsiga           � Data �  11/20/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
���������������������������������������������������������������������������*/

// Regravacao do CTD conforme SA1 e SA2
// Processamento de eliminacao do CTD que nao confere com
User Function ItensCtb()
Private _cSqlSA1 := RetSqlName("SA1")
Private _cSqlSA2 := RetSqlName("SA2")
Private _cSqlCT2 := RetSqlName("CT2")
DbSelectArea("CTD")
CTD->(DbSetOrder(0)) // Recno
CTD->(DbGotop())
While CTD->(!EOF())
	If CTD->CTD_FILIAL == _cFilCTD
		If Len(AllTrim(CTD->CTD_ITEM)) < 9 // Codigo do item nao esta correto...
			nRecsCT2 := CheckCT2()
			If nRecsCT2 == 0 // Nao tem movimentos CT2
				If Left(CTD->CTD_ITEM,1) == "F"
					nRecsSA2 := CheckSA2()
					If nRecsSA2 == 1 // Fornecedor unico...
						RecLock("CTD",.F.)
						CTD->CTD_ITEM := "F" + SA2->A2_COD + SA2->A2_LOJA
						CTD->(MsUnlock())
						RecLock("SA2",.F.)
						SA2->A2_ITEMCTA := CTD->CTD_ITEM
						SA2->(MsUnlock())
					ElseIf nRecsSA2 == 0 // Nao tem amarracao com fornecedor tambem... apago
						RecLock("CTD",.F.)
						CTD->(DbDelete())
						CTD->(MsUnlock())
					EndIf
				ElseIf Left(CTD->CTD_ITEM,1) == "C"
					nRecsSA1 := CheckSA1()
					If nRecsSA1 == 1 // Fornecedor unico...
						RecLock("CTD",.F.)
						CTD->CTD_ITEM := "C" + SA1->A1_COD + SA1->A1_LOJA
						CTD->(MsUnlock())
						RecLock("SA1",.F.)
						SA1->A1_ITEMCTA := CTD->CTD_ITEM
						SA1->(MsUnlock())
					ElseIf nRecsSA1 == 0 // Nao tem amarracao com cliente tambem... apago
						RecLock("CTD",.F.)
						CTD->(DbDelete())
						CTD->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	CTD->(DbSkip())
End
Return

Static Function CheckCT2()
cQryCT2 := "SELECT CT2_ITEMD, CT2_ITEMC, R_E_C_N_O_ "
cQryCT2 += "FROM " + _cSqlCT2 + " WHERE "
cQryCT2 += "CT2_FILIAL = '" + CTD->CTD_FILIAL + "' AND "	// Filial conforme
cQryCT2 += "(CT2_ITEMD = '" + CTD->CTD_ITEM + "' OR "		// Item Credito conforme
cQryCT2 += "CT2_ITEMC = '" + CTD->CTD_ITEM + "') AND "		// Item Debito conforme
cQryCT2 += "D_E_L_E_T_ = ' '"								// Nao apagados
If Select("QRYCT2") > 0
	QRYCT2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),"QRYCT2",.T.,.F.)
Count To nRecsCT2
Return nRecsCT2 // Registros encontrados CT2

Static Function CheckSA1()
cQrySA1 := "SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, R_E_C_N_O_ "
cQrySA1 += "FROM " + _cSqlSA1 + " WHERE "
cQrySA1 += "A1_FILIAL = '" + PadR(Left(CTD->CTD_FILIAL,2),4) + "' AND "		// Filial conforme
cQrySA1 += "A1_ITEMCTA = '" + CTD->CTD_ITEM + "' AND "		// Item contabil conforme
cQrySA1 += "D_E_L_E_T_ = ' '"
If Select("QRYSA1") > 0
	QRYSA1->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA1),"QRYSA1",.T.,.F.)
Count To nRecsSA1
If nRecsSA1 == 1
	QRYSA1->(DbGotop())
	SA1->(DbGoto( QRYSA1->R_E_C_N_O_ ))
EndIf
Return nRecsSA1 // Registros encontrados SA1







/*���������������������������������������������������������������������������
���Programa  �GNRC_TMP  �Autor  �Microsiga           � Data �  11/20/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
���������������������������������������������������������������������������*/

User Function ClearCTD()
Local nRecsCT2 := 0
Local _cFilCTD := xFilial("CTD")
Local _cFilCT2 := xFilial("CT2")
Local _cSqlCT2 := RetSqlName("CT2")

DbSelectArea("CTD")
CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
CTD->(DbSeek(_cFilCTD))
While CTD->(!EOF()) .And. CTD->CTD_FILIAL == _cFilCTD
	                                                                                                                                              // F00001001
	If /*CTD->CTD_BLOQ == "2" .And.*/ !(Left(CTD->CTD_ITEM,1) $ "B") .And. (Len(AllTrim(CTD->CTD_ITEM)) <> 9 .Or. SubStr(CTD->CTD_ITEM,2,6) == "000000") // 2=Debloqueado e nao esta no padrao... se nao tiver lancamentos, apaga tbm
		
		cQryCT2 := "SELECT CT2_ITEMD, CT2_ITEMC, R_E_C_N_O_ "
		cQryCT2 += "FROM " + _cSqlCT2 + " WHERE "
		cQryCT2 += "CT2_FILIAL = '" + _cFilCT2 + "' AND "			// Filial conforme
		cQryCT2 += "(CT2_ITEMD = '" + CTD->CTD_ITEM + "' OR "		// Item Credito conforme
		cQryCT2 += "CT2_ITEMC = '" + CTD->CTD_ITEM + "') AND "		// Item Debito conforme
		cQryCT2 += "D_E_L_E_T_ = ' '"								// Nao apagados
		If Select("QRYCT2") > 0
			QRYCT2->(DbCloseArea())
		EndIf
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),"QRYCT2",.T.,.F.)
		Count To nRecsCT2
		If nRecsCT2 == 0 // Nenhum registro encontrado CT2
			RecLock("CTD",.F.)
			CTD->(DbDelete())
			CTD->(MsUnlock())
		EndIf
		
	EndIf
	
	CTD->(DbSkip())
End
Return




User Function CTDuplic()
Private cCodUsr := RetCodUsr()
Private aAgluts := {}
Private _cFilCTD := xFilial("CTD")
Private _cFilCT2 := xFilial("CT2")
Private _cSqlCT2 := RetSqlName("CT2")
Private _cSqlSA2 := RetSqlName("SA2")


// aAdd(aAgluts, { .T., { F00073801/F00022501				// Esse eh BIOMEC e BIOTEC
// aAdd(aAgluts, { .T., { F00029101/F00016001				// Filiais diferentes		SAO JOSE DOS CAMPOS e SAO PAULO
// aAdd(aAgluts, { .T., { F00069801/F00026101				// Filiais diferentes		CENOFISIO							*** Raiz Cnpj nao confere, verificar
// aAdd(aAgluts, { .T., { F00021901/F00000401				// Filiais diferentes		ANDRA				CASA VERDE	e SANTA IFIGENIA
// aAdd(aAgluts, { .T., { F00013201/F00009601				// Empresas diferentes		MASILOG
// aAdd(aAgluts, { .T., { F00074001/F00075801				// Filiais diferentes		RODONAVES
// aAdd(aAgluts, { .T., { F00012301/F00012302				// Filiais diferentes		SOUZA LIMA

//            { Atv,     Eliminar							Manter	}
aAdd(aAgluts, { .T., { "F00064501" },					"F00006901"	})
aAdd(aAgluts, { .T., { "F00067101" },					"F00014401" })
aAdd(aAgluts, { .T., { "F00042301", "F00045601", "F00070401" },	"F00023901" })
aAdd(aAgluts, { .T., { "F00067301" },					"F00005901"	})
aAdd(aAgluts, { .T., { "F00062801" },					"F00000301"	})
aAdd(aAgluts, { .T., { "F00021201" },					"F00057701"	}) // C00001101
aAdd(aAgluts, { .T., { "F00060701" },					"F00004401"	})
aAdd(aAgluts, { .T., { "F00062001" },					"F00021301"	})
aAdd(aAgluts, { .T., { "F00060601" },					"F00032001"	})
aAdd(aAgluts, { .T., { "F00068501" },					"F00016701" })
aAdd(aAgluts, { .T., { "F00064601" },					"F00006801" })
aAdd(aAgluts, { .T., { "F00070501" },					"F00007201" })
aAdd(aAgluts, { .T., { "F00068201", "F00034201" },		"F00018701"	})
aAdd(aAgluts, { .T., { "F00066001" },					"F00006101"	})
aAdd(aAgluts, { .T., { "F00035001" },					"F00000101" })
aAdd(aAgluts, { .T., { "F00061401", "F00062501" },		"F00002901"	})
aAdd(aAgluts, { .T., { "F00068801" },					"F00019501" })
aAdd(aAgluts, { .T., { "F00066201" },					"F00011101"	})
aAdd(aAgluts, { .T., { "F00033801" },					"F00000801" })
aAdd(aAgluts, { .T., { "F00062201" },					"F00000201"	})
aAdd(aAgluts, { .T., { "F00033501" },					"F00072301"	})
aAdd(aAgluts, { .T., { "F00062701" },					"F00003501"	})
aAdd(aAgluts, { .T., { "F00062901" },					"F00001101"	})
aAdd(aAgluts, { .T., { "F00066101" },					"F00004001"	})
aAdd(aAgluts, { .T., { "C00001801", "F00062101" },		"F00002401"	})
aAdd(aAgluts, { .T., { "F00068301" },					"F00015501"	})
aAdd(aAgluts, { .T., { "F00070001" },					"F00026401"	})
aAdd(aAgluts, { .T., { "F00066501" },					"F00011301"	})
aAdd(aAgluts, { .T., { "F00063601" },					"F00001001"	})
aAdd(aAgluts, { .T., { "F00052301" },					"F00030001"	})
aAdd(aAgluts, { .T., { "F00063701" },					"F00002801" })
aAdd(aAgluts, { .T., { "C00003001" },					"F00007901"	})
aAdd(aAgluts, { .T., { "C00005101", "F00051801" },		"F00001101"	})
aAdd(aAgluts, { .T., { "F00063101" },					"F00000501"	})
aAdd(aAgluts, { .T., { "F00051101" },					"F00016601"	})
aAdd(aAgluts, { .T., { "F00042901" },					"F00027801"	})
aAdd(aAgluts, { .T., { "F00050701" },					"F00073401"	})
aAdd(aAgluts, { .T., { "F00064301" },					"F00007001"	})
aAdd(aAgluts, { .T., { "F00065801" },					"F00011500"	})
aAdd(aAgluts, { .T., { "F00061501" },					"F00002301"	})
aAdd(aAgluts, { .T., { "F00066301" },					"F00007301"	})
aAdd(aAgluts, { .T., { "C00006201" },					"F00018601"	})
aAdd(aAgluts, { .T., { "F00044001" },					"F00072201"	})
aAdd(aAgluts, { .T., { "F00063001" },					"F00001201"	})
aAdd(aAgluts, { .T., { "F00067201" },					"F00020201" })
aAdd(aAgluts, { .T., { "F00067401" },					"F00014701"	})
aAdd(aAgluts, { .T., { "F00067501" },					"F00012601"	})
aAdd(aAgluts, { .T., { "C00002201" },					"F00025701"	})
aAdd(aAgluts, { .T., { "F00063201" },					"F00001301"	})
aAdd(aAgluts, { .T., { "F00058601" },					"F00058001"	})
aAdd(aAgluts, { .T., { "F00062301" },					"F00001401" })
aAdd(aAgluts, { .T., { "F00052201", "C00002701" },		"F00000901" })
aAdd(aAgluts, { .T., { "F00001501" },					"F00063801"	})
aAdd(aAgluts, { .T., { "F00032301", "F00065901", "F00048901" },		"F00013501"	})
aAdd(aAgluts, { .T., { "F00061301" },					"F00001801"	})
aAdd(aAgluts, { .T., { "F00051001" },					"F00027501"	})
aAdd(aAgluts, { .T., { "F00063301" },					"F00001901" })
aAdd(aAgluts, { .T., { "F00031401", "F00063401", "F00067801" }, 	"F00003701" })
aAdd(aAgluts, { .T., { "F00048201" },					"F00027201" })
aAdd(aAgluts, { .T., { "F00047901" },					"F00023601" })
aAdd(aAgluts, { .T., { "F00050001" },					"F00002701"	})
aAdd(aAgluts, { .T., { "F00064401" },					"F00007101" })
aAdd(aAgluts, { .T., { "F00063501" },					"F00003301" })

// CT2_FILIAL == "0505" .And. (CT2_ITEMD $ "F00003301/F00063501" .Or. CT2_ITEMC $ "F00003301/F00063501")






// Parte 01: Carregamento das aglutinacoes 07 BMA

//            { Atv,     Eliminar								Manter	}
/*
// PETROFER
aAdd(aAgluts, { .T., { "F00040001" },						"F00014901" })
aAdd(aAgluts, { .T., { "F00042901" }, 						"F00043301" })
aAdd(aAgluts, { .T., { "F00024701" },						"F00044801"	})
aAdd(aAgluts, { .T., { "F00007201" }, 						"F00041201" })
aAdd(aAgluts, { .T., { "F00024501" },						"F00044201"	})
aAdd(aAgluts, { .T., { "F00040501" },						"F00013001"	})
*/


// F00035901/F00041801	// Ajustado manual
// F00042901/F00043/\301	// CNPJ diferentes
// F00001201/F00043001		// CNPJ diferentes
// F00007201/F00041201
// F00044201/F00024501
// F00013001/F00040501









/*
// PETROFER
aAdd(aAgluts, { .T., { "F00039401" },						"F00014601"	})
aAdd(aAgluts, { .T., { "F00028301" },						"F00011101"	})
aAdd(aAgluts, { .T., { "F00009075" },						"F00001901"	})
aAdd(aAgluts, { .T., { "F00022401" },						"F00013201"	})
aAdd(aAgluts, { .T., { "F00039801" },						"F00008201"	})
aAdd(aAgluts, { .T., { "F00023001" },						"F00042201"	})
aAdd(aAgluts, { .T., { "F00040701" },						"F00012401" })
aAdd(aAgluts, { .T., { "F00022301", "F00041501" },			"F00019901"	})
aAdd(aAgluts, { .T., { "F00001701" },						"F00038101" })
aAdd(aAgluts, { .T., { "F00041001" },						"F00030301"	})
aAdd(aAgluts, { .T., { "F00009045" },						"F00003601"	})
aAdd(aAgluts, { .T., { "C00005401" },						"F00001201"	})
aAdd(aAgluts, { .T., { "F00037601" },						"F00001801"	})
aAdd(aAgluts, { .T., { "F00039601" },						"F00014001"	})
aAdd(aAgluts, { .T., { "F00039001" },						"F00041701"	})
aAdd(aAgluts, { .T., { "F00034001" },						"F00018901"	})
aAdd(aAgluts, { .T., { "F00039901" },						"F00014701"	})
aAdd(aAgluts, { .T., { "F00041601" },						"F00021601"	})
aAdd(aAgluts, { .T., { "F00035301" },						"F00020101"	})
aAdd(aAgluts, { .T., { "F00036601", "F00036701" },			"F00020001"	})
aAdd(aAgluts, { .T., { "F00009009" },						"F00000701"	})
aAdd(aAgluts, { .T., { "F00039101" },						"F00006201"	})
aAdd(aAgluts, { .T., { "C00003701" },						"F00000301"	})
aAdd(aAgluts, { .T., { "F00042501" },						"F00028901"	})
aAdd(aAgluts, { .T., { "F00034201" },						"F00013401"	})
aAdd(aAgluts, { .T., { "F00009142" },						"F00008801"	})
aAdd(aAgluts, { .T., { "F00019301" },						"F00040901"	})
aAdd(aAgluts, { .T., { "F00030701" },						"F00024401"	})
aAdd(aAgluts, { .T., { "F00024201" },						"F00001401"	})
aAdd(aAgluts, { .T., { "F00038201" },						"F00002101"	})
aAdd(aAgluts, { .T., { "F00032801" },						"F00014401" })
aAdd(aAgluts, { .T., { "F00039501" },						"F00004501"	})
aAdd(aAgluts, { .T., { "F00043401" },						"F00040301"	})
*/

// F00015404/F00009028	-> LOCALIZA RENT A CAR						tem varios CNPJs
// F00014201/F00012301	-> KN WAAGEN BALANCAS10 EIRELI              2 CNPJ diferentes
// F00005301/F00013101/F00009009 -> KALUNGA							diversos fornecedores
// F00035901/F00041801 // Misturaram 2 fornecedores


/*
BMA
aAdd(aAgluts, { .T., { "F00013401" },						"F00015701" })
aAdd(aAgluts, { .T., { "F00038501" },						"F00000201" })
aAdd(aAgluts, { .T., { "F00041601" },						"F00010701"	})
aAdd(aAgluts, { .T., { "F00032801" },						"F00004901" })
aAdd(aAgluts, { .T., { "F00038601" },						"F00000901" })

aAdd(aAgluts, { .T., { "F00039801" },						"F00002501" })
aAdd(aAgluts, { .T., { "F00038801" },						"F00000601" })
aAdd(aAgluts, { .T., { "F00022501", "F00040001" },			"F00001901" })
aAdd(aAgluts, { .T., { "F00032401" },						"F00013801" })
aAdd(aAgluts, { .T., { "F00030901", "F00040501" },			"F00008001" })

aAdd(aAgluts, { .T., { "F00026801" }, 						"F00002601" })
aAdd(aAgluts, { .T., { "F00041901" }, 						"F00011301" })
aAdd(aAgluts, { .T., { "F00038301" },						"F00001001" })
aAdd(aAgluts, { .T., { "F00001101" },						"F00038401" })

aAdd(aAgluts, { .T., { "F00032601", "F00041101" },			"F00008401"	})
aAdd(aAgluts, { .T., { "F00039601", "F00036901" },			"F00003301"	})
aAdd(aAgluts, { .T., { "F00027001" },						"F00015001" })
aAdd(aAgluts, { .T., { "F00039901" },						"F00003601" })

aAdd(aAgluts, { .T., { "F00040601", "F00031001" },			"F00007701"	})
aAdd(aAgluts, { .T., { "F00041501" },						"F00010601" })
aAdd(aAgluts, { .T., { "F00039701" },						"F00001801" })
*/


// Parte 02: Avaliacao das aglutinacoes
For w := 1 To Len(aAgluts)
	If aAgluts[w,01] // .T.=Ativo .F.=Inativo
		For w2 := 1 To Len(aAgluts[w,02]) // Rodo nas origens
			
			If CTD->(DbSeek(_cFilCTD + aAgluts[w,03])) // CTD Destino
				
				If CTD->(DbSeek(_cFilCTD + aAgluts[w,02,w2])) // CTD Origem (a excluir)
					
					// Processamento 01: Atualizacoes do CT2
					cQryCT2 := "SELECT CT2_ITEMD, CT2_ITEMC, R_E_C_N_O_ "
					cQryCT2 += "FROM " + _cSqlCT2 + " WHERE "
					cQryCT2 += "CT2_FILIAL = '" + _cFilCT2 + "' AND "			// Filial conforme
					cQryCT2 += "(CT2_ITEMD = '" + CTD->CTD_ITEM + "' OR "		// Item Credito conforme
					cQryCT2 += "CT2_ITEMC = '" + CTD->CTD_ITEM + "') AND "		// Item Debito conforme
					cQryCT2 += "D_E_L_E_T_ = ' '"								// Nao apagados
					If Select("QRYCT2") > 0
						QRYCT2->(DbCloseArea())
					EndIf
					DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),"QRYCT2",.T.,.F.)
					Count To nRecsCT2
					If nRecsCT2 > 0 // Registros encontrados CT2
						QRYCT2->(DbGotop())
						While QRYCT2->(!EOF())
							
							CT2->(DbGoto( QRYCT2->R_E_C_N_O_ ))
							
							If CT2->CT2_ITEMD == CTD->CTD_ITEM
								RecLock("CT2",.F.)
								CT2->CT2_ITEMD := aAgluts[w,03]
								CT2->(MsUnlock())
							EndIf
							
							If CT2->CT2_ITEMC == CTD->CTD_ITEM
								RecLock("CT2",.F.)
								CT2->CT2_ITEMC := aAgluts[w,03]
								CT2->(MsUnlock())
							EndIf
							
							QRYCT2->(DbSkip())
						End
					EndIf
					
					// Processamento 02: Bloqueio e Exclusao do CTD
					RecLock("CTD",.F.)
					CTD->CTD_BLOQ := "1" // Bloqueado
					CTD->(MsUnlock())
					
					If CheckSA2() == 1 // Localizado 1 fornecedor SA2 para o Item Contabil a Excluir.. excluimos o SA2 tambem
						RecLock("SA2",.F.)
						SA2->(DbDelete())
						SA2->(MsUnlock())
					EndIf
					
					RecLock("CTD",.F.)
					CTD->(DbDelete())
					CTD->(MsUnlock())
					
				EndIf
				
			EndIf
			
		Next
	EndIf
	
Next

Return



User Function ImporCT1() // Importacao de Plano de Contas
// CONTA;DC;COD.RES.;D E N O M I N A C A O;;CLASSE;C.NORMAL;CTA SUPERIOR;BLOQ

Local aDado := {}
Local aDados := {}
Private cCodUsr := RetCodUsr()
Private aDadosOk := {}
Private _cFilCT1 := xFilial("CT1")

Private cArqRet := fAbrir() // cArquivo := "C:\TEMP\RETORNOCONCILIA_PAGAMENTO_1443725046558_MOD.CSV" //cArquivo := fAbrir()
If Empty(cArqRet)
	MsgStop("Arquivo nao informado!","ImporCT1")
	Return
ElseIf !File(cArqRet)
	MsgStop("Arquivo nao encontrado!" + Chr(13) + Chr(10) + ;
	cArqRet,"ImporCT1")
	Return
Else
	// SplitPath( cArquivo, @cDrive, @cDir, @cFile, @cExten )
EndIf


// PARTE 01: Carregando dados do .CSV
FT_FUse(cArqRet)
FT_FGOTOP()
FT_FSkip() // Pula cabecalho

// PARTE 01: Carregamento dos dados
DbSelectArea("CT1")
CT1->(DbSetOrder(1)) // CT1_FILIAL + CT1_CONTA
While (!FT_FEOF())
	cBuffer := FT_FREADLN()
	While At(";;",cBuffer) > 0
		cBuffer := StrTran(cBuffer,";;"," ; ; ")
	End
	aDado := StrToKarr(cBuffer,";")
	
	If Len(aDado) >= 8 .And. !Empty(aDado[01]) // Dados ok
		
		//    01;02;      03;                   04;;    06;      07;          08;  09
		// CONTA;DC;COD.RES.;D E N O M I N A C A O;;CLASSE;C.NORMAL;CTA SUPERIOR;BLOQ
		If Len(aDado) == 8 // Sem historico
			aAdd(aDado, "Nao Bloqueada") // 2=Nao Bloqueada
		EndIf
		
		// Filial;Num Invoice;Emissao;Moeda;Valor Moeda;TaxaMoeda;Item Contabil
		aAdd(aDados, aClone(aDado)) // Carrego toda a linha em matriz
		
	EndIf
	
	FT_FSkip() // Pula cabecalho
End
FT_FUse()

// PARTE 02: Preparacao
For w := 1 To Len(aDados)
	cConta	:= PadR(AllTrim(StrTran(aDados[w,01],".","")),20)			// Conta Contabil
	cDC		:= aDados[w,02]												// Digito Controle
	cReduz	:= aDados[w,03]												// Codigo Reduzido
	cDescr	:= Upper(AllTrim(aDados[w,04]))								// Descricao
	cDescI	:= Upper(AllTrim(aDados[w,05]))								// Descricao Ingles
	cClass	:= Upper(aDados[w,06])										// Classe				1=Sintetica	2=Analitica
	cNorma	:= Upper(aDados[w,07])										// Condicao				1=Devedora 2=Credora
	cSuper	:= aDados[w,08]												// Conta Superior
	cBloqu	:= Upper(aDados[w,09])										// Bloqueada
	
	If "SINT" $ cClass
		cClass := "1"
	Else
		cClass := "2"
	EndIf
	
	If "DEV" $ cNorma
		cNorma := "1"
	Else
		cNorma := "2"
	EndIf
	
	If "NAO" $ cBloqu
		cBloqu := "2"
	Else
		cBloqu := "1"
	EndIf
	
	//             {     01,  02,     03,     04,     05,     06,     07,     08,     09 }
	aAdd(aDadosOK, { cConta, cDC, cReduz, cDescr, cDescI, cClass, cNorma, cSuper, cBloqu })
Next

// PARTE 03: Processamento
If MsgYesNo("Confirma processamento CT1?")
	For w := 1 To Len(aDadosOK)
		If CT1->(DbSeek(_cFilCT1 + aDadosOK[w,01]))
			RecLock("CT1",.F.)
		Else
			RecLock("CT1",.T.)
			CT1->CT1_FILIAL := _cFilCT1
			CT1->CT1_CONTA	:= aDadosOK[w,01]
		EndIf
		CT1->CT1_DC		:= aDadosOK[w,02]
		CT1->CT1_RES	:= aDadosOK[w,03]
		CT1->CT1_DESC01	:= aDadosOK[w,04]
		CT1->CT1_DESC02	:= aDadosOK[w,05]
		CT1->CT1_CLASSE	:= aDadosOK[w,06]
		CT1->CT1_NORMAL	:= aDadosOK[w,07]
		CT1->CT1_CTASUP	:= aDadosOK[w,08]
		CT1->CT1_BLOQ	:= aDadosOK[w,09]
		CT1->(MsUnlock())
	Next
EndIf
Return



User Function RepInvoi() // Ajustador das invoices erradas (Jonathan 09/11/2019)
Local aDado := {}
Local aDados := {}
Private cCodUsr := RetCodUsr()
Private aDadosOk := {}
Private _cFilSE2 := xFilial("SE2")
Private _cFilSA2 := xFilial("SA2")
Private _cFilSED := xFilial("SED")
Private _cSqlSE2 := RetSqlName("SE2")
Private cArqRet := fAbrir() // cArquivo := "C:\TEMP\RETORNOCONCILIA_PAGAMENTO_1443725046558_MOD.CSV" //cArquivo := fAbrir()
If Empty(cArqRet)
	MsgStop("Arquivo nao informado!","ImpInvoi")
	Return
ElseIf !File(cArqRet)
	MsgStop("Arquivo nao encontrado!" + Chr(13) + Chr(10) + ;
	cArqRet,"ImpInvoi")
	Return
Else
	// SplitPath( cArquivo, @cDrive, @cDir, @cFile, @cExten )
EndIf

// PARTE 01: Carregando dados do .CSV
FT_FUse(cArqRet)
FT_FGOTOP()
FT_FSkip() // Pula cabecalho

// PARTE 01: Carregamento dos dados
DbSelectArea("SE2")
SE2->(DbSetOrder(2)) // E2_FILIAL + E2_PREFIXO + ...
While (!FT_FEOF()) //  .And. Len(aDados) <= 10
	cBuffer := FT_FREADLN()
	While At(";;",cBuffer) > 0
		cBuffer := StrTran(cBuffer,";;"," ; ; ")
	End
	aDado := StrToKarr(cBuffer,";")
	
	// numero sistema;numero correto
	aAdd(aDados, aClone(aDado)) // Carrego toda a linha em matriz
	
	FT_FSkip() // Pula cabecalho
End
FT_FUse()

// PARTE 02: Preparacao
For w := 1 To Len(aDados)
	
	aSize(aDados[w],04)					// { Num Old, Num New, Localiz }
	
	cFilOld := _cFilSE2					// Filial (old)
	cNumOld := PadR(aDados[w,01],09)	// Numero invoice (old)
	cParOld := Space(02)				// Parcela (old)
	
	cQrySE2 := "SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_ "
	cQrySE2 += "FROM " + _cSqlSE2 + " WHERE "
	cQrySE2 += "E2_FILIAL = '" + cFilOld + "' AND "	   						// Filial conforme
	cQrySE2 += "E2_PREFIXO IN " + FormatIn("INV/INJ/EMP","/") + " AND "		// Prefixo conforme
	cQrySE2 += "E2_NUM = '" + cNumOld + "' AND "							// Numero titulo conforme
	cQrySE2 += "E2_PARCELA = '" + cParOld + "' AND "						// Parcela conforme
	cQrySE2 += "E2_TIPO IN " + FormatIn("INV/EMP","/") + " AND "		 	// Tipo conforme
	cQrySE2 += "E2_SALDO = E2_VALOR AND "									// Valor e Saldo conforme
	cQrySE2 += "(E2_MOEDA = 2 OR E2_MOEDA = 4) AND "						// Moeda conforme
	cQrySE2 += "D_E_L_E_T_ = ' '"											// Nao apagado
	If Select("QRYSE2") > 0
		QRYSE2->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySE2),"QRYSE2",.T.,.F.)
	Count To nRecsSE2
	
	aDados[w,03] := nRecsSE2 == 1	// .T.=Localizado .F.=Nao localizado
	
	If nRecsSE2 <> 1
		MsgStop("Titulo nao encontrado: " + cNumOld)
	Else // Localizado
		QRYSE2->(DbGotop())
		aDados[w,04] := QRYSE2->R_E_C_N_O_
	EndIf
	
Next

// Apagando e gerando novamente
If MsgYesNo("Processa ExecAutos?")
	For w := 1 To Len(aDados)
		
		If aDados[w,03] // .T.=Localizado (vamos entao apagar)
			
			SE2->(DbGoto( aDados[w,4] ))
			
			// Geracao do numero novo caso ainda nao exista
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
			If SA2->(DbSeek(_cFilSA2 + SE2->E2_FORNECE + SE2->E2_LOJA))
				DbSelectArea("SE2")
				SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
				
				If SE2->(!DbSeek(SE2->E2_FILIAL + SE2->E2_PREFIXO + PadR(aDados[w,02],09) + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA))
					
					SE2->(DbGoto( aDados[w,4] )) // Reposiciono no origem
					
					// Geracao do novo com numero correto
					aTit := {}
					aAdd(aTit, { "E2_PREFIXO",		SE2->E2_PREFIXO,						Nil })		// Prefixo do titulo
					aAdd(aTit, { "E2_NUM",			PadR(aDados[w,02],09),					Nil })		// Numero do titulo
					aAdd(aTit, { "E2_PARCELA",		SE2->E2_PARCELA,						Nil })		// Parcela do titulo
					aAdd(aTit, { "E2_TIPO",			SE2->E2_TIPO,							Nil })		// Tipo do titulo
					aAdd(aTit, { "E2_NATUREZ",		SE2->E2_NATUREZ,						Nil })		// Natureza do titulo
					aAdd(aTit, { "E2_FORNECE",		SE2->E2_FORNECE,						Nil })		// Fornecedor
					aAdd(aTit, { "E2_LOJA",			SE2->E2_LOJA,							Nil })		// Loja
					aAdd(aTit, { "E2_EMISSAO",		SE2->E2_EMISSAO,						Nil })		// Data de Emissao
					aAdd(aTit, { "E2_MOEDA",		SE2->E2_MOEDA,							Nil })		// Moeda do Titulo
					aAdd(aTit, { "E2_VALOR",		SE2->E2_VALOR,							Nil })		// Valor Total do Titulo
					aAdd(aTit, { "E2_VENCTO",		SE2->E2_VENCTO,							Nil })		// Vencimento
					aAdd(aTit, { "E2_HIST",			SE2->E2_HIST,							Nil })		// Historico
					aAdd(aTit, { "E2_TXMOEDA",		SE2->E2_TXMOEDA,						Nil })		// Moeda do Titulo
					
					lMsErroAuto := .F.
					lExibeLanc := .F.
					lOnline := .F.
					MsExecAuto({|a,b,c,d,e,f,g|, FINA050(a,b,c,d,e,f,g)}, aTit,,3,, /*aDadosBco*/ Nil, lExibeLanc, lOnline)
					If lMsErroAuto .Or. SE2->E2_NUM <> PadR(aDados[w,02],09) // Falha
						MostraErro()
					Else // Marca como contabilizado
						RecLock("SE2",.F.)
						SE2->E2_LA := "S" // Marca como contabilizado
						SE2->(MsUnlock())
					EndIf
					
				EndIf
			EndIf
			
			
			// Exclusao do antigo
			
			SE2->(DbGoto( aDados[w,4] )) // Reposiciono no origem
			
			aTit := {}
			aAdd(aTit, { "E2_PREFIXO",		SE2->E2_PREFIXO,							Nil })		// Prefixo do titulo
			aAdd(aTit, { "E2_NUM",			SE2->E2_NUM,								Nil })		// Numero do titulo
			aAdd(aTit, { "E2_PARCELA",		SE2->E2_PARCELA,							Nil })		// Parcela do titulo
			aAdd(aTit, { "E2_TIPO",			SE2->E2_TIPO,								Nil })		// Tipo do titulo
			aAdd(aTit, { "E2_FORNECE",		SE2->E2_FORNECE,							Nil })		// Fornecedor
			aAdd(aTit, { "E2_LOJA",			SE2->E2_LOJA,								Nil })		// Loja
			aAdd(aTit, { "E2_NATUREZ",		SE2->E2_NATUREZ,							Nil })		// Natureza do titulo
			
			lMsErroAuto := .F.
			lExibeLanc := .T.
			lOnline := .F.
			MsExecAuto({|x,y,z| FINA050(x,y,z)}, aTit,, 5)
			
			
			// MsExecAuto({|a,b,c,d,e,f,g|, FINA050(a,b,c,d,e,f,g)}, aTit,,5,, /*aDadosBco*/ Nil, lExibeLanc, lOnline)
			If lMsErroAuto // Falha
				//ConOut("ExeAutE2: " + DtoC(Date()) + " " + Time() + " " + cCodUsr + " " + cUserName + " Chamando ExecAuto FINA050... Falha!")
				U_LogAlteracoes("E2", "E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA", aTit, "ExecAuto FINA050", "Falha", cCodUsr)
				MostraErro()
				Return
			Else // Sucesso
				
			EndIf
			
		EndIf
		
	Next
EndIf

MsgInfo("Concluido!")
Return


/*
cFilial := xFilial("SE2")			// Empresa/Filial Petrofer
cPrefix := aDados[w,02] // "INJ"	// Prefixo
cNumInv := PadR(aDados[w,03],09)	// Numero invoice
dEmissa := CtoD(aDados[w,04])		// Data de emissao
If Empty(dEmissa) // Data invalida
MsgStop("Data nao identificada (falha na conversao)!" + Chr(13) + Chr(10) + ;
"Data: " + aDados[w,04],"ImpInvoi")
Return
EndIf
If "EUR" $ Upper(aDados[w,05])		// Euros
nMoeda	:= 4
ElseIf "DOL" $ Upper(aDados[w,05])	// Dolares
nMoeda	:= 2
ElseIf "USD" $ Upper(aDados[w,05])	// Dolares
nMoeda	:= 2
Else
MsgStop("Moeda nao identificada!","ImpInvoi")
Return
EndIf
nVlrInv := Val(StrTran(StrTran(StrTran(StrTran(aDados[w,06],".",""),",","."),"R$",""),"�",""))	// Valor
cIteCtb := PadR(AllTrim(aDados[w,08]),09)						// Item contabil
cNature := PadR(aDados[w,09],10)								// Natureza
cTipInv := "INJ"												// Tipo
dVencim := CtoD("31/12/2019")									// Vencimento
cHistor := AllTrim(aDados[w,10])								// Historico
nTaxMoe := 0
If SM2->(DbSeek("20190628")) // Obtencao da taxa moeda
nTaxMoe := &("SM2->M2_MOEDA" + cValToChar(nMoeda)) // Taxa do SM2
EndIf

If cFilial <> cFilAnt
MsgStop("Filial do titulo nao confere com a filial logada!" + Chr(13) + Chr(10) + ;
"Filial do titulo: " + cFilial,"ImpInvoi")
Return
EndIf

If Len(RTrim(aDados[w,03])) > 9 // Numero maior que 9
MsgStop("Numero do titulo ultrapassa o tamanho maximo!" + Chr(13) + Chr(10) + ;
"Numero: " + aDados[w,03],"ImpInvoi")
Return
EndIf

If nTaxMoe == 0 // Taxa nao obtida
MsgStop("Taxa da Moeda nao identificada!")
Return
EndIf
_cSqlSA2 := RetSqlName("SA2")
cQrySA2 := "SELECT A2_COD, A2_LOJA, A2_ITEMCTA "
cQrySA2 += "FROM " + _cSqlSA2 + " WHERE "
cQrySA2 += "A2_FILIAL = '" + _cFilSA2 + "' AND "		// Filial conforme
cQrySA2 += "A2_ITEMCTA = '" + cIteCtb + "' AND "		// Item contabil conforme
cQrySA2 += "D_E_L_E_T_ = ' '"							// Nao apagado
If Select("QRYSA2") > 0
QRYSA2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySA2),"QRYSA2",.T.,.F.)
Count To nRecsSA2
If nRecsSA2 == 1 // Registro encontrado
QRYSA2->(DbGotop())
DbSelectArea("SED")
SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
If SED->(DbSeek(_cFilSED + cNature)) // {      01,      02,      03,     04,      05,      06,      07,             08,              09,      10,      11,      12,      13 }
aAdd(aDadosOk,                      { cPrefix, cNumInv, dEmissa, nMoeda, nVlrInv, cIteCtb, cNature, QRYSA2->A2_COD, QRYSA2->A2_LOJA, cTipInv, dVencim, cHistor, nTaxMoe })
Else // Natureza nao encontrada
MsgStop("Natureza nao encontrada no cadastro (SED)!" + Chr(13) + Chr(10) + ;
"Natureza: " + cNature,"ImpInvoi")
Return
EndIf
Else // Falha na localizacao do Fornecedor pelo Item Contabil
MsgStop("Foram encontrados " + cValToChar(nRecsSA2) + " fornecedores para o" + Chr(13) + Chr(10) + ;
"Item Contabil informado: " + cIteCtb + Chr(13) + Chr(10) + ;
"A importacao nao pode prosseguir!","ImpInvoi")
Return
EndIf

Next

// PARTE 03: Processamento
If Len(aDadosOk) > 0
If MsgYesNo("Confirma processamento de " + cValToChar(Len(aDadosOk)) + " registros?")
For w := 1 To Len(aDadosOk)
ExeAutE2(aDadosOk[w])
Next
EndIf
EndIf
Return
*/
