#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #include "totvs.ch"
//#INCLUDE "PROTHEUS.CH"
// #include "tryexception.ch"

Static xOldMsg		:= ""
Static cTmpTagICM	:= ""
Static cTmpTagIPI	:= ""
Static cTmpTagPIS	:= ""
Static cTmpTagCOF	:= ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ fXMLcpo  บAutor  ณ Cristiam Rossi     บ Data ณ  25/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche campo, valida e dispara gatilhos                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                Jonathan Schmidt Alves บ Data ณ  29/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ITUP / ECCO                                                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function fXMLcpo(cCampo, xValor, laCols, lValid, lGatilho)
Local cOldReadVar := __READVAR
Local nPos := GDFieldPos(cCampo)
Local lRetVal := .T.
Local aAreaSX3
Local xValid := ""
Default cCampo := ""
Default xValor := ""
Default laCols := .T.
Default lValid := .T.
Default lGatilho := .T.
ConOut("fXMLcpo: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If Empty(cCampo) .Or. Empty(xValor)
	Return
EndIf
If laCols .And. nPos == 0
	Return
EndIf
// TRY EXCEPTION
__READVAR := "M->" + cCampo
If laCols
	aCols[n][nPos] := xValor
EndIf
&(__READVAR) := xValor
If lValid
	//lRetVal := CheckSX3(cCampo, xValor)

	 //Busca as valida็๕es do campo
    cVldSis := GetSX3Cache(cCampo, "X3_VALID")
	//Chama a valida็ใo do sistema
	If ! Empty(cVldSis)
		if cCampo == "C6_QTDVEN" // caso em releases futuros esse processo demore , recarregar os indices das tabelas  
		//RegToMemory("SC6",.T.,.F.)
			lRetVal := A410QTDGRA() 
			if lRetVal
				lRetVal := A410SegUm()
			endif
			if lRetVal
				lRetVal := A410MultT()// C6_DESCONT ou C6_VALDESC
			endif
			if lRetVal
				lRetVal := a410Refr("C6_QTDVEN")
			endif	
		else
			lRetVal := &(cVldSis)
		endif
	EndIf
	if lRetVal
		cVldUsr := GetSX3Cache(cCampo, "X3_VLDUSER")
		//Chama a valida็ใo de usuแrio
		If ! Empty(cVldUsr) .And. lRetVal
			lRetVal := &(cVldUsr)
		EndIf
	endif
EndIf
If lRetVal .And. lGatilho .And. ExistTrigger(cCampo)
	If laCols
		RunTrigger(2,   N, Nil, Nil, cCampo)
	Else
		RunTrigger(1, Nil, Nil, Nil, cCampo)
	EndIf
EndIf
// CATCH EXCEPTION
// lRetVal := .F.
// END TRY
__READVAR := cOldReadVar
ConOut("fXMLcpo: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return lRetVal

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ c2oXML   บAutor  ณCristiam Rossi      บ Data ณ  28/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe XML string e devolve XML objeto                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ XML automatizado                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function c2oXML(cXml)
Local cDelimit := "_"
Local cError   := ""
Local cWarning := ""
Local oXml := nil
Default cXml := ""
ConOut("c2oXML: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
// TRY EXCEPTION
oXml := XmlParser(cXml, cDelimit, @cError, @cWarning)
// CATCH EXCEPTION
// END TRY

ConOut("")
If ValType(oXml) != "O" // Nao teve exito na geracao do Objeto
	ConOut("c2oXML: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Falha na geracao do objeto a partir do XML!")
Else // Sucesso
	ConOut("c2oXML: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Sucesso na geracao do objeto a partir do XML!")
EndIf
ConOut("c2oXML: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Conteudo de cXml:")
ConOut(cXml)
ConOut("")

ConOut("c2oXML: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return oXml

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeXML     บAutor  ณCristiam Rossi      บ Data ณ  28/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ l๊ arquivo XML e retorna seu conte๚do (string)             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ XML automatizado                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function LeXML( cFile )
Local aArea  := GetArea()
Local cXml   := ""
Local xPos
Local xParte
Local xPos1
Local xToken
if FT_FUSE(cFile) == -1
	RestArea( aArea )
	Return ""
endif
while !FT_FEOF()
	cXml += FT_FREADLN()
	FT_FSKIP()
end
FT_FUSE()
RestArea( aArea )
if ! Empty( cXml)	// tratativa pra troca de tokens externos a opera็ใo
	// 		if _tipoNF == "D"
	xPos := AT("nfeproc", lower(cXml))
	if xPos == 0
		//	  			cXml   := ""
	else
		xPos--
		xParte := subStr( cXml, 1, xPos )
		xPos1  := RAT("<", xParte)
		if xPos1 == 0
			cXml   := ""
		else
			xPos1++
			xToken := subStr(xParte, xPos1, xPos-xPos1+1)
			if ! Empty( xToken )
				cXml := strTran( cXml, "<" +xToken, "<" )
				cXml := strTran( cXml, "</"+xToken, "</" )
			endif
		endif
	endif
	// 		endif
endif
Return cXml

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeTXT     บAutor  ณCristiam Rossi      บ Data ณ  22/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ l๊ arquivo TXT e retorna seu conte๚do (array)              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ XML automatizado                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function LeTXT( cFile )
Local aArea  := GetArea()
Local cLinha
Local aDados := {}
if FT_FUSE(cFile) == -1
	RestArea( aArea )
	Return ""
EndIf
While !FT_FEOF()
	cLinha := FT_FREADLN()
	if Left(cLinha, 1) == "1"	// Cabe็alho
		_vLayout := subStr( cLinha, 2, 3 )
	endif
	if Left(cLinha, 1) == "2"
		//			aadd( aDados, Separa( cLinha, ";", .T. ))
		aadd( aDados, cLinha )
	endif
	FT_FSKIP()
End
FT_FUSE()
RestArea( aArea )
Return aDados

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ tstSXE   บAutor  ณCristiam Rossi      บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para validar a exist๊ncia e retornar novo SXE       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function tstSXE( cAlias, cCampo, nOrdem )
Local   aArea := GetArea()
Local   cNovo
Local   cFili := xFilial( cAlias )
Default nOrdem := 1
(cAlias)->( dbSetOrder( nOrdem ) )
while .T.
	cNovo := getSXEnum( cAlias, cCampo )
	if (cAlias)->( dbSeek( cFili + cNovo, .T. ) )
		confirmSX8()
	else
		exit
	endif
end
RestArea( aArea )
Return cNovo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ TrataSE4 บAutor  ณCristiam Rossi      บ Data ณ  09/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa e/ou cadastra e retorna c๓digo da Condi็ใo de     บฑฑ
ฑฑบ          ณ pagamento conforme duplicatas da NF                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function TrataSE4()
Local cCond := "000" // Padrใo "000" - a Vista
Local aArea := GetArea()
Local nValNF := 0
Local aDupl := {}
Local lFound := .F.

Local cTipoNF := "1" // Tipo 1 da Cond. Pagto
Local dTempDt := CtoD("")
Local nTempVl := 0
Local nTempInt := 0

Local cProblema := ""

Local _cFilSE4 := xFilial("SE4")

Private aItens   := {}
Private nI
SE4->(DbSetOrder(1)) // E4_FILIAL + E4_CODIGO
If SE4->(!DbSeek(_cFilSE4 + cCond))
	If Aviso("Condi็ใo de Pagamento inexistente","A Condi็ใo de Pagamento [000 - a Vista] nใo foi encontrada, deseja criar?",{"Sim","Nใo"}) == 1
		If !CriarSE4("1", "0", "a Vista", "000")
			cProblema := "Nใo foi possํvel criar Cond.Pagto!"
			cCond     := ""
		EndIf
	Else
		cProblema := "Nใo encontrada Cond.Pagto: " + cCond
		Return .F.
	EndIf
EndIf


If Empty(cProblema) // Sem problemas
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT") != "U"		// DANFE
		nValNF := Val( aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT )
	EndIf
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT") != "U"			// CT-e
		nValNF := Val( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT )
		cCond  := AllTrim(SE4->E4_COND)
	EndIf
	If nValNF == 0		// nใo tem valor a NF, retorno o padrใo
		Return .T.
	EndIf
	// duplicata DANFE
	If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_COBR:_dup") != "U"
		aItens := Iif(Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_COBR:_dup") == "A", aClone(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_COBR:_dup), { aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_COBR:_dup })
	EndIf
	// duplicata CT-e
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTENORM:_COBR:_dup") != "U"
		aItens := Iif(Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTENORM:_COBR:_dup") == "A", aClone(aChvInfo[15]:_CTEPROC:_CTE:_INFCTENORM:_COBR:_dup), { aChvInfo[15]:_CTEPROC:_CTE:_INFCTENORM:_COBR:_dup })
	EndIf
	
	If Len(aItens) > 0 // Carregada matriz
		cCond := ""
		For nI := 1 To Len(aItens)
			If Empty(cProblema) // Sem problemas
				If u_ztipo("aItens[nI]:_dVenc:TEXT") == "U"
					cProblema := "Nใo encontrado Vencimento da dupl: " + Alltrim(Str(nI))
					// Return .F.
				EndIf
				If u_ztipo("aItens[nI]:_vDup:TEXT") == "U"
					cProblema := "Nใo encontrado Valor da dupl: " + Alltrim(Str(nI))
					// Return .F.
				EndIf
				
				If Empty(cProblema) // Sem problemas
					
					dTempDt  := StoD(Strtran(aItens[nI]:_dVenc:TEXT,"-",""))			// Data vencimento							// Ex: 11/07/2019
					nTempVl  := Val(aItens[nI]:_vDup:TEXT)								// Valor duplicata							// Ex: 3.553,50
					nTempInt := dTempDt - aChvInfo[05] + 1								// Data vencimento - Data Emissao + 1		// 11/07/2019 - 13/06/2019 + 1 = 28 + 1 = 29 dias diferenca
					aAdd(aDupl, { dTempDt, nTempVl, nTempInt })		   					// Vencto, Valor, Dias da Emissใo
					cCond += Iif(Empty(cCond), "", ",") + AllTrim(Str(nTempInt))
					
				Else // Problemas..
					
					lConfirm := u_AskYesNo(   4000,"Cond Pgto","Deseja prosseguir usando a Cond Pgto padrao (000 - A VISTA)?",cProblema,"","","Cancelar","UPDINFORMATION")
					If lConfirm // Confirmado
						cCond := "000"
					Else
						Return .F.
					EndIf
				EndIf
			EndIf
		Next
	Else // Matriz aItens nao carregada
		cProblema := "Nใo foi encontrada informacao a respeito de duplicatas no XML"
		lConfirm := u_AskYesNo(   4000,"Cond Pgto","Deseja prosseguir usando a Cond Pgto padrao (000 - A VISTA)?",cProblema,"Se for uma nota de remessa verificar TES (financeiro)","","Cancelar","UPDINFORMATION")
		If lConfirm // Cond Pgto
			cCond := "000"
		Else // Cancelado
			Return .F.
		EndIf
	EndIf
	If Empty(cCond) .And. _tipoNF != "CTE"		// nใo tem Duplicatas, retorno o padrใo
		Return cCond != ""	// cCond
	EndIf
	
	// Correcao para considerar registros da SE4 apenas da filial conforme xFilial (Jonathan 26/06/2019)
	SE4->(DbSeek(_cFilSE4)) // SE4->( DbGotop() )
	While SE4->(!EOF()) .And. SE4->E4_FILIAL == _cFilSE4
	
		If AllTrim(SE4->E4_COND) == cCond
			cCond  := SE4->E4_CODIGO
			lFound := .T.
			Exit
		EndIf
		SE4->(DbSkip())
	End
	
	If !lFound // Cria็ใo da Condi็ใo de Pagamento
		cDescri := cCond + " D"
		If Len(cDescri) > len(SE4->E4_DESCRI)
			cDescri := AllTrim(Str(Len(aDupl))) + " vezes"
		EndIf
		If !CriarSE4(cTipoNF, cCond, cDescri)
			cProblema := "Nใo foi possํvel criar Cond.Pagto!"
			cCond     := ""
		EndIf
	EndIf
	
EndIf

RestArea(aArea)
Return cCond != ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ criarSE4 บAutor  ณCristiam Rossi      บ Data ณ  09/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo da Condi็ใo de Pagamento                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CriarSE4(cTipoNF, cCond, cDescri, cCod)
Local aArea := GetArea()
Local lSXE  := .F.
Local nI
Default cCod  := ""
Begin Sequence
dbSelectArea("SE4")
regToMemory("SE4")
M->E4_FILIAL  := xFilial("SE4")
If !Empty(cCod)
	M->E4_CODIGO := cCod
EndIf
If Empty(cCod) // Empty( M->E4_CODIGO )
	lSXE := .T.
	M->E4_CODIGO := U_tstSXE("SE4","E4_CODIGO")		// garante que o Numerador nใo exista na base
EndIf
M->E4_TIPO    := cTipoNF
M->E4_COND    := cCond
M->E4_DESCRI  := cDescri
RecLock("SE4", .T.)
For nI := 1 To FCount()
	FieldPut( nI, &("M->"+FieldName(nI)) )
Next
MsUnlock()
End Sequence
If lSXE
	if M->E4_COND == Alltrim(SE4->E4_COND)
		ConfirmSX8()
	else
		RollBackSx8()
	endif
endif
RestArea(aArea)
Return M->E4_COND == Alltrim(SE4->E4_COND)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ TrataSB1 บAutor  ณCristiam Rossi      บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa e/ou cadastro de Produtos                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function TrataSB1()
Local aArea := GetArea()
Local aProds := {}
Local nRecnoB1
Local xProd
Local xNCM := Replicate("0", 8)
Local xCodBar := Space(Len(SB1->B1_CODBAR))
Local xDescri := ""
Local xCFOP := Space(5)
Local xUM := Space(2)
Local xQtd := 1
Local xVunit := 0
Local xVtotal := 0
Local xVdesc := 0
Local xCEST := ""
Local xCodServ := ""
Local xFRETE := 0

Local xPIpi := 0

Local aImpost
Local lAborta := .F.
Private aItens := {}
Private nI
ConOut("TrataSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If _tipoNF == "P" // PREFEITURA
	xProd := GetMV("MV_XSERVIC")
	If _vLayout == "001"
		xDescri := AllTrim(SubStr(aNFS, 886))
	ElseIf _vLayout == "002"
		xDescri := AllTrim(SubStr(aNFS, 924))
	ElseIf _vLayout == "003"
		xDescri := AllTrim(SubStr(aNFS, 1037))
	ElseIf _vLayout == "004"
		xDescri := AllTrim(SubStr(aNFS, 1373))
	EndIf
	xUM      := "UN"
	xVunit   := Val(SubStr(aNFS, 448, 15)) / 100
	xVtotal  := xVunit
	xCodServ := subStr(aNFS, 478, 5)
	aImpost  := TratImp() // Chamada da tratativa dos Impostos
	nRecnoB1 := BuscaSB1(xProd, xNCM, xCodBar, xDescri, xNCM)
	aAdd(aProds, { nRecnoB1, xProd, xCodBar, xDescri, xNCM, xCFOP, xUM, xQtd, xVunit, xVtotal, xVdesc, xCEST, aClone(aImpost), 0 })
EndIf
If _tipoNF == "G" // GINFES
	If Type("aNFS:_NS3_SERVICO") != "U"
		xProd := getMV("MV_XSERVIC")
		If Type("aNFS:_NS3_SERVICO:_NS3_DISCRIMINACAO:TEXT") != "U"
			xDescri := aNFS:_NS3_SERVICO:_NS3_DISCRIMINACAO:TEXT
		EndIf
		xUM := "UN"
		If Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT") != "U"
			xVunit := Val( aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_VALORSERVICOS:TEXT )
		EndIf
		xVtotal  := xVunit
		If Type("aNFS:_NS3_SERVICO:_NS3_ITEMLISTASERVICO:TEXT") != "U"
			xCodServ := aNFS:_NS3_SERVICO:_NS3_ITEMLISTASERVICO:TEXT
		EndIf
		aImpost := TratImp()	// chamada da tratativa dos Impostos
		nRecnoB1 := BuscaSB1( xProd, xNCM, xCodBar, xDescri, xNCM )
		SB1->(DbGoto(nRecnoB1))
		If SB1->(Recno()) == nRecnoB1
			RecLock("SB1",.F.)
			SB1->B1_ALIQISS := aImpost[6]
			SB1->(MsUnlock())
		EndIf
		aAdd(aProds, { nRecnoB1, xProd, xCodBar, xDescri, xNCM, xCFOP, xUM, xQtd, xVunit, xVtotal, xVdesc, xCEST, aClone(aImpost), 0 })
	EndIf
EndIf
If _tipoNF == "D" // DANFE
	if (Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_det") != "U") .Or. (Type("aChvInfo[15]:_NFE:_INFNFE:_det") != "U") // Douglas Telles 31/10/2018
		If Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_det") != "U"
			aItens := iif( Type("aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_det") == "A", aClone(aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_det), {aChvInfo[15]:_NFEPROC:_NFE:_INFNFE:_det} )
		ElseIf Type("aChvInfo[15]:_NFE:_INFNFE:_det") != "U"
			aItens := iif( Type("aChvInfo[15]:_NFE:_INFNFE:_det") == "A", aClone(aChvInfo[15]:_NFE:_INFNFE:_det), {aChvInfo[15]:_NFE:_INFNFE:_det} )
		EndIf
		For nI := 1 To Len(aItens)
			xProd   := ""
			xNCM    := ""
			xCodBar := ""
			xDescri := ""
			xCFOP   := Space(Len(SF4->F4_CF))
			xUM     := ""
			xQtd    := 0
			xVunit  := 0
			xVtotal := 0
			xVdesc  := 0
			xCEST   := ""
			xFRETE  := 0
			aImpost := {} // impostos { ICMS, IPI, PIS, COFINS }
			If u_ztipo("aItens[nI]:_Prod:_cProd:TEXT") != "U"
				xProd := aItens[nI]:_Prod:_cProd:TEXT
				//if len( xProd ) > len( SB1->B1_COD )
				//xProd := right( alltrim( xProd ), len( SB1->B1_COD ) )
				xProd := AllTrim(xProd) + Space(TamSX3("B1_COD")[1] -  Len(AllTrim(xProd)))
				xProd := SubStr(xProd, Len(xProd)- TamSX3("B1_COD")[1],TamSX3("B1_COD")[1])
				//endif
			EndIf
			If u_ztipo("aItens[nI]:_Prod:_NCM:TEXT") != "U"
				xNCM := aItens[nI]:_Prod:_NCM:TEXT
			EndIf
			if u_ztipo("aItens[nI]:_Prod:_cEAN:TEXT") != "U"
				IF !("SEM" $ aItens[nI]:_Prod:_cEAN:TEXT)
					xCodBar := aItens[nI]:_Prod:_cEAN:TEXT
				ENDIF
			EndIf
			if Empty(xCodBar) .and. u_ztipo("aItens[nI]:_Prod:_cEANtrib:TEXT") != "U"
				IF !("SEM" $ aItens[nI]:_Prod:_cEANtrib:TEXT)
					xCodBar := aItens[nI]:_Prod:_cEANtrib:TEXT
				ENDIF
			EndIf
			if Empty( xProd )			// Consist๊ncias - falhou c๓d. Produto, pega C๓digo de Barras
				xProd := xCodBar
			EndIf
			if Empty( xProd )			// Consist๊ncias - falhou c๓d. Produto, C๓digo de Barras.. pega NCM
				xProd := xNCM
			EndIf
			if Empty( xProd )
				cProblema := "Produto Item ["+Alltrim(Str(nI))+"] estแ sem os C๓digos"
				return .F.
			endif
			if u_ztipo("aItens[nI]:_Prod:_xProd:TEXT") != "U"
				xDescri := LimpaSPC( aItens[nI]:_Prod:_xProd:TEXT )
			endif
			if u_ztipo("aItens[nI]:_Prod:_CFOP:TEXT") != "U"
				xCFOP := PadR(aItens[nI]:_Prod:_CFOP:TEXT, len( SF4->F4_CF ) )
			endif
			if u_ztipo("aItens[nI]:_Prod:_uCom:TEXT") != "U"
				xUM := aItens[nI]:_Prod:_uCom:TEXT
			endif
			if Empty(xUM) .and. u_ztipo("aItens[nI]:_Prod:_uTrib:TEXT") != "U"
				xUM := aItens[nI]:_Prod:_uTrib:TEXT
			endif
			if u_ztipo("aItens[nI]:_Prod:_qCom:TEXT") != "U"
				xQtd := Val( aItens[nI]:_Prod:_qCom:TEXT )
			endif
			if xQtd == 0 .and. u_ztipo("aItens[nI]:_Prod:_qTrib:TEXT") != "U"
				xQtd := Val( aItens[nI]:_Prod:_qTrib:TEXT )
			endif
			if u_ztipo("aItens[nI]:_Prod:_vUnCom:TEXT") != "U"
				xVunit := Val( aItens[nI]:_Prod:_vUnCom:TEXT )
			endif
			if xVunit == 0 .and. u_ztipo("aItens[nI]:_Prod:_vUnTrib:TEXT") != "U"
				xVunit := Val( aItens[nI]:_Prod:_vUnTrib:TEXT )
			endif
			if u_ztipo("aItens[nI]:_Prod:_vProd:TEXT") != "U"
				xVtotal := Val( aItens[nI]:_Prod:_vProd:TEXT )
			endif
			if u_ztipo("aItens[nI]:_Prod:_vDesc:TEXT") != "U"
				xVdesc := Val( aItens[nI]:_Prod:_vDesc:TEXT )
			endif
			if u_ztipo("aItens[nI]:_Prod:_CEST:TEXT") != "U"
				xCEST := aItens[nI]:_Prod:_CEST:TEXT
			endif
			if u_ztipo("aItens[nI]:_Prod:_vFrete:TEXT") != "U"
				xFRETE := aItens[nI]:_Prod:_vFrete:TEXT
			endif
			// Alteracao trecho (Jonathan 26/06/2019) Obtencao do Percentual de IPI tributado
			If u_ztipo("aItens[nI]:_Imposto:_Ipi:_IPITrib:_PIPI:TEXT") != "U"
				xPIpi := Val( aItens[nI]:_Imposto:_Ipi:_IPITrib:_PIPI:TEXT )
			EndIf
			
			nRecnoB1 := BuscaSB1( xProd, xNCM, xCodBar, xDescri, xNCM, xPIpi ) // Incluido IPI
			u_NFImpAut(Iif(isInCallStack("U_GETCHVNFE"), "E", "S"), _cCgcEmi, _cCgcDes, xCFOP)
			// chamada da tratativa dos Impostos
			if u_ztipo("aItens[nI]:_imposto") != "U"
				aImpost := TratImp(aItens[nI]:_imposto, xCFOP, xNCM, xDescri, @lAborta, xProd)
				If lAborta
					Return .F.
				EndIf
			Else
				aImpost := { {"0","  "}, "  ", "  ", "  ", 0, 0, 0 }	// ICMS: {origem, cst, retencao}, IPI: cst, PIS: cst, COFINS: cst, TES: record, AliqISS, AliqIPI
			EndIf //     {       01,    02,      03,      04,   05,    06,  07,   08,     09,      10,     11,    12, {          13 },     14 })
			aAdd(aProds, { nRecnoB1, xProd, xCodBar, xDescri, xNCM, xCFOP, xUM, xQtd, xVunit, xVtotal, xVdesc, xCEST, aClone(aImpost), xFRETE })
		next
	endif
endif
if _tipoNF == "CTE"		// CTE
	xProd   := getMV("MV_XPRDCTE")
	xDescri := "CONHECIMENTO DE TRANSPORTE"
	xUM     := "UN"
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT") != "U"			// CT-e
		xVunit := Val( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT )
	EndIf
	xVtotal  := xVunit
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT") != "U"			// CT-e
		xCFOP := PadR(aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT, len( SF4->F4_CF ) )
	EndIf
	// chamada da tratativa dos Impostos
	If Type("aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_imp") != "U"
		aImpost := TratImp( aChvInfo[15]:_CTEPROC:_CTE:_INFCTE:_imp, xCFOP, xNCM, xDescri )
	Else
		aImpost := { {"0","  "}, "  ", "  ", "  ", 0, 0, 0 }	// ICMS: {origem, cst, retencao}, IPI: cst, PIS: cst, COFINS: cst, TES: record, AliqISS
	EndIf
	nRecnoB1 := BuscaSB1(xProd, xNCM, xCodBar, xDescri, xNCM)
	aAdd(aProds, { nRecnoB1, xProd, xCodBar, xDescri, xNCM, xCFOP, xUM, xQtd, xVunit, xVtotal, xVdesc, xCEST, aClone(aImpost), 0 })
EndIf
// Verificar exist๊ncia dos produtos na base
For nI := 1 To Len(aProds)
	If aProds[nI][13][5] == 0 // TES em branco!
		cProblema := "Falha TES do Item [" + Alltrim(Str(nI)) + "] em branco!!!"
		Return .F.
	EndIf
	If aProds[nI][1] == 0 // Produto nใo existe na base
		If !CriarSB1(aProds[nI], xCodServ)
			cProblema := "Falha inclusใo Produto Item [" + Alltrim(Str(nI)) + "]"
			Return .F.
		EndIf
		aProds[nI][1] := SB1->(Recno())
	EndIf
Next
aChvInfo[20] := aClone(aProds) // Produtos
aChvInfo[21] := xCodServ
RestArea(aArea)
If Len(aChvInfo[20]) == 0
	cProblema := "Nใo foram encontrados Produtos!"
EndIf
ConOut("TrataSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return Len(aChvInfo[20]) > 0

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ BuscaSB1 บAutor  ณ Cristiam Rossi     บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa Produto na base de dados usando NCM e C๓digos     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BuscaSB1( xProd, xNCM, xCodBar, xDescri, xNCM, xAliqIPI )
Local nRecord   := 0
Local aArea     := getArea()
Local cAliasQry := getNextAlias()
Local cQuery
Local cCNPJ
Local oFont
Local xB1_COD
Local oDlg
Local lInclPRD := .F.
Default xAliqIPI := 0
ConOut("BuscaSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
/*
if _tipoNF != "D"
SB1->( dbSetOrder(1) )
if SB1->( dbSeek( xFilial("SB1") + xProd ) )
nRecord := SB1->( RECNO() )
endif

restArea( aArea )
return nRecord
endif
*/

//MsgInfo("BuscaSB1...")

//TODO: Analisar error log de chave duplicada na inclusao
If Select("QB1") > 0
	QB1->(DbCloseArea())
EndIf
cQuery2 := "SELECT R_E_C_N_O_ AS REG FROM " + RetSqlName("SB1") + " WHERE "
cQuery2 += "B1_FILIAL = '" + xFilial("SB1") + "' AND "
cQuery2 += "B1_COD = '" + xProd + "' AND "
cQuery2 += "D_E_L_E_T_ = '' "
cQuery2 := ChangeQuery(cQuery2)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"QB1",.F.,.T.)
DbSelectArea("QB1")
DbGotop()
_cRegX := QB1->REG
QB1->(DbCloseArea())
SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
SB1->(DbGoto(_cRegX))
If SB1->(!EOF())
	If RecLock("SB1",.F.)
		SB1->B1_IPI := xAliqIPI
		If SB1->B1_MSBLQL == "1" // Bloqueado
			SB1->B1_MSBLQL := "2" // Desbloqueia
		EndIf
		SB1->(MsUnlock())
	EndIf
	nRecord := SB1->(Recno())
	
EndIf
If _tipoNF != "D" .or. nRecord > 0
	RestArea(aArea)
	Return nRecord
EndIf
if isInCallStack("U_GETCHVNFE") .and. _tipoNF == "D"		// ้ NF Entrada e DANFE
	if aChvInfo[01] $ "D/B"			// buscar amarra็ใo Produto X Cliente
		/*
		SA7->( dbSetOrder(3) )
		if SA7->( dbSeek( xFilial("SA7") + aChvInfo[06] + aChvInfo[07] + xProd ) ) .and. ! empty( SA7->A7_PRODUTO )
		SB1->( dbSetOrder(1) )
		if SB1->( dbSeek( xFilial("SB1") + SA7->A7_PRODUTO ) )
		nRecord := SB1->( RECNO() )
		endif
		endif
		*/
		xTipo := "C"
	else							// buscar amarra็ใo Produto X Fornecedor
		/*
		SA5->( dbSetOrder(14) )
		if SA5->( dbSeek( xFilial("SA5") + aChvInfo[06] + aChvInfo[07] + xProd ) ) .and. ! empty( SA5->A5_PRODUTO )
		SB1->( dbSetOrder(1) )
		if SB1->( dbSeek( xFilial("SB1") + SA5->A5_PRODUTO ) )
		nRecord := SB1->( RECNO() )
		endif
		endif
		*/
		xTipo := "F"
	EndIf
	A_5->( dbSetOrder(1) )
	if A_5->( dbSeek( aChvInfo[06] + aChvInfo[07] + xTipo + xProd ) )
		SB1->( dbSetOrder(1) )
		if SB1->( dbSeek( xFilial("SB1") + A_5->A_5_PRDPAR ) )
			
			If RecLock("SB1", .F.)
				SB1->B1_IPI := xAliqIPI
				If SB1->B1_MSBLQL == "1"
					SB1->B1_MSBLQL := "2"
				EndIf
				
				SB1->(MsUnlock())
			EndIf
			nRecord := SB1->( RECNO() )
			
			
		endif
	endif
	
	/*
	if nRecord > 0
	return nRecord
	endif
	*/
	
	
	Define Font oFont name "Arial" Size 0,-14 Bold
	While nRecord == 0
		xB1_COD := Space( Len( SB1->B1_COD ) )
		DEFINE MSDIALOG oDlg FROM 0,0 TO 125, 500 TITLE "Amarra็ใo Produto X " + iif(aChvInfo[01] == "D","Fornecedor","Cliente") PIXEL
		@005,005 Say "C๓digo:"    of oDlg Pixel
		@004,035 Say xProd        of oDlg Pixel Font oFont
		@005,115 Say "NCM:"       of oDlg Pixel
		@004,130 Say xNCM         of oDlg Pixel Font oFont
		@020,005 Say "Descri็ใo:" of oDlg Pixel
		@019,035 Say xDescri      of oDlg Pixel Font oFont
		
		@040,005 Say "Produto:"   of oDlg Pixel
		@039,040 MsGet xB1_COD Valid Empty(xB1_COD).or.ExistCpo("SB1", xB1_COD) F3 "SB1" Size 60,8 of oDlg Pixel
		
		@040,130 Button "OK"      Size 40,15 of oDlg Pixel Action oDlg:end()
		@040,200 Button "Incluir" Size 40,15 of oDlg Pixel Action (lInclPRD := .T., oDlg:end())
		ACTIVATE MSDIALOG oDlg CENTERED
		if lInclPRD
			restArea( aArea )
			return 0
		endif
		
		if ! Empty( xB1_COD )
			SB1->( dbSetOrder(1) )
			if SB1->( dbSeek( xFilial("SB1") + xB1_COD ) )
				If RecLock("SB1", .F.)
					SB1->B1_IPI := xAliqIPI
					If SB1->B1_MSBLQL == "1"
						SB1->B1_MSBLQL := "2"
					EndIf
					
					SB1->(MsUnlock())
				EndIf
				nRecord := SB1->( RECNO() )
			endif
			
			If alltrim(xProd) != alltrim(xB1_COD)	// armazenar amarra็ใo
				If aChvInfo[01] $ "D/B"
					/*
					regToMemory("SA7", .T.)
					M->A7_FILIAL  := xFilial("SA7")
					M->A7_CLIENTE := aChvInfo[06]
					M->A7_LOJA    := aChvInfo[07]
					M->A7_PRODUTO := xB1_COD
					M->A7_CODCLI  := xProd
					
					recLock("SA7", .T.)
					for nJ := 1 to SA7->( fCount() )
					fieldPut( nJ, &("M->"+fieldName(nJ)) )
					next
					msUnlock()
					*/
					
					xTipo := "C"
				Else
					/*
					SA2->( dbSetOrder(1) )
					SA2->( dbSeek( xFilial("SA2")+ aChvInfo[06] + aChvInfo[07] ) )
					
					regToMemory("SA5", .T.)
					M->A5_FILIAL  := xFilial("SA5")
					M->A5_FORNECE := aChvInfo[06]
					M->A5_LOJA    := aChvInfo[07]
					M->A5_NOMEFOR := SA2->A2_NOME
					M->A5_CODPRF  := xProd
					M->A5_PRODUTO := SB1->B1_COD
					M->A5_NOMPROD := SB1->B1_DESC
					
					recLock("SA5", .T.)
					for nJ := 1 to SA5->( fCount() )
					fieldPut( nJ, &("M->"+fieldName(nJ)) )
					next
					msUnlock()
					*/
					xTipo := "F"
				endif
				
				recLock("A_5", .T.)
				A_5->A_5_COD    := aChvInfo[06]
				A_5->A_5_LOJA   := aChvInfo[07]
				A_5->A_5_TIPO   := xTipo
				A_5->A_5_PRDDE  := xProd
				A_5->A_5_PRDPAR := SB1->B1_COD
				A_5->A_5_DESPAR := SB1->B1_DESC
				MsUnlock()
				
			endif
		endif
	end
	Return nRecord
EndIf
cQuery := "select "
If "SQL" $ Upper(TcGetDB())
	cQuery += " top 1 "
EndIf
cQuery += " 1 pesq, SB11.R_E_C_N_O_ record, SB11.B1_COD from "+RetSqlName("SB1")+" SB11 "
cQuery += " where SB11.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery += " and SB11.B1_POSIPI='"+xNCM+"'"
cQuery += " and SB11.B1_COD='"+xProd+"'"
cQuery += " and SB11.D_E_L_E_T_=' '"
If "ORACLE" $ Upper(TcGetDB())
	cQuery += " and ROWNUM = 1 "
EndIf
cQuery += " union "
cQuery += "select "
If "SQL" $ Upper(TcGetDB())
	cQuery += " top 1 "
EndIf
cQuery += "2 pesq, SB12.R_E_C_N_O_  record, SB12.B1_COD from "+RetSqlName("SB1")+" SB12 "
cQuery += " where SB12.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery += " and SB12.B1_POSIPI='"+xNCM+"'"
cQuery += " and (SB12.B1_COD='"+xProd+"'"
If !empty(xCodBar)
	cQuery += " or SB12.B1_CODBAR='"+xCodBar+"')"
Else
	cQuery += " )"
EndIf
cQuery += " and SB12.D_E_L_E_T_=' '"
If "ORACLE" $ Upper(TcGetDB())
	cQuery += " and ROWNUM = 1 "
EndIf

/*
cQuery +=		" union "
cQuery += "select top 1 3 pesq, SB13.R_E_C_N_O_ record from "+RetSqlName("SB1")+" SB13 "
cQuery +=		" where SB13.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery +=		" and SB13.B1_POSIPI='"+xNCM+"'"
cQuery +=		" and SB13.D_E_L_E_T_=' '"
*/
cQuery += " order by 1 "
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
if !(cAliasQry)->( EOF() )
	nRecord := (cAliasQry)->record
	
	// Alteracao Jonathan 26/06/2019 (atualizar o B1_IPI
	SB1->(DbGoto(nRecord))
	If RecLock("SB1",.F.)
		SB1->B1_IPI := xAliqIPI
		If SB1->B1_MSBLQL == "1" // Bloqueado
			SB1->B1_MSBLQL := "2" // Desbloqueia
		EndIf
		SB1->(MsUnlock())
	EndIf
	// Fim do trecho
	
EndIf
(cAliasQry)->( dbCloseArea() )
ConOut("BuscaSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
RestArea(aArea)
Return nRecord

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ criarSB1 บAutor  ณCristiam Rossi      บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo Produtos                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade - XML                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CriarSB1( aProd, xCodServ )
//Local aArea    := getArea()
Local lSXE     := .F.
Local nI
Local cLocPad  := GetMV("MV_XLOCPAD")
Local cConta   := GetMV("MV_XCTAPRD")
Local xTemp
Local xOrigem  := "0"
Local cTipo    := ""
Local aAreaSX5 := {}
Local aTabIcms := {"S2", "SG"}
Local nTabIcms := 0
ConOut("CriarSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
if ! Empty( xCodServ )		// trata c๓digo do servi็o ISS
	xCodServ := alltrim(Str(Val(xCodServ)))
EndIf
/*
if aProd[13][5] > 0		// TES
SF4->( dbGoto( aProd[13][5] ) )
if aProd[13][5] == SF4->( RECNO() )
if ! Empty( SF4->F4_XCODDES )
xOrigem := SF4->F4_XCODDES
endif
if SF4->F4_CONSUMO == "S"
cTipo := "SV"
endif
endif
endif
*/
aAreaSX5 := SX5->(GetArea())
SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
For nTabIcms := 1 To Len(aTabIcms)
	aDadosSX5 := FWGetSX5(aTabIcms[nTabIcms])
	for nI := 1 to Len(aDadosSX5)
		cTmpTagICM := "oImp:_ICMS:_ICMS" + Alltrim(aDadosSX5[nI][3])
		If u_ztipo(cTmpTagICM) != "U"
			If u_ztipo(cTmpTagICM + ":_orig:TEXT") != "U"
				xOrigem := &(cTmpTagICM + ":_orig:TEXT")
			EndIf
			Exit
		EndIf
	Next
	If u_ztipo(cTmpTagICM) != "U"
		Exit
	EndIf
Next
xOrigem := IIF(Empty(xOrigem), "0", xOrigem)
RestArea(aAreaSX5)
aProd[07] := U_fBuscaUM( aProd[07] )	// Valida Unidade de Medida
if ! empty( xTemp := U_CFxCTA( aProd[06], "SB1" ) )
	cConta := xTemp
endif
Begin Sequence
dbSelectArea("SB1")
regToMemory("SB1", aProd[01] == 0)
M->B1_FILIAL   := xFilial("SB1")
/*
if Empty( M->B1_COD )
lSXE := .T.
M->B1_COD := U_tstSXE("SB1","B1_COD")		// garante que o Numerador nใo exista na base
endif
*/
M->B1_COD      := alltrim(aProd[02])+space(tamsx3("B1_COD")[1]-len(alltrim(aProd[02])))
M->B1_CODBAR   := aProd[03]
M->B1_DESC     := U_xSoDigit( aProd[04] )
M->B1_POSIPI   := aProd[05]
M->B1_UM       := aProd[07]
M->B1_LOCPAD   := cLocPad
M->B1_CONTA    := cConta
M->B1_CEST     := aProd[12]
M->B1_ORIGEM   := xOrigem		// aProd[13][1][1]
While Empty(cTipo)
	If U_fBuscaTp(@cTipo)
		M->B1_TIPO := cTipo
	Else
		Return .F.
	EndIf
End
M->B1_IPI      := aProd[13][7]	// aliquota IPI - 27/12/2016 - Cristiam
M->B1_CODISS   := xCodServ
/*
M->B1_PICMRET  := 	// (MVA)
M->B1_PICMENT  := 	// (MVA)
*/
If Select("QB1") > 0
	QB1->(dbCloseArea())
EndIf
cQuery2 := "SELECT R_E_C_N_O_ AS REG FROM " + RetSqlName("SB1")
cQuery2 += " WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = '"+M->B1_COD+"' "
cQuery2 := ChangeQuery(cQuery2)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery2),"QB1", .F., .T.)
dbSelectArea("QB1")
dbGotop()
_cRegX := QB1->REG
QB1->(dbCloseArea())
SB1->(dbGoto(_cRegX))
If SB1->(Eof())
	RecLock("SB1", .T.)
Else
	RecLock("SB1", .F.)
Endif
for nI := 1 to FCount()
	FieldPut( nI, &("M->"+FieldName(nI)) )
next
MsUnlock()

DbSelectArea("SB2")
SB2->(DbSetOrder(2)) // B2_FILIAL+B2_LOCAL+B2_COD
If !(SB2->(DbSeek(xFilial("SB2") + cLocPad + aProd[02])))
	CriaSB2( aProd[02], cLocPad )	// cria saldo zerado na SB2, evitando mensagem de "Deseja criar saldo no armazem"
EndIf

// Alteracao 29/01/2020 Jonathan (Para consultar uma Conta Contabil qdo incluir um produto)
lResCT1 := .F.
u_AskYesNo(1200,"Conta Contabil","Produto criado sem conta contabil!","Produto: " + SB1->B1_COD,RTrim(SB1->B1_DESC),"","","NOTE",.T.,.F.,{|| lResCT1 := ConPad1(,,,"CT1") }) // Leitura dos dados no arquivo .CSV
If lResCT1 // Confirmada Conta contabil
	RecLock("SB1",.F.)
	SB1->B1_CONTA := CT1->CT1_CONTA
	SB1->(MsUnlock())
EndIf


End Sequence
/*
if lSXE
if M->B1_POSIPI == Alltrim( SB1->B1_POSIPI )
ConfirmSX8()
else
RollBackSx8()
endif
endif
*/
//	restArea( aArea )
ConOut("CriarSB1: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return M->B1_POSIPI == AllTrim(SB1->B1_POSIPI)

User Function xSoDigit(cParEntr)
Local cValidos := "ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890.,"
Local cSaida   := ""
Local cEntrada := Alltrim( Upper( cParEntr ) )
Local xDigito
Local nI
For nI := 1 to len(cEntrada)
	xDigito := substr( cEntrada, nI, 1 )
	If xDigito $ cValidos
		cSaida += xDigito
	Else
		cSaida += "-"
	EndIf
Next
While At(Space(02), cSaida) > 0
	cSaida := StrTran(cSaida, Space(02), Space(01))
End
Return cSaida

User Function fBuscaUM( cUMorig )	// aProd[07]
Local aArea  := GetArea()
Local cRet   := cUMorig
Local cNewUM := Space(2)
Local oDlg
SAH->(DbSetOrder())
if SAH->(!DbSeek(xFilial("SAH") + cUMorig))
	if SX5->( dbSeek( xFilial("SX5")+"um"+cUMorig, .T.  ) )
		return left(FWGetSX5( "um",cUMorig ),2)
	endif
	FwPutSX5(, "00", "um", "De -> Para ", "Unidade de Medida", "XML CONTABIL")
	while empty(cNewUM)
		DEFINE MSDIALOG oDlg FROM 0,0 TO 125, 240 TITLE "Inconsistencia" PIXEL
		@005,005 say "A Unidade de Medida ["+cUMorig+"] e invalida!" of oDlg Pixel
		@020,005 say "Nova U.M.:" of oDlg Pixel
		@019,040 msGet cNewUM Picture "!!" Size 30,8 Valid ExistCpo("SAH", cNewUM) F3 "SAH" of oDlg Pixel
		@045,005 button " Ok " Size 30,12 of oDlg Pixel Action oDlg:end()
		ACTIVATE MSDIALOG oDlg CENTERED
	end
	FwPutSX5(, "um", cUMorig, cNewUM, "", "")
	cRet := cNewUM
else
	cRet := SAH->AH_UNIMED
endif

restArea( aArea )
return cRet

User Function fBuscaTp(cTipo)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local B1_TIPO	:= Space(TamSx3("B1_TIPO")[1])
Local oDlg
If SuperGetMV("IT_PERGTP",,"N") == "S"
	DEFINE MSDIALOG oDlg FROM 0,0 TO 130, 260 TITLE "Inconsist๊ncia" PIXEL
	@005,005 say "Informe o tipo do produto:" of oDlg Pixel
	@015,005 say M->B1_DESC of oDlg Pixel
	@025,005 say "Tipo Prod.:" of oDlg Pixel
	@025,040 MsGet B1_TIPO Picture PesqPict("SB1", "B1_TIPO") Valid IIF(Empty(B1_TIPO), .T., ExistCpo("SX5", "02" + B1_TIPO)) Size 30,8 F3 "02" of oDlg Pixel
	@045,005 button " Ok " Size 30,12 of oDlg Pixel Action oDlg:end()
	@045,040 button " Cancelar " Size 30,12 of oDlg Pixel Action (lRet := .F., oDlg:end())
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	lRet := .T.
	B1_TIPO := "PA"
EndIf
If lRet
	cTipo := B1_TIPO
EndIf
RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ TratImp  บAutor  ณ Cristiam Rossi     บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratativa dos Impostos dos Produtos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade XML                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function TratImp(xParam, cCFOP, xNCM, xDescri, lAborta, xProd)
Local aArea    := GetArea()
Local aAreaSF4 := SF4->( GetArea() )
Local aRet     := { {   "0","  ", 0,0,0,0,0}, "  "    , "  "    , "  "       ,           0,       0,       0,             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }		// ICMS: {origem, cst, reten็ใo}, IPI: cst, PIS: cst, COFINS: cst, TES: Record, AliqISS, AliqIPI, VICMSUFREMET
//                        1                   2     3     4   5  6  7  8  9 10 11 12 13 14 15 16 17, 18,19
Local xJ //         {origem, cst,  reten็ใo}, IPI: cst, PIS: cst, COFINS: cst, TES: Record, AliqISS, AliqIPI, VICMSUFREMET
Local cTemp
Local nRetAvis 	:= 0
Local xTES     	:= ""
Local xCond    	:= ""
Local xxMsg    	:= ""
Local aRecTes  	:= {}
Local aTabIcms 	:= {"S2", "SG"}
Local nTabIcms	:= 0
Local nX			:= 0
Local aOpcTagIPI	:= {"_IPINT", "_IPITRIB", "_IPIOutr"}
Local aOpcTagPIS	:= {"_PISNT", "_PISALIQ", "_PISOutr"}
Local aOpcTagCOF	:= {"_COFINSNT", "_COFINSALIQ", "_COFINSOutr"}
Private oImp     	:= xParam
Default xNCM     	:= ""
Default xDescri  	:= ""
Default xProd    	:= ""
ConOut("TrataImp: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
//	if _tipoNF == "D"
If _tipoNF $ "D;CTE"
	// I C M S
	If Type("oImp:_ICMS") != "U"
		cTmpTagICM := ""
		SX5->(DbSetOrder(1)) // X5_FILIAL + X5_TABELA + X5_CHAVE
		For nTabIcms := 1 To Len(aTabIcms)
			aDadosSX5 := FWGetSX5(aTabIcms[nTabIcms])
			for nI := 1 to Len(aDadosSX5)
				cTmpTagICM := "oImp:_ICMS:_ICMS" + Alltrim(aDadosSX5[nI][3])
				If u_ztipo(cTmpTagICM) != "U"
					Exit
				Else
					cTmpTagICM := ""
				EndIf
			Next
			If u_ztipo(cTmpTagICM) != "U"
				Exit
			EndIf
		Next
		If Empty(cTmpTagICM) .Or. Type(cTmpTagICM) == "U"
			cTmpTagICM := "oImp:_ICMS:_ICMSOutr"
			If Type(cTmpTagICM) == "U"
				cTmpTagICM := ""
			EndIf
		EndIf
		If !Empty(cTmpTagICM)
			If Type(cTmpTagICM + ":_orig:TEXT") != "U"
				aRet[01][01]  := &(cTmpTagICM + ":_orig:TEXT")
			EndIf
			If Type(cTmpTagICM + ":_CST:TEXT") != "U"
				aRet[01][02]  := &(cTmpTagICM + ":_CST:TEXT")
			EndIf
			If Type(cTmpTagICM + ":_vICMSSTRet:TEXT") != "U"	// Reten็ใo ICMS
				aRet[01][03] := val( &(cTmpTagICM + ":_vICMSSTRet:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_vICMSST:TEXT") != "U"	// Reten็ใo ICMS
				aRet[01][03] := val( &(cTmpTagICM + ":_vICMSST:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_vBCST:TEXT") != "U"	// Base ICMS ST
				aRet[01][04] := val( &(cTmpTagICM + ":_vBCST:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_pICMS:TEXT") != "U"	// Aliquota do ICMS
				aRet[01][05] := val( &(cTmpTagICM + ":_pICMS:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_vBC:TEXT") != "U"	// BaseICM
				aRet[01][06] := val( &(cTmpTagICM + ":_vBC:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_vICMS:TEXT") != "U"	// BaseICM
				aRet[01][07] := val( &(cTmpTagICM + ":_vICMS:TEXT") )
			EndIf
			If Type(cTmpTagICM + ":_pRedBC:TEXT") != "U"	// Base ICMS
				aRet[08] := val( &(cTmpTagICM + ":_pRedBC:TEXT") )
			EndIf
		EndIf
	EndIf
	
	// Reten็ใo ICMS
	//		if Type("oImp:_vTotTrib:TEXT") != "U"
	//			aRet[1][3] := val( oImp:_vTotTrib:TEXT )
	//		endif
	
	// I P I
	If Type("oImp:_IPI") != "U"
		cTmpTagIPI := ""
		For nX := 1 To Len(aOpcTagIPI)
			cTmpTagIPI := "oImp:_IPI:" + aOpcTagIPI[nX]
			If u_ztipo(cTmpTagIPI) == "O"
				Exit
			Else
				cTmpTagIPI := ""
			EndIf
		Next
		If !Empty(cTmpTagIPI) .And. Type(cTmpTagIPI) == "O"
			If Type(cTmpTagIPI + ":_CST:TEXT") != "U"
				aRet[02] := &(cTmpTagIPI + ":_CST:TEXT")
			EndIf
			If Type(cTmpTagIPI + ":_PIPI:TEXT") != "U"
				aRet[07] := Val(&(cTmpTagIPI + ":_PIPI:TEXT"))
			EndIf
			If Type(cTmpTagIPI + ":_vBC:TEXT") != "U"
				aRet[10] := Val(&(cTmpTagIPI + ":_vBC:TEXT"))
			EndIf
			If Type(cTmpTagIPI + ":_vIPI:TEXT") != "U"
				aRet[11] := Val(&(cTmpTagIPI + ":_vIPI:TEXT"))
			EndIf
		EndIf
	EndIf
	
	// P I S
	If Type("oImp:_PIS") != "U"
		cTmpTagPIS := ""
		For nX := 1 To Len(aOpcTagPIS)
			cTmpTagPIS := "oImp:_PIS:" + aOpcTagPIS[nX]
			If u_ztipo(cTmpTagPIS) == "O"
				Exit
			Else
				cTmpTagPIS := ""
			EndIf
		Next
		If !Empty(cTmpTagPIS) .And. Type(cTmpTagPIS) == "O"
			if Type(cTmpTagPIS + ":_CST:TEXT") != "U"
				aRet[03]  := &(cTmpTagPIS + ":_CST:TEXT")
			EndIf
			if Type(cTmpTagPIS + ":_pPIS:TEXT") != "U"
				aRet[12]  := val(&(cTmpTagPIS + ":_pPIS:TEXT"))
			EndIf
			if Type(cTmpTagPIS + ":_vBC:TEXT") != "U"
				aRet[14]  := val(&(cTmpTagPIS + ":_vBC:TEXT"))
			EndIf
			if Type(cTmpTagPIS + ":_vPIS:TEXT") != "U"
				aRet[19]  := val(&(cTmpTagPIS + ":_vPIS:TEXT"))
			EndIf
		EndIf
	EndIf
	
	// C O F I N S
	If Type("oImp:_COFINS") != "U"
		cTmpTagCOF := ""
		For nX := 1 To Len(aOpcTagCOF)
			cTmpTagCOF := "oImp:_COFINS:" + aOpcTagCOF[nX]
			If u_ztipo(cTmpTagCOF) == "O"
				Exit
			Else
				cTmpTagCOF := ""
			EndIf
		Next
		If !Empty(cTmpTagCOF) .And. Type(cTmpTagCOF) == "O"
			if Type(cTmpTagCOF + ":_CST:TEXT") != "U"
				aRet[04] := &(cTmpTagCOF + ":_CST:TEXT")
			EndIf
			if Type(cTmpTagCOF + ":_pCOFINS:TEXT") != "U"
				aRet[13] := val(&(cTmpTagCOF + ":_pCOFINS:TEXT"))
			EndIf
			if Type(cTmpTagCOF + ":_vBC:TEXT") != "U"
				aRet[16] := val(&(cTmpTagCOF + ":_vBC:TEXT"))
			EndIf
			if Type(cTmpTagCOF + ":_vCOFINS:TEXT") != "U"
				aRet[18] := val(&(cTmpTagCOF + ":_vCOFINS:TEXT"))
			EndIf
		EndIf
	EndIf
	
	// DIFAL
	/*
	if Type("oImp:_ICMSUFDEST") != "U"
	if Type("oImp:_ICMSUFDEST:_VICMSUFREMET:TEXT") != "U"
	aRet[9]	:= oImp:_ICMSUFDEST:_VICMSUFREMET:TEXT
	If ValType(aRet[9]) != "N"
	aRet[9] := Val(aRet[9])
	EndIf
	EndIf
	EndIf
	*/
	
	// T E S
	ConsTes(isInCallStack("U_GETCHVNFE"), cCFOP, xNCM, xDescri, @aRet, @xxMsg, xProd)
	If aRet[5] == 0 // Recno do SF4 // .and. xOldMsg != xxMsg
		xOldMsg := xxMsg
		If isInCallStack("U_GETCHVSNF")
			_cCFOP_	:= cCFOP
			aRet[5] := CadTes()
			_cCFOP_	:= Nil
		EndIf
		
		If aRet[05] == 0 // Criar nova TES
			// If alltrim(upper(SuperGetMV("IT_TES",,"N"))) == "S"
			While aRet[05] == 0
				nRetAvis := Aviso("Criar TES com:",xxMsg,{"Incluir", "Pesquisar", "Ignorar"},3)
				Do Case
					Case nRetAvis == 1 // Incluir
						_cCFOP_	:= cCFOP
						_aRet_	:= aRet
						AxInclui("SF4", 0, 3,, "U_PopCpTES()")
						_cCFOP_	:= Nil
						_aRet_	:= Nil
					Case nRetAvis == 2 // Pesquisar
						If PergParam(@aRet)
							Exit
						EndIf
					Case nRetAvis == 3 // Ignorar
						lAborta := .T.
						Exit
				EndCase
				ConsTes(isInCallStack("U_GETCHVNFE"), cCFOP, xNCM, xDescri, @aRet, xxMsg, xProd)
			End
			//				EndIf
		EndIf
	EndIf
	
	// If aRet[5] > 0 // TES foi identificada
	//	u_AskYesNo(   4000,"TES Identificada","TES: " + SF4->F4_CODIGO + " foi identificada!","","","","","UPDINFORMATION")
	// EndIf
	
	SF4->(RestArea(aAreaSF4))
	// S E R V I ว O S
ElseIf _tipoNF == "G" // GINFES
	If isInCallStack("U_GETCHVSNF") // XML de saํda
		If Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U" .And. aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT == "1"
			xTES := GetMv("MV_XTSSSSN") // simples nacional
		ElseIf Type("aNFS:_NS3_NATUREZAOPERACAO:TEXT") != "U" .And. aNFS:_NS3_NATUREZAOPERACAO:TEXT == "1"
			xTES := GetMv("MV_XTSSSDM") // dentro do municipio
		Else
			xTES := GetMv("MV_XTSSSFM") // fora do municipio
		EndIf
		If Type("aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_ALIQUOTA:TEXT") != "U"
			aRet[06] := Val(aNFS:_NS3_SERVICO:_NS3_VALORES:_NS3_ALIQUOTA:TEXT) * 100
		EndIf
	EndIf
	If isInCallStack("U_GETCHVNFE") // XML de entrada
		If Type("aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT") != "U" .and. aNFS:_NS3_OPTANTESIMPLESNACIONAL:TEXT == "1"
			xTES := GetMv("MV_XTESSSN") // simples nacional
		ElseIf Type("aNFS:_NS3_NATUREZAOPERACAO:TEXT") != "U" .and. aNFS:_NS3_NATUREZAOPERACAO:TEXT == "1"
			xTES := GetMv("MV_XTESSDM") // dentro do municipio
		Else
			xTES := GetMv("MV_XTESSFM") // fora do municipio
		EndIf
	EndIf
Else // Prefeitura
	If isInCallStack("U_GETCHVSNF") // XML de saํda
		If SubStr(aNFS, 418, 01) > "0"
			xTES := GetMv("MV_XTSSSSN") // simples nacional
		ElseIf SubStr(aNFS, 419, 01) $ "T;I;A;M;X"
			xTES := GetMV("MV_XTSSSDM") // dentro do municipio
		Else
			xTES := GetMv("MV_XTSSSFM") // fora do municipio
		EndIf
		If Val(SubStr(aNFS, 483, 04)) > 0
			aRet[06] := Val(SubStr(aNFS, 483, 04)) / 100
		EndIf
	EndIf
	If isInCallStack("U_GETCHVNFE") // XML de entrada
		If SubStr(aNFS, 418, 01) > "0"
			xTES := GetMv("MV_XTESSSN") // simples nacional
		ElseIf SubStr(aNFS, 419, 01) $ "T;I;A;M;X"
			xTES := GetMv("MV_XTESSDM") // dentro do municipio
		Else
			xTES := GetMv("MV_XTESSFM") // fora do municipio
		EndIf
	EndIf
EndIf
If _tipoNF != "D" // GINFES e Prefeitura
	If !Empty(xTES)
		SF4->(DbSetOrder(1))
		If SF4->(DbSeek(xFilial("SF4") + xTES,.F.))
			aRet[05] := SF4->(Recno()) // TES chumbado pra teste (recno)
		EndIf
	EndIf
EndIf
ConOut("TrataImp: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
RestArea(aArea)
Return aClone(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ConsTes บAutor ณ Douglas Telles        บ Data ณ 22/06/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta o cadastro de TES no banco de dados.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Parametros recebidos:                                      บฑฑ
ฑฑบ          ณ lEntrada: logico, Indica se o XML ้ de entrada ou saํda.   บฑฑ
ฑฑบ          ณ cCFOP: caracter, C๓digo CFOP do XML.                       บฑฑ
ฑฑบ          ณ xNCM: qualquer, C๓digo NCM do XML.                         บฑฑ
ฑฑบ          ณ xDescri: qualquer, Descri็ใo do produto do XML.            บฑฑ
ฑฑบ          ณ aRet: array, Array com os dados utilizados para gerar o    บฑฑ
ฑฑบ          ณ item da nota fiscal.                                       บฑฑ
ฑฑบ          ณ xxMsg: qualquer, Mensagem a ser apresentada ao usuแrio     บฑฑ
ฑฑบ          ณ caso nใo encontre a TES.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ConsTes(lEntrada, cCFOP, xNCM, xDescri, aRet, xxMsg, xProd)
Local aAreaSF4	:= SF4->(GetArea())
Local cQuery	:= ""
Local cInSql	:= "'5" + Substr(cCFOP, 2, 3) + "','6" + Substr(cCFOP, 2, 3) + "','7" + SubStr(cCFOP, 2, 3) + "'"
Local cTmpAlias	:= GetNextAlias()
Local xVal		:= Nil
Local lIpiTrib	:= .F.
ConOut("ConsTes: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
//TODO: validar se esta posicionado na zdt correta
If ValType(lImpAut) != "U" .And. lImpAut

	If Select("ZDT") > 0 .And. ZDT->(!EOF()) // ZDT posicionado
	
    	cTesZDT := ZDT->ZDT_TES
    	ZDT->(DbCloseArea()) // Fecho o ZDT
	
		DbSelectArea("SF4")
		SF4->(DbSetOrder(1)) // F4_FILIAL + F4_CODIGO
		If SF4->(DbSeek(xFilial("SF4") + cTesZDT))
			aRet[05] := SF4->(Recno())
			RestArea(aAreaSF4)
			If aRet[05] > 0 // Recno do SF4
				Return
			EndIf
		EndIf
		RestArea(aAreaSF4)
		
	EndIf
EndIf
If lEntrada
	aRet[05] := GetUltTES(Iif(aChvInfo[01] $ "D/B", "SA7", "SA5"), xProd)
	If aRet[05] > 0
		Return
	EndIf
EndIf
cQuery := "SELECT SF4.*, SF4.R_E_C_N_O_ RECNO " + CRLF
cQuery += "FROM " + RetSqlName("SF4") + " SF4 " + CRLF
cQuery += "WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + CRLF
cQuery += "	AND SF4.F4_CODIGO <> '" + Space(TamSx3("F4_CODIGO")[1]) + "' " + CRLF
cQuery += "	AND SF4.F4_MSBLQL <> '1' " + CRLF
If lEntrada
	cQuery += "	AND SF4.F4_TIPO	= 'E' " + CRLF
	cQuery += "	AND SF4.F4_XCFOP IN(" + cInSql + ") " + CRLF
	cQuery += "	AND SF4.F4_XSITICM = '" + PadR(aRet[1,2],2) + "' " + CRLF
	cQuery += "	AND SF4.F4_XSITIPI = '" + PadR(aRet[2],2) + "' " + CRLF
	cQuery += "	AND SF4.F4_XSITPIS = '" + PadR(aRet[3],2) + "' " + CRLF
	cQuery += "	AND SF4.F4_XSITCOF = '" + PadR(aRet[4],2) + "' " + CRLF
	// Mensagem
	xxMsg := "Filial: " + xFilial("SF4") + CRLF
	xxMsg += "Origem CFOP: " + "5" + SubStr(cCFOP, 2) + ", 6" + SubStr(cCFOP, 2) + " ou 7" + SubStr(cCFOP, 2) + CRLF
	xxMsg += "Sit.Trib.ICM: " + aRet[1,2] + CRLF
	xxMsg += "Sit.Trib.IPI: " + aRet[2] + CRLF
	xxMsg += "Sit.Trib.PIS: " + aRet[3] + CRLF
	xxMsg += "Sit.Trib.COFINS: " + aRet[4] + CRLF
	xxMsg += "Sit.Bas. ICM: " + AllTrim(Str(aRet[8])) + CRLF
Else
	cQuery += "	AND SF4.F4_TIPO	= 'S' " + CRLF
	cQuery += "	AND SF4.F4_CF IN(" + cInSql + ",'" + AllTrim(cCFOP) + "') " + CRLF
	xVal := Nil
	If Type(cTmpTagICM + ":_vBC:TEXT") != "U"
		xVal := SuperVal(&(cTmpTagICM + ":_vBC:TEXT"))
	Else
		xVal := 0
	EndIf
	cQuery += "	AND SF4.F4_CREDICM = '" + Iif(xVal > 0, "S", "N") + "' " + CRLF
	cQuery += "	AND SF4.F4_ICM = '" + Iif(xVal > 0, "S", "N") + "' " + CRLF
	If Type(cTmpTagIPI + ":_CST:TEXT") != "U"
		cQuery += "	AND SF4.F4_CTIPI = '" + &(cTmpTagIPI + ":_CST:TEXT") + "' " + CRLF
		If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "50"
			lIpiTrib := .T.
		Else
			If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "99" .And. Type(cTmpTagIPI + ":_vIPI:TEXT") != "U"
				If Val(&(cTmpTagIPI + ":_vIPI:TEXT")) > 0
					lIpiTrib := .T.
				EndIf
			EndIf
		EndIf
		If lIpiTrib
			cQuery += "	AND SF4.F4_LFIPI = 'T' " + CRLF
		ElseIf &(cTmpTagIPI + ":_CST:TEXT") $ "52"
			cQuery += "	AND SF4.F4_LFIPI = 'I' " + CRLF
		ElseIf &(cTmpTagIPI + ":_CST:TEXT") $ "51/53/54/55/99"
			cQuery += "	AND SF4.F4_LFIPI = 'O' " + CRLF
		Else
			cQuery += "	AND SF4.F4_LFIPI = 'N' " + CRLF
		EndIf
		cQuery += "	AND SF4.F4_CREDIPI = '" + IIF(lIpiTrib, "S", "N") + "' " + CRLF
		cQuery += "	AND SF4.F4_IPI = '" + IIF(lIpiTrib, "S", "N") + "' " + CRLF
	EndIf
	
	// Alteracao 29/05/2019 (CFOP's para nao gerar duplicata, no trecho de criacao mesma logica)
	If SubStr(cCFOP,2,3) $ "152/153/155/156/408/409/414/415/451/501/502/504/505/552/554/557/601/602/605/657/658/659/663/664/665/666/901/902/903/904/905/906/907/908/909/910/911/912/913/914/915/916/917/920/923/924/925/934/949/"
		cQuery += "	AND SF4.F4_DUPLIC = 'N' " + CRLF
	Else
		cQuery += "	AND SF4.F4_DUPLIC = 'S' " + CRLF
	EndIf
	
	If Type(cTmpTagICM + ":_CST:TEXT") != "U"
		cQuery += "	AND SF4.F4_SITTRIB = '" + &(cTmpTagICM + ":_CST:TEXT") + "' " + CRLF
	EndIf
	If &(cTmpTagICM + ":_CST:TEXT") $ "00/10"
		cQuery += "	AND SF4.F4_LFICM = 'T' " + CRLF
	ElseIf &(cTmpTagICM + ":_CST:TEXT") $ "30/40"
		cQuery += "	AND SF4.F4_LFICM = 'I' " + CRLF
	ElseIf &(cTmpTagICM + ":_CST:TEXT") $ "20/41/50/51/60/70/90"
		//If Type(cTmpTagICM + ":_VICMS:TEXT") != "U"
		//If Val(&(cTmpTagICM + ":_VICMS:TEXT")) != 0
		//cQuery += "	AND SF4.F4_LFICM = 'T' " + CRLF
		//Else
		cQuery += "	AND SF4.F4_LFICM = 'O' " + CRLF
		//EndIf
		//Else
		//cQuery += "	AND SF4.F4_LFICM = 'O' " + CRLF
		//EndIf
		//ElseIf &(cTmpTagICM + ":_CST:TEXT") $ "41/50/51/0/70"
		//cQuery += "	AND SF4.F4_LFICM = 'O' " + CRLF
	EndIf
	xVal := Nil
	xVal := Posicione("SA1", 1, xFilial("SA1") + aChvInfo[06] + aChvInfo[07], "A1_TIPO")
	//cQuery += "	AND SF4.F4_INCIDE = '" + IIF(xVal == "F", "S", "N") + "' " + CRLF
	If SuperGetMV("IT_FORCATP",,"N") == "N"
		cQuery += "	AND SF4.F4_INCIDE = '" + IIF(xVal == "F", "S", "N") + "' " + CRLF
	Else
		cQuery += "	AND SF4.F4_INCIDE = 'N' " + CRLF
	EndIf
	If Type(cTmpTagPIS + ":_CST:TEXT") != "U"
		cQuery += "	AND SF4.F4_CSTPIS = '" + &(cTmpTagPIS + ":_CST:TEXT") + "' " + CRLF
		If &(cTmpTagPIS + ":_CST:TEXT") $ "01/02/03/04"
			cQuery += "	AND SF4.F4_PISCRED = '2' " + CRLF
		ElseIf &(cTmpTagPIS + ":_CST:TEXT") $ "05/06/07/08/09/49"
			cQuery += "	AND SF4.F4_PISCRED = '3' " + CRLF
		EndIf
	Else
		// Frank 10-10-17
		cQuery += "	AND SF4.F4_CSTPIS = '49' " + CRLF
		cQuery += "	AND SF4.F4_PISCRED = '3' " + CRLF
	EndIf
	If Type(cTmpTagCOF + ":_CST:TEXT") != "U"
		cQuery += "	AND SF4.F4_CSTCOF = '" + &(cTmpTagCOF + ":_CST:TEXT") + "' " + CRLF
	EndIf
	cQuery += "	AND SF4.F4_DESTACA = 'S' " + CRLF
	cQuery += "	AND SF4.F4_COMPL = 'N' " + CRLF
	cQuery += "	AND SF4.F4_PISCOF = '3' " + CRLF
	If AllTrim(cCFOP) $ "5901;5904;5905;5908;5910;5911;5912;5914;5915;5917;5920;5923;5924"
		cQuery += "	AND SF4.F4_PODER3 = 'R' " + CRLF
	ElseIf AllTrim(cCFOP) $ "5902;5903;5906;5907;5909;5913;5916;5925"
		cQuery += "	AND SF4.F4_PODER3 = 'D' " + CRLF
	Else
		cQuery += "	AND SF4.F4_PODER3 = 'N' " + CRLF
	EndIf
	If lOpConsFin .And. AllTrim(SA1->A1_TIPO) == "F"
		cQuery += "	AND SF4.F4_DIFAL = '1' " + CRLF
	EndIf
	xxMsg := "Filial: " + xFilial("SF4") + CRLF
	xxMsg += "CFOP: " + "5" + Substr(cCFOP, 2) + ", 6" + Substr(cCFOP, 2) + " ou 7" + Substr(cCFOP, 2) + CRLF
	xxMsg += "Sit.Trib.ICM: " + aRet[01,02] + CRLF
	xxMsg += "Sit.Trib.IPI: " + aRet[02] + CRLF
	xxMsg += "Sit.Trib.PIS: " + aRet[03] + CRLF
	xxMsg += "Sit.Trib.COFINS: " + aRet[04] + CRLF
	xxMsg += "Sit.Bas. ICM: " + AllTrim(Str(aRet[08])) + CRLF
EndIf
If !Empty(aRet[08])
	cQuery += "	AND SF4.F4_BASEICM = " + cValToChar(IIF(aRet[8] < 1, 0, noround(100 - aRet[8],2))) + " " + CRLF
EndIf
cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
xxMsg += "NCM: "+ xNCM + CRLF
xxMsg += "Descri็ใo: "+ xDescri + CRLF
xxMsg += CRLF + "Cadastre-a e aperte Pesquisar ou Ignorar para falhar a NF" + CRLF
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
Count To nRecsSF4
// MsgInfo("TES encontradas na query: " + cValToChar(nRecsSF4))
If nRecsSF4 > 0 // Registros encontrados
	(cTmpAlias)->(DbGotop())
	While (cTmpAlias)->(!EOF())
		aRet[05] := (cTmpAlias)->RECNO
		
		// Tratamento especial para ICMSUFDEST - Frank 26/05
		/*
		If !(lEntrada) // Tratamento exclusivo para nota fiscal de saida
		If !(Empty(alltrim(aRet[9]))) .and.;
		((cTmpAlias)->F4_ICM <> "S" .or. (cTmpAlias)->F4_DIFAL <> "1" .or. (cTmpAlias)->F4_COMPL <> "S")
		
		aRet[5] := 0
		xxMsg += " (Erro especifico do DIFAL.) "
		EndIf
		EndIf
		*/
		
		If AllTrim((cTmpAlias)->F4_CF) == AllTrim(cCFOP) // Douglas Telles - 31/10/2018
			Exit
		EndIf
		(cTmpAlias)->(DbSkip())
	End
Else // Nenhum registro encontrado... verificar se tem algum pendente de criacao exatamente igual
	
EndIf
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
ConOut("ConsTes: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ GetUltTES บAutor ณ Douglas Telles     บ Data ณ  15/08/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta a ultima TES usada para o Produto x               บฑฑ
ฑฑบ          ณ Fornecedor/Cliente.                                        บฑฑ
ฑฑบ          ณ Parametros recebidos:                                      บฑฑ
ฑฑบ          ณ cTab: characters, Tabela de amarra็ใo a ser consultada     บฑฑ
ฑฑบ          ณ xProd: caracter, C๓digo do produto a ser consultado        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function GetUltTES(cTab, xProd)
Local nRecno	:= 0
Local cUltTES	:= ""
Local cQuery	:= ""
Local cTmpAlias	:= ""
Local cFornCli	:= aChvInfo[06]
Local cLoja		:= aChvInfo[07]
Local aArea		:= GetArea()
Local aAreaSA5	:= SA5->(GetArea())
Local aAreaSA7	:= SA7->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Default cTab	:= "SA5"
Default xProd	:= ""
If cTab == "SA5"
	If SA5->(FieldPos("A5_XULTTES")) > 0
		cQuery := "SELECT SF4.R_E_C_N_O_ RECNO " + CRLF
		cQuery += "FROM " + RetSqlName("SF4") + " SF4 (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SA5") + " SA5 (NOLOCK) " + CRLF
		cQuery += "	ON SA5.A5_FILIAL = '" + xFilial("SA5") + "' " + CRLF
		cQuery += "	AND SA5.A5_FORNECE = '" + cFornCli + "' " + CRLF
		cQuery += "	AND SA5.A5_LOJA = '" + cLoja + "' " + CRLF
		cQuery += "	AND SA5.A5_PRODUTO = '" + xProd + "' " + CRLF
		cQuery += "	AND SA5.A5_XULTTES = SF4.F4_CODIGO " + CRLF
		cQuery += "	AND SA5.D_E_L_E_T_ <> '*' " + CRLF
		cQuery += "WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + CRLF
		cQuery += "	AND SF4.F4_MSBLQL <> '1' " + CRLF
		cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
	EndIf
	/*
	DbSelectArea("SA5")
	SA5->(DbSetOrder(1)) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
	If SA5->(DbSeek(xFilial("SA5") + cFornCli + cLoja + xProd))
	If SA5->(FieldPos("A5_XULTTES")) > 0
	cUltTES := SA5->A5_XULTTES
	EndIf
	EndIf
	*/
Else
	If SA7->(FieldPos("A7_XULTTES")) > 0
		cQuery := "SELECT SF4.R_E_C_N_O_ RECNO " + CRLF
		cQuery += "FROM " + RetSqlName("SF4") + " SF4 (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SA7") + " SA7 (NOLOCK) " + CRLF
		cQuery += "	ON SA7.A7_FILIAL = '" + xFilial("SA7") + "' " + CRLF
		cQuery += "	AND SA7.A7_CLIENTE = '" + cFornCli + "' " + CRLF
		cQuery += "	AND SA7.A7_LOJA = '" + cLoja + "' " + CRLF
		cQuery += "	AND SA7.A7_PRODUTO = '" + xProd + "' " + CRLF
		cQuery += "	AND SA7.A7_XULTTES = SF4.F4_CODIGO " + CRLF
		cQuery += "	AND SA7.D_E_L_E_T_ <> '*' " + CRLF
		cQuery += "WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + CRLF
		cQuery += "	AND SF4.F4_MSBLQL <> '1' " + CRLF
		cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
	EndIf
	/*
	DbSelectArea("SA7")
	SA7->(DbSetOrder(1)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
	If SA7->(DbSeek(xFilial("SA7") + cFornCli + cLoja + xProd))
	If SA7->(FieldPos("A7_XULTTES")) > 0
	cUltTES := SA7->A7_XULTTES
	EndIf
	EndIf
	*/
EndIf

/*
If !Empty(cUltTES)
DbSelectarea("SF4")
SF4->(DbSetOrder(1)) // F4_FILIAL+F4_CODIGO
If SF4->(DbSeek(xFilial("SF4") + cUltTES))
nRecno := SF4->(Recno())
EndIf
EndIf
*/

If !Empty(cQuery)
	cTmpAlias := GetNextAlias()
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
	If (cTmpAlias)->(!EOF())
		nRecno := (cTmpAlias)->RECNO
	EndIf
	If Select(cTmpAlias) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf
EndIf
RestArea(aAreaSF4)
RestArea(aAreaSA7)
RestArea(aAreaSA5)
RestArea(aArea)
Return nRecno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LimpaSPC บAutor  ณ Cristiam Rossi     บ Data ณ  10/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remove espa็os em branco do inํcio/fim e espa็os duplos    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade XML                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LimpaSPC(cParam)
Local cRet := Alltrim(cParam)
While At(Space(02), cRet) > 0
	cRet := StrTran(cRet, Space(02), Space(01))
End
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณfMoverArq บAutor  ณ Cristiam Rossi     บ Data ณ  23/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Movimenta arquivo para subpasta LIDOS                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade XML                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function fMoverArq()
Local nPos := RAT("\", cFile)
Local cFLidos
Local cArq
If nPos == 0
	Return
EndIf
cArq := SubStr(cFile, nPos + 1)
cFLidos := StrTran(cFile, cArq, "LIDOS")
if !ExistDir(cFLidos)
	if MakeDir(cFLidos) != 0
		if !lQuiet
			Alert("Verifique permiss๕es, ้ necessแrio criar pasta "+cFLidos)
		EndIf
		Return
	EndIf
EndIf
If !__CopyFile(cFile, cFLidos + "\" + cArq)
	If !lQuiet
		alert("Verifique permiss๕es, nใo foi possํvel mover o arquivo lido: " + cFile)
	EndIf
	Return
EndIf
If fErase(cFile) == -1
	If !lQuiet
		Alert("Verifique permiss๕es, nใo foi possํvel remover o arquivo lido: " + cFile + CRLF + "O mesmo jแ foi copiado para a subpasta: " + cFLidos)
	EndIf
	Return
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณGETLOTNF  บAutor  ณ Cristiam Rossi     บ Data ณ  23/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa XMLs/TXTs em lote                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ECCO Contabilidade XML                                     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function GETLOTNF(xPar1, xPar2, xPar3, xPar4, xPar5)
Local cFolder
Local aArqTmp
Local nI
Local aRet
Local xRet
Local cPerg := "XMLCTB"
Local aAreaXML
Local lSimTodos := .F.
Local nRetAvis := 0
private cArqTrab := "XMLTRB"
Private lQuiet := .T.
Private cFolder := U_PEchvNFE( "PATHXML" )
Private nJaLidos := 0
cFolder := cGetFile(Nil, 'Selecione uma pasta com os arquivos a serem importados', 1, cFolder, .F., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
If Empty(cFolder)
	MsgStop("Opera็ใo cancelada", "Importa็ใo XML em Lote")
	Return
EndIf
PutMv("MV_XARQXML", cFolder)
If Left(cFolder, 1) == "\"
	cFolder := SubStr(cFolder, Len(cFolder) - 1)
EndIf
		u_CriaTrab(@cArqTrab)
If Aviso("Importa็ใo XML em Lote", "Somente DANFE ou todos os arquivos?", {"DANFE", "Todos"}) == 1
	Processa( {|| aRet := u_PreLoad( cFolder, "", .T. )}, "Aguarde, carregando arquivos da pasta", "Iniciando processo...")
	If aRet[1] == 0
		MsgStop("Nใo existem DANFEs na pasta selecionada","Importa็ใo NF em Lote")
	Else
		AjustaSX1( cPerg )
		if isInCallStack("MATA410") .or. isInCallStack("MATA920")
			Pergunte( cPerg, .F. )
			lContinua := .T.
			MV_PAR01  := 1
		else
			lContinua := Pergunte( cPerg, .T. )
		endif
		if lContinua
			if MV_PAR01 == 1
				//(cArqTrab)->( dbSetOrder(6) )	// Emissao DESC
				(cArqTrab)->( dbSetOrder(5) )
			elseif MV_PAR01 == 2
				(cArqTrab)->( dbSetOrder(5) )	// Emissao
			elseif MV_PAR01 == 3
				(cArqTrab)->( dbSetOrder(4) )	// Destinatแrio
			else
				(cArqTrab)->( dbSetOrder(3) )	// Emissor
			endif
			(cArqTrab)->( dbGotop() )
			nI := 0
			while ! (cArqTrab)->( EOF() )
				nI++
				aAreaXML := getArea()
				if isInCallStack("MATA410") .or. isInCallStack("MATA920")
					xRet := U_GETCHVSNF( xPar1, xPar2, xPar3, "LOTE", (cArqTrab)->ARQUIVO )
					if ! xRet
						msgAlert("Ocorreu erro na importa็ใo, processo encerrado!")
						exit
					endif
				else
					cMsg := "Arquivo "+ Alltrim(Str(nI))+" / "+Alltrim(Str( aRet[1] )) + CRLF
					cMsg += alltrim((cArqTrab)->DOCUMENTO)
					cMsg += " - Emissใo: "+ DtoC((cArqTrab)->EMISSAO) + CRLF
					cMsg += "Emissor: "+ (cArqTrab)->EMISNOME + CRLF
					if len(alltrim((cArqTrab)->EMISSOR)) == 14
						cMsg += "CNPJ: "+ Transform((cArqTrab)->EMISSOR, "@R 99.999.999/9999-99")
					else
						cMsg += "CPF: " + Transform((cArqTrab)->EMISSOR, "@R 999.999.999-99")
					endif
					cMsg += CRLF + CRLF + "Continua importa็ใo?"
					If !(lSimTodos)
						nRetAvis := Aviso("Importa็ใo NF em Lote", cMsg, {"Sim P/ Todos", "Sim", "Nใo"},2)
						if nRetAvis == 1
							lSimTodos := .T.
						endif
						if nRetAvis == 3
							Exit
						endif
					EndIf
					
					/*
					aAreaXML := getArea()
					if isInCallStack("MATA410")
					U_GETCHVSNF( xPar1, xPar2, xPar3, "LOTE", (cArqTrab)->ARQUIVO )
					else
					*/
					u_GETCHVNFE( xPar1, xPar2, xPar3, "LOTE", (cArqTrab)->ARQUIVO )
					// endif
				EndIf
				RestArea(aAreaXML)
				(cArqTrab)->( dbSkip() )
			End
		EndIf
	EndIf
Else
	aArqTmp := Directory( cFolder + "\*.*", "D") // Coleta no array todos os arquivos do diret๓rio
	For nI := 3 to Len( aArqTmp )
		if isInCallStack("MATA410") .or. isInCallStack("MATA920")
			U_GETCHVSNF( xPar1, xPar2, xPar3, "LOTE", aArqTmp[nI,1] )
		else
			cMsg := "Arquivo "+ Alltrim(Str(nI-2))+" / "+Alltrim(Str( len(aArqTmp)-2 )) + CRLF
			cMsg += CRLF + CRLF + "Continua importa็ใo?"
			If !(lSimTodos)
				nRetAvis := Aviso("Importa็ใo NF em Lote", cMsg, {"Sim P/ Todos", "Sim", "Nใo"},2)
				if nRetAvis == 1
					lSimTodos := .T.
				endif
				if nRetAvis == 3
					Exit
				endif
			EndIf
			/*
			if isInCallStack("MATA410")
			( xPar1, xPar2, xPar3, "LOTE", aArqTmp[nI,1] )
			else
			*/
			U_GETCHVNFE( xPar1, xPar2, xPar3, "LOTE", aArqTmp[nI,1] )
			// endif
		EndIf
	Next
EndIf
DelClassIntf()	// Exclui todas classes de interface da thread
u_killTrab(cArqTrab)
If nJaLidos > 0
	MsgInfo("Processo finalizado" + CRLF + CRLF + "Foram encontrados " + cValToChar(nJaLidos) + " documentos lidos anteriormente.", "Importa็ใo XML em Lote")
Else
	MsgInfo("Processo finalizado", "Importa็ใo XML em Lote")
EndIf
Return

Static Function AjustaSX1(cPerg)
u_XPUTSX1(cPerg,"01","Ordem das DANFEs?","","","mv_ch1","N",01,00,00,"C","","","","","MV_PAR01","Emissao decrescente","Emissao decrescente","Emissao decrescente","","Emissao crescente"  ,"Emissao crescente"  ,"Emissao crescente"  ,"Destinatario"       ,"Destinatario"       ,"Destinatario","Emissor"            ,"Emissor"            ,"Emissor","","","",,,,"Informe a Ordem das Danfes")
Return

User Function CriaTrab(cArqTrab)
    Local oTempTable := FWTemporaryTable():New("XMLTRB")
    Local aStru := {}

    If Empty(cArqTrab)
        // MsgStop("Nใo foi possํvel vincular o arquivo.","Aten็ใo!")
        // return .F.
    EndIf

    aAdd(aStru, {"ARQUIVO"  ,"C",99,0})
    aAdd(aStru, {"CHAVE"    ,"C",44,0})
    aAdd(aStru, {"EMISSOR"  ,"C",14,0})
    aAdd(aStru, {"DESTINA"  ,"C",14,0})
    aAdd(aStru, {"EMISSAO"  ,"D",08,0})
    aAdd(aStru, {"DOCUMENTO","C",15,0})
    aAdd(aStru, {"EMISNOME" ,"C",50,0})
    aAdd(aStru, {"DESTNOME" ,"C",50,0})
    aAdd(aStru, {"STATUS"   ,"C",01,0})
    aAdd(aStru, {"XML"     ,"M",10,0})

    oTempTable:SetFields(aStru)

    // If Select("XMLTRB") == 0
    //     //Final("Nใo foi possํvel fazer a pr้-carga dos XMLs")
    // EndIf
	
	oTempTable:AddIndex( "XMLTRB_5", {"EMISSAO"} )
	oTempTable:AddIndex( "XMLTRB_4", {"DESTINA"} )
	oTempTable:AddIndex( "XMLTRB_3", {"EMISSOR"} )
	oTempTable:AddIndex( "XMLTRB_2", {"CHAVE"} )
	oTempTable:AddIndex( "XMLTRB_1", {"ARQUIVO"} )

	oTempTable:Create()
	cArqTrab := oTempTable:GetAlias()
Return

User Function killTrab( cArqTrab )
	//cArqTrab:Delete()
	if Select(cArqTrab) > 0
            XMLTRB->(dbCloseArea())
        Endif

Return

User Function PreLoad( cFolder, cChave, lLote )
Local aArqTmp
Local aTemp
Local nDanfe := 0
Local nNF    := 0
Local nI
If Empty( cFolder )
	Return .F.
EndIf
If !lLote .And. !Empty(cChave)
	Return
EndIf
DbSelectArea(cArqTrab)
ZAP
If left( cFolder, 1) == "\"
	cFolder := substr( cFolder, len(cFolder)-1 )
endif
aArqTmp := DIRECTORY( cFolder + "\*.xml", "D" )		// Coleta no array todos os arquivos do diret๓rio
ProcRegua( len( aArqTmp ) )
For nI := 1 to Len( aArqTmp )
	incProc( "arquivo "+cValToChar(nI)+" de "+cValToChar(Len( aArqTmp )) )
	aTemp := destrincha( cFolder + aArqTmp[nI,1] )
	if len( aTemp ) > 0
		nDanfe++
		dbSelectArea(cArqTrab)
		dbSetOrder(2)			// pela Chave da DANFE
		if ! dbSeek( aTemp[1] )
			dbAppend()
			ARQUIVO   := aArqTmp[nI,1]
			CHAVE     := aTemp[1]
			EMISSAO   := aTemp[2]
			EMISSOR   := aTemp[3]
			DESTINA   := aTemp[4]
			XML       := aTemp[5]
			DOCUMENTO := aTemp[6]
			EMISNOME  := aTemp[7]
			DESTNOME  := aTemp[8]
			STATUS    := "1"	// carregado
			msUnlock()
		endif
	else
		nNF++
	endif
Next
if ! empty(cChave) .and. ! MsgYesNo("Deseja manter a Chave selecionada?"+CRLF+cChave)
	cChave := Space(44)
endif

/// daqui 
dbSelectArea(cArqTrab)
dbSetOrder(1)			// pelo nome do arquivo

if ! dbSeek( Upper(cChave) )
cChave := Space(44)
else
if ! MsgYesNo("Deseja manter a Chave selecionada?"+CRLF+cChave)
cChave := Space(44)
endif
endif
/// daqui 

Return { nDanfe, nNF }

Static Function destrincha(cArquivo)
Local cXML
Local cChave    := ""
Local dEmissao  := CtoD("")
Local cEmissor  := ""
Local cDestina  := ""
Local cDocumen  := ""
Local cEmisNome := ""
Local cDestNome := ""
Private oXML
cXML := u_LeXml( cArquivo )	  				// L๊ XML e retorna conte๚do
if Empty( cXml )
	Return {}
EndIf
if "www.ginfes.com.br" $ lower( cXML )		// Ginfes
	return {}
endif
oXML := U_c2oXML( cXml )					// Carrega XML no Objeto
If ValType( oXML ) != "O"
	return {}
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_ID:TEXT") != "U"			// Chave DANFE
	cChave   := substr(oXML:_NFEPROC:_NFE:_INFNFE:_ID:TEXT, 4)
ElseIf Type("oXML:_NFE:_INFNFE:_ID:TEXT") != "U"			// Chave DANFE
	cChave   := substr(oXML:_NFE:_INFNFE:_ID:TEXT, 4)
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatแrio
	cDestina := oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
ElseIf Type("oXML:_NFE:_INFNFE:_DEST:_CNPJ:TEXT") != "U"	// CNPJ Destinatแrio
	cDestina := oXML:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:TEXT") != "U"	// Emissใo
	dEmissao := StoD( StrTran( Left( oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:TEXT, 10 ), "-", "" ) )
ElseIf Type("oXML:_NFE:_INFNFE:_IDE:_dhEmi:TEXT") != "U"	// Emissใo
	dEmissao := StoD( StrTran( Left( oXML:_NFE:_INFNFE:_IDE:_dhEmi:TEXT, 10 ), "-", "" ) )
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:TEXT") != "U"	// Emissใo
	dEmissao := StoD( StrTran( oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:TEXT, "-", "" ) )
ElseIf Type("oXML:_NFE:_INFNFE:_IDE:_dEmi:TEXT") != "U"	// Emissใo
	dEmissao := StoD( StrTran( oXML:_NFE:_INFNFE:_IDE:_dEmi:TEXT, "-", "" ) )
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhSaiEnt:TEXT") != "U"	// Saํda
	dEmissao := StoD( StrTran( oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhSaiEnt:TEXT, "-", "" ) )
ElseIf Type("oXML:_NFE:_INFNFE:_IDE:_dhSaiEnt:TEXT") != "U"	// Saํda
	dEmissao := StoD( StrTran( oXML:_NFE:_INFNFE:_IDE:_dhSaiEnt:TEXT, "-", "" ) )
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT") != "U"
	cEmissor := oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
ElseIf Type("oXML:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT") != "U"
	cEmissor := oXML:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT") != "U"	// Numero do Documento
	cDocumen := replicate("0", 9) + alltrim( oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT )
	cDocumen := alltrim( cDocumen )
ElseIf Type("oXML:_NFE:_INFNFE:_IDE:_NNF:TEXT") != "U"	// Numero do Documento
	cDocumen := replicate("0", 9) + alltrim( oXML:_NFE:_INFNFE:_IDE:_NNF:TEXT )
	cDocumen := alltrim( cDocumen )
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT") != "U"	// S้rie do Documento
	cDocumen += "/" + alltrim( oXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT )
ElseIf Type("oXML:_NFE:_INFNFE:_IDE:_SERIE:TEXT") != "U"	// S้rie do Documento
	cDocumen += "/" + alltrim( oXML:_NFE:_INFNFE:_IDE:_SERIE:TEXT )
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_xNome:TEXT") != "U"
	cEmisNome := oXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_xNome:TEXT
ElseIf Type("oXML:_NFE:_INFNFE:_EMIT:_xNome:TEXT") != "U"
	cEmisNome := oXML:_NFE:_INFNFE:_EMIT:_xNome:TEXT
EndIf
if Type("oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT") != "U"
	cDestNome := oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT
ElseIf Type("oXML:_NFE:_INFNFE:_DEST:_xNome:TEXT") != "U"
	cDestNome := oXML:_NFE:_INFNFE:_DEST:_xNome:TEXT
EndIf
oXML := nil
// cXML := nil
if empty( cChave )
	Return {}
EndIf
Return { cChave, dEmissao, cEmissor, cDestina, cXML, cDocumen, cEmisNome, cDestNome }

User Function PesqDANFE( cPesq, cPasta )		// Pesquisa Chave
Local nI
Local xTemp    := Upper( alltrim(cPasta) + alltrim(cPesq) )
Local aArea	   := {}
default cPesq  := ""
default cPasta := ""
If select(cArqTrab) == 0
	MsgStop("Falha na abertura do arquivo.","Aten็ใo!")
	Return .F.
EndIf
aArea := (cArqTrab)->(GetArea())
DbSelectArea(cArqTrab)
(cArqTrab)->(DbSetOrder(1)) // ARQUIVO
For nI := 1 to 2			// 1=Arquivo, 2=Chave
	If DbSeek( xTemp )
		Return .T.
	EndIf
	xTemp := alltrim( upper( cPesq ) )
Next
RestArea(aArea)
Return .F.

User Function addItCtb( cParItem, cNome, cNormal ) // Cria Item Contabil na Inclusใo de Cliente/Fornecedor
Local aArea := getArea()
Local cItem := PadR(cParItem, len(CTD->CTD_ITEM) )
CTD->( dbSetOrder(1) )
if CTD->(!dbSeek(xFilial("CTD") + cItem))
	Reclock("CTD", .T.)
	CTD->CTD_FILIAL := xFilial("CTD")
	CTD->CTD_ITEM   := cItem
	CTD->CTD_CLASSE := "2"		// 1=Sintetica 2=Analitica
	CTD->CTD_NORMAL := cNormal	// 1=Receita 2=Despesa
	CTD->CTD_DESC01 := cNome
	CTD->CTD_BLOQ   := "2"		// 2=Nao Bloqueado
	CTD->CTD_DTEXIS := CtoD("19800101")
	msUnLock()
EndIf
restArea(aArea)
Return

User Function xPreenNF()
Local xNFOri  := gdFieldGet("D1_NFORI")
Local xSerOri := gdFieldGet("D1_SERIORI")
Local nI
if Aviso( "Preencher/Apagar NF e S้rie de Origem", "Voc๊ deseja replicar para os demais itens a NF de Origem/S้rie "+xNFOri+"/"+xSerOri+"?", {"Sim","Nใo"} ) == 1
	For nI := 1 to len( aCols )
		if !aTail(aCols[nI])	// nใo deletado
			gdFieldPut( "D1_NFORI" , xNFOri , nI )
			gdFieldPut( "D1_SERIORI", xSerOri, nI )
		EndIf
	next
EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PopCpTES บAutor ณ Douglas Telles       บ Data ณ 23/06/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula os campos do cadastro de TES acionado pelo aviso.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function PopCpTES()
Local lEntrada	:= isInCallStack('U_GETCHVNFE')
Local cCFOP		:= _cCFOP_
Local aRet		:= _aRet_
Local lIpiTrib	:= .F.
If lEntrada
	M->F4_CODIGO	:= ProximaTES("E")
	M->F4_TIPO		:= "E"
	M->F4_XCFOP		:= "5" + Substr(cCFOP, 2)
	M->F4_XSITICM	:= PadR(aRet[1,2],2)
	M->F4_XSITIPI	:= PadR(aRet[2],2)
	M->F4_XSITPIS	:= PadR(aRet[3],2)
	M->F4_XSITCOF	:= PadR(aRet[4],2)
	If !(Empty(aRet[8]))
		M->F4_BASEICM	:= IIF(aRet[8] < 1, 0, noround(100 - aRet[8], 2))
	EndIf
Else
	M->F4_CODIGO	:= ProximaTES("S")
	M->F4_TIPO		:= "S"
	M->F4_CF		:= cCFOP
	M->F4_TEXTO		:= Posicione("SX5", 1, xFilial("SX5") + "13" + M->F4_CF, "X5_DESCRI")
	xVal := Nil
	If Type(cTmpTagICM + ":_vBC:TEXT") != "U"
		xVal := SuperVal(&(cTmpTagICM + ":_vBC:TEXT"))
	Else
		xVal := 0
	Endif
	M->F4_CREDICM	:= IIF(xVal > 0, "S", "N")
	M->F4_ICM		:= M->F4_CREDICM
	If Type(cTmpTagIPI + ":_CST:TEXT") != "U"
		M->F4_CTIPI	:= &(cTmpTagIPI + ":_CST:TEXT")
		If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "50"
			lIpiTrib	:= .F.
		Else
			If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "99" .And. Type(cTmpTagIPI + ":_vIPI:TEXT") != "U"
				If Val(&(cTmpTagIPI + ":_vIPI:TEXT")) > 0
					lIpiTrib := .T.
				EndIf
			EndIf
		EndIf
		If lIpiTrib
			M->F4_LFIPI := "T"
		ElseIf M->F4_CTIPI $ "52"
			M->F4_LFIPI := "I"
		ElseIf M->F4_CTIPI $ "51/53/54/55/99"
			M->F4_LFIPI := "O"
		Else
			M->F4_LFIPI := "N"
		EndIf
		M->F4_CREDIPI	:= IIF(lIpiTrib, "S", "N")
		M->F4_IPI		:= M->F4_CREDIPI
	EndIf
	
	// Alteracao 29/05/2019 (CFOP's para nao gerar duplicata, no trecho de criacao mesma logica)
	If SubStr(cCFOP,2,3) $ "152/153/155/156/408/409/414/415/451/501/502/504/505/552/554/557/601/602/605/657/658/659/663/664/665/666/901/902/903/904/905/906/907/908/909/910/911/912/913/914/915/916/917/920/923/924/925/934/949/"
		M->F4_DUPLIC	:= "N"
	Else
		M->F4_DUPLIC	:= "S"
	EndIf
	
	
	If Type(cTmpTagICM + ":_CST:TEXT") != "U"
		M->F4_SITTRIB	:= &(cTmpTagICM + ":_CST:TEXT")
	EndIf
	If M->F4_SITTRIB $ "00/10" // retirado o 20 Frank 05/10/17
		M->F4_LFICM := "T"
	ElseIf M->F4_SITTRIB $ "30/40"
		M->F4_LFICM := "I"
	ElseIf M->F4_SITTRIB $ "20/41/50/51/60/70/90"
		M->F4_LFICM := "O"
		//ElseIf M->F4_SITTRIB $ "90"
		//	If Type(cTmpTagICM + ":_VICMS:TEXT") != "U"
		//		If Val(&(cTmpTagICM + ":_VICMS:TEXT")) != 0
		//			M->F4_LFICM := "T"
		//		Else
		//			M->F4_LFICM := "O"
		//		EndIf
		//	Else
		//		M->F4_LFICM := "O"
		//	EndIf
		//ElseIf M->F4_SITTRIB $ "41/50/51/0/70"
		//	M->F4_LFICM := "O"
	EndIf
	If SuperGetMV("IT_FORCATP",,"N") == "N"
		M->F4_INCIDE	:= IIF(Posicione("SA1", 1, xFilial("SA1") + aChvInfo[06] + aChvInfo[07], "A1_TIPO") == "F", "S", "N")
	Else
		M->F4_INCIDE	:= "N"
	EndIF
	If Type(cTmpTagPIS + ":_CST:TEXT") != "U"
		M->F4_CSTPIS	:= &(cTmpTagPIS + ":_CST:TEXT")
		If M->F4_CSTPIS $ "01/02/03/04"
			M->F4_PISCRED	:= "2"
		ElseIf M->F4_CSTPIS $ "05/06/07/08/09/49"
			M->F4_PISCRED	:= "3"
		EndIf
	Else
		// Frank 10-10-17
		M->F4_CSTPIS	:= "49"
		M->F4_PISCRED	:= "3" // IIF(M->F4_CSTPIS $ "01/02/03", "2", "3")
	EndIf
	If Type(cTmpTagCOF + ":_CST:TEXT") != "U"
		M->F4_CSTCOF := &(cTmpTagCOF + ":_CST:TEXT")
	EndIf
	M->F4_DESTACA	:= "S"
	M->F4_COMPL		:= "N"
	M->F4_PISCOF	:= "3"
	If AllTrim(cCFOP) $ "5901;5904;5905;5908;5910;5911;5912;5914;5915;5917;5920;5923;5924"
		M->F4_PODER3	:= "R"
	ElseIf AllTrim(cCFOP) $ "5902;5903;5906;5907;5909;5913;5916;5925"
		M->F4_PODER3	:= "D"
	Else
		M->F4_PODER3	:= "N"
	EndIf
	If Type(cTmpTagICM + ":_pRedBC:TEXT") != "U"
		If !(Empty(&(cTmpTagICM + ":_pRedBC:TEXT")))
			M->F4_BASEICM	:= IIF(val( &(cTmpTagICM + ":_pRedBC:TEXT") ) < 1, 0, noround(100 - val( &(cTmpTagICM + ":_pRedBC:TEXT") ), 2))
		EndIf
	EndIf
	M->F4_ESTOQUE	:= "S"
	If (lOpConsFin) .And. (Alltrim(SA1->A1_TIPO) == "F")
		M->F4_DIFAL = '1'
	Else
		M->F4_DIFAL = '2'
	EndIf
	If ExistBlock("PECADTES")
		ExecBlock("PECADTES",.F.,.F.)
	EndIf
EndIf
Return

/*/{Protheus.doc} ProximaTES
Consulta o pr๓ximo c๓digo livre da TES.
@author Douglas Telles
@since 16/08/2017
@param cTipo, characters, Indica se o tipo da TES ้ entrada ou saํda.
@type function
/*/

Static Function ProximaTES(cTipo)
Local cRet		:= PadL("", TamSx3("F4_CODIGO")[1])
Local cQuery	:= ""
Local cMin		:= ""
Local cMax		:= ""
Local cTable	:= GetNextAlias()
Local cIndex	:= cTable + "1"
Local aEstruct	:= {{'TES_COD','C',3,0}}
Local lAlfaNum	:= GetMV("IT_TESALNU",,.T.)
cMin := IIF(cTipo == "E", "001", "501")
cMax := IIF(cTipo == "E", "500", "999")
/*
If MsFile(cTable, '', "TOPCONN")
If Select(cTable) > 0
(cTable)->(DbCloseArea())
EndIf

TCDelFile(cTable)
EndIf

DbCreate(cTable, aEstruct, "TOPCONN")
DbUseArea(.T.,"TOPCONN",cTable,cTable,.F.,.F.)
DBCreateIndex(cIndex, "TES_COD", {|| "TES_COD"}, .F.)

cQuery := "DECLARE @max INT, @curr INT " + CRLF
cQuery += "SET @max = " + cMax + CRLF
cQuery += "SET @curr = " + cMin + CRLF
cQuery += "WHILE @curr <= @max " + CRLF
cQuery += "	BEGIN " + CRLF
cQuery += "	IF(EXISTS(SELECT SF4.F4_CODIGO FROM " + RetSqlName("SF4") + " SF4 "
cQuery += " WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery += "	AND SF4.F4_CODIGO = @curr AND SF4.D_E_L_E_T_ <> '*')) " + CRLF
cQuery += "		SET @curr = @curr + 1 " + CRLF
cQuery += "	ELSE " + CRLF
cQuery += "		BEGIN " + CRLF
cQuery += "			INSERT INTO " + cTable + " (TES_COD, R_E_C_N_O_) VALUES (CAST(@curr AS CHAR(3)), 1) " + CRLF
cQuery += "			BREAK " + CRLF
cQuery += "		END " + CRLF
cQuery += "END " + CRLF

TCSqlExec(cQuery)

(cTable)->(DbGoTop())
If !((cTable)->(Eof()))
cRet := PadL(AllTrim((cTable)->TES_COD), TamSx3("F4_CODIGO")[1], "0")
EndIf

If MsFile(cTable, '', "TOPCONN")
If Select(cTable) > 0
(cTable)->(DbCloseArea())
EndIf

TCDelFile(cTable)
EndIf
*/
If Empty(cRet)
	If !(lAlfaNum) // Apenas TES Num้rica
		cQuery := "SELECT MIN(SF4.F4_CODIGO + 1) CODTES " + CRLF
		cQuery += "FROM " + RetSqlName("SF4") + " SF4 " + CRLF
		cQuery += "WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + CRLF
		cQuery += "	AND SF4.F4_CODIGO BETWEEN '" + cMin + "' AND '" + cMax + "' " + CRLF
		cQuery += "	AND (SF4.F4_CODIGO + 1) NOT IN( " + CRLF
		cQuery += "		SELECT SF4B.F4_CODIGO " + CRLF
		cQuery += "		FROM " + RetSqlName("SF4") + " SF4B " + CRLF
		cQuery += "		WHERE SF4B.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4B.D_E_L_E_T_ <> '*') " + CRLF
		cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
		If Select(cTable) > 0
			(cTable)->(DbCloseArea())
		EndIf
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cTable,.F.,.T.)
		If !((cTable)->(EOF()))
			cRet := PadL(AllTrim(Str((cTable)->CODTES)), TamSx3("F4_CODIGO")[1], "0")
		EndIf
		If Val(cRet) == 0
			cRet := cMin
		EndIf
	Else // TES Alfanum้rica
		Processa( {|| LoadTabTes(cTipo)}, "Carregando tabela de c๓digos da TES", "Por favor aguarde...")
		cRet := ProxTESAN(cTipo)
	EndIf
EndIf
If Select(cTable) > 0
	(cTable)->(DbCloseArea())
EndIf
If !(DbCheckTes(cRet))
	cRet := ""
	If Empty(cRet)
		Aviso("C๓digo da TES","Nใo foi possํvel gerar o c๓digo do TES, Informe o administrador do sistema!",{"OK"}, 2)
	EndIf
EndIf
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ CadTes บAutor ณ Douglas Telles         บ Data ณ 28/08/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o cadastro automแtico da TES.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CadTes()
Local nRet		:= 0
Local nX		:= 0
Local xVal		:= Nil
Local lIpiTrib	:= .F.
ConOut("CadTes: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
RegToMemory("SF4", .T.)
M->F4_CODIGO := ProximaTES("S")
If !(Empty(M->F4_CODIGO))
	M->F4_FILIAL	:= xFilial("SF4")
	M->F4_TIPO		:= "S"
	M->F4_CF		:= _cCFOP_
	M->F4_TEXTO		:= Posicione("SX5", 1, xFilial("SX5") + "13" + M->F4_CF, "X5_DESCRI")
	xVal := Nil
	If Type(cTmpTagICM + ":_vBC:TEXT") != "U"
		xVal := SuperVal(&(cTmpTagICM + ":_vBC:TEXT"))
	Else
		xVal := 0
	EndIf
	M->F4_CREDICM	:= IIF(xVal > 0, "S", "N")
	M->F4_ICM		:= M->F4_CREDICM
	If Type(cTmpTagIPI + ":_CST:TEXT") != "U"
		M->F4_CTIPI	:= &(cTmpTagIPI + ":_CST:TEXT")
		If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "50"
			lIpiTrib := .T.
		Else
			If PadR(&(cTmpTagIPI + ":_CST:TEXT"),2) == "99" .And. Type(cTmpTagIPI + ":_vIPI:TEXT") != "U"
				If Val(&(cTmpTagIPI + ":_vIPI:TEXT")) > 0
					lIpiTrib := .T.
				EndIf
			EndIf
		EndIf
		If lIpiTrib
			M->F4_LFIPI := "T"
		ElseIf M->F4_CTIPI $ "52"
			M->F4_LFIPI := "I"
		ElseIf M->F4_CTIPI $ "51/53/54/55/99"
			M->F4_LFIPI := "O"
		Else
			M->F4_LFIPI := "N"
		EndIf
		M->F4_CREDIPI	:= IIF(lIpiTrib, "S", "N")
		M->F4_IPI		:= M->F4_CREDIPI
	EndIf
	
	// Alteracao 29/05/2019 (CFOP's para nao gerar duplicata, no trecho de criacao mesma logica)
	If SubStr(_cCFOP_,2,3) $ "152/153/155/156/408/409/414/415/451/501/502/504/505/552/554/557/601/602/605/657/658/659/663/664/665/666/901/902/903/904/905/906/907/908/909/910/911/912/913/914/915/916/917/920/923/924/925/934/949/"
		M->F4_DUPLIC	:= "N"
	Else
		M->F4_DUPLIC	:= "S"
	EndIf
	
	If Type(cTmpTagICM + ":_CST:TEXT") != "U"
		M->F4_SITTRIB	:= &(cTmpTagICM + ":_CST:TEXT")
	EndIf
	If M->F4_SITTRIB $ "00/10"
		M->F4_LFICM := "T"
	ElseIf M->F4_SITTRIB $ "30/40"
		M->F4_LFICM := "I"
	ElseIf M->F4_SITTRIB $ "20/41/50/51/60/70/90"
		M->F4_LFICM := "O"
		//If Type(cTmpTagICM + ":_VICMS:TEXT") != "U"
		//	If Val(&(cTmpTagICM + ":_VICMS:TEXT")) != 0
		//		M->F4_LFICM := "T"
		//	Else
		//		M->F4_LFICM := "O"
		//	EndIf
		//Else
		//	M->F4_LFICM := "O"
		//EndIf
		//ElseIf M->F4_SITTRIB $ "41/50/51/0/70"
		//M->F4_LFICM := "O"
	EndIf
	If SuperGetMV("IT_FORCATP",,"N") == "N"
		M->F4_INCIDE	:= IIF(Posicione("SA1", 1, xFilial("SA1") + aChvInfo[06] + aChvInfo[07], "A1_TIPO") == "F", "S", "N")
	Else
		M->F4_INCIDE	:= "N"
	EndIf
	If Type(cTmpTagPIS + ":_CST:TEXT") != "U"
		M->F4_CSTPIS	:= &(cTmpTagPIS + ":_CST:TEXT")
		IF M->F4_CSTPIS $ "01/02/03/04"
			M->F4_PISCRED := "2"
		ELSEIF M->F4_CSTPIS $ "05/06/07/08/09/49"
			M->F4_PISCRED := "3"
		ENDIF
	Else
		// Frank 10-10-17
		M->F4_CSTPIS	:= "49"
		M->F4_PISCRED	:= IIF(M->F4_CSTPIS $ "01/02/03", "2", "3")
	EndIf
	If Type(cTmpTagCOF + ":_CST:TEXT") != "U"
		M->F4_CSTCOF := &(cTmpTagCOF + ":_CST:TEXT")
	EndIf
	M->F4_DESTACA	:= "S"
	M->F4_COMPL		:= "N"
	M->F4_PISCOF	:= "3"
	If Type(cTmpTagICM + ":_pRedBC:TEXT") != "U"
		If !(Empty(&(cTmpTagICM + ":_pRedBC:TEXT")))
			M->F4_BASEICM	:= IIF(val( &(cTmpTagICM + ":_pRedBC:TEXT") ) < 1, 0, noround(100 - val( &(cTmpTagICM + ":_pRedBC:TEXT") ),2))
		EndIf
	EndIf
	M->F4_ESTOQUE	:= "S"
	If AllTrim(_cCFOP_) $ "5901;5904;5905;5908;5910;5911;5912;5914;5915;5917;5920;5923;5924"
		M->F4_PODER3	:= "R"
	ElseIf AllTrim(_cCFOP_) $ "5902;5903;5906;5907;5909;5913;5916;5925"
		M->F4_PODER3	:= "D"
	Else
		M->F4_PODER3	:= "N"
	EndIf
	If (lOpConsFin) .And. (Alltrim(SA1->A1_TIPO) == "F")
		M->F4_DIFAL = '1'
	Else
		M->F4_DIFAL = '2'
	EndIf
	If ExistBlock("PECADTES")
		ExecBlock("PECADTES",.F.,.F.)
	EndIf
	If CpoObrig("SF4")
		RecLock("SF4", .T.)
		For nX := 1 To FCount()
			FieldPut(nX, &("M->" + FieldName(nX)))
		Next nX
		MsUnlock()
		nRet := SF4->(Recno())
	EndIf
EndIf
ConOut("CadTes: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return nRet

/*/{Protheus.doc} CpoObrig
Valida se existe algum campo obrigat๓rio nใo preenchido antes da
grava็ใo de um novo registro via Reclock.
@type function
@author Douglas Telles
@since 22/09/2017
@version 1.0
@param cTabPesq, character, Alias a ser validado.
@return lRet, Indica se todos os campos obrigat๓rios estใo preenchidos.
/*/

Static Function CpoObrig(cTabPesq)
    Local lRet       := .T.
    Local aArea      := GetArea()
    Local cEmpresa   := FWGrpEmp()
    Local cAliasTmp  := GetNextAlias()
    Local cFiltro    := ""
    Default cTabPesq := "   "
    // Abrir a SX3 com um alias temporแrio
    OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)
    (cAliasTmp)->(DbSetOrder(1)) // X3_ARQUIVO+X3_ORDEM
    cFiltro := "X3_ARQUIVO == '" + cTabPesq + "' .And. X3_ORDEM == '01'"
    (cAliasTmp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
    (cAliasTmp)->(DbGoTop())
    lRet := !(cAliasTmp)->(Eof())
    If lRet    
		If (u_ztipo("M->" + GetSX3Cache(cTabPesq, "X3_CAMPO") != "U") .And. X3Obrigat(GetSX3Cache(cTabPesq, "X3_CAMPO")))
			If Empty(&("M->" + GetSX3Cache(cTabPesq, "X3_CAMPO")))
				lRet := .F.
				Aviso("Campo Obrigat๓rio", "O campo " + AllTrim(GetSX3Cache(cTabPesq, "X3_CAMPO")) + " do cadastro da TES nใo possui informa็ใo, Cadastre a TES manualmente!", {"OK"}, 2)
			EndIf
		EndIf
    EndIf
    (cAliasTmp)->(DbCloseArea())
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} NFImpAut
Verifica se a nota a ser importada se encaixa na importa็ใo automแtica de NF.
@author Douglas Telles
@since 04/09/2017
@version undefined
@type function
/*/

User Function NFImpAut(cTipo, cCGCEmi, cCGCDes, cCFOP)
Local cQuery	:= ""
Local lContinua	:= .F.
Local cTmpAlias	:= GetNextAlias()

Local _cFilSA1 := xFilial("SA1")
Local _cFilSA2 := xFilial("SA2")
Local _cFilSF4 := xFilial("SF4")

Local aArea		:= GetArea()
Local aAreaSX2	:= SX2->(GetArea())

Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())

Default cTipo	:= ""
Default cCGCEmi	:= ""
Default cCGCDes	:= ""
Default cCFOP	:= ""
lContinua := SX2->(DbSeek("ZDT"))
If lContinua
	cTipo	:= PadR(cTipo	, TamSx3("ZDT_TIPO")[1])
	cCGCEmi	:= PadR(cCGCEmi	, TamSx3("ZDT_CGCEMI")[1])
	cCGCDes	:= PadR(cCGCDes	, TamSx3("ZDT_CGCDES")[1])
	cCFOP	:= PadR(cCFOP	, TamSx3("ZDT_CFOP")[1])
	
	If cTipo == "S" // "S"=Saida
		cInfo01 := "Operacao: 'S'=Saida"
		cInfo02 := "Emitente: " + RTrim(SM0->M0_CODFIL) + ": " + RTrim(SM0->M0_FILIAL)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
		If (lContinua := SA1->(DbSeek(_cFilSA1 + cCGCDes)))
			cInfo03 := "Destinatario: " + SA1->A1_COD + "/" + SA1->A1_LOJA + ": " + RTrim(SA1->A1_NREDUZ)
		EndIf
	Else // "E"=Entrada
		cInfo01 := "Operacao: 'E'=Entrada"
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
		If (lContinua := SA2->(DbSeek(_cFilSA2 + cCGCEmi)))
			cInfo02 := "Emitente: " + SA1->A1_COD + "/" + SA1->A1_LOJA + ": " + RTrim(SA1->A1_NREDUZ)
		EndIf
		cInfo03 := "Destinatario: " + SM0->M0_CODFIL + ": " + RTrim(SM0->M0_FILIAL)
	EndIf
	
	If lContinua
		cQuery := "SELECT ZDT.ZDT_TES, ZDT.R_E_C_N_O_ RECNO " + CRLF
		cQuery += "FROM " + RetSqlName("ZDT") + " ZDT " + CRLF
		cQuery += "WHERE ZDT.ZDT_FILIAL = '" + xFilial("ZDT") + "' " + CRLF
		cQuery += "	AND ZDT.ZDT_STATUS = '1' " + CRLF
		cQuery += "	AND ZDT.ZDT_TIPO = '" + cTipo + "' " + CRLF
		cQuery += "	AND ZDT.ZDT_CGCEMI = '" + cCGCEmi + "' " + CRLF
		cQuery += "	AND ZDT.ZDT_CGCDES = '" + cCGCDes + "' " + CRLF
		cQuery += "	AND ZDT.ZDT_CFOP = '" + cCFOP + "' " + CRLF
		cQuery += "	AND ZDT.D_E_L_E_T_ = ' ' " + CRLF
		If Select(cTmpAlias) > 0
			(cTmpAlias)->(DbCloseArea())
		EndIf
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
		If (cTmpAlias)->(!EOF())
			DbSelectArea("ZDT")
			ZDT->(DbGoTo((cTmpAlias)->Recno))
			
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1)) // F4_FILIAL + F4_CODIGO
			If SF4->(DbSeek(_cFilSF4 + (cTmpAlias)->ZDT_TES))
				lImpAut := u_AskYesNo(   4000,"TES Automatica","Confirma utilizacao da TES automatica? " + "TES: " + SF4->F4_CODIGO,cInfo01,cInfo02,cInfo03,"Cancelar","UPDINFORMATION")
				// u_AskYesNo(3000,"TES Automatica","Deseja realmente cancelar?"                                        ,""     ,""     ,""     ,"Cancelar","UPDINFORMATION")
			EndIf
			
		EndIf
	EndIf
EndIf
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf

RestArea(aAreaSF4)
RestArea(aAreaSA2)
RestArea(aAreaSA1)

RestArea(aAreaSX2)
RestArea(aArea)
Return

/*/{Protheus.doc} CancelNF
Efetua o cancelamento de uma NF.
@author Douglas Telles
@since 23/08/2017
@type function
/*/

User Function CancelNF(lEntrada)
Local lRet		:= .T.
Local nX		:= 0
Local aPedidos	:= {}
Local cTipoMov	:= ""
Local cCliFor	:= aChvInfo[06]
Local cLoja		:= aChvInfo[07]
Local cDoc		:= aChvInfo[03]
Local cSerie	:= aChvInfo[04]
Default lEntrada	:= Nil
If ValType(lEntrada) != "L"
	Return .F.
EndIf
cTipoMov := IIF(lEntrada, "E", "S")
Begin Transaction
If lEntrada
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If SD1->(DbSeek(xFilial("SD1") + cDoc + cSerie + cCliFor + cLoja, .T.))
		While !(SD1->(Eof())) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == (xFilial("SD1") + cDoc + cSerie + cCliFor + cLoja)
			If aScan(aPedidos, {|aX| SD1->D1_PEDIDO $ aX}) == 0
				Aadd(aPedidos, SD1->D1_PEDIDO)
			EndIf
			DeletReg("SD1")
			SD1->(DbSkip())
		End
	EndIf
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(DbSeek(xFilial("SF1") + cDoc + cSerie + cCliFor + cLoja, .T.))
		While !(SF1->(Eof())) .And. SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) == (xFilial("SF1") + cDoc + cSerie + cCliFor + cLoja)
			DeletReg("SF1")
			SF1->(DbSkip())
		End
	EndIf
	DbSelectArea("SE2")
	SE2->(DbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If SE2->(DbSeek(xFilial("SE2") + cCliFor + cLoja + cSerie + cDoc, .T.))
		While !(SE2->(Eof())) .And. SE2->(E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM) == (xFilial("SE2") + cCliFor + cLoja + cSerie + cDoc)
			DeletReg("SE2")
			SE2->(DbSkip())
		End
	EndIf
	For nX := 1 To Len(aPedidos)
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1)) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		If SC7->(DbSeek(xFilial("SC7") + aPedidos[nX], .T.))
			While !(SC7->(Eof())) .And. SC7->(C7_FILIAL + C7_NUM) == (xFilial("SC7") + aPedidos[nX])
				DeletReg("SC7")
				SC7->(DbSkip())
			End
		EndIf
	Next
Else
	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If SD2->(DbSeek(xFilial("SD2") + cDoc + cSerie + cCliFor + cLoja, .T.))
		While !(SD2->(Eof())) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == (xFilial("SD2") + cDoc + cSerie + cCliFor + cLoja)
			If aScan(aPedidos, {|aX| SD2->D2_PEDIDO $ aX}) == 0
				Aadd(aPedidos, SD2->D2_PEDIDO)
			EndIf
			DeletReg("SD2")
			SD2->(DbSkip())
		End
	EndIf
	DbSelectArea("SF2")
	SF2->(DbSetOrder(2)) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
	If SF2->(DbSeek(xFilial("SF2") + cCliFor + cLoja + cDoc + cSerie))
		While !(SF2->(Eof())) .And. SF2->(F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_DOC + F2_SERIE) == (xFilial("SF2") + cCliFor + cLoja + cDoc + cSerie)
			DeletReg("SF2")
			SF2->(DbSkip())
		End
	EndIf
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1") + cCliFor + cLoja + cSerie + cDoc, .T.))
		While !(SE1->(Eof())) .And. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == (xFilial("SE1") + cCliFor + cLoja + cSerie + cDoc)
			DeletReg("SE1")
			SE1->(DbSkip())
		End
	EndIf
	For nX := 1 To Len(aPedidos)
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(DbSeek(xFilial("SC6") + aPedidos[nX], .T.))
			While !(SC6->(Eof())) .And. SC6->(C6_FILIAL + C6_NUM) == (xFilial("SC6") + aPedidos[nX])
				DeletReg("SC6")
				SC6->(DbSkip())
			End
		EndIf
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
		If SC5->(DbSeek(xFilial("SC5") + aPedidos[nX]))
			While !(SC5->(Eof())) .And. SC5->(C5_FILIAL + C5_NUM) == (xFilial("SC5") + aPedidos[nX])
				DeletReg("SC5")
				SC5->(DbSkip())
			End
		EndIf
	Next
EndIf
DbSelectArea("SF3")
SF3->(DbSetOrder(4)) // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
If SF3->(DbSeek(xFilial("SF3") + cCliFor + cLoja + cDoc + cSerie))
	While !(SF3->(Eof())) .And. SF3->(F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SERIE) == (xFilial("SF3") + cCliFor + cLoja + cDoc + cSerie)
		RecLock("SF3", .F.)
		SF3->F3_DTCANC := aChvInfo[05]
		SF3->F3_OBSERV := "NF CANCELADA"
		MsUnlock()
		SF3->(DbSkip())
	End
EndIf
DbSelectArea("SFT")
SFT->(DbSetOrder(1)) // FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
If SFT->(DbSeek(xFilial("SFT") + cTipoMov + cSerie + cDoc + cCliFor + cLoja, .T.))
	While !(SFT->(Eof())) .And. SFT->(FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA) == (xFilial("SFT") + cTipoMov + cSerie + cDoc + cCliFor + cLoja)
		RecLock("SFT", .F.)
		SFT->FT_DTCANC := aChvInfo[05]
		SFT->FT_OBSERV := "NF CANCELADA"
		MsUnlock()
		SFT->(DbSkip())
	End
EndIf
End Transaction
Return lRet

/*/{Protheus.doc} DeletReg
Deleta o registro posicionado de uma tabela.
@author Douglas Telles
@since 25/08/2017
@param cTab, characters, C๓digo da tabela a ter o registro deletado.
@type function
/*/

Static Function DeletReg(cTab)
Reclock(cTab, .F.)
DbDelete()
MsUnlock()
Return

User function fzf35
SC5->(dbGotop())
While !SC5->(Eof())
	RecLock("SC5",.F.)
	SC5->(dbDelete())
	SC5->(MsUnlock())
	SC5->(dbSkip())
End
SC6->(dbGotop())
While !SC6->(Eof())
	RecLock("SC6",.F.)
	SC6->(dbDelete())
	SC6->(MsUnlock())
	SC6->(dbSkip())
End
SF1->(dbGotop())
While !SF1->(Eof())
	RecLock("SF1",.F.)
	SF1->(dbDelete())
	SF1->(MsUnlock())
	SF1->(dbSkip())
End
SF4->(dbGotop())
While !SF4->(Eof())
	RecLock("SF4",.F.)
	SF4->(dbDelete())
	SF4->(MsUnlock())
	SF4->(dbSkip())
End
SFT->(dbGotop())
While !SFT->(Eof())
	RecLock("SFT",.F.)
	SFT->(dbDelete())
	SFT->(MsUnlock())
	SFT->(dbSkip())
End
SF3->(dbGotop())
While !SF3->(Eof())
	RecLock("SF3",.F.)
	SF3->(dbDelete())
	SF3->(MsUnlock())
	SF3->(dbSkip())
End
SF2->(dbGotop())
While !SF2->(Eof())
	RecLock("SF2",.F.)
	SF2->(dbDelete())
	SF2->(MsUnlock())
	SF2->(dbSkip())
End
SB1->(dbGotop())
While !SB1->(Eof())
	RecLock("SB1",.F.)
	SB1->(dbDelete())
	SB1->(MsUnlock())
	SB1->(dbSkip())
End
SD2->(dbGotop())
While !SD2->(Eof())
	RecLock("SD2",.F.)
	SD2->(dbDelete())
	SD2->(MsUnlock())
	SD2->(dbSkip())
End
SA1->(dbGotop())
While !SA1->(Eof())
	RecLock("SA1",.F.)
	SA1->( dbDelete() )
	SA1->(MsUnlock())
	SA1->(dbSkip())
End
MsgStop("tabelas zeradas")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ CarregaX บAutor  ณ Frank Z Fuga       บ Data ณ  10/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche campo, valida e dispara gatilhos                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ITUP / ECCO                                                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function CarregaX()
Local _nX
Local _lProc    := .F.
Local _nPosProd := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_COD" })
Local _nPosItem := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_ITEM" })
Local _nPosLoca := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_LOCAL" })
Local _nPosQuan := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_QUANT" })
Local _nPosPrcv := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_PRCVEN" })
Local _nPosTota := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_TOTAL" })
Local _nPosTes  := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_TES" })
Local _nPosCF   := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_CF" })
Local _nPosCONT := aScan(aHeader, { |x| Alltrim(x[02]) == "D2_CONTA" })
Local _nPosUM	:= aScan(aHeader, { |x| Alltrim(x[02]) == "D2_UM" })
Local aCols0	:= {}
For _nX:=1 to 6
	If alltrim(ProcName(_nX)) == "U_GETCHVSNF"
		_lProc := .T.
	EndIf
Next
If !_lProc
	Return ""
EndIf
c920Nota	:= aChvInfo[03]
c920Serie	:= aChvInfo[04]
c920Client	:= aChvInfo[06]
c920Loja	:= aChvInfo[07]
d920Emis	:= aChvInfo[05]
cTipo		:= aChvInfo[01]
c920Especi	:= aChvInfo[08]
// MAFISINI(c920Client,c920Loja,IIf(cTipo$'DB',"F","C"),cTipo,IIf(cTipo$'DB',Nil,SA1->A1_TIPO),MaFisRelImp("MT100",{"SF2","SD2"}),,.T.)
aCols0 := {}
For _nX := 1 to Len(aHeader)
	If !aHeader[_nX,10]=="V"
		SD2->( AAdd( aCols0,FieldGet( FieldPos( aHeader[_nX,2]))))
	Else
		SD2->(AAdd(aCols0,CriaVar(aHeader[_nX,2])))
	EndIf
Next
aAdd(aCols0,.F.)
aCols := {}
aCols0[1] := ""
For _nX := 1 To Len(aChvInfo[20])
	//If _nX > 1
	aAdd(aCols,aCols0)
	//EndIf
	SB1->(DbGoto(aChvInfo[20][_nX][1])) // Recno SB1
	aCols[len(aCols)][_nPosItem]	:= StrZero(_nX, TamSx3("D2_ITEM")[1])
	aCols[len(aCols)][_nPosProd]	:= SB1->B1_COD
	aCols[len(aCols)][_nPosLoca]	:= SB1->B1_LOCPAD
	aCols[len(aCols)][_nPosUM]		:= SB1->B1_UM
	//MAFISRET("IT_PRODUTO","MT100",SB1->B1_COD)
	aCols[len(aCols)][_nPosQuan]	:= aChvInfo[20][_nX][8]
	//MAFISRET("IT_QUANT","MT100",aCols[_nX][_nPosQuan])
	aCols[len(aCols)][_nPosPrcv]	:= aChvInfo[20][_nX][9]
	//MAFISRET("IT_PRCUNI","MT100",aCols[_nX][_nPosPrcv])
	aCols[len(aCols)][_nPosTota]	:= aChvInfo[20][_nX][10]
	//MAFISRET("IT_VALMERC","MT100",aCols[_nX][_nPosTota])
	SF4->(DbGoto(aChvInfo[20][_nX][13][5])) // Recno SF4
	If SF4->(Recno()) == aChvInfo[20][_nX][13][5]
		aCols[len(aCols)][_nPosTES]	:= SF4->F4_CODIGO
		//MAFISRET("IT_TES","MT100",SF4->F4_CODIGO)
		aCols[len(aCols)][_nPosCF]		:= SF4->F4_CF
		If SF4->(FieldPos("F4_XCONTA")) > 0 .and. !(Empty(SF4->F4_XCONTA))
			aCols[len(aCols)][_nPosCF]	:= SF4->F4_XCONTA
			//MAFISRET("IT_CF","MT100",SF4->F4_XCONTA)
		EndIf
	EndIf
	// oGetDados:oBrowse:Refresh()
	MaFisAlt("IT_TES",aCols[len(aCols)][_nPosTes],len(aCols))
	//eval(bListRefresh)
	//MaColsToFis(aHeader,aCols,len(aCols),"MT100",.T.,.F.,.T.)
	//eval(bDoRefresh)
Next
Return ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ PergParam บ Autor ณ Michel Taipina     บ Data ณ 15/10/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pergunta para selecao da Tes.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function PergParam(aRet)
Local _aAreaOld := GetArea()
Local _aAreaSF4 := SF4->(GetArea())
Local _aPergs   := {}
Local _aRet     := {}
Local _lRet     := .f.
Local _cTes     := ""
// Definicao do valor default das perguntas
_cTes := iif(SF4->(FieldPos("F4_CODIGO"))>0 ,Space(SF4->(GetSx3Cache("F4_CODIGO","X3_TAMANHO"))),Space(03))
// Definicao das perguntas
aAdd( _aPergs ,{1,"TES: "      , _cTes ,"@!"	,'.t.',"SF4"   ,'.t.'	   , 50,.t.})
If ParamBox(_aPergs ,"Parametros ",_aRet, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.)
	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))	// F4_FILIAL + F4_CODIGO
	If SF4->(DbSeek(xFilial("SF4") + _aRet[01]))
		aRet[05] := SF4->(Recno())
		_lRet := .t.
	EndIf
EndIf
SF4->(RestArea(_aAreaSF4))
RestArea(_aAreaOld)
Return _lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณXMLXFUN_  บAutor ณ Douglas Telles       บ Data ณ 05/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Double Check para verificar se o c๓digo da TES nใo estแ    บฑฑ
ฑฑบ          ณ sendo utilizado.                                           บฑฑ
ฑฑบ          ณ Parametros recebidos:                                      บฑฑ
ฑฑบ          ณ cCodTes: character, Codigo da TES a ser verificado         บฑฑ
ฑฑบ          ณ Retorno:                                                   บฑฑ
ฑฑบ          ณ lTesEmUso: boolean, Indica se c๓digo do TES estแ em uso.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function DbCheckTes(cCodTes)
Local lTesEmUso	:= .T.
Local cQuery	:= ''
Local cTmpAlias	:= GetNextAlias()
Default cCodTes	:= ""
If !(Empty(cCodTes))
	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SF4") + " SF4 " + CRLF
	cQuery += "WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' " + CRLF
	cQuery += "	AND SF4.F4_CODIGO = '" + cCodTes + "' " + CRLF
	cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
	If (Select(cTmpAlias) > 0)
		(cTmpAlias)->(DbCloseArea())
	EndIf
	DbUseArea(.T., 'TOPCONN', TCGenQry(,, cQuery), cTmpAlias, .F., .T.)
	lTesEmUso := !((cTmpAlias)->(Eof()))
EndIf
If (Select(cTmpAlias) > 0)
	(cTmpAlias)->(DbCloseArea())
EndIf
Return !lTesEmUso

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LoadTabTes บAutor ณ Douglas Telles    บ Data ณ  08/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o carregamento da tabela de c๓digos da TES caso    บฑฑ
ฑฑบ          ณ nใo exista.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LoadTabTes(cTipo)
Local cDigTes1	:= ""
Local cDigTes2	:= ""
Local cDigTes3	:= ""
Local cQuery	:= ""
Local cTmpAlias	:= GetNextAlias()
Local cTable	:= "DEPARATES"
Local cIndex	:= cTable + "1"
Local aEstruct	:= { { 'FILIAL', 'C', TamSx3("F4_FILIAL")[1], 0 }, { 'TIPO', 'C', 01, 0 }, { 'CODTES', 'C', TamSx3("F4_CODIGO")[1], 0 } }
If !(MsFile(cTable, '', "TOPCONN"))
	DbCreate(cTable, aEstruct, "TOPCONN")
	DbUseArea(.T.,"TOPCONN",cTable,cTable,.F.,.F.)
	DBCreateIndex(cIndex, "FILIAL+TIPO+CODTES", {|| "FILIAL+TIPO+CODTES"}, .F.)
EndIf
cQuery := "SELECT COUNT(*) QTD " + CRLF
cQuery += "FROM DEPARATES DPT " + CRLF
cQuery += "WHERE DPT.FILIAL = '" + xFilial("SF4") + "' " + CRLF
cQuery += "	AND DPT.TIPO = '" + cTipo + "' " + CRLF
cQuery += "	AND DPT.D_E_L_E_T_ <> '*' " + CRLF
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
If (cTmpAlias)->(EoF()) .Or. ((cTmpAlias)->QTD == 0)
	cDigTes1 := IIF(cTipo == "E", "0", "5")
	cDigTes2 := "0"
	cDigTes3 := "1"
	DbSelectArea("DEPARATES")
	DEPARATES->(DbSetOrder(1)) // FILIAL+TIPO+CODTES
	While .T.
		If !(DEPARATES->(DbSeek(xFilial("SF4") + cTipo + cDigTes1 + cDigTes2 + cDigTes3)))
			RecLock("DEPARATES", .T.)
			DEPARATES->FILIAL	:= xFilial("SF4")
			DEPARATES->TIPO		:= cTipo
			DEPARATES->CODTES	:= cDigTes1 + cDigTes2 + cDigTes3
			MsUnlock()
		EndIf
		If (cTipo == "E")
			If cDigTes1 == '4' .And. cDigTes2 == 'Z' .And. cDigTes3 = 'Z'
				Exit
			EndIf
			If cDigTes3 == 'Z'
				If cDigTes2 == 'Z'
					cDigTes1 := Soma1(cDigTes1)
					cDigTes2 := "0"
				Else
					cDigTes2 := Soma1(cDigTes2)
				EndIf
				cDigTes3 := "0"
			Else
				cDigTes3 := Soma1(cDigTes3)
			EndIf
		EndIf
		If (cTipo == "S")
			If cDigTes1 == '9' .And. cDigTes2 == 'Z' .And. cDigTes3 = 'Z'
				Exit
			EndIf
			If cDigTes3 == 'Z'
				If cDigTes2 == 'Z'
					cDigTes1 := Soma1(cDigTes1)
					cDigTes2 := "0"
				Else
					cDigTes2 := Soma1(cDigTes2)
				EndIf
				cDigTes3 := "0"
			Else
				cDigTes3 := Soma1(cDigTes3)
			EndIf
		EndIf
	End
EndIf
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ ProxTESAN บAutor ณ Douglas Telles      บ Data ณ 05/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa o pr๓ximo c๓digo de TES disponํvel alfa num้rico. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ProxTESAN(cTipo)
Local cRet := PadL("", TamSx3("F4_CODIGO")[1])
Local cQuery := ""
Local cTmpAlias	:= GetNextAlias()
cQuery := "SELECT MIN(DPT.CODTES) CODTES " + CRLF
cQuery += "FROM DEPARATES DPT " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SF4") + " SF4 " + CRLF
cQuery += "	ON SF4.F4_FILIAL = DPT.FILIAL " + CRLF
cQuery += "	AND SF4.F4_TIPO = DPT.TIPO " + CRLF
cQuery += "	AND SF4.F4_CODIGO = DPT.CODTES " + CRLF
cQuery += "	AND SF4.D_E_L_E_T_ <> '*' " + CRLF
cQuery += "WHERE DPT.FILIAL = '" + xFilial("SF4") + "' " + CRLF
cQuery += "	AND DPT.TIPO = '" + cTipo + "' " + CRLF
cQuery += "	AND SF4.F4_CODIGO IS NULL " + CRLF
cQuery += "	AND DPT.D_E_L_E_T_ <> '*' " + CRLF
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
If !((cTmpAlias)->(EOF()))
	cRet := (cTmpAlias)->CODTES
EndIf
If Select(cTmpAlias) > 0
	(cTmpAlias)->(DbCloseArea())
EndIf
Return cRet
