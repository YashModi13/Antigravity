import { Injectable } from '@angular/core';
import * as CryptoJS from 'crypto-js';
import { SECRET_KEYS } from '../../mms/shared/constant';

@Injectable({
    providedIn: 'root'
})
export class EncryptionService {

    // This matches the key in the database
    private readonly SECRET_KEY = SECRET_KEYS.APP_SECRET;

    constructor() { }

    encrypt(data: any): string {
        try {
            const jsonString = JSON.stringify(data);
            const encrypted = CryptoJS.AES.encrypt(jsonString, CryptoJS.enc.Utf8.parse(this.SECRET_KEY), {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7
            });
            return encrypted.toString();
        } catch (e) {
            console.error('Encryption failed', e);
            return '';
        }
    }

    decrypt(encryptedData: string): any {
        try {
            const decrypted = CryptoJS.AES.decrypt(encryptedData, CryptoJS.enc.Utf8.parse(this.SECRET_KEY), {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7
            });
            const jsonString = decrypted.toString(CryptoJS.enc.Utf8);
            return JSON.parse(jsonString);
        } catch (e) {
            console.error('Decryption failed', e);
            return null;
        }
    }
}
