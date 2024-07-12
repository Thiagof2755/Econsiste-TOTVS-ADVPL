#INCLUDE "PROTHEUS.CH"

/*/
@description: Fun��es para corre��o de erros code analysis
@author T�lio Henrique 
@since 28/05/2024
/*/
User Function LogAlteracoes(cFunc,cStatus)

local cinfolog := cFunc + ": " + DtoC(Date()) + " " + Time() + " " + cUserName + " " + cStatus

FWLogMsg(;
        "INFO",;    //cSeverity      - Informe a severidade da mensagem de log. As op��es poss�veis s�o: INFO, WARN, ERROR, FATAL, DEBUG
        ,;          //cTransactionId - Informe o Id de identifica��o da transa��o para opera��es correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        "logCargaSD1",;//cGroup         - Informe o Id do agrupador de mensagem de Log
        ,;          //cCategory      - Informe o Id da categoria da mensagem
        ,;          //cStep          - Informe o Id do passo da mensagem
        ,;          //cMsgId         - Informe o Id do c�digo da mensagem
        cinfolog,;  //cMessage       - Informe a mensagem de log. Limitada � 10K
        ,;          //nMensure       - Informe a uma unidade de medida da mensagem
        ,;          //nElapseTime    - Informe o tempo decorrido da transa��o
        ;           //aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} }
    ) 

return 


User Function ztipo(cCampo)
Return Type(cCampo)

User Function zGetmv(cCampo)
Return GetMv(cCampo)

User Function zSuperGet(cCampo,bCampo,aCampo)
Return SuperGetMv(cCampo,bCampo,aCampo)

