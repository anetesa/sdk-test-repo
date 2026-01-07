import {useEffect} from 'react';
import {growthBook} from '@/utils/growthBook';
import {useUserStore} from '@/stores/userStore';

export function useGrowthBookAttributes() {
  const {id, merchantId} = useUserStore(s => ({
    id: s.id,
    merchantId: s.merchantId,
  }));

  useEffect(() => {
    if (id && merchantId) {
      growthBook.instance.setAttributes({
        id,
        merchantId,
      });
    }
  }, [id, merchantId]);
}
