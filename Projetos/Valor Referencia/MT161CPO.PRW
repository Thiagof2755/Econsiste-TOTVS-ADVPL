#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT161CPO
Autor : Thiago Alves da Silva Filho 
Data : 16/07/2024

Ponto de Entrada da Rotina de Analise de Cotação adicionando o campo C8_REF na grid "Produtos"
/*/

User Function MT161CPO()

	Local aPropostas := PARAMIXB[1] // Array com os dados das propostas dos Fornecedores
	Local aItens     := PARAMIXB[2] // Array com os dados da grid "Produtos"
	Local aCampos    := {"C8_PRECO"} // Array com os campos adicionados na grid "Item da Proposta"
	Local aCposProd  := {"C8_REF"} // Array com os campos adicionados na grid "Produtos"
	Local aRetorno   := {}
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local nCount     := 0
	Local aAreaSC8   := SC8->(GetArea())
    Local Valor

	For nX := 1 To Len(aPropostas)
		For nY := 1 To Len(aPropostas[nX])
			For nZ := 1 To Len(aPropostas[nX][nY][2])
				nCount++

				//C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO
				If Len(aPropostas[nX][nY][1]) > 0
					AADD(aPropostas[nX][nY][2][nZ], Posicione("SC8",1,SC8->(C8_FILIAL+C8_NUM)+aPropostas[nX][nY][1][1]+aPropostas[nX][nY][1][2]+aPropostas[nX][nY][2][nZ][2]+aPropostas[nX][nY][2][nZ][12], "C8_PRECO"))
				Else
					AADD(aPropostas[nX][nY][2][nZ],0)
				EndIf
			Next nZ
		Next nY
	Next nX

	For nX := 1 To Len(aItens)
		//C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO
        Valor := U_BVAL()
		AADD(aItens[nX], Valor)
	Next nX

	AADD(aRetorno, aPropostas)
	AADD(aRetorno, aCampos)
	AADD(aRetorno, aItens)
	AADD(aRetorno, aCposProd)

	RestArea(aAreaSC8)

Return aRetorno
