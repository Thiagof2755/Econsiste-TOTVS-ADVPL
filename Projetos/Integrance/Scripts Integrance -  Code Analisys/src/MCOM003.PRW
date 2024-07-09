#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "TBICODE.CH"
#include 'FWMVCDEF.CH'

/**************************************************************************************************
{Protheus.doc} MCOM003
@description	rotina para correção dos dados da importação antes do reprocessamento
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/
user function MCOM003()

	local oDlgRep	:= NIL
	local oBrwErEx	:= NIL
	local oSize		:= Nil
	local aPosObj 	:= {}
	local aHeadCols := {}
	local aParam	:= {}
	local aAux		:= {}
	local cCodEdi	:= ""
	local cCodErro	:= ""
	local nI		:= 0
	
	aHeadCols := {	RetTitle("DS_ARQUIVO")			,; //01
					RetTitle("DS_DOC")				,; //02
					SerieNfId("SDS",7,"DS_SERIE")	,; //03
					RetTitle("DS_NOMEFOR")			,; //04
					'Empresa de Processamento'		,; //05
					'Filial de Processamento'		,; //06
					'Código do Erro'				,; //07
					'Descrição do Erro'				,; //08
					RetTitle("CKO_CNPJIM")			,; //09
					'Detalhe Mensagem de Erro'		 } //10

	Pergunte("COLREP",.F.)
	aAdd(aParam,Iif(MV_PAR01==2,.T.,.F.))
	aAdd(aParam,MV_PAR02)
	aAdd(aParam,MV_PAR03)
	
	aAux := Separa(AllTrim(MV_PAR04),";")

	for nI := 1 To Len(aAux)
		If Empty(cCodEdi)
			cCodEdi := "'" + aAux[nI] + "'"
		Else
			cCodEdi += ",'" + aAux[nI] + "'"
		Endif
	next nI

	aAdd(aParam,cCodEdi) 

	aAux := Separa(AllTrim(MV_PAR05),";")

	for nI := 1 To Len(aAux)
		if Empty(cCodErro)
			cCodErro := "'" + aAux[nI] + "'"
		else
			cCodErro += ",'" + aAux[nI] + "'"
		endif
	next nI

	aAdd(aParam,cCodErro)

	oSize := FwDefSize():New(.F.)

	oSize:AddObject('GRID'	,100,90,.T.,.T.)		

	oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:Process()

	aPosObj := { 3, 3, oSize:GetDimension("GRID","COLEND")-86,oSize:GetDimension("GRID","LINEND")}

	Define MsDialog oDlgRep Title 'Ajustar Importação' From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] Pixel 

	oBrwErEx := TWBrowse():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4],,aHeadCols,,oDlgRep,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrwErEx:bLDblClick   := {|| f002(oBrwErEx:aArray,oBrwErEx) }

	oRepOk	:= TButton():New(oSize:GetDimension("GRID","LININI")+045,oSize:GetDimension("GRID","COLEND")-75,"Ok"                	,oDlgRep,{|| f004(), oDlgRep:End()			}, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepPq	:= TButton():New(oSize:GetDimension("GRID","LININI")+065,oSize:GetDimension("GRID","COLEND")-75,"Pesquisar"         	,oDlgRep,{|| f005(oBrwErEx)					}, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepVin	:= TButton():New(oSize:GetDimension("GRID","LININI")+085,oSize:GetDimension("GRID","COLEND")-75,"Vincular Produto"  	,oDlgRep,{|| f002(oBrwErEx:aArray,oBrwErEx) }, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepFor	:= TButton():New(oSize:GetDimension("GRID","LININI")+105,oSize:GetDimension("GRID","COLEND")-75,"Incluir Fornecedor"  	,oDlgRep,{|| f008(oBrwErEx:aArray,oBrwErEx) }, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepXml	:= TButton():New(oSize:GetDimension("GRID","LININI")+125,oSize:GetDimension("GRID","COLEND")-75,"Visualizar XML"  		,oDlgRep,{|| f009(oBrwErEx:aArray,oBrwErEx) }, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepPF	:= TButton():New(oSize:GetDimension("GRID","LININI")+145,oSize:GetDimension("GRID","COLEND")-75,"Produto x Fornecedor"	,oDlgRep,{|| MATA061() 						}, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepAFor:= TButton():New(oSize:GetDimension("GRID","LININI")+165,oSize:GetDimension("GRID","COLEND")-75,"Importar Todos Forn."	,oDlgRep,{|| u_MCOM007() 					}, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oRepSa	:= TButton():New(oSize:GetDimension("GRID","LININI")+185,oSize:GetDimension("GRID","COLEND")-75,"Sair"              	,oDlgRep,{|| oDlgRep:End()					}, 70,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	f003(@oBrwErEx, aParam)

	Activate MsDialog oDlgRep Centered

return
/**************************************************************************************************
{Protheus.doc} f002
@description	Função para selecionar arquivos a serem reprocessados

@param	nOpc		1 ou 3-Linha / 2 ou 4-Header / 5 - Header Monitor / 6 - Limpa Marca (Fechar Monitor) / 7 - Seleciona Monitor
@param	aArquivo	Array com os arquivos
@param	oBrowse		Objeto Browse

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static Function f002(aArquivo,oBrowse) 

	local cArquivo := aArquivo[oBrowse:nAt,1]

	u_MCOM005( cArquivo )

	oBrowse:SetArray(aArquivo)
	oBrowse:bLine := {|| {aArquivo[oBrowse:nAt,01],aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05],aArquivo[oBrowse:nAt,06],aArquivo[oBrowse:nAt,07],aArquivo[oBrowse:nAt,08],aArquivo[oBrowse:nAt,09],aArquivo[oBrowse:nAt,10]}}
	oBrowse:Refresh()

return
/**************************************************************************************************
{Protheus.doc} f003
@description	Pesquisa arquivo na tela de reprocessar

@param	oBrwErEx	Objeto para pesquisa
@param	aParam		Parametros para filtro

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static function f003(oBrwErEx, aParam)

	f006(@oBrwErEx,aParam)

	oBrwErEx:Refresh()

return
/**************************************************************************************************
{Protheus.doc} f004
@description	Atualiza Flag do arquivo para reprocessar

@param	lProc		Reprocessar arquivos (.T.)
@param	lExcArq		Excluir arquivos (.T.)	
@param	oBrwErEx	oBrowse dos arquivos de erro / excluidos

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static function f004()

	Aviso('Atenção','Utilize a rotina de reprocessar para enviar o xml para processamento.',{"OK"}) 

return .T.
/**************************************************************************************************
{Protheus.doc} f005
@description	Pesquisa arquivo na tela de reprocessar

@param	oBrowse	Objeto para pesquisa

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static Function f005(oBrowse)

	local lProc      := .F.
	local cCpoPesq   := Space(100)
	local cOrdem     := "Arquivo"
	local nSeek      := 0
	local nOrdem     := 1

	Define MSDialog oDlgPesq Title 'Pesquisar' From 00,00 To 100,490 Pixel 

	@05,05 ComboBox oCbo1 Var cOrdem Items {RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),;
			SerieNfId("SDS",7,"DS_SERIE"),RetTitle("DS_NOMEFOR"),RetTitle("CKO_CNPJIM")} Size 206,36 Pixel Of oDlgPesq On Change (nOrdem := oCbo1:nAT)
	
	
	@22,05 MSGet oGet Var cCpoPesq Size 206,10 Pixel Of oDlgPesq
	
	Define SButton From 05,215 Type 1 Of oDlgPesq Enable Action (lProc := .T., oDlgPesq:End())
	Define SButton From 20,215 Type 2 Of oDlgPesq Enable Action oDlgPesq:End()

	Activate MSDialog oDlgPesq Center

	if lProc
		
		cCpoPesq := Upper(AllTrim(cCpoPesq))
		
		if nOrdem == 1 //-- Arquivo
			aSort(oBrowse:aArray,,,{|x,y| x[1] < y[1]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[1])) == cCpoPesq})	
		elseIf nOrdem == 2 //-- Documento
			aSort(oBrowse:aArray,,,{|x,y| x[2] < y[2]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(Left(x[2],Len(cCpoPesq))) == cCpoPesq})
		elseIf nOrdem == 3 //-- Serie	
			aSort(oBrowse:aArray,,,{|x,y| x[3] < y[3]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[3])) == cCpoPesq})
		elseIf nOrdem == 4 //-- Razao Social
			aSort(oBrowse:aArray,,,{|x,y| x[4] < y[4]} )
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[4])) == cCpoPesq})
		elseIf nOrdem == 5 //-- CNPJ Importado
			aSort(oBrowse:aArray,,,{|x,y| x[09] < y[09]} )
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[09])) == cCpoPesq})
		endIf

		if nSeek > 0
			oBrowse:nAT := nSeek
			oBrowse:Refresh()
			oBrowse:SetFocus()
		else
			Aviso('Atenção','A busca não encontrou resultados.',{"OK"}) 
		endIf

	endIf

return
/**************************************************************************************************
{Protheus.doc} f006
@description	Carga de arquivos com erros e excluidos para reprocessar

@param	oBrowse		Objeto oBrowse (Erro/Excluidos)
@param	aParam		Parametro pergunte COLREP

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static function f006(oBrowse, aParam) 

	local aArea			:= SDS->(GetArea())
	local aArquivo		:= {}
	local aDocs			:= {}
	local oColab		:= NIL
	local nX			:= 1
	local aCkoDados		:= {}
	local nTamCKOARQ	:= TamSX3("CKO_ARQUIV")[1]
	local lUsaFiltro	:= .F.
	local dDtDE			:= CtoD("//")
	local dDtATE		:= CtoD("//")
	local cCodEdi		:= ""
	local cCodErro		:= ""
	local aCodEdi		:= {}

	if Len(aParam) > 0
		lUsaFiltro	:= aParam[1]
		dDtDE		:= aParam[2]
		dDtATE		:= aParam[3]
		cCodEdi		:= aParam[4]
		cCodErro	:= aParam[5]
		aCodEdi		:= Separa(StrTran(cCodEdi,"'",""),",")
	endif

	oColab 				:= ColaboracaoDocumentos():New()
	oColab:cModelo 		:= ""
	oColab:cTipoMov 	:= '2'
	oColab:cFlag 		:= '2'
	oColab:cEmpProc 	:= cEmpAnt 
	oColab:cFilProc 	:= cFilAnt 
	oColab:aQueue 		:= Iif(lUsaFiltro .And. Len(aCodEdi) > 0,aCodEdi,{"109","319","214","273"})
	oColab:cQueue 		:= "109"
	
	if lUsaFiltro
		oColab:aParamMonitor:= {lUsaFiltro,dDtDE,dDtATE,cCodEdi,cCodErro}
	endif
		
	oColab:buscaDocumentosFilial()

	if Len(oColab:aNomeArq)
		
		for nX := 1 To Len(oColab:aNomeArq)
			oColab:cNomeArq := oColab:aNomeArq[nX,1]
			oColab:cFlag := '2'
			oColab:Consultar() 

			aCkoDados := GetAdvFVal("CKO",{"CKO_CODEDI","CKO_DOC","CKO_SERIE","CKO_NOMFOR"},Padr(oColab:aNomeArq[nX,1],nTamCKOARQ),1)
	
			aAdd(aDocs,{oColab:aNomeArq[nX,1],;
						aCkoDados[2],;
						aCkoDados[3],;
						aCkoDados[4],;
						oColab:cEmpProc,;
						oColab:cFilProc,;
						oColab:cCodErrErp,;
						oColab:cMsgErrErp,;
						oColab:cCnpjImp,;
						oColab:cMsgErr024,;
						aCkoDados[1],;
						""})			
		next nX

	endif

	for nX := 1 To Len(aDocs)
		aAdd(aArquivo,{})	
		aAdd(aTail(aArquivo),aDocs[nX,01]) //-- Nome do arquivo
		aAdd(aTail(aArquivo),aDocs[nX,02]) //-- Numero do Doc. 
		aAdd(aTail(aArquivo),aDocs[nX,03]) //-- Serie Doc.
		aAdd(aTail(aArquivo),aDocs[nX,04]) //-- Razao Social do fornecedor
		aAdd(aTail(aArquivo),aDocs[nX,05]) //-- Empresa
		aAdd(aTail(aArquivo),aDocs[nX,06]) //-- Filial
		aAdd(aTail(aArquivo),aDocs[nX,07]) //-- Codigo Erro
		aAdd(aTail(aArquivo),aDocs[nX,08]) //-- Mensagem Erro
		aAdd(aTail(aArquivo),aDocs[nX,09]) //-- CNPJ Importação
		aAdd(aTail(aArquivo),aDocs[nX,10]) //-- Detalhe Mensagem de Erro
	next nX

	if Len(aArquivo) > 0 
		aArquivo := f007(aArquivo)
	else
		aAdd(aArquivo,{})
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
	endIf

	oBrowse:SetArray(aArquivo)
	oBrowse:nAt := 1
	oBrowse:bLine := {|| {aArquivo[oBrowse:nAt,01],aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05],aArquivo[oBrowse:nAt,06],aArquivo[oBrowse:nAt,07],aArquivo[oBrowse:nAt,08],aArquivo[oBrowse:nAt,09],aArquivo[oBrowse:nAt,10]}}
	oBrowse:Refresh()

	SDS->( restArea(aArea) )

return
/**************************************************************************************************
{Protheus.doc} f007
@description	Função para retirar documento duplicados ao reprocessar

@param		aArquivo, array, Documentos carregados

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static function f007(aArquivo)

	local aArea			:= GetArea()
	local aRet			:= {}
	local aAux			:= {}
	local nI			:= 0
	local aCodErroExc	:= {"COM005","COM006","COM019"}

	dbSelectArea("CKO")
	CKO->(DbSetOrder(1))

	//Verifica duplicidade
	for nI := 1 To Len(aArquivo)
		if !Empty(aArquivo[nI,2]) .And. !Empty(aArquivo[nI,3]) .And. !Empty(aArquivo[nI,4])
			nPos := aScan(aRet,{|x| AllTrim(x[2])+AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5])+AllTrim(x[6]) == AllTrim(aArquivo[nI,2])+AllTrim(aArquivo[nI,3])+AllTrim(aArquivo[nI,4])+AllTrim(aArquivo[nI,5])+AllTrim(aArquivo[nI,6])}) 
			if nPos == 0
				aAdd(aRet,{aArquivo[nI,1],AllTrim(aArquivo[nI,2]),AllTrim(aArquivo[nI,3]),AllTrim(aArquivo[nI,4]),AllTrim(aArquivo[nI,5]),AllTrim(aArquivo[nI,6]),AllTrim(aArquivo[nI,7]),AllTrim(aArquivo[nI,8]),AllTrim(aArquivo[nI,9]),AllTrim(aArquivo[nI,10])})
			else						
				aRet[nPos,1]  := aArquivo[nI,1]
				aRet[nPos,2]  := aArquivo[nI,2]
				aRet[nPos,3]  := aArquivo[nI,3]
				aRet[nPos,4]  := aArquivo[nI,4]
				aRet[nPos,5]  := aArquivo[nI,5]
				aRet[nPos,6]  := aArquivo[nI,6]
				aRet[nPos,7]  := aArquivo[nI,7]
				aRet[nPos,8]  := aArquivo[nI,8]		
				aRet[nPos,9]  := aArquivo[nI,9]
				aRet[nPos,10] := aArquivo[nI,10]
			endif
		else
			aAdd(aRet,{aArquivo[nI,1],AllTrim(aArquivo[nI,2]),AllTrim(aArquivo[nI,3]),AllTrim(aArquivo[nI,4]),AllTrim(aArquivo[nI,5]),AllTrim(aArquivo[nI,6]),AllTrim(aArquivo[nI,7]),AllTrim(aArquivo[nI,8]),AllTrim(aArquivo[nI,9]),AllTrim(aArquivo[nI,10])})
		endif
	next nI

	//Retira os arquivos com os codigo de erro:
	for nI := 1 To Len(aRet)
		if aScan(aCodErroExc,AllTrim(aRet[nI,8])) == 0
			aAdd(aAux,{aRet[nI,1],AllTrim(aRet[nI,2]),AllTrim(aRet[nI,3]),AllTrim(aRet[nI,4]),AllTrim(aRet[nI,5]),AllTrim(aRet[nI,6]),AllTrim(aRet[nI,7]),AllTrim(aRet[nI,8]),AllTrim(aRet[nI,9]),AllTrim(aRet[nI,10])})
		endif
	next nI

	//Atualiza aRet
	aRet := aClone(aAux)

	restArea(aArea)

return aRet
/**************************************************************************************************
{Protheus.doc} f008
@description	Função para selecionar arquivos a serem reprocessados

@param	nOpc		1 ou 3-Linha / 2 ou 4-Header / 5 - Header Monitor / 6 - Limpa Marca (Fechar Monitor) / 7 - Seleciona Monitor
@param	aArquivo	Array com os arquivos
@param	oBrowse		Objeto Browse

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static Function f008(aArquivo,oBrowse) 

	local cArquivo := aArquivo[oBrowse:nAt,1]

	u_MCOM006( cArquivo )

	oBrowse:SetArray(aArquivo)
	oBrowse:bLine := {|| {aArquivo[oBrowse:nAt,01],aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05],aArquivo[oBrowse:nAt,06],aArquivo[oBrowse:nAt,07],aArquivo[oBrowse:nAt,08],aArquivo[oBrowse:nAt,09],aArquivo[oBrowse:nAt,10]}}
	oBrowse:Refresh()

return
/**************************************************************************************************
{Protheus.doc} f008
@description	Função para selecionar arquivos a serem reprocessados

@param	nOpc		1 ou 3-Linha / 2 ou 4-Header / 5 - Header Monitor / 6 - Limpa Marca (Fechar Monitor) / 7 - Seleciona Monitor
@param	aArquivo	Array com os arquivos
@param	oBrowse		Objeto Browse

@type   		static function 
@author			Ruann Carlos
@version   		1.00
@since     		14/05/2023
**************************************************************************************************/ 
static function f009(aArquivo,oBrowse) 

	local cTempPath := GetTempPath(.T.)
	local cArquivo  := aArquivo[oBrowse:nAt,1]
	local cFile 	:= cTempPath + cArquivo + ".xml"
	local aXMLDoc 	:= {}
	local oDlgXML	:= TDialog():New( 150, 150, 500, 500,'',,,,,,,,,.T.)

	// Se existir algum arquivo com o mesmo nome no temp da máquina, exclui, pois se o sistema oscilar a estação pode cair e não excluir o .xml
	if File( cFile )
		FErase( cFile )
	endIf

	aXMLDoc := f010( cArquivo )

	// Cria o arquivo XML temporário para apresentação na tela
	If MemoWrite( cFile, aXMLDoc[04] )
		oXml := TXMLViewer():New(10, 10, oDlgXML , cFile, 150, 150, .T. )
		oXML:SetXML( cFile )
		oDlgXML:Activate()

		// Quando usuário fechar a tela, exclui o XML temporário
		FErase( cFile )

	Else
		MsgAlert( "Erro ao tentar visualizar XML" )
	EndIf

return
/**************************************************************************************************
{Protheus.doc} f001
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f010( cArquivo )

    local aRegs  := {}
	local cAlias := GetNextAlias()
	  
	beginSql Alias cAlias

        SELECT 
                CKO_FILIAL
            ,	CKO_ARQUIV
            ,	CKO_STATUS
            ,	CKO.R_E_C_N_O_ CKORECNO
        FROM 
            %Table:CKO% CKO
        WHERE 
                CKO.%NotDel% 
            AND CKO.CKO_FILIAL = %xFilial:CKO%
            AND CKO.CKO_ARQUIV = %exp:cArquivo% 

	endSql		

    dbSelectArea('CKO')
    CKO->( dbSetOrder(1) )

    while !(cAlias)->(Eof())

        CKO->( dbGoTo( (cAlias)->CKORECNO ) )
		
		aRegs :=  {	    CKO->CKO_FILIAL    ,;    // 01
                        CKO->CKO_ARQUIV    ,;    // 02
                        CKO->CKO_STATUS    ,;    // 03
                        CKO->CKO_XMLRET    ,;    // 04
                        CKO->CKO_FLAG      ,;    // 05
                        CKO->CKO_CODEDI    ,;    // 06
                        CKO->CKO_CODERR    ,;    // 07
                        CKO->CKO_FILPRO    ,;    // 08
                        CKO->CKO_CNPJIM    ,;    // 09
                        CKO->CKO_MSGERR    ,;    // 10
                        CKO->CKO_DOC       ,;    // 11
                        CKO->CKO_NOMFOR    ,;    // 12
                        CKO->CKO_SERIE     ,;    // 13
                        CKO->CKO_ARQXML	   ,;    // 14
                        CKO->CKO_EMPPRO    }     // 15

		(cAlias)->( dbSkip() )

	endDo

	(cAlias)->( dbCloseArea() )   

    if len( aRegs ) == 0 
        message( 'Nenhum registro localizado!' , 2 ) 
    endIf

return aRegs 
