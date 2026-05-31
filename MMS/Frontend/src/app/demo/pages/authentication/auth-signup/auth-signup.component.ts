import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { REST_URLS } from '../../../../mms/shared/resturl';

@Component({
  selector: 'app-auth-signup',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  template: `
    <div class="auth-wrapper glass-theme animate__animated animate__fadeIn">
      <div class="auth-background"></div>
      <div class="auth-content">
        <div class="glass-card p-5 animate__animated animate__zoomIn">
          <div class="text-center mb-5">
            <div class="app-logo mb-4">
               <div class="logo-circle">
                 <i class="feather icon-users"></i>
               </div>
            </div>
            <h1 class="auth-title h2 mb-2">Create Account</h1>
            <p class="subtitle">Join the Dhiran Mortgage System</p>
          </div>

          <!-- Alerts -->
          <div class="alert alert-danger glass-alert border-0 small mb-4 animate__animated animate__shakeX" *ngIf="errorMessage">
            {{ errorMessage }}
          </div>
          <div class="alert alert-success glass-alert border-0 small mb-4 animate__animated animate__fadeIn" *ngIf="successMessage">
            {{ successMessage }}
          </div>

          <div class="form-group mb-4">
            <label class="form-label ms-1 mb-2 small">Full Name</label>
            <input type="text" class="form-control custom-input" [(ngModel)]="fullName" placeholder="e.g. Yash Modi">
          </div>

          <div class="form-group mb-4">
            <label class="form-label ms-1 mb-2 small">Email Address</label>
            <input type="email" class="form-control custom-input" [(ngModel)]="username" placeholder="name@example.com">
          </div>

          <div class="form-group mb-5">
            <label class="form-label ms-1 mb-2 small">Secure Password</label>
            <div class="input-group">
              <input [type]="showPassword ? 'text' : 'password'" class="form-control custom-input border-end-0" [(ngModel)]="password" placeholder="••••••••">
              <button class="btn custom-input border-start-0 px-3" type="button" (click)="togglePassword()">
                <i class="feather text-muted" [ngClass]="showPassword ? 'icon-eye-off' : 'icon-eye'"></i>
              </button>
            </div>
          </div>

          <div class="form-check custom-check mb-5">
            <input class="form-check-input" type="checkbox" id="agreeTerms" [(ngModel)]="agreeTerms">
            <label class="form-check-label ms-2" for="agreeTerms">
              I agree to the System Security Policy
            </label>
          </div>

          <button class="btn register-btn w-100 shadow-lg" (click)="register()">
             Request Activation <i class="feather icon-shield ms-2"></i>
          </button>

          <div class="auth-footer text-center pt-4 mt-4">
            <p class="mb-0 subtitle">Already have an account? <a [routerLink]="['/login']" class="login-link fw-bold">Login Screen</a></p>
          </div>
        </div>
      </div>
    </div>
  `,
  styleUrls: ['./auth-signup.component.scss']
})
export class AuthSignupComponent {
  fullName = '';
  username = '';
  password = '';
  agreeTerms = false;
  showPassword = false;
  
  errorMessage = '';
  successMessage = '';

  private http = inject(HttpClient);
  private router = inject(Router);

  register() {
    if (!this.agreeTerms) {
      this.errorMessage = 'Please agree to the security policy';
      return;
    }
    this.errorMessage = '';
    this.successMessage = '';

    this.http.post(REST_URLS.AUTH_SIGNUP, {
      fullName: this.fullName,
      username: this.username,
      password: this.password
    }).subscribe({
      next: (res: any) => {
        this.successMessage = 'Request sent! Administrator will activate your account.';
        setTimeout(() => this.router.navigate(['/login']), 3000);
      },
      error: (err) => {
        this.errorMessage = err.error?.message || 'Error sending request';
      }
    });
  }

  togglePassword() {
    this.showPassword = !this.showPassword;
  }
}
