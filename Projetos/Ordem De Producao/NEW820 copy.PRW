#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.ch"


User Function NEW820()

Local cQuery
Local cAlias := 'TBLTEM'

MATR820()



pergunte("MTR820",.F.)


    cQuery = GetOP(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR08,MV_PAR10)

	MpSysOpenQuery(cQuery,cAlias)
    UsrRetName(RetCodUsr())

    While (cAlias)->(!EOF())
		dbselectarea("SC2")
		SC2->(MsSeek(FWxFilial("SC2") + (cAlias)->(C2_NUM)+(cAlias)->(C2_ITEM)+(cAlias)->(C2_SEQUEN)+(cAlias)->(C2_ITEMGRD))) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
		Reclock("SC2",.F.)
        IF Empty(SC2->C2_NUMIMP)
            SC2->C2_NUMIMP := 1
            SC2->C2_USR := UsrRetName(RetCodUsr())
        ELSE 
            SC2->C2_NUMIMP := (SC2->C2_NUMIMP) + 1
            SC2->C2_USR := (SC2->C2_USR) + " /" + UsrRetName(RetCodUsr())
        ENDIF
		SC2->(MSuNLOCK())
		(cAlias)->(dbskip())
	End *




Return 

    // Variaveis utilizadas para parametros                       
        //mv_par01            // Da OP                               
        //mv_par02            // Ate a OP                            
        //mv_par03            // Da data                             
       // mv_par04            // Ate a data                                     
       // mv_par08            // Imprime Op Encerrada                              
        ///mv_par10            // Impr. OP's Firmes, Previstas ou Amba


Static function GetOP(OPde,OPate,DataDe,DataAte,Encerrada,Tipo)
Local cQuery := ""

//converte data para PADROES SQL
DataDe := DTOS(DataDe)
DataAte := DTOS(DataAte)


cQuery += "SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_ITEMGRD FROM  " + RetSqlName("SC2") + " "
cQuery += "WHERE C2_NUM  BETWEEN  '" +OPde + "' AND '" + OPate + "' "
cQuery += "AND C2_DATPRF BETWEEN '" + DataDe + "' AND '" + DataAte + "' "

    IF Encerrada == 2
    cQuery += "AND C2_DATPRF = ' ' "
    ENDIF
    IF Tipo <> 3
        IF Tipo == 1
        cQuery += "AND C2_TPOP = 'F' "
        ENDIF
        IF Tipo == 2
        cQuery += "AND C2_TPOP = 'P' "
        ENDIF
    ENDIF

cQuery +=  "AND C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery += "AND D_E_L_E_T_ = ' ' "
Return  cQuery
