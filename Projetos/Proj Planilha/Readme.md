# WWESTM04 - Excel to CSV Converter for Protheus

Este repositório contém o script `WWESTM04.prw`, que é responsável por converter arquivos Excel (.xls e .xlsx) em arquivos CSV, para importação no sistema Protheus da TOTVS.

## Descrição

O script `WWESTM04` realiza as seguintes operações:
- Seleção de um arquivo Excel a partir de um diálogo de arquivo.
- Conversão do arquivo Excel selecionado para o formato CSV.
- Importação dos dados do arquivo CSV para o sistema Protheus.

### Estrutura do Código

1. **WWESTM04**
   - Função principal que gerencia a seleção e conversão do arquivo Excel para CSV.
   - Se o arquivo selecionado for válido, chama a função `fXLStoCSV` para realizar a conversão.
   - Em seguida, chama a função `fImporta` para importar os dados do CSV para o sistema Protheus.

2. **fImporta**
   - Função que processa o arquivo CSV e realiza a importação dos dados para o Protheus.
   - Abre o arquivo CSV e lê suas linhas.
   - Realiza a transação de importação, linha por linha, verificando erros e gerando logs conforme necessário.

3. **fExecAuto**
   - Executa a importação automática dos dados no sistema Protheus.
   - Gera logs de sucesso ou erro durante a importação.

4. **fXLStoCSV**
   - Função que realiza a conversão do arquivo Excel (.xls ou .xlsx) para CSV usando um script VBScript.

## Pré-requisitos

Para executar o script, você precisa ter:
- TOTVS Protheus configurado.
- Permissões adequadas para execução de scripts e importação de dados no sistema.
- Ambiente configurado para execução de VBScript no Windows.

## Como Executar

1. **Clonar o repositório:**
   ```sh
   git clone https://github.com/.......
   cd seu-repositorio
   ```

2. **Abrir o Protheus e executar o script:**
   - Abra o ambiente de desenvolvimento do Protheus.
   - Carregue e execute o script `WWESTM04.prw`.

3. **Seleção do Arquivo:**
   - Um diálogo de arquivo será exibido para que você selecione o arquivo Excel a ser convertido.
   - Após a seleção, o script converterá o arquivo para CSV e iniciará a importação.

## Notas

- O script utiliza um VBScript para realizar a conversão de Excel para CSV. Certifique-se de que seu ambiente permite a execução de scripts VBScript.
- Logs de erro e sucesso são gerados durante a importação para facilitar a verificação e solução de problemas.

## Referências

- Baseado na solução encontrada em: [Saulo Martins - GitHub](https://github.com/saulogm/advpl-excel)

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo `LICENSE` para obter mais detalhes.


