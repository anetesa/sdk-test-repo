import {useQuery} from '@tanstack/react-query';
import {QUERY_KEYS} from '@/constants/queryKeys';
import {
  fetchTechSupport,
  type TechSupportInfo,
} from '@/services/techSupportService';

export function useTechSupport() {
  return useQuery<TechSupportInfo, Error>({
    queryKey: QUERY_KEYS.TECH_SUPPORT,
    queryFn: fetchTechSupport,
    onError: error => {
      console.error('Error fetching tech support info:', error);
    },
  });
}
