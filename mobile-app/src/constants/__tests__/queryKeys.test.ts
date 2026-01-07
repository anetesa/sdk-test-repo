import {QUERY_KEYS, createQueryKey} from '../queryKeys';

describe('queryKeys', () => {
  it('creates merchantSettings key', () => {
    expect(createQueryKey.merchantSettings('m-1')).toEqual([
      QUERY_KEYS.MERCHANT_SETTINGS,
      'm-1',
    ]);
  });

  it('creates dashboard transactions key with params', () => {
    expect(createQueryKey.dashboardTransactions(1, 20, true, 'date')).toEqual([
      QUERY_KEYS.DASHBOARD_TRANSACTIONS,
      1,
      20,
      true,
      'date',
    ]);
  });

  it('creates infinite dashboard key with params', () => {
    expect(
      createQueryKey.infiniteDashboardTransactions(20, false, 'id'),
    ).toEqual([QUERY_KEYS.INFINITE_DASHBOARD_TRANSACTIONS, 20, false, 'id']);
  });
});
