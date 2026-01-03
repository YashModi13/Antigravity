// angular import
import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subscription } from 'rxjs';

// project import
import { SharedModule } from 'src/app/theme/shared/shared.module';
import { MmsService } from 'src/app/mms/mms.service';
import { map } from 'rxjs';
import { CONFIG_KEYS } from 'src/app/mms/shared/constant';

@Component({
  selector: 'app-nav-left',
  standalone: true,
  imports: [SharedModule, CommonModule],
  templateUrl: './nav-left.component.html',
  styleUrls: ['./nav-left.component.scss']
})
export class NavLeftComponent implements OnInit, OnDestroy {
  latestPrices: any[] = [];
  currencySymbol$ = this.mmsService.configs$.pipe(
    map(configs => {
      const config = configs.find(c => c.propertyKey === CONFIG_KEYS.SYSTEM_CURRENCY_SYMBOL);
      return config ? config.propertyValue : '₹';
    })
  );
  private subscription: Subscription = new Subscription();

  constructor(private mmsService: MmsService) { }

  ngOnInit() {
    console.log('NavLeftComponent: Initializing ticker...');

    this.subscription.add(
      this.mmsService.prices$.subscribe(data => {
        if (data && data.length > 0) {
          this.latestPrices = data;
        }
      })
    );

    // Initial load
    this.mmsService.refreshLatestPrices();
  }

  trackByItem(index: number, item: any) {
    return item.itemName;
  }

  ngOnDestroy() {
    this.subscription.unsubscribe();
  }
}
