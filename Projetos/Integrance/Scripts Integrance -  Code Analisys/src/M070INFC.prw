#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � M070INFC �Autor � Cristiam Rossi         � Data � 27/12/16 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. Final da grava��o do Banco - SA6                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ECCO / ITUP                                                ���
���������������������������������������������������������������������������*/

User Function M070INFC()
Local aArea	:= GetArea()
u_AddItCtb("B" + SA6->A6_COD, SA6->A6_NOME, "1" /*Receita*/)
RestArea(aArea)
Return