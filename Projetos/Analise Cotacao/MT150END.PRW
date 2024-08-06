#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT150GRV
(long_description)
@type user function
@author user
@since 05/08/2024
@version version
(examples)
@see (links_or_references)
/*/
User Function MT150END()
Local nOp := PARAMIXB[1]

    if nOp <> 5 // alterar
        (cAliasTSC8)->(DbGoTop())
        While !(cAliasTSC8)->(EOF())
        dbseek((cAliasTSC8)->C8_FILIAL+(cAliasTSC8)->C8_NUM+(cAliasTSC8)->C8_FORNECE+(cAliasTSC8)->C8_LOJA+(cAliasTSC8)->C8_ITEM+(cAliasTSC8)->C8_NUMPRO+(cAliasTSC8)->C8_ITEMGRD)
                RecLock('SC8', .F.)
                    SC8->C8_X_FPGTO := cTIPO
                SC8->(MsUnlock())
				(cAliasTSC8)->(dbskip())
			End *
    endif
Return 
