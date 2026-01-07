import {useMutation} from '@tanstack/react-query';
import {changePasswordWithId} from '@/services/authService';

export interface ChangePasswordWithIdPayload {
  changePasswordId: string;
  password: string;
}

export function useChangePasswordWithIdMutation() {
  return useMutation<any, any, ChangePasswordWithIdPayload>({
    mutationFn: changePasswordWithId,
  });
}
