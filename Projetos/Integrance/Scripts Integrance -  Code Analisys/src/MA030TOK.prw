#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MA030TOK ºAutor ³ Jonathan Schmidt Alves ºData³ 20/02/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. na rotina MATA020 (Cadastro de Clientes) para         º±±
±±º          ³ tratar a inclusao de itens contabeis na validacao do       º±±
±±º          ³ cliente. Usado este ponto para inclusao de clientes        º±±
±±º          ³ em consultas padroes onde o P.E. MA030INC nao esta sendo   º±±
±±º          ³ chamado.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MA030TOK()
Local lRet := .T.
Local cItem := "C" + M->A1_COD + M->A1_LOJA // C=Cliente F=Fornecedor
Local aArea := GetArea()
Local aAreaSA1 := SA1->(GetArea())
ConOut("MA030TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If !("MATA030" $ FunName()) .And. Inclui // Inclusao de cliente nao passando pela MATA030 (consulta padrao, etc)
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
	CTD->CTD_DESC01 := AllTrim(M->A1_NREDUZ)
	CTD->CTD_DTEXIS := CtoD("19800101")
	CTD->CTD_BLOQ   := "2" // Nao Bloqueado
	CTD->(MsUnlock())
	// Atualizacao do Item Contabil no SA2
	M->A1_ITEMCTA := CTD->CTD_ITEM
EndIf
ConOut("MA030TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
RestArea(aAreaSA1)
RestArea(aArea)
Return lRet