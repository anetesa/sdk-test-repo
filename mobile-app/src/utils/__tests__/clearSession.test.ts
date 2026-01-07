import {clearSession} from '../clearSession';
import {resetAsyncStorageSession} from '../asyncStorage';
import {clearTokens} from '../tokenRefresh';

// Mock the logger
jest.mock('../logger');

jest.mock('@/utils/asyncStorage', () => ({
  resetAsyncStorageSession: jest.fn(),
}));

jest.mock('@/utils/tokenRefresh', () => ({
  clearTokens: jest.fn(),
}));

jest.mock('@/utils/queryClient', () => ({
  queryClient: {
    cancelQueries: jest.fn().mockResolvedValue(undefined),
    clear: jest.fn(),
  },
}));

const mockReset = jest.fn();
jest.mock('@/stores/userStore', () => ({
  useUserStore: {
    getState: () => ({
      reset: mockReset,
    }),
  },
}));

const mockedClearTokens = clearTokens as jest.MockedFunction<
  typeof clearTokens
>;
const mockedResetAsyncStorageSession =
  resetAsyncStorageSession as jest.MockedFunction<
    typeof resetAsyncStorageSession
  >;

describe('clearSession', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should call all clearing services', async () => {
    mockedResetAsyncStorageSession.mockResolvedValueOnce(undefined);
    mockedClearTokens.mockResolvedValueOnce(undefined);

    await clearSession();

    expect(resetAsyncStorageSession).toHaveBeenCalledTimes(1);
    expect(mockedClearTokens).toHaveBeenCalledTimes(1);
    expect(mockReset).toHaveBeenCalledTimes(1);
  });

  it('should throw an error if token clearing fails', async () => {
    const error = new Error('Token clearing error');
    mockedClearTokens.mockRejectedValue(error);

    await expect(clearSession()).rejects.toThrow('Token clearing error');

    // Get the mocked logger
    const {logger} = require('../logger');
    expect(logger.error).toHaveBeenCalledWith(error, 'Error during app reset');
  });

  it('should throw an error if async storage reset fails', async () => {
    const error = new Error('AsyncStorage error');
    mockedResetAsyncStorageSession.mockRejectedValue(error);

    await expect(clearSession()).rejects.toThrow('AsyncStorage error');

    // Get the mocked logger
    const {logger} = require('../logger');
    expect(logger.error).toHaveBeenCalledWith(error, 'Error during app reset');
  });
});
