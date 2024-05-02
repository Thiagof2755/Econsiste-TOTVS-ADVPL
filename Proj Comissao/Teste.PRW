//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "COMISSÃO"

/*/{Protheus.doc} zModel3
/*/

User Function zModel3()
	Local aArea   := GetArea()
	Local oBrowse
	oBrowse := FWMBrowse():New()//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse:SetAlias("SZ9") //Selecionar a tabela
	oBrowse:SetDescription(cTitulo)//Setando a descrição da rotina
	oBrowse:Activate()//Ativa a Browse
	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor:THIAGO                                              |
| Data:  29/04/2024                                                 |
| Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

/*/{Protheus.doc} MenuDef
********************MenuDef************************
/*/
Static Function MenuDef()
	local aRotina     := FWMVCMenu("MVCPERC")
Return aRotina
/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor:THIAGO                                              |
| Data:  29/04/2024                                                 |
| Desc:  Criação do MODEL MVC                                          |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'SZ9')
	Local oStFilho 	:= FWFormStruct(1, 'SZ8')
	Local tRelac		:= {}
		
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MVCPERCC')
	oModel:AddFields('SZ9MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('SZ8DETAIL','SZ9MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(tRelac, {'SZ9_FILIAL','SZ8_FILIAL'} )
	aAdd(tRelac, {'SZ9_CODVEN',	'SZ8_CODVEN'} )

	oModel:SetRelation('SZ8DETAIL', tRelac, SZ9->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('SZ8DETAIL'):SetUniqueLine({"Z8_CODVEN","Z8_PERC"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Grupo de Produtos - Mod. 3")
	oModel:GetModel('SZ9MASTER'):SetDescription('Cadastro')
	oModel:GetModel('SZ8DETAIL'):SetDescription('CDs')
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: THIAGO                                               |
| Data:  29/04/2024                                              |
| Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()

	Local oView := Nil
	Local oModel := FWLoadModel("MVCPERC")
	Local oStPaiZ9 := FWFormStruct(2,"SZ9")
	Local oStFilhoZ8 := FWFormStruct(2,"SZ8")
	oStFilhoZ8:RemoveField("Z8_CODVEN")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewZ3",oStPaiZ9,"SZ9MASTER")
	oView:AddGrid("ViewZ4",oStFilhoZ8,"SZ8DETAL")
	// Criando os Box
	oView:CreateHorizontalBox("CABEC",30)
	oView:CreateHorizontalBox("GRID",70)
	oView:SetCloseOnOk({||.T.})//Fecha a tela ao clicar no botão OK
	//Amarro os campos ao Box
	oView:SetOwnerView("ViewZ3","CABEC")//Cabeçalho
	oView:SetOwnerView("ViewZ4","GRID")//Grid
	oView:EnableTitleView("ViewZ3","Vendedor")//Cabeçalho
	oView:EnableTitleView("ViewZ4","Percentual")//Grid

Return oView
