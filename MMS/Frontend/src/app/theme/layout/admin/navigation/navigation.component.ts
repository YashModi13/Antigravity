import { Component, output, inject } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { NavLogoComponent } from './nav-logo/nav-logo.component';
import { NavContentComponent } from './nav-content/nav-content.component';
import { MmsService } from 'src/app/mms/mms.service';
import { CommonModule } from '@angular/common';
import { REST_URLS } from 'src/app/mms/shared/resturl';

@Component({
  selector: 'app-navigation',
  standalone: true,
  imports: [SharedModule, NavLogoComponent, NavContentComponent, CommonModule],
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.scss']
})
export class NavigationComponent {
  NavCollapse = output();
  NavCollapsedMob = output();
  navCollapsed: boolean;
  navCollapsedMob: boolean;
  windowWidth = window.innerWidth;
  
  activeUser: any = null;
  private router = inject(Router);
  private http = inject(HttpClient);

  constructor(private mmsService: MmsService) {
    this.navCollapsedMob = false;
    const userStr = localStorage.getItem('user');
    if (userStr) {
      this.activeUser = JSON.parse(userStr);
    }
  }

  navCollapse() {
    if (this.windowWidth >= 992) {
      this.navCollapsed = !this.navCollapsed;
      this.NavCollapse.emit();
    }
  }

  navCollapseMob() {
    if (this.windowWidth < 992) {
      this.NavCollapsedMob.emit();
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
