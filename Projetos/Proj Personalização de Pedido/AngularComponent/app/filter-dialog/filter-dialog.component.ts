import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';
import { DateMaskDirective } from './date-mask.directive';  // Importe a diretiva

@Component({
  selector: 'app-filter-dialog',
  templateUrl: './filter-dialog.component.html',
  styleUrls: ['./filter-dialog.component.css'],
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    DateMaskDirective  // Adicione a diretiva
  ]
})
export class FilterDialogComponent {
  filterForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    public dialogRef: MatDialogRef<FilterDialogComponent>
  ) {
    this.filterForm = this.fb.group({
      vendedorDe: ['', [Validators.required, Validators.maxLength(6)]],
      vendedorate: ['', [Validators.required, Validators.maxLength(6)]],
      pedidoDe: ['', [Validators.required, Validators.maxLength(6)]],
      pedidoAte: ['', [Validators.required, Validators.maxLength(6)]],
      dataDe: ['', [Validators.required, this.dateValidator]],
      dataAte: ['', [Validators.required, this.dateValidator]]
    });   
  }

  private dateValidator(control: AbstractControl): ValidationErrors | null {
    const datePattern = /^\d{2}\/\d{2}\/\d{4}$/;
    if (!control.value || datePattern.test(control.value)) {
      return null;
    }
    return { dateInvalid: true };
  }

  private formatDate(date: string): string {
    const [day, month, year] = date.split('/');
    return `${year}${month}${day}`;
  }

  applyFilter() {
    if (this.filterForm.valid) {
      const formData = this.filterForm.value;
      formData.dataDe = this.formatDate(formData.dataDe);
      formData.dataAte = this.formatDate(formData.dataAte);
      this.dialogRef.close(formData);
    }
  }

  cancel() {
    this.dialogRef.close(null);
  }

  resetAndClose() {
    const today = new Date();
    this.dialogRef.close({
      vendedorDe: '000000',
      vendedorate: 'zzzzzz',
      pedidoDe: '000000',
      pedidoAte: 'zzzzzz',
      dataDe: '20000101',
      dataAte: this.formatDate(today.toISOString().split('T')[0].split('-').reverse().join('/'))
    });
  }
}
