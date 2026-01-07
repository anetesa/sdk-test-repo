import {useMutation} from '@tanstack/react-query';
import {storeTokens} from '@/utils/tokenRefresh';
import type {TwoFactorRequest, TwoFactorResponse} from '@/types/Login';
import {getTwoFactorTrustId, setTwoFactorTrustId} from '@/utils/asyncStorage';
import {submitTwoFactorLogin} from '@/services/authService';

export function useMfaMutation() {
  return useMutation<TwoFactorResponse, any, TwoFactorRequest>({
    mutationFn: submitTwoFactorLogin,
    onSuccess: async (data, variables) => {
      if ((data as any).token && (data as any).refreshToken) {
        await storeTokens((data as any).token, (data as any).refreshToken);
      }

      if (
        (data as any).twoFactorTrustId &&
        variables.trustComputer &&
        variables.userEmail
      ) {
        let objTrustData: Record<string, string> = {};

        const currentListTrustData = await getTwoFactorTrustId();
        if (currentListTrustData) {
          objTrustData = JSON.parse(currentListTrustData);
        }

        const newListTrustData = {
          ...objTrustData,
          [variables.userEmail]: (data as any).twoFactorTrustId,
        };
        await setTwoFactorTrustId(JSON.stringify(newListTrustData));
      }
    },
  });
}
