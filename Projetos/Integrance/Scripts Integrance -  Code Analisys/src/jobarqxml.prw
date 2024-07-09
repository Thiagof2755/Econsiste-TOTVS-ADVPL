#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ JOBARQXML บAutor ณFrank Zwarg Fuga    บ Data ณ  11/24/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao dos xmls processados do sefaz nos diretorios de    บฑฑ
ฑฑบ          ณ cada empresa filial                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                Jonathan Schmidt Alves บ Data ณ  29/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function JOBARQXML(_cEmpX, _cFilX)
Local _aProcessa  := {}
Local _nX
Local _cProcessos := ""
Local _cTemp      := ""
Local MV_PAR01
Local cAlias1     := ""
Local cPatch
Local oScript
Local cError      := ""
Local cWarning    := ""
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
_cProcessos := SuperGetMV("IT_JOBARQX",.F.,"080101") // indica quais empresas e filiais serao processadas, 080101;080102;030101... Empresa + Filial + ;
For _nX := 1 To Len(_cProcessos)
	If SubStr(_cProcessos, _nX, 01) <> ";"
		_cTemp += substr(_cProcessos, _nX, 01)
	EndIf
	If SubStr(_cProcessos, _nX, 01) == ";"
		aAdd(_aProcessa,_cTemp)
		_cTemp := ""
	EndIf
	If _nX == Len(_cProcessos) .And. !Empty(_cTemp)
		aAdd(_aProcessa, _cTemp)
	EndIf
Next
RESET ENVIRONMENT
For _nX := 1 To Len(_aProcessa)
	PREPARE ENVIRONMENT EMPRESA substr(_aProcessa[_nX],1,2) FILIAL substr(_aProcessa[_nX],3,4)
	// Local da gravacao do XML
	//mv_par01 := SuperGetMV("IT_DIRJOB",.F.,"C:\TEMP\")
	Mv_Par01 := zGetmv("IT_DIRJOB")
	SX6->(DbSetOrder(1))
	SX6->(DbSeek(SubStr(_aProcessa[_nX],3,4)+"IT_DIRJOB"))
	If SX6->(Eof())
		Loop
	EndIf
	If ValType(Mv_Par01) == "L"
		Loop
	EndIf
	cAlias1 := u_RETMV("ZZO")
	If !AliasInDic(cAlias1)
		Loop
	EndIf
	If Empty(Mv_Par01)
		Loop
	EndIf
	If Right( Alltrim( mv_par01 ), 1 ) != "\"
		Mv_Par01 := Alltrim( mv_par01 ) + "\"
	EndIf
	(cAlias1)->(DbGotop())
	While (cAlias1)->(!EOF()) // Validar a filial
		If (cAlias1)->ZZO_OBRA <> substr(_aProcessa[_nX],3,4)
			(cAlias1)->(DbSkip())
			Loop
		EndIf
		cPatch	:= AllTrim(Mv_Par01) + AllTrim( &((cAlias1)->(cAlias1 + "_CHVNFE"))) + ".xml"
		If !File(cPatch)
			MemoWrite(cPatch, &((cAlias1)->(cAlias1 + "_XML")))
			If File(cPatch)
				(cAlias1)->(RecLock((cAlias1),.F.))
				(cAlias1)->(DbDelete())
				(cAlias1)->(MsUnlock())
			EndIf
		Else
			(cAlias1)->(RecLock((cAlias1),.F.))
			(cAlias1)->(DbDelete())
			(cAlias1)->(MsUnlock())
		EndIF
		(cAlias1)->(DbSkip())
	End
	RESET ENVIRONMENT
Next
Return
