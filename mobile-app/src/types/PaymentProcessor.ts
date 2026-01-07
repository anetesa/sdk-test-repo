export type PaymentProcessor = {
  paymentProcessors: {
    id: string;
    displayName: string;
    isDefault: boolean;
    mid: string;
    settlementTimeSlots: {
      hours: number;
      minutes: number;
    }[];
    processSettlementAutomatically: boolean;
    paymentProcessorType: {
      id: number;
      name: string;
    };
    paymentProcessorStatus: {
      id: number;
      name: string;
    };
    paymentMethod: {
      id: number;
      name: string;
    };
  }[];
};
