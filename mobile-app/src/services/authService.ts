import authApi from '@/clients/authApi';
import {runtimeConfig} from '@/utils/runtimeConfig';
import type {
  LoginResponse,
  TwoFactorRequest,
  TwoFactorResponse,
} from '@/types/Login';

export async function login(params: {
  loginId: string;
  password: string;
  applicationId?: string;
  twoFactorTrustId?: string;
}): Promise<LoginResponse> {
  const {loginId, password, applicationId, twoFactorTrustId} = params;
  const defaultApplicationId =
    applicationId || runtimeConfig.APP_FUSIONAUTH_APPLICATION_ID || '';

  try {
    const response = await authApi.post<LoginResponse>(
      `${runtimeConfig.APP_API_AUTH_URL}/api/login`,
      {
        loginId,
        password,
        applicationId: defaultApplicationId,
        twoFactorTrustId,
      },
      {
        headers: {
          applicationId: defaultApplicationId,
        },
      },
    );
    return response.data;
  } catch (error: any) {
    if (error.response && error.response.data) {
      throw error.response.data;
    }
    throw error;
  }
}

export async function submitTwoFactorLogin(
  payload: TwoFactorRequest,
): Promise<TwoFactorResponse> {
  const response = await authApi.post<TwoFactorResponse>(
    `${runtimeConfig.APP_API_AUTH_URL}/api/two-factor/login`,
    payload,
  );
  return response.data;
}

export async function sendTwoFactorCode(params: {
  twoFactorId: string;
  methodId: string;
}): Promise<void> {
  await authApi.post(
    `${runtimeConfig.APP_API_AUTH_URL}/api/two-factor/send?twoFactorId=${params.twoFactorId}`,
    {methodId: params.methodId},
    {
      headers: {
        'Content-Type': 'application/json',
      },
    },
  );
}

export async function requestPasswordReset(payload: {
  loginId: string;
}): Promise<any> {
  const response = await authApi.post<any>(
    `${runtimeConfig.APP_API_AUTH_URL}/api/user/forgot-password`,
    payload,
    {
      headers: {
        'X-FusionAuth-TenantId': runtimeConfig.APP_FUSIONAUTH_TENANT_ID || '',
      },
    },
  );
  return response.data;
}

export async function changePasswordWithId(payload: {
  changePasswordId: string;
  password: string;
}): Promise<any> {
  const response = await authApi.post<any>(
    `${runtimeConfig.APP_API_AUTH_URL}/api/user/change-password`,
    {
      password: payload.password,
      changePasswordId: payload.changePasswordId,
    },
    {
      headers: {
        'X-FusionAuth-TenantId': runtimeConfig.APP_FUSIONAUTH_TENANT_ID || '',
        ApplicationId: runtimeConfig.APP_FUSIONAUTH_APPLICATION_ID || '',
      },
    },
  );
  return response.data;
}
