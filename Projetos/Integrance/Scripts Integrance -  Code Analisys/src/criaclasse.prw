#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} criaclass
    (long_description)
    @type  Function
    @author user
    @since 06/02/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function criaclass()
    DbSelectArea("SA2")
    DbSetOrder(1)
    DBSEEK(xFilial("SA2"))
    WHILE SA2->(!EOF()) .AND. AllTrim(SA2->A2_FILIAL) == '17'
        u_M020INC()
        SA2->(dbskip())
    END
Return 
