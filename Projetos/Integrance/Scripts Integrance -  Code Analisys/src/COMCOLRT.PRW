#include 'totvs.ch'

/**************************************************************************************************
{Protheus.doc} COMCOLRT
@description	Ponto de entrada para inclusão da opção no menu do COMXCOL
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		13/05/2023
**************************************************************************************************/
user function COMCOLRT()

    local aRot := Paramixb[1]

    aAdd(aRot,{"Ajustar Importação" ,"u_MCOM003()",0,3,0,.F.})
    
return aRot
