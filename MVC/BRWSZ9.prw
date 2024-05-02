#include 'Totvs.ch'


User Function BRWSZ9()
	Local aArea := GetNextAlias()// cria instringa para armazenar o nome da tabela
	Local oBrowseSA1

	oBrowseSA1 := FwmBrowse():New()

	dbSelectArea("SZ3") //Selecionar a área, e se a tabela não estiver criada, ele vai criar
	DBSetOrder(1)
	dbCloseArea()

	//Passo como parametro a tabela que eu quero mostrar no Browse
	oBrowseSA1:SetAlias("SZ3")

	oBrowseSA1:SetDescription("Clientes Academia")

	oBrowseSA1:SetOnlyFields({"A1_COD", "A1_NOME", "A1_END", "A1_MUN" })

	oBrowseSA1:AddLegend("SA1->A1_MSBLQL =='1'","GREEN","Ativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 1
	oBrowseSA1:AddLegend("SA1->A1_MSBLQL =='2'","RED","Inativo") //Filtro para mostrar somente os registros que possuem o campo A1_MSBLQL igual a 0
	//A1_MSBLQL

	oBrowseSA1:Activate()

	RestArea(aArea)

Return
