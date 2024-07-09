#INCLUDE "TOTVS.CH"

/*���������������������������������������������������������������������������
���Programa  � MT100TOK �Autor � Cristiam Rossi       � Data � 22/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. na rotina MATA103 (Documento de Entrada) para tratar  ���
���          � validacao geral conforme parte customizada XML Entrada.    ���
�������������������������������������������������������������������������͹��
���Revisao   �                Jonathan Schmidt Alves � Data �  30/05/2019 ���
�������������������������������������������������������������������������͹��
���Uso       � ITUP / ECCO                                                ���
���������������������������������������������������������������������������*/

User Function MT100TOK()
Local lRet := .T.
Local _cFilSA2 := xFilial("SA2")
Local _cFilSA1 := xFilial("SA1")
Local _cFilCTD := xFilial("CTD")
Local aArea := GetArea()
Local aAreaCTD := CTD->(GetArea())
local _cAliasTMP := iif(c103TP $ "D/B","SA1","SA2")
local _cFil := iif(c103TP $ "D/B",xFilial("SA1"),xFilial("SA2"))
local _cCampo := iif(c103TP $ "D/B","SA1->A1_ITEMCTA","SA2->A2_ITEMCTA")

ConOut("MT100TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If IsInCallStack("U_GETCHVNFE") // chamado pelo customiza��o de XML
	lRet := u_PEchvNFe("MT100LOK") // atualiza valor ICMS ST - Cristiam em 22/08/2016
EndIf
If lRet // Ainda valido (avaliar se o fornecedor esta conforme em relacao ao item contabil)
	DbSelectArea(_cAliasTMP)
	(_cAliasTMP)->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
    If (_cAliasTMP)->(DbSeek(_cFil + cA100For + cLoja))
    	If Empty(&_cCampo)
    	     MsgStop("Item Contabil do fornecedor/cliente nao esta preenchido (SA2)!" + Chr(13) + Chr(10) + ;
    	     "Sem o Item Contabil (CTD) a contabilizacao nao ocorrera corretamente!" + Chr(13) + Chr(10) + ;
    	     "Fornecedor/Cliente: " + cA100For + "/" + cLoja,"MT100TOK")
    	     lRet := .F.
    	Else // Validacao do Item Contabil (CTD)
    		DbSelectArea("CTD")
    		CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
    		If CTD->(DbSeek(_cFilCTD + &_cCampo))
		    	If Len(AllTrim(&_cCampo)) <> 9
			   	     MsgStop("Item Contabil do fornecedor/cliente nao esta consistente (SA2)!" + Chr(13) + Chr(10) + ;
		    	     "Sem o Item Contabil consistente (CTD) a contabilizacao nao ocorrera corretamente!" + Chr(13) + Chr(10) + ;
		    	     "Fornecedor/Cliente: " + cA100For + "/" + cLoja + Chr(13) + Chr(10) + ;
		    	     "Item Contabil: " + &_cCampo,"MT100TOK")
		    	     lRet := .F.
		    	ElseIf CTD->CTD_BLOQ == "1" // Item Contabil Bloqueado no cadastro
			   	     MsgStop("Item Contabil do fornecedor/cliente esta bloqueado (CTD)!" + Chr(13) + Chr(10) + ;
		    	     "Sem o Item Contabil consistente (CTD) a contabilizacao nao ocorrera corretamente!" + Chr(13) + Chr(10) + ;
		    	     "Fornecedor/Cliente: " + cA100For + "/" + cLoja + Chr(13) + Chr(10) + ;
		    	     "Item Contabil: " + &_cCampo,"MT100TOK")
		    	     lRet := .F.		    		
		    	EndIf
		    Else // CTD nao encontrado
		   	     MsgStop("Item Contabil do fornecedor/cliente nao encontrado no cadastro (CTD)!" + Chr(13) + Chr(10) + ;
	    	     "Sem o Item Contabil consistente (CTD) a contabilizacao nao ocorrera corretamente!" + Chr(13) + Chr(10) + ;
	    	     "Fornecedor/Cliente: " + cA100For + "/" + cLoja + Chr(13) + Chr(10) + ;
	    	     "Item Contabil: " + &_cCampo,"MT100TOK")
	    	     lRet := .F.
		    EndIf
    	EndIf
    EndIf
EndIf
RestArea(aAreaCTD)
RestArea(aArea)
ConOut("MT100TOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return lRet
