#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � M020INC  �Autor� Antonio Carlos da Rosa� Data � 06/08/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA020 (Cadastro de Fornecedores) para     ���
���          � tratar a inclusao do item contabil (CTD).                  ���
���          � Usado tambem para gravar o fornecedor como bloqueado.      ���
�������������������������������������������������������������������������͹��
���Revisao   �                  Jonathan Schmidt Alves �Data � 16/08/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function M020INC(lBloq)
Local cItem := "F" + SA2->A2_COD + SA2->A2_LOJA // C=Cliente F=Fornecedor
Default lBloq := .F.
ConOut("MA020INC: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
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
CTD->CTD_DESC01 := AllTrim(SA2->A2_NREDUZ)
CTD->CTD_DTEXIS := CtoD("19800101")
CTD->CTD_BLOQ   := "2" // Nao Bloqueado
CTD->(MsUnlock())
RecLock("SA2",.F.)
If lBloq // .T.=Faz o bloqueio do fornecedor
	SA2->A2_MSBLQL := "1"
EndIf
If SA2->(FieldPos("A2_ITEMCTA")) > 0
	SA2->A2_ITEMCTA := cItem // Marco no fornecedor como gerado
EndIf
// SA2->A2_CONTA = "2100000"
SA2->(MsUnLock())
If lBloq .And. (Type("l020Auto") == "U" .Or. !l020Auto) .And. (Type("Inclui") == "U" .Or. Inclui) // Se nao for rotina automatica
	MsgAlert("Fornecedor ser� Bloqueado para an�lise do depto Fiscal!","M020INC")
EndIf
ConOut("MA020INC: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return