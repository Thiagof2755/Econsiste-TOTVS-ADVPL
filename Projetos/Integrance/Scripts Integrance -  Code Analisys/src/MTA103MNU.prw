#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � MTA103MNU �Autor � Cristiam Rossi     � Data �  29/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA103 (Documento de Entrada) para tratar  ���
���          � inclusao de rotina espec�fica no menu Acoes Relacionadas.  ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function MTA103MNU()
ConOut("MTA130MNU: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
u_PEchvNFe("MTA103MNU") // adi��o rotinas Import. XML e Lote XML - Cristiam Em 09/08/2016
ConOut("MTA130MNU: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return