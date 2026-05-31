import { Component, inject } from '@angular/core';
import { RouterModule, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { REST_URLS } from '../../../../mms/shared/resturl';

@Component({
  selector: 'app-auth-signin',
  imports: [RouterModule, FormsModule, CommonModule],
  templateUrl: './auth-signin.component.html',
  styleUrls: ['./auth-signin.component.scss']
})
export class AuthSigninComponent {
  username = '';
  password = '';
  errorMessage = '';
  showPassword = false;

  private http = inject(HttpClient);
  private router = inject(Router);

  login() {
    this.errorMessage = '';
    this.http.post(REST_URLS.AUTH_LOGIN, {
      username: this.username,
      password: this.password
    }, { withCredentials: true }).subscribe({
      next: (res: any) => {
        // Store session tokens & info locally
        localStorage.setItem('token', res.token);
        localStorage.setItem('user', JSON.stringify(res));

        // Create 1hr explicit auto-timeout
        const timeoutMs = 60 * 60 * 1000; // 1 hr in milliseconds
        const expiryTime = new Date().getTime() + timeoutMs;
        localStorage.setItem('sessionExpiry', expiryTime.toString());

        this.startSessionTimer(timeoutMs);

        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.errorMessage = err.error?.message || 'Invalid username or password';
      }
    });
  }

  private startSessionTimer(timeoutMs: number) {
    // Session timeout after 1 hr
    setTimeout(() => {
      this.logout();
    }, timeoutMs);
  }

  private logout() {
    this.http.post(REST_URLS.AUTH_LOGOUT, {}, { withCredentials: true }).subscribe({
      next: () => {
        localStorage.clear();
        this.router.navigate(['/login']);
      },
      error: () => {
        localStorage.clear();
        this.router.navigate(['/login']);
      }
    });
  }
}

