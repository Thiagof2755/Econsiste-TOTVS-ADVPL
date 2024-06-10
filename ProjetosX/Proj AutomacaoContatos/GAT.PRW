User Function GAT()
	Local aArea    		:= GetArea()
	Local cNome 		:= " "
	Local cAlias 		:= GetNextAlias()
	Local oModel 		:= FWModelActive()
	Local oModelGrid 	:= oModel:GetModel('SU5CHILD')
	Local cCelular 	    := oModelGrid:GetValue('U5_CELULAR' )
	local aCols         := oModelGrid:aHeader
	local nCampos       := {}
	local nI            := 0
	Local cQuery         := ""
	local cValor

	cQuery += 'SELECT * FROM '+RetSqlName("SU5")+''
	cQuery += " WHERE U5_CELULAR = '"+cCelular+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

    
	MpSysOpenQuery(cQuery,cAlias)

    if ALLTRIM((cAlias)->(U5_CONTAT)) == ""
		oModel:SetValue("SU5CHILD","U5_CODCONT","")
	return cNome
	endif

		FOR nI := 1 TO Len(aCols)
			if aCols[nI,10] == 'R' .AND.  aCols[nI,8] != 'M'
				AAdd(nCampos,aCols[nI,2] )
			endif
		NEXT


		dbselectarea("SU5")
		IF !(Empty(nCampos))
			FOR nI := 1 TO Len(nCampos)
				cValor := ALLTRIM((cAlias)->&((nCampos[nI])))
				oModel:SetValue("SU5CHILD",(nCampos[nI]),cValor)
			NEXT
			SU5->(dbskip())
		ENDIF

		RestArea(aArea)

		cNome := ALLTRIM((cAlias)->(U5_CONTAT))


Return cNome

