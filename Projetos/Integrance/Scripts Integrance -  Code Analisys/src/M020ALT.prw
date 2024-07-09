#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � M020ALT  �Autor� Jonathan Schmidt Alves �Data� 19/09/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA020 (Cadastro de Fornecedores) para     ���
���          � tratar a inclusao/correcao do item contabil (CTD).         ���
�������������������������������������������������������������������������͹��
���Revisao   �                  Jonathan Schmidt Alves �Data � 16/08/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function M020ALT()
ConOut("MA020ALT: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
u_M020INC(.F.) // Chamada o P.E. de inclusao para incluir/alterar o Item Contabil (CTD)
ConOut("MA020ALT: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return