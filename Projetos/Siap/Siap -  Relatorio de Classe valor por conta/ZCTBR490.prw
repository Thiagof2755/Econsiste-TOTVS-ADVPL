#include "totvs.ch"
#include "FWMVCDEF.ch"
#INCLUDE 'topconn.ch'

User Function ZCTBR490()

dbSelectArea("CT1")
dbSelectArea("CT2")
dbSelectArea("CTH")

Local oReport := Nil
oReport := ReportDef()
oReport:PrintDialog()
oReport := Nil

CtbRazClean()
RestArea("CT1")
RestArea("CT2")
RestArea("CTH")

Return              


Static Function ReportDef()

Local cTitulo		:= "Emissao do Razao Contabil por Classe de Valor"

Local oReport
Local oSection

oReport := TReport():New("CTBR490",cTitulo, cPerg, {|oReport|,oReport:CancelPrint(), ReportPrint(oReport)})
oReport:ParamReadOnly()
oReport:SetLandScape()
oReport:SetTotalInLine(.F.)

oSection := TRSection():New(oReport, "Contas", {""}) 

TRCell():New(oSection,"CLN_CONTA"			,"","Conta" 				,"@R 9.9.9.9.99.9999",GetSx3Cache('CT1_CONTA',"X3_TAMANHO")+4)  
TRCell():New(oSection,"CLN_CTADESC"			,"","Conta Desc." 			,,90)
TRCell():New(oSection,"CLN_CLVALOR"			,"","Classe Valor" 			,"@R 9.9.9.9.99.999",GetSx3Cache('CTH_CLVL',"X3_TAMANHO")+2)
TRCell():New(oSection,"CLN_CLVLRDESC"		,"","Class. Vlr. Desc." 	,,90) 
TRCell():New(oSection,"CLN_NUMERO"			,"","Lote/Sub/Doc/Linha" 	,,20)
TRCell():New(oSection,"CLN_HISTORICO"		,"","Historico" 			,,40)
TRCell():New(oSection,"CLN_CONTRA_PARTIDA"	,"","Contra Partida" 		,"@R 9.9.9.9.99.9999",GetSx3Cache('CT1_CONTA',"X3_TAMANHO")+4)
TRCell():New(oSection,"CLN_SALDOANT"		,"","Sld. Anterior" 		,GetSx3Cache('CT7_DEBITO',"X3_PICTURE"),GetSx3Cache('CT7_DEBITO',"X3_TAMANHO")+4)  
TRCell():New(oSection,"CLN_VLR_DEBITO"		,"","Vlr. Debito" 			,GetSx3Cache('CT7_DEBITO',"X3_PICTURE"),GetSx3Cache('CT7_DEBITO',"X3_TAMANHO")+4) 
TRCell():New(oSection,"CLN_VLR_CREDITO"		,"","Vlr. Credito" 			,GetSx3Cache('CT7_CREDIT',"X3_PICTURE"),GetSx3Cache('CT7_CREDIT',"X3_TAMANHO")+4)
TRCell():New(oSection,"CLN_VLR_SALDO"		,"","Sld. Atual" 			,GetSx3Cache('CT7_DEBITO',"X3_PICTURE"),GetSx3Cache('CT7_DEBITO',"X3_TAMANHO")+4)


Return(oReport)

Static Function ReportPrint(oReport)

Local oSection	:=  oReport:Section(1) 
Local cQuery := Getquerry()
Local cAlias := GetNextAlias()

MpSysOpenQuery(cQuery,cAlias)
(cAlias)->(dbGoTop())
oReport:SetMeter(RecCount())

oSection:Init()
While !(cAlias)->(Eof())
	// se cancelar a impressão saia
	IF oReport:Cancel()
		Exit
	EndIF
	// inicia a barra de carregamento
	oReport:IncMeter()
	//Conta
	oSection:Cell("CLN_CONTA")			:SetValue((cAlias)->CT2_DEBITO)
	oSection:Cell("CLN_CTADESC")		:SetValue((cAlias)->CT1_DESCR01)

	//classe valor
	oSection:Cell("CLN_CLVALOR")		:SetValue((cAlias)->CT2_CLVLDB)
	oSection:Cell("CLN_CLVLRDESC")		:SetValue((cAlias)->CTH_DESCR01)

	//Razão  
	oSection:Cell("CLN_NUMERO")			:SetValue((cAlias)->NUMB)
	oSection:Cell("CLN_HISTORICO")		:SetValue((cAlias)->CT2_HIST)
	oSection:Cell("CLN_CONTRA_PARTIDA")	:SetValue((cAlias)->CT2_CREDIT)
							
	//Valores
	oSection:Cell("CLN_SALDOANT")		:SetValue((cAlias)->CT7_ANTCRD - (cAlias)->CT7_ANTDEB)
	oSection:Cell("CLN_VLR_DEBITO")		:SetValue((cAlias)->CT7_DEBITO)
	oSection:Cell("CLN_VLR_CREDITO")	:SetValue((cAlias)->CT7_CREDIT)
	oSection:Cell("CLN_VLR_SALDO")		:SetValue((cAlias)->CT7_ATUCRD - (cAlias)->CT7_ATUDEB)

	oSection:Printline()
EndDo
oSection:Finish()
Return

static function Getquerry()

// Cria a Querry
Local cQRY

cQRY := "Select CT2.CT2_DEBITO, CT2.CT2_CLVLDB, (CT2.CT2_LOTE+CT2.CT2_SBLOTE+CT2.CT2_DOC+CT2.CT2_LINHA) AS NUMB,"
cQRY += " CT2.CT2_HIST, CT2.CT2_CREDIT, CT2_VALOR, CT2_CCD, CT7.CT7_ANTDEB, CT7.CT7_ANTCRD, CT7.CT7_DEBITO, CT7.CT7_CREDIT, CT7.CT7_ATUDEB, CT7.CT7_ATUCRD"
cQRY += " from CT2010 CT2"
cQRY += 	" INNER JOIN CT7010 CT7"
cQRY += 	" ON CT7_CONTA = CT2_DEBITO"
cQRY += " WHERE CT2.D_E_L_E_T_ = ' '"
cQRY +=   " AND CT2_FILIAL  between '" + MV_PAR01 + "' and '" + MV_PAR02 + "'"
cQRY +=   " AND CT2_DATA  between '" +  DTOS(MV_PAR03) + "' and '" + DTOS(MV_PAR04) + "'"
cQRY +=   " AND CT2_DEBITO  between '" + MV_PAR05 + "' and '" + MV_PAR06 + "'"
cQRY +=   " AND CT2_CCD  between '" + MV_PAR07 + "' and '" + MV_PAR08 + "'"
cQRY += " Order by CT2_DATA"

Return cQRY
