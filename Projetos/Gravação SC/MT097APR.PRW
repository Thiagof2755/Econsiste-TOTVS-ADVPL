#INCLUDE "TOTVS.CH"

//GRAVA��O APROVA��O DO PEDIDO DE COMPRA { CRIAR CAMPO CR_X_DTAPR E CR_X_HRAPR} E COMPILAR O FONTE 

User Function   MT097APR()
  local aAreaSCR := SCR->(GetArea())//GetArea(SCR)

  if SCR->CR_TIPO $ 'PC/IP'
      RecLock('SC1', .F.) //Bloqueia o registro
                SCR->CR_X_DTAPR := date() //Grava no campo data de aprova��o
                SCR->CR_X_HRAPR := time() // Grava no campo hora de aprova��o
            SCR->(MsUnlock()) //Libera o registro
  endif

  RestArea(aAreaSCR)//Restaura a area

Return

