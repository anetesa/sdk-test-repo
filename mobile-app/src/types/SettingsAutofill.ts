export type SettingsAutofill = {
  l2Settings: {
    taxRate: number;
  };
  l3Settings: {
    shippingCharge: number;
    dutyChargeRate: number;
    product: {
      name: string;
      code: string;
      unitPrice: number;
      measurementUnit: string;
      quantity: number;
      discountPercentage: number;
      description: string | null;
      discountRate: number;
    };
  };
};
