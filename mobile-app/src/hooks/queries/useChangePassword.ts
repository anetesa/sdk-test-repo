import {useMutation} from '@tanstack/react-query';
import {requestPasswordReset} from '@/services/authService';

export function useChangePasswordMutation() {
  return useMutation<any, any, {loginId: string}>({
    mutationFn: requestPasswordReset,
  });
}
