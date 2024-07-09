#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ M030INC  ºAutor³ Jonathan Schmidt Alves ºData³  19/09/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. na rotina MATA030 (Cadastro de Clientes) para         º±±
±±º          ³ tratar a inclusao do item contabil (CTD).                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function M030INC()
Local cItem := "C" + SA1->A1_COD + SA1->A1_LOJA // C=Cliente F=Fornecedor
ConOut("MA030INC: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
DbSelectArea("CTD")
CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
If CTD->(MsSeek(xFilial("CTD") + cItem))
	RecLock("CTD",.F.)
Else
	RecLock("CTD",.T.)
	CTD->CTD_FILIAL := xFilial("CTD")
	CTD->CTD_ITEM := cItem
EndIf
CTD->CTD_CLASSE := "2" // 1=Sintetica 2=Analitica
CTD->CTD_NORMAL := "1" // 1=Receita 2=Despesa
CTD->CTD_DESC01 := AllTrim(SA1->A1_NREDUZ)
CTD->CTD_DTEXIS := CtoD("19800101")
CTD->CTD_BLOQ   := "2" // Nao Bloqueado
CTD->(MsUnlock())
RecLock("SA1",.F.)
If SA1->(FieldPos("A1_ITEMCTA")) > 0
	SA1->A1_ITEMCTA := cItem // Marco no cliente como gerado
EndIf
SA1->(MsUnLock())
ConOut("MA030INC: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return