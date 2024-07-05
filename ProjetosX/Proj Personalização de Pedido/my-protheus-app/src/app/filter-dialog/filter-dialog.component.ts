import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-filter-dialog',
  templateUrl: './filter-dialog.component.html',
  styleUrls: ['./filter-dialog.component.css'],
  standalone: true,
  imports: [
    MatFormFieldModule,
    MatInputModule,
    FormsModule,
    ReactiveFormsModule,
    MatIconModule,
    MatButtonModule
  ]
})
export class FilterDialogComponent {
  filterForm: FormGroup;

  constructor(
    public dialogRef: MatDialogRef<FilterDialogComponent>,
    private fb: FormBuilder
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
    this.dialogRef.close();
  }

  resetAndClose() {
    const today = new Date();
    this.dialogRef.close({
      clienteDe: '000000',
      clienteAte: 'zzzzzz',
      dataDe: '20000101',
      dataAte: this.formatDate(today.toISOString().split('T')[0])
    });
  }
}
