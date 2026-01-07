import axios from 'axios';
import {
  setupAuthInterceptors,
  setupDeviceHeaders,
  setupProfileHeaders,
} from '@/utils/apiInterceptors';
import {runtimeConfig} from '@/utils/runtimeConfig';

// Create authenticated API client for merchant operations
export const apiClient = axios.create({
  baseURL: runtimeConfig.APP_API_MERCHANT_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

setupAuthInterceptors(apiClient);
setupDeviceHeaders(apiClient);
setupProfileHeaders(apiClient);

// Create authenticated API client for public operations that require auth
export const publicApiClient = axios.create({
  baseURL: runtimeConfig.APP_API_PUBLIC_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

setupAuthInterceptors(publicApiClient);
