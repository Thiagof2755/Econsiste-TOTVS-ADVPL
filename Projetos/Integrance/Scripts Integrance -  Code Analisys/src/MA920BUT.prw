#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � MA920BUT �Autor � Douglas Telles       � Data � 28/09/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA920 (Nota Fiscal Saida Livros Fiscais)  ���
���          � para incluir um menu na tela de nota fiscal manual de      ���
���          � saida.                                                     ���
�������������������������������������������������������������������������͹��
���Revisao   �                 Jonathan Schmidt Alves � Data � 23/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function MA920BUT()
Local aRet := u_PEchvNFe("MA920BUT") 
Return aRet