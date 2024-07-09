#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ ITXMLMAN ºAutor ³Microsiga             º Data ³ ??/??/???? º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ITXMLMAN()
Local aSize
Local aInfo
Local _aCampos
Local _aTabAux
Local _aCols0
Local _nPos
Local _oDlg
Local _cTitle
Local _oEnChoice
Local aObjects
Local aPosObj
Local _cTemp
Local _nUsado
Local lOk
Local _cAliasC	:= "PA1"
Local aCols0		:= {}
Local _nCod
Local _nQtd
Local _nVlr
Local _nVlrTot
Local _nTes
Local _nCF
Local _nDesc
Local _nNFori
Local _nSerori
Local _nItori
Local _nBicms
Local _nPicm
Local _nValicm
Local _nBricms
Local _nIcmsre
Local _nIcmsco
Local _nDifal
Local _nAlfccm
Local _nVfcodi
Local _nBaseip
Local _nIPI
Local _nValipi
Local _nAliq5
Local _nAliq6
Local aCabec    := {}
Local aItem     := {}
Local aItensT   := {}
Local aLinha    := {}
Local _nBase5
Local _nBase6
Local _nValo5
Local _nValo6
Private _oGet
Private _oGet2
Private aRotina 	:= {}
Private lMsErroAuto := .F.
Private	_nStyle
Private	_aHeader
Private	_aCols
aAdd(aRotina,{"Pesquisar"		,"AxPesqui"     ,0,1})
aAdd(aRotina,{"Visualizar"      ,"AxVisual"     ,0,2})
aAdd(aRotina,{"Incluir"			,"U_ITXMLMAN"  	,0,3})
aSize	   	 := MsAdvSize(.T.,.f.)
aInfo	 	 := {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
aObjects	 := {}
aPosObj	   	 := {}
_aButtons	 := {}
_aComponente := {}
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal
_aCampos	:= {}
_aHeader	:= {}
_aCols  	:= {}
_aTabAux	:= {}
_aCols0		:= {}
_nPos		:= 0
_cTitle		:= "Pré Nota Fiscal - Integração XML"
_nStyle		:= GD_INSERT + GD_UPDATE + GD_DELETE
_cTemp		:= ""

// Carrega as informações do Cabeçalho
// Atualização de acesso a sx3 -> GetSX3Cache([Campo do dicionário procurado], [Campo da SX3])
/*SX3->(dbSetOrder(1))
SX3->(dbSeek(_cAliasC))
While SX3->(!EOF() .And. X3_ARQUIVO == _cAliasC)
	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		aAdd(_aCampos, SX3->X3_CAMPO)
	EndIf
	SX3->(DbSkip())
EndDo*/

//Abre a temporaria ja filtrando a tabela que preciso
cEmpresa  := FWGrpEmp()
cAliasTmp := "SX3TEMP"
cFiltro   := "X3_ARQUIVO == 'PA1'"
OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)
(cAliasTmp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
(cAliasTmp)->(DbGoTop())
 
While ! (cAliasTmp)->(Eof())
    If X3Uso( &("(cAliasTmp)->X3_USADO")) .And. cNivel >= &("(cAliasTmp)->X3_NIVEL")
        aAdd(_aCampos, &("(cAliasTmp)->X3_CAMPO"))
    EndIf        
    (cAliasTmp)->(dbSkip())
EndDo



RegToMemory(_cAliasC,.T.)
_nXFrete := 0
For _nX := 1 To Len(aChvInfo[20])
	_nXFrete += Iif(ValType(aChvInfo[20][_nX][14]) == "N", aChvInfo[20][_nX][14], Val(aChvInfo[20][_nX][14]))
Next
M->PA1_FILIAL	:= xFilial("PA1")
M->PA1_TIPO		:= aChvInfo[01]
M->PA1_DOC		:= aChvInfo[03]
M->PA1_SERIE	:= aChvInfo[04]
M->PA1_DATA		:= aChvInfo[05]
M->PA1_CLIENT	:= aChvInfo[06]
M->PA1_LOJA		:= aChvInfo[07]
M->PA1_ESPEC	:= aChvInfo[08]
M->PA1_FRETE	:= _nXFrete

// Carrega as informações dos Itens
// SX3->(dbSetOrder(1))
// SX3->(dbSeek("PA2"))
// While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "PA2"
// 	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
// 		_aTabAux := {}
// 		aAdd(_aTabAux,Trim(x3Titulo()))
// 		aAdd(_aTabAux,SX3->X3_CAMPO        )
// 		aAdd(_aTabAux,SX3->X3_PICTURE      )
// 		aAdd(_aTabAux,SX3->X3_TAMANHO      )
// 		aAdd(_aTabAux,SX3->X3_DECIMAL      )
// 		aAdd(_aTabAux,SX3->X3_VALID        )
// 		aAdd(_aTabAux,SX3->X3_USADO        )
// 		aAdd(_aTabAux,SX3->X3_TIPO         )
// 		aAdd(_aTabAux,SX3->X3_F3           )
// 		aAdd(_aTabAux,SX3->X3_CONTEXT      )
// 		aAdd(_aTabAux,SX3->X3_CBOX         )
// 		aAdd(_aTabAux,SX3->X3_RELACAO      )
// 		aAdd(_aTabAux,SX3->X3_WHEN         )
// 		aAdd(_aTabAux,SX3->X3_VISUAL       )
// 		aAdd(_aTabAux,SX3->X3_VLDUSER      )
// 		aAdd(_aTabAux,SX3->X3_PICTVAR      )
// 		aAdd(_aTabAux,SX3->X3_OBRIGAT	   )
// 		aAdd(_aHeader,_aTabAux			   )
// 	EndIf
// 	SX3->(DbSkip())
// End

//Abre a temporaria ja filtrando a tabela que precis
cFiltro   := "X3_ARQUIVO == 'PA2'"
OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)
(cAliasTmp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
(cAliasTmp)->(DbGoTop())

While ! (cAliasTmp)->(Eof())
	If X3Uso( &("(cAliasTmp)->X3_USADO")) .And. cNivel >= &("(cAliasTmp)->X3_NIVEL")
		_aTabAux := {}
		aAdd(_aTabAux,Trim(&("(cAliasTmp)->X3_TITULO")))
		aAdd(_aTabAux,&("(cAliasTmp)->X3_CAMPO")        )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_PICTURE")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_TAMANHO")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_DECIMAL")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_VALID")        )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_USADO")        )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_TIPO")         )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_F3")           )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_CONTEXT")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_CBOX")         )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_RELACAO")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_WHEN")         )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_VISUAL")       )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_VLDUSER")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_PICTVAR")      )
		aAdd(_aTabAux,&("(cAliasTmp)->X3_OBRIGAT")	   )
		aAdd(_aHeader,_aTabAux			   )
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo


_aCols  := fCols(_aHeader,"PA2",1,xFilial("PA2"),"PA2_FILIAL=='XX'" ,"PA2_FILIAL=='XX'")
aCols0	:= _aCols
_nCod		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_COD" })
_nQtd		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_QTD" })
_nVlr		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VLR" })
_nVlrTot	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VLRTOT" })
_nTes		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_TES" })
_nCF		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_CF" })
_nDesc		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_DESC" })
_nNFori		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_NFORI" })
_nSerori	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_SERORI" })
_nItori		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ITORI" })
_nBicms		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_BICMS" })
_nPicm		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_PICM" })
_nValicm	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VALICM" })
_nBricms	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_BRICMS" })
_nIcmsre	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ICMSRE" })
_nIcmsco	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ICMSCO" })
_nDifal		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_DIFAL" })
_nAlfccm	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ALFCCM" })
_nVFCPDI	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VFCPDI" })
_nBaseip	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_BASEIP" })
_nIPI		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_IPI" })
_nValipi	:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VALIPI" })
_nAliq5		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ALIQ5" })
_nAliq6		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_ALIQ6" })
_nBase5		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_BAS5" })
_nBase6		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_BAS6" })
_nValo5		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VL5" })
_nValo6		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VL6" })
_nFrete		:= aScan(_aHeader, { |x| Alltrim(x[02]) == "PA2_VALFRE" })
For _nX := 1 To Len(aChvInfo[20])
	If _nX > 1
		aCols0 := {}
		For _nY := 1 to Len(_aHeader)
			If !_aHeader[_nY,10]=="V"
				PA2->(AAdd(aCols0,FieldGet(FieldPos(_aHeader[_nY,2]))))
			Else
				PA2->(AAdd(aCols0,Criavar(_aHeader[_nY,2])))
			EndIF
		Next
		aadd(aCols0,.F.)
		aadd(_aCols,aCols0)
	EndIf
	SB1->(DbGoto(aChvInfo[20][_nX][1])) // Recno SB1
	_aCols[len(_aCols)][_nCod]		:= SB1->B1_COD
	_aCols[len(_aCols)][_nQTD]		:= aChvInfo[20][_nX][8]
	_aCols[len(_aCols)][_nVLR]		:= aChvInfo[20][_nX][9]
	_aCols[len(_aCols)][_nVLRTOT]	:= aChvInfo[20][_nX][10]
	SF4->(DbGoto(aChvInfo[20][_nX][13][5])) // Recno SF4
	If SF4->(Recno()) == aChvInfo[20][_nX][13][5]
		_aCols[len(_aCols)][_nTES]	:= SF4->F4_CODIGO
		_aCols[len(_aCols)][_nCF]	:= SF4->F4_CF
		If SF4->F4_PISCRED == "2" // Credita Pis e Cofins
			Do Case
				Case SF4->F4_PISCOF == "3"	// Ambos
					If aChvInfo[20][_nX][13][18] == 0	// Cofins
						aChvInfo[20][_nX][13][13] := zSuperGet("MV_TXCOFIN",.f.,aChvInfo[20][_nX][13][13])	// Aliquota Cofins
						aChvInfo[20][_nX][13][16] := aChvInfo[20][_nX][10]									// Base Cofins
						aChvInfo[20][_nX][13][18] := NoRound((aChvInfo[20][_nX][13][16] * aChvInfo[20][_nX][13][13])/100, SD2->(GetSx3Cache("D2_VALIMP5","X3_DECIMAL")))	// Valor Cofins
					EndIf
					If aChvInfo[20][_nX][13][19] == 0	// Pis
						aChvInfo[20][_nX][13][12] := zSuperGet("MV_TXPIS",.f.,aChvInfo[20][_nX][13][12])	// Aliquota Pis
						aChvInfo[20][_nX][13][14] := aChvInfo[20][_nX][10]									// Base Pis
						aChvInfo[20][_nX][13][19] := NoRound((aChvInfo[20][_nX][13][14] * aChvInfo[20][_nX][13][12])/100, SD2->(GetSx3Cache("D2_VALIMP6","X3_DECIMAL")))	// Valor Pis
					EndIf
				Case SF4->F4_PISCOF == "1"	// Pis
					If aChvInfo[20][_nX][13][19] == 0	// Pis
						aChvInfo[20][_nX][13][12] := zSuperGet("MV_TXPIS",.f.,aChvInfo[20][_nX][13][12])	// Aliquota Pis
						aChvInfo[20][_nX][13][14] := aChvInfo[20][_nX][10]									// Base Pis
						aChvInfo[20][_nX][13][19] := NoRound((aChvInfo[20][_nX][13][14] * aChvInfo[20][_nX][13][12])/100, SD2->(GetSx3Cache("D2_VALIMP6","X3_DECIMAL")))	// Valor Pis
					EndIf
				Case SF4->F4_PISCOF == "2"	// Cofins
					If aChvInfo[20][_nX][13][18] == 0	// Cofins
						aChvInfo[20][_nX][13][13] := zSuperGet("MV_TXCOFIN",.f.,aChvInfo[20][_nX][13][13])	// Aliquota Cofins
						aChvInfo[20][_nX][13][16] := aChvInfo[20][_nX][10]									// Base Cofins
						aChvInfo[20][_nX][13][18] := NoRound((aChvInfo[20][_nX][13][16] * aChvInfo[20][_nX][13][13])/100, SD2->(GetSx3Cache("D2_VALIMP5","X3_DECIMAL")))	// Valor Cofins
					EndIf
			EndCase
		EndIf
		If SF4->(FieldPos("F4_XCONTA")) > 0 .and. !(Empty(SF4->F4_XCONTA))
			_aCols[len(_aCols)][_nCF]	:= SF4->F4_XCONTA
		EndIF
	EndIf
	_aCols[len(_aCols)][_nDESC]		:= aChvInfo[20][_nX][11]
	_aCols[len(_aCols)][_nNFORI]	:= ""
	_aCols[len(_aCols)][_nSERORI]	:= ""
	_aCols[len(_aCols)][_nITORI]	:= ""
	_aCols[len(_aCols)][_nBICMS]	:= aChvInfo[20][_nX][13][1][6]
	_aCols[len(_aCols)][_nPICM]		:= aChvInfo[20][_nX][13][1][5]
	_aCols[len(_aCols)][_nVALICM]	:= aChvInfo[20][_nX][13][1][7]
	_aCols[len(_aCols)][_nBRICMS]	:= aChvInfo[20][_nX][13][1][4]
	_aCols[len(_aCols)][_nICMSRE]	:= Iif(aChvInfo[20][_nX][13][1][4] > 0, aChvInfo[20][_nX][13][1][3], 0)
	_aCols[len(_aCols)][_nICMSCO]	:= 0
	_aCols[len(_aCols)][_nDIFAL]	:= 0
	_aCols[len(_aCols)][_nALFCCM]	:= 0
	_aCols[len(_aCols)][_nVFCPDI]	:= 0
	_aCols[len(_aCols)][_nBASEIP]	:= aChvInfo[20][_nX][13][10]
	_aCols[len(_aCols)][_nIPI]		:= aChvInfo[20][_nX][13][7]
	_aCols[len(_aCols)][_nVALIPI]	:= aChvInfo[20][_nX][13][11]
	_aCols[len(_aCols)][_nAliq5]	:= aChvInfo[20][_nX][13][13]
	_aCols[len(_aCols)][_nAliq6]	:= aChvInfo[20][_nX][13][12]
	_aCols[len(_aCols)][_nBase5]	:= aChvInfo[20][_nX][13][16]
	_aCols[len(_aCols)][_nBase6]	:= aChvInfo[20][_nX][13][14]
	_aCols[len(_aCols)][_nValo5]	:= aChvInfo[20][_nX][13][18]	// Cofins
	_aCols[len(_aCols)][_nValo6]	:= aChvInfo[20][_nX][13][19]	// Pis
	_aCols[len(_aCols)][_nFrete]	:= if(valtype(aChvInfo[20][_nX][14])=="N",aChvInfo[20][_nX][14],val(aChvInfo[20][_nX][14]))
Next
lOk := .F.
nOpc := 3
_oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],_cTitle,,,,,,,,,.T.)                                                // 3
_oEnChoice:=MSMGet():New( _cAliasC, (_cAliasC)->(Recno()), 3,,,,_aCampos,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3]-50,aPosObj[1,4]},,3,1,,,_oDlg)
_oGet:=MsNewGetDados():New( aPosObj[2,1]-50,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4] ,_nStyle,,,"+PA2_ITEM",,,110 ,,,.t.,_oDlg ,_aHeader,_aCols)
//_oGet:=MsGetDados():New( aPosObj[2,1]-50,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4] ,3,,,"+PA2_ITEM",,,,,9999,)
_oDlg:lCentered	:= .T.
//_oDlg:Activate()
ACTIVATE MSDIALOG _oDlg ON INIT (EnchoiceBar(_oDlg,{|| Iif(.T.,(lOk := .T., _oDlg:End()),.F.) },{|| _oDlg:End()},,@_aButtons))
If lOk
	If MsgYesNo("Confirma a inclusão","Atenção!")
		aCabec    := {}
		aItem     := {}
		aItensT   := {}
		aLinha    := {}
		aAdd(aCabec, { "F2_TIPO"   , M->PA1_TIPO   })
		aAdd(aCabec, { "F2_DOC"    , M->PA1_DOC    })
		aAdd(aCabec, { "F2_SERIE"  , M->PA1_SERIE  })
		aAdd(aCabec, { "F2_EMISSAO", M->PA1_DATA   })
		aAdd(aCabec, { "F2_CLIENTE", M->PA1_CLIENT })
		aAdd(aCabec, { "F2_LOJA"   , M->PA1_LOJA   })
		aAdd(aCabec, { "F2_ESPECIE", M->PA1_ESPEC  })
		_nXDesc := 0
		For _nX := 1 To Len(_aCols)
			If _aCols[_nX][_nQTD] == 0 .Or. _aCols[_nX][_nVLR] == 0 .Or. _aCols[_nX][_nVLRTOT] == 0
				Loop
			EndIf
			If !_aCols[_nX][len(_aHeader)+1]
				_nXDesc += _aCols[_nX][_nDESC]
			EndIf
		Next
		aAdd(aCabec,{"F2_FORMUL",	"N" })
		aAdd(aCabec,{"F2_COND",		"001" })
		aAdd(aCabec,{"F2_DESCONT",	_nXDesc })
		aAdd(aCabec,{"F2_FRETE",	M->PA1_FRETE })
		aAdd(aCabec,{"F2_SEGURO",	aChvInfo[30,02] })
		aAdd(aCabec,{"F2_DESPESA",	aChvInfo[30,03] })
		aAdd(aCabec,{"F2_CHVNFE",	aChvInfo[11] })
		_nLinha := 0
		_cLinha := "00"
		For _nX := 1 To Len(_aCols)
			aLinha := {}
			If _aCols[_nX][_nQTD] == 0 .Or. _aCols[_nX][_nVLR] == 0 .Or. _aCols[_nX][_nVLRTOT] == 0
				Loop
			EndIf
			If !_aCols[_nX][Len(_aHeader) + 1] // Nao apagado
				_nLinha++
				_cLinha := Soma1(_cLinha)
				aAdd(aLinha,{"D2_ITEM" 		,_cLinha					,Nil})
				aAdd(aLinha,{"D2_COD" 		,_aCols[_nX][_nCod]			,Nil})
				aAdd(aLinha,{"D2_QUANT"		,_aCols[_nX][_nQTD]			,Nil})
				aAdd(aLinha,{"D2_PRCVEN"	,_aCols[_nX][_nVLR]			,Nil})
				aAdd(aLinha,{"D2_TOTAL"		,_aCols[_nX][_nVLRTOT]		,Nil})
				aAdd(aLinha,{"D2_TES"		,_aCols[_nX][_nTES]			,Nil})
				aAdd(aLinha,{"D2_CF"		,_aCols[_nX][_nCF]			,Nil})
				aAdd(aLinha,{"D2_DESC"		,_aCols[_nX][_nDESC]		,Nil})
				aAdd(aLinha,{"D2_NFORI"		,_aCols[_nX][_nNFORI]		,Nil})
				aAdd(aLinha,{"D2_SERIORI"	,_aCols[_nX][_nSERORI]		,Nil})
				aAdd(aLinha,{"D2_ITEMORI"	,_aCols[_nX][_nITORI]		,Nil})
				aAdd(aLinha,{"D2_BASEICM"	,_aCols[_nX][_nBICMS]		,Nil})
				aAdd(aLinha,{"D2_PICM"		,_aCols[_nX][_nPICM]		,Nil})
				aAdd(aLinha,{"D2_VALICM"	,_aCols[_nX][_nVALICM]		,Nil})
				aAdd(aLinha,{"D2_BRICMS"	,_aCols[_nX][_nBRICMS]		,Nil})
				aAdd(aLinha,{"D2_ICMSRET"	,_aCols[_nX][_nICMSRE]		,Nil})
				aAdd(aLinha,{"D2_ICMSCOM"	,_aCols[_nX][_nICMSCO]		,Nil})
				//aadd(aLinha,{"D2_DIFAL"		,_aCols[_nX][_nDIFAL]		,Nil})
				//aadd(aLinha,{"D2_ALFCCMP"	,_aCols[_nX][_nALFCCM]		,Nil})
				//aadd(aLinha,{"D2_VFCPDIF"	,_aCols[_nX][_nVFCPDI]		,Nil})
				aAdd(aLinha,{"D2_BASEIPI"	,_aCols[_nX][_nBASEIP]		,Nil})
				aAdd(aLinha,{"D2_IPI"		,_aCols[_nX][_nIPI]			,Nil})
				aAdd(aLinha,{"D2_VALIPI"	,_aCols[_nX][_nVALIPI]		,Nil})
				aAdd(aLinha,{"D2_VALFRE"	,_aCols[_nX][_nFrete]		,Nil})
				aAdd(aItensT,aLinha)
			EndIf
		Next
		MsExecAuto({|x,y,z| Mata920(x,y,z)}, aCabec, aItensT, 3) // Inclusao
		If lMsErroAuto
			MostraErro()
			Return .F.
		Else
			_nLinha  := 0
			_nXBasRet := 0
			_nXICMSRe := 0
			SF3->(dbSetOrder(5))
			If SF3->(DbSeek(xFilial("SF3")+M->PA1_SERIE+M->PA1_DOC+M->PA1_CLIENT+M->PA1_LOJA))
				While !SF3->(Eof()) .and. SF3->F3_FILIAL == xFilial("SF3") .and. SF3->F3_SERIE == M->PA1_SERIE .and. SF3->F3_NFISCAL == M->PA1_DOC .and. SF3->F3_CLIEFOR == M->PA1_CLIENT .and. SF3->F3_LOJA == M->PA1_LOJA
					SF3->(RecLock("SF3",.F.))
					SF3->F3_VALCONT := 0
					SF3->(MsUnlock())
					SF3->(dbSkip())
				End
			EndIf
			_cLinha := "00"
			For _nX:=1 to Len(_aCols)
				If !_aCols[_nX][len(_aHeader)+1]
					_nLinha ++
					_cLinha := soma1(_cLinha)
					SD2->(dbSetOrder(3))
					If SD2->(dbSeek(xFilial("SD2")+M->PA1_DOC+M->PA1_SERIE+M->PA1_CLIENT+M->PA1_LOJA+_aCols[_nX][_nCod]+_cLinha))
						SD2->(RecLock("SD2",.F.))
						SD2->D2_BRICMS  := _aCols[_nX][_nBRICMS]
						SD2->D2_ICMSRET := _aCols[_nX][_nICMSRE]
						SD2->D2_ALQIMP5 := _aCols[_nX][_nAliq5]
						SD2->D2_ALQIMP6 := _aCols[_nX][_nAliq6]
						SD2->D2_BASIMP5 := _aCols[_nX][_nBase5]
						SD2->D2_BASIMP6 := _aCols[_nX][_nBase6]
						SD2->D2_VALIMP5 := _aCols[_nX][_nValo5]
						SD2->D2_VALIMP6 := _aCols[_nX][_nValo6]
						SD2->D2_ORIGLAN	:= '' // Douglas 01/11/2018
						SD2->(MsUnlock())
						_nXBasRet += _aCols[_nX][_nBRICMS]
						_nXICMSRe += _aCols[_nX][_nICMSRE]
						SFT->(dbSetOrder(1))
						If SFT->(dbSeek(xFilial("SFT")+"S"+M->PA1_SERIE+M->PA1_DOC+M->PA1_CLIENT+M->PA1_LOJA+_cLinha+"  "+_aCols[_nX][_nCod] ))
							SFT->(RecLock("SFT",.F.))
							SFT->FT_BASERET := _aCols[_nX][_nBRICMS]
							SFT->FT_ICMSRET := _aCols[_nX][_nICMSRE]
							SFT->FT_ALIQCOF := _aCols[_nX][_nAliq5]
							SFT->FT_ALIQPIS := _aCols[_nX][_nAliq6]
							SFT->FT_BASECOF := _aCols[_nX][_nBase5]
							SFT->FT_BASEPIS := _aCols[_nX][_nBase6]
							SFT->FT_VALCOF  := _aCols[_nX][_nValo5]
							SFT->FT_VALPIS  := _aCols[_nX][_nValo6]
							//SFT->FT_VALCONT := SFT->(FT_BASEICM + FT_VALIPI + FT_ICMSRET)
							SFT->FT_VALCONT := SD2->(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_VALFRE)
							SFT->FT_TOTAL	:= SFT->FT_VALCONT
							SFT->(MsUnlock())
							SF3->(dbSetOrder(5))
							If SF3->(dbSeek(xFilial("SF3")+M->PA1_SERIE+M->PA1_DOC+M->PA1_CLIENT+M->PA1_LOJA+SFT->FT_IDENTF3))
								If _nXBasRet > 0 .or. _nXICMSRe > 0
									SF3->(RecLock("SF3"),.F.)
									SF3->F3_BASERET := _nXBasRet
									SF3->F3_ICMSRET := _nXICMSRe
									SF3->(MsUnlock())
								EndIf
								SF3->(RecLock("SF3"),.F.)
								SF3->F3_VALCONT += SFT->FT_VALCONT
								SF3->F3_CHVNFE  := aChvInfo[11]
								SF3->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf
			Next
			MsgAlert("Nota fiscal de saída gerada com sucesso!","Atenção!")
			Return .T.
		EndIF
	EndIf
EndIf
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³fCols     ºAutor  ³Frank Z Fuga        º Data ³  05/17/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ montagem do acols                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fCols(aHeader,cAlias,nIndice,cChave,cCondicao,cFiltro)
Local nPos
Local aCols0
Local aCols     := {}
Local cAliasAnt := Alias()
DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(nIndice))
(cAlias)->(DbSeek(cChave, .T.))
While (cAlias)->(!EOF() .And. &cCondicao)
	If !(cAlias)->(&cFiltro)
		(cAlias)->(DbSkip())
		Loop
	EndIf
	aCols0 := {}
	For nPos := 1 To Len(aHeader)
		If !aHeader[nPos,10] == "V" // x3_context
			(cAlias)->(aAdd(aCols0, FieldGet(FieldPos(aHeader[nPos,2]))))
		Else
			(cAlias)->(aAdd(aCols0, CriaVar(aHeader[nPos,2])))
		EndIf
	Next
	aAdd(aCols0, .F.) // Deleted
	aAdd(aCols, aCols0)
	(cAlias)->(DbSkip())
End
If Empty(aCols)
	aCols0 := {}
	For nPos := 1 to Len(aHeader)
		(cAlias)->(aAdd(aCols0,CriaVar(aHeader[nPos,2])))
	Next
	aAdd(aCols0, .F.) // Deleted
	aAdd(aCols, aCols0)
EndIf
aCols0 := {}
For nPos := 1 To Len(aHeader)
	(cAlias)->(aAdd(aCols0, CriaVar(aHeader[nPos,2])))
Next
aAdd(aCols0, .F.) // Deleted
DbSelectArea(cAliasAnt)
Return aClone(aCols)
