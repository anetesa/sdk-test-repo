export type TransactionBinData = {
  typeId: number;
  type: string;
};

/*
{"typeId":1,"type":"Credit"}
{"typeId":2,"type":"Debit"}
{"typeId":3,"type":"Unknown"} // The inputted BIN cannot be identified as either debit or credit. Please use a different card.
*/
