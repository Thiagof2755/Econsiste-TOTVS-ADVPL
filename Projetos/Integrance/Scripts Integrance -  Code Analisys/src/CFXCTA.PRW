
#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CFXCTA    ºAutor  ³ Cristiam Rossi     º Data ³  28/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina DE -> PARA de CFOP e tabela que retorne a Conta     º±±
±±º          ³ Contábil                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ECCO / ITUP                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

uso:
----

Coloque no menu para acesso ao cadastro das regras:
			<MenuItem Status="Enable">
				<Title lang="pt">@CFOP X Cta Contabil</Title>
				<Title lang="es">@</Title>
				<Title lang="en">@</Title>
				<Function>CFxCTA</Function>
				<Type>3</Type>
				<Access>xxxxxxxxxx</Access>
				<Module>06</Module>
				<Owner>2</Owner>
			</MenuItem>

chamada da função para retorno da Conta Contábil:

	cConta := U_CFxCTA( "1102", "SB1" )


Obs:  caso não encontre o retorno será em branco (spaços vazios no tamanho da conta contábil)

Obs2: Na primeira vez que rodar, automaticamente será criada a base de dados, tabela C_F

*/
User Function CFxCTA( cCFOP, cTb )
Local   aArea  := getArea()
Local   xRet   := nil
Default cCFOP  := ""
Default cTb    := Space(3)

	if ! ChkTB()
		Aviso( "Criação da tabela C_F", "Ocorreu algum erro na criação da tabela C_F, rotina cancelada", {"Ok"} )
		restArea( aArea )
		return xRet
	endif

	dbSelectArea("C_F")

	if ! empty( cCFOP )
		xRet := Pesquisa( cCFOP, cTb )
	else
		axCadastro("C_F","Amarração CFOP x Conta Contábil",".T.",".T.")
	endif

	restArea( aArea )
return xRet


//--------------------------------
Static Function Pesquisa( cCFparam, cTb )
Local   xRet  := Space( len( C_F_CONTA ) )
Local   aCFOP := {}
Local   cCFOP := alltrim( cCFparam )
Local   nI
Default cTb   := Space(3)

	cTb := padR(cTb, 3)

	if left( cCFOP, 1 ) $ "1,2,3"
		for nI := 1 to 3
			aadd( aCFOP, cValToChar(nI) + substr( cCFOP, 2 ) )
		next
	elseif left( cCFOP, 1 ) $ "5,6,7"
		for nI := 5 to 7
			aadd( aCFOP, cValToChar(nI) + substr( cCFOP, 2 ) )
		next
	else
		aadd( aCFOP, cCFOP )
	endif

	dbSeek( xFilial("C_F") + cTb )

	while ! EOF() .and. xFilial("C_F") == C_F_FILIAL .and. cTb == C_F_TABELA .and. empty( xRet )

		if C_F_MSBLQL != "1"
			for nI := 1 to len( aCFOP )
				if aCFOP[nI] $ C_F_LISTA
					xRet := C_F_CONTA
					exit
				endif
			next
		endif

		dbSkip()
	end

return xRet


//--------------------------------
Static Function ChkTB()
Local aRegs
Local nI
Local nJ

	if chkFile("C_F")
		return .T.
	endif

	aRegs  := {}
	AADD(aRegs,{"C_F","", ,"RELACAO CFOP X CONTA CONTABIL ","RELACAO CFOP X CONTA CONTABIL ","RELACAO CFOP X CONTA CONTABIL ","                                        ","C","C","C",00," ","                                                                                                                                                                                                                                                          "," ",00,"                                                                                                                                                                                                                                                              ","                              ","                              "," "})

	dbSelectArea("SX2")
	dbSetOrder(1)

	For nI := 1 To Len(aRegs)
		dbSetOrder(1)
		if ! dbSeek(aRegs[nI, 1])

			RecLock("SX2", .T.)

			For nJ := 1 to FCount()
				If nJ <= Len(aRegs[nI])
					If allTrim(Field(nJ)) == "X2_ARQUIVO"
						aRegs[nI,nJ] := aRegs[nI,1] + SM0->M0_CODIGO + "0"
					EndIf
					FieldPut( nJ, aRegs[nI,nJ])
				Endif
			Next
			MsUnlock()
		endif
	Next


	aRegs := {}
	AADD(aRegs,{"C_F","01","C_F_FILIAL","C",004,00,"Filial      ","Sucursal    ","Branch      ","Filial do Sistema        ","Sucursal                 ","Branch of the System     ","@!                                           ","                                                                                                                                ","€€€€€€€€€€€€€€€","                                                                                                                                ","      ",01,"þÀ"," "," ","U","N"," "," "," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","033"," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," "," "," ","               ","   "," ","N","N","N"})
	AADD(aRegs,{"C_F","02","C_F_TABELA","C",003,00,"Tabela      ","Tabela      ","Tabela      ","Tabela                   ","Tabela                   ","Tabela                   ","@!                                           ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","SX2PAD",00,"þA"," ","S","U","S","A","R"," ","vazio().or.ExistCpo('SX2',M->C_F_TABELA)                                                                                        ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","   "," ","N","N","N"})
	AADD(aRegs,{"C_F","03","C_F_DESCTB","C",040,00,"Descr.Tabela","Descr.Tabela","Descr.Tabela","Descr.Tabela             ","Descr.Tabela             ","Descr.Tabela             ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","POSICIONE('SX2',1,M->C_F_TABELA,'X2_NOME')                                                                                      ","      ",00,"þA"," "," ","U","S","V","V"," ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","POSICIONE('SX2',1,C_F->C_F_TABELA,'X2_NOME')                                    ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","   "," ","N","N","N"})
	AADD(aRegs,{"C_F","04","C_F_CONTA ","C",020,00,"Conta Contab","Conta Contab","Conta Contab","Conta Contabil           ","Conta Contabil           ","Conta Contabil           ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","CT1   ",00,"þÀ"," "," ","U","S","A","R","€","vazio().or.ExistCpo('CT1',M->C_F_CONTA)                                                                                         ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","   "," ","N","N","N"})
	AADD(aRegs,{"C_F","05","C_F_MSBLQL","C",001,00,"Bloqueado?  ","Bloqueado?  ","Bloqueado?  ","Registro bloqueado       ","Registro bloqueado       ","Registro bloqueado       ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","'2'                                                                                                                             ","      ",09,"‚€"," "," ","L","N","A","R"," ","                                                                                                                                ","1=Sim;2=Não                                                                                                                     ","1=Si;2=No                                                                                                                       ","1=Yes;2=No                                                                                                                      ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","   "," ","N","N","N"})
	AADD(aRegs,{"C_F","06","C_F_LISTA ","C",250,00,"CFOPs       ","CFOPs       ","CFOPs       ","lista de CFOPs           ","lista de CFOPs           ","lista de CFOPs           ","                                             ","                                                                                                                                ","€€€€€€€€€€€€€€ ","                                                                                                                                ","      ",00,"þÀ"," "," ","U","S","A","R","€","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                                                                                                                                ","                    ","                                                            ","                                                                                ","   "," "," ","                                                                                                                                                                                                                                                          ","                                                                                                                                                                                                                                                          "," ","N","N","               ","   "," ","N","N","N"})

	dbSelectArea("SX3")
	dbSetOrder(1)

	For nI := 1 To Len(aRegs)
		dbSetOrder(1)
		if ! dbSeek(aRegs[nI, 1] + aRegs[nI, 2])

			RecLock("SX3", .T.)

			For nJ := 1 to FCount()
				If nJ <= Len(aRegs[nI])
					FieldPut( nJ, aRegs[nI,nJ])
				Endif
			Next
			MsUnlock()
		endif
	Next


	aRegs  := {}
	AADD(aRegs,{"C_F","1","C_F_FILIAL+C_F_TABELA                                                                                                                                           ","Tabela                                                                ","Tabela                                                                ","Tabela                                                                ","U","                                                                                                                                                                ","          ","S"})

	dbSelectArea("SIX")
	dbSetOrder(1)

	For nI := 1 To Len(aRegs)
		dbSetOrder(1)
		if ! dbSeek(aRegs[nI, 1])

			RecLock("SIX", .T.)

			For nJ := 1 to FCount()
				If nJ <= Len(aRegs[nI])
					FieldPut( nJ, aRegs[nI,nJ])
				Endif
			Next
			MsUnlock()
		endif
	Next


	aRegs  := {}
	AADD(aRegs,{"C_F_TABELA","001","SX2->X2_NOME                                                                                        ","C_F_DESCTB","P","S","SX2",01,"M->C_F_TABELA                                                                                       ","                                        ","U"})

	dbSelectArea("SX7")
	dbSetOrder(1)

	For nI := 1 To Len(aRegs)
		dbSetOrder(1)
		if ! dbSeek(aRegs[nI, 1] + aRegs[nI, 2])

			RecLock("SX7", .T.)

			For nJ := 1 to FCount()
				If nJ <= Len(aRegs[nI])
					FieldPut( nJ, aRegs[nI,nJ])
				Endif
			Next
			MsUnlock()
		endif
	Next

return chkFile("C_F")
