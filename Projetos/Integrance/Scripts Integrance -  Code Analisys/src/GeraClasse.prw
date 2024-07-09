#include "totvs.ch"  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GeraClasse ³ Autor ³ Econsiste           ³ Data ³ 06/02/23 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ ECONSISTE        ³Contato ³ emerson@econsiste.com.br       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Classe Valor conforme cliente ou fornecedor.          ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±          

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GeraClasse(cCodLoja)
local _aarea   :=getarea()
local _aareacth:=cth->(getarea())
local _aareasa1:=sa1->(getarea())
local _aareasa2:=sa2->(getarea())

Default cCodLoja := ""

if Empty(cCodLoja) // Todos

	if MsgYesNO("Confirma geracao da classe valor para todos cliente e fornecedores?","TODOS")  

		DbSelectArea("SA1")
		SA1->(DbSetorder(1))	
		SA1->(DbGoTop())		
		While SA1->(!Eof())
			u_fGeraClasse("C"+SA1->A1_COD+SA1->A1_LOJA)
	        SA1->(DbSkip())
	  	End
	  	
		DbSelectArea("SA2")
		SA2->(DbSetorder(1))	
		SA2->(DbGoTop())		
		While SA2->(!Eof())
			u_fGeraClasse("F"+SA2->A2_COD+SA2->A2_LOJA)
	        SA2->(DbSkip())
	  	End   
	endif
else  	
	u_fGeraClasse(cCodLoja)
endif
cth->(restarea(_aareacth))
sa1->(restarea(_aareasa1))
sa2->(restarea(_aareasa2))
restarea(_aarea)
Return()



User Function fGeraClasse(_cclasse)

if substr(alltrim(_cclasse),1,1)=="C" // CLIENTE

	cth->(dbsetorder(1))
	if ! cth->(dbseek(xfilial("CTH")+_cclasse))
		sa1->(dbsetorder(1))
		if sa1->(dbseek(xfilial("SA1")+substr(_cclasse,2,8)))
			reclock("CTH",.t.)
			cth->cth_filial:=xfilial("CTH")
			cth->cth_clvl  :=_cclasse
			cth->cth_classe:="2"
			cth->cth_desc01:=sa1->a1_nome
			cth->cth_bloq  :="2"
			cth->cth_dtexis:=ctod("01/01/2014")
			cth->cth_clvllp:=_cclasse
			cth->cth_clsup :="C"
			msunlock()
		endif
	endif
elseif substr(alltrim(_cclasse),1,1)=="F" // FORNECEDOR
	cth->(dbsetorder(1))
	if ! cth->(dbseek(xfilial("CTH")+_cclasse))
		sa2->(dbsetorder(1))
		if sa2->(dbseek(xfilial("SA2")+substr(_cclasse,2,8)))
			reclock("CTH",.t.)
			cth->cth_filial:=xfilial("CTH")
			cth->cth_clvl  :=_cclasse
			cth->cth_classe:="2"
			cth->cth_desc01:=sa2->a2_nome
			cth->cth_bloq  :="2"
			cth->cth_dtexis:=ctod("01/01/2014") 
			cth->cth_clvllp:=_cclasse
			cth->cth_clsup :="F"
			msunlock()
		endif
	endif
endif

return(_cclasse)
