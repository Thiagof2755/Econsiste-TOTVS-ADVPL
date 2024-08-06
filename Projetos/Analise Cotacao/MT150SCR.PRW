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
    Public cTIPO     := " "




    aSizeAut	:= MsAdvSize()
	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial("SC8")+CA150NUM+CA150FORN+CA150LOJ+ALLTRIM(ACOLS[1][3]))
	if !Empty(SC8->C8_X_FPGTO)
		//cTIPO := ALLTRIM(SC8->C8_X_FPGTO)
		For NI := 1 To Len(Compara[1])
			if Compara[2][NI] = ALLTRIM(SC8->C8_X_FPGTO)
				cTIPO := ALLTRIM(SC8->C8_X_FPGTO)
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


    @ aPosObj[1][1]+17 ,aPosGet[1,7] SAY OemToAnsi("TIPO DE PAGAMENTO") Of oDlg PIXEL SIZE 60,8 
    @ aPosObj[1][1]+27 ,aPosGet[1,7] COMBOBOX cTIPO ITEMS aTIPO   OF oDlg PIXEL SIZE 60,8 

    RestArea(aArea)
Return

