// angular import
import { Component, Input, output } from '@angular/core';
import { RouterModule } from '@angular/router';

// project import
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService } from 'src/app/mms/mms.service';
import { CommonModule } from '@angular/common';

import { map } from 'rxjs';
import { CONFIG_KEYS } from 'src/app/mms/shared/constant';

@Component({
  selector: 'app-nav-logo',
  standalone: true,
  imports: [SharedModule, RouterModule, CommonModule],
  templateUrl: './nav-logo.component.html',
  styleUrls: ['./nav-logo.component.scss']
})
export class NavLogoComponent {
  // public props
  @Input() navCollapsed: boolean;
  NavCollapse = output();
  windowWidth = window.innerWidth;

  businessName$ = this.mmsService.configs$.pipe(
    map(configs => {
      // Try to find short name first for sidebar, fallback to full name
      const shortName = configs.find(c => c.propertyKey === CONFIG_KEYS.BUSINESS_SHORT_NAME);
      if (shortName) return shortName.propertyValue;

      const config = configs.find(c => c.propertyKey === CONFIG_KEYS.BUSINESS_NAME);
      if (!config) throw new Error("Missing config: " + CONFIG_KEYS.BUSINESS_NAME);
      return config.propertyValue;
    })
  );

  constructor(public mmsService: MmsService) { }

  // public method
  navCollapse() {
    if (this.windowWidth >= 992) {
      this.navCollapsed = !this.navCollapsed;
      this.NavCollapse.emit();
    }
  }
}
