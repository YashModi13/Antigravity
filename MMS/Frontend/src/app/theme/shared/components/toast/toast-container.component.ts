import { Component, inject } from '@angular/core';
import { ToastService } from './toast.service';
import { NgbToastModule } from '@ng-bootstrap/ng-bootstrap';
import { NgFor, NgIf, NgTemplateOutlet } from '@angular/common';

@Component({
  selector: 'app-toasts',
  standalone: true,
  imports: [NgbToastModule, NgFor, NgIf, NgTemplateOutlet],
  template: `
    <ngb-toast
      *ngFor="let toast of toastService.toasts"
      [class]="toast.classname"
      [autohide]="true"
      [delay]="toast.delay || 5000"
      (hidden)="toastService.remove(toast)"
      class="mb-2"
    >
      <ng-container *ngIf="isTemplate(toast); else text">
        <ng-container [ngTemplateOutlet]="toast.textOrTpl"></ng-container>
      </ng-container>

      <ng-template #text>{{ toast.textOrTpl }}</ng-template>
    </ngb-toast>
  `,
  host: {
    class: 'toast-container position-fixed top-0 end-0 p-3',
    style: 'z-index: 1200; margin-top: 55px;'
  }
})
export class ToastsContainerComponent {
  toastService = inject(ToastService);

  isTemplate(toast: any) {
    return toast.textOrTpl instanceof Object;
  }
}
