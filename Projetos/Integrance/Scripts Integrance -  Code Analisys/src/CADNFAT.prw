#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ CADNFAT บAutor ณDouglas Telles         บ Data ณ 04/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para efetuar o cadastro das notas a serem importadas  บฑฑ
ฑฑบ          ณ automaticamente.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                 Jonathan Schmidt Alves บ Data ณ 04/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function CADNFAT()
Local aCores := {{'ZDT->ZDT_STATUS == "1"', 'ENABLE' },; // Ativo
{'ZDT->ZDT_STATUS == "2"', 'DISABLE' }} // Inativo
Private cAlias		:= "ZDT"
Private cCadastro	:= "Cadastro de NF Automatica"
Private aRotina		:= {{"Pesquisar", "AxPesqui"	, 0, 1 },;
{"Visualizar"	, "AxVisual"	, 0, 2 },;
{"Incluir"		, "AxInclui"	, 0, 3 },;
{"Alterar"		, "AxAltera"	, 0, 4 },;
{"Excluir"		, "AxDeleta"	, 0, 5 },;
{"Legenda"		, "U_NFATLEG"	, 0, 7, 0, .F. }} // "Legenda"
DbSelectArea("ZDT")
ZDT->(DbSetOrder(1)) // ZDT_FILIAL + ZDT_TIPO + ZDT_CGCEMI + ZDT_CGCDES + ZDT_CFOP + ZDT_NCM
mBrowse( ,,,,"ZDT",,,,,,aCores)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ NFATLEG บAutor ณDouglas Telles         บ Data ณ 04/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da tela de cadastro de nf automatica.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                 Jonathan Schmidt Alves บ Data ณ 04/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function NFATLEG()
Local aLegenda := {}
aAdd(aLegenda,{"ENABLE"		,"Cadastro Ativo"		})
aAdd(aLegenda,{"DISABLE"	,"Cadastro Bloqueado"	})
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return