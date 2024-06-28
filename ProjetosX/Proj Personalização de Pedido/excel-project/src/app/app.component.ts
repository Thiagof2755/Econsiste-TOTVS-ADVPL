import { Component, OnInit } from '@angular/core';
import * as ExcelJS from 'exceljs';
import { saveAs } from 'file-saver';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';

interface Produto {
  caixas: number;
  descricao: string;
  precoUnitario: number;
  precoCaixa: number;
  total: number;
}

interface Pedido {
  numero: string;
  cliente: string;
  cnpj: string;
  endereco: string;
  cidade: string;
  email: string;
  prazoEntrega: string;
  produtos: Produto[];
  totalPedido: number;
  prazoPagamento: string;
  obs: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  standalone: true,
  imports: [CommonModule, HttpClientModule] // Adiciona HttpClientModule aqui
})
export class AppComponent implements OnInit {
  title = 'exceljs-angular';
  pedidos: Pedido[] = [];

  constructor(private http: HttpClient) { }

  ngOnInit() {
    this.fetchPedidos();
  }

  fetchPedidos() {
    this.http.get<{ ConsultarPedidos: Pedido[] }>('http://localhost:8080/rest/REESTPED/consultar/Pedidos')
      .subscribe(
        response => this.pedidos = response.ConsultarPedidos,
        error => console.error('Error fetching pedidos:', error)
      );
  }

  getTotalCaixas() {
    const totais: { [key: string]: number } = {};

    this.pedidos.forEach(pedido => {
      pedido.produtos.forEach(produto => {
        if (!totais[produto.descricao]) {
          totais[produto.descricao] = 0;
        }
        totais[produto.descricao] += produto.caixas;
      });
    });

    return Object.keys(totais).map(key => ({
      descricao: key,
      total: totais[key]
    }));
  }

  async exportToExcel() {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Pedidos');

    // Função para criar o cabeçalho
    const createHeader = () => {
      worksheet.mergeCells('A1:G1');
      worksheet.getCell('A1').value = 'Rodovia BR-153 - Lote 1-A - Zona de Expansão Industrial';
      worksheet.getCell('A1').font = { bold: true };
      worksheet.getCell('A1').alignment = { vertical: 'middle', horizontal: 'center' };

      worksheet.mergeCells('A2:G2');
      worksheet.getCell('A2').value = 'CEP: 75.340-000 - Hidrolândia - GO';
      worksheet.getCell('A2').font = { bold: true };
      worksheet.getCell('A2').alignment = { vertical: 'middle', horizontal: 'center' };

      worksheet.mergeCells('A3:G3');
      worksheet.getCell('A3').value = 'CNPJ: 24.849.580/0001-54 - I.E. 10.175.560-0';
      worksheet.getCell('A3').font = { bold: true };
      worksheet.getCell('A3').alignment = { vertical: 'middle', horizontal: 'center' };

      worksheet.mergeCells('A4:G4');
      worksheet.getCell('A4').value = 'Fone: (62) 3553-8000';
      worksheet.getCell('A4').font = { bold: true };
      worksheet.getCell('A4').alignment = { vertical: 'middle', horizontal: 'center' };

      worksheet.addRow([]);
    };

    createHeader();

    this.pedidos.forEach(pedido => {
      const currentRow = worksheet.rowCount + 1;

      // Dados do Cliente na Coluna A
      worksheet.getCell(`A${currentRow}`).value = `Numero: ${pedido.numero}`;
      worksheet.getCell(`A${currentRow}`).font = { bold: true, color: { argb: 'FFFFFFFF' } }; // Define a fonte branca

      // Preencher a célula com cor azul e definir a fonte branca
      worksheet.getCell(`A${currentRow}`).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF000080' } // Cor azul
      };
      worksheet.getCell(`A${currentRow}`).font = { bold: true, color: { argb: 'FFFFFFFF' } };
      worksheet.getCell(`A${currentRow + 1}`).value = `CLIENTE: ${pedido.cliente}`;
      worksheet.getCell(`A${currentRow + 1}`).font = { bold: true };

      worksheet.getCell(`A${currentRow + 2}`).value = `CNPJ: ${pedido.cnpj}`;
      worksheet.getCell(`A${currentRow + 2}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 3}`).value = `ENDEREÇO: ${pedido.endereco}`;
      worksheet.getCell(`A${currentRow + 3}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 4}`).value = `CIDADE: ${pedido.cidade}`;
      worksheet.getCell(`A${currentRow + 4}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 5}`).value = `E-MAIL: ${pedido.email}`;
      worksheet.getCell(`A${currentRow + 5}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 6}`).value = `PRAZO DE ENTREGA: ${pedido.prazoEntrega}`;
      worksheet.getCell(`A${currentRow + 6}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 7}`).value = `PRAZO DE PAGAMENTO: ${pedido.prazoPagamento}`;
      worksheet.getCell(`A${currentRow + 7}`).font = { bold: true };
      worksheet.getCell(`A${currentRow + 8}`).value = `OBS: ${pedido.obs}`;
      worksheet.getCell(`A${currentRow + 8}`).font = { bold: true };

      // Cabeçalho dos Produtos na Coluna C e subsequentes, começando na mesma linha que os dados do cliente
      const productHeaderRow = currentRow;
      worksheet.getCell(`B${productHeaderRow}`).value = 'CAIXAS';
      worksheet.getCell(`C${productHeaderRow}`).value = 'PRODUTO';
      worksheet.getCell(`D${productHeaderRow}`).value = 'PREÇO UNITÁRIO';
      worksheet.getCell(`E${productHeaderRow}`).value = 'PREÇO CAIXA';
      worksheet.getCell(`F${productHeaderRow}`).value = 'TOTAL';
      ['B', 'C', 'D', 'E', 'F'].forEach(col => {
        const cell = worksheet.getCell(`${col}${productHeaderRow}`);
        cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
        cell.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FF000080' },

        };
        cell.alignment = { vertical: 'middle', horizontal: 'center' };
      });

      // Itens do Pedido, começando na linha após os dados do cliente
      pedido.produtos.forEach((produto, index) => {
        const productRow = productHeaderRow + index + 1;
        worksheet.getCell(`B${productRow}`).value = produto.caixas;
        worksheet.getCell(`C${productRow}`).value = produto.descricao;
        worksheet.getCell(`D${productRow}`).value = `R$ ${produto.precoUnitario.toFixed(2)}`;
        worksheet.getCell(`E${productRow}`).value = `R$ ${produto.precoCaixa.toFixed(2)}`;
        worksheet.getCell(`F${productRow}`).value = `R$ ${produto.total.toFixed(2)}`;
        // Centralizar as células
        ['B', 'C', 'D', 'E', 'F'].forEach(col => {
          const cell = worksheet.getCell(`${col}${productRow}`);
          cell.alignment = { vertical: 'middle', horizontal: 'center' };
        });
      });

      // Total do Pedido, após os itens do pedido ou abaixo da OBS
      const lastDataRow = currentRow + 8; // Linha onde terminam os dados do cliente e OBS
      const lastProductRow = productHeaderRow + pedido.produtos.length; // Linha onde terminam os produtos

      const totalRow = Math.max(lastDataRow, lastProductRow) + 1; // Seleciona a maior linha entre dados e produtos e adiciona uma linha

      const totalCellD = worksheet.getCell(`E${totalRow}`);
      totalCellD.value = 'TOTAL DO PEDIDO';
      totalCellD.font = { bold: true, color: { argb: 'FFFFFFFF' } }; // Fonte branca
      totalCellD.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF000080' } // Fundo azul
      };
      totalCellD.alignment = { vertical: 'middle', horizontal: 'right' };

      const totalCellE = worksheet.getCell(`F${totalRow}`);
      totalCellE.value = `R$ ${pedido.totalPedido.toFixed(2)}`;
      totalCellE.font = { bold: true, color: { argb: '0000000' } }; // Fonte branca
      totalCellE.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFFFFFFF' } // Fundo azul
      };
      totalCellE.alignment = { vertical: 'middle', horizontal: 'center' };

      worksheet.addRow([]);
      worksheet.addRow([]);
      worksheet.addRow([]);
      worksheet.addRow([]);
    });

    // Adicionar a tabela de total de caixas
    const totalTableHeaderRow = worksheet.rowCount + 1;
    worksheet.getCell(`A${totalTableHeaderRow}`).value = 'Descrição';
    worksheet.getCell(`B${totalTableHeaderRow}`).value = 'Total de Caixas';
    ['A', 'B'].forEach(col => {
      const cell = worksheet.getCell(`${col}${totalTableHeaderRow}`);
      cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      cell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF000080' }
      };
      cell.alignment = { vertical: 'middle', horizontal: 'center' };
    });

    const totals = this.getTotalCaixas();

    totals.forEach((total, index) => {
      const totalRow = totalTableHeaderRow + index + 1;
      worksheet.getCell(`A${totalRow}`).value = total.descricao;
      worksheet.getCell(`B${totalRow}`).value = total.total;
    });

    try {
      const buffer = await workbook.xlsx.writeBuffer();
      saveAs(new Blob([buffer]), 'Pedidos.xlsx');
    } catch (error) {
      console.error('Error exporting to Excel:', error);
    }
  }
}