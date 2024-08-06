#Include "TOTVS.ch"
#include "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RESTFUL
API REST Protheus Pedidos em Aberto
API utilizada para efetuar a consulta de Pedidos em Aberto
@author Thiago Alves
@since 28/06/2024

	######## ##     ## ####    ###     ######    #######
		##    ##     ##  ##    ## ##   ##    ##  ##     ##
		##    ##     ##  ##   ##   ##  ##        ##     ##
		##    #########  ##  ##     ## ##   #### ##     ##
		##    ##     ##  ##  ######### ##    ##  ##     ##
		##    ##     ##  ##  ##     ## ##    ##  ##     ##
		##    ##     ## #### ##     ##  ######    #######

/*/
//-------------------------------------------------------------------

WSRESTFUL REESTPED DESCRIPTION "API REST Protheus Pedidos em Aberto" FORMAT APPLICATION_JSON


	WSDATA vendedorDe AS CHARACTER OPTIONAL
	WSDATA vendedorate AS CHARACTER OPTIONAL
	WSDATA dataDe AS CHARACTER OPTIONAL
	WSDATA dataAte AS CHARACTER OPTIONAL
	WSDATA filial AS CHARACTER OPTIONAL
	WSDATA pedidoDe AS CHARACTER OPTIONAL
	WSDATA pedidoAte AS CHARACTER OPTIONAL
	WSDATA usuario AS CHARACTER

	WSMETHOD GET ConsultarPedidos;
	DESCRIPTION "API utilizada para efetuar a consulta de Pedidos em Aberto";
	WSSYNTAX "/consultar/Pedidos/?vendedorDe={vendedorDe}&vendedorate={vendedorate}&dataDe={dataDe}&dataAte={dataAte}&filial={filial}&pedidoDe={pedidoDe}&pedidoAte={pedidoAte}&usuario={usuario}";
	PATH "/consultar/Pedidos/";
	TTALK "ConsultarPedidos";
	PRODUCES APPLICATION_JSON;

END WSRESTFUL


WSMETHOD GET ConsultarPedidos HEADERPARAM vendedorDe, vendedorate, dataDe, dataAte WSSERVICE REESTPED
// Define "ValueRef" como um parâmetro de cabeçalho para o método GET "ConsultarPedidos"
// Indica que este método é parte do serviço "REESTPED"

//http://192.168.55.235:8996/rest/REESTPED/consultar/Pedidos?vendedorDe=000000&vendedorate=zzzzzz&dataDe=2000-01-01&dataAte=2024-07-04

	Local oResponse		:=	Nil
	Local oJson := JsonObject():New()
	Local cQueryCab 
	Local cAliasCab		:=	"TMPCAB"
	Local cAliasProd	:=	"TMPITE"
	Local aResponse		:=	{}
    Local filial        := self:filial 
	Local cQueryProd    := ''
	Local oPedido       := nil
	Local oProduto      := nil


	oJson:FromJson(filial)
	filial := oJson['Code']
	cQueryCab     :=  FGetQueryCabecalho( self:vendedorDe, self:vendedorate, self:dataDe, self:dataAte, filial , self:pedidoDe, self:pedidoAte, self:usuario)

	MpSysOpenQuery(cQueryCab, cAliasCab)



	(cAliasCab)->(DbGoTop())


	IF (cAliasCab)->(EOF())
		(cAliasCab)->(DbcloseArea())
		oResponse := JsonObject():New()
		oResponse["ConsultarPedidos"]	:= {}
		self:SetResponse( oResponse:ToJson() )
		FreeObj( oResponse )
		oResponse := Nil
		Return( .T. )
	ELSE
		While !(cAliasCab)->(EOF())
			oPedido := JsonObject():New()
			oPedido["numero"] := ALLTRIM((cAliasCab)->C5_NUM)
			oPedido["cliente"] := ALLTRIM((cAliasCab)->A1_NOME)
			oPedido["cnpj"] := (cAliasCab)->A1_CGC
			oPedido["endereco"] := ALLTRIM((cAliasCab)->A1_ENDREC)
			oPedido["cidade"] := (ALLTRIM((cAliasCab)->A1_ESTADO) + ' - ' + ALLTRIM((cAliasCab)->A1_MUN))
			oPedido["email"] := ALLTRIM((cAliasCab)->A1_EMAIL)
			oPedido["prazoEntrega"] := ALLTRIM((cAliasCab)->C6_ENTREG)
			oPedido["obs"] := (ALLTRIM((cAliasCab)->C5_OBS)) 
			oPedido["prazoPagamento"] := ALLTRIM((cAliasCab)->prazoPagamento)
			oPedido["produtos"] := {}
			oPedido["totalPedido"] := ((cAliasCab)->VALOR_TOTAL_POR_PEDIDO)

			cQueryProd := FGetQueryProd(ALLTRIM((cAliasCab)->C5_NUM))
			MpSysOpenQuery(cQueryProd, cAliasProd)
			While !(cAliasProd)->(EOF())
				// Cria um novo objeto JSON para o produto a cada iteração
				oProduto := JsonObject():New()
				oProduto["caixas"] := (cAliasProd)->CAIXAS // Assumindo 1 unidade por caixa
				oProduto["descricao"] := ALLTRIM((cAliasProd)->B1_DESC)
				oProduto["precoUnitario"] := (cAliasProd)->PRECO_UNITARIO
				oProduto["precoCaixa"] := (cAliasProd)->VALOR_POR_CAIXA // Assumindo 12 unidades por caixa
				oProduto["total"] := (cAliasProd)->VALOR_TOTAL_POR_ITEM

				// Adiciona o produto ao array de produtos do pedido
				AAdd(oPedido["produtos"], oProduto)

				(cAliasProd)->(dbskip())
			End *

			aadd(aResponse,oPedido)
			(cAliasCab)->(dbskip())
		End *
		oResponse := JsonObject():New()
		oResponse["ConsultarPedidos"]	:= aResponse
		self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
	ENDIF

	FreeObj( oResponse )
	oResponse := Nil

Return( .T. )


Static Function FGetQueryCabecalho( vendedorDe, vendedorate, dataDe, dataAte , filial , pedidoDe, pedidoAte,usuario )

	Local cQuery := ""


	cQuery += "SELECT * FROM ( "
	cQuery += "SELECT "
	cQuery += "    SC5.C5_NUM, " 
	cQuery += "          SUBSTR(SC5.C5_USERLGA, 11, 1) || "
	cQuery += "			 SUBSTR(SC5.C5_USERLGA, 15, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 19, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 2, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 6, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 10, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 14, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 1, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 18, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 5, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 9, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 13, 1) || "
    cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 17, 1) || "
	cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 4, 1) || "
	cQuery += "     	 SUBSTR(SC5.C5_USERLGA, 8, 1) "
	cQuery += "    AS C5_USERALT, "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 11, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 15, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 19, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 2, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 6, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 10, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 14, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 1, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 18, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 5, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 9, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 13, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 17, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 4, 1) || "
	cQuery += "          SUBSTR(SC5.C5_USERLGI, 8, 1) "
	cQuery += "    AS C5_USERINC, "
	cQuery += "    SA1.A1_NOME, "
	cQuery += "    SA1.A1_CGC, "
	cQuery += "    SA1.A1_ENDREC, "
	cQuery += "    SA1.A1_EMAIL, "
	cQuery += "    SA1.A1_MUN, "
	cQuery += "    SA1.A1_ESTADO, "
	cQuery += "    SC5.C5_EMISSAO, "
	cQuery += "    SC5.C5_OBS, "
	cQuery += "    SE4.E4_DESCRI AS prazoPagamento, "
	cQuery += "    MAX(SC6.C6_ENTREG) AS C6_ENTREG, "
	cQuery += "    SUM(SC6.C6_PRCVEN * (SC6.C6_QTDVEN - SC6.C6_QTDENT)) AS VALOR_TOTAL_POR_PEDIDO "
	cQuery += "FROM "
	cQuery += "    "+RetSqlName("SC5")+"  SC5 "
	cQuery += "    INNER JOIN "+RetSqlName("SC6")+"  SC6 ON "
	cQuery += "        SC5.C5_NUM = SC6.C6_NUM "
	cQuery += "        AND SC5.C5_CLIENTE = SC6.C6_CLI "
	cQuery += "        AND SC5.C5_LOJACLI = SC6.C6_LOJA "
	cQuery += "        AND SC5.C5_FILIAL = SC6.C6_FILIAL "
	cQuery += "        AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
	cQuery += "        AND SC6.C6_BLQ <> 'S' "
	cQuery += "        AND SC6.C6_QTDVEN > SC6.C6_QTDENT "
	cQuery += "   INNER JOIN "+RetSqlName("SA3")+"  SA3 ON ("
	cQuery += "        SA3.A3_COD  = SC5.C5_VEND1 "
	cQuery += "        OR SA3.A3_COD  = SC5.C5_VEND2 "
	cQuery += "        OR SA3.A3_COD  = SC5.C5_VEND3 "
	cQuery += "        OR SA3.A3_COD  = SC5.C5_VEND4 "
	cQuery += "        OR SA3.A3_COD  = SC5.C5_VEND5) "
	cQuery += "        AND SA3.D_E_L_E_T_  = SC5.D_E_L_E_T_ "
	cQuery += "   INNER JOIN "+RetSqlName("SB1")+"  SB1 ON "
	cQuery += "        SB1.B1_COD = SC6.C6_PRODUTO "
	cQuery += "        AND SB1.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
	cQuery += "   INNER JOIN "+RetSqlName("SA1")+"  SA1 ON "
	cQuery += "        SA1.A1_COD = SC5.C5_CLIENTE "
	cQuery += "        AND SA1.A1_LOJA  =	SC5.C5_LOJACLI  "
	cQuery += "        AND SA1.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
	cQuery += "   INNER JOIN "+RetSqlName("SE4")+"  SE4 ON "
	cQuery += "        SE4.E4_CODIGO = SC5.C5_CONDPAG "
	cQuery += "        AND SE4.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
	cQuery += "WHERE "
	cQuery += "    SC5.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC5.C5_FILIAL ='"+filial+"' "
	cQuery += "    AND SC5.C5_EMISSAO BETWEEN '"+dataDe+"' AND '"+dataAte+"' "
	cQuery += "    AND SA3.A3_COD BETWEEN  '"+vendedorDe+"' AND '"+vendedorate+"' "
	cQuery += "    AND SC5.C5_NUM BETWEEN '"+pedidoDe+"' AND '"+pedidoAte+"' "
	cQuery += "GROUP BY "
	cQuery += "    SC5.C5_NUM, "
	cQuery += "    SA1.A1_NOME, "
	cQuery += "    SA1.A1_CGC, "
	cQuery += "    SA1.A1_ENDREC, "
	cQuery += "    SA1.A1_EMAIL, "
	cQuery += "    SC5.C5_EMISSAO, "
	cQuery += "    SC5.C5_OBS, "
	cQuery += "    SE4.E4_DESCRI, "
	cQuery += "    SA1.A1_MUN, "
	cQuery += "    SA1.A1_ESTADO, "
	cQuery += "    SC5.C5_USERLGI,"
	cQuery += "    SC5.C5_USERLGA "
	cQuery += "	) A "
	cQuery += "WHERE RTRIM(LTRIM(SUBSTR(A.C5_USERINC, 1, 6))) =  '"+usuario+"'"

Return cQuery


Static Function FGetQueryProd(NumeroPedido)


	LOCAL cQuery := ""
	default NumeroPedido := ''
	cQuery += "SELECT "
	cQuery += "    SC6.C6_PRODUTO, "
	cQuery += "    (SC6.C6_QTDVEN - SC6.C6_QTDENT) AS CAIXAS, "
	cQuery += "    SB1.B1_DESC, "
	cQuery += "    (SC6.C6_PRCVEN / NULLIF(SB1.B1_QE, 0)) AS PRECO_UNITARIO, "
	cQuery += "    SC6.C6_PRCVEN  AS VALOR_POR_CAIXA, "
	cQuery += "    (SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN AS VALOR_TOTAL_POR_ITEM "
	cQuery += "FROM "
	cQuery += "    "+RetSqlName("SC6")+"  SC6 "
	cQuery += "    INNER JOIN "+RetSqlName("SB1")+" SB1 ON "
	cQuery += "        SB1.B1_COD = SC6.C6_PRODUTO "
	cQuery += "        AND SB1.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
	cQuery += "WHERE "
	cQuery += "    SC6.C6_NUM = '"+NumeroPedido+"' "
	cQuery += "    AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC6.C6_BLQ <> 'S' "
	cQuery += "    AND SC6.C6_QTDVEN > SC6.C6_QTDENT "

Return cQuery




