#Include "TOTVS.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc}MVCSZ3
********************MVCSZ3************************
/*/
User Function MVCSZ3()
	Local aArea := GetArea()
	Local oBrowseSA1

	oBrowseSA1 := FwmBrowse():New() //Cria uma nova instância da classe FwmBrowse

	oBrowseSA1:SetAlias("SZ3") //Passo como parametro a tabela que eu quero mostrar no Browse

	oBrowseSA1:SetDescription("Turmas") //Passo como parametro o nome da tabela

	oBrowseSA1:SetOnlyFields({"Z3_COD","Z3_MODALID","Z3_INSTRUT","Z3_HR",}) //Passo como parametro os campos que eu quero mostrar no Browse

	oBrowseSA1:AddLegend("SZ3->Z3_MSBLQL =='1'","RED","Ativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 1
	oBrowseSA1:AddLegend("SZ3->Z3_MSBLQL =='2'","GREEN","Inativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 0
	//Z3_MSBLQL

	oBrowseSA1:Activate()

	RestArea(aArea)
Return


/*/{Protheus.doc} ModelDef
********************ModelDef************************
/*/

Static Function ModelDef()

	Local oModel :=  Nil

	Local bVldPos       := {|| u_VldSZ3()}

	Local oStructSZ3 := FWFormStruct(1,"SZ3")//Cria uma nova instância da classe FwmBrowse trazendo as caracteristicas dos campos para o modelo (1-Model 2-View)

	oModel := MPFormModel():New("MVCSZ3M",/*VLDpre*/,bVldPos)// Cria uma nova instância da classe MPFormModel e passa como parametro o nome do modelo


	oModel:AddFields("FORMSZ3",,oStructSZ3) //Atribuindo formulario ao modelo de dados

	oModel:SetPrimaryKey({"Z3_FILIAL","Z3_COD"}) //Atribuindo aS chaveS primáriaS ao modelo de dados

	oModel:SetDescription("Cadastro de Turmas") //Atribuindo a descrição ao modelo de dados

	oModel:GetModel("FORMSZ3"):SetDescription("Formulario de Cadastro de turmas") //Atribuindo a descrição aos campos do modelo de dados

Return oModel


/*/{Protheus.doc} ViewDef
********************ViewDef************************
/*/
Static Function ViewDef()
	Local oView := Nil
//Função que retorna um objeto de Model de um Determinado Fonte 
	Local oModel :=FWLoadModel("MVCSZ3")

	Local oStructSZ3 := FWFormStruct(2,"SZ3")//Cria uma nova instância da classe FwmBrowse trazendo as caracteristicas dos campos para o modelo (1-Model 2-View)

	oView := FWFormView():New()// Cria uma nova instância da classe MPFormModel e passa como parametro o nome do modelo

	oView:SetModel(oModel)

	oView:AddField("VIEWSZ3",oStructSZ3,"FORMSZ3") //Atribuindo formulario ao modelo de dados

	oView:CreateHorizontalBox("TELASZ3",100)//Cria um container 'Tela' com 100% de largura

	oView:EnableTitleView("VIEWSZ3","Turmas")//Habilita o titulo da tela

	oView:SetCloseOnOk({||.T.})//Fecha a tela ao clicar no botão OK

	oView:SetOwnerView("VIEWSZ3","TELASZ3")//Atribui a tela ao modelo


Return oView



/*/{Protheus.doc} MenuDef
********************MenuDef************************
/*/
Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu("MVCSZ3")// cria o Menu

Return aRotina



/*/{Protheus.doc} VldSZ3
********************Validaçoes************************
/*/
User Function VldSZ3()

	Local lRet := .T. //Retorno da Função True se o codigo não estiver presente na tabela
	Local aArea :=GetArea()

	Local oModel := FwModelActive()
	Local SZ3Filial := oModel:GetValue("FORMSZ3","Z3_FILIAL")
	Local SZ3Cod := oModel:GetValue("FORMSZ3","Z3_COD")
	Local cOption := oModel:GetOperation()


	IF cOption == MODEL_OPERATION_INSERT
		DBSelectArea("SZ3")
		SZ3->(DBSetOrder(1))

		//Verifica se o registro existe
		IF SZ3 ->(DBSeek(SZ3Filial+SZ3Cod))

			Help(NIL, NIL, "Escolha outro Codigo", NIL, "Este Codigo já existe em nosso sistema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"ATENÇÃO"})
			lRet := .F.

		ENDIF

	ELSEIF cOption == MODEL_OPERATION_UPDATE
		DBSelectArea("SZ3")
		SZ3->(DBSetOrder(1))

		//Verifica se o registro existe
		IF SZ3 ->(DBSeek(SZ3Filial+SZ3Cod))

			Help(NIL, NIL, "Escolha outro Codigo", NIL, "Este Codigo já existe em nosso sistema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"ATENÇÃO"})
			lRet := .F.

		ENDIF

	ENDIF

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} Vld24h
/*/
User Function Vld24h(x)
	Local lRet := .T. // Retorno da Função: True se o horário estiver correto
	Local aArea := GetArea()

	// Captura o valor do campo Z3_HR
	Local SZ3Hr := x
	Local nHoras := SubStr(SZ3Hr, 1, 2)
	Local nMinutos := SubStr(SZ3Hr, 4, 2)



	Local nValor1 := GetDToVal(nHoras)
	Local nValor2 := GetDToVal(nMinutos)

	IF nValor2 > 59 .or. nValor1 > 23
		FWAlertInfo("horario invalido!", "Exemplo mToH")
		lRet := .F.
	ENDIF
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} VldEnd
/*/
User Function VldEnd(x,y)
	Local lRet := .T. // Retorno da Função: True se o horário estiver correto
	Local aArea := GetArea()

	// Captura o valor do campo Z3_HR
	Local SZ3Hr := x
	Local nHoras1 := SubStr(SZ3Hr, 1, 2)
	Local nMinutos1 := SubStr(SZ3Hr, 4, 2)
	Local SZ3Hr2 := y
	Local nHoras2 := SubStr(SZ3Hr2, 1, 2)
	Local nMinutos2 := SubStr(SZ3Hr2, 4, 2)
	Local Tot1 := 0
	Local Tot2 := 0


	Local nValor1 := GetDToVal(nHoras1)
	Local nValor2 := GetDToVal(nMinutos1)
	Tot1 := (nValor1 * 60) + nValor2

	Local nValor3 := GetDToVal(nHoras2)
	Local nValor4 := GetDToVal(nMinutos2)
	Tot2 := (nValor3 * 60) + nValor4

	IF nValor2 > 59 .or. nValor1 > 23
		FWAlertInfo("horario invalido!", "Exemplo mToH")
		lRet := .F.
	ENDIF


	IF Tot1 < Tot2 .or.Tot1 == Tot2
		FWAlertInfo("Horario de termino menor que o horário de inicio", "Exemplo mToH")
		lRet := .F.
	ENDIF


	RestArea(aArea)

Return lRet



/*/{Protheus.doc} BusPos
/*/
User Function BusPos(chave)
	Local aArea      := FWGetArea()
	Local aCampos    := ("A2_NOME")
	Local aBusca     := {}
	Local cChavePesq := FWxFilial("SA2") + AsString(chave) 
	Local aDefault   := ("")

	//Realiza a busca na tabela conforme a chave passada
	aBusca := GetAdvFVal("SA2", aCampos, cChavePesq, 1, aDefault)

	FWRestArea(aArea)
Return aBusca

/*/{Protheus.doc} vldDisp
/*/
User Function vldDisp(inicio, fim, CodINSTR)
	Local Lret := .T.
    Local cQuery := FGetQuery(CodINSTR)
    Local cAlias := GetNextAlias()


    Local MintotIni := ((GetDToVal(SubStr(inicio, 1, 2))) * 60) + (GetDToVal(SubStr(inicio, 4, 2)))
    Local MintotFim := ((GetDToVal(SubStr(fim, 1, 2))) * 60) + (GetDToVal(SubStr(fim, 4, 2)))

    MpSysOpenQuery(cQuery, cAlias)

    (cAlias)->(DBGoTop())

    While !(cAlias)->(Eof())
        // Verifica se o horário está ocupado
        IF (MintotIni >= ((GetDToVal(SubStr((cAlias)->z3_hr, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hr, 4, 2)))) .AND. (MintotIni < ((GetDToVal(SubStr((cAlias)->z3_hrend, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hrend, 4, 2))))
            MsgInfo("Horário Ocupado Escolha outro Instrutor")
			Lret := .F.
            Return lRet
        EndIf

        IF (MintotFim > ((GetDToVal(SubStr((cAlias)->z3_hr, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hr, 4, 2)))) .AND. (MintotFim <= ((GetDToVal(SubStr((cAlias)->z3_hrend, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hrend, 4, 2))))
            MsgInfo("Horário Ocupado Escolha outro Instrutor")
			Lret := .F.
            Return lRet
        EndIf

        IF (MintotIni <= ((GetDToVal(SubStr((cAlias)->z3_hr, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hr, 4, 2)))) .AND. (MintotFim >= ((GetDToVal(SubStr((cAlias)->z3_hrend, 1, 2))) * 60) + (GetDToVal(SubStr((cAlias)->z3_hrend, 4, 2))))
            MsgInfo("Horário Ocupado Escolha outro Instrutor")
			Lret := .F.
            Return lRet
        EndIf

        (cAlias)->(DBSkip())
    End
    // Se o loop terminar sem retornar, o horário está disponível
    MsgInfo("Horário Disponível")

Return Lret 

/*/{Protheus.doc} FGetQuery
/*/
Static Function FGetQuery(CodINSTR)
    Local cQuery := ""

    cQuery  :=  'SELECT z3_hr, z3_hrend '
    cQuery  +=  'FROM sz3990 '
    cQuery  +=  "WHERE Z3_INSTRUT = '" + CodINSTR +  "' "
    cQuery  +=  "AND D_E_L_E_T_ = '' "

Return (cQuery)


