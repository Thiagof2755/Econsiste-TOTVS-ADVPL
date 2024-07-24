# Protheus API Pedidos em Aberto

Este projeto é uma solução completa composta por uma API RESTful desenvolvida em AdvPL para consultar pedidos em aberto no sistema Protheus, e um front-end em Angular que consome essa API, exibe os pedidos e permite a exportação dos dados para um arquivo Excel.


## Descrição

Este projeto foi criado para facilitar a consulta e o gerenciamento de pedidos em aberto no sistema Protheus. Ele inclui uma API backend em AdvPL que fornece os dados dos pedidos e um frontend em Angular para exibir esses dados e possibilitar a exportação para Excel.

## Funcionalidade

- **API RESTful em AdvPL**: Permite a consulta de pedidos em aberto no sistema Protheus com base em filtros opcionais de cliente e data.
- **Frontend em Angular**: Consome a API, exibe os pedidos em uma tabela e permite a exportação dos dados para um arquivo Excel.
- **Exportação para Excel**: Gera um arquivo Excel com os detalhes dos pedidos, incluindo cliente, produtos, prazos e valores totais.

## Estrutura do Projeto

### Backend (API AdvPL)

- **Arquivo Principal**: `REESTPED.PRW`
- **Função Principal**: `ConsultarPedidos`
- **Estrutura de Dados**:
  - `clienteDe` (opcional): Código inicial do cliente.
  - `clienteAte` (opcional): Código final do cliente.
  - `dataDe` (opcional): Data inicial dos pedidos (formato `YYYYMMDD`).
  - `dataAte` (opcional): Data final dos pedidos (formato `YYYYMMDD`).

### Frontend (Angular)

- **Componente Principal**: `AppComponent`
- **Componentes Auxiliares**:
  - `FilterDialogComponent`: Diálogo para aplicar filtros aos pedidos.
- **Bibliotecas Utilizadas**:
  - `HttpClient`: Para fazer requisições HTTP à API.
  - `ExcelJS`: Para gerar o arquivo Excel.
  - `FileSaver`: Para salvar o arquivo Excel no cliente.
  - `Angular Material`: Para UI e diálogos.


## Uso

### Backend (API AdvPL)

Para consultar os pedidos em aberto, envie uma requisição GET para o endpoint `/consultar/Pedidos` com os seguintes parâmetros opcionais:

- `clienteDe`: Código inicial do cliente.
- `clienteAte`: Código final do cliente.
- `dataDe`: Data inicial dos pedidos (formato `YYYY-MM-DD`).
- `dataAte`: Data final dos pedidos (formato `YYYY-MM-DD`).

Exemplo de URL:

```
http://<SEU_SERVIDOR>/rest/REESTPED/consultar/Pedidos?clienteDe=000000&clienteAte=zzzzzz&dataDe=2023-01-01&dataAte=2024-12-31
```

### Frontend (Angular)

A aplicação Angular permite:

1. **Filtrar Pedidos**:
   - Ao iniciar a aplicação, um diálogo de filtro é exibido.
   - O usuário pode inserir os códigos dos clientes e as datas para filtrar os pedidos.

2. **Exibir Pedidos**:
   - Os pedidos filtrados são exibidos em uma tabela na interface do usuário.

3. **Exportar para Excel**:
   - Clique no botão "Exportar para Excel" para gerar um arquivo Excel com os detalhes dos pedidos.


## Licença

Este projeto está licenciado sob a licença MIT

