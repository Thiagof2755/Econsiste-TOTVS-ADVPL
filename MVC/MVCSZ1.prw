#include "totvs.ch"
#include "FWMVCDEF.ch"


User Function MVCMOD3()
	Local aArea := GetNextAlias()
	Local oBrowseSZ1 //Objeto receberá classe FWMBrowse
	oBrowseSZ1 := FWMBrowse():New //Definindo o objeto como classe FWMbrowse
	oBrowseSZ1:SetAlias("SZ3") //Definindo a tabela que serão retirados os dados que aparecerão no Browse
	oBrowseSZ1:SetDescription("Animais Cadastrados")
	oBrowseSZ1:SetMenuDef("MVCMOD3") //Define o menu que será utilizado no browse como "MVCSZ1".
	oBrowseSZ1:Activate()//Executando chamada do objeto
	RestArea(aArea)
Return

Static Function ModelDef()
	local oStuctSZ1 := FWFormStruct(1,"SZ1") //Puxa a Estrutura da tabela SZ1 e deixa ela no modelo do forms (1 para model)
	local oStuctZX1 := FWFormStruct(1,"ZX1") //Puxa a Estrutura da tabela ZX1 e deixa ela no modelo do forms (1 para model)
	local oModel := MPFormModel():new("MVCSZ1M") //Recebeu um modelo criado com o id MVCSZ1M
	oModel:AddFields("FORMSZ1",,oStuctSZ1) //Adiciona os campos da estrutura "oStuctSZ1" ao formulário "FORMSZ1" no modelo de dados.
	oModel:AddGrid("DONOSZX1","FORMSZ1",oStuctZX1) // Adiciona a grade "DONOSZX1" ao formulário "FORMSZ1" utilizando a estrutura "oStuctZX1".
	oModel:SetRelation("DONOSZX1",{{"ZX1_FILIAL","xFilial('SZ1')"},{"ZX1_IDANIM","Z1_ID"}})
	oModel:SetPrimaryKey({"Z1_FILIAL","Z1_ID"})//Setando Quais são as referencias como chaves primarias na tabela SZ1
	oModel:GetModel("DONOSZX1"):SetUniqueLine({"ZX1_IDCLIE", "ZX1_LOJA"}) //Define a combinação das colunas "ZX1_FILIAL" e "ZX1_IDCLIE" como única na grade "DONOSZX1".
	oModel:SetDescription("Modelo de dados do Cadastro de Animais") //Descrevendo objeto
	oModel:GetModel("FORMSZ1"):SetDescription("Formulario de Cadastro de novo Animal") //Descrevendo o Formulario do objeto
	oModel:GetModel("DONOSZX1"):SetDescription("Donos/Responsaveis") //Descrevendo a tabela subordinada.
Return oModel

Static Function ViewDef()
	local oModel := FwLoadModel("MVCSZ1") //Cria uma variável local "oModel" e carrega o modelo com o ID "MVCSZ1".
	local oStuctSZ1 := FWFormStruct(2,"SZ1") //Puxa a Estrutura da tabela SZ1 e deixa ela no modelo do forms (2 para view)
	local oStuctZX1 := FWFormStruct(2,"ZX1") //Puxa a Estrutura da tabela ZX1 e deixa ela no modelo do forms (2 para view)
	oStuctZX1:RemoveField("ZX1_IDANIM") //Remove o campo "ZX1_IDANIM" da estrutura "oStuctZX1".
	local oView := FwFormView():New() //Criando Form de visão
	oView:SetModel(oModel) //Define o modelo "oModel" para o formulário de visão "oView".
	oView:AddField("VIEWSZ1", oStuctSZ1, "FORMSZ1") //Atribuindo a estrutura e formulario objetoview
	oView:AddGrid("VIEWZX1", oStuctZX1, "DONOSZX1") //Atribuindo a estrutura e formulario objetoview
	oView:CreateHorizontalBox("InfoAnimal", 60) //Cria box para parte dos dados do animal
	oView:CreateHorizontalBox("InfoDonos", 40) //Cria box para parte dos dados do Dono
	oView:SetOwnerView("VIEWSZ1", "InfoAnimal") //Relaciona a Janela ao Field
	oView:SetOwnerView("VIEWZX1", "InfoDonos") //Relaciona a Janela ao Field
	oView:EnableTitleView("VIEWSZ1", "Informacoes do animal") //Da titulo a janela de visualização
	oView:EnableTitleView("VIEWZX1", "Informacoes do Dono ou Responsavel") //Da titulo a janela de visualização
	oView:SetCloseOnOK({||.T.}) //Fecha a janela apos clicar em ok e todos os dados estiverem corretamente preenchidos
Return oview

Static Function MenuDef()
	local aRotina     := FWMVCMenu("MVCMOD3")

	ADD OPTION aRotina TITLE 'Gerar Relatorio'         ACTION 'u_SZ1RELAT'   OPERATION 6  ACCESS 0
 /*
 ADD OPTION aRotina TITLE 'Pesquisar'       ACTION 'VIEWDEF.MVCSZ1'   OPERATION 1  ACCESS 0
 ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.MVCSZ1'   OPERATION 2  ACCESS 0
 ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.MVCSZ1'   OPERATION 3  ACCESS 0
 ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.MVCSZ1'   OPERATION 4  ACCESS 0
 ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.MVCSZ1'   OPERATION 5  ACCESS 0
 */
 /*
 1 - Pesquisar
 2 - Visualizar 
 3 - Incluir
 4 - Alterar
 5 - Excluir
 6 - Outras Funções
 7 - Copiar
 */
Return aRotina

//Função pra gerar relatorio
User Function SZ1RELAT()
	private oReport
	private cPerg := "ANIMPR"
	Pergunte(cPerg,.T.)
	ReportDef()
	oReport:PrintDialog()
Return

// Define estrutura do relatorio
Static Function ReportDef()

	// Definindo relatorio
	oReport := TReport():New("Animais","Animais por Tipo",,{|oReport| PrintReport(oReport)})
	oReport:SetLandscape(.T.)
	local oSection01
	local oSection02

	// Definindo sessão 1 submissa ao relatorio
	oSection01 := TRSection():New(oReport,"Animais" ,{""})
	TRCell():New(oSection01,"Z1_ID","")
	TRCell():New(oSection01,"Z1_NOMEA","")
	TRCell():New(oSection01,"Z1_SEXO","")
	TRCell():New(oSection01,"Z1_TIPO","")
	TRCell():New(oSection01,"Z1_ESPECIE","")

	// Definindo sessão 2 submissa a sessão1
	oSection02 := TRSection():New(oSection01,"Donos" ,{""})
	TRCell():New(oSection02,"A1_COD","")
	TRCell():New(oSection02,"A1_LOJA","")
	TRCell():New(oSection02,"A1_NOME","")
	TRCell():New(oSection02,"A1_EST","")
	TRCell():New(oSection02,"A1_MUN","")

	// Definindo função para contar quantidade de impressões da sessão cabeçario (sessão 1)
	TRFunction():New(oSection01:Cell("Z1_ID"),,"COUNT",,,,,.F.,.T.,.F.,oSection01)
	// Definindo função para contar quantidade de impressões da sessão analitica (sessão 2)
	TRFunction():New(oSection02:Cell("A1_COD"),,"COUNT",,,,,.T.,.F.,.F.,oSection02)
Return

// Imprime o Relatorio da Maneira Correta
Static Function PrintReport(oReport)

	//Definindo Variaveis necessarias
	Local oSection01 := oReport:Section(1)
	Local oSection02 := oReport:Section(1):Section(1)
	Local cQuery := FGetQuery()
	Local cAlias := GetNextAlias()
	Local cAnimal   := ""
	Local aDonos   := {}
	local nIndice := 1

	//Manipulando Alias e Resultado da Querry
	MpSysOpenQuery(cQuery,cAlias)
	// Indo pra cima do arquivo da querry
	(cAlias)->(dbGoTop())
	// começando laço para cada um dos animais
	While !(cAlias)->(EOF())
		//Inicia contagem
		oReport:IncMeter()
		// imprime os donos do ultimo animal e limpa o array de donos se o o animal anterior for diferente do atual e se existir animal anterior
		if (!Empty(cAnimal) .And. cAnimal != (cAlias)->Z1_ID) .And. !Empty(aDonos)
			oSection02:Init()
			For nIndice := 1 to Len(aDonos)
				oSection02:Cell("A1_COD"):SetValue(aDonos[nIndice][1])
				oSection02:Cell("A1_LOJA"):SetValue(aDonos[nIndice][2])
				oSection02:Cell("A1_NOME"):SetValue(aDonos[nIndice][3])
				oSection02:Cell("A1_EST"):SetValue(aDonos[nIndice][4])
				oSection02:Cell("A1_MUN"):SetValue(aDonos[nIndice][5])
				oSection02:Printline()
			Next
			oSection02:Finish()
			oSection01:Finish()
			// limpa array de donos
			aDonos := {}
		EndIf
		// imprime o Animal se o o animal anterior for vazio ou diferente do atual
		If Empty(cAnimal) .Or. cAnimal != (cAlias)->Z1_ID
			// Iniciando sessão 1 (imprimindo descrição de campos animal)
			oSection01:Init()
			oSection01:Cell("Z1_ID"):SetValue((cAlias)->Z1_ID)
			oSection01:Cell("Z1_NOMEA"):SetValue((cAlias)->Z1_NOMEA)
			oSection01:Cell("Z1_SEXO"):SetValue((cAlias)->Z1_SEXO)
			oSection01:Cell("Z1_TIPO"):SetValue((cAlias)->Z1_TIPO)
			oSection01:Cell("Z1_ESPECIE"):SetValue((cAlias)->Z1_ESPECIE)
			oSection01:Printline()
		EndIf
		// se existir registro de dono na tabela ZX1, adiciona na array os dados do dono.
		If  !Empty(AllTrim((cAlias)->ZX1_IDANIM))
			aAdd(aDonos,{(cAlias)->A1_COD,(cAlias)->A1_LOJA,(cAlias)->A1_NOME,(cAlias)->A1_EST,(cAlias)->A1_MUN})
		EndIf

		cAnimal := (cAlias)->Z1_ID
		(cAlias)->(dbSkip())
	EndDo
	// Finaliza impressão do relatório e imprime o rodapé
Return

// Retorna a Query
Static Function FGetQuery()
	Local cQuery := ""
	cQuery  := 'Select * SZ1990 SZ1 '
	cQuery  += 'LEFT JOIN ZX1990 ZX1 ON SZ1.Z1_ID = ZX1.ZX1_IDANIM '
	cQuery  +=						'AND SZ1.Z1_FILIAL = ZX1.ZX1_FILIAL '
	cQuery  +=						'AND SZ1.D_E_L_E_T_ = ZX1.D_E_L_E_T_ '
	cQuery  += 'LEFT JOIN SA1990 SA1 ON ZX1.ZX1_IDCLIE = SA1.A1_COD '
	cQuery  +=						'AND ZX1.ZX1_LOJA = SA1.A1_LOJA '
	cQuery  +=						'AND ZX1.ZX1_FILIAL = SA1.A1_FILIAL '
	cQuery  +=						'AND ZX1.D_E_L_E_T_ = SA1.D_E_L_E_T_ '
	cQuery  += "WHERE SZ1.D_E_L_E_T_ = ' ' "
	cQuery  +=      "AND SZ1.Z1_ID >= '" + MV_PAR01 + "' "
	cQuery  +=      "AND SZ1.Z1_ID <= '" + MV_PAR02 + "' "
	cQuery  += 'ORDER BY SZ1.Z1_ID '
Return (cQuery)

User function xIniPad()
	local cRet := ''
	DBSelectArea("SA1")
	dbsetorder(1)
	if dbseek(xFilial("SA1")+ ZX1->ZX1_IDCLIE + ZX1->ZX1_LOJA)
		cRet := SA1->A1_NOME
	else
		cRet := ''
	endif
return cRet
