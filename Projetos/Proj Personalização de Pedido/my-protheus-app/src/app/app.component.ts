import { Component, OnInit } from '@angular/core';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { HttpClient, HttpClientModule, HttpHeaders } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { FilterDialogComponent } from './filter-dialog/filter-dialog.component';
import * as ExcelJS from 'exceljs';
import { saveAs } from 'file-saver';
import { CommonModule } from '@angular/common';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { tap } from 'rxjs/operators';
import jwt_decode from 'jwt-decode';

interface Produto {
  caixas: number;
  descricao: string;
  precoUnitario: number;
  precoCaixa: number;
  total: number;
}

interface DecodedToken {
  userid: string;
}

interface Pedido {
  numero: string;
  codVendedor: string;
  vendedor: string;
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
  totalDesconto: number;
  percentualdesconto: number;
}


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  standalone: true,
  imports: [
    CommonModule,
    HttpClientModule,
    MatDialogModule,
    FormsModule,
    MatProgressSpinnerModule,
    FilterDialogComponent,
  ]
})
export class AppComponent implements OnInit {
  
  title = 'exceljs-angular';  
  pedidos: Pedido[] = [];
  isLoading = false;
  tokenx: string | null;


  // Injete o serviço no construtor
  constructor(private http: HttpClient, public dialog: MatDialog) {
    this.tokenx = sessionStorage.getItem("ERPTOKEN") || "TESTE"; // Obtenha o token da sessionStorage
    //this.testeurl =  `http://192.158.15.108:8080/rest/REESTPED/consultar/Pedidos?vendedorDe=000000&vendedorate=zzzzzz&dataDe=20210101&dataAte=20250101&filial=&pedidoDe=000000&pedidoAte=zzzzzz&usuario=zzzzz`;
    
  
  }

  ngOnInit() {
    this.openFilterDialog(); // Abra o filtro
  }

  openFilterDialog(): void {
    const dialogRef = this.dialog.open(FilterDialogComponent, {
      width: '300px',
      disableClose: true // Desabilita o fechamento ao clicar fora do diálogo
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.fetchPedidos(result);
      }
    });
  }

//**************************************DECODE TOKEN************************************ */

base64UrlDecode(base64Url: string): string {
    // Substitua os caracteres não padrão do Base64 URL
    let base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    // Adicione o padding se necessário
    switch (base64.length % 4) {
      case 0:
        break; // No padding needed
      case 2:
        base64 += '==';
        break; // Pad to 4 bytes
      case 3:
        base64 += '=';
        break; // Pad to 4 bytes
      default:
        throw new Error('Illegal base64url string!');
    }
    // Decodifique base64 para UTF-8
    return atob(base64);
  }

  decodeJwtToken(token: string): DecodedToken {
    const parts = token.split('.');
    if (parts.length !== 3) {
      throw new Error('JWT does not have 3 parts!');
    }

    const payload = parts[1];
    const decodedPayload = this.base64UrlDecode(payload);
    
    return JSON.parse(decodedPayload);
}


  fetchPedidos(filter: { vendedorDe: string, vendedorate: string, dataDe: string, dataAte: string ,pedidoDe: string, pedidoAte: string}) {
    this.isLoading = true;

    // Obtenha os dados da sessionStorage
    const proBranch = sessionStorage.getItem("ProBranch");
    const Dtoken = sessionStorage.getItem("ERPTOKEN");
    let usuario: string | null = null;

  // Parseie o token para obter o access_token
  const tokenObj = Dtoken ? JSON.parse(Dtoken) : null;
  const accessToken = tokenObj ? tokenObj.access_token : '';
  if (accessToken) {
    try {
      const decodedToken = this.decodeJwtToken(accessToken);
      usuario = decodedToken.userid;
      console.log('Token decodificado:', decodedToken);
    } catch (error) {
      usuario = 'Erro ao decodificar o token:';
      console.error('Erro ao decodificar o token:', error);
  }
}
  
    // Adicione a filial como um parâmetro de consulta
    const filial = proBranch || '{"Code":"XX"}'; // Usa a filial



    //const url = `http://192.168.55.235:8996/rest/REESTPED/consultar/Pedidos?vendedorDe=${filter.vendedorDe}&vendedorate=${filter.vendedorate}&dataDe=${filter.dataDe}&dataAte=${filter.dataAte}&filial=${filial}`;
    const url =  `http://192.168.55.235:8996/rest/REESTPED/consultar/Pedidos?vendedorDe=${filter.vendedorDe}&vendedorate=${filter.vendedorate}&dataDe=${filter.dataDe}&dataAte=${filter.dataAte}&filial=${filial}&pedidoDe=${filter.pedidoDe}&pedidoAte=${filter.pedidoAte}&usuario=${usuario}`;
   // const url = `http://127.0.0.1:8080/rest/REESTPED/consultar/Pedidos?vendedorDe=${filter.vendedorDe}&vendedorate=${filter.vendedorate}&dataDe=${filter.dataDe}&dataAte=${filter.dataAte}&filial=${filial}&pedidoDe=${filter.pedidoDe}&pedidoAte=${filter.pedidoAte}&usuario=${usuario}`;

    // Adicione os cabeçalhos com o token
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${accessToken}`
    });
    console.log('Token:', accessToken);
    console.log('URL:', url);

    // Faça a requisição com os cabeçalhos
    this.http.get<{ ConsultarPedidos: Pedido[] }>(url, { headers }).pipe(
      tap(response => {
        console.log('Response:', response);
      })
    ).subscribe(
      response => {
        this.pedidos = response.ConsultarPedidos;
        console.log('Pedidos:', this.pedidos);
        this.isLoading = false;
      },
      error => {
        console.error('Error fetching pedidos:', error);
        this.isLoading = false;
      }
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

      worksheet.getCell(`A${currentRow}`).value = `Numero: ${pedido.numero}          Vendedor: ${pedido.codVendedor}   -   ${pedido.vendedor}`;
      worksheet.getCell(`A${currentRow}`).font = { bold: true, color: { argb: 'FFFFFFFF' } };
      worksheet.getCell(`A${currentRow}`).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF000080' }
      };

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
      worksheet.getCell(`A${currentRow + 9}`).value = `Descontos: ${pedido.percentualdesconto}%`;
      worksheet.getCell(`A${currentRow + 9}`).font = { bold: true };

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
          fgColor: { argb: 'FF000080' }
        };
        cell.alignment = { vertical: 'middle', horizontal: 'center' };
      });

      pedido.produtos.forEach((produto, index) => {
        const productRow = productHeaderRow + index + 1;
        worksheet.getCell(`B${productRow}`).value = produto.caixas;
        worksheet.getCell(`C${productRow}`).value = produto.descricao;
        worksheet.getCell(`D${productRow}`).value = `R$ ${produto.precoUnitario.toFixed(2)}`;
        worksheet.getCell(`E${productRow}`).value = `R$ ${produto.precoCaixa.toFixed(2)}`;
        worksheet.getCell(`F${productRow}`).value = `R$ ${produto.total.toFixed(2)}`;
        ['B', 'C', 'D', 'E', 'F'].forEach(col => {
          const cell = worksheet.getCell(`${col}${productRow}`);
          cell.alignment = { vertical: 'middle', horizontal: 'center' };
        });
      });

      const lastDataRow = currentRow + 8;
      const lastProductRow = productHeaderRow + pedido.produtos.length;
      const totalRow = Math.max(lastDataRow, lastProductRow) + 1;

      const totalCellD = worksheet.getCell(`E${totalRow}`);
      totalCellD.value = 'TOTAL DO PEDIDO';
      totalCellD.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      totalCellD.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF000080' }
      };
      totalCellD.alignment = { vertical: 'middle', horizontal: 'right' };

      const totalCellE = worksheet.getCell(`F${totalRow}`);
      totalCellE.value = `R$ ${pedido.totalPedido.toFixed(2)}`;
      totalCellE.font = { bold: true, color: { argb: '0000000' } };
      totalCellE.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFFFFFFF' }
      };
      totalCellE.alignment = { vertical: 'middle', horizontal: 'center' };

      // total com desconto

      const totalDescontoCellD = worksheet.getCell(`E${totalRow + 1}`);
      totalDescontoCellD.value = 'TOTAL C/DESCONTO';
      totalDescontoCellD.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      totalDescontoCellD.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF000080' } };
      totalDescontoCellD.alignment = { vertical: 'middle', horizontal: 'right' };
      
      const totalDescontoCellE = worksheet.getCell(`F${totalRow + 1}`);
      totalDescontoCellE.value = `R$ ${pedido.totalDesconto.toFixed(2)}`;
      totalDescontoCellE.font = { bold: true, color: { argb: '0000000' } };
      totalDescontoCellE.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFFFFFFF' } };
      totalDescontoCellE.alignment = { vertical: 'middle', horizontal: 'center' };
      

      worksheet.addRow([]);
      worksheet.addRow([]);
      worksheet.addRow([]);
      worksheet.addRow([]);
    });

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
