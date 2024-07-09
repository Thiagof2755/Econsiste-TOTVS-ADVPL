#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma ³ MA080MNU ºAutor ³Marcelo Garcia           º Data ³ 03/02/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ PE para adicionar função na aRotina do Cadsatro de TES      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ INTEGRANCE                                                  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MA080MNU()
Local aRotina := ParamIxb[1]
aAdd(aRotina, { "Copia" , "u_fCopiaSF4()" , 0 , 4, 15, Nil })
Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma ³ GCCPTES ºAutor ³Marcelo Garcia            º Data ³ 03/02/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³Copiar a TES atual para uma nova com novo código e/ou filial    º±±
±±º ³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso ³ Guacira .                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function fCopiaSF4()
Local nI := 0
Local cQuery := ""
Local aStruct := {}
Local cCod := SF4->F4_CODIGO
Local cCodNew, cFilNew
local nRecno:=SF4->(RecNo())
If xFilial("SF4") # SF4->F4_FILIAL .Or. (SF4->(EOF()) .And. SF4->(BOF()))
	HELP(" ",1,"ARQVAZIO")
	Return .F.
EndIf
ValidPerg('COPYTES')
Pergunte("COPYTES",.T.)
cCodNew:=PadR(MV_PAR01,(TamSX3("F4_CODIGO")[1]))
cFilNew:=PadR(MV_PAR02,(TamSX3("F4_FILIAL")[1]))
If Alltrim(cCodNew) == ''
	Aviso("Finalizado","Processo finalizado sem alterações" ,{'Ok'})
	Return .F.
EndIf
nRecno := SF4->(RecNo())
DbSelectArea("SF4")
SF4->( DbSetOrder(1) )
If (MsSeek(cFilNew+cCodNew ))
	Aviso("Atenção...","Código de TES (" + cCodNew + ") ja existente para a filial " + cFilNew ,{'Ok'})
	Return(.f.)
EndIf
SF4->(dbgoto(nRecno))
If (SF4->F4_TIPO == 'E' .And. cCodNew > "500") .Or. (SF4->F4_TIPO == "S" .And. cCodNew <= "500")
	Help(" ",1,"F4_TIPO")
	Return(.F.)
EndIf
SF4->(DbSetOrder(1))
If SF4->(MsSeek(xFilial("SF4") + cCod))
	aStruct := SF4->(DbStruct())
	cQuery := " SELECT * " + ;
	" FROM " + RetSqlName("SF4") + ;
	" WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND " + ;
	" F4_CODIGO = '" + cCod + "' AND " + ;
	" D_E_L_E_T_ = ' ' "
	PLSQuery(cQuery, "SF4TMP")
	If SF4TMP->(!EOF())
		SF4->(RecLock("SF4", .T.))
		For nI := 1 To Len(aStruct)
			If SF4->(FieldPos(aStruct[nI,1])) > 0 .And. SF4TMP->(FieldPos(aStruct[nI,1])) > 0
				&("SF4->" + aStruct[nI][1]) := &("SF4TMP->" + aStruct[nI][1])
			Endif
		Next nI
		SF4->F4_FILIAL := cFilNew
		SF4->F4_CODIGO := cCodNew
		SF4->( MsUnLock() )
	Else
		Return .F.
	EndIf
	SF4TMP->( DbCloseArea() )
EndIf
Aviso("Finalizado","Processo finalizado" ,{'Ok'})
Return .T.

Static Function ValidPerg(cPerg)
Local _sAlias,i,j
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,10)
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/f3
aAdd(aRegs,{cPerg,"01","Nova TES","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Filial ","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
For i := 1 To Len(aRegs)
	If !DbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 To FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
		dbCommit()
	EndIf
Next
DbSelectArea(_sAlias)
Return
