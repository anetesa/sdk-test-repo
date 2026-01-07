import AriseMobileSdk, {ArisePaymentSettings} from '@/native/AriseMobileSdk';

export async function fetchPaymentSettings(): Promise<ArisePaymentSettings> {
  return await AriseMobileSdk.getPaymentSettings();
}
