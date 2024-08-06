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
LOCAL cCampo     := PadR("C8_X_FPGTO", 10)
Local Compara 	 := X3CboxToArray(cCampo)
Local NI         := NIL

    if nOp <> 5 // alterar

        For NI := 1 To Len(Compara[1])
            if Compara[2][NI] = ALLTRIM(cTIPO)
                RecLock('SC8', .F.)
                    SC8->C8_X_FPGTO := Compara[2][NI]
                SC8->(MsUnlock())
            EndIF
        Next
    endif
Return 
