#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MALTCLI  บAutorณ Jonathan Schmidt Alves บDataณ 19/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na rotina MATA030 (Cadastro de Clientes) para         บฑฑ
ฑฑบ          ณ tratar a inclusao/correcao do item contabil (CTD).         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                  Jonathan Schmidt Alves บData ณ 16/08/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MALTCLI()
ConOut("MALTCLI: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
u_M030INC(.F.) // Chamada o P.E. de inclusao para incluir/alterar o Item Contabil (CTD)
ConOut("MALTCLI: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return