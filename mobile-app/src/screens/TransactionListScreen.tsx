import React, {useCallback, useMemo, useState} from 'react';
import {
  View,
  Text,
  RefreshControl,
  StyleSheet,
  Dimensions,
  FlatList,
  Pressable,
} from 'react-native';
import Header from '@/components/Header';
import {useGetInfiniteTransactions} from '@/hooks/queries/useGetTransactions';
import {
  CustomLoadingIndicator,
  CustomSVGSpinner,
} from '@/components/baseComponents/CustomSpinner';
import {FullSkeletonList} from '@/components/baseComponents/ListItemSkeleton';

import {useQueryClient} from '@tanstack/react-query';
import {invalidateTransactionsTodayQuery} from '@/hooks/queries/useTransactionsTodayQuery';
import TransactionItem from '@/components/transactions/TransactionItem';
import {SafeAreaView} from 'react-native-safe-area-context';
import {
  NAVIGATION_TITLES,
  TRANSACTION_MESSAGES,
  UI_ERROR_MESSAGES,
} from '@/constants/messages';

const TransactionListError = () => {
  const screenHeight = Dimensions.get('window').height;
  // Subtract approximate header height (around 120px)
  const minHeight = screenHeight - 120;

  return (
    <View
      style={{minHeight}}
      className="bg-white items-center justify-center px-4">
      <Text className="text-text-secondary text-[16px] text-center mb-4">
        {UI_ERROR_MESSAGES.FAILED_TO_LOAD_TRANSACTIONS}
      </Text>
    </View>
  );
};

export {TransactionItem};

export const TransactionListScreen = () => {
  const [isManualRefreshing, setIsManualRefreshing] = useState(false);

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isRefetching,
    isLoading,
    isError,
    refetch,
  } = useGetInfiniteTransactions({
    pageSize: 20,
    asc: false,
  });

  // Flatten all pages into a single array
  const items = useMemo(
    () => data?.pages?.flatMap(page => page?.items || []) || [],
    [data?.pages],
  );

  const showFullScreenError = isError && items.length === 0 && !isLoading;

  // Handle infinite scroll
  const handleLoadMore = useCallback(() => {
    if (hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  const queryClient = useQueryClient();

  // Handle pull to refresh
  const handleRefresh = useCallback(async () => {
    invalidateTransactionsTodayQuery(queryClient);
    setIsManualRefreshing(true);
    try {
      await refetch();
    } finally {
      setTimeout(() => {
        setIsManualRefreshing(false);
      }, 500);
    }
  }, [refetch, queryClient]);

  const renderItem = useCallback(
    ({item}: {item: any}) => (
      <TransactionItem
        transaction={item}
        isAmountHidden={false}
        showBorder={true}
      />
    ),
    [],
  );

  const keyExtractor = useCallback((item: any) => String(item.id), []);

  const showPaginationError = isError && items.length > 0;

  const ListFooterComponent = useCallback(() => {
    return (
      <View>
        {isFetchingNextPage && <CustomLoadingIndicator />}

        {showPaginationError && (
          <View className="py-4 items-center">
            <Text className="text-text-secondary text-[14px] text-center mb-3">
              {UI_ERROR_MESSAGES.FAILED_TO_LOAD_TRANSACTIONS}
            </Text>
            <Pressable
              className="px-4 py-2 rounded-full border border-gray-200"
              onPress={() => fetchNextPage()}>
              <Text className="text-text-primary text-[14px] font-medium">
                Retry
              </Text>
            </Pressable>
          </View>
        )}

        {!hasNextPage && items.length > 0 && (
          <View className="py-6 items-center">
            <Text className="text-text-secondary text-[14px]">
              {TRANSACTION_MESSAGES.NO_MORE_TRANSACTIONS}
            </Text>
          </View>
        )}
      </View>
    );
  }, [
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    showPaginationError,
    items.length,
  ]);

  return (
    <View className="flex-1 bg-white">
      <SafeAreaView edges={['top']} className="bg-dark-page-bg">
        <Header showBack={true} title={NAVIGATION_TITLES.TRANSACTION_HISTORY} />
      </SafeAreaView>
      <View className="flex-1 relative">
        {/* Custom loading indicator that shows only when manually refreshing */}
        {isManualRefreshing && (
          <View className="absolute top-0 left-0 right-0 z-10 items-center pt-4">
            <View className="flex items-center px-3 py-2 mx-4">
              <View className="flex items-center py-2">
                <CustomSVGSpinner size={26} />
                <Text className="text-text-secondary text-[12px] mt-2">
                  Loading...
                </Text>
              </View>
            </View>
          </View>
        )}

        {showFullScreenError ? (
          <TransactionListError />
        ) : (
          <FlatList
            data={items}
            renderItem={renderItem}
            keyExtractor={keyExtractor}
            className="flex-1 bg-white"
            contentContainerStyle={[
              styles.scrollViewContainer,
              isManualRefreshing && styles.refreshPadding,
              {paddingHorizontal: 20},
            ]}
            refreshControl={
              <RefreshControl
                refreshing={isRefetching || isManualRefreshing}
                onRefresh={handleRefresh}
                tintColor="transparent"
                title=""
                titleColor="transparent"
                colors={['transparent']}
                progressBackgroundColor="transparent"
                progressViewOffset={0}
              />
            }
            onEndReached={handleLoadMore}
            onEndReachedThreshold={0.35}
            removeClippedSubviews
            initialNumToRender={12}
            maxToRenderPerBatch={12}
            windowSize={7}
            updateCellsBatchingPeriod={50}
            showsVerticalScrollIndicator={false}
            ListEmptyComponent={isLoading ? <FullSkeletonList /> : null}
            ListFooterComponent={ListFooterComponent}
          />
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  scrollViewContainer: {
    paddingBottom: 5, // Add significant bottom padding to ensure last item is visible
  },
  refreshPadding: {
    paddingTop: 60,
  },
});
