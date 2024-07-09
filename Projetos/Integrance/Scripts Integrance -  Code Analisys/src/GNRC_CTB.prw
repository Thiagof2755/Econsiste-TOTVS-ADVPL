#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SA1TOCTD ºAutor ³Jonathan Schmidt Alvesº Data ³ 16/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de reprocessamento seguro do CTD conforme cliente.  º±±
±±º          ³ O objetivo eh manter integro o CTD (Itens Contabeis) que   º±±
±±º          ³ sao criados conforme criacao de Clientes (SA1) fazendo a   º±±
±±º          ³ contabilizacao automatica.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SA1TOCTD()
Local nRecs := 0
Local cRecs := ""
Local cQry := ""
Local _cFilSA1 := xFilial("SA1")
Local nLastUpdate := Seconds()
DbSelectArea("SA1")
//ConOut("SA1TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("SA1TOCTD" , "Iniciando...")
SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
cQry := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, R_E_C_N_O_ "
cQry += "FROM " + RetSqlName("SA1") + " WHERE "
cQry += "A1_FILIAL = '" + _cFilSA1 + "' AND "
If SA1->(FieldPos("A1_ITEMCTA")) > 0
	cQry += "A1_ITEMCTA = '" + Space(09) + "' AND "		// Item contabil nao gerado
EndIf
cQry += "D_E_L_E_T_ = ' ' "
cQry += "ORDER BY A1_COD + A1_LOJA "
cQry := ChangeQuery(cQry)
If Select("TRBSA1") > 0
	TRBSA1->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSA1",.T.,.T.)
Count To nRecs
cRecs := cValToChar(nRecs)
If nRecs > 0
	//ConOut("SA1TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Registros para atualizacao SA1: " + cRecs)
	U_LogAlteracoes("SA1TOCTD" , "Registros para atualizacao SA1: " + cRecs)
	_oMeter:nTotal := nRecs
	TRBSA1->(DbGotop())
	While TRBSA1->(!EOF())
		SA1->(DbGoto(TRBSA1->R_E_C_N_O_))
		u_M030INC() // P.E. para criacao do CTD Clientes
		++nCurrent
		If (Seconds() - nLastUpdate) > 1 // Se passou 1 segundo
			u_AtuAsk09(nCurrent,"Contabilidade","Atualizando Item Contabil...","Atualizando clientes... " + cValToChar(nCurrent) + " / " + cRecs,"",30)
			nLastUpdate := Seconds()
		EndIf
		TRBSA1->(DbSkip())
	End
EndIf
TRBSA1->(DbCloseArea())
//ConOut("SA1TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("SA1TOCTD" , "Concluido!")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SA2TOCTD ºAutor ³Jonathan Schmidt Alvesº Data ³ 16/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de reprocessamento seguro do CTD conforme fornece.  º±±
±±º          ³ O objetivo eh manter integro o CTD (Itens Contabeis) que   º±±
±±º          ³ sao criados conforme criacao de Fornecedores (SA2) fazendo º±±
±±º          ³ a contabilizacao automatica.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRANCE                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SA2TOCTD()
Local nRecs := 0
Local cRecs := ""
Local cQry := ""
Local _cFilSA2 := xFilial("SA2")
Local nLastUpdate := Seconds()
//ConOut("SA2TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
U_LogAlteracoes("SA2TOCTD" , "Iniciando...")
DbSelectArea("SA2")
SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD
cQry := "SELECT A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, R_E_C_N_O_ "
cQry += "FROM " + RetSqlName("SA2") + " WHERE "
cQry += "A2_FILIAL = '" + _cFilSA2 + "' AND "
If SA2->(FieldPos("A2_ITEMCTA")) > 0
	cQry += "A2_ITEMCTA = '" + Space(09) + "' AND "		// Item contabil nao gerado
EndIf
cQry += "D_E_L_E_T_ = ' ' "
cQry += "ORDER BY A2_COD + A2_LOJA "
cQry := ChangeQuery(cQry)
If Select("TRBSA2") > 0
	TRBSA2->(DbCloseArea())
EndIf
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSA2",.T.,.T.)
Count To nRecs
If nRecs > 0
	cRecs := cValToChar(nRecs)
	//ConOut("SA2TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Registros para atualizacao SA2: " + cRecs)
	U_LogAlteracoes("SA2TOCTD" , "Registros para atualizacao SA2: " + cRecs)
	_oMeter:nTotal := nRecs
	TRBSA2->(DbGotop())
	While TRBSA2->(!EOF())
		SA2->(DbGoto(TRBSA2->R_E_C_N_O_))
		u_M020INC(.F.) // P.E. para criacao do CTD Fornecedores
		++nCurrent
		If (Seconds() - nLastUpdate) > 1 // Se passou 1 segundo
			u_AtuAsk09(nCurrent,"Contabilidade","Atualizando Item Contabil...","Atualizando fornecedores... " + cValToChar(nCurrent) + " / " + cRecs,"",30)
			nLastUpdate := Seconds()
		EndIf
		TRBSA2->(DbSkip())
	End
EndIf
TRBSA2->(DbCloseArea())
//ConOut("SA2TOCTD: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
U_LogAlteracoes("SA2TOCTD" , "Concluido!")
Return
