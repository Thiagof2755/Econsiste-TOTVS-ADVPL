#INCLUDE "TOTVS.CH"

User Function   MT097APR()
  local aAreaSCR := SCR->(GetArea())

  if SCR->CR_TIPO $ 'PC/IP'
      RecLock('SC1', .F.)
                SCR->CR_X_DTAPR := date()
                SCR->CR_X_HRAPR := time()
            SCR->(MsUnlock())
  endif

  RestArea(aAreaSCR)

Return
