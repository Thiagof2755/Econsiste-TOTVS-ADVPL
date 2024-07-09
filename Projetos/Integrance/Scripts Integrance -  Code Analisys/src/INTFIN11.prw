#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ INTFIN11 บAutor ณ Jonathan Schmidt Alves บDataณ 25/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de carregamento dos extratos.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function INTFIN11() // Tela de apresentacao
Local cTitle := "IntFin11: Extrato Integrance"
Private _cFilSE2 := xFilial("SE2")
Private _cFilSA6 := xFilial("SA6")
Private _cFilSA2 := xFilial("SA2")
Private _cSqlSE2 := RetSqlName("SE2")
Private nClrC20 := RGB(199,199,199)	// Cinza Padrao Claro		*** Panel Top e Cores GetDados 03 (apagado)
Private nClrC21 := RGB(161,161,161)	// Cinza Padrao Claro		*** Panel Top e Cores GetDados 03 (apagado)
Private nClrC22 := RGB(217,204,117) // Cinza Amarelado			*** Cores GetDados 03
Private nClrC23 := RGB(234,167,138) // Cinza Avermelhado		*** Panel Bottom
Private nClrCV1 := RGB(165,250,160) // Verde Claro				***
Private nClrCV2 := RGB(026,207,005) // Verde Escuro				***
Private nClrCE2 := RGB(255,111,111) // Vermelho					*** Get2 Titulos a Pagar
Private nClrCA1 := RGB(249,255,164) // Amarelo Claro			***
Private nClrCA2 := RGB(185,185,000) // Amarelo Escuro			***
Private nClrCV4 := RGB(132,155,251) // Azul Claro				*** Get2 Pedidos de Venda
Private nIniLin := 4 // Linha inicial
Private aDados := {}
Private aFound := {}
Private aRelacio := {}
Private aMolds01 := {}
Private aMolds02 := {}
//             {           01,           02,              03,        04,  05,  06,                  07,                   08,                                                                       09,                     10,                                    11 }
//             {        Ordem,   Nome Field,    Titulo Field, Tipo Dado, Tam, Dec,             Picture,               Origem,                                                            Options Field, Condicao Processamento, Processamento anterior/posicionamento }
aAdd(aMolds01, {           01, "FIN_DATMOV",      "[ Data ]",       "D",  08,  00,                  "",        "CtoD(xDado)",                                                                       "",        "AllwaysTrue()",                                    "" })
aAdd(aMolds01, {           02, "FIN_HISTOR", "[ Historico ]",       "C",  40,  00,                  "",     "AllTrim(xDado)",                                                                       "",        "AllwaysTrue()",                                    "" })
aAdd(aMolds01, {           03, "FIN_DOCUME", "[ Documento ]",       "C",  40,  00,                  "",     "AllTrim(xDado)",                                                                       "",        "AllwaysTrue()",                                    "" })
aAdd(aMolds01, {           04, "FIN_VLRMOV",     "[ Valor ]",       "N",  12,  02, "@E 999,999,999.99", "&(aRelacio[w2,05])",                                                                       "",        "AllwaysTrue()",                                    "" })
aAdd(aMolds01, {           05, "FIN_SLDFIM",     "[ Saldo ]",       "N",  12,  02, "@E 999,999,999.99", "&(aRelacio[w2,05])",                                                                       "",        "AllwaysTrue()",                                    "" })
//             {    01,           02,           03,        04,  05,  06,                  07,                                 08,                                                                    09,                     10,                                    11 }
//             { Ordem,   Nome Field, Titulo Field, Tipo Dado, Tam, Dec,             Picture,                             Origem,                                                         Options Field, Condicao Processamento, Processamento anterior/posicionamento }
aAdd(aMolds02, {    01, "FIN_PREFIX",    "Prefixo",       "C",  03,  00,                  "",                  "SE2->E2_PREFIXO",                                                                    "",        "aFound[w] > 0",          "SE2->(DbGoto( aFound[w] ))" })
aAdd(aMolds02, {    02, "FIN_NUMTIT",     "Numero",       "C",  09,  00,                  "",                      "SE2->E2_NUM",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    03, "FIN_PARCEL",    "Parcela",       "C",  02,  00,                  "",                  "SE2->E2_PARCELA",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    04, "FIN_TIPTIT",       "Tipo",       "C",  03,  00,                  "",                     "SE2->E2_TIPO",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    05, "FIN_CODFOR",     "CodFor",       "C",  06,  00,                  "",                  "SE2->E2_FORNECE",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    06, "FIN_LOJFOR",       "Loja",       "C",  02,  00,                  "",                     "SE2->E2_LOJA",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    07, "FIN_NOMFOR", "Fornecedor",       "C",  40,  00,                  "",                   "SE2->E2_NOMFOR",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    08, "FIN_NOMSA2",  "Razao Soc",       "C",  40,  00,                  "",                     "SA2->A2_NOME",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    09, "FIN_VLRTIT",      "Valor",       "N",  12,  02, "@E 999,999,999.99",                    "SE2->E2_VALOR",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    10, "FIN_SLDTIT",      "Saldo",       "N",  12,  02, "@E 999,999,999.99",                    "SE2->E2_SALDO",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    11, "FIN_EMISSA",    "Emissao",       "D",  08,  00,                  "",                  "SE2->E2_EMISSAO",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    12, "FIN_VENCTO",     "Vencto",       "D",  08,  00,                  "",                   "SE2->E2_VENCTO",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    13, "FIN_VENCREA",  "VencReal",       "D",  08,  00,                  "",                  "SE2->E2_VENCREA",                                                                    "",        "aFound[w] > 0",                                    "" })
aAdd(aMolds02, {    14, "FIN_STAPRC",     "StaPrc",       "C",  02,  00,                  "", "StrZero(Val(Left(cStaReg,1)),02)",    "02=Nao Processar;03=Processar;04=Nao Localizado;05=Ja Processado",        "AllwaysTrue()",                                    "" })
aAdd(aMolds02, {    15, "FIN_STAREG",     "StaReg",       "C", 100,  00,                  "",                          "cStaReg",                                                                    "",        "AllwaysTrue()",                                    "" })
Private oDlg11
Private oGetD1
Private aHdr01 := {}
Private aFldsAlt01 := {}
Private aGetMotBxa := ReadMotBx()
// Banco
Private oSayCodBco
Private oGetCodBco
Private cGetCodBco := Space(TamSX3("A6_COD")[01])
// Agencia
Private oSayCodAge
Private oGetCodAge
Private cGetCodAge := Space(TamSX3("A6_AGENCIA")[01])
// Conta
Private oSayNumCon
Private oGetNumCon
Private cGetNumCon := Space(TamSX3("A6_NUMCON")[01])
// Nome Banco
Private oSayNomBco
Private oGetNomBco
Private cGetNomBco := Space(TamSX3("A6_NOME")[01])
// Motivo Baixa
Private oSayMotBxa
Private oGetMotBxa
Private cGetMotBxa := Space(03)
SetKey(VK_F8,{|| MarkRegs() }) // Marcar/Desmarcar processamentos
SetKey(VK_F11,{|| __QUIT() }) // Fecha rapido
SetKey(VK_F12,{|a,b| AcessaPerg("FIN080",.T.)})
DEFINE MSDIALOG oDlg11 FROM 050,165 TO 742,1443 TITLE cTitle Pixel
// Barras Laterais
@000,-01 BitMap Size 004,500 File "BLatIntegrance.jpg" Of oDlg11 Pixel Stretch
@000,637 BitMap Size 004,500 File "BLatIntegrance.jpg" Of oDlg11 Pixel Stretch
// Cabecalho
@000,000 BitMap Size 500,003 File "BSupIntegrance.jpg" Of oDlg11 Pixel Stretch Noborder
@000,251 BitMap Size 500,003 File "BSupIntegrance.jpg" Of oDlg11 Pixel Stretch Noborder
@000,490 BitMap Size 500,003 File "BSupIntegrance.jpg" Of oDlg11 Pixel Stretch Noborder
// Panel
oPnlTop	:= TPanel():New(002,002,,oDlg11,,,,,nClrC21,635,053,.F.,.F.)
oPnlMid	:= TPanel():New(055,002,,oDlg11,,,,,nClrC23,635,280,.F.,.F.)
oPnlBot	:= TPanel():New(283,002,,oDlg11,,,,,nClrC22,635,060,.F.,.F.)
// Logo Integrance
@001,494 BitMap Size 260,050 File "LogoIntegrance.jpg" Of oPnlTop Pixel Stretch Noborder
@006,006 SAY	oSayCodBco PROMPT "Banco:" SIZE 040,010 OF oPnlTop PIXEL
@004,030 MSGET	oGetCodBco VAR cGetCodBco SIZE 025,008 OF oPnlTop PICTURE "@!" F3 "SA6" PIXEL HASBUTTON Valid VldBco01()
@006,072 SAY	oSayCodAge PROMPT "Agencia:" SIZE 040,010 OF oPnlTop PIXEL
@004,100 MSGET	oGetCodAge VAR cGetCodAge SIZE 030,008 OF oPnlTop PICTURE "@!" PIXEL READONLY
@006,142 SAY	oSayNumCon PROMPT "Conta:" SIZE 040,010 OF oPnlTop PIXEL
@004,165 MSGET	oGetNumCon VAR cGetNumCon SIZE 030,008 OF oPnlTop PICTURE "@!" PIXEL READONLY
@006,200 SAY	oSayNomBco PROMPT "Nome:" SIZE 040,010 OF oPnlTop PIXEL
@004,220 MSGET	oGetNomBco VAR cGetNomBco SIZE 080,008 OF oPnlTop PICTURE "@!" PIXEL READONLY
@006,320 SAY	oSayMotBxa PROMPT "Motivo Baixa:" SIZE 040,010 OF oPnlTop PIXEL
@004,360 MSCOMBOBOX oGetMotBxa VAR cGetMotBxa ITEMS aGetMotBxa SIZE 105,011 OF oPnlTop Pixel Valid VldMot01()

// Carregar o DEB no motivo da baixa
If (nFind := ASCan(aGetMotBxa, {|x|, Left(x,03) == "DEB" })) > 0
	oGetMotBxa:nAt := nFind
EndIf

// Inativando objetos
aObjInac := { "oGetCodAge", "oGetNumCon", "oGetNomBco" }
aEVal(aObjInac, {|x|, &(x):lActive := .F. })
@032,505 BUTTON "Carregar Excel"	Size 047,012 Pixel Of oDlg11 Action(INTFIN21()) // Carregar Excel
@032,570 BUTTON "Processar"			Size 047,012 Pixel Of oDlg11 Action(INTFIN31()) // Processar
@044,505 SAY	oSayHlpF8	PROMPT "F8 = Marca/Desmarca" SIZE 120,010 OF oPnlTop PIXEL
@044,575 SAY	oSayHlpF12	PROMPT "F12 = Parametros Baixa" SIZE 120,010 OF oPnlTop PIXEL
aHdr01 := LoadHder() // Criacao do Header
For w := 1 To Len(aHdr01)
	&("nP01" + SubStr(aHdr01[w,2],5,6)) := w
Next
aCls01 := ClearCls(aHdr01) // Montagem em branco do aCols
aFldsAlt01 := {}
oGetD1 := MsNewGetDados():New(001,001,203,635,Nil,"AllwaysTrue()", "AllwaysTrue()" ,,aFldsAlt01,,,,,"AllwaysTrue()",oPnlMid,@aHdr01,@aCls01)
oGetD1:oBrowse:lVisible := .F.
oGetD1:oBrowse:lHScroll := .F.
oGetD1:oBrowse:SetBlkBackColor({|| GetD1Clr(oGetD1:aCols, oGetD1:nAt, aHdr01) })
// oGetD1:oBrowse:bChange := {|| ShowDets() }
// Rodape
@346,002 BitMap Size 500,008 File "BSupIQA.jpg" Of oDlg11 Pixel Stretch Noborder
@346,251 BitMap Size 500,008 File "BSupIQA.jpg" Of oDlg11 Pixel Stretch Noborder
@346,490 BitMap Size 500,008 File "BSupIQA.jpg" Of oDlg11 Pixel Stretch Noborder
ACTIVATE MSDIALOG oDlg11 CENTERED
SetKey(VK_F8,{|| Nil })				// Desativo atalho marcar registros processar/nao processar
SetKey(VK_F11,	{|| u_INTFIN11() }) // Extrato Carla
SetKey(VK_F12,{|| Nil })			// Desativo atalho parametros F12 Baixa Pagar (FINA080)
Return

Static Function GetD1Clr(aCols, nLine, aHdrs) // Cores GetDados 01
Local nClr := nClrC21 // Cinza Padrao
If !Empty(aCols[nLine, nP01NumTit]) // Registro localizado
	If Left(aCols[nLine, nP01StaReg],1) == "5" // Ja baixado
		nClr := nClrCV4		// Azul Claro
	ElseIf Left(aCols[nLine, nP01StaReg],3) >= "310" // Precisao '10' ou maior
		If aCols[nLine, nP01StaPrc] == "03" // "03=Processar
			nClr := nClrCV2 // Verde Escuro
		Else
			nClr := nClrCV1 // Verde Claro
		EndIf
	ElseIf Left(aCols[nLine, nP01StaReg],3) > "300" .And. Left(aCols[nLine, nP01StaReg],3) <= "309" // Precisao 'intermediaria'
		If aCols[nLine, nP01StaPrc] == "03" // "03=Processar
			nClr := nClrCA2 // Amarelo Escuro
		Else
			nClr := nClrCA1 // Amarelo Claro
		EndIf
	EndIf
ElseIf Left(aCols[nLine, nP01StaReg],1) == "4" // Nao Localizado
	If Left(aCols[nLine, nP01StaReg],3) $ "401/403/" // Nao localizado pq nao tem valor (receber) ou nao tem documento (tarifa/etc na Planilha 03=Totvs)
		nClr := nClrC20 	// Cinza padrao
	Else
		nClr := nClrCE2 	// Vermelho
	EndIf
EndIf
Return nClr

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ INTFIN21 บAutor ณ Jonathan Schmidt Alves บDataณ 25/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que recebe a matriz de dados para localizacoes.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Estrutura da matriz:                                       บฑฑ
ฑฑบ          ณ [01] Data da baixa/movimento                               บฑฑ
ฑฑบ          ณ [02] Historico                                             บฑฑ
ฑฑบ          ณ [03] Numero documento/identificacao                        บฑฑ
ฑฑบ          ณ [04] Valor da baixa/movimento                              บฑฑ
ฑฑบ          ณ [05] Saldo                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function INTFIN21()
Local nVlrProc := 0		// Valor do processamento
Local aDocsInf := {}	// Matriz com documento/serie
Local nRecsSE2 := 0
DbSelectArea("SE2")
SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
Private lOk := .T.
Private cArquivo := ""
Private cDrive := ""
Private cDir := ""
Private cFile := ""
Private cExten := ""
If Empty(cArquivo)
	cArquivo := fAbrir() // "C:\TEMP\RETORNOCONCILIA_PAGAMENTO_1443725046558_MOD.CSV"
EndIf
If Empty(cArquivo)
	MsgStop("Arquivo nao informado!","INTFIN21")
	Return
ElseIf !File(cArquivo)
	MsgStop("Arquivo nao encontrado!" + Chr(13) + Chr(10) + ;
	cArquivo,"INTFIN21")
	Return
Else
	SplitPath(cArquivo, @cDrive, @cDir, @cFile, @cExten)
EndIf
nOpc := Aviso("Layout Extrato Excel","Informe o Layout do arquivo Excel!", { "1=Sicoob", "2=Itau", "3=Totvs" })

// Private aMolds01 := { { 01, "FIN_DATMOV", "[ Data ]", "D", 08, 00, "", "CtoD(xDado)" }, { 02, "FIN_HISTOR", "[ Historico ]", "C", 40, 00, "", "AllTrim(xDado)" },;
// { 03, "FIN_DOCUME", "[ Documento ]", "C", 40, 00, "", "AllTrim(xDado)" }, { 04, "FIN_VLRMOV", "[ Valor ]", "N", 12, 02, "@E 999,999,999.99", "&(aRelacio[w2,05])" },;
// { 05, "FIN_SLDFIM", "[ Saldo ]", "N", 12, 02, "@E 999,999,999.99", "&(aRelacio[w2,05])" } }

If nOpc == 1 // Sicoob Ex: "DATA;DOCUMENTO;HISTำRICO;VALOR"
	//            { Coluna Origem Excel, Coluna conforme aMolds01,      Titulo, Localiz, Tratamento dif propagado pro aMolds01, Linhas duplas }
	aRelacio := { {                  01,                       01, "Data"     ,     .F.,                                    "",           .F. },;
	{                                02,                       03, "Historico",     .T.,                                    "",           .T. },;
	{                                03,                       02, "Documento",     .F.,                                    "",           .F. },;
	{                                04,                       04, "Valor"    ,     .T., "Val(StrTran(StrTran(StrTran(StrTran(xDado,'R$',''),'.',''),',','.'),' ',''))", .F. },;
	{                                05,                       05, "Saldo"    ,     .F., "Val(StrTran(StrTran(StrTran(StrTran(xDado,'R$',''),'.',''),',','.'),' ',''))", .F. } }
ElseIf nOpc == 2 // Itau Ex: " ;DATA;LANวAMENTO;;DEBITO;CREDITO;SALDO R$;;"
	//            { Coluna Origem Excel, Coluna conforme aMolds01,      Titulo, Localiz, Tratamento dif propagado pro aMolds01, Linhas duplas }
	aRelacio := { {                  02,                       01, "Data"     ,     .F.,                                    "",           .F. },;
	{                                03,                       02, "Historico",     .F.,                                    "",           .T. },;
	{                                04,                       03, "Documento",     .T.,                                    "",           .F. },;
	{                                05,                       04, "Valor"    ,     .T., "Val(StrTran(StrTran(StrTran(xDado,'R$',''),',',''),' ',''))", .F. },;
	{                                06,                       05, "Saldo"    ,     .F., "Val(StrTran(StrTran(StrTran(xDado,'R$',''),',',''),' ',''))", .F. } }
ElseIf nOpc == 3 // Santander (Extrato Totvs) Data Cr้dito; Num. Cheque; Opera็ใo; Documento; Pessoa; Categoria; Entradas; Saidas; Saldo
	nIniLin := 2 // Santander Petrofer inicia da linha 2
	//            { Coluna Origem Excel, Coluna conforme aMolds01,      Titulo, Localiz, Tratamento dif propagado pro aMolds01, Linhas duplas }
	aRelacio := { {                  01,                       01, "Data"     ,     .F.,                                    "",           .F. },;
	{                                05,                       02, "Historico",     .F.,                                    "",           .T. },;
	{                                04,                       03, "Documento",     .T.,                                    "",           .F. },;
	{                                08,                       04, "Valor"    ,     .T., "Val(StrTran(StrTran(StrTran(StrTran(xDado,'R$',''),'.',''),',','.'),' ',''))" /*"Val(StrTran(StrTran(StrTran(StrTran(xDado,'R$',''),'.',''),',','.'),' ',''))"*/ /*"Val(StrTran(StrTran(StrTran(xDado,'R$',''),',',''),' ',''))"*/, .F. },;
	{                                09,                       05, "Saldo"    ,     .F., "Val(StrTran(StrTran(StrTran(StrTran(xDado,'R$',''),'.',''),',','.'),' ',''))" /*"Val(StrTran(StrTran(StrTran(xDado,'R$',''),',',''),' ',''))"*/, .F. } }
EndIf
aSort(aRelacio,,, {|x,y|, x[02] < y[02] }) // Ordenar o aRelacio na ordem das colunas do aMolds01
u_AskYesNo(1200,"Carregando","Carregando dados do arquivo...",cArquivo,"","","","NOTE",.T.,.F.,{|| lOk := LoadData(cArquivo,nIniLin) }) // Leitura dos dados no arquivo .CSV
If !lOk // Invalido
	MsgStop("Carregamento do arquivo com resultado invalido!","INTFIN21")
	Return
ElseIf Len(aDados) == 0
	MsgStop("Nenhuma linha foi carregada do arquivo!","INTFIN21")
	Return
EndIf
aCls01 := ClearCls(aHdr01) // Montagem em branco do aCols
u_AskYesNo(1200,"Processando","Processando dados do arquivo...",cArquivo,"","","","NOTE",.T.,.F.,{|| lOk := ProcData(aDados) }) // Leitura dos dados no arquivo .CSV
If !lOk
	MsgStop("Processamento do arquivo com resultado invalido!","INTFIN21")
	Return
Else // Sucesso
	oGetD1:oBrowse:lVisible := Len(aCls01) > 0
	If Len(aCls01) == 0
		aCls01 := ClearCls(aHdr01) // Montagem em branco do aCols
	EndIf
	oGetD1:aCols := aClone(aCls01)
	oGetD1:Refresh()
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LoadData บAutor ณ Jonathan Schmidt Alves บDataณ 15/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carregamento de dados da planilha.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LoadData(cArquivo, nIniLin) // , aMolds)
Local lRet := .T.
Local nLastUpdate := Seconds()
Local nLayPrc := 0
Local cLastLay := ""
Local nLenBuf := 0
Local cBuffer := ""
Local nLenCols := 4 // Local nLenMolds := Len(aMolds)
FT_FUse(cArquivo)
FT_FGOTOP()
nLines := FT_FLASTREC()
cLines := cValToChar(nLines)
aDado := {} // Dados de cada linha
aDados := {} // Detalhes de Dados
nLine := 0 // Linha inicial
// Posicionando na linha inicial
For w := 1 To nIniLin -1
	FT_FSkip()
	nLine++
	nCurrent++
Next
_oMeter:nTotal := nLines
While (!FT_FEOF()) .And. lRet
	nCurrent++
	nLine++
	If (Seconds() - nLastUpdate) > 2 // Se passou 2 segundos desde a ๚ltima atualiza็ใo da tela
		u_AtuAsk09(nCurrent,"Lendo linha... " + cValToChar(nLine) + " / " + cLines,"","","",80)
		nLastUpdate := Seconds()
	EndIf
	cBuffer := FT_FREADLN()
	While ";;" $ cBuffer
		cBuffer := StrTran(cBuffer,";;","; ;")
	End
	aDado := StrToKarr(cBuffer,";")
	If Len(aDado) >= nLenCols .And. !Empty(aDado[ nP01DatMov ]) // Minimo de colunas
		aAdd(aDados, aClone(aDado)) // Inclusao do elemento
	Else // Colunas incompletas
		// Trecho Linha dupla (os historicos no Excel/CSV as vezes tem 2 linhas, esse trecho identifica e trata isso)
		For z := 1 To Len(aDado) // Rodo nas colunas complementares carregadas
			If !Empty(aDado[z])
				nColExcel := ASCan(aRelacio, {|x|, x[01] == z })
				If aRelacio[nColExcel,06] // .T.=Coluna Excel com possibilidade de linha dupla
					If nColExcel > 0 // Coluna Excel
						nColMolds := aRelacio[nColExcel,02] // Coluna aMolds01
						If nColMolds > 0 // Coluna no aMolds01
							aDados[ Len(aDados), nColMolds ] += " " + aDado[z] // Inclui linha complementar
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		// Fim do trecho linha dupla
	EndIf
	FT_FSkip()
End
FT_FUse() // Fecha o arquivo .CSV
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ProcData บAutor ณ Jonathan Schmidt Alves บDataณ 15/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento dos dados carregados da planilha.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ProcData()
Local lRet := .T.
Private aCompars := {}
Private aChecks := {}
aAdd(aChecks, { "aCompars[w4,01] <= _aCls01[ nP01DatMov ]",						.F., 02 }) // Emissao de acordo
aAdd(aChecks, { "aCompars[w4,02] <= aCompars[w4,02]",							.F., 02 }) // Vencimento de acordo (nao vencido)
aAdd(aChecks, { "aCompars[w4,03] <= aCompars[w4,03]",							.F., 01 }) // Vencimento Real de acordo (nao vencido)
aAdd(aChecks, { "aCompars[w4,04] == aCompars[w4,05]",							.F., 01 }) // Valor igual ao saldo (aberto)
aAdd(aChecks, { "AllTrim(Upper(aCompars[w4,06])) $ Upper(_aCls01[nP01Histor])", .F., 04 }) // Nome Reduzido do Fornecedor confere com historico
aAdd(aChecks, { "AllTrim(Upper(aCompars[w4,07])) $ Upper(_aCls01[nP01Histor])", .F., 04 }) // Razao Social do Fornecedor confere com historico
aCls01 := {}
aFound := {}
For w := 1 To Len(aDados) // Rodo nos registros
	_aCls01 := {}
	// Tratamento das colunas aMolds01 (Excel)
	For w2 := 1 To Len(aRelacio) // Rodo nos relacionamentos (colunas do Excel com o elemento do aMolds01)
		nColExcel := aRelacio[w2,01] // Coluna Origem Excel
		nColRelac := aRelacio[w2,02] // Coluna de relacionamento
		If nColRelac > 0 // Existe coluna de relacionamento no aMolds01
			nColMolds := ASCan(aMolds01, {|x|, x[01] == nColRelac }) // Encontro a coluna com os tratamentos no aMolds01
			If nColMolds > 0 // Encontrada a coluna de relacionamento
				If nColExcel <= Len(aDados[w]) // A coluna esta no Excel
					xDado := aDados[w,nColExcel] // Origem da informacao no aDados
					If !Empty(aMolds01[nColMolds,08]) // Tem tratamento
						xDado := &( aMolds01[nColMolds,08] ) // Evaluate do tratamento em xDado
					EndIf
					aAdd(_aCls01, xDado)
				Else // Coluna nao esta no Excel
					If aMolds01[nColMolds,04] == "C"
						xDado := Space( aMolds02[w2,05] )
					ElseIf aMolds01[nColMolds,04] == "D"
						xDado := CtoD("")
					ElseIf aMolds01[nColMolds,04] == "N"
						xDado := 0
					EndIf
					aAdd(_aCls01, xDado)
				EndIf
			EndIf
		EndIf
	Next
	cStaReg := IntFin13(_aCls01) // Localizacoes SE2
	// Trecho novo
	For w2 := 1 To Len(aMolds02)
		xDado := Nil
		If !Empty(aMolds02[w2,10]) // 10=Condicao para processamento
			If &(aMolds02[w2,10]) .And. !Empty(aMolds02[w2,08]) // 10=Condicao valida e tem 08=Origem
				If !Empty(aMolds02[w2,11]) // 11=Processamento anterior/posicionamento
					xProc := &(aMolds02[w2,11]) // Processo o posicionamento
				EndIf
				xDado := &(aMolds02[w2,08]) // Dado origem no SE2
			EndIf
		EndIf
		If ValType(xDado) == "U" // xDado nao foi carregado/Condicao nao preenchida
			If aMolds02[w2,04] == "C"
				xDado := Space(aMolds02[w2,05])
			ElseIf aMolds02[w2,04] == "D"
				xDado := CtoD("")
			ElseIf aMolds02[w2,04] == "N"
				xDado := 0
			EndIf
		EndIf
		aAdd(_aCls01, xDado)
	Next
	// Fim
	aAdd(_aCls01, .F.) // Nao apagado
	aAdd(aCls01, aClone(_aCls01))
Next
Return lRet

Static Function IntFin13() // Localizacoes
cStaReg := ""
nVlrProc := 0 // Valor para processamento
aDocsInf := {} // Matriz de dados do documento
If !Empty(_aCls01[nP01VlrMov]) // Valor existe
	nVlrProc := _aCls01[nP01VlrMov] // Valor do processamento (positivo/negativo)
	If nVlrProc > 0 // Valor identificado
		If nOpc <> 3 .Or. !Empty(StrTran(_aCls01[nP01Docume],"-","")) // Se nao for 3=Planilha Totvs ou se for mas tem o Documento
			// Pesquisa no SE2
			cQrySE2 := "SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_SALDO, R_E_C_N_O_ "
			cQrySE2 += "FROM " + _cSqlSE2 + " WHERE "
			cQrySE2 += "E2_FILIAL = '" + _cFilSE2 + "' AND "						// Empresa/Filial conforme
			cQrySE2 += "E2_VALOR = " + cValToChar(Abs(nVlrProc)) + " AND "			// Valor absoluto conforme
			cQrySE2 += "E2_EMISSAO <= '" + DtoS(_aCls01[nP01DatMov]) + "' AND "		// Emissao conforme
			cQrySE2 += "E2_TIPO <> 'PA ' AND "										// Nao processar adiantamentos
			If (nFind := ASCan(aRelacio, {|x|, "DOCUMENTO" $ Upper(x[03]) })) > 0 .And. aRelacio[ nFind, 04 ] // Like por Documento
				If !Empty(_aCls01[nP01Docume]) // Documento existe
					If nOpc == 3 // 3=Planilha Totvs
						aDocsInf := StrToKarr( RTrim(Left(_aCls01[nP01Docume],09)), "%")
					Else // Outras planilhas
						aDocsInf := StrToKarr( _aCls01[nP01Docume], " ")
					EndIf
					If Len(aDocsInf) > 0 // Dados do documento, etc
						cQrySE2 += Iif(Len(aDocsInf) > 1,"(","")
						For w2 := 1 To Len(aDocsInf)
							cQrySE2 += "E2_NUM LIKE '%" + AllTrim(aDocsInf[w2]) + "%'"
							If w2 < Len(aDocsInf)
								cQrySE2 += " OR "
							ElseIf w2 > 1 .And. w2 == Len(aDocsInf) // Ultimo
								cQrySE2 += ") "
							EndIf
						Next
						cQrySE2 += " AND "
					EndIf
				EndIf
			ElseIf (nFind := ASCan(aRelacio, {|x|, "HISTORICO" $ Upper(x[03]) })) > 0 .And. aRelacio[ nFind, 04 ] // Like por Documento // Like por Historico
				If !Empty(_aCls01[nP01Histor]) // Documento existe
					aDocsInf := StrToKarr( _aCls01[nP01Histor], " ")
					For w3 := Len(aDocsInf) To 1 Step -1
						If Val(aDocsInf[w3]) == 0 // Nao eh numero (nota/titulo/etc)
							aDel(aDocsInf,w3) // Removo elemento
							aSize(aDocsInf, Len(aDocsInf) - 1) // Reduzo matriz
						EndIf
					Next
					If Len(aDocsInf) > 0 // Dados do documento, etc
						cQrySE2 += Iif(Len(aDocsInf) > 1,"(","")
						For w2 := 1 To Len(aDocsInf)
							cQrySE2 += "E2_NUM LIKE '%" + AllTrim(aDocsInf[w2]) + "%'"
							If w2 < Len(aDocsInf)
								cQrySE2 += " OR "
							ElseIf w2 > 1 .And. w2 == Len(aDocsInf) // Ultimo
								cQrySE2 += ") "
							EndIf
						Next
						cQrySE2 += " AND "
					EndIf
				EndIf
			EndIf
			cQrySE2 += "D_E_L_E_T_ = ' '"											// Nao apagado
			If Select("QRYSE2") > 0
				QRYSE2->(DbCloseArea())
			EndIf
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySE2),"QRYSE2",.F.,.T.)
			Count To nRecsSE2
			If nRecsSE2 > 0 // Registros encontrados
				QRYSE2->(DbGotop())
				aCompars := {}
				While QRYSE2->(!EOF())
					SE2->(DbGoto( QRYSE2->R_E_C_N_O_ )) // Posiciono no SE2
					SA2->(DbSeek(_cFilSA2 + SE2->E2_FORNECE + SE2->E2_LOJA)) // Posiciono SA2 tambem
					//If nRecsSE2 >= 1 // Tem mais de 1 na query...
					//             {              01,             02,              03,            04,            05,             06,           07,,,             10,,,,,,,,,,           20 }
					//             {         Emissao,     Vencimento,     Vencto Real,  Valor Titulo,  Saldo Aberto,  Nome Reduzido, Razao Social,,,      Recno SE2,,,,,,,,,, Localizacoes }
					aAdd(aCompars, { SE2->E2_EMISSAO, SE2->E2_VENCTO, SE2->E2_VENCREA, SE2->E2_VALOR, SE2->E2_SALDO, SE2->E2_NOMFOR, SA2->A2_NOME,,, SE2->(Recno()),,,,,,,,,,            0 })
					//Else // Exato
					//	cStaReg := "310=Registro localizado (precisao '10')"
					//	aAdd(aFound, SE2->(Recno()))
					//EndIf
					QRYSE2->(DbSkip())
				End
				If Len(aCompars) > 0 // Tem mais de 1 registro (comparacoes)
					/*
					aAdd(aChecks, { "aCompars[w4,01] <= _aCls01[ nP01DatMov ]",						.F. }) // Emissao de acordo
					aAdd(aChecks, { "aCompars[w4,02] <= aCompars[w4,02]",							.F. }) // Vencimento de acordo (nao vencido)
					aAdd(aChecks, { "aCompars[w4,03] <= aCompars[w4,03]",							.F. }) // Vencimento Real de acordo (nao vencido)
					aAdd(aChecks, { "aCompars[w4,04] == aCompars[w4,05]",							.F. }) // Valor igual ao saldo (aberto)
					aAdd(aChecks, { "AllTrim(Upper(aCompars[w4,06])) $ Upper(_aCls01[nP01Histor])", .F. }) // Nome do Fornecedor confere com historico
					*/
					aSort(aCompars,,, {|x,y|, x[01] < y[01] }) // Ordenacao pela maior emissao
					// Cada um dos SE2 localizados faco as comparacoes
					For w4 := 1 To Len(aCompars)
						aEVal(aChecks, {|x|, x[02] := .F. }) // Reseto os .T. todos para .F.
						For w5 := 1 To Len(aChecks) // Faco as conferencias
							If &(aChecks[w5,01]) // .T.=De acordo .F.=Nao de acordo
								aChecks[w5,02] := .T.
								aCompars[w4,20] += aChecks[w5,03] // Incremento pontuacao de acordos conforme o nivel de precisao em aChecks
							EndIf
						Next
					Next
					aSort(aCompars,,, {|x,y|, x[20] > y[20] }) // Ordeno pelo que tem mais de acordos
					If aCompars[01,20] > 0 // Alguma coisa de acordo
						cStaReg := "3" + StrZero(aCompars[01,20],02) + "=Registro localizado (precisao '" + StrZero(aCompars[01,20],02) + "')"
						aAdd(aFound, aCompars[01,10]) // Recno do SE2 q mais se aproxima
					Else // Sem precisao
						cStaReg := "403=Registro localizado mas sem precisao"
						aAdd(aFound, 0) // Nada parecido
					EndIf
				EndIf
				If aTail(aFound) > 0 // Achou SE2... vejo se ja esta baixado ou nao
					SE2->(DbGoto( aTail(aFound) )) // Posiciono no SE2
					SA2->(DbSeek(_cFilSA2 + SE2->E2_FORNECE + SE2->E2_LOJA)) // Posiciono SA2 tambem
					If SE2->E2_SALDO == 0 // Ja totalmente baixado
						cStaReg := "501=Titulo ja foi totalmente baixado (" + cStaReg + ")"
					ElseIf SE2->E2_SALDO <> Abs(nVlrProc) // Ja tem baixas
						cStaReg := "401=Titulo nao tem saldo correto para a baixa (" + cStaReg + ")"
					EndIf
				EndIf
			Else // Nao achou nada na query SE2
				cStaReg := "402=Registro nao localizado (query)"
				aAdd(aFound, 0) // Por enquanto 0
			EndIf
		Else
			cStaReg := "403=Registro nao localizado (documento nao identificado)"
			aAdd(aFound, 0) // Por enquanto 0
		EndIf
	Else // Sem valor identificado (receber)
		cStaReg := "402=Registro nao localizado (query)"
		aAdd(aFound, 0) // Por enquanto 0
	EndIf
Else // Nao tem valor, nao tem como achar
	cStaReg := "401=Registro nao localizado (valor nao identificado)"
	aAdd(aFound, 0) // Por enquanto 0
EndIf
Return cStaReg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ INTFIN31 บAutor ณJonathan Schmidt Alves บData ณ 15/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa as baixas localizadas.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function INTFIN31()
Local nRecsProc := 0
Local nRecsDone := 0
Local dDataFin := GetMv("MV_DATAFIN")
AEVal(oGetD1:aCols, {|x|, Iif(x[nP01StaPrc] == "03", nRecsProc++, Nil) })	// Contador de registros a processar
If nRecsProc > 0 // Registros a processar
	If (nFind := ASCan(oGetD1:aCols, {|x|, x[nP01StaPrc] == "03" .And. x[nP01DatMov] < dDataFin })) > 0 // Algum registro Marcado para Processamento e Com Data Antes do MV_DATAFIN
		MsgStop("Periodo financeiro esta fechado (MV_DATAFIN)!" + Chr(13) + Chr(10) + ;
		"Verifique a liberacao do periodo e tente novamente!" + Chr(13) + Chr(10) + ;
		"Data Fechamento: " + DtoC(dDataFin) + Chr(13) + Chr(10) + ;
		"Data Movimento: " + oGetD1:aCols[nFind,nP01DatMov],"IntFin31")
	Else // Prossegue com as baixas
		cMotBaixa := Left(cGetMotBxa,3)						// Motivo da Baixa			E5_MOTBX
		cBcoBaixa := cGetCodBco								// Banco					E5_BANCO
		cAgeBaixa := cGetCodAge								// Agencia					E5_AGENCIA
		cConBaixa := cGetNumCon								// Numero da Conta			E5_NUMCON
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
		If SA6->(DbSeek(_cFilSA6 + cBcoBaixa + cAgeBaixa + cConBaixa))
			If u_AskYesNo(2500,"ConfBxas","Confirma processamento das baixas?","","","","Cancelar","UPDINFORMATION")
				u_AskYesNo(3500,"Processando baixas","Baixas pagar...","Processando...","","","","NOTE",.T.,.F.,{|| ConfBxas(nRecsProc) })
			EndIf
		Else // Banco nao encontrado (SA6)
			MsgStop("Banco/Agencia/Conta nao encontrados no cadastro (SA6)!" + Chr(13) + Chr(10) + ;
			"Banco/Agencia/Conta: " + cBcoBaixa + "/" + cAgeBaixa + "/" + cConBaixa,"IntFin31")
		EndIf
	EndIf
EndIf
Return

Static Function ConfBxas(nRecsProc)
Local aBaixa := {}
_oMeter:nTotal := nRecsProc
For w5 := 1 To Len(oGetD1:aCols) // Rodo nos registros
	If oGetD1:aCols[ w5, nP01StaPrc ] == "03" // "03"=Processar
		SE2->(DbGoto(aFound[ w5 ])) // Posiciono nos titulos a pagar
		++nCurrent
		For _w := 1 To 3
			u_AtuAsk09(nCurrent,"Processando baixas... " + cValToChar(nCurrent) + " / " + cValToChar(nRecsProc),"Baixas pagar... " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM, "Processando... " + SE2->E2_NOMFOR, "",80,"PROCESSA")
		Next
		dDatBaixa := oGetD1:aCols[w5,nP01DatMov]			// Data Baixa				E5_DATA
		dDatCredi := oGetD1:aCols[w5,nP01DatMov]			// Data Disponivel			E5_DTDISPO
		cHisBaixa := FTAcento(oGetD1:aCols[w5,nP01Histor])	// Historico Baixa			E5_HISTOR
		nVlrPagto := oGetD1:aCols[w5,nP01VlrMov]			// Valor Pagamento			E5_VALOR
		aBaixa := {}
		aAdd(aBaixa, {"E2_FILIAL",		SE2->E2_FILIAL,		Nil})
		aAdd(aBaixa, {"E2_PREFIXO",		SE2->E2_PREFIXO,	Nil})
		aAdd(aBaixa, {"E2_NUM",			SE2->E2_NUM,		Nil})
		aAdd(aBaixa, {"E2_PARCELA",		SE2->E2_PARCELA,	Nil})
		aAdd(aBaixa, {"E2_TIPO",		SE2->E2_TIPO,		Nil})
		aAdd(aBaixa, {"E2_FORNECE",		SE2->E2_FORNECE,	Nil})
		aAdd(aBaixa, {"E2_LOJA",		SE2->E2_LOJA,		Nil})
		aAdd(aBaixa, {"AUTMOTBX",		cMotBaixa,			Nil})
		aAdd(aBaixa, {"AUTBANCO",		cBcoBaixa,			Nil})
		aAdd(aBaixa, {"AUTAGENCIA",		cAgeBaixa,			Nil})
		aAdd(aBaixa, {"AUTCONTA",		cConBaixa,			Nil})
		aAdd(aBaixa, {"AUTDTBAIXA",		dDatBaixa,			Nil})
		aAdd(aBaixa, {"AUTDTCREDITO",	dDatCredi,			Nil})
		aAdd(aBaixa, {"AUTHIST",		cHisBaixa,			Nil})
		aAdd(aBaixa, {"AUTVLRPG",		nVlrPagto,			Nil})
		AcessaPerg("FIN080",.F.)
		lMsErroAuto := .F.
		
		dHldDtbase := dDatabase	// Hold do dDatabase
		dDatabase := dDatBaixa	// Database fica conforme data da baixa
		
		MsExecAuto({|x,y| FINA080(x,y)}, aBaixa, 3)
		
		dDatabase := dHldDtbase // Retorno dDatabase conforme era antes
		
		If lMsErroAuto // Erro ExecAuto
			For _w := 1 To 3
				u_AtuAsk09(nCurrent,"Processando baixas... " + cValToChar(nCurrent) + " / " + cValToChar(nRecsProc),"Baixas pagar... " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + " Falha!", "Processando... " + SE2->E2_NOMFOR, "",80,"UPDERROR")
				Sleep(010)
			Next
			MostraErro()
			Return .F.
		Else // Processamento com sucesso
			For _w := 1 To 3
				u_AtuAsk09(nCurrent,"Processando baixas... " + cValToChar(nCurrent) + " / " + cValToChar(nRecsProc),"Baixas pagar... " + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + " Sucesso!", "Processando... " + SE2->E2_NOMFOR, "",80,"OK")
				Sleep(050)
			Next
			oGetD1:aCols[w5,nP01StaPrc] := "05" // 05=Ja Processados
			oGetD1:aCols[w5,nP01StaReg] := "502=Titulo foi agora baixado! " + "(" + oGetD1:aCols[w5,nP01StaReg] + ")"
			// AtuRodap() // Atualizacao do Rodape
			oGetD1:Refresh()
		EndIf
	EndIf
Next
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LoadHder บAutor ณ Jonathan Schmidt Alves บDataณ 25/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para recarregamento do Header.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LoadHder()
aHdr01 := {}
For w := 1 To Len(aMolds01)
	aAdd(aHdr01, { aMolds01[w,03],							aMolds01[w,02],	aMolds01[w,07],						aMolds01[w,05], aMolds01[w,06], ".F.",				"€€€€€€€€€€€€€€ ", aMolds01[w,04], "",		"R", aMolds01[w,09], "" }) // 01
Next
For w := 1 To Len(aMolds02)
	aAdd(aHdr01, { aMolds02[w,03],							aMolds02[w,02],	aMolds02[w,07],						aMolds02[w,05], aMolds02[w,06], ".F.",				"€€€€€€€€€€€€€€ ", aMolds02[w,04], "",		"R", aMolds02[w,09], "" }) // 01
Next
Return aHdr01

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ClearCls บAutor ณ Jonathan Schmidt Alves บDataณ 25/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carregamento do aCols conforme padrao do aHdr01 passado.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ClearCls(aHdr01) // Criador de aCols
Local aCls := {}
Local _aCls := {}
For z := 1 To Len(aHdr01)
	If aHdr01[z,08] == "C" // Char
		aAdd(_aCls, Space(aHdr01[z,04]))
	ElseIf aHdr01[z,08] == "N" // Num
		aAdd(_aCls, 0)
	ElseIf aHdr01[z,08] == "D" // Data
		aAdd(_aCls, CtoD(""))
	EndIf
Next
aAdd(_aCls, .F.) // Nao apagado
aAdd(aCls, _aCls)
Return aCls

Static Function fAbrir()
Local cType := "Arquivo CSV. | *.CSV|"
Local cArqRet := cGetFile(cType, OemToAnsi("Selecione o arquivo para importar"),0,,.T.,GETF_LOCALHARD + GETF_LOCALFLOPPY)
Return cArqRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MarkRegs บAutor ณ Jonathan Schmidt Alves บDataณ 15/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca/Desmarca registros para processamento.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Status de Processamento:                                   บฑฑ
ฑฑบ          ณ 02=Nao Processar                                           บฑฑ
ฑฑบ          ณ 03=Processar                                               บฑฑ
ฑฑบ          ณ 04=Nao Localizado                                          บฑฑ
ฑฑบ          ณ 05=Ja Processado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MarkRegs()
Local nLin := oGetD1:nAt
If nLin > 0 .And. nLin <= Len(oGetD1:aCols)
	If oGetD1:aCols[ nLin, nP01StaPrc ] == "02" // 02=Nao Processar 03=Processar
		oGetD1:aCols[ nLin, nP01StaPrc ] := "03"
	ElseIf oGetD1:aCols[ nLin, nP01StaPrc ] == "03" // 03=Processar
		oGetD1:aCols[ nLin, nP01StaPrc ] := "02"
	EndIf
	oGetD1:Refresh()
EndIf
Return

Static Function VldBco01() // Validacao Banco
Local lRet := .T.
If Empty(cGetCodBco) // Sem banco preenchido
	cGetCodAge := Space(Len(cGetCodAge))
	cGetNumCon := Space(Len(cGetNumCon))
Else // Banco preenchido
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1)) // A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
	If SA6->(DbSeek(_cFilSA6 + cGetCodBco)) // Tudo preenchido
		cGetCodAge := SA6->A6_AGENCIA
		cGetNumCon := SA6->A6_NUMCON
		cGetNomBco := SA6->A6_NOME
	Else
		MsgStop("Banco nao encontrado no cadastro (SA6)!" + Chr(13) + Chr(10) + ;
		"Banco: " + cGetCodBco,"VldBco01")
		lRet := .F.
	EndIf
EndIf
oGetCodAge:Refresh()
oGetNumCon:Refresh()
oGetNomBco:Refresh()
Return lRet

Static Function VldMot01() // Validacao Motivo da Baixa
Local lRet := .F.
If Left(cGetMotBxa,03) $ "NOR/DAC/DEB/"
	lRet := ASCan(aGetMotBxa, {|x|, Left(x,03) == Left(cGetMotBxa,03) }) > 0 // Ascan(aMotBx,{|e| AllTrim(Upper(cMotBx))==AllTrim(Upper(Substr(e,1,3)))})
EndIf
Return lRet