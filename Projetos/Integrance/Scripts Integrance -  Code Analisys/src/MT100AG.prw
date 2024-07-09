#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � MT100AG  �Autor � Cristiam Rossi       � Data � 26/10/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA103 (Documento de Entrada) no final das ���
���          � gravacoes para tratar parte customizada do XML Entrada.    ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function MT100AG()
Local lRet := .T.
If IsInCallStack("U_GETCHVNFE") // chamado pelo customiza��o de XML
	lRet := u_PEchvNFe("MT100AG") // criar rela��o Produto X Fornecedror
EndIf
Return lRet