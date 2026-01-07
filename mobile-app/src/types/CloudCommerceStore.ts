export const initialStatus = {
  isPrepared: false,
  isLoading: false,
  error: null, // Can be null, string (legacy), or error object (new)
  status: 'Ready to prepare',
  sdkState: null,
  readerProgress: null,
};

export const initialConfig = {
  isProd: false,
};
