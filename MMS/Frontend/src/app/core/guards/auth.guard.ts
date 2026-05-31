import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

export const authGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const token = localStorage.getItem('token');
  const sessionExpiryStr = localStorage.getItem('sessionExpiry');
  
  if (token && sessionExpiryStr) {
    const expiryTime = parseInt(sessionExpiryStr, 10);
    if (new Date().getTime() <= expiryTime) {
      return true;
    }
  }

  localStorage.clear();
  router.navigate(['/login']);
  return false;
};
