#include "TOTVS.CH"

/*/{Protheus.doc} RTPERC
********************RTPERC************************
/*/
User Function RTPERC()

	Private cPerg 	 := "RTPERC"

	Pergunte(cPerg,.T.) // SE TRUE ELE CHAMA A PERGUNTA ASSIM QUE O RELATÓRIO É ACIONADO

	IF Empty(MV_PAR02)
		MV_PAR02 := 'zzzzzz'
	ENDIF

	cVendde := MV_PAR01
	cVendAte := MV_PAR02
	cDtDe := (DTOS(MV_PAR03))
	cDtAte := (DTOS(MV_PAR04))


	BusVen( cVendde, cVendAte, cDtDe, cDtAte )

Return


/*/{Protheus.doc} BusVen
/*/

Static Function BusVen(cVendde,cVendAte,cDtDe,cDtAte)


	Local cQuery := FGetQuery(cVendde,cVendAte,cDtDe,cDtAte)
	Local cAlias := GetNextAlias()

	MpSysOpenQuery(cQuery,cAlias)

	While (cAlias)->(! Eof())

		fAtuComis(cDtDe,cDtAte,(cAlias)->(Z8_CODVEN),(cAlias)->(Z8_PERC))
		(cAlias)->(DbSkip())
	EndDo

Return

/*/{Protheus.doc} fAtuComis
/*/

Static Function fAtuComis(dIni,dFim,cVend,cNewPerc)

	Local cQuery := FGetResult(dIni,dFim,cVend)
	Local cAlias := GetNextAlias()

	MpSysOpenQuery(cQuery,cAlias)


	While (cAlias)->(!EOF())
		dbselectarea("SD2")
		SD2->(dbgoto((cAlias)->(SD2RECNO)))
		Reclock("SD2",.F.)
		if (cAlias)->(F2_VEND1) == cVend
			SD2->D2_COMIS1 := cNewPerc
		elseif (cAlias)->(F2_VEND2) == cVend
			SD2->D2_COMIS2 := cNewPerc
		elseif (cAlias)->(F2_VEND3) == cVend
			SD2->D2_COMIS3 := cNewPerc
		elseif (cAlias)->(F2_VEND4) == cVend
			SD2->D2_COMIS4 := cNewPerc
		elseif (cAlias)->(F2_VEND5) == cVend
			SD2->D2_COMIS5 := cNewPerc
		endif
		SD2->(MSuNLOCK())
		(cAlias)->(dbskip())
	End *

Return




/*/{Protheus.doc} FGetQuery

*/
Static Function FGetQuery(cVendde,cVendAte,cDtDe,cDtAte)
    Local cQuery := ""
    cQuery := 'SELECT '
    cQuery += 		'TOTAL_VALBRUT, '
    cQuery += 		'Z8_PERC, '
    cQuery += 		'Z8_CODVEN, '
    cQuery += 		'F4_DUPLIC '
    cQuery += 'FROM ( '
    cQuery += 			'SELECT '
    cQuery += 				'SUM(SD2.D2_VALBRUT) AS TOTAL_VALBRUT, '
    cQuery += 				'SZ8.Z8_PERC, '
    cQuery += 				'SZ8.Z8_CINI, '
    cQuery += 				'SZ8.Z8_CFIM, '
    cQuery += 				'SZ8.Z8_CODVEN, '
    cQuery += 				'SF4.F4_DUPLIC '
    cQuery += 			'FROM '+RetSqlName("SZ9")+' SZ9 '
    cQuery +=               "INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = '0201' "
    cQuery +=                       'AND SZ9.D_E_L_E_T_ = SF2.D_E_L_E_T_ '
    cQuery +=                       'AND (SZ9.Z9_CODVEN = SF2.F2_VEND1 '
    cQuery +=                       'OR SZ9.Z9_CODVEN = SF2.F2_VEND2 '
    cQuery +=                       'OR SZ9.Z9_CODVEN = SF2.F2_VEND3 '
    cQuery +=                       'OR SZ9.Z9_CODVEN = SF2.F2_VEND4 '
    cQuery +=                       'OR SZ9.Z9_CODVEN = SF2.F2_VEND5 ) '
    cQuery +=                       "AND SF2.F2_EMISSAO BETWEEN '"+ cDtDe +"' AND '"+ cDtAte +" '
    cQuery +=                "INNER JOIN "+RetSqlName("SZ8")+" SZ8 ON SZ9.Z9_CODVEN = SZ8.Z8_CODVEN "
    cQuery +=                       'AND SZ8.Z8_FILIAL = SZ9.Z9_FILIAL '
    cQuery +=                       'AND SZ9.D_E_L_E_T_ = SZ8.D_E_L_E_T_ '
    cQuery +=                       'AND SZ8.Z8_CODVEN = SZ9.Z9_CODVEN '
    cQuery +=                "INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
    cQuery +=                       'AND SD2.D2_DOC = SF2.F2_DOC '
    cQuery +=                       'AND SD2.D2_SERIE = SF2.F2_SERIE '
    cQuery +=                       'AND SD2.D2_CLIENTE = SF2.F2_CLIENTE '
    cQuery +=                       'AND SD2.D2_LOJA = SF2.F2_LOJA '
    cQuery +=                       'AND SD2.D_E_L_E_T_ = SF2.D_E_L_E_T_ '
    cQuery +=                "INNER JOIN "+RetSqlName("SF4")+" SF4 ON SD2.D2_TES = SF4.F4_CODIGO "
    cQuery +=                       'AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_ '
    cQuery +=                       "AND SF4.F4_DUPLIC = 'S' "
    cQuery +=                       "AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
    cQuery +=                 "WHERE SZ9.D_E_L_E_T_ = ' ' "
    cQuery +=                 "AND SZ9.Z9_CODVEN BETWEEN '"+ cVendde +"' and '"+cVendAte +"' "
    cQuery +=                 "AND SZ9.Z9_FILIAL = '"+xFilial("SZ9")+"' "
    cQuery +=           'GROUP BY '
    cQuery +=            'SZ8.Z8_PERC, '
    cQuery +=            'SZ8.Z8_CINI, '
    cQuery +=            'SZ8.Z8_CFIM, '
    cQuery +=            'SZ8.Z8_CODVEN, ' 
    cQuery +=            'SF4.F4_DUPLIC '
    cQuery +=            ') '
    cQuery +=                   'AS Subquery '
    cQuery +=            'WHERE TOTAL_VALBRUT BETWEEN Z8_CINI AND Z8_CFIM '



Return cQuery



/*/{Protheus.doc} FGetResult

*/
Static Function FGetResult( dIni,dFim,cVend )
	Local cQuery := ""
	cQuery  := 'SELECT '
    cQuery  +=      'SD2.R_E_C_N_O_ AS SD2RECNO, '
    cQuery  +=      'SF2.F2_VEND1, '
    cQuery  +=      'SF2.F2_VEND2, '
    cQuery  +=      'SF2.F2_VEND3, '
    cQuery  +=      'SF2.F2_VEND4, '
    cQuery  +=      'SF2.F2_VEND5, '
    cQuery  +=      'SD2.D2_COMIS1, '
    cQuery  +=      'SD2.D2_COMIS2, '
    cQuery  +=      'SD2.D2_COMIS3, '
    cQuery  +=      'SD2.D2_COMIS4, '
    cQuery  +=      'SD2.D2_COMIS5 '
    cQuery  += 'FROM '+RetSqlName("SF2")+' SF2 '
    cQuery  += 'INNER JOIN '+RetSqlName("SD2")+' SD2 ON ( '
    cQuery  +=      "SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
    cQuery  +=          'AND SD2.D2_DOC = SF2.F2_DOC '
    cQuery  +=          'AND SD2.D2_SERIE = SF2.F2_SERIE '
    cQuery  +=          'AND SD2.D2_CLIENTE = SF2.F2_CLIENTE '
    cQuery  +=          'AND SD2.D2_LOJA = SF2.F2_LOJA '
    cQuery  +=          'AND SD2.D_E_L_E_T_ = SF2.D_E_L_E_T_ '
    cQuery  +=          ')'
    cQuery  += 		'INNER JOIN '+RetSqlName("SF4")+' SF4 ON ( '
	cQuery  +=			 'SD2.D2_TES = SF4.F4_CODIGO '
	cQuery  +=			 'AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_ '
	cQuery  +=			 "AND SF4.F4_DUPLIC = 'S' "
    cQuery  +=           "AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "
	cQuery  +=			') '
    cQuery  += 'WHERE '
    cQuery  +=      "SD2.D_E_L_E_T_ = ''  "
    cQuery  +=      "AND SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
    cQuery  +=      "AND SD2.D2_EMISSAO BETWEEN '"+ dIni +"' AND '"+ dFim +"' "
    cQuery  +=      "AND ( SF2.F2_VEND1 = '"+ cVend +"' OR "
    cQuery  +=          "SF2.F2_VEND2 = '"+cVend+"' OR "
    cQuery  +=          "SF2.F2_VEND3 = '"+cVend+"' OR "
    cQuery  +=          "SF2.F2_VEND4 = '"+cVend+"' OR "
    cQuery  +=          "SF2.F2_VEND5 = '"+cVend+"' ) "

Return cQuery

