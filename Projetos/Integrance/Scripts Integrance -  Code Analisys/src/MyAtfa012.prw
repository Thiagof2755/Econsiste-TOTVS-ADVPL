#INCLUDE "PROTHEUS.CH"

// Exemplo de Inclusao

User Function MyAtfa012
Local aArea := GetArea()
Local cBase := "0000000000"
Local cItem := "0000"
Local cDescri := "TESTE"
Local nQtd := 1
Local cChapa := "00000"
Local cPatrim := "N"
Local cGrupo := "01"
Local dAquisic := dDataBase
Local dIndDepr := RetDinDepr(dDataBase)
Local cDescric := "Teste 01"
Local nQtd := 2
Local cChapa := "00000"
Local cPatrim := "N"
Local cTipo := "01"
Local cHistor := "TESTE "
Local cContab := "11101"
Local cCusto := "CDL"
Local nValor := 1000
Local nTaxa := 10
Local nTamBase := TamSX3("N3_CBASE")[1]
Local nTamChapa := TamSX3("N3_CBASE")[1]
Local cGrupo := "0001"
Local aParam := {}
Local aCab := {}
Local aItens := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
aCab := {}
AAdd(aCab,{"N1_CBASE" , cBase ,NIL})
AAdd(aCab,{"N1_ITEM" , cItem ,NIL})
AAdd(aCab,{"N1_AQUISIC", dDataBase ,NIL})
AAdd(aCab,{"N1_DESCRIC", cDescric ,NIL})
AAdd(aCab,{"N1_QUANTD" , nQtd ,NIL})
AAdd(aCab,{"N1_CHAPA" , cChapa ,NIL})
AAdd(aCab,{"N1_PATRIM" , cPatrim ,NIL})
AAdd(aCab,{"N1_GRUPO" , cGrupo ,NIL})
aItens := {} // Preenche itens

aAdd(aItens,{;
{"N3_CBASE" , cBase ,NIL},;
{"N3_ITEM" , cItem ,NIL},;
{"N3_TIPO" , cTipo ,NIL},;
{"N3_BAIXA" , "0" ,NIL},;
{"N3_HISTOR" , cHistor ,NIL},;
{"N3_CCONTAB" , cContab ,NIL},;
{"N3_CUSTBEM" , cCusto ,NIL},;
{"N3_CDEPREC" , cContab ,NIL},;
{"N3_CDESP" , cContab ,NIL},;
{"N3_CCORREC" , cContab ,NIL},;
{"N3_CCUSTO" , cCusto ,NIL},;
{"N3_DINDEPR" , dIndDepr ,NIL},;
{"N3_VORIG1" , nValor ,NIL},;
{"N3_TXDEPR1" , nTaxa ,NIL},;
{"N3_VORIG2" , nValor ,NIL},;
{"N3_TXDEPR2" , nTaxa ,NIL},;
{"N3_VORIG3" , nValor ,NIL},;
{"N3_TXDEPR3" , nTaxa ,NIL},;
{"N3_VORIG4" , nValor ,NIL},;
{"N3_TXDEPR4" , nTaxa ,NIL},;
{"N3_VORIG5" , nValor ,NIL},;
{"N3_TXDEPR5" , nTaxa ,NIL};
})
Begin Transaction
MsExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
If lMsErroAuto
	MostraErro()
	DisarmTransaction()
Endif
End Transaction
RestArea(aArea)
Return

// Exemplo de Alteração:

User Function MyAltAtfa012
Local aArea := GetArea()
Local nQtd := 1
Local dAquisic := dDataBase
Local dIndDepr := RetDinDepr(dDataBase)
Local nQtd := 2
Local nValor := 1000
Local nTaxa := 10
Local nTamBase := TamSX3("N3_CBASE")[1]
Local nTamChapa := TamSX3("N3_CBASE")[1]
Local cGrupo := "0001"
Local aParam := {}
Local aCab := {}
Local aItens := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
If SN1->(DbSeek(xFilial("SN1")+"0000000000"+"0001"))
	aCab := {}
	AAdd(aCab,{"N1_CBASE" , SN1->N1_CBASE ,NIL})
	AAdd(aCab,{"N1_ITEM" , SN1->N1_ITEM ,NIL})
	AAdd(aCab,{"N1_AQUISIC", SN1->N1_AQUISIC ,NIL})
	AAdd(aCab,{"N1_DESCRIC", "TESTE MYAATF012 2" ,NIL})
	AAdd(aCab,{"N1_QUANTD" , SN1->N1_QUANTD ,NIL})
	AAdd(aCab,{"N1_CHAPA" , SN1->N1_CHAPA ,NIL})
	AAdd(aCab,{"N1_PATRIM" , SN1->N1_PATRIM ,NIL})
	AAdd(aCab,{"N1_GRUPO" , SN1->N1_GRUPO ,NIL})
	aItens := {} // Preenche itens
	SN3->(DbSetOrder(1))//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	If SN3->(DbSeek(xFilial("SN3")+"0000000000"+"0001"+"01"+"0"+"001"))
		aAdd(aItens,{;
		{"N3_CBASE" , SN3->N3_CBASE ,NIL},;
		{"N3_ITEM" , SN3->N3_ITEM ,NIL},;
		{"N3_TIPO" , SN3->N3_TIPO ,NIL},;
		{"N3_BAIXA" , SN3->N3_BAIXA ,NIL},;
		{"N3_HISTOR" , "TESTE MYAATF012 2" ,NIL},;
		{"N3_CCONTAB" , SN3->N3_CCONTAB ,NIL},;
		{"N3_CUSTBEM" , SN3->N3_CUSTBEM ,NIL},;
		{"N3_CDEPREC" , SN3->N3_CDEPREC ,NIL},;
		{"N3_CDESP" , SN3->N3_CDESP ,NIL},;
		{"N3_CCORREC" , SN3->N3_CCORREC ,NIL},;
		{"N3_CCUSTO" , SN3->N3_CCUSTO ,NIL},;
		{"N3_DINDEPR" , SN3->N3_DINDEPR ,NIL},;
		{"N3_VORIG1" , SN3->N3_VORIG1 ,NIL},;
		{"N3_TXDEPR1" , SN3->N3_TXDEPR1 ,NIL},;
		{"N3_VORIG2" , SN3->N3_VORIG2 ,NIL},;
		{"N3_TXDEPR2" , SN3->N3_TXDEPR2 ,NIL},;
		{"N3_VORIG3" , SN3->N3_VORIG3 ,NIL},;
		{"N3_TXDEPR3" , SN3->N3_TXDEPR3 ,NIL},;
		{"N3_VORIG4" , SN3->N3_VORIG4 ,NIL},;
		{"N3_TXDEPR4" , SN3->N3_TXDEPR4 ,NIL},;
		{"N3_VORIG5" , SN3->N3_VORIG5 ,NIL},;
		{"N3_SEQ" , SN3->N3_SEQ ,NIL},;
		{"N3_TXDEPR5" , SN3->N3_TXDEPR5 ,NIL}})
	EndIf
	Begin Transaction
	MsExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,4,aParam)
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	Endif
	End Transaction
EndIf
RestArea(aArea)
Return

// Obs.: Nos casos em que ocorram mais de uma linha na tabela SN3, é obrigatório a passagem do campo N3_SEQ ( Conforme exemplo acima ).
// Exemplo de Exclusão:

User Function MyExcAtfa012
Local aArea := GetArea()
Local nQtd := 1
Local dAquisic := dDataBase
Local dIndDepr := RetDinDepr(dDataBase)
Local nQtd := 2
Local nValor := 1000
Local nTaxa := 10
Local nTamBase := TamSX3("N3_CBASE")[1]
Local nTamChapa := TamSX3("N3_CBASE")[1]
Local cGrupo := "0001"
Local aParam := {}
Local aCab := {}
Local aItens := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
If SN1->(DbSeek(xFilial("SN1")+"0000000000"+"0001"))
	aCab := {}
	AAdd(aCab,{"N1_CBASE" , SN1->N1_CBASE ,NIL})
	AAdd(aCab,{"N1_ITEM" , SN1->N1_ITEM ,NIL})
	AAdd(aCab,{"N1_AQUISIC", SN1->N1_AQUISIC ,NIL})
	AAdd(aCab,{"N1_DESCRIC", "TESTE MYAATF012" ,NIL})
	AAdd(aCab,{"N1_QUANTD" , SN1->N1_QUANTD ,NIL})
	AAdd(aCab,{"N1_CHAPA" , SN1->N1_CHAPA ,NIL})
	AAdd(aCab,{"N1_PATRIM" , SN1->N1_PATRIM ,NIL})
	AAdd(aCab,{"N1_GRUPO" , SN1->N1_GRUPO ,NIL})
	Begin Transaction
	MsExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,Nil,5,aParam)
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
	Endif
	End Transaction
EndIf
RestArea(aArea)
Return 