#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/**************************************************************************************************
{Protheus.doc} MCOM006
@description	rotina para selecao dos titulos do xml e mostrar os itens 
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		10/07/2023
**************************************************************************************************/
user function MCOM007()

    local cAlias := GetNextAlias()

    if !isBlind()
        if !msgYesNo('Deseja importar todos os fornecedores?')
            return .F.
        endIf
    endIf
	  
    beginSql Alias cAlias

        SELECT 
                CKO_FILIAL
            ,	CKO_ARQUIV
            ,	CKO_STATUS
            ,	CKO.R_E_C_N_O_ CKORECNO
        FROM 
            %Table:CKO% CKO
        WHERE 
                CKO.%NotDel% 
            AND CKO.CKO_FILIAL = %xFilial:CKO%
            AND CKO.CKO_STATUS <> '1'
            AND CKO.CKO_CODERR = 'COM007'
            AND CKO.CKO_EMPPRO = %exp:cEmpAnt% 
            AND CKO.CKO_FILPRO = %exp:cFilAnt% 
    endSql	

    while !(cAlias)->(Eof())	

        conout('MCOM007 - Iniciando processamento do  arquivo: ' + (cAlias)->CKO_ARQUIV )
        u_MCOM006( (cAlias)->CKO_ARQUIV , .F. )
        conout('MCOM007 - Finalizado processamento do  arquivo: ' + (cAlias)->CKO_ARQUIV )

        (cAlias)->( dbSkip() )
    endDo

    (cAlias)->( dbCloseArea() )

    if !isBlind()
        Aviso('Atenção','Rotina processada com sucesso, utilize a rotina de reprocessar para enviar o xml para processamento.',{"OK"}) 
    endIf

return .T.
