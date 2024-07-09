#include 'totvs.ch'
#include 'topConn.ch'
/*/MT103FIM
Ponto de entrada ao final da NF de Entrada
gera comissão e incentivo negativos em caso de devolucao
@author Matheus Abrão
@since 01/02/2021
/*/
user function MT103FIM()
local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
local cNfOri    := ""
local cSerOri   := ""
local cItOri    := ""
local cProduto  := ""
//local cVend1    := ""
//local cVend2    := ""
//local cTes      := ""
//local lGerCom1  := .F. 
//local lGerCom2  := .F.
local nVlrCom1  := 0
local nVlrCom2  := 0
local nTotCom   := 0
local nIncentivo:= 0
local nTotInce  := 0
//local nTotInNF  := 0
//local aAuxInc   := {}
//local i
local cQry      := ""

local aAreaSD1  := SD1->(getArea())
local aAreaSD2  := SD2->(getArea())
local aAreaSF2  := SF2->(getArea())

if nConfirma == 1 .and. (nOpcao == 3 .OR.  nOpcao == 4)
    if SF1->F1_TIPO = "D"
        SD1->(dbSelectAre("SD1"))
        SD1->(dbSetOrder(1)) 

        if SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
            while SD1->(!Eof()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_DOC == SF1->F1_DOC
                if !Empty(SD1->D1_NFORI)
                    cNfOri    := SD1->D1_NFORI
                    cSerOri   := SD1->D1_SERIORI
                    cItOri    := Alltrim(SD1->D1_ITEMORI)
                    cProduto  := SD1->D1_COD

                    cQry := ""
                    cQry := retQryE3(cNfOri,cSerOri,cItOri)

                    TCQUERY cQry NEW ALIAS "qZZSE3"

                    while qZZSE3->(!eof())  
                        cVend       := qZZSE3->E3_VEND
                        nVlrCom     := 0
                        nVlrCom1    := 0
                        nVlrCom2    := 0
                        nTotCom     := 0
                        nIncentivo  := 0
                        nTotInce    := 0

                        nVlrCom     := SD1->D1_TOTAL * (qZZSE3->E3_PORC/100)

                        //Econsiste - StaticCall descontinuada versao 12.1.33 substituida pela funcao geraComis 
                        //StaticCall( M460FIM, geraComis,cVend,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,(SD1->D1_TOTAL*-1),qZZSE3->E3_PORC,SD1->D1_EMISSAO,SD1->D1_EMISSAO,"01",qZZSE3->E3_PEDIDO,qZZSE3->E3_ZZITPV,SD1->D1_COD,SD1->D1_ITEM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_UM,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri))
                        geraComis(cVend,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,(SD1->D1_TOTAL*-1),qZZSE3->E3_PORC,SD1->D1_EMISSAO,SD1->D1_EMISSAO,"01",qZZSE3->E3_PEDIDO,qZZSE3->E3_ZZITPV,SD1->D1_COD,SD1->D1_ITEM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_UM,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri))
                        
                        qZZSE3->(dbSkip())
                    end

                    qZZSE3->(dbCloseArea())

                    cQry := ""
                    cQry := retQryZZ2(cNfOri,cSerOri,cItOri,cProduto,SF1->F1_FORNECE , SF1->F1_LOJA)
                    TCQUERY cQry NEW ALIAS "qZZ2"

                    while qZZ2->(!eof()) 
                        nIncentivo  := 0
                        nTotInce    := 0

                        nIncentivo := qZZ2->ZZ2_VALINC
                        nTotInce   := SD1->D1_QUANT * nIncentivo
                        //Econsiste - StaticCall descontinuada no versao 12.1.33 e substituida pela funcao geraIncentivo 
                        //StaticCall( M460FIM, geraIncentivo,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,qZZ2->ZZ2_PEDIDO,qZZ2->ZZ2_ITEMPV,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_TOTAL,qZZ2->ZZ2_VENDED,nIncentivo*-1,nTotInce*-1,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri),"SIGACOM")
                        geraIncentivo(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,qZZ2->ZZ2_PEDIDO,qZZ2->ZZ2_ITEMPV,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_TOTAL,qZZ2->ZZ2_VENDED,nIncentivo*-1,nTotInce*-1,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri),"SIGACOM")

                        qZZ2->(dbSkip())
                    end

                    qZZ2->(dbCloseArea())


                    /*SF2->(dbSelectArea("SF2"))
                    SF2->(dbSetOrder(1)) 
                    if SF2->(dbSeek(xFilial("SF2") +cNfOri + cSerOri + SF1->F1_FORNECE + SF1->F1_LOJA))
                        if alltrim(SF2->F2_TIPO) == "N"
                            cVend1    := SF2->F2_VEND1
                            cVend2    := SF2->F2_VEND2

                            if !empty(cVend1)
                                lGerCom1  := posicione("SA3",1,xFilial("SA3") + cVend1,"A3_ZZGERCO") == "1" // Sim
                            endif

                            if !empty(cVend2)
                                lGerCom2  := posicione("SA3",1,xFilial("SA3") + cVend2,"A3_ZZGERCO") == "1" // Sim
                            endif

                            SD2->(Dbselectarea("SD2"))
                            SD2->(dbSetOrder(3))
                            if SD2->(Dbseek(xFilial("SD2")+cNfOri+cSerOri+SD1->D1_FORNECE+SD1->D1_LOJA+cProduto+Alltrim(cItOri))   )
                                cTes        := SD2->D2_TES
                                nVlrCom1    := 0
                                nVlrCom2    := 0
                                nTotCom     := 0
                                nIncentivo  := 0
                                nTotInce    := 0
                                if posicione("SF4",1,xFilial("SF4") + cTes ,"F4_DUPLIC") == "S"
                                    if lGerCom1
                                        nVlrCom1    := SD1->D1_TOTAL * (SD2->D2_COMIS1/100)
                                    endif
                                    if lGerCom2
                                        nVlrCom2    := SD1->D1_TOTAL * (SD2->D2_COMIS2/100)
                                    endif
                                    nTotCom     := nVlrCom1 + nVlrCom2

                                    nIncentivo := SD2->D2_ZZINCE
                                    nTotInce   := SD1->D1_QUANT * nIncentivo
                                    
                                    nTotInNF   += nTotInce

                                    //cChave := xFilial("SD2")+cNfOri+cSerOri+SD1->D1_FORNECE+SD1->D1_LOJA
                                    //nPos   := aScan( aAuxInc, { |x| AllTrim( x[1] ) == alltrim(cChave) } ) 
                                    //if nPos > 0
                                    //    aAuxInc[nPos,7] += nTotInce
                                    //else
                                    //    aadd(aAuxInc,{cChave,cNfOri,cSerOri,SD1->D1_FORNECE,SD1->D1_LOJA,cVend1,nTotInce})
                                    //endif

                                    SD1->(recLock("SD1",.F.))
                                        SD1->D1_ZZVRCO1 := nVlrCom1*-1
                                        SD1->D1_ZZVRCO2 := nVlrCom2*-1
                                        SD1->D1_ZZCOMIT := nTotCom*-1

                                        SD1->D1_ZZINCE  := nIncentivo*-1
                                        SD1->D1_ZZTINCE := nTotInce*-1
                                    SD1->(msUnlock())

                                    
                                    //retDaFuncStatic := StaticCall( xParam1, xParam2, xParam3, ..., ..., xParamN)

                                    //xParam1 := NomeDoPrograma (sem aspas), onde se encontra a Static Function
                                    //xParam2 := NomeDaStaticFunction (sem aspas), a ser executada
                                    //xParam3 := A partir desse espaço são definidos os parametros que são passados
                                    //para a Static Function que esta sendo invocada.

                                    if lGerCom1 .AND. nVlrCom1 <> 0
                                        //StaticCall( M460FIM, geraComis,cVend1,SF2->F2_DOC,SF2->F2_SERIE,dDatabase,SF2->F2_CLIENTE,SF2->F2_LOJA,(SD1->D1_TOTAL*-1),SD2->D2_COMIS1,dDatabase,dDatabase,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_ITEM,SD1->D1_QUANT,SD2->D2_PRCVEN,SD2->D2_UM)
                                        //geraComis(cVend1,SF2->F2_DOC,SF2->F2_SERIE,dDatabase,SF2->F2_CLIENTE,SF2->F2_LOJA,(SD2->D2_TOTAL*-1),SD2->D2_COMIS1,dDatabase,dDatabase,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_ITEM,SD1->D1_QUANT,SD2->D2_PRCVEN,SD2->D2_UM)
                                        StaticCall( M460FIM, geraComis,cVend1,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,(SD1->D1_TOTAL*-1),SD2->D2_COMIS1,SD1->D1_EMISSAO,SD1->D1_EMISSAO,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD1->D1_COD,SD1->D1_ITEM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_UM,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri))
                                    endif
                                    if lGerCom2 .AND. nVlrCom2 <> 0
                                        //StaticCall( M460FIM, geraComis,cVend2,SF2->F2_DOC,SF2->F2_SERIE,dDatabase,SF2->F2_CLIENTE,SF2->F2_LOJA,(SD1->D1_TOTAL*-1),SD2->D2_COMIS2,dDatabase,dDatabase,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_ITEM,SD1->D1_QUANT,SD2->D2_PRCVEN,SD2->D2_UM)
                                        //geraComis(cVend2,SF2->F2_DOC,SF2->F2_SERIE,dDatabase,SF2->F2_CLIENTE,SF2->F2_LOJA,(SD2->D2_TOTAL*-1),SD2->D2_COMIS2,dDatabase,dDatabase,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_ITEM,SD1->D1_QUANT,SD2->D2_PRCVEN,SD2->D2_UM)
                                        StaticCall( M460FIM, geraComis,cVend2,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,(SD1->D1_TOTAL*-1),SD2->D2_COMIS2,SD1->D1_EMISSAO,SD1->D1_EMISSAO,"01",SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD1->D1_COD,SD1->D1_ITEM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_UM,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri))
                                    endif

                                    StaticCall( M460FIM, geraIncentivo,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_ITEM,SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD1->D1_EMISSAO,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_VUNIT,cVend1,SD1->D1_ZZINCE,SD1->D1_ZZTINCE,"DEV NF " + alltrim(cNfOri) + "/" + alltrim(cSerOri) + " Item " + alltrim(cItOri),"SIGACOM")

                                endif
                            endif
                        endif
                    endif*/
                endif
                SD1->(dbSkip())
            end
        endif
        /*for i := 1 to len(aAuxInc)
            if aAuxInc[i,7] > 0
                StaticCall( M460FIM, geraIncentivo, aAuxInc[i,2],aAuxInc[i,3],dDatabase,aAuxInc[i,4],aAuxInc[i,5],aAuxInc[i,6],(aAuxInc[i,7]*-1))
                //geraIncentivo(aAuxInc[i,2],aAuxInc[i,3],dDatabase,aAuxInc[i,4],aAuxInc[i,5],aAuxInc[i,6],aAuxInc[i,7] )
            endif
        next*/
    endif
endif

//Funcao de alteracao do custo dos produtos impactados
if nConfirma == 1 .and. (nOpcao == 3 .OR.  nOpcao == 4)
    //Funcao de alteracao do custo dos produtos impactados
    AttCustoStd()
endif

restArea(aAreaSD1)
restArea(aAreaSD2)
restArea(aAreaSF2)

return

static function retQryZZ2(cNfOri,cSerOri,cItOri,cProduto,cCliente,cLoja)
local cRet      := ""

cRet      := "SELECT   "
cRet      += "    * "
cRet      += "FROM  "
cRet      += "    " + retSqlName("ZZ2") + " ZZ2 "
cRet      += "WHERE "
cRet      += "    ZZ2.ZZ2_FILIAL = '" + xFilial("ZZ2") + "' AND "
cRet      += "    ZZ2.ZZ2_DOC = '" + cNfOri + "' AND "
cRet      += "    ZZ2.ZZ2_SERIE = '" + cSerOri + "' AND "
cRet      += "    ZZ2.ZZ2_ITEMNF = '" + cItOri + "' AND "
cRet      += "    ZZ2.ZZ2_CLIENT = '" + cCliente + "' AND "
cRet      += "    ZZ2.ZZ2_LOJACL = '" + cLoja + "' AND "
cRet      += "    ZZ2.ZZ2_ZZORIG = 'SIGAFAT' AND "
cRet      += "    ZZ2.D_E_L_E_T_ = '' "
return cRet


static function retQryE3(cNfOri,cSerOri,cItOri)
local cRet      := ""

cRet      := "SELECT   "
cRet      += "    * "
cRet      += "FROM  "
cRet      += "    " + retSqlName("SE3") + " SE3 "
cRet      += "WHERE "
cRet      += "    SE3.E3_FILIAL = '" + xFilial("SE3") + "' AND "
cRet      += "    SE3.E3_NUM = '" + cNfOri + "' AND "
cRet      += "    SE3.E3_SERIE = '" + cSerOri + "' AND "
cRet      += "    SE3.E3_ZZITNF = '" + cItOri + "' AND "
cRet      += "    SE3.D_E_L_E_T_ = '' "

return cRet

/*
Função: geraComis
*/

static function geraComis(cVendedor,cDoc,cSerie,dData,cCliente,cLoja,nTotal,nPComis,dDtPgto,dDtVcto,cMoeda,cPedido,cItemPV,cProduto,cItemNf,nQuant,nPrcVen,cUM,cObs)

local a490Auto  := {}
local cDescPrd  := posicione("SB1",1,xFilial("SB1") + cProduto,"B1_DESC")
local cNomeVend := posicione("SA3",1,xFilial("SA3") + cVendedor,"A3_NOME")
local cNomeCLi  := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_NOME")
local cNRedCli  := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_NREDUZ")
local cCidade   := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_MUN")
local cErro     := ""
local cMsg      := ""
lMsErroAuto     := .F.

aAdd(a490Auto,{"E3_VEND"   ,cVendedor ,Nil})
aAdd(a490Auto,{"E3_NUM"    ,cDoc ,Nil})
aAdd(a490Auto,{"E3_EMISSAO",dData ,Nil})
aAdd(a490Auto,{"E3_SERIE"  ,cSerie ,Nil})
aAdd(a490Auto,{"E3_CODCLI" ,cCliente ,Nil})
aAdd(a490Auto,{"E3_LOJA"   ,cLoja ,Nil})
aAdd(a490Auto,{"E3_BASE"   ,nTotal ,Nil})
aAdd(a490Auto,{"E3_PORC"   ,nPComis ,Nil})
//////aAdd(a490Auto,{"E3_DATA"   ,dDtPgto ,Nil})
//aAdd(a490Auto,{"E3_PREFIXO" ,"001" ,Nil})
//aAdd(a490Auto,{"E3_PARCELA" ,"1" ,Nil})
//aAdd(a490Auto,{"E3_SEQ" ,"  " ,Nil})
//aAdd(a490Auto,{"E3_TIPO" ,"DH" ,Nil})
aAdd(a490Auto,{"E3_PEDIDO" ,cPedido ,Nil})
aAdd(a490Auto,{"E3_VENCTO" ,dDtVcto ,Nil})
//aAdd(a490Auto,{"E3_PROCCOM" ,"INCLUSAO" ,Nil})
aAdd(a490Auto,{"E3_MOEDA"  ,cMoeda ,Nil})
aAdd(a490Auto,{"E3_ZZITPV" ,cItemPV ,Nil})
aAdd(a490Auto,{"E3_ZZPRODU",cProduto ,Nil})
aAdd(a490Auto,{"E3_ZZDESPR",cDescPrd ,Nil})
aAdd(a490Auto,{"E3_ZZITNF" ,cItemNf ,Nil})
aAdd(a490Auto,{"E3_ZZQUANT",nQuant ,Nil})
aAdd(a490Auto,{"E3_ZZPRCVE",nPrcVen ,Nil})
aAdd(a490Auto,{"E3_ZZUM"   ,cUM ,Nil})
aAdd(a490Auto,{"E3_ZZVEND" ,cNomeVend ,Nil})
aAdd(a490Auto,{"E3_ZZNCLI" ,cNomeCLi ,Nil})
aAdd(a490Auto,{"E3_ZZNRCLI" ,cNRedCli ,Nil})
aAdd(a490Auto,{"E3_ZZCIDA" ,cCidade ,Nil})
aAdd(a490Auto,{"E3_ZZOBS" ,cObs ,Nil})

MSExecAuto({|x,y| Mata490(x,y)},a490Auto,3) //Inclusao

if lMsErroAuto
    Conout("Erro geração de Comissão [M460FIM].")
    cErro := mostraErro("\system\","erro_M460FIM_Mata490_"+dtos(dDataBase)+"_"+StrTran(time(),":","")+".txt")
    cMsg  := "Erro na gravação da comissão:" + CRLF
    cMsg  += "Vendedor: " + cVendedor + " - " + alltrim(posicione("SA3",1,xFilial("SA3") + cVendedor,"A3_NOME")) + CRLF
    cMsg  += "Nota Fiscal: " + cDoc + " / " + cSerie + CRLF
    cMsg  += "Item Nota Fiscal: " + cItemNf + CRLF
    cMsg  += "Pedido: " + cPedido + CRLF
    cMsg  += "Item Pedido: " + cItemPV + CRLF
    cMsg  += "Produto: " + cProduto + " - " + alltrim(cDescPrd) + CRLF
    cMsg  += "Erro: " + CRLF
    cMsg  += cErro

    Aviso("Comissão",cMsg,{"Fechar"},3) 

else
    Conout("Executado com sucesso.")
endif

return

/*
Funcao: geraIncentivo
*/

static function geraIncentivo(cDoc,cSerie,cItemNf,cPedido,cItemPV,dData,cCliente,cLoja,cProduto,nQuant,cVlrUnit,nVlrTotal,cVendedor,nIncUnit,nTotInc,cObs,cOrigem)

local cNomeCLi  := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_NOME")
local cNRedCli  := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_NREDUZ")
local cCidade   := posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_MUN")
local cNomeVend := posicione("SA3",1,xFilial("SA3") + cVendedor,"A3_NOME")
local cDescPrd  := posicione("SB1",1,xFilial("SB1") + cProduto,"B1_DESC")

ZZ2->(dbSelectArea("ZZ2"))
ZZ2->(dbSetOrder(1))
ZZ2->(recLock("ZZ2",.T.))
    ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
    ZZ2->ZZ2_DOC    := cDoc
    ZZ2->ZZ2_SERIE  := cSerie
    ZZ2->ZZ2_ITEMNF := cItemNf
    ZZ2->ZZ2_PEDIDO := cPedido
    ZZ2->ZZ2_ITEMPV := cItemPV
    ZZ2->ZZ2_DATA   := dData
    ZZ2->ZZ2_CLIENT := cCliente
    ZZ2->ZZ2_LOJACL := cLoja
    ZZ2->ZZ2_NOMECL := cNomeCLi
    ZZ2->ZZ2_NREDUZ := cNRedCli
    ZZ2->ZZ2_CIDADE := cCidade
    ZZ2->ZZ2_PRODUT := cProduto
    ZZ2->ZZ2_DESCPR := cDescPrd
    ZZ2->ZZ2_QUANT  := nQuant
    ZZ2->ZZ2_PRECO  := cVlrUnit
    ZZ2->ZZ2_PRCTOT := nVlrTotal
    ZZ2->ZZ2_VENDED := cVendedor
    ZZ2->ZZ2_NOMVEN := cNomeVend
    ZZ2->ZZ2_VALINC := nIncUnit
    ZZ2->ZZ2_TOTINC := nTotInc
    ZZ2->ZZ2_ZZOBS  := cObs
    ZZ2->ZZ2_ZZORIG := cOrigem 
ZZ2->(msUnlock())

return

/*
Static Function AttCustoStd()
    // Preparação de variáveis
    local aAreaSD1  := SD1->(getArea())
    local aAreaSF4  := SF4->(getArea())

    //Selecionar a área SD1 (Itens NF) e ordenar pelo indice 1
    SD1->(dbSelectAre("SD1"))
    SD1->(dbSetOrder(1)) 

    //Selecionar a área SF4 (Registro Tes) e ordenar pelo indice 1
    SF4->(dbSelectAre("SF4"))
    SF4->(dbSetOrder(1))

    //Se o registro existe
    if SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
        //Enquanto existir registros itens das NF e os campos forem iguais ao registro do Cabeçalho da NF
        while SD1->(!Eof()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
         SD1->D1_LOJA == SF1->F1_LOJA .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_DOC == SF1->F1_DOC
            //Se Registro possue TES
            If !Empty(SD1->D1_TES)
                //Procura a TES do produto
                If SF4->(dbseek(xFilial("SF4") + SD1->D1_TES))
                    //Se Campo "F4_UPRC" da TES do produto é = S 
                    If SF4->F4_UPRC != "N" 
                        //Rodar Mata320 -> "Ult Prec Compra" para atualizar o custo do produto
                        MATA320("Ult Prec Compra", SD1->D1_COD)
                        //Chamar Função recursiva para Verificar se produto pertence a alguma estrutura
                        RecAttCust(SD1->D1_COD)
                    Endif
                Endif
            Endif
        end
    Endif
    
    //Restaurar as áreas
    restArea(aAreaSD1)
    restArea(aAreaSF4)
    restArea(aAreaSG1)
return

Static Function RecAttCust(cProduto)

    // Preparação de variáveis      
    //local aAreaSB1  := SB1->(getArea())
    local aAreaSG1  := SG1->(getArea())
    local cFiltro   := "SG1_COMP == '" + cProduto + "'"

    //Selecionar a área SB1 (Produto) e ordenar pelo indice 1 
    //SB1->(dbSelectAre("SB1")) // Selecionar a área SB1 (Produto)
    //SB1->(dbSetOrder(1)) // Ordenar por código do produto
    //SB1->(DbGoTop())

    //Selecionar a área SG1 (Registro Estrutura) e ordenar pelo indice 1 
    SG1->(dbSelectAre("SG1")) // Selecionar a área SG1 (Registro Estrutura)
    SG1->(dbSetOrder(2)) // Ordenar por código da estrutura e código do componente(Produto)
    SG1->(DbSetFilter({|| &(cFiltro)}, cFiltro)) // Filtrar por código do componente(Produto)
    SG1->(DbGoTop())

    //Enquanto existir registros de estrutura e o campo "SG1_COMP" for igual ao código do produto
    While !SG1->(Eof()) .AND. SG1->SG1_COMP == cProduto
        //Rodar Mata320 -> "Ult Cust Compra" para a estrutura na SG1
        MATA320("Ult Cust Compra", SG1->SG1_COD)
        //Chamar Função recursiva para Verificação de estrutura
        RecAttCust(SG1->SG1_COD)
        SG1->(dbSkip())
    End
    //restArea(aAreaSB1)
    restArea(aAreaSG1)
return 
*/

Static Function AttCustoStd()
    // Preparação de variáveis
    local aAreaSD1  := SD1->(getArea())
    local aAreaSF4  := SF4->(getArea())
    // local aAreaSF4  := S->(getArea())
    local lExecuta := .f.
    PRIVATE nTotRegs:=0 //Variaveis da rotina

    //Selecionar a área SD1 (Itens NF) e ordenar pelo indice 1
    SD1->(dbSelectAre("SD1"))
    SD1->(dbSetOrder(1)) 

    //Selecionar a área SF4 (Registro Tes) e ordenar pelo indice 1
    SF4->(dbSelectAre("SF4"))
    SF4->(dbSetOrder(1))

    //Se o registro existe
    if SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
        //Enquanto existir registros itens das NF e os campos forem iguais ao registro do Cabeçalho da NF
        while SD1->(!Eof()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .AND.;
         SD1->D1_LOJA == SF1->F1_LOJA .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_DOC == SF1->F1_DOC
            //Se Registro possue TES
            If !Empty(SD1->D1_TES)
                //Procura a TES do produto
                If SF4->(dbseek(xFilial("SF4") + SD1->D1_TES))
                    //Se Campo "F4_UPRC" da TES do produto é = S 
                    If SF4->F4_UPRC != "N" 
                        lExecuta := .t.
                        exit
                    Endif
                Endif
            Endif
        end
    Endif

    if lExecuta
        pergunte("MTA320",.F.)
        nBkpMv01 := MV_PAR01
        nBkpMv03 := MV_PAR03
        nBkpMv06 := MV_PAR06
        nBkpMv07 := MV_PAR07
        nBkpMv08 := MV_PAR08
        nBkpMv09 := MV_PAR09
        // MV_PAR03 := //Cacular custo por: 1-Ultimo preço compra;2=Estrutura;3=Ultimo custo de compra
        SetMVValue("MTA320","MV_PAR01",1, .T.)
        SetMVValue("MTA320","MV_PAR03",3, .T.)
        SetMVValue("MTA320","MV_PAR06",space(tamsx3("B1_TIPO")[1]), .T.) //Tipo de ?
        SetMVValue("MTA320","MV_PAR07",PadL('',tamsx3("B1_TIPO")[1],"Z"), .T.) //Tipo Ate ?
        SetMVValue("MTA320","MV_PAR08",space(tamsx3("B1_GRUPO")[1]), .T.) //Grupo Ate ?
        SetMVValue("MTA320","MV_PAR09",PadL('',tamsx3("B1_GRUPO")[1],"Z"), .T.) //Grupo Ate ?
        cCB := "StaticCall(MATA320,MA320Process,.f.,Nil)"

        // Processa({|lEnd| MA320Process(@lEnd)},"Custo de reposição","Calculando custo de reposição",.F.) //"Custo de Reposi‡„o"###"Calculando Custo de Reposi‡„o..."
        Processa({|lEnd| &cCB},"Custo de reposição","Calculando custo de reposição",.F.) //"Custo de Reposi‡„o"###"Calculando Custo de Reposi‡„o..."

        // Atuzaliando o custo dos produtos por estrutura
        SetMVValue("MTA320","MV_PAR01",1, .T.)
        SetMVValue("MTA320","MV_PAR03",2, .T.)
        SetMVValue("MTA320","MV_PAR06",space(tamsx3("B1_TIPO")[1]), .T.) //Tipo de ?
        SetMVValue("MTA320","MV_PAR07",PadL('',tamsx3("B1_TIPO")[1],"Z"), .T.) //Tipo Ate ?
        SetMVValue("MTA320","MV_PAR08",space(tamsx3("B1_GRUPO")[1]), .T.) //Grupo Ate ?
        SetMVValue("MTA320","MV_PAR09",PadL('',tamsx3("B1_GRUPO")[1],"Z"), .T.) //Grupo Ate ?
        

        Processa({|lEnd| &cCB},"Custo de reposição","Calculando custo de reposição da estrutura",.F.) //"Custo de Reposi‡„o"###"Calculando Custo de Reposi‡„o..."
        // Processa({|lEnd| MA320Process(@lEnd)},"Custo de reposição","Calculando custo de reposição da estrutura",.F.) //"Custo de Reposi‡„o"###"Calculando Custo de Reposi‡„o..."

        Pergunte("MTA320",.F.)
        SetMVValue("MTA320","MV_PAR01",nBkpMv01, .T.)
        SetMVValue("MTA320","MV_PAR03",nBkpMv03, .T.)
        SetMVValue("MTA320","MV_PAR06",nBkpMv06, .T.)
        SetMVValue("MTA320","MV_PAR07",nBkpMv07, .T.)
        SetMVValue("MTA320","MV_PAR08",nBkpMv08, .T.)
        SetMVValue("MTA320","MV_PAR09",nBkpMv09, .T.)
    endif

    
    //Restaurar as áreas
    restArea(aAreaSD1)
    restArea(aAreaSF4)
    // restArea(aAreaSG1)
return
