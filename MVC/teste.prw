#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
User Function SCRIPT()
	Private oReport  := Nil
	Private oSecCab	 := Nil
	Private cPerg 	 := "TURALU"

//Fun��o respons�vel por chamar a pergunta criada na fun��o ValidaPerg, 
//a vari�vel PRIVATE cPerg, � passada.
	Pergunte(cPerg,.T.) // SE TRUE ELE CHAMA A PERGUNTA ASSIM QUE O RELAT�RIO � ACIONADO

//CHAMAMOS AS FUN��ES QUE CONSTRUIR�O O RELAT�RIO
	ReportDef() //MONTAR A ESTRUTURA
	oReport:PrintDialog() //TRAZER OS DADOS E PRINTA/IMPRIME NA TELA OU EM ARQUIVO OU NA IMPRESSORA O RELAT�RIO
Return

Static Function ReportDef(x)

	oReport := TReport():New("TURM","Relat�rio de Turmas",cPerg,{|oReport| PrintReport(oReport)},"Relat�rio de Turmas")

	oReport:SetLandscape(.T.) // SIGNIFICA QUE O RELAT�RIO SER� EM PAISAGEM

//TrSection serve para constrole da se��o do relat�rio, neste caso, teremos somente uma
	oSecCab := TRSection():New( oReport , "TURMA", {"SQL"} )

	TRCell():New( oSecCab, "Z4_CODT", "SZ4")
	TRCell():New( oSecCab, "Z3_MODALID","SZ3")
	TRFunction():New(oSecCab:Cell("Z4_CODT"),,"COUNT",,,,,.F.,.T.,.F.,oSecCab)


	oSecCon := TRSection():New( oReport , "ALUNOS", {"SQL"} )
	TRCell():New( oSecCon, "A1_NOME","SA1")
	TRCell():New( oSecCon, "Z4_CODA","SZ4")

Return

Static Function PrintReport(oReport)

	Local oSec2 := oReport:Section(2)
	local cAlias := GetNextAlias()
	Local Vld := ''
	Local Modal := {"Muscula��o","Jiu-Jitsu","Dan�a", "Nata��o", "Futebol"}
	Local Print:= .T.
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

		oSecCab:Init()
		oSecCab:Cell("Z4_CODT"):SetValue((cAlias)->Z4_CODT)
		oSecCab:Cell("Z3_MODALID"):SetValue(Modal[GetDToVal((cAlias)->Z3_MODALID)])
		oSec2:Init()
		IF (cAlias)->Z4_CODT == Vld
			oSec2:Cell("Z4_CODA"):SetValue((cAlias)->Z4_CODA)
			oSec2:Cell("A1_NOME"):SetValue((cAlias)->A1_NOME)
			Print := .F.
		Else
			oSec2:Cell("Z4_CODA"):SetValue((cAlias)->Z4_CODA)
			oSec2:Cell("A1_NOME"):SetValue((cAlias)->A1_NOME)
			oSecCab:Printline()
			//oSec2:Finish()
		endif
		Vld := (cAlias)->Z4_CODT
		// se o vld for igual o proximo valor, ele vai para o proximo
		oSec2:Printline()
		oSecCab:Finish()
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())
Return
