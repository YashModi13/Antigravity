import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MmsService } from '../mms.service';
import { SharedModule } from '../../theme/shared/shared.module';
import { FormsModule } from '@angular/forms';

@Component({
    selector: 'app-backup-restore',
    standalone: true,
    imports: [CommonModule, SharedModule, FormsModule],
    template: `
    <div class="row">
      <div class="col-sm-12">
        <div class="card shadow-sm border-0">
          <div class="card-header bg-white pt-4 pb-0 border-bottom-0">
            <h5 class="text-danger mb-0"><i class="feather icon-database me-2"></i>Backup & Maintenance</h5>
            <p class="text-muted small mt-2">Manage database backups and perform system restoration.</p>
          </div>
          <div class="card-body pt-0">
            
            <div class="row g-4 mt-2">
               <!-- Database Backup -->
               <div class="col-md-4">
                <div class="card h-100 border border-light shadow-sm hover-shadow transition">
                  <div class="card-body text-center p-4">
                    <div class="rounded-circle bg-light-danger d-inline-flex p-3 mb-3 text-danger">
                      <i class="feather icon-database" style="font-size: 2rem;"></i>
                    </div>
                    <h6 class="fw-bold">Full Schema Backup</h6>
                    <p class="text-muted small mb-4">Download a complete SQL dump of the MMS schema for recovery.</p>
                    <button class="btn btn-danger w-100" (click)="backup()" [disabled]="loading['backup']">
                      <span *ngIf="loading['backup']" class="spinner-border spinner-border-sm me-1"></span>
                      <i *ngIf="!loading['backup']" class="feather icon-shield me-2"></i>Generate Backup
                    </button>
                  </div>
                </div>
              </div>

              <!-- Database Restore -->
              <div class="col-md-8">
                <div class="card h-100 border border-light shadow-sm">
                  <div class="card-header py-3 bg-light">
                    <h6 class="mb-0 fw-bold text-danger"><i class="feather icon-upload-cloud me-2"></i>Database Restore Panel</h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label small fw-bold">DB Host</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.host">
                      </div>
                      <div class="col-md-3">
                        <label class="form-label small fw-bold">Port</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.port">
                      </div>
                      <div class="col-md-3">
                        <label class="form-label small fw-bold">DB Name</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.db">
                      </div>
                      <div class="col-md-4">
                        <label class="form-label small fw-bold">DB User</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.user">
                      </div>
                      <div class="col-md-4">
                        <label class="form-label small fw-bold">DB Pass</label>
                        <input type="password" class="form-control form-control-sm" [(ngModel)]="restoreParams.pass">
                      </div>
                      <div class="col-md-4">
                        <label class="form-label small fw-bold">Target Schema</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.schema">
                      </div>
                      <div class="col-md-12">
                        <label class="form-label small fw-bold">PSQL Path (on Server)</label>
                        <input type="text" class="form-control form-control-sm" [(ngModel)]="restoreParams.psqlPath">
                      </div>
                    </div>
                    
                    <hr class="my-4">
                    
                    <div class="d-flex align-items-center">
                      <div class="flex-grow-1">
                        <p class="text-muted small mb-0"><i class="feather icon-alert-triangle text-warning me-1"></i>Warning: Restoration will delete all existing data in the target schema.</p>
                      </div>
                      <input type="file" #fileInput (change)="onFileSelected($event)" accept=".sql" style="display: none;">
                      <button class="btn btn-danger" (click)="fileInput.click()" [disabled]="loading['restore']">
                        <span *ngIf="loading['restore']" class="spinner-border spinner-border-sm me-1"></span>
                        <i *ngIf="!loading['restore']" class="feather icon-refresh-cw me-2"></i>Select File & Restore
                      </button>
                    </div>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Premium Restore Confirmation Modal -->
    <div class="modal-overlay" *ngIf="showConfirmModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0 overflow-hidden bg-white">
          <div class="modal-header bg-danger text-white p-4">
            <h5 class="modal-title d-flex align-items-center fw-bold">
              <i class="feather icon-alert-octagon me-3 fs-3"></i>
              Restore Confirmation
            </h5>
            <button type="button" class="btn-close btn-close-white" (click)="showConfirmModal = false"></button>
          </div>
          <div class="modal-body p-4">
            <div class="alert alert-warning border-warning shadow-sm mb-4">
               <div class="d-flex">
                 <i class="feather icon-alert-triangle fs-4 me-3 text-warning"></i>
                 <div>
                   <h6 class="fw-bold text-dark mb-1">CRITICAL WARNING</h6>
                   <p class="small mb-0 text-dark opacity-75">All data in <strong>'{{restoreParams.schema}}'</strong> will be wiped. This is irreversible.</p>
                 </div>
               </div>
            </div>

            <div class="card border-0 shadow-sm rounded-3 bg-light">
              <ul class="list-group list-group-flush small bg-transparent">
                <li class="list-group-item d-flex justify-content-between p-3 bg-transparent">
                  <span class="text-muted fw-bold">Server Host</span>
                  <span class="text-dark fw-bold">{{restoreParams.host}}:{{restoreParams.port}}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between p-3 bg-transparent">
                  <span class="text-muted fw-bold">Database</span>
                  <span class="text-dark fw-bold font-monospace">{{restoreParams.db}}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between p-3 bg-transparent">
                  <span class="text-muted fw-bold">Schema</span>
                  <span class="text-danger fw-bold">{{restoreParams.schema}}</span>
                </li>
                <li class="list-group-item d-flex justify-content-between p-3 bg-light-info">
                  <span class="text-muted fw-bold">Backup File</span>
                  <span class="text-truncate text-dark fw-bold ms-5" style="max-width: 250px;">{{selectedFile?.name}}</span>
                </li>
              </ul>
            </div>
          </div>
          <div class="modal-footer p-3 bg-white border-0">
            <button type="button" class="btn btn-secondary px-4 py-2 rounded-pill shadow-sm" (click)="showConfirmModal = false">Cancel</button>
            <button type="button" class="btn btn-danger px-4 py-2 rounded-pill shadow-sm fw-bold" (click)="proceedWithRestore()">Confirm Restore</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Success Modal -->
    <div class="modal-overlay" *ngIf="showSuccessModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0 overflow-hidden bg-white" style="max-width: 450px;">
          <div class="modal-body p-5 text-center">
            <div class="success-icon-wrapper mb-4">
              <div class="success-icon-bg shadow-sm">
                <i class="feather icon-check" style="font-size: 3rem; color: #2ecc71;"></i>
              </div>
            </div>
            <h4 class="fw-bold text-dark mb-3">Operation Successful!</h4>
            <p class="text-dark mb-4 px-3 fw-medium lh-base">{{statusMessage}}</p>
            <button type="button" class="btn btn-success px-5 py-3 rounded-pill shadow-sm fw-bold w-100" style="background: #27ae60; border: none;" (click)="closeSuccessModal()">
              <i class="feather icon-check-circle me-2"></i>Got it
            </button>
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

    .success-icon-bg, .error-icon-bg {
      width: 100px;
      height: 100px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto;
    }
    .success-icon-bg { background: #f0fff4; border: 5px solid #ffffff; }
    .error-icon-bg { background: #fff5f5; border: 5px solid #ffffff; }
    
    .btn-success { background: #2ecc71; border: none; transition: background 0.2s; }
    .btn-success:hover { background: #27ae60; }
  `]
})
export class BackupRestoreComponent implements OnInit {
    loading: { [key: string]: boolean } = {};
    showConfirmModal = false;
    showSuccessModal = false;
    showErrorModal = false;
    statusMessage = '';
    selectedFile: File | null = null;
    needsReload = false;

    restoreParams = {
        host: 'localhost',
        port: '5432',
        user: 'mms',
        pass: 'Mms@123',
        db: 'postgres',
        schema: 'mms',
        psqlPath: 'C:\\Program Files\\PostgreSQL\\17\\bin\\psql.exe'
    };

    constructor(private mmsService: MmsService) { }

    ngOnInit() {
        this.mmsService.configs$.subscribe(configs => {
            if (configs && configs.length > 0) {
                this.loadSettings();
            }
        });
    }

    loadSettings() {
        try {
            this.restoreParams.host = this.mmsService.getConfigValue('DB_HOST');
            this.restoreParams.port = this.mmsService.getConfigValue('DB_PORT');
            this.restoreParams.user = this.mmsService.getConfigValue('DB_USER');
            this.restoreParams.pass = this.mmsService.getConfigValue('DB_PASS');
            this.restoreParams.db = this.mmsService.getConfigValue('DB_NAME');
            this.restoreParams.schema = this.mmsService.getConfigValue('BACKUP_SCHEMA');
            this.restoreParams.psqlPath = this.mmsService.getConfigValue('PSQL_PATH');
        } catch (e) {
            console.warn('Could not load all DB settings from configs table. Using defaults/UI manual entry.');
        }
    }

    backup() {
        this.loading['backup'] = true;
        this.mmsService.backupDatabase().subscribe({
            next: (blob) => {
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                const now = new Date();
                const timestamp = now.toISOString().replace(/T/, '_').replace(/\..+/, '').replace(/:/g, '-');
                a.download = `mms_schema_backup_${timestamp}.sql`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                this.loading['backup'] = false;

                this.statusMessage = 'Database backup generated and downloaded successfully.';
                this.needsReload = false;
                this.showSuccessModal = true;
            },
            error: (err) => {
                console.error('Backup failed', err);
                this.statusMessage = 'Database backup failed. Ensure pg_dump is correctly configured.';
                this.showErrorModal = true;
                this.loading['backup'] = false;
            }
        });
    }

    onFileSelected(event: any) {
        const file = event.target.files[0];
        if (!file) return;
        this.selectedFile = file;
        this.showConfirmModal = true;
        event.target.value = '';
    }

    proceedWithRestore() {
        if (!this.selectedFile) return;

        this.showConfirmModal = false;
        this.loading['restore'] = true;

        this.mmsService.restoreDatabase(this.selectedFile, this.restoreParams).subscribe({
            next: (res) => {
                this.statusMessage = 'Database schema restored successfully! The application will now reload to apply the new data.';
                this.needsReload = true;
                this.showSuccessModal = true;
                this.loading['restore'] = false;
            },
            error: (err) => {
                console.error('Restore failed', err);
                this.statusMessage = 'Restore failed: ' + (err.error || 'Connection refused or invalid SQL file.');
                this.showErrorModal = true;
                this.loading['restore'] = false;
            }
        });
    }

    closeSuccessModal() {
        this.showSuccessModal = false;
        if (this.needsReload) {
            window.location.reload();
        }
    }
}
