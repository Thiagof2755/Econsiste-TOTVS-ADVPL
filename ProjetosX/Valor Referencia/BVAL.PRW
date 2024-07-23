/*/{Protheus.doc} BVAL
Autor : Thiago Alves da Silva Filho 
Data : 16/07/2024

CRIAR CAMPO C8_REF e Chamar a Função U_BVAL() no Inicializador Do Campo
/*/
User Function BVAL()
Local cQuery := GetVAL(AllTrim(SC8->C8_PRODUTO)) //Pega o Cod do Produto e Busca o Valor de Entrada na cQuery
Local cAlias := "TMPTAB"
Local Valor := 0

MpSysOpenQuery(cQuery,cAlias)

if !Empty( cAlias ) // Se retornou algum valor
    Valor := (cAlias)->D1_VUNIT // Retorna o Valor do Campo
EndIf

Return  Valor


/*/{Protheus.doc} GetVAL

/*/
Static Function GetVAL(CodProd) //Busca o Ultimo Valor de entrada do Produto
Local cQuery := ""

cQuery += "SELECT TOP 1 SD1.D1_VUNIT FROM " + RetSqlName("SD1") + " AS SD1 "
cQuery +=    "WHERE SD1.D1_COD = '"+CodProd+"'"
cQuery +=        "AND D_E_L_E_T_ = '' "
cQuery +=        "AND D1_FILIAL = '" + xFilial("SD1") + "' "
cQuery +=    "ORDER BY D1_DTDIGIT DESC "
    
Return  cQuery
