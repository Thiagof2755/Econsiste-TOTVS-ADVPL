#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � M410INIC �Autor  � Cristiam Rossi     � Data �  24/08/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. in�cio MATA410 - Pedido de Vendas                     ���
���          � *parte XML Sa�da - ECCO*                                   ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function M410INIC()
If IsInCallStack("U_GETCHVSNF")		// chamado pelo customiza��o de XML
	u_PEchvNFe("M410INIC")			// Carrega cabe�alho Pedido de Vendas - Cristiam em 24/08/2016
EndIf
Return