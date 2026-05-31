import packageInfo from '../../package.json';

export const environment = {
  appVersion: packageInfo.version,
  production: true,
  apiUrl: 'https://mms-backend-service.onrender.com' // Replace with your actual deployed backend URL
};
