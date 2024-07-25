import { Directive, HostListener, ElementRef } from '@angular/core';

@Directive({
    selector: '[appDateMask]',
    standalone: true
})
export class DateMaskDirective {
    constructor(private el: ElementRef) { }

    @HostListener('input', ['$event'])
    onInput(event: Event): void {
        const input = event.target as HTMLInputElement;
        let value = input.value.replace(/\D/g, ''); // Remove all non-digit characters

        if (value.length > 2 && value.length <= 4) {
            value = value.replace(/^(\d{2})(\d{1,2})/, '$1/$2');
        } else if (value.length > 4) {
            value = value.replace(/^(\d{2})(\d{2})(\d{1,4})/, '$1/$2/$3');
        }

        input.value = value;
    }
}
