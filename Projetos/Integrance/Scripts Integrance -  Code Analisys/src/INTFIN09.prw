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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBM02   �Autor  �Elias Reis          � Data �  01/02/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Importacao de lancamentos TITULOS A PAGAR via excel         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �   		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������������������Ŀ
//� Seleciona o arquivo                                                 �
//�����������������������������������������������������������������������
cArq := cGetFile(cType, OemToAnsi("Selecione a planilha excel com as informa��es dos TITULOS A PAGAR."),0,"",.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
If Empty(cArq)
	Aviso("Inconsist�ncia","Selecione a planilha excel com as informa��es dos TITULOS A PAGAR.",{"Ok"},,"Aten��o:")
	Return()
Endif

//���������������������������������������������������������������������Ŀ
//� Cria os parametros da rotina                                        �
//�����������������������������������������������������������������������
Aadd(aRegs,{cPerg,"01","Folder Planilha ?"	,"","","mv_ch1","C",30,0,0,"G","NaoVazio()"					   		,"MV_PAR01","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aRegs,{cPerg,"02","Linha Inicial  ?"	,"","","mv_ch2","N",05,0,0,"G","NaoVazio() .and. Entre(2,65536)"		,"MV_PAR02","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aRegs,{cPerg,"03","Linha Final  ?"		,"","","mv_ch3","N",05,0,0,"G","NaoVazio() .and. Entre(2,65536)"		,"MV_PAR03","","","","",	"","","","","","","","","","","","","","","","","","","","","","","","","" })

CriaSx1(aRegs)

If !Pergunte(cPerg,.T.)
	Return
Endif

//����������������Ŀ
//�Ativa o processo�
//������������������
While !lProcess
	oProcess:Activate()
End do

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarrXLS   �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
Local cErro			:= ""//Posi��o para guardar ql o erro de valida��o dakla posi��o

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

//������������������������������������������������������������������������������Ŀ
//� Realiza a interface com o excel                                              �
//��������������������������������������������������������������������������������
aDados := GetExcel(cArq,Alltrim(MV_PAR01),Padr("A",2)+Alltrim(Str(MV_PAR02)),Padr(/*"U"*/"V",2)+Alltrim(Str(MV_PAR03)))
If Len(aDados) == 0
	Aviso("Inconsist�ncia","N�o foi localizado um retorno para a planilha informada.",{"Ok"},,"Aten��o:")
	Return()
Endif

//������������������������������������������������������������������������������Ŀ
//�Define os campos a serem exibidos                                             �
//��������������������������������������������������������������������������������
Aadd(aCampos,{"A1_OBSERV","V","Arquivo"})//posi��o para o nome do arquivo
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

//�����������������������������������������������������������������������������Ŀ
//� Monta o aHeader da tabela de Medicoes                						�
//�������������������������������������������������������������������������������
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

//���������������������������������������������
//�Define as vari�veis de posi��es do aColsVar�
//���������������������������������������������
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


//�����������������������������������������������������������������������������Ŀ
//� Monta o aColsVar                                       					    �
//�������������������������������������������������������������������������������
oProcess:SetRegua1(len(aDados))
For nX	:= 1 to len(aDados)
	
	oProcess:IncRegua1("Processando linha: "+Alltrim(STR(nX))+" ...")
	
	cErro := ""
	
	//�����������������������������������������������������������������������������Ŀ
	//�Verifica se deve desprezar esta linha                                        �
	//�������������������������������������������������������������������������������
	If Empty(Alltrim(aDados[nX][1])) .and.  Empty(Alltrim(aDados[nX][2])) .and. Empty(Alltrim(aDados[nX][11]))
		Loop
	Endif
	
	//�����������������������������������������������������������������������������Ŀ
	//�Cria a coluna que indica a liha deletada                                     �
	//�������������������������������������������������������������������������������
	Aadd(aColsVar,Array(Len(aHeaderVar)+1))
	
	//�����������������������������������������������������������������������������Ŀ
	//�Inicializa as colunas com a picture de cada campo                            �
	//�������������������������������������������������������������������������������
	For i := 1 To Len(aHeaderVar)
		aColsVar[Len(aColsVar)][i]	:= CriaVar(aHeaderVar[i,2],.F.)
	Next i
	
	//�����������������������������������������������������������������������������Ŀ
	//�inicia o preenchimento dos campos                                            �
	//�������������������������������������������������������������������������������
	aColsVar[Len(aColsVar)][nColsArquiv]			:= cArq//nome do arquivo
	aColsVar[Len(aColsVar)][Len(aHeaderVar)+1] 	:= .F.//seta o Deleted como .F.
	
	//�����������������������������������������������������������������������������Ŀ
	//�Valida as posicoes do aDados e adiciona no aColsVar                          �
	//�������������������������������������������������������������������������������
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
				cErro += OemToAnsi("Tipo de t�tulo nao cadastrado ["+aColsVar[Len(aColsVar)][nPosE2TIPO]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2FORNECE
			
			nTam := TamSX3("A2_COD")[1]
			aColsVar[Len(aColsVar)][nPosE2FORNECE]	:= Padr(Substr(aDados[nX][nArqE2FORNECE],1,nTam),nTam)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If !MsSeek(xFilial("SA2")+aColsVar[Len(aColsVar)][nPosE2FORNECE])
				cErro += OemToAnsi("Codigo de Fornecedor n�o cadastrado ["+aDados[nX][nArqE2FORNECE]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2LOJA
			
			nTam := TamSX3("A2_LOJA")[1]
			aColsVar[Len(aColsVar)][nPosE2LOJA]	:= Padr(Substr(aDados[nX][nArqE2LOJA],1,nTam),nTam)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If !MsSeek(xFilial("SA2")+aColsVar[Len(aColsVar)][nPosE2FORNECE]+aColsVar[Len(aColsVar)][nPosE2LOJA])
				cErro += OemToAnsi("Codigo de Fornecedor/Loja n�o cadastrado ["+aColsVar[Len(aColsVar)][nPosE2FORNECE]+'/'+aColsVar[Len(aColsVar)][nPosE2LOJA]+"]!")
			Elseif SA2->A2_MSBLQL $ "1,S"
				cErro += OemToAnsi("Codigo de Fornecedor/Loja BLOQUEADO ["+aColsVar[Len(aColsVar)][nPosE2FORNECE]+'/'+aColsVar[Len(aColsVar)][nPosE2LOJA]+"]!")
			EndIf
			
		ElseIf nLoopDad==nArqE2NATUREZ
			
			nTam := TamSX3("ED_CODIGO")[1]
			aColsVar[Len(aColsVar)][nPosE2NATUREZ]	:= Padr(Substr(aDados[nX][nArqE2NATUREZ],1,nTam),nTam)
			
			DbSelectArea("SED")
			DbSetOrder(1)
			If !MsSeek(xFilial("SED")+aColsVar[Len(aColsVar)][nPosE2NATUREZ])
				cErro += OemToAnsi("Codigo de Natureza n�o cadastrado ["+aColsVar[Len(aColsVar)][nPosE2NATUREZ]+"]!")
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
				cErro += OemToAnsi("Valor do titulo n�o pode ser negativo.")
			Endif
			
		ElseIf nLoopDad==nArqE2ITEMD
			
			nTam := TamSX3("CTD_ITEM")[1]
			aColsVar[Len(aColsVar)][nPosE2ITEMD]	:= Padr(Substr(aDados[nX][nArqE2ITEMD],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2ITEMD])
				DbSelectArea("CTD")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTD")+aColsVar[Len(aColsVar)][nPosE2ITEMD])
					cErro += OemToAnsi("Item cont�bil n�o cadastrado."+aColsVar[Len(aColsVar)][nPosE2ITEMD])
				Elseif CTD->CTD_BLOQ == "1"
					cErro += OemToAnsi("Item cont�bil bloqueado."+aColsVar[Len(aColsVar)][nPosE2ITEMD])
				EndIf
			Else
				cErro += OemToAnsi("Item cont�bil n�o preenchido [E2_ITEMD]")
			Endif
			
		ElseIf nLoopDad==nArqE2CCD
			
			nTam := TamSX3("CTT_CUSTO")[1]
			aColsVar[Len(aColsVar)][nPosE2CCD]	:= Padr(Substr(aDados[nX][nArqE2CCD],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2CCD])
				DbSelectArea("CTT")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTT")+aColsVar[Len(aColsVar)][nPosE2CCD])
					cErro += OemToAnsi("Centro de Custo n�o cadastrado."+aColsVar[Len(aColsVar)][nPosE2CCD])
				Elseif CTT->CTT_BLOQ == "1"
					cErro += OemToAnsi("Centro de Custo bloqueado."+aColsVar[Len(aColsVar)][nPosE2CCD])
				EndIf
			Else
				cErro += OemToAnsi("Centro de Custo n�o preenchido [E2_CCD]")
			Endif
			
		ElseIf nLoopDad==nArqE2ClVLDB
			
			nTam := TamSX3("CTH_CLVL")[1]
			aColsVar[Len(aColsVar)][nPosE2ClVLDB]	:= Padr(Substr(aDados[nX][nArqE2ClVLDB],1,nTam),nTam)
			If !Empty(aDados[nX][nArqE2ClVLDB])
				DbSelectArea("CTH")
				DbSetOrder(1)
				If !MsSeek(xFilial("CTH")+aColsVar[Len(aColsVar)][nPosE2ClVLDB])
					cErro += OemToAnsi("Classe de Valro n�o cadastrada."+aColsVar[Len(aColsVar)][nPosE2ClVLDB])
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
		cErro += OemToAnsi("T�tulo ja existe na base de dados ")
	Endif
	
	//���������������������������Ŀ
	//�Se cErro estiver preenchido�
	//�joga o valor na Observa��o �
	//�e marca a posi��o do array �
	//�como deletado.             �
	//�����������������������������
	If !Empty(Alltrim(cErro))
		aColsVar[Len(aColsVar)][nPosAH1OBSERV] := cErro
		aColsVar[Len(aColsVar)][Len(aHeaderVar)+1] := .T.//seta o Deleted como .F.
	Endif
	
Next nX

//������������������������������������������������������������������������������Ŀ
//�Monta a tela de exibicao do resultado da importacao                           �
//��������������������������������������������������������������������������������
oDlgMain := TDialog():New(aSize[7],00,aSize[6],aSize[5],"Titulos Pagar a importar",,,,,,,,oMainWnd,.T.)

aObjects 	:= {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo 		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj 	:= MsObjSize( aInfo, aObjects )

//�����������������������������������������������������������������������������Ŀ
//� Monta a GetDados de variaveis                        						�
//�������������������������������������������������������������������������������
oGetDad := MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],(aPosObj[1,3]-aPosObj[1,1])+25,(aPosObj[1,4]-aPosObj[1,2]),GD_UPDATE+GD_DELETE,,,,,,9999,,,,oDlgMain,@aHeaderVar,@aColsVar)

//����������������������������Ŀ
//�Tela de resumo da importa��o�
//������������������������������
oDlgMain:Activate(,,,,,,{||EnchoiceBar(oDlgMain,{||(nOpcA := 1, aColsVar := oGetDad:aCols, oDlgMain:End())},{||(nOpcA := 0, oDlgMain:End())},,)})

//�����������������������������������������������������������������������������Ŀ
//� Grava as informacoes                                 						�
//�������������������������������������������������������������������������������
If nOpcA == 1
	Processa({|lEnd| GravaLcto() },"Gravando Titulos ")
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GravaLcto �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GravaLcto()

//�����������������������Ŀ
//�Declara��o de vari�veis�
//�������������������������
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
	
	//��������������������������Ŀ
	//�Pula se estiver "deletado"�
	//����������������������������
	If aColsVar[nX][Len(aHeaderVar)+1]
		cLogErro += "O Titulo a Pagar da linha "+Alltrim(Str(nX))+" n�o pode ser gravado! "+aColsVar[nX][nPosAH1OBSERV]+c_BR
		nErro++
		Loop
	Endif
	
	oProcess:IncRegua1("Importando registro: ")
	
	nProcess++
	
	//���������������������������������������������������������������������Ŀ
	//� Incrementa a regua                                                  �
	//�����������������������������������������������������������������������
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
		//�������������������������������������������������������������������Ŀ
		//�Remove a identifica��o criada no PE F050INC que impede a Contabili �
		//�zacao da inclusao destes titulos a pagar                           �
		//���������������������������������������������������������������������
		If IsInCallStack("U_RCTBM02")
			RecLock("SE2",.F.)
			SE2->E2_LA := 'N'
			MsUnlock()
		EndIf
		nCriados++
	EndIf
	
Next nX


//������������������������������������������������Ŀ
//�Exibe resumo da importa��o                      �
//��������������������������������������������������
AVISO("", OemToAnsi(;
"N�mero de linhas processadas: "+Alltrim(STR(nProcess))+c_BR+;
"N�mero de registros criados: "+Alltrim(STR(nCriados))+c_BR+;
"N�mero de linhas com erro ou vazias: "+Alltrim(STR(nErro))), {"Ok"},)

//����������������������Ŀ
//�Gerar um log dos erros�
//������������������������
GRVLOG(cLogErro+c_BR+OemToAnsi(;
"N�mero de linhas processadas: "+Alltrim(STR(nProcess))+c_BR+;
"N�mero de registros criados: "+Alltrim(STR(nCriados))+c_BR+;
"N�mero de linhas com erro ou vazias: "+Alltrim(STR(nErro))))

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GRVLOG    �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GRVLOG(cLog)

Local cNomeArq		:= ""
Local nHdl
Local cMskFil 		:= "Arquivos TXT (*.txt) |*.txt|"

cNomeArq  := Upper(cGetFile(cMskFil, "Salvar Arquivo Como",,,.T.,,.F.))

cNomeArq  := IIf(rAt(".TXT", cNomeArq) == 0, cNomeArq + ".TXT", cNomeArq)

//����������������������������������������������Ŀ
//�Verifica se j� existe arquivo com o mesmo nome�
//������������������������������������������������
If File(cNomeArq)
	If !fErase(cNomeArq) == 0
		MsgAlert('Ocorreram problemas na tentativa de dele��o do arquivo '+AllTrim(cNomeArq)+'.')
	EndIf
Endif

//��������������Ŀ
//�Cria o arquivo�
//����������������
nHdl:=fCreate(cNomeArq)

If nHdl == -1
	MsgAlert('O arquivo '+AllTrim(cNomeArq)+' n�o p�de ser criado! Verifique os par�metros.','Aten��o!')
	Return
Endif

//������������������������Ŀ
//�Grava��o do novo arquivo�
//��������������������������
fwrite(nHdl, cLog)

//�����������������
//�fecha o arquivo�
//�����������������
fclose(nHdl)

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa   �GetExcel  � Autor �                           �Data�          ���
����������������������������������������������������������������������������͹��
���Descricao  �Funcao para leitura e retorno em um array do conteudo         ���
���           �de uma planilha excel                                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function GetExcel(cArqPlan,cPlan,cCelIni,cCelFim)

//�������������������������������������������������������������������������Ŀ
//� Declaracao de variaveis                             		     	    �
//���������������������������������������������������������������������������
Local aReturn		:= {}

//��������������������������������������������������������������������������Ŀ
//� Processa a interface de leitura da planilha excel                        �
//����������������������������������������������������������������������������
Processa({|| aReturn := LeExcel(cArqPlan,cPlan,cCelIni,cCelFim)} ,"Planilha Excel")

Return(aReturn)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa   �LeExcel   � Autor �                           �Data�          ���
����������������������������������������������������������������������������͹��
���Descricao  �Funcao para leitura e retorno em um array do conteudo         ���
���           �de uma planilha excel                                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function LeExcel(cArqPlan,cPlan,cCelIni,cCelFim)

//�������������������������������������������������������������������������Ŀ
//� Declaracao de variaveis                             		     	    �
//���������������������������������������������������������������������������
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

//�������������������������������������������������������������������������Ŀ
//� Valida os parametros informados pelo usuario        		     	    �
//���������������������������������������������������������������������������
If Empty(cArqPlan)
	Aviso("Inconsist�ncia","Informe o diret�rio e o nome da planilha a ser processada.",{"Sair"},,"Aten��o:")
	Return(aReturn)
Endif
If Empty(cPlan)
	Aviso("Inconsist�ncia","Informe nome do Folder da planilha a ser processada.",{"Sair"},,"Aten��o:")
	Return(aReturn)
Endif
If Empty(cCelIni)
	Aviso("Inconsist�ncia","Informe a refer�ncia da c�lula inicial a ser processada.",{"Sair"},,"Aten��o:")
	Return(aReturn)
Endif
If Empty(cCelFim)
	Aviso("Inconsist�ncia","Informe a refer�ncia da c�lula final a ser processada.",{"Sair"},,"Aten��o:")
	Return(aReturn)
Endif
If !File(cArqPlan)
	Aviso("Inconsist�ncia","N�o foi poss�vel localizar a planilha "+Alltrim(cArqPlan)+" especificada.",{"Sair"},,"Aten��o:")
	Return(aReturn)
Else
	cFile := Alltrim(cArqPlan)
Endif

//�������������������������������������������������������������������������Ŀ
//� Copia a DLL de interface com o excel                		     	    �
//���������������������������������������������������������������������������
If !CpDllXls()
	Return(aReturn)
Endif

//�������������������������������������������������������������������������Ŀ
//� Processa a coordenada inicial da celula             		     	    �
//���������������������������������������������������������������������������
nPosIni	:= 0
For nX := 1 to Len(Alltrim(cCelIni))
	If aScan(aNumbers, Substr(cCelIni,nX,1)) > 0
		nPosIni	:= nX
		Exit
	Endif
Next nX
If nPosIni == 0
	Aviso("Inconsist�ncia","N�o foi possivel determinar a refer�ncia num�rica da linha inicial a ser processada. Verifique a refer�ncia da c�lula inicial informada.",{"Sair"},,"Aten��o:")
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

//�������������������������������������������������������������������������Ŀ
//� Processa a coordenada final   da celula             		     	    �
//���������������������������������������������������������������������������
nPosIni	:= 0
For nX := 1 to Len(Alltrim(cCelFim))
	If aScan(aNumbers, Substr(cCelFim,nX,1)) > 0
		nPosIni	:= nX
		Exit
	Endif
Next nX
If nPosIni == 0
	Aviso("Inconsist�ncia","N�o foi possivel determinar a refer�ncia num�rica da linha final a ser processada. Verifique a refer�ncia da c�lula final informada.",{"Sair"},,"Aten��o:")
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

//�������������������������������������������������������������������������Ŀ
//� Determina o total de linhas e colunas               		     	    �
//���������������������������������������������������������������������������
nMaxLin := nLinFim - nLinIni + 1
nMaxCol := nColFim - nColIni + 1

//��������������������������������������������������������������������������Ŀ
//� Abre a DLL de interface excel                                            �
//����������������������������������������������������������������������������
nHdl := ExecInDLLOpen(Alltrim(GetMv("MV_DRDLLXLS",,"c:\temp"))+'\readexcel.dll')

If nHdl < 0
	Aviso("Inconsist�ncia","N�o foi poss�vel carregar a DLL de interface com o Excel (readexcel.dll).",{"Sair"},,"Aten��o:")
	Return(aReturn)
Endif

//��������������������������������������������������������������������������Ŀ
//� Carrega o excel e abre o arquivo                                         �
//����������������������������������������������������������������������������
cBuffer := cFile+Space(512)
nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

//��������������������������������������������������������������������������Ŀ
//� Valida se abriu a planilha corretamente                                  �
//����������������������������������������������������������������������������
If nBytes < 0
	Aviso("Inconsist�ncia","N�o foi poss�vel abrir a planilha Excel solicitada ("+Alltrim(cFile)+").",{"Sair"},,"Aten��o:")
	Return(aReturn)
ElseIf nBytes > 0
	//��������������������������������������������������������������������������Ŀ
	//� Erro critico na abertura do arquivo com msg de erro						 �
	//����������������������������������������������������������������������������
	Aviso("Inconsist�ncia","N�o foi poss�vel abrir a planilha Excel solicitada ("+Alltrim(cFile)+"). "+Chr(13)+Chr(10)+"Erro interno: "+Subs(cBuffer, 1, nBytes),{"Sair"},,"Aten��o:")
	Return(aReturn)
EndIf

//��������������������������������������������������������������������������Ŀ
//� Seleciona a worksheet                                  					 �
//����������������������������������������������������������������������������
cBuffer := Alltrim(cPlan)+Space(512)
nBytes 	:= ExeDLLRun2(nHdl,CMD_ACTIVEWORKSHEET,@cBuffer)

//��������������������������������������������������������������������������Ŀ
//� Valida se selecionou o worksheet solicitado                              �
//����������������������������������������������������������������������������
If nBytes < 0
	Aviso("Inconsist�ncia","N�o foi poss�vel selecionar a WorkSheet solicitada ("+Alltrim(cPlan)+") na planilha Excel ("+Alltrim(cFile)+").",{"Sair"},,"Aten��o:")
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	ExecInDLLClose(nHdl)
	Return(aReturn)
ElseIf nBytes > 0
	//��������������������������������������������������������������������������Ŀ
	//� Erro critico na abertura do arquivo com msg de erro						 �
	//����������������������������������������������������������������������������
	Aviso("Inconsist�ncia","N�o foi poss�vel selecionar a WorkSheet solicitada ("+Alltrim(cPlan)+") na planilha Excel ("+Alltrim(cFile)+")."+Chr(13)+Chr(10)+"Erro interno: "+Subs(cBuffer, 1, nBytes),{"Sair"},,"Aten��o:")
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	ExecInDLLClose(nHdl)
	Return(aReturn)
EndIf

//��������������������������������������������������������������������������Ŀ
//� Define a regua de processamento                                          �
//����������������������������������������������������������������������������
ProcRegua(nMaxLin*nMaxCol)

//�������������������������������������������������������������������������Ŀ
//� Gera o array com todas as coordenadas necessarias   		     	    �
//���������������������������������������������������������������������������
For nLin := nLinIni to nLinFim
	
	//��������������������������������������������������������������������������Ŀ
	//� Adiciona no array a linja a ser importada                                �
	//����������������������������������������������������������������������������
	Aadd(aReturn, Array(nMaxCol))
	
	//��������������������������������������������������������������������������Ŀ
	//� Processa as colunas da linha atual                                       �
	//����������������������������������������������������������������������������
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
		//��������������������������������������������������������������������������Ŀ
		//� Incrementa a regua de processamento                                      �
		//����������������������������������������������������������������������������
		IncProc("Importando planilha...")
		
		//��������������������������������������������������������������������������Ŀ
		//� Compoe a coordenada da celula a ser importada                            �
		//����������������������������������������������������������������������������
		cCell := Alltrim(cDigCol1)+Alltrim(cDigCol2)+Alltrim(Str(nLin))
		
		//��������������������������������������������������������������������������Ŀ
		//� Realiza a leitura da celula no excel                                     �
		//����������������������������������������������������������������������������
		cBuffer := cCell+Space(1024)
		nBytes 	:= ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
		//aReturn[nLin,nCol] := Subs(cBuffer, 1, nBytes)
		aReturn[Len(aReturn),nColArr] := Subs(cBuffer, 1, nBytes)
	Next nCol
Next nLin

//��������������������������������������������������������������������������Ŀ
//� Fecha a interface com o excel                                            �
//����������������������������������������������������������������������������
cBuffer := Space(512)

ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)

ExecInDLLClose(nHdl)

Return(aReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CpDllXls  �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para copiar a DLL para a esta��o do usuario          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CpDllXls()

//�������������������������������������������������������������������������������Ŀ
//�Declaracao de variaveis                                                        �
//���������������������������������������������������������������������������������
Local cDirDest	:= Alltrim(GetMv("MV_DRDLLXLS",,"c:\temp"))
Local nResult	:= 0
Local lReturn	:= .T.

//�������������������������������������������������������������������������������Ŀ
//�Cria o diretorio de destino da DLL na estacao do usuario                       �
//���������������������������������������������������������������������������������
If !lIsDir(cDirDest)
	nResult := MakeDir(cDirDest)
Endif
If nResult <> 0
	Aviso("Inconist�ncia","N�o foi poss�vel criar o diret�rio "+cDirDest+" para a DLL de leitura da planilha Excel.",{"Sair"},,"Aten��o:")
	lReturn := .F.
Else
	//�������������������������������������������������������������������������������Ŀ
	//�Copia a DLL para o diretorio na estacao do usuario                             �
	//���������������������������������������������������������������������������������
	If !File("ReadExcel.dll")
		Aviso("Inconist�ncia","N�o foi poss�vel localizar a DLL de leitura da planilha excel (ReadExcel.dll) no diret�rio SYSTEM ou SIGAADV.",{"Sair"},,"Aten��o:")
		lReturn := .F.
	Else
		If !File(cDirDest+"\ReadExcel.dll")
			COPY FILE ("ReadExcel.dll") TO (cDirDest+"\ReadExcel.dll")
			If !File(cDirDest+"\ReadExcel.dll")
				Aviso("Inconist�ncia","N�o foi poss�vel copiar a DLL de leitura da planilha excel para o diret�rio "+cDirDest+".",{"Sair"},,"Aten��o:")
				lReturn := .F.
			Endif
		Endif
	Endif
Endif

Return(lReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaSx1   �Autor  �Microsiga           � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
