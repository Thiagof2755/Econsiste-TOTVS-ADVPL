#INCLUDE "TOTVS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MT100LOK บAutor ณ Cristiam Rossi      บ Data ณ  22/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na rotina MATA103 (Documento de Entrada) na validacao บฑฑ
ฑฑบ          ณ da linha para tratar parte customizada do XML Entrada.     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบRevisao   ณ                Jonathan Schmidt Alves บ Data ณ  30/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ITUP / ECCO                                                บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MT100LOK()
Local lRet := .T.
ConOut("M100LOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Iniciando...")
If isInCallStack("U_GETCHVNFE") // chamado pelo customiza็ใo de XML
	lRet := u_PEchvNFe("MT100LOK") // atualiza valor ICMS ST - Cristiam em 22/08/2016
EndIf
ConOut("M100LOK: " + DtoC(Date()) + " " + Time() + " " + cUserName + " Concluido!")
Return lRet