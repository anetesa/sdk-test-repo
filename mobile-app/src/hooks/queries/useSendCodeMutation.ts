import {useMutation} from '@tanstack/react-query';
import {sendTwoFactorCode} from '@/services/authService';

type SendCodePayload = {
  twoFactorId: string;
  methodId: string;
};

export function useSendCodeMutation() {
  return useMutation<void, any, SendCodePayload>({
    mutationFn: sendTwoFactorCode,
  });
}
