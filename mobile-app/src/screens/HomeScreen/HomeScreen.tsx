import React, {useState, useEffect, useCallback} from 'react';
import {
  View,
  Text,
  Pressable,
  useWindowDimensions,
  Platform,
} from 'react-native';
import {SafeAreaView, useSafeAreaInsets} from 'react-native-safe-area-context';
import {MoreVertical} from 'lucide-react-native';
import {useUserStore} from '@/stores/userStore';
import {
  useTransactionsTodayQuery,
  invalidateTransactionsTodayQuery,
} from '@/hooks/queries/useTransactionsTodayQuery';
import {
  invalidateInfiniteDashboardTransactions,
  useGetInfiniteTransactions,
} from '@/hooks/queries/useGetTransactions';
import TransactionList from '@/components/transactions/TransactionList';
import {TransactionsToday} from './TransactionsToday';
import AriseButton from '@/components/baseComponents/AriseButton';
import LeaveFeedback from '@/components/baseComponents/LeaveFeedback';
import {useFeatureIsOn} from '@growthbook/growthbook-react';
import {useQueryClient} from '@tanstack/react-query';
import {
  isAmountHiddenKey,
  getAmountHiddenKey,
  setAmountHiddenKey,
} from '@/utils/asyncStorage';
import {getTransactionCount} from '@/utils/transactionHelpers';
import {ROUTES} from '@/constants/routes';
import RefreshLayout from '../../components/baseComponents/RefreshLayout';
import {useSelectedProfile} from '@/hooks/useSelectedProfile';
import {FEATURES} from '@/constants/features';
import {UI_MESSAGES} from '@/constants/messages';
import {PERMISSIONS} from '@/constants/permission';
import {useAlertStore} from '@/stores/alertStore';
import {useTransactionStore} from '@/stores/transactionStore';
import BannerTTP from '@/components/baseComponents/BannerAdminTTP';
import BannerStaffTTP from '@/components/baseComponents/BannerStaffTTP';
import AriseMobileSdk from '@/native/AriseMobileSdk';

const HomeScreen = ({navigation}: any) => {
  const {reset} = useTransactionStore();
  const {height: H} = useWindowDimensions();
  const isProMaxScreen = Platform.OS === 'ios' && H >= 896;
  const insets = useSafeAreaInsets();
  const queryClient = useQueryClient();

  // User & profile
  const {id: userId, email} = useUserStore();
  const {transactionsToday, salesToday, errors} = useTransactionsTodayQuery();
  const {selectedProfile} = useSelectedProfile();

  // Extract merchant data from selected profile
  const merchantName = selectedProfile?.accountName;
  const firstName = selectedProfile?.firstName;
  const isTransactionsSubmitPermission =
    selectedProfile?.permissions?.includes(PERMISSIONS.TRANSACTIONS_SUBMIT) ??
    false;

  // Features
  const isPendoFeedbackOn = useFeatureIsOn(FEATURES.PENDO_FEEDBACK);

  const [isTapToPayBasicTransactionOn, setIsTapToPayBasicTransactionOn] =
    useState(false);
  const isTTPFeatureOn = useFeatureIsOn(FEATURES.TAP_TO_PAY_BASIC_TRANSACTION);

  useEffect(() => {
    const checkCompatibility = async () => {
      const compatibility = await AriseMobileSdk.checkCompatibility();
      setIsTapToPayBasicTransactionOn(
        isTTPFeatureOn && compatibility.isCompatible,
      );
    };
    checkCompatibility();
  }, [isTTPFeatureOn]);

  // Helper function for transaction count logic
  const getNumberOfTransactions = useCallback(() => {
    const result = getTransactionCount(
      isPendoFeedbackOn ?? false,
      isTransactionsSubmitPermission ?? false,
      isProMaxScreen,
    );
    return result;
  }, [isPendoFeedbackOn, isTransactionsSubmitPermission, isProMaxScreen]);

  const {
    data,
    isLoading: isLoadingTransactions,
    error: errorTransactions,
  } = useGetInfiniteTransactions({
    pageSize: getNumberOfTransactions(),
    asc: false,
  });

  const transactions = data?.pages?.flatMap(page => page?.items || []) || [];

  const {showErrorAlert} = useAlertStore();

  useEffect(() => {
    if (errors.sales || errors.transactions || errorTransactions) {
      showErrorAlert('An error occured. Please try again');
    }
  }, [errors.sales, errors.transactions, errorTransactions, showErrorAlert]);
  // end of tap to pay activation via Home screen ---

  // Amount toggle
  const [isAmountHidden, setIsAmountHidden] = useState(false);
  useEffect(() => {
    (async () => {
      const saved = await getAmountHiddenKey(isAmountHiddenKey(userId));
      if (saved !== null) {
        const isHidden = saved === String(true);
        setIsAmountHidden(isHidden);
      }
    })();
  }, [userId]);

  const toggleAmountVisibility = useCallback(async () => {
    const next = !isAmountHidden;
    setIsAmountHidden(next);
    await setAmountHiddenKey(userId, next);
  }, [isAmountHidden, userId]);

  // Auth guard
  useEffect(() => {
    if (!email) {
      navigation.navigate(ROUTES.LOGIN);
    }
  }, [email, navigation]);

  const onRefresh = useCallback(() => {
    invalidateTransactionsTodayQuery(queryClient);
    invalidateInfiniteDashboardTransactions(queryClient);
    queryClient.invalidateQueries({
      queryKey: ['tap-to-pay-device-status'],
    });
  }, [queryClient]);

  return (
    <SafeAreaView edges={['top']} className="flex-1 bg-dark-page-bg">
      <RefreshLayout
        onRefresh={onRefresh}
        className="bg-dark-page-bg"
        contentContainerStyle={{paddingBottom: insets.bottom + 100}}>
        {/* HEADER */}
        <View className="px-4 pt-4 flex-row justify-between items-center">
          <View>
            <Text className="text-white text-[32px] font-medium leading-none">
              Hi,&nbsp;
              <Text className="text-white capitalize">{firstName}!</Text>
            </Text>
            <Text className="text-white/60 text-base">{merchantName}</Text>
          </View>
          <Pressable
            className="p-2 pt-0"
            onPress={() => navigation.navigate(ROUTES.SETTINGS)}>
            <MoreVertical color="white" size={24} />
          </Pressable>
        </View>

        {/* TRANSACTIONS TODAY */}
        <TransactionsToday
          transactionsToday={transactionsToday}
          salesToday={salesToday}
          onPress={toggleAmountVisibility}
          isAmountHidden={isAmountHidden}
        />

        {/* PENDO FEEDBACK */}
        {isPendoFeedbackOn && <LeaveFeedback />}

        {/* TAP TO PAY BANNER TTP */}
        {isTapToPayBasicTransactionOn && <BannerTTP />}
        {isTapToPayBasicTransactionOn && <BannerStaffTTP />}

        {/* LAST TRANSACTIONS */}
        <View
          className="bg-white px-6 pt-6 mt-6"
          style={{
            minHeight: H,
            paddingBottom: insets.bottom + 100,
          }}>
          <View className="flex-row justify-between mb-6">
            <Text className="text-xl font-medium text-text-primary">
              {UI_MESSAGES.LAST_TRANSACTIONS}
            </Text>
            <Pressable
              onPress={() => navigation.navigate(ROUTES.TRANSACTION_LIST)}>
              <Text className="text-brand-main font-medium text-base">
                {UI_MESSAGES.SHOW_ALL}
              </Text>
            </Pressable>
          </View>
          <TransactionList
            scrollEnabled={false}
            hideLastBorder={!isPendoFeedbackOn}
            isLoading={isLoadingTransactions}
            transactions={transactions}
            isAmountHidden={isAmountHidden}
          />
        </View>
      </RefreshLayout>

      {/* NEW TRANSACTION BUTTON */}
      {isTransactionsSubmitPermission && (
        <View
          className="absolute left-0 right-0 bottom-0 bg-white px-4 "
          style={{paddingBottom: insets.bottom + 16}}>
          <AriseButton
            title={UI_MESSAGES.NEW_TRANSACTION}
            onPress={() => {
              reset();
              navigation.navigate(ROUTES.NEW_TRANSACTION);
            }}
          />
        </View>
      )}
    </SafeAreaView>
  );
};

export default HomeScreen;
