import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MmsService } from '../mms.service';
import { SharedModule } from '../../theme/shared/shared.module';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule, SharedModule, FormsModule],
  template: `
    <div class="row">
      <div class="col-sm-12">
        <div class="card shadow-sm border-0">
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

    <!-- Error Modal -->
    <div class="modal-overlay" *ngIf="showErrorModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0 overflow-hidden bg-white" style="max-width: 450px;">
          <div class="modal-body p-5 text-center">
            <div class="error-icon-wrapper mb-4">
              <div class="error-icon-bg shadow-sm">
                <i class="feather icon-alert-circle" style="font-size: 3rem; color: #e74c3c;"></i>
              </div>
            </div>
            <h4 class="fw-bold text-dark mb-3">Operation Failed</h4>
            <p class="text-danger mb-4 px-3 fw-medium lh-base">{{statusMessage}}</p>
            <button type="button" class="btn btn-secondary px-5 py-3 rounded-pill shadow-sm fw-bold w-100" (click)="showErrorModal = false">
              <i class="feather icon-x-circle me-2"></i>Close
            </button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .bg-light-primary { background-color: rgba(70, 128, 255, 0.1); }
    .bg-light-success { background-color: rgba(46, 204, 113, 0.1); }
    .bg-light-warning { background-color: rgba(241, 196, 15, 0.1); }
    .bg-light-danger { background-color: rgba(231, 76, 60, 0.1); }
    .bg-light-info { background-color: rgba(62, 166, 255, 0.08) !important; }
    .transition { transition: all 0.3s ease-in-out; }
    .hover-shadow:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important; }
    .hover-shadow { border: 1px solid #eee !important; }

    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.7);
      backdrop-filter: blur(8px);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10000;
      animation: fadeIn 0.2s ease-out;
    }

    .modal-content {
      background: #ffffff !important;
      border-radius: 1.25rem;
      animation: slideIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25) !important;
    }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideIn { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

    .error-icon-bg {
      width: 100px;
      height: 100px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto;
      background: #fff5f5; 
      border: 5px solid #ffffff;
    }
  `]
})
export class ReportsComponent implements OnInit {
  loading: { [key: string]: boolean } = {};
  showErrorModal = false;
  statusMessage = '';

  constructor(private mmsService: MmsService) { }

  ngOnInit() {
  }

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
        this.statusMessage = 'Failed to generate report. Please try again.';
        this.showErrorModal = true;
        this.loading[type] = false;
      }
    });
  }
}
