#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
                                                             
/**************************************************************************************************
{Protheus.doc} MCOM005
@description	rotina para selecao dos titulos do xml e mostrar os itens 
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		13/05/2023
**************************************************************************************************/
user function MCOM005( cArquivo )

	local oDlg		    := nil
    local oBmp          := nil
    local aTemp         := {}
    
	local nLin1 	    := 035
	local nLin2 	    := 045
	local nLin3     	:= 210
	local nCol		    := 005
    local cUsr		    := allTrim(usrFullName(retCodUsr()))

    local aXMLDoc       := {}
    local cArqXML       := ''
    local cXMLOri       := ''
    local cErro         := ''
    local cDoc          := ''
    local cSerie        := ''
    local cNomFor       := ''

    private oOk         := 'BR_VERDE'
    private oNo         := 'BR_VERMELHO'

	private _oGetTit	:= nil
	private cCadastro 	:= 'Vincular Produto x Fornecedor'

    default cArquivo    := ''

    if !empty( cArquivo )

        aXMLDoc := f002( cArquivo )

        if len( aXMLDoc ) > 0 

            cArqXML := aXMLDoc[02]
            cXMLOri := aXMLDoc[04]
            cErro   := aXMLDoc[07]
            cDoc    := aXMLDoc[11]
            cSerie  := aXMLDoc[13]
            cNomFor := aXMLDoc[12]

            aTemp := f006( cXMLOri )

            DEFINE MSDIALOG oDlg TITLE cCadastro From 000,000 to 460,1000 of oMainWnd PIXEL
            DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD

            @ nLin1,nCol SAY "Arquivo: " OF oDlg PIXEL FONT oBold COLOR CLR_RED
            @ nLin2,nCol MSGET oArqXML VAR cArqXML SIZE 127,009 OF oDlg COLOR CLR_RED  PIXEL WHEN .F.
            
            @ nLin1,nCol+128 SAY "Documento:" SIZE 070,07  OF oDlg PIXEL FONT oBold
            @ nLin2,nCol+128 MSGET oDoc VAR cDoc SIZE 070,009 OF oDlg COLOR CLR_BLACK  PIXEL  WHEN .F.
                        
            @ nLin1,nCol+198 SAY "Serie:" SIZE 070,07  OF oDlg PIXEL FONT oBold
            @ nLin2,nCol+198 MSGET oSerie VAR cSerie SIZE 020,009 OF oDlg COLOR CLR_BLACK PIXEL WHEN .F. 
            
            @ nLin1,nCol+220 SAY "Fornecedor:" SIZE 070,07  OF oDlg PIXEL FONT oBold
            @ nLin2,nCol+220 MSGET oNomFor VAR cNomFor SIZE 200,009 OF oDlg COLOR CLR_BLACK PIXEL WHEN .F.
                
            @ nLin1,nCol+420 SAY "Erro:" SIZE 070,07  OF oDlg PIXEL FONT oBold
            @ nLin2,nCol+420 MSGET oErro VAR cErro SIZE 075,009 OF oDlg COLOR CLR_BLACK PIXEL WHEN .F.

            //Criação do GetDados
            f001( oDlg )
            
            // Função Duplo Clique do Mouse ou ENTER
            _oGetTit:oBrowse:bLDblClick 	:= {|| f005() }
                                                
            //Alimenta o aCols com os dados enviados
            _oGetTit:aCols := aTemp
            
            //Atualiza o objeto
            _oGetTit:refresh()

            @ nLin3, nCol 	  	BITMAP oBmp RESNAME "BR_VERMELHO" SIZE 016,016 NOBORDER OF oDlg PIXEL
            @ nLin3, nCol+010 	SAY "Item Não Vinculado" OF oDlg PIXEL FONT oBold 

            @ nLin3, nCol+080   BITMAP oBmp RESNAME "BR_VERDE" SIZE 016,016 NOBORDER OF oDlg PIXEL
            @ nLin3, nCol+090 	SAY "Item Vinculado" OF oDlg PIXEL FONT oBold 

            @ nLin3+1,nCol+220 SAY " | " OF oDlg PIXEL FONT oBold

            @ nLin3+1, nCol+230 SAY "Usuário: " OF oDlg PIXEL FONT oBold
            @ nLin3+1, nCol+270 SAY cUsr        OF oDlg PIXEL FONT oBold  COLOR CLR_RED
                    
            ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , { || iif( f003(), oDlg:End() , ) } , { || oDlg:End() } , .F. , ) CENTERED

        endIf

    else
        Aviso('ATENÇÃO', 'Nenhum arquivo selecionado', {'Confirmar'} ) 
        return .F.
    endIf

return
/**************************************************************************************************
{Protheus.doc} f001
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f001(oDlg)

	local nX			:= 0
	local aCpoGDa       := {	'XX_LEGEND'		,;  //01
								'A5_PRODUTO'	,;  //02 
                                'B1_DESC'       ,;  //03
								'A5_CODPRF'	    ,;  //04
                                'A5_NOMPROD'    ,;  //05
								'D1_QUANT'	    ,;  //06
                                'D1_VUNIT'	    ,;  //07
                                'D1_TOTAL'	    ,;  //08
                                'A5_NOMEFOR'	,;  //09  
                                'A2_CGC'	    ,;  //10
                                'A2_COD'	    ,;  //11
                                'A2_LOJA'	    ,;  //12
                                'A2_NOME'	    ,;  //13
                                'B1_POSIPI'     ,;  //14
                                'B1_CEST'       ,;  //15
                                'B1_PICMENT'    ,;  //16
                                'B1_ORIGEM'     }   //17
	local aAlter       	:= { }	               	// Vetor com os campos que poderao ser alterados
	local cLinhaOk     	:= "AllwaysTrue"    	// Funcao executada para validar o contexto da linha atual do aCols
	local cTudoOk      	:= "AllwaysTrue"    	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	local cIniCpos     	:= ""               	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
                                           			// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                          			// segundo campo>+..."                                                               
	local nFreeze      	:= 000              	// Campos estaticos na GetDados.
	local nMax         	:= 000              	// Numero maximo de linhas permitidas. Valor padrao 99
	local cCampoOk     	:= "AllwaysTrue"    	// Funcao executada na validacao do campo
	local cSuperApagar 	:= ""               	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	local cApagaOk     	:= "AllwaysTrue"    	// Funcao executada para validar a exclusao de uma linha do aCols
	local oWnd          := oDlg					// Objeto no qual a MsNewGetDados sera criada
	local aHead        	:= {}               	// Array a ser tratado internamente na MsNewGetDados como aHeader
	local aCol         	:= {}               	// Array a ser tratado internamente na MsNewGetDados como aCols
                                                                                                                                
	
	aAdd(aHead,{	""				,;
					"XX_LEGEND"		,;
					"@BMP"			,;
					10				,;
					0				,;
					""				,;
					""				,;
					"C"				,;
					""				,;
					""				,;
					""				,;
					""				})
                                                                                                                 
	// dbSelectArea("SX3")
	// SX3->( dbSetOrder(2) ) // Campo
    // for nX := 1 to len( aCpoGDa )
    //     if SX3->(DbSeek(aCpoGDa[nX]))
	// 		aAdd(aHead,{ AllTrim(X3Titulo())	,;
	// 							SX3->X3_CAMPO	,;
	// 							SX3->X3_PICTURE	,;
	// 							SX3->X3_TAMANHO	,;
	// 							SX3->X3_DECIMAL	,;
	// 							SX3->X3_VALID	,;
	// 							SX3->X3_USADO	,;
	// 							SX3->X3_TIPO	,;
	// 							SX3->X3_F3 		,;
	// 							SX3->X3_CONTEXT	,;
	// 							SX3->X3_CBOX	,;
	// 							SX3->X3_RELACAO	})
	// 	endif
	// next nX

    cEmpresa  := FWGrpEmp()
    cAliasTmp := "SX3TEMP"
    cFiltro   := ""
    For nX := 2 To Len(aCpoGDa)
        If nX > 2
            cFiltro += " .And. "
        EndIF
        cFiltro   += " X3_CAMPO == '" + aCpoGDa[nX] + "'"
    next nX
    OpenSXs(NIL, NIL, NIL, NIL, cEmpresa, cAliasTmp, "SX3", NIL, .F.)
    (cAliasTmp)->(DbSetFilter({|| &(cFiltro)}, cFiltro))
    (cAliasTmp)->(DbGoTop())
    while !(cAliasTmp)->(Eof())
        aAdd(aHead, {&("(cAliasTmp)->X3_Titulo"),;
                        &("(cAliasTmp)->X3_CAMPO"),;
                        &("(cAliasTmp)->X3_PICTURE"),;
                        &("(cAliasTmp)->X3_TAMANHO"),;
                        &("(cAliasTmp)->X3_DECIMAL"),;
                        &("(cAliasTmp)->X3_VALID"),;
                        &("(cAliasTmp)->X3_USADO"),;
                        &("(cAliasTmp)->X3_TIPO"),;
                        &("(cAliasTmp)->X3_F3"),;
                        &("(cAliasTmp)->X3_CONTEXT"),;
                        &("(cAliasTmp)->X3_CBOX"),;
                        &("(cAliasTmp)->X3_RELACAO")})
        (cAliasTmp)->(DbSkip())
    endDo


	aAux := {}

	for nX := 1 to len( aCpoGDa )
		If nX == 1 .or. nX == 2
			aAdd( aAux , oNo )
		Else
			aAdd( aAux , CriaVar(aHead[nX,2]))
		EndIf
	next nX

	aAdd(aAux,.F.)
	aAdd(aCol,aAux)

	_oGetTit := MsNewGetDados():New( 060, 004, 203, 498, GD_UPDATE , cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax, cCampoOk, cSuperApagar, cApagaOk, oWnd, aHead, aCol)

return
/**************************************************************************************************
{Protheus.doc} f002
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f002( cArquivo )

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
/**************************************************************************************************
{Protheus.doc} f003
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f003()
return .T.
/**************************************************************************************************
{Protheus.doc} f004
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f004()    
return .T.
/**************************************************************************************************
{Protheus.doc} f005
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f005()

    local aProd := ''

    if _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('XX_LEGEND' , _oGetTit:aHeader )] == oOk
        Aviso('ATENÇÃO', 'Produto já cadastrado e vinculado com o Fornecedor', {'OK'}) 
    else 

        f008()

        aProd := f007(  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A2_COD'    , _oGetTit:aHeader )] ,;
                        _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A5_CODPRF' , _oGetTit:aHeader )] )

        if !empty( aProd[01] ) .and. !empty( aProd[02] )  
            _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('XX_LEGEND' , _oGetTit:aHeader )] := oOk
            _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A5_PRODUTO', _oGetTit:aHeader )] := aProd[01]
            _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('B1_DESC'   , _oGetTit:aHeader )] := aProd[02]
        else
            _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('XX_LEGEND' , _oGetTit:aHeader )] := oNo
        endIf

    endIf

    _oGetTit:refresh()

return .T.
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f006( cXMLOri )

    local cError        := ''
    local cWarning      := ''
    local oFullXML      := nil
    local oXML          := nil
    local oAuxXML       := nil
    local oXMLProtNFe   := nil
    local lFound        := .F.

    local cCGCDes       := ''           // CGC Destinatario
    local cInsDes       := ''           // Inscricao Destinatario
    local cInsc         := ''           // Inscricao Estadual
    local cChvNfe       := ''           // Chave NFe
    local cCGC          := ''		    // CGC
    local cDoc          := ''		    // Numero do Documento
    local cSerie        := '' 		    // Serie
    local cCodigo       := ''		    // Fornecedor
    local cLoja         := '' 		    // Loja do Fornecedor
    local cNomeFor      := ''		    // Nome do Fornecedor
    local dEmis         := cToD('//')	// Data de Emissão
    local cEst          := ''	        // Estado de emissao da NF
    local cTipoNF       := ''			// Tipo da Nota
    local cVersao       := ''			// Versão
    local nVlrFrete     := 0            // Valor Frete
    local nVlrSeguro    := 0            // Valor Seguro
    local nVlrDespesa   := 0            // Valor Desconto
    local nVlrDesconto  := 0            // Valor Desconto
    local nVlrMerc      := 0            // Valor Mercadoria
    local cTipoFrete    := ''			// Tipo de Frete
    local cPlacaTran	:= ''			// Placa
    local nPesoLiq		:= 0    		// Peso Liquido
    local nPesoBruto    := 0    		// Peso Bruto
    local cHrEmis       := ''	    	// Hora NF-e
    local cCGCTransp    := ''           // CGC Transportadora
    local aItens        := {}           // Itens

    local cCodPFor 	    := ''           // Codigo Produto Fornecedor
    local cDescPFor     := ''           // Descrição Produto Fornecedor
    local cNomFor       := ''           // Nome do Fornecedor
    local nQuant 		:= 0            // Qtd do item
    local nPrecUni 	    := 0            // Preco Unitário
    local nTotItem      := 0            // Valor Total
    local nFretItem     := 0			// Valor Frete
    local nDespItem     := 0			// Valor Despesa
    local nSegItem      := 0			// Valor Seguro
    local nDescItem     := 0 			// Valor Desconto
    local cPedido	    := 0 			// Pedido
    local cItemPed      := 0 			// Item do pedido
    local cCFOP         := ''			// Confirma CFOP de Retorno de Beneficiamento 'S' ou 'N'
    local cLote	        := ''			// Lote
    local dValidLote    := cToD('//')	// Validade do Lote
    local cFciCod       := ''			// Codigo FCI (alteração)          
    local cCodCFOP      := ''           // CFOP
    local nIPIItem      := 0            // IPI
    local nICMItem      := 0            // ICMS
    local nISSItem      := 0            // ISS
    local nPISItem      := 0            // PIS
    local nCOFItem      := 0            // COFINS
    local nIMCSTIt      := 0            // ICMS Substituicao
    local nAlIPIItem    := 0            // Aliquota IPI
    local nAlICMItem    := 0            // Aliquota ICMS
    local nAlISSItem    := 0            // Aliquota ISS
    local nAlPISItem    := 0            // Aliquota PIS
    local nAlCOFItem    := 0            // Aliquota COFINS
    local nALIMCSTIt    := 0            // Aliquota ICMS Substituicao                    
    local dFabLote      := cToD('//')   // Dt Fabricação
    local nBCFCPSTRet   := 0            // Base FCP Ant
    local nPFCPSTRet    := 0            // Aliq FCP Ant
    local nVFCPSTRet    := 0            // Vlr. FCP Ant
    local nBCFCPST      := 0            // Base FCP ST 
    local nPFCPST       := 0            // Aliq FCP ST 
    local nVFCPST       := 0            // Valor FCP ST
    local nVICMSSTRet   := 0            // ICMS ST Ante
    local nBICMSSTRet   := 0            // B.ICMS ST An
    local nAICMSSTRet   := 0            // A.ICMS ST An
    local cClasFis      := 0            // Sit.Tribut.  
    local nICMDeson     := 0            // ICMS Deson  
    local cICMDesMot    := 0            // ICM Des Mot 
    local aQtdVol       := {}
    local cCNPJTran     := ''
    local cNFECFAP      := SuperGetMV("MV_XMLCFPC",.F.,"")
    local cNFECFBN      := SuperGetMV("MV_XMLCFBN",.F.,"")
    local cNFECFDV      := SuperGetMV("MV_XMLCFDV",.F.,"")
    local cNFECFND      := SuperGetMV("MV_XMLCFND",.F.,"")
    local cNFECFNO      := SuperGetMV("MV_XMLCFNO",.F.,"")
    Local nTamFci	    := TamSx3("DT_FCICOD")[1]

    local aRet          := {}
    local nX            := 0 
    local cXML          := ''

    if !empty( cXMLOri )

        if subStr( cXMLOri, 1, 1 ) != "<"
            nPosPesq := at( "<", cXMLOri )
            cXMLOri  := substr( cXMLOri, nPosPesq, len(cXMLOri) )	// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
        endIf
        
        cXML := decodeUTF8( cXMLOri )
        
        if empty( cXML )
            cXML := cXMLOri
        endIf
        
        cXML := convAsc(cXML)       //remove acentuação
        cXML := a140IRemASC(cXML)	//remove caracteres especiais não aceitos pelo encode
        
        cXML := encodeUtf8(cXML)
            
        if empty( cXML )
            cXML := cXMLOri
        endIf

    endIf

    if empty( cXML )
        message( 'Erro no parse do xml' , 2)
    else 

        oFullXML := XmlParser( cXML, "_", @cError, @cWarning )

        if empty( oFullXML ) .Or. !Empty(cError)
            
            Aviso('ATENÇÃO', cError, {'OK'}) 
            return .F.

        else

            oXML    := oFullXML
            oAuxXML := oXML	

            while !lFound

                oAuxXML := XmlChildEx( oAuxXML , "_NFE" )

                if !(lFound := oAuxXML # NIL)

                    for nX := 1 To XmlChildCount( oXML )
                        oAuxXML  := XmlChildEx( XmlGetchild(oXML,nX) , "_NFE" )
                        lFound := oAuxXML:_InfNfe# Nil
                        if lFound
                            oXML := oAuxXML
                            exit
                        endIf
                    next nX

                endIf				

                if lFound
                    oXML := oAuxXML
                    exit
                endIf

            endDo

            oAuxXml := XmlChildEx(oXml,"_INFNFE")

            cDoc        := strzero( val( allTrim( oXML:_InfNfe:_Ide:_nNF:Text ) ) , tamSx3("F1_DOC")[1] )
            cSerie      := padR( oXML:_InfNfe:_Ide:_Serie:Text , SerieNfId("SF1",6,"F1_SERIE") )
            cChvNfe	    := right(AllTrim(oXML:_InfNfe:_Id:Text),44)
            cEst        := oXML:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
            cVersao     := oXML:_InfNfe:_versao:text 	
            nVlrFrete   := val(oXML:_INFNFE:_TOTAL:_ICMSTOT:_vFrete:TEXT) 
            nVlrSeguro  := val(oXML:_INFNFE:_TOTAL:_ICMSTOT:_vSeg:TEXT)   
            nVlrDespesa := val(oXML:_INFNFE:_TOTAL:_ICMSTOT:_vOutro:TEXT) 
            nVlrDesconto:= val(oXML:_INFNFE:_TOTAL:_ICMSTOT:_vDesc:TEXT)  
            nVlrMerc    := val(oXML:_INFNFE:_TOTAL:_ICMSTOT:_vProd:TEXT)  

            //Hora emissão da NF-e
            If XmlChildEx(oFullXML, "_NFEPROC") # NIL
                If XmlChildEx(oFullXML:_NFEPROC,"_PROTNFE") # NIL
                    oXMLProtNFe := XmlChildEx(oFullXML:_NFEPROC:_PROTNFE,"_INFPROT")
                    If XmlChildEx(oXMLProtNFe,"_DHRECBTO") # NIL
                        cHrEmis := Substr(oXMLProtNFe:_DhRecbto:Text,12)
                    Endif
                Elseif XmlChildEx(oAuxXml, "_IDE") # NIL .And. XmlChildEx(oAuxXml:_IDE,"_DHEMI") # NIL // XML de Devolução/Cancelamento
                    cHrEmis := Substr(oAuxXml:_IDE:_DHEMI:Text,12)
                    If XmlChildEx(oFullXML:_NFEPROC,"_RETCANCNFE") # NIL .And. ;
                        XmlChildEx(oFullXML:_NFEPROC:_RETCANCNFE,"_INFCANC") # NIL
                        oXMLProtNFe := XmlChildEx(oFullXML:_NFEPROC:_RETCANCNFE,"_INFCANC")
                    Endif
                Endif
            Endif

            if empty( cHrEmis ) 
                cChvNfe := Right(AllTrim(oXML:_InfNfe:_Id:Text),44)		
                Aviso('ATENÇÃO', "Tag _NFEPROC não encontrada no XML da NF-e." + cChvNfe ,{"OK"}) 
                return .F.
            endIf

            //Emitente
            if XmlChildEx(oAuxXml:_EMIT,"_CNPJ") # NIL
                cCGC := oAuxXml:_EMIT:_CNPJ:TEXT
            elseif XmlChildEx(oAuxXml:_EMIT,"_CPF") # NIL
                cCGC := oAuxXml:_EMIT:_CPF:TEXT
            endIf	

            if XmlChildEx(oAuxXml:_EMIT,"_IE") # NIL
                cInsc := oAuxXml:_EMIT:_IE:TEXT
            endIf

            //Destinatario
            if XmlChildEx(oAuxXml:_DEST,"_CNPJ") # NIL
                cCGCDes := oAuxXml:_DEST:_CNPJ:TEXT
            elseif XmlChildEx(oAuxXml:_DEST,"_CPF") # NIL
                cCGCDes := oAuxXml:_DEST:_CPF:TEXT
            endIf

            if XmlChildEx(oAuxXml:_DEST,"_IE") # NIL
                cInsDes := oAuxXml:_DEST:_IE:TEXT					
            endIf

            
            if XmlChildEx(oAuxXml:_TRANSP,"_TRANSPORTA") # NIL 
                if XmlChildEx(oAuxXml:_TRANSP:_Transporta,"_CNPJ") # NIL
                    cCGCTransp := oAuxXml:_TRANSP:_Transporta:_CNPJ:TEXT
                elseIf XmlChildEx(oAuxXml:_TRANSP:_Transporta,"_CPF") # NIL
                    cCGCTransp := oAuxXml:_TRANSP:_Transporta:_CPF:TEXT					
                endIf 	
            endIf

            aItens := IIF(ValType(oXML:_InfNfe:_Det) == "O",{oXML:_InfNfe:_Det},oXML:_InfNfe:_Det)	

            if AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "1"

                cTipoNF := "N"

                //-- Valida o tipo da nf
                for nX := 1 To len( aItens )
                    if aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFAP
                        cTipoNF := "O"
                    elseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFBN
                        cTipoNF := "B"
                    elseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFDV
                        cTipoNF := "D"
                    endIf
                    
                    if cTipoNF <> "N"
                        Exit
                    endIf
                next nX

            elseIf AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "4"

                for nX := 1 To Len(aItens)
                    
                    if aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFNO // Tratamento para modificar o tipo da nota para N = Normal, quando TAG FINNFE = 4.
                        cTipoNF := "N"
                        Exit
                    elseIf aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFBN
                        cTipoNF := "B"       
                        Exit
                    endIf
                    
                next nX
                    
                if Empty(cTipoNF)
                    cTipoNF := "D"
                endif

            Endif

            do case 
                case AllTrim(oXML:_InfNfe:_Transp:_ModFrete:Text) == "0"
                    cTipoFrete := "C"
                case AllTrim(oXML:_InfNfe:_Transp:_ModFrete:Text) == "1"
                    cTipoFrete := "F"
                case AllTrim(oXML:_InfNfe:_Transp:_ModFrete:Text) == "2"
                    cTipoFrete := "T"			
                case AllTrim(oXML:_InfNfe:_Transp:_ModFrete:Text) == "3" .Or. AllTrim(oXML:_InfNfe:_Transp:_ModFrete:Text) == "9" 
                    cTipoFrete := "S"
            end case

            if valType( XmlChildEx(oXML:_InfNFe,"_TRANSP") ) == "O" 	

                if ValType(XmlChildEx(oXML:_InfNFe:_Transp,"_TRANSPORTA")) == "O"
                    if ValType(XmlChildEx(oXML:_InfNFe:_Transp:_Transporta,"_CPF")) == "O"
                        cCNPJTran := oXML:_InfNfe:_Transp:_Transporta:_CPF:Text	
                    elseIf ValType(XmlChildEx(oXML:_InfNFe:_Transp:_Transporta,"_CNPJ")) == "O"
                        cCNPJTran := oXML:_InfNfe:_Transp:_Transporta:_CNPJ:Text
                    endIf
                endIf

                if ValType(XmlChildEx(oXML:_InfNFe:_Transp,"_VEICTRANSP")) == "O"
                    if ValType(XmlChildEx(oXML:_InfNFe:_Transp:_VeicTransp,"_PLACA")) == "O"
                        cPlacaTran := oXML:_InfNFe:_Transp:_VeicTransp:_Placa:Text
                    endIf
                endIf

                if ValType(XmlChildEx(oXML:_InfNFe:_Transp,"_VOL")) == "O"
                    aQtdVol := {oXML:_InfNfe:_Transp:_Vol}
                elseIf ValType(XmlChildEx(oXML:_InfNFe:_Transp,"_VOL")) == "A"
                    aQtdVol := oXML:_InfNfe:_Transp:_Vol
                endIf

                for nX := 1 To len(aQtdVol)
                    if ValType(XmlChildEx(aQtdVol[nX],"_PESOB")) == "O"
                        nPesoBruto += Val(aQtdVol[nX]:_PESOB:TEXT)
                    endIf
                    if ValType(XmlChildEx(aQtdVol[nX],"_PESOL")) == "O"
                        nPesoLiq += Val(aQtdVol[nX]:_PESOL:TEXT)
                    endIf
                next nX

            endIf

            //Valida tag da data de emissao
            if valType(XmlChildEx(oXML:_InfNfe:_Ide,"_DEMI")) == "O"
                dEmis := StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DEmi:Text),"-",""))
            elseIf valType(XmlChildEx(oXML:_InfNfe:_Ide,"_DHEMI")) == "O"
                dEmis := StoD(StrTran(Substr((oXML:_InfNfe:_Ide:_DhEmi:Text),1,10),"-",""))
            endIf

            dbSelectArea('SA2')
            SA2->( dbSetOrder(3) )

            if SA2->( dbSeek( xFilial('SA2') + AllTrim(cCGC) ))		
                cCodigo 	:= SA2->A2_COD
                cLoja   	:= SA2->A2_LOJA
                cNomeFor    := SA2->A2_NOME	
            endIf

            SA2->( dbCloseArea() )

            for nX := 1 To len( aItens )

                cCodPFor 	:= ''               // Codigo Produto Fornecedor
                cDescPFor   := ''               // Descrição Produto Fornecedor
                cNomFor     := ''               // Nome do Fornecedor
                nQuant 		:= 0                // Qtd do item
                nPrecUni 	:= 0                // Preco Unitário
                nTotItem    := 0                // Valor Total
                nFretItem   := 0				// Valor Frete
                nDespItem   := 0				// Valor Despesa
                nSegItem    := 0				// Valor Seguro
                nDescItem   := 0 				// Valor Desconto
                cPedido	    := 0 				// Pedido
                cItemPed    := 0 				// Item do pedido
                cCFOP       := ''				// Confirma CFOP de Retorno de Beneficiamento 'S' ou 'N'
                cLote	    := ''				// Lote
                dValidLote  := cToD('//')		// Validade do Lote
                cFciCod     := ''				// Codigo FCI (alteração)          
                cCodCFOP    := ''               //CFOP
                nIPIItem    := 0                //IPI
                nICMItem    := 0                //ICMS
                nISSItem    := 0                //ISS
                nPISItem    := 0                //PIS
                nCOFItem    := 0                //COFINS
                nIMCSTIt    := 0                //ICMS Substituicao
                nAlIPIItem  := 0                //Aliquota IPI
                nAlICMItem  := 0                //Aliquota ICMS
                nAlISSItem  := 0                //Aliquota ISS
                nAlPISItem  := 0                //Aliquota PIS
                nAlCOFItem  := 0                //Aliquota COFINS
                nALIMCSTIt  := 0                //Aliquota ICMS Substituicao                    
                dFabLote    := cToD('//')       //Dt Fabricação
                nBCFCPSTRet := 0                //Base FCP Ant
                nPFCPSTRet  := 0                //Aliq FCP Ant
                nVFCPSTRet  := 0                //Vlr. FCP Ant
                nBCFCPST    := 0                //Base FCP ST 
                nPFCPST     := 0                //Aliq FCP ST 
                nVFCPST     := 0                //Valor FCP ST
                nVICMSSTRet := 0                //ICMS ST Ante
                nBICMSSTRet := 0                //B.ICMS ST An
                nAICMSSTRet := 0                //A.ICMS ST An
                cClasFis    := 0                //Sit.Tribut.  
                nICMDeson   := 0                //ICMS Deson  
                cICMDesMot  := 0                //ICM Des Mot 
                cNCM        := ''
                cCest       := ''
                cOrigClas   := ''               //Origem do produto

                
                
                cCodPFor 	:= AllTrim(aItens[nX]:_Prod:_cProd:Text)
                cDescPFor   := AllTrim(aItens[nX]:_Prod:_xProd:Text)
                cNCM        := iif( valType(XmlChildEx(aItens[nX]:_Prod,"_NCM" )) == "O" , AllTrim(aItens[nX]:_Prod:_NCM:Text)  , '' )
                cCest       := iif( valType(XmlChildEx(aItens[nX]:_Prod,"_CEST")) == "O" , AllTrim(aItens[nX]:_Prod:_CEST:Text) , '' )
                cNomFor     := oXML:_INFNFE:_EMIT:_XNOME:Text
                nQuant 		:= Val(aItens[nX]:_Prod:_qCom:Text) //Vlor Unitário
                nPrecUni 	:= Val(aItens[nX]:_Prod:_vUnCom:Text)

                nMVA        := Posicione("SYD",1,(xFilial("SYD")+padr( cNCM , tamSx3('YD_TEC')[01] ) ),"YD_XMVA")

                //Verifica se existe a Tag para pedido de compra
                If ValType(XmlChildEx(aItens[nX]:_Prod,"_XPED")) == "O"

                    cPedido := aItens[nX]:_Prod:_xPed:Text

                    If Len(cPedido) > TamSx3("DT_PEDIDO")[1]
                        cPedido := RIGHT(cPedido,TamSx3("DT_PEDIDO")[1])
                    Else
                        cPedido := PADR(cPedido,TamSx3("DT_PEDIDO")[1])
                    EndIf

                EndIf

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_NITEMPED")) == "O"

                    cItemPed:= aItens[nX]:_Prod:_nItemPed:Text

                    If Len(cItemPed) > TamSx3("DT_ITEMPC")[1]
                        cItemPed := RIGHT(cItemPed,TamSx3("DT_ITEMPC")[1])
                    Else
                        cItemPed := PADL(cItemPed,TamSx3("DT_ITEMPC")[1],"0")
                    EndIf
                    
                EndIf
                

                
                //Verifica se existe a Tag para códido do FCI
                cFciCod := ""

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_NFCI")) == "O"

                    cFciCod := aItens[nX]:_Prod:_nFCI:Text
                
                    If Len(cFciCod) > nTamFCI
                        cFciCod := RIGHT(cFciCod,nTamFci)
                    Else
                        cFciCod := PADR(cFciCod,nTamFci)
                    EndIf

                EndIf

                
                //Informacoes de Lote e Validade do Lote
                If ValType(XmlChildEx(aItens[nX]:_Prod,"_RASTRO")) == "O"
                    cLote		:= aItens[nX]:_Prod:_Rastro:_nLote:Text
                    dValidLote	:= StoD(StrTran(AllTrim(aItens[nX]:_Prod:_Rastro:_dVal:Text),"-",""))
                    dFabLote	:= StoD(StrTran(AllTrim(aItens[nX]:_Prod:_Rastro:_dFab:Text),"-",""))		
                EndIf

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_VFRETE")) == "O"
                    nFretItem := Val(aItens[nX]:_Prod:_vFrete:Text)
                EndIf

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_VOUTRO")) == "O"
                    nDespItem := Val(aItens[nX]:_Prod:_vOutro:Text)
                EndIf

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_VSEG")) == "O"
                    nSegItem := Val(aItens[nX]:_Prod:_vSeg:Text)
                EndIf

                If ValType(XmlChildEx(aItens[nX]:_Prod,"_VDESC")) == "O"
                    nDescItem := Val(aItens[nX]:_Prod:_vDesc:Text)
                EndIf
                                                    
                cCfop := 'N'

                If aItens[nX]:_PROD:_CFOP:TEXT $ cNFECFND
                    cCfop:='S'
                EndIF

                cCodCFOP := ""
                
                If !Empty(aItens[nX]:_PROD:_CFOP:TEXT)
                    cCodCFOP := aItens[nX]:_PROD:_CFOP:TEXT
                EndIF
                    
                //--IPI
                If ValType(XmlChildEx(aItens[nX]:_Imposto,"_IPI")) == "O"

                    If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI,"_IPITRIB")) == "O"
                        // Verifica as TAGS do imposto IPI, pois ha XML que vem somente com 1 das TAGS abaixo.
                        If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_VIPI")) == "O"
                            nIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_vIPI:Text)
                        EndIf
                        
                        If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_PIPI")) == "O"
                            nAlIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_pIPI:Text)
                        EndIf
                    Endif

                EndIf

                //--ICMS
                If ValType(XmlChildEx(aItens[nX]:_Imposto,"_ICMS")) == "O"
                    If ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS00")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_pICMS:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_CST:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS10")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMS:Text), 0)
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMSST:Text), 0)
                        nBCFCPST 	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VBCFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_VBCFCPST:Text), 0)
                        nPFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_PFCPST:Text), 0)
                        nVFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_VFCPST:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_CST:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS20")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_pICMS:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_motDesICMS:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS30")) == "O"
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_pICMSST:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_motDesICMS:Text,"")
                        nBCFCPST 	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VBCFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_VBCFCPST:Text), 0)
                        nPFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_PFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_PFCPST:Text), 0)
                        nVFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_VFCPST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS40")) == "O"
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS40:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_motDesICMS:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS41")) == "O"
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS41:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_motDesICMS:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS50")) == "O"
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS50:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_motDesICMS:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS51")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_pICMS:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_CST:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS60")) == "O"
                        nBCFCPSTRet := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vBCFCPSTRet:Text), 0)
                        nPFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_pFCPSTRet:Text), 0)
                        nVFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vFCPSTRet:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_CST:Text,"")
                        nVICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vICMSSTRet:Text), 0)
                        nBICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VBCSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vBCSTRet:Text), 0)
                        nAICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_PST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_pST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS70")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMS:Text), 0)
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMSST:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_motDesICMS:Text,"")
                        nBCFCPST 	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VBCFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_VBCFCPST:Text), 0)
                        nPFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_PFCPST:Text), 0)
                        nVFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_VFCPST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS90")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMS:Text), 0)	
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMSST:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_CST:Text,"")
                        nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMSDeson:Text), 0)
                        cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_motDesICMS:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSPART")) == "O"
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_pICMSST:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSPART:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSPART:_CST:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSST")) == "O" 
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSST:_vICMSSTRet:Text), 0)
                        cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSST:_Orig:Text,"")
                        cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSST:_CST:Text,"")
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN201")) == "O"	
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_pICMSST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN202")) == "O"
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_vICMSST:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_pICMSST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN500")) == "O"	
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vICMSSTRet:Text), 0)
                        nBCFCPSTRet := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vBCFCPSTRet:Text), 0)
                        nPFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_pFCPSTRet:Text), 0)
                        nVFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vFCPSTRet:Text), 0)
                        nVICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vICMSSTRet:Text), 0)
                        nBICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VBCSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vBCSTRet:Text), 0)
                        nAICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_PST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_pST:Text), 0)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN900")) == "O"
                        nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMS:Text), 0)
                        nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMS:Text), 0)	
                        nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMSSTRet:Text), 0)
                        nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMSSTRet:Text), 0)
                    EndIf
                EndIf
                    
                //--PIS
                If ValType(XmlChildEx(aItens[nX]:_Imposto,"_PIS")) == "O"
                    If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISALIQ")) == "O"  
                        nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_vPIS:Text)
                        nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_pPIS:Text)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISQTDE")) == "O"
                        nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISQtde:_vPIS:Text)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISOUTR")) == "O"
                        nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vPIS:Text)
                        If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_PPIS")) == "O"
                            nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_pPIS:Text)
                        ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_VALIQPROD")) == "O"
                            nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vAliqProd:Text)
                        EndIf
                    Endif
                EndIf
                    
                //--COFINS
                If ValType(XmlChildEx(aItens[nX]:_Imposto,"_COFINS")) == "O"
                    If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSALIQ")) == "O"
                        nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:Text)
                        nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:Text)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSQTDE")) == "O"
                        nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSQtde:_vCOFINS:Text)
                    ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSOUTR")) == "O"
                        nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vCOFINS:Text)
                        If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_PCOFINS")) == "O"
                            nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_pCOFINS:Text)
                        ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_VALIQPROD")) == "O"
                            nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vAliqProd:Text)
                        EndIf
                    EndIf
                EndIf
                        
                //Verifica Tag vProd
                If ValType(XmlChildEx(aItens[nX]:_Prod,"_VPROD")) == "O" 
                    nTotItem := Val(aItens[nX]:_Prod:_vProd:Text)
                EndIf

                aProd := f007( cCodigo, cCodPFor )

                aAdd( aRet , {	iif( empty( aProd[01] ) , oNo , oOk )   ,;    // 01
                                aProd[01]   ,;    // 02
                                aProd[02]   ,;    // 03
                                cCodPFor    ,;    // 04
                                cDescPFor   ,;    // 05
                                nQuant      ,;    // 06
                                nPrecUni    ,;    // 07
                                nTotItem    ,;    // 08
                                cNomFor     ,;    // 09
                                cCGC        ,;    // 10
                                cCodigo 	,;    // 11
                                cLoja   	,;    // 12
                                cNomeFor    ,;    // 13
                                cNCM        ,;    // 14
                                cCest       ,;    // 15
                                nMVA        ,;    // 16
                                iif( empty( cOrigClas ) , '0', cOrigClas)   ,;    // 17
                                .F.			})    // 18

            next nX

        endIf

    endIf

return aRet
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f007( cCodFor, cPrdFor )

    local aRet   := { '' , '' }
	local cAlias := GetNextAlias()
	  
	beginSql Alias cAlias

        SELECT
                A5_PRODUTO
            ,	A5_NOMPROD
        FROM
            %Table:SA5%  SA5
        WHERE
                SA5.%NotDel% 
            AND SA5.A5_FILIAL = %xFilial:SA5%
            AND SA5.A5_FORNECE = %exp:cCodFor%
            AND SA5.A5_CODPRF  = %exp:cPrdFor%

	endSql		

    while !(cAlias)->(Eof())

        aRet   := { (cAlias)->A5_PRODUTO , (cAlias)->A5_NOMPROD }

		(cAlias)->( dbSkip() )

	endDo

	(cAlias)->( dbCloseArea() )   

return aRet 
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f008()

    local oDlgPrd   := nil
    local oCodFor   := nil
    local oForn     := nil
    local oPrdFor   := nil
    local oPrdDes   := nil
    local oCodPrd   := nil
    local oDesPrd   := nil
    local cForCm    := ''
    local cCodFor   := space(tamSx3('A2_COD')[01])
    local cForn     := space(tamSx3('A2_NOME')[01])
    local cPrdFor   := space(tamSx3('A5_CODPRF')[01])
    local cPrdDes   := space(tamSx3('B1_DESC')[01])
    local cCodPrd   := space(tamSx3('B1_COD')[01])
    local cDesPrd   := space(tamSx3('B1_DESC')[01])
	local cNCM		:= space(tamSx3('B1_POSIPI')[01])
	local cCest		:= space(tamSx3('B1_CEST')[01])
	local nMVA		:= 0
    local cOrigClas := ''

    private cCadastro := 'Fornecedor x Produto'

    DEFINE MSDIALOG oDlgPrd TITLE cCadastro From 000,000 to 300,560 of oMainWnd PIXEL

        cCodFor :=  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A2_COD'    , _oGetTit:aHeader )]
        cLojFor :=  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A2_LOJA'   , _oGetTit:aHeader )]
        cForn   :=  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A2_NOME'   , _oGetTit:aHeader )]

        cForCm  := cCodFor + ' - ' + cLojFor
        
        cPrdFor :=  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A5_CODPRF'  , _oGetTit:aHeader )]
	    cPrdDes :=  _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('A5_NOMPROD' , _oGetTit:aHeader )]

	    cNCM	:= _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('B1_POSIPI'  , _oGetTit:aHeader )]
		cCest	:= _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('B1_CEST'    , _oGetTit:aHeader )]
		nMVA	:= _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('B1_PICMENT' , _oGetTit:aHeader )]

        cOrigClas := _oGetTit:aCols[_oGetTit:oBrowse:nAt][gdFieldPos('B1_ORIGEM' , _oGetTit:aHeader )]

        DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD

    	@ 035, 005 SAY "Fornecedor:"            SIZE 070,007 OF oDlgPrd PIXEL FONT oBold
        @ 045, 005 MSGET oCodFor VAR cForCm     SIZE 070,009 OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F.
        @ 045, 075 MSGET oForn   VAR cForn      SIZE 203,009 OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F.

        @ 060, 005 SAY "Produto do Fornecedor:" SIZE 070,007  OF oDlgPrd PIXEL FONT oBold
        @ 070, 005 MSGET oPrdFor VAR cPrdFor    SIZE 070,009  OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F.
        @ 070, 075 MSGET oPrdDes VAR cPrdDes    SIZE 203,009  OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F.
        
        @ 087, 005 SAY "NCM:"                   SIZE 070,007  OF oDlgPrd PIXEL FONT oBold
        @ 085, 023 MSGET oPrdDes VAR cNCM       SIZE 070,009  OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F. PICTURE PesqPict('SB1','B1_POSIPI') 

        @ 087, 095 SAY "CEST:"                  SIZE 070,007  OF oDlgPrd PIXEL FONT oBold
        @ 085, 115 MSGET oPrdDes VAR cCest      SIZE 070,009  OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F. PICTURE PesqPict('SB1','B1_CEST') 

        @ 087, 189 SAY "MVA:"                   SIZE 070,007  OF oDlgPrd PIXEL FONT oBold
        @ 085, 208 MSGET oPrdDes VAR nMVA       SIZE 070,009  OF oDlgPrd COLOR CLR_BLACK PIXEL WHEN .F. PICTURE PesqPict('SB1','B1_PICMENT') 

        @ 105, 005 SAY "Produto Protheus:"      SIZE 070,007  OF oDlgPrd PIXEL FONT oBold
        @ 115, 005 MSGET oCodPrd VAR cCodPrd    SIZE 070,009  OF oDlgPrd COLOR CLR_BLACK  PIXEL WHEN .T. F3 'SB1' VALID f009( @cCodPrd , @cDesPrd ) 
        @ 115, 075 MSGET oDesPrd VAR cDesPrd    SIZE 203,009  OF oDlgPrd COLOR CLR_BLACK  PIXEL WHEN .F.

        @ 135, 070 SAY "Não localizou o produto? " SIZE 200,007  OF oDlgPrd PIXEL FONT oBold COLOR CLR_RED

        @ 133,145 BUTTON oButton1 PROMPT "Incluir" SIZE 060, 012 OF oDlgPrd PIXEL Action ( f010( cPrdFor, cPrdDes, cNCM, cCest, nMVA, @cCodPrd, @cDesPrd, cOrigClas  ) )

    ACTIVATE MSDIALOG oDlgPrd ON INIT EnchoiceBar( oDlgPrd , { || iif( f012( cCodFor, cLojFor, cPrdFor, cPrdDes, cCodPrd, cDesPrd ) , oDlgPrd:End() , ) } , { || oDlgPrd:End() } , .F. , ) CENTERED

return 
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f009(cCodPrd, cDesc )

    local aArea := getArea()

    cDesc := space( tamSx3('B1_DESC')[01] )

	if !empty( cCodPrd )

		dbSelectArea("SB1")
		SB1->( dbSetOrder(1) )

		if SB1->( dbSeek( xFilial("SB1") + cCodPrd ) )
			cDesc := SB1->B1_DESC
		else
			Aviso('ATENÇÃO','Nenhum produto localizado!',{"OK"})
			cCodPrd := space( tamSx3('B1_COD')[01] )
		endIf

		SB1->( dbCloseArea() )

	endIf

    restArea( aArea )

return
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f010( cPrdFor, cPrdDes, cNCM, cCest, nMVA, cCodPrd, cDesPrd, cOrigClas )

	local aRet := { .F. , '' , '' }

	processa({|| aRet := f011(cPrdDes, cNCM, cCest, nMVA, cOrigClas ) } , "Processando...")

	if aRet[01]
		cCodPrd := aRet[02]
		cDesPrd := aRet[03]
	endIf

return aRet[01]
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f011(cPrdDes, cNCM, cCest, nMVA, cOrigClas )

	local aArea        := GetArea()
	local cTitulo      := OemtoAnsi('Atualização de Produtos')
	local cPrograma    := 'MCOM004' //Criei esse modelo para SB1 pq a rotina padrão estava dando erro ao carregar o modelo
	local aRet 		   := { .F. , '', '' }

	dbSelectArea('SB1')
	SB1->( dbSetOrder(1) )

	oModel := FWLoadModel( cPrograma )
	oModel:SetOperation(3) 
	oModel:Activate() 
	
	oModel:SetValue( "MASTER" , "B1_DESC"		, padr( cPrdDes, tamSx3('B1_DESC')[01] )  )
	oModel:SetValue( "MASTER" , "B1_POSIPI"  	, cNCM    )
	oModel:SetValue( "MASTER" , "B1_CEST" 		, cCest   )
	oModel:SetValue( "MASTER" , "B1_PICMENT" 	, nMVA    )
    oModel:SetValue( "MASTER" , "B1_ORIGEM" 	, cOrigClas    )

	lRet := FWExecView( cTitulo , cPrograma, 3, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel ) == 0 
	
	oModel:Deactivate()

	if lRet 
		aRet[01] := .T.
		aRet[02] := SB1->B1_COD
		aRet[03] := SB1->B1_DESC
	endIf

	SB1->( dbCloseArea() )

	restArea( aArea )

return aRet
/**************************************************************************************************
{Protheus.doc} message
@description	rotina para selecao dos titulos para geracao do PV e DOC Saida
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f012( cCodFor, cLojFor, cPrdFor, cPrdDes, cCodPrd, cDesPrd )

    local oModel := nil
    local lRet   := .F.
    
    if empty( cCodFor )
        Aviso('ATENÇÃO', 'Código do Fornecedor Protheus não informado', {'Confirmar'}) 
        return .F.
    endIf

    if empty( cLojFor )
        Aviso('ATENÇÃO', 'Loja do Fornecedor Protheus não informado', {'Confirmar'}) 
        return .F.
    endIf

    if empty( cPrdFor )
        Aviso('ATENÇÃO', 'Código do Produto do Fornecedor não informado', {'Confirmar'}) 
        return .F.
    endIf

    if empty( cPrdDes )
        Aviso('ATENÇÃO', 'Descrição do Produto do Fornecedor não informado', {'Confirmar'}) 
        return .F.
    endIf

    if empty( cCodPrd )
        Aviso('ATENÇÃO', 'Código do Produto do Protheus não informado', {'Confirmar'}) 
        return .F.
    endIf

    oModel := FWLoadModel('MATA061')
    oModel:SetOperation(3)
    oModel:Activate()
    
    //Cabeçalho
    oModel:SetValue( 'MdFieldSA5' , 'A5_PRODUTO' , padr( cCodPrd , tamSx3('A5_PRODUTO')[01] ) )
    oModel:SetValue( 'MdFieldSA5' , 'A5_NOMPROD' , padr( cDesPrd , tamSx3('A5_NOMPROD')[01] ) )
    
    //Grid
    oModel:SetValue( 'MdGridSA5' , 'A5_FORNECE' , padr( cCodFor , tamSx3('A5_FORNECE')[01]  ) )
    oModel:SetValue( 'MdGridSA5' , 'A5_LOJA'    , padr( cLojFor , tamSx3('A5_LOJA')[01]     ) )
    oModel:SetValue( 'MdGridSA5' , 'A5_CODPRF'  , padr( cPrdFor , tamSx3('A5_CODPRF')[01]   ) )
    oModel:SetValue( 'MdGridSA5' , 'A5_DESCPRF' , padr( cPrdDes , tamSx3('A5_DESCPRF')[01]  ) )
    
    If oModel:VldData()
        lRet := oModel:CommitData()
    Endif
    
    oModel:DeActivate()
    oModel:Destroy()

return lRet
/*
COM001 - Erro de sintaxe no arquivo XML: Entre em contato com o emissor do documento e comunique a ocorrência.
COM002 - Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente.
COM003 - Documento complemento de preço icms/ipi não é tratado pelo TOTVS Colaboração.Gere o documento complementeo de preço icms/ipi manualmente através da rotina documento de entrada.
COM004 - Tipo NF-e de ajustes não será tratado pelo TOTVS Colaboração.Gere o documento de ajustes de forma manual através da rotina documento de entrada.
COM005 - ID de NF-e já registrado na NF do fornecedor.
COM006 - ID de NF-e já registrado na NF do Do Cliente.
COM007 - Fornecedor/Cliente inexistente na base. Gere cadastro para este fornecedor/cliente.
COM008 - O Cliente Emitente não está cadastrado: Inclua o emitente manualmente.
COM009 - Não foi possível incluir o destinatário. Inclua o destinatário  manualmente.
COM010 - Não foi possível incluir o local de entrega. Inclua o local de entrega  manualmente.
COM011 - Não foi possível atualizar o local de entrega. Atualize o local de entrega manualmente.
COM012 - Fornecedor sem cadastro de Produto X Fornecedor.
COM013 - Nota fiscal possui itens com valor zerado.Verifique a nota recebida do fornecedor.
COM014 - Não foi identificado nenhum pedido de compra referente ao item.
COM015 - Verifique as informações da Nf-e.
COM016 - DS_PLIQUI - O tamanho do campo não suporta o valor fornecido.
COM017 - DS_PBRUTO - O tamanho do campo não suporta o valor fornecido.
COM018 - Este XML possui um codigo de Serviço que não está cadastrado em um produto na empresa/filial corrente.
COM019 - ID de CT-e já registrado na NF.
COM020 - Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada.
COM021 - TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente.
COM022 - Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro
COM023 - Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.
COM024 - Corrija a inconsistência apontada no log.
COM025 - Documento já processado.
COM026 - O tamanho de um dos campos de volume não suporta o valor fornecido.
COM027 - Cliente sem cadastro de Produto X Cliente.
COM028 - CNPJ fornecedor/cliente duplicado.
COM029 - Quantidade nos Pedidos (P.E A140IVPED) é maior que a quantidade do XML
COM030 - Fornecedor/Cliente bloqueado na base. Faça o desbloqueio do cadastro para este fornecedor/cliente.
COM031 - TES bloqueado. Verifique a configuração do cadastro.
COM032 - Retorno do ponto de entrada A116ICOMP inconsistente. Verifique a documentacao do mesmo no portal TDN.
COM033 - Inscrição Estadual do Fornecedor/Cliente não identificada. Verifique o cadastro do Fornecedor/Cliente.
COM034 - Tag _DTEMISNFSE não encontrada. Verificar com quem originou o XML.
COM035 - Tag _NNFSE não encontrada. Verificar com quem originou o XML.
COM036 - CT-e cancelado.
COM037 - CT-e rejeitado.
COM038 - Tag _UFTOM não encontrada. Verificar com quem originou o XML.
COM039 - Valor total da prestação de serviço e valor a receber estão zerados.
COM040 - NF-e cancelada.
COM041 - NF-e rejeitada
COM042 - Existe mais de uma Empresa/Filial para este XML.
COM043 - Aliquota de imposto igual ou superior a 100%.Verificar com quem originou o XML.
COM044 - Documento de entrada existente na base. Processe o recebimento deste documento de entrada para importar o CTE corretamente
COM045 - CTEOS cancelada.
COM046 - CTEOS rejeitada.
COM047 - Complemento de imposto não é tratado pelo Totvs Colaboração/Importador.
COM048 - Inconsistência na importação do CT-e. Verifique no SIGAGFE (GFEA118)
COM049 - Tag _NFEPROC não encontrada no XML da NF-e. Verifique se o XML esta correto.
COM050 - Não foi possivel converter para 1ª unidade de medida, pois o produto não possui fator de conversão. Ajuste o produto.
COM051 - Codigo do municipio inexistente. Realize o cadastro.
COM052 - CNPJ/IE não pertence a empresa. Verificar se XML está correto.
*/
