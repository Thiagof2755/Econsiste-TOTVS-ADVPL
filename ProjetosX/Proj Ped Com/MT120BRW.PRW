#include 'Totvs.ch'


/*/{Protheus.doc} MT120BRW
    Fonte responsavel por pegar um arquivo Excel e 
	transformar em CSV para importação para o sistema Protheus
/*/
User Function MT120BRW()

	AAdd( aRotina, { 'Alterar Fornecedores', 'U_MODFOR', 0, 2 } )

Return

/*/{Protheus.doc} MODFOR
*/
User Function MODFOR()

	Local aPergs   := {}

	Local cForn  := Space(TamSX3("A2_COD")[01])
	Local Loja    := Space(TamSX3("A2_LOJA")[01])

	Local cPedComp := SC7->C7_NUM



	aAdd(aPergs, {1, "Fornecedor",  cForn,  "",             ".T.",        "SA2A", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Loja",  Loja,         "",             ".T.",            "", ".F.", 80,  .T.})

	if ParamBox(aPergs, "Os parâmetros são obrigatórios")
	else
		Return
	EndIf
	cFornecedor := MV_PAR01
	cLoja := MV_PAR02
	updForn(cPedComp,cFornecedor,cLoja)

Return


Static Function updForn(cPedComp,cFornecedor,cLoja)

	Local cQuery := FGetQuery(cPedComp)
	Local cAlias := GetNextAlias()


	MpSysOpenQuery(cQuery,cAlias)

	if (cAlias)->(C7_NUM) == ""
		MsgBox("Nenhum registro encontrado")
		Return
	EndIf

	While (cAlias)->(!EOF())
		dbselectarea("SC7")
		SC7->(dbgoto((cAlias)->(SC7RECNO)))
		IF (cAlias)->(VLD) == "X"
			MsgAlert("Pedido já foi entregue ou concluido com resíduo")
			Return	
		EndIf
		if (cAlias)->(C7_NUM) == cPedComp .AND. (cAlias)->(C7_QUJE) < (cAlias)->(C7_QUANT) .AND. Empty((cAlias)->(C7_RESIDUO))
			Reclock("SC7",.F.)
			SC7->C7_FORNECE := cFornecedor
			SC7->C7_LOJA := cLoja
			SC7->(MSuNLOCK())
		EndIf
		(cAlias)->(dbskip())
	End *

Return

/*/{Protheus.doc} FGetQuery
*/
Static Function FGetQuery(cPedComp)
    Local cQuery := ""
    cQuery := 'SELECT '
    cQuery += 		'C7_NUM, ' //codigo do pedido
    cQuery += 		'C7_LOJA, ' //loja
    cQuery += 		'C7_FORNECE, ' //fornecedor
	cQuery += 		'C7_FILIAL, ' //filial
	cQuery += 		'C7_QUANT, '	//quantidade do pedido
	cQuery += 		'C7_QUJE, ' 	//quantidade ja entregue
	cQuery += 		'C7_RESIDUO, ' //residuo S ou "" 
	cQuery += 		'C7_PRODUTO, ' //cod do produto
    cQuery += 		'R_E_C_N_O_ AS SC7RECNO, ' //recno
    cQuery +=      'CASE '
    cQuery +=          'WHEN EXISTS ('
    cQuery +=              'SELECT 1 '
    cQuery +=              'FROM ' + RetSqlName("SC7") + ' AS SC7_SUB '
    cQuery +=              'WHERE SC7_SUB.C7_NUM = SC7.C7_NUM '
    cQuery +=              'AND SC7_SUB.C7_FILIAL = SC7.C7_FILIAL '
	cQuery += 			   "AND (SC7_SUB.C7_QUJE >= SC7_SUB.C7_QUANT OR SC7_SUB.C7_RESIDUO = 'S' ) "
    cQuery +=          ") THEN 'X' "
    cQuery +=          "ELSE '' "
    cQuery +=      'END AS VLD '
    cQuery += 'FROM ' + RetSqlName("SC7") + ' AS SC7 '
    cQuery += "WHERE C7_NUM = '" + cPedComp + "' "
	cQuery  +=      "AND C7_FILIAL = '" + xFilial("SC7") + "' "

Return cQuery



