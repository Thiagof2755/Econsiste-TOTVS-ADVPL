#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � MT103NFE �Autor � Cristiam Rossi       � Data � 29/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA103 (Documento de Entrada) no momento   ���
���          � do acesso a uma das opcoes da NFE (2=Visualiza/ 3=Incluir/ ���
���          � 4=Classificar/ 5=Excluir) chamando processamento da parte  ���
���          � customizada do XML Entrada.                                ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function MT103NFE()
ConOut("MT103NFE: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If IsInCallStack("U_GETCHVNFE") // chamado pelo customiza��o de XML
	u_PEchvNFe("MT103NFE") // Carrega cabe�alho Documento de Entrada - Cristiam em 09/08/2016
EndIf
ConOut("MT103NFE: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return