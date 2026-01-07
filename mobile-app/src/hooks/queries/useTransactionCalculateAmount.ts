import {useQuery} from '@tanstack/react-query';
import type {
  CalculateAmountResponseDTO,
  GetApiTransactionsCalculateAmountParams,
} from '@/types/CalculateAmount';
import {calculateAmount} from '@/services/nativeTransactionActionsService';

async function fetchTransactionCalculateAmount(
  params: GetApiTransactionsCalculateAmountParams,
): Promise<CalculateAmountResponseDTO> {
  const response = await calculateAmount(params);
  return response as unknown as CalculateAmountResponseDTO;
}

export function useTransactionCalculateAmount(
  params: GetApiTransactionsCalculateAmountParams,
) {
  return useQuery<CalculateAmountResponseDTO, Error>({
    queryKey: [
      'transactionCalculateAmount',
      params.amount,
      params.tipAmount,
      params.surchargeRate,
      params.useCardPrice,
      params.currencyId,
    ],
    queryFn: () => fetchTransactionCalculateAmount(params),
    enabled: !!params.amount,
    staleTime: 30000, // Cache for 30 seconds to avoid excessive requests
    refetchOnWindowFocus: false, // Don't refetch when window gains focus
  });
}
