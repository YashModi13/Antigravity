import { APP_INITIALIZER, enableProdMode, importProvidersFrom } from '@angular/core';
import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';

import { environment } from './environments/environment';
import { BrowserModule, bootstrapApplication } from '@angular/platform-browser';

import { provideAnimations } from '@angular/platform-browser/animations';

import { AppRoutingModule } from './app/app-routing.module';
import { AppComponent } from './app/app.component';
import { errorInterceptor } from './app/core/interceptors/error.interceptor';
import { encryptionInterceptor } from './app/core/interceptors/encryption.interceptor';
import { EncryptionService } from './app/core/services/encryption.service';
import { firstValueFrom, catchError, of } from 'rxjs';

if (environment.production) {
  enableProdMode();
}

function initializeApp(http: HttpClient, encryptionService: EncryptionService) {
  return () => firstValueFrom(
    http.get<{ key: string }>('http://localhost:8081/api/public/encryption-key').pipe(
      catchError(() => {
        console.warn('Could not fetch dynamic encryption key. Using fallback.');
        return of({ key: '' });
      })
    )
  ).then(response => {
    if (response?.key) {
      encryptionService.setSecretKey(response.key);
      console.info('Security: Configuration synchronized with Admin Database.');
    }
  });
}

bootstrapApplication(AppComponent, {
  providers: [
    importProvidersFrom(BrowserModule, AppRoutingModule),
    provideAnimations(),
    provideHttpClient(withInterceptors([errorInterceptor, encryptionInterceptor])),
    {
      provide: APP_INITIALIZER,
      useFactory: initializeApp,
      deps: [HttpClient, EncryptionService],
      multi: true
    }
  ]

}).catch((err) => console.error(err));
