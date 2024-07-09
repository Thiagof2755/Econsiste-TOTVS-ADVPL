#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
                                                             
/**************************************************************************************************
{Protheus.doc} MCOM006
@description	rotina para selecao dos titulos do xml e mostrar os itens 
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		10/07/2023
**************************************************************************************************/
user function MCOM006( cArquivo , lAlert )

    local aTemp         := {}
    local aXMLDoc       := {}
    local cArqXML       := ''
    local cXMLOri       := ''
    local cErro         := ''
    local cDoc          := ''
    local cSerie        := ''
    local cNomFor       := ''

    default lAlert      := .T.

    private lShow       := lAlert
	private cCadastro 	:= 'Incluir Fornecedor'

    default cArquivo    := ''

    if !empty( cArquivo )

        aXMLDoc := f001( cArquivo )

        if len( aXMLDoc ) > 0 

            cArqXML := aXMLDoc[02]
            cXMLOri := aXMLDoc[04]
            cErro   := aXMLDoc[07]
            cDoc    := aXMLDoc[11]
            cSerie  := aXMLDoc[13]
            cNomFor := aXMLDoc[12]

            aTemp := f002( cXMLOri )

            if len( aTemp ) > 0 
                f003( aTemp )
            endIf

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
static function f001( cArquivo )

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
{Protheus.doc} f002
@description	rotina para busca dos dados do xml
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		05/05/2023
**************************************************************************************************/
static function f002( cXMLOri )

    local cError        := ''
    local cWarning      := ''
    local oFullXML      := nil
    local oXML          := nil
    
    local oXMLProtNFe   := nil
    local lFound        := .F.

    local cNomeFor      := ''           // Nome Fornecedor
    local cNomFant      := ''           // Nome Fantasia
    local cIEM          := ''           // Inscricao Municipal
    local cInEst        := ''           // IE Substituo Tributario
    local cInsc         := ''           // Inscricao Estadual
    local cChvNfe       := ''           // Chave NFe
    local cCGC          := ''		    // CGC
    local cDoc          := ''		    // Numero do Documento
    local cSerie        := '' 		    // Serie
    local dEmis         := cToD('//')	// Data de Emissão
    local cEst          := ''	        // Estado de emissao da NF
    local cVersao       := ''			// Versão
    local cHrEmis       := ''           // Hora da Emissão
    local cCep          := ''           // CEP emitente
    local cCdMun        := ''           // Codigo Municipio Emitente
    local cCdPais       := ''           // Codigo Pais Emitente
    local cFone         := ''           // Telefone Emitente
    local cNro          := ''           // Numero do endereço do Emitente
    local cUF           := ''           // UF do endereço do Emitente
    local cBairro       := ''           // Bairro do endereço do Emitente
    local cEnd          := ''           // Endereço do Emitente
    local cMun          := ''           // Municipio do endereço do Emitente
    local cPais         := ''           // Pais do endereço do Emitente
    local aRet          := {}           
    local nX            := 0 
    local cXML          := ''

    Private oAuxXML       := nil

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

            if XmlChildEx(oAuxXml:_EMIT,"_IEST") # NIL
                cInEst := oAuxXml:_EMIT:_IEST:TEXT
            endIf

            if XmlChildEx(oAuxXml:_EMIT,"_XNOME") # NIL
                cNomeFor := oAuxXml:_EMIT:_XNOME:TEXT
            endIf

            if XmlChildEx(oAuxXml:_EMIT,"_XFANT") # NIL
                cNomFant := oAuxXml:_EMIT:_XFANT:TEXT
            endIf

            if XmlChildEx(oAuxXml:_EMIT,"_IM") # NIL
                cIEM := oAuxXml:_EMIT:_IM:TEXT
            endIf

            if XmlChildEx(oAuxXml:_EMIT,"_ENDEREMIT") # NIL
                cCep    := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_CEP')    =='U','',oAuxXml:_EMIT:_ENDEREMIT:_CEP:TEXT     ) 
                cCdMun  := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_CMUN')   =='U','',oAuxXml:_EMIT:_ENDEREMIT:_CMUN:TEXT    )
                cCdPais := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_CPAIS')  =='U','',oAuxXml:_EMIT:_ENDEREMIT:_CPAIS:TEXT   ) 
                cFone   := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_FONE')   =='U','',oAuxXml:_EMIT:_ENDEREMIT:_FONE:TEXT    )
                cNro    := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_NRO')    =='U','',oAuxXml:_EMIT:_ENDEREMIT:_NRO:TEXT     ) 
                cUF     := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_UF')     =='U','',oAuxXml:_EMIT:_ENDEREMIT:_UF:TEXT      ) 
                cBairro := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_XBAIRRO')=='U','',oAuxXml:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT ) 
                cEnd    := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_XLGR')   =='U','',oAuxXml:_EMIT:_ENDEREMIT:_XLGR:TEXT    ) 
                cMun    := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_XMUN')   =='U','',oAuxXml:_EMIT:_ENDEREMIT:_XMUN:TEXT    ) 
                cPais   := iif(Type('oAuxXml:_EMIT:_ENDEREMIT:_XPAIS')  =='U','',oAuxXml:_EMIT:_ENDEREMIT:_XPAIS:TEXT   )         
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

                Aviso(  'Atenção' ,;
                        'Fornecedor cadastrado'                         ;
                        + CRLF + 'Código: ' + alltrim(SA2->A2_COD)      ;
                        + CRLF + 'Loja..: ' + alltrim(SA2->A2_LOJA)     ;     
                        + CRLF + 'Nome..: ' + alltrim(SA2->A2_NOME)     ;
                        , {"OK"} ) 
            
            else


                aRet := {   cNomeFor    ,;
                            cNomFant    ,;
                            cCGC        ,;
                            cInsc       ,;
                            cIEM        ,;
                            cInEst      ,;
                            cCep        ,;
                            cCdMun      ,;
                            cCdPais     ,;
                            cFone       ,;
                            cNro        ,;
                            cUF         ,;
                            cBairro     ,;
                            cEnd        ,;
                            cMun        ,;
                            cPais       ,;
                            cEst         ; 
                        }

            endIf

            SA2->( dbCloseArea() )

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
static function f003( aFornece )

	local aRet := { .F. , '' , '' }

	processa({|| aRet := f004( aFornece ) } , "Processando...")

	if aRet[01]
		cCodPrd := aRet[02]
		cDesPrd := aRet[03]
	endIf

return aRet[01]
/**************************************************************************************************
{Protheus.doc} f004
@description	Rotina para inclusao do fornecedor
@type   		User Function 
@author			Ruann Carlos
@version   		1.00
@since     		10/07/2023
**************************************************************************************************/
static function f004( aFornece )

	local aArea        := GetArea()
	local cTitulo      := OemtoAnsi('Criação dos Fornecedores')
	local cPrograma    := 'MATA020M' 
	local aRet 		   := { .F. , '', '' }
    local lMvcMata020  := TableInDic( "G3Q", .F. )
    local cCContabil   := SuperGetMV("EC_FORXML",.F.,"")
    local lRet         := .F.

	dbSelectArea('SA2')
	SA2->( dbSetOrder(1) )

    if lMvcMata020

        oModel := FWLoadModel( cPrograma )
        oModel:SetOperation(3) 
        oModel:Activate() 

        oModel:SetValue( "SA2MASTER" , "A2_LOJA" 	    , iif( len(aFornece[03]) > 11, substr(aFornece[03],11,2), '  ' )         )

        if empty( oModel:getValue( "SA2MASTER" , "A2_CODPAIS" ) ) 
            oModel:SetValue( "SA2MASTER" , "A2_CODPAIS" 	    , '01058' )
        endIf
        
        oModel:SetValue( "SA2MASTER" , "A2_NOME"		, padr( aFornece[01], tamSx3('A2_NOME')[01]     ) )
        oModel:SetValue( "SA2MASTER" , "A2_NREDUZ"  	, padr( aFornece[02], tamSx3('A2_NREDUZ')[01]   ) )
        oModel:SetValue( "SA2MASTER" , "A2_CGC" 	    , padr( aFornece[03], tamSx3('A2_CGC')[01]      ) )
        
        oModel:SetValue( "SA2MASTER" , "A2_EST"     	, padr( aFornece[12], tamSx3('A2_EST')[01]      ) )
        oModel:SetValue( "SA2MASTER" , "A2_COD_MUN" 	, padr( substr(aFornece[08], 3) , tamSx3('A2_COD_MUN')[01]  ) )
        oModel:SetValue( "SA2MASTER" , "A2_MUN"     	, padr( aFornece[15], tamSx3('A2_MUN')[01]      ) )

        oModel:SetValue( "SA2MASTER" , "A2_INSCR" 	    , padr( aFornece[04], tamSx3('A2_INSCR')[01]    ) )
        oModel:SetValue( "SA2MASTER" , "A2_INSCRM" 	    , padr( aFornece[05], tamSx3('A2_INSCRM')[01]   ) )

        oModel:SetValue( "SA2MASTER" , "A2_BAIRRO" 	    , padr( aFornece[13], tamSx3('A2_BAIRRO')[01]   ) )
        oModel:SetValue( "SA2MASTER" , "A2_END" 		, padr( alltrim( aFornece[14] ) + ' ' + alltrim( aFornece[11] )  , tamSx3('A2_END')[01]      ) )
        oModel:SetValue( "SA2MASTER" , "A2_CEP"     	, padr( aFornece[07], tamSx3('A2_CEP')[01]      ) )
        oModel:SetValue( "SA2MASTER" , "A2_PAIS" 	    , padr( aFornece[09], tamSx3('A2_PAIS')[01]     ) )

        if len( aFornece[10] ) > 9 

            if substr(aFornece[10], 1, 1 ) == '0'
                oModel:SetValue( "SA2MASTER" , "A2_TEL" 	    , padr( substr(aFornece[10], 4    ), tamSx3('A2_TEL')[01]      ) )
                oModel:SetValue( "SA2MASTER" , "A2_DDD" 	    , padr( substr(aFornece[10], 1, 3 ), tamSx3('A2_DDD')[01]      ) )
            else
                oModel:SetValue( "SA2MASTER" , "A2_TEL" 	    , padr( substr(aFornece[10], 3    ), tamSx3('A2_TEL')[01]      ) )
                oModel:SetValue( "SA2MASTER" , "A2_DDD" 	    , padr( substr(aFornece[10], 1, 2 ), tamSx3('A2_DDD')[01]      ) )
            endIf

        else
            oModel:SetValue( "SA2MASTER" , "A2_TEL" 	    , padr( aFornece[10], tamSx3('A2_TEL')[01]      ) )
            oModel:SetValue( "SA2MASTER" , "A2_DDD" 	    , padr( ''          , tamSx3('A2_DDD')[01]      ) )
        endif

        oModel:SetValue( "SA2MASTER" , "A2_TIPO" 	    , iif( len(aFornece[03]) > 11, 'J', 'F' )         )

        if !empty( cCContabil )
            oModel:SetValue( "SA2MASTER" , "A2_CONTA" 	    , cCContabil       )
        endIf

        if lShow
            lRet := FWExecView( cTitulo , cPrograma, 3, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel ) == 0 
        else
            
            if (oModel:VldData())
                oModel:CommitData()
                conout('MCOM006 - Processamento do arquivo finalizado com sucesso. ')
                lRet := .T.
		    else
                cLog := oModel:GetErrorMessage()[3]
                cLog += '--' + oModel:GetErrorMessage()[5]
                cLog += '--' + oModel:GetErrorMessage()[6]
                cLog += '--' + oModel:GetErrorMessage()[7]
                AutoGRLog(cLog)
                conout('MCOM006 - Erro no processamento do arquivo: ' + cLog )
                lRet := .F.
            EndIf
		endIf

        oModel:DeActivate()
		oModel:Destroy()
		oModel := Nil

    endIf

	if lRet 
		aRet[01] := .T.
		aRet[02] := SA2->A2_COD + ' ' + SA2->A2_LOJA
		aRet[03] := SA2->A2_NOME
	endIf

	SA2->( dbCloseArea() )

	restArea( aArea )

return aRet
