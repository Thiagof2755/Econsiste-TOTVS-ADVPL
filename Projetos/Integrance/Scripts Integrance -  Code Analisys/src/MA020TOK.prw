#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � MA020TOK �Autor � Jonathan Schmidt Alves �Data� 20/02/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA020 (Cadastro de Fornecedores) para     ���
���          � tratar a inclusao de itens contabeis na validacao do       ���
���          � fornecedor. Usado este ponto para inclusao de fornecedores ���
���          � em consultas padroes onde o P.E. MA020INC nao esta sendo   ���
���          � chamado.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function MA020TOK()
Local lRet := .T.
Local cItem := "F" + M->A2_COD + M->A2_LOJA // C=Cliente F=Fornecedor
Local aArea := GetArea()
Local aAreaSA2 := SA2->(GetArea())
ConOut("MA020TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If !("MATA020" $ FunName()) .And. Inclui // Inclusao de fornecedor nao passando pela MATA020 (consulta padrao, etc)
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
	CTD->CTD_NORMAL := "2" // 1=Receita 2=Despesa
	CTD->CTD_DESC01 := AllTrim(M->A2_NREDUZ)
	CTD->CTD_DTEXIS := CtoD("19800101")
	CTD->CTD_BLOQ   := "2" // Nao Bloqueado
	CTD->(MsUnlock())
	// Atualizacao do Item Contabil no SA2
	M->A2_ITEMCTA := CTD->CTD_ITEM
EndIf
ConOut("MA020TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
RestArea(aAreaSA2)
RestArea(aArea)
Return lRet