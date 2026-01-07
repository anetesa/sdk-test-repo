import AriseMobileSdk from '@/native/AriseMobileSdk';
import type {GetTransactionsResponseDTO} from '@/types/TransactionResponse';

type GetTransactionsResponse = {
  items: GetTransactionsResponseDTO[];
  total: number;
};

export async function fetchTransactionsPage(params: {
  page: number;
  pageSize: number;
  asc: boolean;
  orderBy?: string;
}): Promise<GetTransactionsResponse> {
  const {page, pageSize, asc, orderBy} = params;
  try {
    return await AriseMobileSdk.getTransactions({
      page,
      pageSize,
      orderBy,
      asc,
    });
  } catch (error) {
    // During logout we clear the native SDK session; calls can briefly fail and it's expected.
    // Avoid noisy logs; upstream UI handles the "no data" state anyway.
    const msg = (error as any)?.message;
    if (msg?.includes('AriseMobileSdk not configured')) {
      throw new Error('Failed to fetch transaction data');
    }
    console.error('Error fetching transactions:', error);
    throw new Error('Failed to fetch transaction data');
  }
}
