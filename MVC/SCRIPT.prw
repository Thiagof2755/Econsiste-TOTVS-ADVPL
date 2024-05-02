#include "TOTVS.CH"

/*/{Protheus.doc} SCRIPT
********************MVCSZ3MODELO3************************
/*/
User Function SCRIPT()
	Private oReport  := Nil
	Private oSecCab	 := Nil
	Private cPerg 	 := "TURALU"

//Função responsável por chamar a pergunta criada na função ValidaPerg, 
//a variável PRIVATE cPerg, é passada.
	Pergunte(cPerg,.T.) // SE TRUE ELE CHAMA A PERGUNTA ASSIM QUE O RELATÓRIO É ACIONADO

//CHAMAMOS AS FUNÇÕES QUE CONSTRUIRÃO O RELATÓRIO
	ReportDef() //MONTAR A ESTRUTURA
	oReport:PrintDialog() //TRAZER OS DADOS E PRINTA/IMPRIME NA TELA OU EM ARQUIVO OU NA IMPRESSORA O RELATÓRIO
Return

/*/{Protheus.doc} ReportDef
********************MVCSZ3MODELO3************************
/*/
Static Function ReportDef(x)

	oReport := TReport():New("TURM","Relatório de Turmas",cPerg,{|oReport| PrintReport(oReport)},"Relatório de Turmas")

	oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELATÓRIO SERÁ EM PAISAGEM

//TrSection serve para constrole da seção do relatório, neste caso, teremos somente uma
	oSecCab := TRSection():New( oReport , "TURMA", {"SQL"} )

	TRCell():New( oSecCab, "Z4_CODT", "SZ4")
	TRCell():New( oSecCab, "Z3_MODALID","SZ3")
	TRFunction():New(oSecCab:Cell("Z4_CODT"),,"COUNT",,,,,.F.,.T.,.F.,oSecCab)



	oSecCon := TRSection():New( oReport , "ALUNOS", {"SQL"} )
	TRCell():New( oSecCon, "A1_NOME","SA1")
	TRCell():New( oSecCon, "Z4_CODA","SZ4")

Return

/*/{Protheus.doc} PrintReport
********************MVCSZ3MODELO3************************
/*/
Static Function PrintReport(oReport)

	Local oSec2 := oReport:Section(2)
	Local oSecCab := oReport:Section(1)
	local cAlias := GetNextAlias()
	Local Modal := {"Musculação","Jiu-Jitsu","Dança", "Natação", "Futebol"}
	Local Turmas := {}
	local nIndice := 0
	local Vld := ''


	IF Empty(MV_PAR02)
		MV_PAR02 := 'zzzzzz'
	ENDIF
	IF Empty(MV_PAR04)
		MV_PAR04 := 'zzzzzz'
	ENDIF

	cTumade := MV_PAR01
	cTumaAte := MV_PAR02
	cAlunode := MV_PAR03
	cAlunoAte := MV_PAR04

	BeginSql Alias cAlias
        SELECT A1_NOME, Z4_CODA ,Z4_CODT ,Z3_MODALID   FROM %table:SZ4% 
            INNER JOIN %table:SA1% ON A1_COD = Z4_CODA
            INNER JOIN %table:SZ3% ON Z3_COD = Z4_CODT
                WHERE %table:SZ4%.%notdel% 
				and Z4_CODT >= %exp:cTumade%
				and Z4_CODT <= %exp:cTumaAte%
				and Z4_CODA >= %exp:cAlunode%
				AND Z4_CODA <= %exp:cAlunoAte%
	EndSql


	While (cAlias)->(! Eof())
		aAdd(Turmas,{(cAlias)->(Z4_CODT), (cAlias)->(Z3_MODALID), (cAlias)->(A1_NOME), (cAlias)->(Z4_CODA)})
		(cAlias)->(DbSkip())
	EndDo


	For nIndice := 1 to Len(Turmas)

		oSecCab:Init()
		oSecCab:Cell("Z4_CODT"):SetValue(Turmas[nIndice][1])
		oSecCab:Cell("Z3_MODALID"):SetValue(Modal[GetDToVal(Turmas[nIndice][2])])
		oSec2:Init()

		IF (Turmas[nIndice][1]) == Vld
			oSec2:Cell("Z4_CODA"):SetValue(Turmas[nIndice][4])
			oSec2:Cell("A1_NOME"):SetValue(Turmas[nIndice][3])

		ELSE
			oSec2:Cell("Z4_CODA"):SetValue(Turmas[nIndice][4])
			oSec2:Cell("A1_NOME"):SetValue(Turmas[nIndice][3])
			oSecCab:Printline()
		ENDIF

		Vld := (Turmas[nIndice][1])

		IF nIndice == len(Turmas)
			oSec2:Printline()
		ENDIF

		If   nIndice < Len(Turmas)
			IF (Turmas[nIndice][1]) != (Turmas[nIndice+1][1])
				oSec2:Printline()
				oSec2:Finish()
				oSecCab:Finish()
			ENDIF
		ENDIF
		If   nIndice < Len(Turmas)
			IF Vld == (Turmas[nIndice+1][1]) .AND. (Turmas[nIndice][4]) != (Turmas[nIndice-1][4]) .AND. (Turmas[nIndice][4]) != (Turmas[nIndice+1][4])
				oSec2:Printline()
			ENDIF
		ENDIF
	Next
	(cAlias)->(DbCloseArea())
Return


