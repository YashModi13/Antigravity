import { HttpInterceptorFn, HttpResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { map } from 'rxjs';
import { EncryptionService } from '../services/encryption.service';

export const encryptionInterceptor: HttpInterceptorFn = (req, next) => {
    const encryptionService = inject(EncryptionService);

    // Skip encryption for public endpoints
    if (req.url.includes('/api/public/')) {
        return next(req);
    }

    let request = req;

    // Encrypt Request Body (if POST/PUT/PATCH)
    // and it is not FormData
    let newBody = request.body;
    if (req.body && !(req.body instanceof FormData) && (req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH')) {
        const encrypted = encryptionService.encrypt(req.body);
        newBody = { data: encrypted };
    }

    // Clone request with updates
    request = request.clone({
        body: newBody
    });

    return next(request).pipe(
        map(event => {
            // Decrypt Response Body
            if (event instanceof HttpResponse && event.body) {
                const body = event.body as any;
                if (body && body.data) { // Check body exist
                    const decrypted = encryptionService.decrypt(body.data);

                    // Only replace if decryption was successful (allow falsy values like false or 0)
                    if (decrypted !== null && decrypted !== undefined) {
                        return event.clone({ body: decrypted });
                    }
                }
            }
            return event;
        })
    );
};
