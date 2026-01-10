import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { ToastService } from 'src/app/theme/shared/components/toast/toast.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
    const toastService = inject(ToastService);

    return next(req).pipe(
        catchError((error: HttpErrorResponse) => {
            // Standard "Business Best Way" Static Message
            const standardMessage = 'Something went wrong. Please try again.';

            // Display the standard popup (Toast)
            toastService.error(standardMessage);

            return throwError(() => error);
        })
    );
};
