# Documentação do arquivo MVCPERC.prw

Este arquivo é um código-fonte em ADVPL (Advanced Protheus Language), uma linguagem de programação proprietária do sistema de gestão empresarial Protheus da TOTVS.

O arquivo MVCPERC.prw é responsável pela implementação de uma rotina de cadastro de comissões para vendedores. Ele contém funções para a definição do modelo de dados, visualização, menu, validações e cálculos.

## Funções Principais

- `MVCPERC()`: Função principal que ativa a visualização do cadastro de comissões.
- `ModelDef()`: Define o modelo de dados para o cadastro de comissões.
- `ViewDef()`: Define a visualização para o cadastro de comissões.
- `MenuDef()`: Define o menu para o cadastro de comissões.
- `VldVen(CodVenD)`: Valida se o vendedor já possui uma regra de comissão.
- `VldDT(INI, FIM)`: Valida se a data inicial é menor que a data final.
- `VldEdT(INI)`: Valida se a data inicial é menor que a data atual.
- `VldPos(CodVenD, INI, FIM)`: Valida se já existe um cadastro para o vendedor no intervalo de tempo especificado.
- `fValGridCB8(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)`: Função de pre-validação da edição de linha do grid.
- `Calculo(oModel, nTotalAtual, xValor, lSomando)`: Realiza um cálculo de totalização.
- `fValVlr()`: Função de validação da edição de linha do grid.

## Como usar

Este arquivo deve ser compilado e executado dentro do ambiente Protheus. Para isso, você precisa ter acesso ao ambiente Protheus e ao SmartClient ou TDS (TOTVS Developer Studio).

## Licença

Este código é de propriedade da TOTVS e é protegido por direitos autorais. A distribuição ou cópia deste código sem permissão é estritamente proibida.