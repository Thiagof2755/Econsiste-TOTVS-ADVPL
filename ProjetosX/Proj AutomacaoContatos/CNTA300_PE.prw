#include 'totvs.ch'
#include 'parmtype.ch'

#define DS_MODALFRAME   128

/*/{Protheus.doc} CNTA300
//
@author Leandro Pereira
@since 13/01/2020
@version P12
@type function
/*/
User Function CNTA300()

	Local aParam     := PARAMIXB
	Local xRet
	Local oModel     := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.
	Local nLinha     := 0
	Local nQtdLinhas := 0
	Local cMsg       := ''
	Local nOperation := 0

	If aParam <> NIL
		oModel       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )
		nOperation := oModel:GetOperation()
		/*
		If lIsGrid
			nQtdLinhas := oModel:GetQtdLine()
			nLinha     := oModel:nLine
		EndIf
		*/

		If cIdPonto == 'MODELPRE' //Antes da altera��o de qualquer campo do modelo
			xRet	:= .T.

		ElseIf cIdPonto == 'MODELPOS' //Na valida��o total do modelo
			xRet	:= .T.

		ElseIf cIdPonto == "MODELVLDACTIVE" //Na ativa��o do modelo
			xRet	:= .T.

		ElseIf cIdPonto == 'FORMPRE' //Antes da altera��o de qualquer campo do formul�rio
			xRet	:= .T.

		ElseIf cIdPonto == 'FORMPOS' //Na valida��o total do formul�rio.
			xRet	:= .T.

		ElseIf cIdPonto == 'FORMLINEPRE' //Antes da altera��o da linha do formul�rio FWFORMGRID
			xRet	:= .T.

		ElseIf cIdPonto == 'FORMLINEPOS' //Na valida��o total da linha do formul�rio FWFORMGRID
			xRet	:= .T.

		ElseIf cIdPonto == 'MODELCOMMITTTS' //Ap�s a grava��o total do modelo e dentro da transa��o

		ElseIf cIdPonto == 'MODELCOMMITNTTS' // Ap�s a grava��o total do modelo e fora da transa��o.
			//Se inclus�o ou altera��o
			If nOperation == 4 .Or. nOperation == 3
				oModel 		:= FWModelActive() //SZGMASTER
				oModelCN9	:= oModel:GetModel("CN9MASTER")
				cNumContr := oModelCN9:GetValue('CN9_NUMERO')

				//Percorrendo a SCR para burscar o aprovador,
				Dbselectarea("SCR")
				dbsetorder(1)
				dbseek(xFilial("SCR")+Padr('CT',Tamsx3("CR_TIPO")[1])+AllTrim(cNumContr))
				While SCR->(!EoF()) .and. SCR->(CR_FILIAL+CR_TIPO+AllTrim(CR_NUM)) == xFilial("SCR")+Padr('SC',Tamsx3("CR_TIPO")[1])+AllTrim(cNumContr)
					RecLock("SCR",.F.)
					SCR->CR_XNUSROR := upper(UsrRetName(RetCodUsr()))
					MsUnlock()
					SCR->(dbskip())
				End
			endif

		ElseIf cIdPonto == 'FORMCOMMITTTSPRE' //Antes da grava��o da tabela do formul�rio.

		ElseIf cIdPonto == 'FORMCOMMITTTSPOS' //Ap�s a grava��o da tabela do formul�rio

		ElseIf cIdPonto == 'MODELCANCEL' //No cancelamento do bot�o
			xRet	:= .T.

		ElseIf cIdPonto == 'BUTTONBAR' //Para a inclus�o de bot�es na ControlBar.
			xRet := { }
		EndIf

		Return ( xRet )
