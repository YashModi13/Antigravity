import { Injectable } from '@angular/core';
import * as CryptoJS from 'crypto-js';

@Injectable({
    providedIn: 'root'
})
export class EncryptionService {

    // This key is loaded dynamically from the backend on startup
    private SECRET_KEY = 'AntigravitySecretKey2024Secure!!'; // Secure Fallback

    constructor() { }

    setSecretKey(key: string) {
        if (key && key.trim() !== '') {
            this.SECRET_KEY = key;
        }
    }

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
            if (!encryptedData) return null;
            const decrypted = CryptoJS.AES.decrypt(encryptedData, CryptoJS.enc.Utf8.parse(this.SECRET_KEY), {
                mode: CryptoJS.mode.ECB,
                padding: CryptoJS.pad.Pkcs7
            });
            const jsonString = decrypted.toString(CryptoJS.enc.Utf8);
            if (!jsonString) {
                console.warn('Decryption produced empty string (Invalid Key?)');
                return null;
            }
            return JSON.parse(jsonString);
        } catch (e) {
            console.error('Decryption failed', e);
            return null;
        }
    }
}
