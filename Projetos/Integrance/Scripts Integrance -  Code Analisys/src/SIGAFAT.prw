#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ SIGAFAT ºAutor ³ Jonathan Schmidt Alves º Data³ 03/06/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. na rotina SIGAFAT (Faturamento) para criacao de       º±±
±±º          ³ atalhos.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SIGAFAT()
If RetCodUsr() == "000041" // jonathan.alves
	//SetKey(VK_F4,	{|| u_OPER_F4_() })	// Operacao F4
	//SetKey(VK_F6,	{|| u_IntGrCVD() })	// Clonagem do CVD (Plano Referencial) F6
	// SetKey(VK_F7,	{|| u_ImpInvoi() })	// Importacao Invoices F7
	
	// SetKey(VK_F7,	{|| /*MsgInfo("SIGAFAT F7 (28/01/2020 1104hrs)","SIGAFAT")*/ u_CnsPdCT1() }) // TESTE


	// SetKey(VK_F9,	{|| u_CTDuplic() }) // CTD Duplicados (Jonathan 08/11/2019)
	// SetKey(VK_F9,	{|| u_ImporCT1() }) // Importacao CT1
	// SetKey(VK_F9,	{|| u_RepInvoi() }) // RepInvoi
	
	// SetKey(VK_F9,	{|| u_ClearCTD() }) // Exclusao CTD bloqueados
	
	
	// SetKey(VK_F9,	{|| u_ItensSA2() }) // Reestruturacao Itens Contabeis (CTD) Fornecedores
	//SetKey(VK_F9,	{|| u_ItensSA1() }) // Reestruturacao Itens Contabeis (CTD) Clientes
	
	//SetKey(VK_F10,	{|| u_RCTBM02() }) // Importacao Excel
	SetKey(VK_F10,	{|| u_IMPCONTB() }) // Importacao Lancamentos Contabeis
	SetKey(VK_F11,	{|| u_INTFIN11() }) // Extrato Carla
	
	// SetKey(VK_F12,	{|| u_ItensCtb() }) // Reprocessamento de Itens Contabeis (CTD)
	// SetKey(VK_F12,	{|| DbSelectArea("SE2"), SE2->(DbGoto(5617)), u_LoadsSE5( "201907", SE2->E2_BAIXA - 1 ) })
	
ElseIf RetCodUsr() $ "000035/000046/" // carla.herrera e igor.vereda
	SetKey(VK_F11,	{|| u_INTFIN11() }) // Extrato Carla
EndIf
Return

User Function CnsPdCT1()
lResCT1 := .F.
SB1->(DbGoto(2948))
u_AskYesNo(1200,"Conta Contabil","Produto criado sem conta contabil!","Produto: " + SB1->B1_COD,RTrim(SB1->B1_DESC),"","","NOTE",.T.,.F.,{|| lResCT1 := ConPad1(,,,"CT1") }) // Leitura dos dados no arquivo .CSV
If lResCT1 // Confirmada Conta contabil
	RecLock("SB1",.F.)
	SB1->B1_CONTA := CT1->CT1_CONTA
	SB1->(MsUnlock())
EndIf

Return