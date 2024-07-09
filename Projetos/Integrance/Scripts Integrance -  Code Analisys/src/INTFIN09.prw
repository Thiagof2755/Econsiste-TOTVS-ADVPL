#Define CMD_OPENWORKBOOK			1
#Define CMD_CLOSEWORKBOOK			2
#Define CMD_ACTIVEWORKSHEET			3
#Define CMD_READCELL				4

#Include "Protheus.ch"
#Include "Topconn.ch"

#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4
#DEFINE GD_UPDATE	2
#DEFINE c_BR CHR(13)+CHR(10)

Static lProcess := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCTBM02   ºAutor  ³Elias Reis          º Data ³  01/02/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importacao de lancamentos TITULOS A PAGAR via excel         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³   		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCTBM02()

Local cType			:=	"Arquivos XLS|*.XLS|Todos os Arquivos|*.*"
Local aRegs			:= {}
Local cPerg			:= Padr("RCTBM02",GetSX3Cache("X1_GRUPO", "X3_TAMANHO"))

Private cArq		:= ""
Private oProcess  	:= MsNewProcess():New({|lEnd| CarrXLS()(lEnd)},"Carregando dados","Carregando...",.T.)

//Log de uso de funcoes customizadas
If ExistBlock("RCFGM01")
	U_RCFGM01()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona o arquivo                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq := cGetFile(cType, OemToAnsi("Selecione a planilha excel com as informações dos TITULOS A PAGAR."),0,"",.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
If Empty(cArq)
	Aviso("Inconsistência","Selecione a planilha excel com as informações dos TITULOS A PAGAR.",{"Ok"},,"Atenção:")
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria os parametros da rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aRegs,{cPerg,"01","Folder Planilha ?"	,"","","mv_ch1","C",30,0,0,"G","NaoVazio()"					   		,"MV_PAR01","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aRegs,{cPerg,"02","Linha Inicial  ?"	,"","","mv_ch2","N",05,0,0,"G","NaoVazio() .and. Entre(2,65536)"		,"MV_PAR02","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aRegs,{cPerg,"03","Linha Final  ?"		,"","","mv_ch3","N",05,0,0,"G","NaoVazio() .and. Entre(2,65536)"		,"MV_PAR03","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })

CriaSx1(aRegs)

If !Pergunte(cPerg,.T.)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa o processo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !lProcess
	oProcess:Activate()
End do

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CarrXLS   ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarrXLS()

Local nLoopDad		:= 0
Local aDados		:= {}
Local nValor		:= 0
Local aPosObj    	:= {}
Local oDlgMain		:= Nil
Local nOpcA			:= 0
Local aObjects		:= {}
Local aSize      	:= MsAdvSize()
Local aCampos		:= {}
Local cErro			:= ""//Posição para guardar ql o erro de validação dakla posição

Local cPrefREP 		:= AllTrim(Upper(GetMV("REP_PREFIX",.F.,"REP")))

Private aColsVar 	:= {}
Private oGetDad		:= Nil
Private aHeaderVar	:= {}

Private nArqE2PREFIXO := 01
Private nArqE2NUM     := 02
Private nArqE2PARCELA := 03
Private nArqE2TIPO    := 04
Private nArqE2FORNECE := 05
Private nArqE2LOJA    := 06
Private nArqE2NATUREZ := 07
Private nArqE2EMISSAO := 08
Private nArqE2VENCTO  := 09
Private nArqE2VALOR   := 10
Private nArqE2HIST    := 11
Private nArqE2ITEMD   := 12
Private nArqE2CCD     := 13
Private nArqE2CLVLDB  := 24


Private nPosE2PREFIXO := 0
Private nPosE2NUM     := 0
Private nPosE2PARCELA := 0
Private nPosE2TIPO    := 0
Private nPosE2FORNECE := 0
Private nPosE2LOJA    := 0
Private nPosE2NATUREZ := 0
Private nPosE2EMISSAO := 0
Private nPosE2VENCTO  := 0
Private nPosE2VALOR   := 0
Private nPosE2ITEMD   := 0
Private nPosE2CCD     := 0
Private nPosE2HIST    := 0
Private nPosE2XBANCO  := 0
Private nPosE2XAGENCI := 0
Private nPosE2XCONTA  := 0
Private nPosE2XRAZSOC := 0
Private nPosE2XCGC    := 0
Private nPosE2XTPCONT := 0
Private nPosAH1OBSERV := 0
Private nPosE2XDVCTA  := 0
Private nPosE2CLVLDB  := 0
Private nPosE2XEMAIL  := 0

//inicia o processo
lProcess	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a interface com o excel                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDados := GetExcel(cArq,Alltrim(MV_PAR01),Padr("A",2)+Alltrim(Str(MV_PAR02)),Padr(/*"U"*/"V",2)+Alltrim(Str(MV_PAR03)))
If Len(aDados) == 0
	Aviso("Inconsistência","Não foi localizado um retorno para a planilha informada.",{"Ok"},,"Atenção:")
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define os campos a serem exibidos                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos,{"A1_OBSERV","V","Arquivo"})//posição para o nome do arquivo
Aadd(aCampos,{"E2_PREFIXO","V",RetTitle("E2_PREFIXO")})
Aadd(aCampos,{"E2_NUM","V",RetTitle("E2_NUM")})
Aadd(aCampos,{"E2_PARCELA","V",RetTitle("E2_PARCELA")})
Aadd(aCampos,{"E2_TIPO","V",RetTitle("E2_TIPO")})
Aadd(aCampos,{"E2_FORNECE","V",RetTitle("E2_FORNECE")})
Aadd(aCampos,{"E2_LOJA","V",RetTitle("E2_LOJA")})
Aadd(aCampos,{"E2_NATUREZ","V",RetTitle("E2_NATUREZ")})
Aadd(aCampos,{"E2_EMISSAO","V",RetTitle("E2_EMISSAO")})
Aadd(aCampos,{"E2_VENCTO","V",RetTitle("E2_VENCTO")})
Aadd(aCampos,{"E2_VALOR","V",RetTitle("E2_VALOR")})
Aadd(aCampos,{"E2_HIST","V",RetTitle("E2_HIST")})
Aadd(aCampos,{"E2_ITEMD","V",RetTitle("E2_ITEMD")})
Aadd(aCampos,{"E2_CCD","V",RetTitle("E2_CCD")})
Aadd(aCampos,{"AH1_OBSERV","V",RetTitle("AH1_OBSERV")})
Aadd(aCampos,{"E2_CLVLDB","V",RetTitle("E2_CLVLDB")})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader da tabela de Medicoes                						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadVar := {}
For nX := 1 to Len(aCampos)
	Aadd(aHeaderVar,{;
	aCampos[nX,3],;
	aCampos[nX,1],;
	GetSX3Cache( aCampos[nX,1] , "X3_PICTURE"),;
	GetSX3Cache( aCampos[nX,1] , "X3_TAMANHO"),;
	GetSX3Cache( aCampos[nX,1] , "X3_DECIMAL"),;
	GetSX3Cache( aCampos[nX,1] , "X3_VALID"),;
	GetSX3Cache( aCampos[nX,1] , "X3_USADO"),;
	GetSX3Cache( aCampos[nX,1] , "X3_TIPO"),;
	GetSX3Cache( aCampos[nX,1] , "X3_F3"),;
	GetSX3Cache( aCampos[nX,1] , "X3_CONTEXT"),;
	GetSX3Cache( aCampos[nX,1] , "X3_CBOX"),;
	"",;
	GetSX3Cache( aCampos[nX,1] , "X3_WHEN"),;
	aCampos[nX,2],;
	GetSX3Cache( aCampos[nX,1] , "X3_VLDUSER"),;
	GetSX3Cache( aCampos[nX,1] , "X3_PICTVAR"),;
	GetSX3Cache( aCampos[nX,1] , "X3_OBRIGAT")})
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as variáveis de posições do aColsVar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nColsArquiv   := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "A1_OBSERV"	})
nPosE2PREFIXO := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_PREFIXO"})
nPosE2NUM     := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_NUM"	})
nPosE2PARCELA := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_PARCELA"})
nPosE2TIPO    := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_TIPO"	})
nPosE2FORNECE := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_FORNECE"})
nPosE2LOJA    := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_LOJA"	})
nPosE2NATUREZ := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_NATUREZ"})
nPosE2EMISSAO := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_EMISSAO"})
nPosE2VENCTO  := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_VENCTO" })
nPosE2VALOR   := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_VALOR" 	})
nPosE2HIST    := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_HIST" 	})
nPosE2ITEMD   := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_ITEMD" 	})
nPosE2CCD     := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_CCD" 	})
nPosAH1OBSERV := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "AH1_OBSERV"})
nPosE2CLVLDB  := aScan( aHeaderVar, { |x| AllTrim(x[2]) == "E2_CLVLDB"	})


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aColsVar                                       					    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oProcess:SetRegua1(len(aDados))
For nX	:= 1 to len(aDados)
	
	oProcess:IncRegua1("Processando linha: "+Alltrim(STR(nX))+" ...")
	
	cErro := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se deve desprezar esta linha                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Alltrim(aDados[nX][1])) .and.  Empty(Alltrim(aDados[nX][2])) .and. Empty(Alltrim(aDados[nX][11]))
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria a coluna que indica a liha deletada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aColsVar,Array(Len(aHeaderVar)+1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa as colunas com a picture de cada campo                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i := 1 To Len(aHeaderVar)
		aColsVar[Len(aColsVar)][i]	:= CriaVar(aHeaderVar[i,2],.F.)
	Next i
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³inicia o preenchimento dos campos                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsVar[Len(aColsVar)][nColsArquiv]			:= cArq//nome do arquivo
	aColsVar[Len(aColsVar)][Len(aHeaderVar)+1] 	:= .F.//seta o Deleted como .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida as posicoes do aDados e adiciona no aColsVar                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoopDad := 1 to Len(aDados[nX])
		
		If nLoopDad==nArqE2PREFIXO
			
			nTam := TamSX3("E2_PREFIXO")[1]
			
			aColsVar[Len(aColsVar)][nPosE2PREFIXO]	:= Padr(Substr(aDados[nX][nArqE2PREFIXO],1,nTam),nTam)
			
			If aColsVar[Len(aColsVar)][nPosE2PREFIXO] $ cPrefREP
				cErro += OemToAnsi("Prefixo reservado para o REPASSE.")
			EndIf
			
		ElseIf nLoopDad==nArqE2NUM
			aColsVar[Len(aColsVar)][nPosE2NUM]		:= Alltrim(aDados[nX][nArqE2NUM])
		ElseIf nLoopDad==nArqE2PARCELA
			aColsVar[Len(aColsVar)][nPosE2PARCELA]	:= Alltrim(aDados[nX][nArqE2PARCELA])
		ElseIf nLoopDad==nArqE2TIPO
			
			nTam := TamSX3("X5_CHAVE")[1]
			aColsVar[Len(aColsVar)][nPosE2TIPO]	:= Padr(Substr(aDados[nX][nArqE2TIPO],1,nTam),nTam)
			
			dbSelectArea("SX5")
			dbSetOrder(1)
			If !MsSeek(xFilial("SX5")+"05"+aColsVar[Len(aColsVar)][nPosE2TIPO])
				cErro += OemToAnsi("Tipo de título nao cadastrado ["+aColsVar[Len(aColsVar)][nPosE2TIPO]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2FORNECE
			
			nTam := TamSX3("A2_COD")[1]
			aColsVar[Len(aColsVar)][nPosE2FORNECE]	:= Padr(Substr(aDados[nX][nArqE2FORNECE],1,nTam),nTam)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If !MsSeek(xFilial("SA2")+aColsVar[Len(aColsVar)][nPosE2FORNECE])
				cErro += OemToAnsi("Codigo de Fornecedor não cadastrado ["+aDados[nX][nArqE2FORNECE]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2LOJA
			
			nTam := TamSX3("A2_LOJA")[1]
			aColsVar[Len(aColsVar)][nPosE2LOJA]	:= Padr(Substr(aDados[nX][nArqE2LOJA],1,nTam),nTam)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If !MsSeek(xFilial("SA2")+aColsVar[Len(aColsVar)][nPosE2FORNECE]+aColsVar[Len(aColsVar)][nPosE2LOJA])
				cErro += OemToAnsi("Codigo de Fornecedor/Loja não cadastrado ["+aColsVar[Len(aColsVar)][nPosE2FORNECE]+'/'+aColsVar[Len(aColsVar)][nPosE2LOJA]+"]!")
			Elseif SA2->A2_MSBLQL $ "1,S"
				cErro += OemToAnsi("Codigo de Fornecedor/Loja BLOQUEADO ["+aColsVar[Len(aColsVar)][nPosE2FORNECE]+'/'+aColsVar[Len(aColsVar)][nPosE2LOJA]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2NATUREZ
			
			nTam := TamSX3("ED_CODIGO")[1]
			aColsVar[Len(aColsVar)][nPosE2NATUREZ]	:= Padr(Substr(aDados[nX][nArqE2NATUREZ],1,nTam),nTam)
			
			DbSelectArea("SED")
			DbSetOrder(1)
			If !MsSeek(xFilial("SED")+aColsVar[Len(aColsVar)][nPosE2NATUREZ])
				cErro += OemToAnsi("Codigo de Natureza não cadastrado ["+aColsVar[Len(aColsVar)][nPosE2NATUREZ]+"]!")
			Elseif SED->ED_MSBLQL $ "1,S"
				cErro += OemToAnsi("Codigo de Natureza BLOQUEADO ["+aColsVar[Len(aColsVar)][nPosE2NATUREZ]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2EMISSAO
			
			aColsVar[Len(aColsVar)][nPosE2EMISSAO]	:= IIF(EMPTY(aDados[nX][nArqE2EMISSAO]),dDatabase,CTOD(aDados[nX][nArqE2EMISSAO]))
			
		ElseIf nLoopDad==nArqE2VENCTO
			
			aColsVar[Len(aColsVar)][nPosE2VENCTO]	:= IIF(EMPTY(aDados[nX][nArqE2VENCTO]),dDatabase,CTOD(aDados[nX][nArqE2VENCTO]))
			If CTOD(aDados[nX][nArqE2VENCTO]) < CTOD(aDados[nX][nArqE2EMISSAO])
				cErro += OemToAnsi("Data de emissao maior que a data de vencimento.")
			Endif
			
		ElseIf nLoopDad==nArqE2VALOR
			
			nVlr := Val(STRTRAN(STRTRAN(aDados[nX][nArqE2VALOR],".",""),",","."))
			
			aColsVar[Len(aColsVar)][nPosE2VALOR] := nVlr
			
			If aColsVar[Len(aColsVar)][nPosE2VALOR] < 0
				cErro += OemToAnsi("Valor do titulo não pode ser negativo.")
			Endif
			
		ElseIf nLoopDad==nArqE2ITEMD
			
			nTam := TamSX3("CTD_ITEM")[1]
			aColsVar[Len(aColsVar)][nPosE2ITEMD]	:= Padr(Substr(aDados[nX][nArqE2ITEMD],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2ITEMD])
				DbSelectArea("CTD")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTD")+aColsVar[Len(aColsVar)][nPosE2ITEMD])
					cErro += OemToAnsi("Item contábil não cadastrado."+aColsVar[Len(aColsVar)][nPosE2ITEMD])
				Elseif CTD->CTD_BLOQ == "1"
					cErro += OemToAnsi("Item contábil bloqueado."+aColsVar[Len(aColsVar)][nPosE2ITEMD])
				EndIf
			Else
				cErro += OemToAnsi("Item contábil não preenchido [E2_ITEMD]")
			Endif
			
		ElseIf nLoopDad==nArqE2CCD
			
			nTam := TamSX3("CTT_CUSTO")[1]
			aColsVar[Len(aColsVar)][nPosE2CCD]	:= Padr(Substr(aDados[nX][nArqE2CCD],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2CCD])
				DbSelectArea("CTT")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTT")+aColsVar[Len(aColsVar)][nPosE2CCD])
					cErro += OemToAnsi("Centro de Custo não cadastrado."+aColsVar[Len(aColsVar)][nPosE2CCD])
				Elseif CTT->CTT_BLOQ == "1"
					cErro += OemToAnsi("Centro de Custo bloqueado."+aColsVar[Len(aColsVar)][nPosE2CCD])
				EndIf
			Else
				cErro += OemToAnsi("Centro de Custo não preenchido [E2_CCD]")
			Endif
			
		ElseIf nLoopDad==nArqE2ClVLDB
			
			nTam := TamSX3("CTH_CLVL")[1]
			aColsVar[Len(aColsVar)][nPosE2ClVLDB]	:= Padr(Substr(aDados[nX][nArqE2ClVLDB],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2ClVLDB])
				DbSelectArea("CTH")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTH")+aColsVar[Len(aColsVar)][nPosE2ClVLDB])
					cErro += OemToAnsi("Classe de Valro não cadastrada."+aColsVar[Len(aColsVar)][nPosE2ClVLDB])
				Elseif CTH->CTH_BLOQ $ "1,S"
					cErro += OemToAnsi("Classe de Valor bloqueada."+aColsVar[Len(aColsVar)][nPosE2ClVLDB])
				EndIf
			Endif
			
		ElseIf nLoopDad==nArqE2HIST
			aColsVar[Len(aColsVar)][nPosE2HIST]			:= Alltrim(aDados[nX][nArqE2HIST])
		EndIf
		
	Next nLoopDad
	
	//Consiste a existencia do registro na base de dados
	nTam := TamSX3("E2_PREFIXO")[1] 	;	cPrefixo := Padr(Left(aColsVar[Len(aColsVar)][nPosE2PREFIXO],nTam),nTam)
	nTam := TamSX3("E2_NUM")[1] 		;	cNumero  := Padr(Left(aColsVar[Len(aColsVar)][nPosE2NUM],nTam),nTam)
	nTam := TamSX3("E2_PARCELA")[1] 	;	cParcela := Padr(Left(aColsVar[Len(aColsVar)][nPosE2PARCELA],nTam),nTam)
	nTam := TamSX3("E2_TIPO")[1] 		;	cTipo    := Padr(Left(aColsVar[Len(aColsVar)][nPosE2TIPO],nTam),nTam)
	nTam := TamSX3("E2_FORNECE")[1] 	;	cFornece := Padr(Left(aColsVar[Len(aColsVar)][nPosE2FORNECE],nTam),nTam)
	nTam := TamSX3("E2_LOJA")[1] 		;	cLoja    := Padr(Left(aColsVar[Len(aColsVar)][nPosE2LOJA],nTam),nTam)
	
	dbSelectArea("SE2")
	dbSetOrder(1)
	If dbSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja)
		cErro += OemToAnsi("Título ja existe na base de dados ")
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se cErro estiver preenchido³
	//³joga o valor na Observação ³
	//³e marca a posição do array ³
	//³como deletado.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(Alltrim(cErro))
		aColsVar[Len(aColsVar)][nPosAH1OBSERV] := cErro
		aColsVar[Len(aColsVar)][Len(aHeaderVar)+1] := .T.//seta o Deleted como .F.
	Endif
	
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a tela de exibicao do resultado da importacao                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgMain := TDialog():New(aSize[7],00,aSize[6],aSize[5],"Titulos Pagar a importar",,,,,,,,oMainWnd,.T.)

aObjects 	:= {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo 		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj 	:= MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de variaveis                        						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDad := MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],(aPosObj[1,3]-aPosObj[1,1])+25,(aPosObj[1,4]-aPosObj[1,2]),GD_UPDATE+GD_DELETE,,,,,,9999,,,,oDlgMain,@aHeaderVar,@aColsVar)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tela de resumo da importação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgMain:Activate(,,,,,,{||EnchoiceBar(oDlgMain,{||(nOpcA := 1, aColsVar := oGetDad:aCols, oDlgMain:End())},{||(nOpcA := 0, oDlgMain:End())},,)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as informacoes                                 						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == 1
	Processa({|lEnd| GravaLcto() },"Gravando Titulos ")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaLcto ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaLcto()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaração de variáveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nX			:= 0
Local nCriados		:= 0
Local nAltera 		:= 0
Local nProcess  	:= 0
Local nErro			:= 0
Local cLogErro		:= ""
Local aArSb1		:= 0
Local cArquivo

oProcess:SetRegua1(len(aColsVar))

For nX := 1 to len(aColsVar)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pula se estiver "deletado"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aColsVar[nX][Len(aHeaderVar)+1]
		cLogErro += "O Titulo a Pagar da linha "+Alltrim(Str(nX))+" não pode ser gravado! "+aColsVar[nX][nPosAH1OBSERV]+c_BR
		nErro++
		Loop
	Endif
	
	oProcess:IncRegua1("Importando registro: ")
	
	nProcess++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Importando Titulos a Pagar ...")
	
	lMsErroAuto := .F.
	
	aVetor :={}
	aAdd(aVetor,{"E2_PREFIXO"	,aColsVar[nX][nPosE2PREFIXO]				,Nil})
	aAdd(aVetor,{"E2_NUM"		,aColsVar[nX][nPosE2NUM]					,Nil})
	aAdd(aVetor,{"E2_PARCELA"	,aColsVar[nX][nPosE2PARCELA]				,Nil})
	aAdd(aVetor,{"E2_TIPO"		,aColsVar[nX][nPosE2TIPO]					,Nil})
	aAdd(aVetor,{"E2_NATUREZ"	,aColsVar[nX][nPosE2NATUREZ]				,Nil})
	aAdd(aVetor,{"E2_FORNECE"	,aColsVar[nX][nPosE2FORNECE]				,Nil})
	aAdd(aVetor,{"E2_LOJA"		,aColsVar[nX][nPosE2LOJA]					,Nil})
	aAdd(aVetor,{"E2_EMISSAO"	,aColsVar[nX][nPosE2EMISSAO]				,NIL})
	aAdd(aVetor,{"E2_VENCTO"	,aColsVar[nX][nPosE2VENCTO]					,NIL})
	aAdd(aVetor,{"E2_VENCREA"	,DataValida(aColsVar[nX][nPosE2VENCTO])		,NIL})
	aAdd(aVetor,{"E2_VALOR"		,aColsVar[nX][nPosE2VALOR]					,Nil})
	aAdd(aVetor,{"E2_HIST"		,aColsVar[nX][nPosE2HIST] 					,NIL})
	aAdd(aVetor,{"E2_MOEDA"		,1											,NIL})
	aAdd(aVetor,{"E2_VLCRUZ"	,aColsVar[nX][nPosE2VALOR]					,Nil})
	aAdd(aVetor,{"E2_CCD"		,aColsVar[nX][nPosE2CCD]					,Nil})
	aAdd(aVetor,{"E2_ITEMD"		,aColsVar[nX][nPosE2ITEMD]					,Nil})
	aAdd(aVetor,{"E2_EMIS1"		,dDatabase									,NIL})
	aAdd(aVetor,{"E2_ORIGEM"  	,"FINA050"                 					,NIL})
	aAdd(aVetor,{"E2_ClVLDB"	,aColsVar[nX][nPosE2ClVLDB] 				,NIL})
	
	cRef := Substr(DTOS(aColsVar[nX][nPosE2EMISSAO]),5,2)+ Substr(DTOS(aColsVar[nX][nPosE2EMISSAO]),1,4)
	Aadd(aVetor,{"E2_ZZREFER"   ,cRef						,Nil})
	
	
	MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,/*Inclusao*/3)
	
	If lMsErroAuto
		Mostraerro()
		nErro++
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Remove a identificação criada no PE F050INC que impede a Contabili ³
		//³zacao da inclusao destes titulos a pagar                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IsInCallStack("U_RCTBM02")
			RecLock("SE2",.F.)
			SE2->E2_LA := 'N'
			MsUnlock()
		EndIf
		nCriados++
	EndIf
	
Next nX


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe resumo da importação                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AVISO("", OemToAnsi(;
"Número de linhas processadas: "+Alltrim(STR(nProcess))+c_BR+;
"Número de registros criados: "+Alltrim(STR(nCriados))+c_BR+;
"Número de linhas com erro ou vazias: "+Alltrim(STR(nErro))), {"Ok"},)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gerar um log dos erros³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GRVLOG(cLogErro+c_BR+OemToAnsi(;
"Número de linhas processadas: "+Alltrim(STR(nProcess))+c_BR+;
"Número de registros criados: "+Alltrim(STR(nCriados))+c_BR+;
"Número de linhas com erro ou vazias: "+Alltrim(STR(nErro))))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRVLOG    ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GRVLOG(cLog)

Local cNomeArq		:= ""
Local nHdl
Local cMskFil 		:= "Arquivos TXT (*.txt) |*.txt|"

cNomeArq  := Upper(cGetFile(cMskFil, "Salvar Arquivo Como",,,.T.,,.F.))

cNomeArq  := IIf(rAt(".TXT", cNomeArq) == 0, cNomeArq + ".TXT", cNomeArq)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se já existe arquivo com o mesmo nome³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cNomeArq)
	If !fErase(cNomeArq) == 0
		MsgAlert('Ocorreram problemas na tentativa de dele‡„o do arquivo '+AllTrim(cNomeArq)+'.')
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdl:=fCreate(cNomeArq)

If nHdl == -1
	MsgAlert('O arquivo '+AllTrim(cNomeArq)+' n„o p“de ser criado! Verifique os parƒmetros.','Aten‡„o!')
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravação do novo arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fwrite(nHdl, cLog)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fecha o arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fclose(nHdl)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³GetExcel  º Autor ³                           ºData³          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao  ³Funcao para leitura e retorno em um array do conteudo         º±±
±±º           ³de uma planilha excel                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetExcel(cArqPlan,cPlan,cCelIni,cCelFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis                             		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aReturn		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa a interface de leitura da planilha excel                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| aReturn := LeExcel(cArqPlan,cPlan,cCelIni,cCelFim)} ,"Planilha Excel")

Return(aReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³LeExcel   º Autor ³                           ºData³          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao  ³Funcao para leitura e retorno em um array do conteudo         º±±
±±º           ³de uma planilha excel                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LeExcel(cArqPlan,cPlan,cCelIni,cCelFim)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis                             		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aReturn		:= {}
Local nLin			:= 0
Local nCol			:= 0
Local nLinIni		:= 0
Local nLinFim		:= 0
Local nColIni		:= 0
Local nColFim		:= 0
Local nMaxLin		:= 0
Local nMaxCol		:= 0
Local cDigCol1		:= ""
Local cDigCol2		:= ""
Local nHdl 			:= 0
Local cBuffer		:= "'
Local cCell 		:= ""
Local cFile			:= ""
Local nPosIni		:= 0
Local aNumbers		:= {"0","1","2","3","4","5","6","7","8","9"}
Local nX			:= 0
Local nColArr		:= 0
Default cArqPlan	:= ""
Default cPlan		:= ""
Default cCelIni		:= ""
Default cCelFim		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida os parametros informados pelo usuario        		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cArqPlan)
	Aviso("Inconsistência","Informe o diretório e o nome da planilha a ser processada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
If Empty(cPlan)
	Aviso("Inconsistência","Informe nome do Folder da planilha a ser processada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
If Empty(cCelIni)
	Aviso("Inconsistência","Informe a referência da célula inicial a ser processada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
If Empty(cCelFim)
	Aviso("Inconsistência","Informe a referência da célula final a ser processada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
If !File(cArqPlan)
	Aviso("Inconsistência","Não foi possível localizar a planilha "+Alltrim(cArqPlan)+" especificada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Else
	cFile := Alltrim(cArqPlan)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia a DLL de interface com o excel                		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !CpDllXls()
	Return(aReturn)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa a coordenada inicial da celula             		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosIni	:= 0
For nX := 1 to Len(Alltrim(cCelIni))
	If aScan(aNumbers, Substr(cCelIni,nX,1)) > 0
		nPosIni	:= nX
		Exit
	Endif
Next nX
If nPosIni == 0
	Aviso("Inconsistência","Não foi possivel determinar a referência numérica da linha inicial a ser processada. Verifique a referência da célula inicial informada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
nLinIni := Val(Substr(cCelIni,nPosIni,(Len(cCelIni)-nPosIni)+1))

cDigCol1 := Alltrim(Substr(cCelIni,1,nPosIni-1))
If Len(cDigCol1) == 2
	cDigCol1 	:= Substr(cCelIni,1,1)
	cDigCol2 	:= Substr(cCelIni,2,1)
	nColIni		:= ((Asc(cDigCol1)-64)*26) + (Asc(cDigCol2)-64)
Else
	cDigCol1 	:= Substr(cCelIni,1,1)
	cDigCol2 	:= ""
	nColIni		:= Asc(cDigCol1)-64
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa a coordenada final   da celula             		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosIni	:= 0
For nX := 1 to Len(Alltrim(cCelFim))
	If aScan(aNumbers, Substr(cCelFim,nX,1)) > 0
		nPosIni	:= nX
		Exit
	Endif
Next nX
If nPosIni == 0
	Aviso("Inconsistência","Não foi possivel determinar a referência numérica da linha final a ser processada. Verifique a referência da célula final informada.",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif
nLinFim := Val(Substr(cCelFim,nPosIni,(Len(cCelFim)-nPosIni)+1))

cDigCol1 := Alltrim(Substr(cCelFim,1,nPosIni-1))
If Len(cDigCol1) == 2
	cDigCol1 	:= Substr(cCelFim,1,1)
	cDigCol2 	:= Substr(cCelFim,2,1)
	nColFim		:= ((Asc(cDigCol1)-64)*26) + (Asc(cDigCol2)-64)
Else
	cDigCol1 	:= Substr(cCelFim,1,1)
	cDigCol2 	:= ""
	nColFim		:= Asc(cDigCol1)-64
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina o total de linhas e colunas               		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMaxLin := nLinFim - nLinIni + 1
nMaxCol := nColFim - nColIni + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre a DLL de interface excel                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdl := ExecInDLLOpen(Alltrim(GetMv("MV_DRDLLXLS",,"c:\temp"))+'\readexcel.dll')

If nHdl < 0
	Aviso("Inconsistência","Não foi possível carregar a DLL de interface com o Excel (readexcel.dll).",{"Sair"},,"Atenção:")
	Return(aReturn)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o excel e abre o arquivo                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBuffer := cFile+Space(512)
nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se abriu a planilha corretamente                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nBytes < 0
	Aviso("Inconsistência","Não foi possível abrir a planilha Excel solicitada ("+Alltrim(cFile)+").",{"Sair"},,"Atenção:")
	Return(aReturn)
ElseIf nBytes > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Erro critico na abertura do arquivo com msg de erro						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso("Inconsistência","Não foi possível abrir a planilha Excel solicitada ("+Alltrim(cFile)+"). "+Chr(13)+Chr(10)+"Erro interno: "+Subs(cBuffer, 1, nBytes),{"Sair"},,"Atenção:")
	Return(aReturn)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a worksheet                                  					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBuffer := Alltrim(cPlan)+Space(512)
nBytes 	:= ExeDLLRun2(nHdl,CMD_ACTIVEWORKSHEET,@cBuffer)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se selecionou o worksheet solicitado                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nBytes < 0
	Aviso("Inconsistência","Não foi possível selecionar a WorkSheet solicitada ("+Alltrim(cPlan)+") na planilha Excel ("+Alltrim(cFile)+").",{"Sair"},,"Atenção:")
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	ExecInDLLClose(nHdl)
	Return(aReturn)
ElseIf nBytes > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Erro critico na abertura do arquivo com msg de erro						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso("Inconsistência","Não foi possível selecionar a WorkSheet solicitada ("+Alltrim(cPlan)+") na planilha Excel ("+Alltrim(cFile)+")."+Chr(13)+Chr(10)+"Erro interno: "+Subs(cBuffer, 1, nBytes),{"Sair"},,"Atenção:")
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	ExecInDLLClose(nHdl)
	Return(aReturn)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a regua de processamento                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(nMaxLin*nMaxCol)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o array com todas as coordenadas necessarias   		     	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLin := nLinIni to nLinFim
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona no array a linja a ser importada                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aReturn, Array(nMaxCol))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa as colunas da linha atual                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nColArr := 0
	For nCol := nColIni to nColFim
		nColArr++
		If Int((nCol/26)-0.01) > 0
			cDigCol1 := Chr(Int((nCol/26)-0.01)+64)
		Else
			cDigCol1 := " "
		Endif
		If nCol - (Int((nCol/26)-0.01)*26) > 0
			cDigCol2 := Chr((nCol - (Int((nCol/26)-0.01)*26))+64)
		Else
			cDigCol2 := " "
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua de processamento                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IncProc("Importando planilha...")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compoe a coordenada da celula a ser importada                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCell := Alltrim(cDigCol1)+Alltrim(cDigCol2)+Alltrim(Str(nLin))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a leitura da celula no excel                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBuffer := cCell+Space(1024)
		nBytes 	:= ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
		//aReturn[nLin,nCol] := Subs(cBuffer, 1, nBytes)
		aReturn[Len(aReturn),nColArr] := Subs(cBuffer, 1, nBytes)
	Next nCol
Next nLin

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha a interface com o excel                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBuffer := Space(512)

ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)

ExecInDLLClose(nHdl)

Return(aReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CpDllXls  ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para copiar a DLL para a estação do usuario          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CpDllXls()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDirDest	:= Alltrim(GetMv("MV_DRDLLXLS",,"c:\temp"))
Local nResult	:= 0
Local lReturn	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o diretorio de destino da DLL na estacao do usuario                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lIsDir(cDirDest)
	nResult := MakeDir(cDirDest)
Endif
If nResult <> 0
	Aviso("Inconistência","Não foi possível criar o diretório "+cDirDest+" para a DLL de leitura da planilha Excel.",{"Sair"},,"Atenção:")
	lReturn := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Copia a DLL para o diretorio na estacao do usuario                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File("ReadExcel.dll")
		Aviso("Inconistência","Não foi possível localizar a DLL de leitura da planilha excel (ReadExcel.dll) no diretório SYSTEM ou SIGAADV.",{"Sair"},,"Atenção:")
		lReturn := .F.
	Else
		If !File(cDirDest+"\ReadExcel.dll")
			COPY FILE ("ReadExcel.dll") TO (cDirDest+"\ReadExcel.dll")
			If !File(cDirDest+"\ReadExcel.dll")
				Aviso("Inconistência","Não foi possível copiar a DLL de leitura da planilha excel para o diretório "+cDirDest+".",{"Sair"},,"Atenção:")
				lReturn := .F.
			Endif
		Endif
	Endif
Endif

Return(lReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaSx1   ºAutor  ³Microsiga           º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ		:= 0
Local nY		:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAtu)

Return(Nil)
