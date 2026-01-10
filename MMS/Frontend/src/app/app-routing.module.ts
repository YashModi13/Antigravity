import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

// project import
import { AdminComponent } from './theme/layout/admin/admin.component';
import { GuestComponent } from './theme/layout/guest/guest.component';

const routes: Routes = [
  {
    path: '',
    component: AdminComponent,
    children: [
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full'
      },
      {
        path: 'dashboard',
        loadComponent: () => import('./mms/dashboard/dashboard.component').then((c) => c.MmsDashboardComponent)
      },
      {
        path: 'mms/dashboard',
        loadComponent: () => import('./mms/dashboard/dashboard.component').then((c) => c.MmsDashboardComponent)
      },
      {
        path: 'mms/deposits',
        loadComponent: () => import('./mms/deposits/list.component').then((c) => c.MmsDepositsListComponent)
      },
      {
        path: 'mms/entry',

        loadComponent: () => import('./mms/entry/entry.component').then((c) => c.MmsEntryComponent)
      },
      {
        path: 'mms/customer-items',
        loadComponent: () => import('./mms/customer-items/customer-items.component').then((c) => c.CustomerItemsComponent)
      },

      {
        path: 'mms/merchant',
        loadComponent: () => import('./mms/merchant/merchant.component').then((c) => c.MmsMerchantComponent)
      },
      {
        path: 'mms/reports',
        loadComponent: () => import('./mms/reports/reports.component').then((c) => c.ReportsComponent)
      },
      {
        path: 'mms/configs',
        loadComponent: () => import('./mms/settings/config-property.component').then((c) => c.ConfigPropertyComponent)
      },
      {
        path: 'mms/enc-test',
        loadComponent: () => import('./mms/settings/encryption-test.component').then((c) => c.EncryptionTestComponent)
      },


      {
        path: 'basic',
        loadChildren: () => import('./demo/ui-elements/ui-basic/ui-basic.module').then((m) => m.UiBasicModule)
      },
      {
        path: 'forms',
        loadComponent: () => import('./demo/pages/form-element/form-element').then((c) => c.FormElement)
      },
      {
        path: 'tables',
        loadComponent: () => import('./demo/pages/tables/tbl-bootstrap/tbl-bootstrap.component').then((c) => c.TblBootstrapComponent)
      },
      {
        path: 'apexchart',
        loadComponent: () => import('./demo/pages/core-chart/apex-chart/apex-chart.component').then((c) => c.ApexChartComponent)
      },
      {
        path: 'sample-page',
        loadComponent: () => import('./demo/extra/sample-page/sample-page.component').then((c) => c.SamplePageComponent)
      }
    ]
  },
  {
    path: '',
    component: GuestComponent,
    children: [
      {
        path: 'login',
        loadComponent: () => import('./demo/pages/authentication/auth-signin/auth-signin.component').then((c) => c.AuthSigninComponent)
      },
      {
        path: 'register',
        loadComponent: () => import('./demo/pages/authentication/auth-signup/auth-signup.component').then((c) => c.AuthSignupComponent)
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
