#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � MT100LOK �Autor � Cristiam Rossi      � Data �  22/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA103 (Documento de Entrada) na validacao ���
���          � da linha para tratar parte customizada do XML Entrada.     ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function MT100LOK()
Local lRet := .T.
ConOut("M100LOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If isInCallStack("U_GETCHVNFE") // chamado pelo customiza��o de XML
	lRet := u_PEchvNFe("MT100LOK") // atualiza valor ICMS ST - Cristiam em 22/08/2016
EndIf
ConOut("M100LOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return lRet