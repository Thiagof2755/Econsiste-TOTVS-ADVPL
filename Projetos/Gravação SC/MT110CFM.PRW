/*/{Protheus.doc} MT110CFM
User Function MT110CFM()Local ExpC1  := PARAMIXB[1]     Local ExpN1  := PARAMIXB[2]       // Validações do UsuárioReturn Nil
GRAVAÇÃO APROVAÇÃO DE SOLICITAÇÃO COMPLETA
/*/
User Function MT110CFM()
	Local aAreaSC1 := SC1->(GETAREA())
    Local cNunSC  := PARAMIXB[1]
    Local nOpcao  := PARAMIXB[2]

    if nOpcao == 1 //Aprovação
        pergunte("MTA110",.F.)
        lItem := mv_par02 == 1 
        
        if lItem
            RecLock('SC1', .F.)
                SC1->C1_X_DTAPR := date()
                SC1->C1_X_HRAPR := time()
            SC1->(MsUnlock())
        else
            dbselectarea("SC1")
            dbsetorder(1)
            dbseek(xFilial("SC1")+cNunSC)
            while SC1->(!Eof()) .AND. SC1->(C1_FILIAL + C1_NUM) == xFilial("SC1")+cNunSC
                RecLock('SC1', .F.)
                    SC1->C1_X_DTAPR := date()
                    SC1->C1_X_HRAPR := time()
                SC1->(MsUnlock())
                SC1->(dbskip())
            end 
        endif
    EndIf

    restarea(aAreaSC1)
Return
