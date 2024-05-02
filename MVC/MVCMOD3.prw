#Include "TOTVS.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} MVCMOD3
********************MVCSZ3MODELO3************************
/*/
User Function MVCMOD3()
	Local aArea := GetArea()
	Local oBrowse
	oBrowse:= FwmBrowse():New()
	oBrowse:SetAlias("SZ3")
	oBrowse:SetDescription("Cadastro de Turmas X Alunos")
	oBrowse:AddLegend("SZ3->Z3_MSBLQL =='1'","RED","Ativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 1
	oBrowse:AddLegend("SZ3->Z3_MSBLQL =='2'","GREEN","Inativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 0
	oBrowse:Activate()
	RestArea(aArea)

Return

/*/{Protheus.doc} ModelDef
********************MVCSZ3MODELO3************************
/*/
Static Function ModelDef()
	Local oModel :=  Nil
	
	Local oStPaiZ3 := FWFormStruct(1,"SZ3")
	Local oStFilhoZ4 := FWFormStruct(1,"SZ4")
	oModel := MPFormModel():New("MVCMOD3M" ,,,,) /* MPFORMMODEL():New(< cID >, < bPre >, < bPost >, < bCommit >, < bCancel >)-> NIL */
	oStFilhoZ4:SetProperty("Z4_CODT",MODEL_FIELD_OBRIGAT,.F.)
	oModel:AddFields("SZ3MASTER",,oStPaiZ3)
	oModel:AddGrid("SZ4DETAIL","SZ3MASTER",oStFilhoZ4)
	oModel:SetRelation("SZ4DETAIL",{{"Z4_FILIAL","xFilial('SZ3')"},{"Z4_CODT","Z3_COD"}})// Grid que Relaciona
	oModel:SetPrimaryKey({"Z4_FILIAL","Z4_CODT","Z4_CODA"})//Chave primária
	oModel:GetModel("SZ4DETAIL"):SetUniqueLine({"Z4_CODT","Z4_CODA","Z4_CODL"})//Combinação de campos que nao podem se repetir
	oModel:SetDescription("Modelo 3 - Turma X Aluno") //Atribuindo a descrição ao modelo de dados
	oModel:GetModel("SZ4DETAIL"):SetDescription("Alunos") //Atribuindo a descrição ao modelo de dados
	oModel:GetModel("SZ3MASTER"):SetDescription("Cabecalho") //Atribuindo a descrição ao modelo de dados

Return oModel

/*/{Protheus.doc} ViewDef
********************MVCSZ3MODELO3************************
/*/
Static Function ViewDef()

	Local oView := Nil
	Local oModel := FWLoadModel("MVCMOD3")
	Local oStPaiZ3 := FWFormStruct(2,"SZ3")
	Local oStFilhoZ4 := FWFormStruct(2,"SZ4")
	oStFilhoZ4:RemoveField("Z4_CODT")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewZ3",oStPaiZ3,"SZ3MASTER")
	oView:AddGrid("ViewZ4",oStFilhoZ4,"SZ4DETAIL")
	// Criando os Box
	oView:CreateHorizontalBox("CABEC",60)
	oView:CreateHorizontalBox("GRID",40)
	oView:SetCloseOnOk({||.T.})//Fecha a tela ao clicar no botão OK
	//Amarro os campos ao Box
	oView:SetOwnerView("ViewZ3","CABEC")
	oView:SetOwnerView("ViewZ4","GRID")
	oView:EnableTitleView("ViewZ3","Turma")
	oView:EnableTitleView("ViewZ4","Aluno")

Return  oView

/*/{Protheus.doc} MenuDef
********************MenuDef************************
/*/
Static Function MenuDef()
	local aRotina     := FWMVCMenu("MVCMOD3")
	ADD OPTION aRotina TITLE 'Imprimir Dados da Turma'         ACTION 'u_RELAT(1)'   OPERATION 6  ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Dados da Turma'         ACTION 'u_RELAT(2)'   OPERATION 6  ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Dados da Turma'         ACTION 'u_RELAT(3)'   OPERATION 6  ACCESS 0


Return aRotina

/*/{Protheus.doc} RELAT
********************u_RELAT************************
/*/
User Function RELAT()
    private oReport
    private cPerg := "Imprimir Dados da Turma "
    Pergunte(cPerg,.T.)
	ReportDef()
	oReport:PrintDialog()
Return


