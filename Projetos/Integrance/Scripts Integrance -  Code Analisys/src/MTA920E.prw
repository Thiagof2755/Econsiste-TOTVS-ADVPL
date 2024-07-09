#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
���Programa  � MTA920E  �Autor � Frank Zwarg Fuga     � Data � 31/10/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA920 (Nota Fiscal Saida Livros Fiscais)  ���
���          � para tratar a exclusao do SFT e SF3.                       ���
�������������������������������������������������������������������������͹��
���Revisao   �                 Jonathan Schmidt Alves � Data � 23/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � INTEGRANCE                                                 ���
���������������������������������������������������������������������������*/

User Function MTA920E()
SFT->(DbSetOrder(1)) // FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
If SFT->(DbSeek(xFilial("SFT") + "S" + SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA))
	While SFT->(!EOF()) .And. SFT->FT_FILIAL + SFT->FT_TIPOMOV + SFT->FT_SERIE + SFT->FT_NFISCAL + SFT->FT_CLIEFOR + SFT->FT_LOJA == xFilial("SFT") + "S" + SF2->F2_SERIE + SF2->F2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA
		SFT->(RecLock("SFT",.F.))
		SFT->(DbDelete())
		SFT->(MsUnlock())
		SFT->(DbSkip())
	End
	SF3->(DbSetOrder(4)) // F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SERIE
	If SF3->(DbSeek(xFilial("SF3") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE))
		SF3->(RecLock("SF3"),.F.)
		SF3->(DbDelete())
		SF3->(MsUnlock())
	EndIf
EndIf
Return .T.