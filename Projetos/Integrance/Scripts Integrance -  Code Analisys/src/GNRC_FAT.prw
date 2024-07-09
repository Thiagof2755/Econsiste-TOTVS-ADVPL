#INCLUDE "PROTHEUS.CH"
//#INCLUDE "RESTFUL.CH"
//#INCLUDE "JSON.CH"
//#INCLUDE "SHASH.CH"
//#INCLUDE "AARRAY.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ GNRC_FAT ºAutor ³Jonathan Schmidt Alvesº Data ³ 26/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcoes genericas do faturamento.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ ASKYESNO ºAutor ³Jonathan Schmidt Alves º Data ³26/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para apresentacao de tela temporaria de espera por  º±±
±±º          ³ decisao do usuario.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Argumentos:                                                º±±
±±º          ³ _nWait: Tempo em milisegundos de existencia da tela        º±±
±±º          ³ _cTitulo: Titulo da janela                                 º±±
±±º          ³ _cMsg1: Texto da mensagem da linha 1                       º±±
±±º          ³ _cMsg2: Texto da mensagem da linha 2                       º±±
±±º          ³ _cMsg3: Texto da mensagem da linha 3                       º±±
±±º          ³ _cMsg4: Texto da mensagem da linha 4                       º±±
±±º          ³ _cTitBut: Titulo do botao de cancelamento                  º±±
±±º          ³ _xTpImg: Numero da imagem, codigo do nivel ou especifica   º±±
±±º          ³ _lIncrease: Apresenta e incrementa barra oMeter            º±±
±±º          ³ _lAutoIn: Auto incremento conforme tempo _nWait            º±±
±±º          ³ __xBlock: Bloco de codigo de processamento                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function AskYesNo(_nWait,_cTitulo,_cMsg1,_cMsg2,_cMsg3,_cMsg4,_cTitBut,_xTpImg,_lIncrease,_lAutoInc,__xBlock)
Local aImgPads := { "UPDINFORMATION", "UPDWARNING", "UPDERROR", "OK", "CLIENTE" }
Local aImgFase := {}
Local cResource := ""
Local nCl := 0
Local nLn := 005
Private oTimer
Private oBtCancel
Private oDlgAsk
Private oTitCpo := TFont():New("Cambria",,018,,.T.,,,,,.F.,.F.)
Private oBmp99
Default _xTpImg := 0 // 0=Sem Imagem 1=Imagem informacao 2=Imagem alerta 3=Imagem erro
Default _nWait := 10000
Default _lIncrease := .F.
Default _lAutoInc := .F.
Default __xBlock := .F.
Private oMeter
Private nMeter := 0
Private nWait := _nWait
Private lIncrease := _lIncrease
Private lAutoInc := _lAutoInc
Private _bBlock := __xBlock
Private xTpImg := _xTpImg
Public oSayMsg1
Public oSayMsg2
Public oSayMsg3
Public oSayMsg4
Public cTitWnd := _cTitulo
Public cMsg1 := _cMsg1
Public cMsg2 := _cMsg2
Public cMsg3 := _cMsg3
Public cMsg4 := _cMsg4
Public _lButton := .T.
DEFINE MSDIALOG oDlgAsk FROM 0,0 TO 125,480 PIXEL TITLE cTitWnd
If lIncrease
	Public _oMeter := tMeter():New(56,15,{|u| if(Pcount() > 0, nMeter := u, nMeter)},100,oDlgAsk, 210, 05,,.T.,,,,,,1000) // cria a régua
	nCurrent := Eval(_oMeter:bSetGet) // pega valor corrente da régua
EndIf
If !Empty(xTpImg) // Exibir imagem
	If ValType(xTpImg) == "N" .And. xTpImg <= Len(aImgPads)
		cResource := aImgPads[xTpImg]
	ElseIf ValType(xTpImg) == "C"
		If (nPosX := ASCan(aImgFase, {|x|, x[1] == xTpImg })) > 0 // Cores das Fases
			cResource := aImgFase[nPosX,3] // Resource da imagem
			cMsg1 := xTpImg + " = " + aImgFase[nPosX,2] // Descricao da fase
			nCl := 008
			nLn := 002
		Else
			cResource := xTpImg // Texto direto a imagem do GetResources
			nCl := 004
		EndIf
	EndIf
	If !Empty(cResource) // Imagem a apresentar
		@nLn,007 BitMap oBmp99 Resource cResource Size 80,80 Of oDlgAsk Pixel Noborder // Stretch //Noborder
		nCl := 020
		nLn := 001
	EndIf
EndIf
@nLn,005 + nCl SAY oSayMsg1 VAR cMsg1 SIZE 225,020 OF oDlgAsk FONT oTitCpo Pixel
@015,005 + nCl SAY oSayMsg2 VAR cMsg2 SIZE 225,020 OF oDlgAsk FONT oTitCpo Pixel
@025,005 + nCl SAY oSayMsg3 VAR cMsg3 SIZE 225,020 OF oDlgAsk FONT oTitCpo Pixel
@035,005 + nCl SAY oSayMsg4 VAR cMsg4 SIZE 225,020 OF oDlgAsk FONT oTitCpo Pixel
DEFINE SBUTTON oBtCancel FROM 045,195 TYPE 2 ACTION (AskWait9(.F.,.T.)) ENABLE OF oDlgAsk
DEFINE TIMER oTimer INTERVAL nWait ACTION AskWait9(.T.,.F.) OF oDlgAsk
If ValType(_bBlock) == "B"
	DEFINE TIMER oTimer2 INTERVAL 10 ACTION AskWait7() OF oDlgAsk
EndIf
oDlgAsk:bLClicked := {|| oTimer:DeActivate(), oTimer:nInterval := nWait, oTimer:lActive := .T. }
If Empty(_cTitBut)
	oBtCancel:lVisible := .F.
Else
	oBtCancel:cCaption := _cTitBut
EndIf
ACTIVATE MSDIALOG oDlgAsk CENTERED ON INIT InitAsk9()
Return _lButton // .T.=Nao Cancelado .F.=Cancelado

Static Function InitAsk9() // Inicializador do Timer e do Meter se necessario
Local _nWait := 0
If lIncrease // Incremento de regua
	If lAutoInc // Auto incremento
		oTimer:Activate()
		_nWait := nWait / 10 // 2000 divid 10 sao 10 incrementos a cada 200 milisegundos
		For w := 1 To 10
			If ValType(_oMeter) == "O" // Objeto ativo
				nCurrent += 10 // atualiza régua
				_oMeter:Set(nCurrent)
				ProcessMessages()
				_oMeter:Refresh()
				Sleep(_nWait) // Espero 200 milisegundos, sao 10 rodadas
			Else
				Return
			EndIf
		Next
	ElseIf ValType(_bBlock) == "B" // !Empty(cFunction)
		oTimer2:Activate() // Ativa timer de processamento
	EndIf
Else // Sem incremento de regua
	oTimer:Activate()
EndIf
Return

Static Function AskWait7()
Eval(_bBlock)
oDlgAsk:End()
Return

Static Function AskWait9(__lButton,lClick)
If lClick
	_lButton := .F.
	oTimer:End()
EndIf
oBtCancel:SetDisabled()
oDlgAsk:Refresh()
SysRefresh()
If !__lButton
	oBtCancel:Refresh()
	Sleep(500)
EndIf
oDlgAsk:End()
Return

User Function AtuAsk09(nCurrent,cMsg1,cMsg2,cMsg3,cMsg4,nSleep,cPict) // Atualizacao do Objeto AskYesNo
Default nSleep := 0
Default cPict := ""
_oMeter:Set(nCurrent)
oSayMsg1:cCaption := cMsg1
oSayMsg2:cCaption := cMsg2
oSayMsg3:cCaption := cMsg3
oSayMsg4:cCaption := cMsg4
oSayMsg1:Refresh()
oSayMsg2:Refresh()
oSayMsg3:Refresh()
oSayMsg4:Refresh()
If !Empty(cPict)
	oBmp99:cResName := cPict
	oBmp99:lVisible := .T.
	oBmp99:Refresh()
EndIf
_oMeter:Refresh()
ProcessMessages()
Sleep(nSleep)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ GERAEX02 ºAutor  ³Jonathan Schmidt Alvesº Data³ 26/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcoes genericas faturamento.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//User Function GeraEx01(aCabec, aColun, aDados, aColsSoma, nExcLines, lAuto) // aExcLines = Ultimas linhas a desconsiderar na apresentacao (totalizacao duplicada)
User Function GeraExcl(aCabec, aColun, aDados, aColsSoma, nExcLines, lAuto)
Local cDet
Local nCount := 0 // aColsSoma { 3, 5, 7 }
Local aSomas := Array(Len(aColsSoma)) // { 0, 0, 0 }
Private nHdl := 0
Private cArqDest := "C:\" + AllTrim(FunName()) + ".CSV"
Private nTotReg	:= 0
Private aRetTela := {}
Private lProsiga := .T.
Private cCRLF := Chr(13) + Chr(10)
Private cArqDest
Default nExcLines := 0 // Padrao nao desconsidera linhas
Default lAuto := .F.
//ConOut("GeraEx01: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("GeraEx01" , "Iniciando...")
For w := 1 To Len(aColsSoma)
	aSomas[w] := 0
Next
If !lAuto
	//ProcRegua(Len(aDados) * 4)
EndIf
If lAuto .Or. GeraEx02() // Funcao de apontamento do arquivo retorna .T. (OK, prossegue...)
	If lAuto
		nHdl := fCreate(cArqDest) // Cria arquivo txt
	EndIf
	// Cabecalho
	If ValType(aCabec) == "A" // { { "COLUNA 1", "COLUNA 2", "COLUNA 3" }, { "COLUNA 1", "COLUNA 2", "COLUNA 3" } }
		For w := 1 To Len(aCabec)
			cDet := ""
			For x := 1 To Len(aCabec[w])
				cDet += aCabec[w,x] + ";"
			Next
			cDet += cCRLF
			fWrite(nHdl,cDet,Len(cDet))
		Next
		cDet := cCRLF
		fWrite(nHdl,cDet,Len(cDet)) // Pula linha
	EndIf
	// Objeto (colunas)
	If ValType(aColun) == "A"
		cDet := ""
		For w := 1 To Len(aColun)
			If ValType(aColun[w]) == "C"
				cDet += aColun[w] + ";"
			Else
				cDet += transform(aColun[w],"@E 9999999") + ";"
			EndIf
		Next
		cDet += cCRLF
		fWrite(nHdl,cDet,Len(cDet))
	EndIf
	// Dados (informacoes)
	If ValType(aDados) == "A"
		cDet := ""
		For w := 1 To Len(aDados)
			For k := 1 To 4
				//IncProc("Imprimindo... " + {"/","-","\","|"}[k])
			Next
			If nExcLines == 0 .Or. (Len(aDados) - w + 1) > nExcLines // 50 - 49 = 1 > 2
				cDet := ""
				For x := 1 To Len(aDados[w])
					If ValType(aDados[w,x]) == "C"
						cDet += aDados[w,x] + ";"
					Else
						cDet += Transform(aDados[w,x],"@E 999999.99") + ";"
					EndIf
				Next
				// aColsSoma { 3, 5, 7 }
				// { 0, 0, 0 }                            T
				// Soma das colunas
				For s := 1 To Len(aColsSoma)
					aSomas[s] += Val(AllTrim(StrTran(StrTran(aDados[w,aColsSoma[s]],".",""),",",".")))
				Next
				cDet += cCRLF
				fWrite(nHdl,cDet,Len(cDet))
			EndIf
			nCount++ // Soma de registros
		Next
	EndIf // Totalizacoes (somadas)
	// Totalizacoes (somadas)
	If ValType(aDados) == "A" .And. Len(aDados) > 0 .And. ValType(aSomas) == "A" .And. Len(aSomas) > 0
		cDet := ""
		For w := 1 To Len(aDados[1])
			nPos := ASCan(aColsSoma, {|y|, y == w }) // Coluna em questao eh de totalizacao
			If nPos > 0 // Coluna totalizavel
				cDet += TransForm(aSomas[nPos],"@E 999,999,999.99")
			EndIf
			cDet += ";"
		Next
		cDet += cCRLF
		fWrite(nHdl,cDet,Len(cDet))
	EndIf
	fClose(nHdl) // Finaliza processo e fecha arquivo txt
	If nCount == Len(aDados)
		If Select("TRB") > 0
			TRB->(DbCloseArea())
		EndIf
		If !lAuto // Nao eh automatico
			MsgInfo("Fim do processo!" + Chr(13) + Chr(10) + ;
			"Arquivo gerado com " + cValToChar(Len(aDados)) + " registros!" + Chr(13) + Chr(10) + ;
			"Arquivo destino: " + AllTrim(cArqDest),AllTrim(FunName()))
		EndIf
	Else
		If !lAuto // Nao eh automatico
			MsgAlert("Impressao concluida!" + Chr(13) + Chr(10) + ;
			"Arquivo gerado com " + cValToChar(Len(aDados)) + " registros!" + Chr(13) + Chr(10) + ;
			"ALERTA: Nao foram impressos todos os registros em tela!",AllTrim(FunName()))
		EndIf
	EndIf
EndIf
Return

Static Function GeraEx02()
aRetTela := fTelaParam() // Tela de apontamento de parametros
lProsiga := aRetTela[1] // Fragmentando resultado da variavel
cArqDest := aRetTela[2]
If !lProsiga
	MsgAlert("Erro: 01" + cCRLF + "Operação cancelada!",FunName())
	Return .F.
EndIf
If File(cArqDest) // Apaga arquivo caso exista
	If SimNao("Arquivo já existe, deseja substituir?") == "S"
		If fErase(cArqDest) = -1
			MsgAlert("Erro: 02" + cCRLF + "Operação cancelada!",FunName())
			Return .F.
		EndIf
	Else
		MsgAlert("Erro: 03" + cCRLF + "Operação cancelada!",FunName())
		Return .F.
	EndIf
EndIf
nHdl := fCreate(cArqDest) // Cria arquivo txt
Return .T.

Static Function fTelaParam()
Local oDlg
Local lRet := .T.
Local nOpca := 0
Local cDest := Space(300)
Local cArqu := Space(300)
Local bOk := {||nOpca:=1,oDlg:End()}
Local bCancel := {||nOpca:=2,oDlg:End()}
DEFINE MSDIALOG oDlg From 000,000 TO 130,400 Title OemToAnsi("Gera Excel (" + AllTrim(FunName()) + ")") Pixel
@035,005 Say OemToAnsi("Caminho destino:") Pixel
@048,005 Say OemToAnsi("Nome do arquivo:") Pixel
@034,050 Get cDest	Size 130,8 Picture "@!" Pixel When .F.
@047,050 Get cArqu	Size 147,8 Picture "@!" Pixel When .T. Valid fTrataFile(@cArqu,@cDest)
@034,185 Button oBtn2 Prompt OemToAnsi("...") Size 10,10 Pixel of oDlg Action fBscDir(.T.,@cDest,@cArqu)
ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
If nOpca == 1
	If lRet .And. (Empty(cDest) .Or. Empty(cArqu)) // Se o arquivo nao for encontrado, sair da rotina.
		MsgAlert("Caminho ou nome do arquivo de destino não informado!",FunName())
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf
Return { lRet, cDest }

Static Function fTrataFile(cAquivo, cCaminho)
Local cDrive	:= ""
Local cDir		:= ""
Local cFile		:= ""
Local cExten	:= ""
If Empty(cCaminho)
	cCaminho := "C:"
EndIf
If Empty(cAquivo)
	cAquivo := FunName()
EndIf
cAquivo := AllTrim(cAquivo)
If SubStr(cAquivo,Len(cAquivo)-3,4) != ".CSV"
	cAquivo := cAquivo+".CSV"
EndIf
cAquivo := Padr(cAquivo,300)
If !Empty(cCaminho)
	cCaminho := AllTrim(cCaminho)
	If ".CSV" $ cCaminho
		SplitPath( cCaminho, @cDrive, @cDir, @cFile, @cExten )
		cCaminho := cDrive+cDir
		MsDocRmvBar(@cCaminho)
	Else
		cCaminho := AllTrim(cCaminho)
	EndIf
	cCaminho := Padr(cCaminho+"\"+cAquivo,300)
EndIf
Return

Static Function fBscDir(lDir,cDirArq,cAquivo)
Local cTipo 	:= "Documentos de texto | *.CSV |"
Local cTitulo	:= "Dialogo de Selecao de Arquivos"
Local cDirIni	:= ""
Local cDrive	:= ""
Local cRet		:= ""
Local cDir		:= ""
Local cFile		:= ""
Local cExten	:= ""
Local cGetFile	:= ""
If lDir
	cGetFile := cGetFile(cTipo,cTitulo,,cDirIni,,GETF_RETDIRECTORY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
Else
	cGetFile := cGetFile(cTipo,cTitulo,,cDirIni,.F.,GETF_ONLYSERVER+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY)
EndIf
MsDocRmvBar(@cGetFile) // Retira a ultima barra invertida se houver
SplitPath( cGetFile, @cDrive, @cDir, @cFile, @cExten ) // Separa os componentes
If !Empty(cFile) .And. !lDir //Trata variavel de retorno
	cRet := cGetFile
EndIf
If lDir // Trata variavel de retorno
	fTrataFile(@cAquivo,"")
	If !Empty(cAquivo)
		cRet := cGetFile + "\" + cAquivo
	Else
		cRet := cGetFile
	EndIf
EndIf
cDirArq := cRet
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ NEXTSA2 ºAutor  ³Jonathan Schmidt Alvesº Data ³ 09/11/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para o codigo do fornecedor SA2       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Configuracao SX3:                                          º±±
±±º          ³ Campo: A2_COD                                              º±±
±±º          ³ Inicializador Padrao: u_NEXTSA2()                          º±±
±±º          ³ Validacao anterior: GetSXENum("SA2")                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function NEXTSA2()
Local aAreaSA2 := SA2->(GetArea())
Local _cFilSA2 := xFilial("SA2")
Local cCod := ""
If ExistBlock("NUMERICO") // Funcao do fonte MA020ROT.PRW
	DbSelectArea("SA2")
	DbSetOrder(1) // A2_FILIAL + A2_COD + A2_LOJA
	SA2->(DbSeek(_cFilSA2 + "ZZZZZZZZ")) // SA2->(DbGoBottom())
	While SA2->(!BOF())
		If SA2->A2_FILIAL == _cFilSA2 .And. u_Numerico(SA2->A2_COD)
			cCod := SA2->A2_COD
			Exit
		EndIf
		SA2->(DbSkip(-1))
	End
	cCod := Soma1(cCod)
Else
	MsgStop("Funcao 'NUMERICO()' nao localizada!" + Chr(13) + Chr(10) + "Contate o suporte Microsiga","NEXTSA2")
EndIf
RestArea(aAreaSA2)
Return cCod

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ NEXTSA1 ºAutor  ³Jonathan Schmidt Alvesº Data ³ 09/11/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador padrao para o codigo do cliente SA1          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Configuracao SX3:                                          º±±
±±º          ³ Campo: A1_COD                                              º±±
±±º          ³ Inicializador Padrao: u_NEXTSA1()                          º±±
±±º          ³ Substituida chamada padrao:  A030INICPD()                  º±±
±±º          ³ Iif(ExistBlock("NEXTSA1"), u_NEXTSA1(), A030INICPD() )     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function NEXTSA1()
Local aAreaSA1 := SA1->(GetArea())
Local _cFilSA1 := xFilial("SA2")
Local cCod := ""
If ExistBlock("NUMERICO")
	DbSelectArea("SA1")
	DbSetOrder(1) // A1_FILIAL + A1_COD + A1_LOJA
	SA1->(DbSeek(_cFilSA1 + "ZZZZZZZZ")) // SA1->(DbGoBottom())
	While SA1->(!BOF())
		If SA1->A1_FILIAL == _cFilSA1 .And. u_Numerico(SA1->A1_COD) // .And. SA1->A1_COD < "2012  " // Excecao para cod invalidos que apareceram em ??/10/2012 (Jonathan)
			cCod := SA1->A1_COD
			Exit
		EndIf
		SA1->(DbSkip(-1))
	End
	cCod := Soma1(cCod)
Else
	MsgStop("Funcao 'NUMERICO' nao compilada!" + Chr(13) + Chr(10) + "Contate o suporte Microsiga","NEXTSA1")
EndIf
RestArea(aAreaSA1)
Return cCod

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ VLDCGC  ºAutor  ³Jonathan Schmidt Alvesº Data ³09/11/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validacao do CPF/CNPJ e tambem chamada na      º±±
±±º          ³ validacao do NOME, tanto do Cliente ou Fornecedor.         º±±
±±º          ³                                                            º±±
±±º          ³ Os objetivos sao:                                          º±±
±±º          ³ 1) Verificar se ja existe algum CPF/CNPJ repetido no       º±±
±±º          ³ cadastro de fornecedores/clientes evitando duplicados.     º±±
±±º          ³                                                            º±±
±±º          ³ 2) Amarrar codigos com chave de CNPJ (8 digitos) iguais.   º±±
±±º          ³ Caso exista um outro CNPJ com 8 digitos, localizamos o     º±±
±±º          ³ codigo e incrementamos para a proxima loja.                º±±
±±º          ³                                                            º±±
±±º          ³ 3) Localizar 1fornecedores/clientes estrangeiros que nao   º±±
±±º          ³ tem CNPJ ou que tem CNPJ preenchido com "00000000000000"   º±±
±±º          ³ para obtencao do codigo de cliente/fornecedor ja existente º±±
±±º          ³ aglutinando tambem codigos com esta inteligencia, mantendo º±±
±±º          ³ tambem os codigos de Itens Contabeis (CTD) que sao do      º±±
±±º          ³ mesmo grupo juntos.                                        º±±
±±º          ³                                                            º±±
±±º          ³ O objetivo geral da funcao eh manter cadastros importantes º±±
±±º          ³ de Clientes (SA1) e Fornecedores (SA2) mais consistentes   º±±
±±º          ³ refletindo nos cadastros de Itens Contabeis (CTD)          º±±
±±º          ³                                                            º±±
±±º          ³ Exemplos:                                                  º±±
±±º          ³ 000076 01 AKG NORTH AMERICAN OPERATIONS                    º±±
±±º          ³ 000076 02 AKG NORTH AMERICAN OPERATIONS                    º±±
±±º          ³ 000076 03 AKG NORTH AMERICAN OPERATIONS                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Configuracao SX3: (Cadastro de Fornecedores)               º±±
±±º          ³                                                            º±±
±±º          ³ Campo: A2_CGC                                              º±±
±±º          ³ Vld Usuario: u_VLDCGC("MATA020")                           º±±
±±º          ³ Iif(ExistBlock("VLDCGC"), u_VLDCGC("MATA020"), .T.)        º±±
±±º          ³                                                            º±±
±±º          ³ Campo: A2_NOME                                             º±±
±±º          ³ Validacao Usuario: Texto() .And. u_VLDCGC("MATA020")       º±±
±±º          ³ Texto() .And.                                              º±±
±±º          ³ Iif(ExistBlock("VLDCGC"), u_VLDCGC("MATA020"), .T.)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Configuracao SX3: (Cadastro de Clientes)                   º±±
±±º          ³                                                            º±±
±±º          ³ Campo: A1_CGC                                              º±±
±±º          ³ Validacao Usuario: u_VLDCGC("MATA030")                     º±±
±±º          ³ Iif(ExistBlock("VLDCGC"), u_VLDCGC("MATA030"), .T.)        º±±
±±º          ³                                                            º±±
±±º          ³ Campo: A1_NOME                                             º±±
±±º          ³ Validacao Usuario: Texto() .And. u_VLDCGC("MATA030")       º±±
±±º          ³ Texto() .And.                                              º±±
±±º          ³ Iif(ExistBlock("VLDCGC"), u_VLDCGC("MATA030"), .T.)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function VLDCGC(cRotina)
Local lRet := .T.
Local cCodOri := ""
Local cLojOri := ""
Local cNomOri := ""
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local _cFilSA1 := xFilial("SA1")
Local _cFilSA2 := xFilial("SA2")
If Inclui // Apenas em uma inclusao
	If cRotina == "MATA020" // Cadastro de Fornecedores
		cCGCChk := M->A2_CGC
		If Empty(cCGCChk) .Or. cCGCChk == "00000000000000" // Se nao tem CNPJ ou CNPJ == "00000000000000" (Empresas estrangeiras)
			If !Empty(M->A2_NOME) // Tem Razao Social
				If MsgYesNo("Rastrear codigo de Fornecedor (A2_COD) e filial (A2_LOJA) conforme a" + Chr(13) + Chr(10) + ;
					"Razao Social: " + RTrim(M->A2_NOME) + " ?" + Chr(13) + Chr(10) + ;
					"Isso mantem os cadastros aglutinados com precisao!","VLDCGC")
					DbSelectArea("SA2")
					SA2->(DbSetOrder(2)) // A2_FILIAL + A2_NOME
					If SA2->(DbSeek(_cFilSA2 + M->A2_NOME))
						While SA2->(!EOF()) .And. SA2->A2_FILIAL + SA2->A2_NOME == _cFilSA2 + M->A2_NOME // Razao Social conforme
							cCodOri := SA2->A2_COD
							cLojOri := SA2->A2_LOJA
							cNomOri := SA2->A2_NOME
							SA2->(DbSkip())
						End
						MsgInfo("Fornecedor/Loja localizado no cadastro (SA2)!" + Chr(13) + Chr(10) + ;
						"Cod/Loja: " + cCodOri + "/" + cLojOri + Chr(13) + Chr(10) + ;
						"Razao Social: " + RTrim(cNomOri) + Chr(13) + Chr(10) + ;
						"Codigo e Loja serao carregados automaticamente!","VLDCGC")
						M->A2_COD := cCodOri			// Codigo localizado
						M->A2_LOJA := Soma1(cLojOri,2)	// Loja (proxima)
					EndIf
				EndIf
			EndIf
		Else // Avaliar o CNPJ preenchido entao...
			DbSelectArea("SA2")
			SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
			If SA2->(DbSeek(_cFilSA2 + cCGCChk)) // Verificando CGC repetido
				MsgStop("Este CPF/CNPJ ja esta cadastrado (SA2)!" + Chr(10) + Chr(13) + ;
				"Codigo/Loja: " + SA2->A2_COD + "/" + SA2->A2_LOJA + Chr(10) + Chr(13) + ;
				"Nome: " + SA2->A2_NOME,"VLDCGC")
				lRet := .F.
			ElseIf SA2->(DbSeek(_cFilSA2 + Left(cCGCChk,8)))
				While SA2->(!EOF()) .And. SA2->A2_FILIAL + Left(SA2->A2_CGC,8) == _cFilSA2 + Left(cCGCChk,8)
					cCodOri := SA2->A2_COD
					cLojOri := SA2->A2_LOJA
					cNomOri := SA2->A2_NOME
					SA2->(DbSkip())
				End
				MsgInfo("Fornecedor/Loja localizado no cadastro (SA2)!" + Chr(13) + Chr(10) + ;
				"Cod/Loja: " + cCodOri + "/" + cLojOri + Chr(13) + Chr(10) + ;
				"Razao Social: " + RTrim(cNomOri) + Chr(13) + Chr(10) + ;
				"Codigo e Loja serao carregados automaticamente!","VLDCGC")
				M->A2_COD := cCodOri
				M->A2_LOJA := Soma1(cLojOri)
			EndIf
		EndIf
		RestArea(aAreaSA2)
	Else // Cadastro de Clientes
		cCGCChk := M->A1_CGC
		If Empty(cCGCChk) .Or. cCGCChk == "00000000000000" // Se nao tem CNPJ ou CNPJ == "00000000000000" (Empresas estrangeiras)
			If !Empty(M->A1_NOME) // Tem Razao Social
				If MsgYesNo("Rastrear codigo de Cliente (A1_COD) e filial (A1_LOJA) conforme a" + Chr(13) + Chr(10) + ;
					"Razao Social: " + RTrim(M->A1_NOME) + " ?" + Chr(13) + Chr(10) + ;
					"Isso mantem os cadastros aglutinados com precisao!","VLDCGC")
					DbSelectArea("SA1")
					SA1->(DbSetOrder(2)) // A1_FILIAL + A1_NOME
					If SA1->(DbSeek(_cFilSA1 + M->A1_NOME))
						While SA1->(!EOF()) .And. SA1->A1_FILIAL + SA1->A1_NOME == _cFilSA1 + M->A1_NOME // Razao Social conforme
							cCodOri := SA1->A1_COD
							cLojOri := SA1->A1_LOJA
							cNomOri := SA1->A1_NOME
							SA1->(DbSkip())
						End
						MsgInfo("Cliente/Loja localizado no cadastro (SA1)!" + Chr(13) + Chr(10) + ;
						"Cod/Loja: " + cCodOri + "/" + cLojOri + Chr(13) + Chr(10) + ;
						"Razao Social: " + RTrim(cNomOri) + Chr(13) + Chr(10) + ;
						"Codigo e Loja serao carregados automaticamente!","VLDCGC")
						M->A1_COD := cCodOri			// Codigo localizado
						M->A1_LOJA := Soma1(cLojOri,2)	// Loja (proxima)
					EndIf
				EndIf
			EndIf
		Else // Avaliar CNPJ preenchido entao...
			DbSelectArea("SA1")
			SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
			If SA1->(DbSeek(_cFilSA1 + cCGCChk)) // Verificando CGC repetido
				MsgStop("Este CPF/CNPJ ja esta cadastrado (SA1)!" + Chr(10) + Chr(13) + ;
				"Codigo/Loja: " + SA1->A1_COD + "/" + SA1->A1_LOJA + Chr(10) + Chr(13) + ;
				"Nome: " + SA1->A1_NOME,"VLDCGC")
				lRet := .F.
			ElseIf SA1->(DbSeek(_cFilSA1 + Left(cCGCChk,8)))
				While SA1->(!EOF()) .And. SA1->A1_FILIAL + Left(SA1->A1_CGC,8) == _cFilSA1 + Left(cCGCChk,8)
					cCodOri := SA1->A1_COD
					cLojOri := SA1->A1_LOJA
					cNomOri := SA1->A1_NOME
					SA1->(DbSkip())
				End
				M->A1_COD := cCodOri
				M->A1_LOJA := Soma1(cLojOri)
			EndIf
		EndIf
		RestArea(aAreaSA1)
	EndIf
EndIf
Return lRet

User Function Numerico(cTexto)
cTexto := AllTrim(cTexto)
For nE := 1 To Len(cTexto)
	If !(SubStr(cTexto,nE,1) $ "0123456789")
		Return .F.
	EndIf
Next
Return .T.
