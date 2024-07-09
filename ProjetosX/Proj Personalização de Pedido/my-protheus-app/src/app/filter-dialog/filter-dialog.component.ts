import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-filter-dialog',
  templateUrl: './filter-dialog.component.html',
  styleUrls: ['./filter-dialog.component.css'],
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule // Importando ReactiveFormsModule
  ]
})
export class FilterDialogComponent {
  filterForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    public dialogRef: MatDialogRef<FilterDialogComponent>
  ) {
    this.filterForm = this.fb.group({
      clienteDe: ['', [Validators.required, Validators.maxLength(6)]],
      clienteAte: ['', [Validators.required, Validators.maxLength(6)]],
      dataDe: ['', Validators.required],
      dataAte: ['', Validators.required]
    });
  }

  private formatDate(date: string): string {
    return date.replace(/-/g, '');
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
      clienteDe: '000000',
      clienteAte: 'zzzzzz',
      dataDe: '20230101',
      dataAte: this.formatDate(today.toISOString().split('T')[0])
    });
  }
}
