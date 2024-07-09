#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � MALTCLI  �Autor� Jonathan Schmidt Alves �Data� 19/09/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA030 (Cadastro de Clientes) para         ���
���          � tratar a inclusao/correcao do item contabil (CTD).         ���
�������������������������������������������������������������������������͹��
���Revisao   �                  Jonathan Schmidt Alves �Data � 16/08/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function MALTCLI()
ConOut("MALTCLI: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
u_M030INC(.F.) // Chamada o P.E. de inclusao para incluir/alterar o Item Contabil (CTD)
ConOut("MALTCLI: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return