#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MTA103MNU บAutor ณ Cristiam Rossi     บ Data ณ  29/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na rotina MATA103 (Documento de Entrada) para tratar  บฑฑ
ฑฑบ          ณ inclusao de rotina especํfica no menu Acoes Relacionadas.  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบRevisao   ณ                Jonathan Schmidt Alves บ Data ณ  30/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ITUP / ECCO                                                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MTA103MNU()
ConOut("MTA130MNU: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
u_PEchvNFe("MTA103MNU") // adi็ใo rotinas Import. XML e Lote XML - Cristiam Em 09/08/2016
ConOut("MTA130MNU: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return