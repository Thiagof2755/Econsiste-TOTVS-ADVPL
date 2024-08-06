#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT150FIX
(long_description)
@type user function
@author THIAGO
@since 30/07/2024
@version version
PONTO DE ENTRADA MANIPULAR CAMPOS 
/*/
User Function MT150SCR()
	Local aArea := GetArea()
    Local oDlg := PARAMIXB
    Local oSize
    Local oPagamento := Nil
    Local aPosObj 	 := {}
	LOCAL cCampo     := PadR("C8_X_FPGTO", 10)
    Local aTIPO   	 := TkSX3Box(cCampo)
	Local Compara 	 := X3CboxToArray(cCampo)
	Local NI         := NIL
	LOCAL cQuery 	 := FGetResult()
	Public cAliasTSC8 := GetNextAlias()
    Public cTIPO     := " "


//criar campo SC8 =  C8_X_FPGTO 
//CARACTER  = 1 
//FORMATO =  @!  
//Opcoes =  1=Pix;2=Cartão;3=Boleto;4=Permuta;5=Transferência;6=Dinheiro       
//Descricoes =  Forma de Pag                                                                                                       


    aSizeAut	:= MsAdvSize()
	MpSysOpenQuery(cQuery, cAliasTSC8)
	(cAliasTSC8)->(DbGoTop())

	if !Empty((cAliasTSC8)->C8_X_FPGTO)
		//cTIPO := ALLTRIM(SC8->C8_X_FPGTO)
		For NI := 1 To Len(Compara[1])
			if Compara[2][NI] = ALLTRIM((cAliasTSC8)->C8_X_FPGTO)
				cTIPO := ALLTRIM((cAliasTSC8)->C8_X_FPGTO)
			EndIF
		Next
	Endif

	//Adiciona uma nova aba no documento de entrada
    aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
							{{10,40,95,140,200,222,268,240},;
							{10,40,111,140,223,268,63},;
							{5,70,160,205,295},;
							{6,34,200,215},;
							{6,34,80,113,153,178},;
							{6,34,235,268,260},;
							{10,50,150,190,120},;
							{273,130,190},;
							{8,45,73,103,139,167,190,225,253},;
							{144,190,144,190,289,293},;
							{142,293,140},;
							{9,47,188,148,9,146}} )



						oSize := FwDefSize():New(.T.,,,oDlg)

						oSize:AddObject('HEADER',100,40,.T.,.F.)
						oSize:AddObject('GRID'  ,100,10,.T.,.T.)
						oSize:AddObject('FOOT'  ,100,90,.T.,.F.)

						oSize:aMargins 	:= { 3, 3, 3, 3 }
						oSize:Process()

						aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
						aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})
						aAdd(aPosObj,{oSize:GetDimension('FOOT'  , 'LININI'),oSize:GetDimension('FOOT'  , 'COLINI'),oSize:GetDimension('FOOT'  , 'LINEND'),oSize:GetDimension('FOOT'  , 'COLEND')})


    @ aPosObj[1][1]+17 ,aPosGet[1,7] SAY OemToAnsi("FORMA DE PAGAMENTO") Of oDlg PIXEL SIZE 80,8 
    @ aPosObj[1][1]+27 ,aPosGet[1,7] COMBOBOX cTIPO ITEMS aTIPO   OF oDlg PIXEL SIZE 60,8 

    RestArea(aArea)
Return

Static Function FGetResult()
	Local cQuery := ""
	cQuery  :=  "SELECT * FROM "+RetSqlName("SC8")+" "
	cQuery += "WHERE D_E_L_E_T_ = '' "
	cQuery += "AND C8_FILIAL = '"+xFilial("SC8")+"' "
	cQuery += "AND C8_NUM = '"+CA150NUM+"' "
	cQuery += "AND C8_FORNECE = '"+CA150FORN+"' "
	cQuery += "AND C8_LOJA = '"+CA150LOJ+"' "

Return cQuery

