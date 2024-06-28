#Include "protheus.ch"

User Function TRIM(Valor)

    Local cValor := Valor
    Local oModel          := FWModelActive()
    Local oView 		  := FwViewActive()
    Local oModelGrid      := oModel:GetModel('CT1MASTER')

    if EMPTY(SUBSTR(M->CT1_CONTA,1,1))         
    oModelGrid:SetValue("CT1_CONTA",AllTrim(cValor) )
    oView:Refresh()
    ENDIF

Return .T.
