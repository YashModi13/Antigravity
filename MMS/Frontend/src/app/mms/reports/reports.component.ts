import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MmsService } from '../mms.service';
import { SharedModule } from '../../theme/shared/shared.module';

@Component({
    selector: 'app-reports',
    standalone: true,
    imports: [CommonModule, SharedModule],
    template: `
    <div class="row">
      <div class="col-sm-12">
        <div class="card shadow-sm">
          <div class="card-header bg-white pt-4 pb-0 border-bottom-0">
            <h5 class="text-primary mb-0"><i class="feather icon-file-text me-2"></i>Report Center</h5>
            <p class="text-muted small mt-2">Generate and download business reports in Excel format.</p>
          </div>
          <div class="card-body pt-0">
            <div class="row g-4 mt-2">
              <!-- Deposits Report -->
              <div class="col-md-4">
                <div class="card h-100 border border-light shadow-sm hover-shadow transition">
                  <div class="card-body text-center p-4">
                    <div class="rounded-circle bg-light-primary d-inline-flex p-3 mb-3 text-primary">
                      <i class="feather icon-list" style="font-size: 2rem;"></i>
                    </div>
                    <h6 class="fw-bold">Deposits Report</h6>
                    <p class="text-muted small mb-4">Export all active customer deposits with interest details.</p>
                    <button class="btn btn-primary w-100" (click)="download('deposits')" [disabled]="loading['deposits']">
                      <span *ngIf="loading['deposits']" class="spinner-border spinner-border-sm me-1"></span>
                      <i *ngIf="!loading['deposits']" class="feather icon-download me-2"></i>Download XLSX
                    </button>
                  </div>
                </div>
              </div>

              <!-- Customers Report -->
              <div class="col-md-4">
                <div class="card h-100 border border-light shadow-sm hover-shadow transition">
                  <div class="card-body text-center p-4">
                    <div class="rounded-circle bg-light-success d-inline-flex p-3 mb-3 text-success">
                      <i class="feather icon-users" style="font-size: 2rem;"></i>
                    </div>
                    <h6 class="fw-bold">Customers Master</h6>
                    <p class="text-muted small mb-4">Full directory of registered customers and contact info.</p>
                    <button class="btn btn-success w-100" (click)="download('customers')" [disabled]="loading['customers']">
                      <span *ngIf="loading['customers']" class="spinner-border spinner-border-sm me-1"></span>
                      <i *ngIf="!loading['customers']" class="feather icon-download me-2"></i>Download XLSX
                    </button>
                  </div>
                </div>
              </div>

              <!-- Merchant Report -->
              <div class="col-md-4">
                <div class="card h-100 border border-light shadow-sm hover-shadow transition">
                  <div class="card-body text-center p-4">
                    <div class="rounded-circle bg-light-warning d-inline-flex p-3 mb-3 text-warning">
                      <i class="feather icon-briefcase" style="font-size: 2rem;"></i>
                    </div>
                    <h6 class="fw-bold">Merchant Transfers</h6>
                    <p class="text-muted small mb-4">Monitor active re-pledges and merchant account status.</p>
                    <button class="btn btn-warning w-100 text-dark" (click)="download('merchants')" [disabled]="loading['merchants']">
                      <span *ngIf="loading['merchants']" class="spinner-border spinner-border-sm me-1"></span>
                      <i *ngIf="!loading['merchants']" class="feather icon-download me-2"></i>Download XLSX
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
    styles: [`
    .bg-light-primary { background-color: rgba(70, 128, 255, 0.1); }
    .bg-light-success { background-color: rgba(46, 204, 113, 0.1); }
    .bg-light-warning { background-color: rgba(241, 196, 15, 0.1); }
    .transition { transition: all 0.3s ease-in-out; }
    .hover-shadow:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important; }
    .hover-shadow { border: 1px solid #eee !important; }
  `]
})
export class ReportsComponent {
    loading: { [key: string]: boolean } = {};

    constructor(private mmsService: MmsService) { }

    download(type: string) {
        this.loading[type] = true;
        this.mmsService.downloadReport(type).subscribe({
            next: (blob) => {
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `${type}_report_${new Date().toISOString().split('T')[0]}.xlsx`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                this.loading[type] = false;
            },
            error: (err) => {
                console.error('Download failed', err);
                alert('Failed to generate report. Please try again.');
                this.loading[type] = false;
            }
        });
    }
}
