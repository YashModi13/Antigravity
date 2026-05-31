import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { NgbDropdownConfig } from '@ng-bootstrap/ng-bootstrap';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { REST_URLS } from 'src/app/mms/shared/resturl';

@Component({
  selector: 'app-nav-right',
  imports: [SharedModule],
  templateUrl: './nav-right.component.html',
  styleUrls: ['./nav-right.component.scss'],
  providers: [NgbDropdownConfig]
})
export class NavRightComponent {
  private router = inject(Router);
  private http = inject(HttpClient);
  
  currentUser: any = null;

  constructor() {
    const config = inject(NgbDropdownConfig);
    config.placement = 'bottom-right';
    
    const userStr = localStorage.getItem('user');
    if (userStr) {
      this.currentUser = JSON.parse(userStr);
    }
  }

  logout() {
    this.http.post(REST_URLS.AUTH_LOGOUT, {}, { withCredentials: true }).subscribe({
      next: () => this.doLocalLogout(),
      error: () => this.doLocalLogout()
    });
  }

  private doLocalLogout() {
    localStorage.clear();
    this.router.navigate(['/login']);
  }
}
