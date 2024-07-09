#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MT103NFE บAutor ณ Cristiam Rossi       บ Data ณ 29/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na rotina MATA103 (Documento de Entrada) no momento   บฑฑ
ฑฑบ          ณ do acesso a uma das opcoes da NFE (2=Visualiza/ 3=Incluir/ บฑฑ
ฑฑบ          ณ 4=Classificar/ 5=Excluir) chamando processamento da parte  บฑฑ
ฑฑบ          ณ customizada do XML Entrada.                                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบRevisao   ณ                Jonathan Schmidt Alves บ Data ณ  30/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ITUP / ECCO                                                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MT103NFE()
ConOut("MT103NFE: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If IsInCallStack("U_GETCHVNFE") // chamado pelo customiza็ใo de XML
	u_PEchvNFe("MT103NFE") // Carrega cabe็alho Documento de Entrada - Cristiam em 09/08/2016
EndIf
ConOut("MT103NFE: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return