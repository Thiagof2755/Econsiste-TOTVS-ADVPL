#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ MA920MNU บAutor ณ Frank Zwarg Fuga     บ Data ณ 09/10/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ P.E. na rotina MATA920 (Nota Fiscal Saida Livros Fiscais)  บฑฑ
ฑฑบ          ณ para incluir o menu da importa็ใo do xml na nota fiscal    บฑฑ
ฑฑบ          ณ de saida manual.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRevisao   ณ                 Jonathan Schmidt Alves บ Data ณ 23/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ INTEGRANCE                                                 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function MA920MNU()
aAdd(aRotina, { "Importa็ใo XML"		,"u_GETCHVSNF",	0, 3, 0, Nil })
aAdd(aRotina, { "Importa็ใo Lote XML"	,"u_GETLOTNF",	0, 3, 0, Nil })
Return