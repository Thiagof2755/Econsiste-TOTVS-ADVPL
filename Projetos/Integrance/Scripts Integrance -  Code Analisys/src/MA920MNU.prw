#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � MA920MNU �Autor � Frank Zwarg Fuga     � Data � 09/10/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA920 (Nota Fiscal Saida Livros Fiscais)  ���
���          � para incluir o menu da importa��o do xml na nota fiscal    ���
���          � de saida manual.                                           ���
�������������������������������������������������������������������������͹��
���Revisao   �                 Jonathan Schmidt Alves � Data � 23/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function MA920MNU()
aAdd(aRotina, { "Importa��o XML"		,"u_GETCHVSNF",	0, 3, 0, Nil })
aAdd(aRotina, { "Importa��o Lote XML"	,"u_GETLOTNF",	0, 3, 0, Nil })
Return