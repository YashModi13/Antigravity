import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { EncryptionService } from 'src/app/core/services/encryption.service';
import { HttpClient } from '@angular/common/http';
import { ENCRYPTION_UI_TEXTS } from '../shared/constant';

@Component({
  selector: 'app-encryption-test',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="row">
      <div class="col-sm-12">
        <div class="card shadow-sm">
          <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
             <h5 class="mb-0 text-primary"><i class="feather icon-shield me-2"></i>{{ UI.TITLE }}</h5>
             <p class="text-muted small mt-2">{{ UI.SUBTITLE }}</p>
          </div>
          <div class="card-body">
            
            <div class="row">
                <!-- INPUT SECTION -->
                <div class="col-md-12 mb-4">
                    <label class="form-label fw-bold text-uppercase small text-secondary">{{ UI.INPUT_LABEL }}</label>
                    <div class="input-group">
                        <textarea class="form-control font-monospace bg-light border-secondary" 
                                  style="font-size: 0.9rem;" 
                                  rows="12" 
                                  [(ngModel)]="sharedInput" 
                                  [placeholder]="UI.INPUT_PLACEHOLDER"></textarea>
                    </div>
                    <div class="d-flex justify-content-end mt-2">
                        <small class="text-muted">Type plain text or JSON here.</small>
                    </div>
                </div>

                <!-- ACTION TOOLBAR -->
                <div class="col-md-12 mb-4">
                    <div class="card bg-light border-0">
                        <div class="card-body p-3 d-flex flex-wrap gap-2 align-items-center justify-content-between">
                            
                            <div class="d-flex gap-2">
                                <button class="btn btn-primary" (click)="doEncrypt()">
                                    <i class="feather icon-lock me-2"></i>{{ UI.BTN_ENCRYPT }}
                                </button>
                                <button class="btn btn-success" (click)="doDecrypt()">
                                    <i class="feather icon-unlock me-2"></i>{{ UI.BTN_DECRYPT }}
                                </button>
                            </div>

                            <div class="d-flex gap-2">
                                <button class="btn btn-info text-white" (click)="doPretty()" title="Format JSON">
                                    <i class="feather icon-layout me-2"></i>{{ UI.BTN_PRETTY }}
                                </button>
                                <button class="btn btn-secondary" (click)="sharedInput=''; resultData=''">
                                    <i class="feather icon-refresh-cw me-2"></i>{{ UI.BTN_RESET }}
                                </button>
                            </div>

                            <div class="border-start ps-2" style="border-color: #ccc !important;">
                                <button class="btn btn-warning text-dark fw-bold" (click)="sendToServer()" [disabled]="isLoading">
                                    <span *ngIf="isLoading" class="spinner-border spinner-border-sm me-1"></span>
                                    <i *ngIf="!isLoading" class="feather icon-server me-2"></i>
                                    {{ UI.BTN_SEND }}
                                </button>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- RESULT SECTION -->
                <div class="col-md-12" *ngIf="resultData">
                    <div class="card border border-primary shadow-sm" style="overflow: hidden;">
                        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center py-2">
                            <span class="fw-bold small text-uppercase"><i class="feather icon-activity me-2"></i>{{ resultTitle }}</span>
                            <div>
                                <button class="btn btn-light btn-sm text-primary py-0" (click)="copyToInput()" title="Edit Result">
                                    <i class="feather icon-edit me-1"></i>Edit in Input
                                </button>
                                <button class="btn btn-light btn-sm text-dark ms-2 py-0" (click)="copyResult()" title="Copy Value">
                                    <i class="feather icon-copy me-1"></i>Copy
                                </button>
                            </div>
                        </div>
                        <div class="card-body bg-white p-0">
                            <div class="p-3 font-monospace" style="max-height: 500px; overflow-y: auto; white-space: pre-wrap; font-size: 0.85rem; color: #2c3e50; background-color: #f8f9fa;">{{ resultData }}</div>
                        </div>
                        <div class="card-footer bg-light py-2 text-end" *ngIf="resultInfo">
                            <small class="text-secondary"><i class="feather icon-info me-1"></i>{{ resultInfo }}</small>
                        </div>
                    </div>
                </div>

            </div>

          </div>
        </div>
      </div>
    </div>
  `
})
export class EncryptionTestComponent implements OnInit {

  UI = ENCRYPTION_UI_TEXTS;


  sharedInput = 'Test Data 123';

  resultData = '';
  resultTitle = '';
  resultInfo = '';

  isLoading = false;

  constructor(private encryptionService: EncryptionService, private http: HttpClient) { }

  ngOnInit() {
    // Just a placeholder start
  }

  doEncrypt() {
    if (!this.sharedInput) return;
    try {
      this.resultData = this.encryptionService.encrypt(this.sharedInput);
      this.resultTitle = this.UI.RESULT_ENCRYPTED_TITLE;
      this.resultInfo = this.UI.RESULT_ENCRYPTED_INFO;
    } catch (e) {
      this.resultData = 'Error: ' + e;
      this.resultTitle = this.UI.RESULT_ERROR_TITLE;
    }
  }

  doDecrypt() {
    if (!this.sharedInput) return;
    try {
      let cipherText = this.sharedInput.trim();

      // Smart extraction: If user pastes { "data": "..." }, extract the string
      if (cipherText.startsWith('{') && cipherText.endsWith('}')) {
        try {
          const parsed = JSON.parse(cipherText);
          if (parsed && parsed.data) {
            cipherText = parsed.data;
            console.log('Smart Extract: Found ciphertext in JSON object');
          }
        } catch (e) {
          // Not valid JSON, proceed as raw string
        }
      }

      // Remove Quotes if user pasted "ciphertext"
      if (cipherText.startsWith('"') && cipherText.endsWith('"')) {
        cipherText = cipherText.substring(1, cipherText.length - 1);
      }

      const res = this.encryptionService.decrypt(cipherText);

      if (typeof res === 'object' && res !== null) {
        this.resultData = JSON.stringify(res, null, 2);
      } else if (res) {
        this.resultData = String(res);
      } else {
        this.resultData = 'Decryption Failed (Invalid Key or Format)';
      }

      this.resultTitle = this.UI.RESULT_DECRYPTED_TITLE;
      this.resultInfo = res ? this.UI.RESULT_DECRYPTED_INFO : '';
    } catch (e) {
      this.resultData = 'Error: ' + e;
      this.resultTitle = this.UI.RESULT_ERROR_TITLE;
    }
  }

  sendToServer() {
    this.isLoading = true;
    this.resultData = '';
    this.resultTitle = 'Sending...';

    const payload = { message: this.sharedInput, timestamp: new Date().toISOString() };

    // Using the echo endpoint
    this.http.post('http://localhost:8081/api/security/echo', payload).subscribe({
      next: (res) => {
        this.resultData = JSON.stringify(res, null, 2);
        this.resultTitle = this.UI.RESULT_SERVER_TITLE;
        this.resultInfo = this.UI.RESULT_SERVER_INFO;
        this.isLoading = false;
      },
      error: (err) => {
        this.resultData = JSON.stringify({ error: err.statusText, message: err.message }, null, 2);
        this.resultTitle = this.UI.RESULT_ERROR_TITLE;
        this.resultInfo = this.UI.RESULT_ERROR_INFO;
        this.isLoading = false;
      }
    });
  }

  doPretty() {
    if (!this.sharedInput) return;
    try {
      const obj = JSON.parse(this.sharedInput);
      this.sharedInput = JSON.stringify(obj, null, 2);
    } catch (e) {
      alert('Invalid JSON: Cannot format');
    }
  }

  copyToInput() {
    if (this.resultData) {
      this.sharedInput = this.resultData;
    }
  }

  copyResult() {
    if (this.resultData) {
      navigator.clipboard.writeText(this.resultData).catch(err => {
        console.error('Could not copy text: ', err);
      });
    }
  }

}
