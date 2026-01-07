import {useMutation} from '@tanstack/react-query';
import type {LoginResponse} from '@/types/Login';
import {storeTokens} from '@/utils/tokenRefresh';
import {login} from '@/services/authService';

export function useLoginMutation() {
  return useMutation<
    LoginResponse,
    any,
    {
      loginId: string;
      password: string;
      applicationId?: string;
      twoFactorTrustId?: string;
    }
  >({
    mutationFn: login,
    onSuccess: async (data: LoginResponse) => {
      if ((data as any).token && (data as any).refreshToken) {
        await storeTokens((data as any).token, (data as any).refreshToken);
      }
    },
  });
}
