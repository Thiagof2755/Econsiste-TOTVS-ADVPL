#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ SIGACTB บAutor ณ Jonathan Schmidt Alvesบ Data ณ 16/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na entrada do modulo SIGACTB (Contabilidade).         บฑฑ
ฑฑบ          ณ Ao logar no SIGACTB (Modulo de Contabilidade) nos dias de  บฑฑ
ฑฑบ          ณ semana segunda, quinta ou sexta o sistema faz o um         บฑฑ
ฑฑบ          ณ reprocessamento de segurancao dos Itens Contabeis (CTD)    บฑฑ
ฑฑบ          ณ para garantir que os clientes e fornecedores (SA1/SA2)     บฑฑ
ฑฑบ          ณ estao alinhados com os itens contabeis (CTD).              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ Empresas para processamento:                               บฑฑ
ฑฑบ          ณ Apenas empresas que ja tiveram o saneamento de cadastros   บฑฑ
ฑฑบ          ณ Clientes/Fornecedores/Itens Contabeis devem ter esse       บฑฑ
ฑฑบ          ณ reprocessamento.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function SIGACTB()
Local cFunName := AllTrim(FunName())
Local _cFilCTD := xFilial("CTD")
If cFunName $ "CTBLOAD" // Carregamento
	If _cFilCTD $ "0101/0505/0707/0909/1010/"
		If (DoW(Date()) == 2 .Or. DoW(Date()) == 5 .Or. DoW(Date()) == 6) .And. GetMv("IN_ATUACTD") < DtoS(Date()) // Ainda nao reprocessado // 2do dia da semana (Segunda-feira) Ativado so no 2do semestre (Julho)
			PutMv("IN_ATUACTD",DtoS(Date())) // Atualiza parametro
			u_AskYesNo(2500,"Contabilidade","Atualizando Item Contabil...","Atualizando clientes...		","","","","SALVAR",.T.,.F.,{|| u_SA1TOCTD() })
			u_AskYesNo(2500,"Contabilidade","Atualizando Item Contabil...","Atualizando fornecedores...	","","","","SALVAR",.T.,.F.,{|| u_SA2TOCTD() })
		EndIf
	EndIf
EndIf
Return