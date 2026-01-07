import Header from '@/components/Header';
import React, {useState} from 'react';
import {
  SafeAreaView,
  View,
  Text,
  ScrollView,
  TouchableOpacity,
} from 'react-native';

import {getScenariosByCategory} from '@/mocks/transactionScenarios';
import {TransactionItem} from '@/screens/TransactionListScreen';

// Transaction type definition - EXACTLY the same as TransactionListScreen
interface Transaction {
  id: string;
  statusId: number;
  totalAmount: number;
  date: string;
  typeId: number;
}

// Test scenario interface for the selector
interface TestScenario extends Transaction {
  description: string;
  expectedTitle?: string | null;
  expectedIconBgColor?: string | null;
}

export const TransactionTestScreen = () => {
  const [selectedScenario, setSelectedScenario] = useState<TestScenario | null>(
    null,
  );
  const [showAllScenarios, setShowAllScenarios] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  const categories = getScenariosByCategory();

  const getFilteredScenarios = () => {
    switch (selectedCategory) {
      case 'card':
        return categories.cardTransactions;
      case 'ach':
        return categories.achTransactions;
      case 'edge':
        return categories.edgeCases;
      default:
        return categories.allScenarios;
    }
  };

  const handleBack = () => {
    // TODO: Implement back navigation
  };

  const handleScenarioSelect = (scenario: TestScenario) => {
    setSelectedScenario(scenario);
    setShowAllScenarios(false);
  };

  const handleShowAll = () => {
    setShowAllScenarios(true);
    setSelectedScenario(null);
  };

  const handleShowSingle = () => {
    setShowAllScenarios(false);
    setSelectedScenario(null);
  };

  const renderScenarioSelector = () => (
    <View className="bg-gray-100 p-4">
      <Text className="text-xl font-bold mb-4">Select Test Scenario:</Text>

      {/* Category Filter */}
      <View className="flex-row ">
        <TouchableOpacity
          onPress={() => setSelectedCategory('all')}
          className={`px-3 py-2 rounded ${
            selectedCategory === 'all' ? 'bg-blue-500' : 'bg-gray-300'
          }`}>
          <Text
            className={
              selectedCategory === 'all' ? 'text-white' : 'text-gray-700'
            }>
            All
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => setSelectedCategory('card')}
          className={`px-3 py-2 rounded ${
            selectedCategory === 'card' ? 'bg-blue-500' : 'bg-gray-300'
          }`}>
          <Text
            className={
              selectedCategory === 'card' ? 'text-white' : 'text-gray-700'
            }>
            Card
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => setSelectedCategory('ach')}
          className={`px-3 py-2 rounded ${
            selectedCategory === 'ach' ? 'bg-blue-500' : 'bg-gray-300'
          }`}>
          <Text
            className={
              selectedCategory === 'ach' ? 'text-white' : 'text-gray-700'
            }>
            ACH
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => setSelectedCategory('edge')}
          className={`px-3 py-2 rounded ${
            selectedCategory === 'edge' ? 'bg-blue-500' : 'bg-gray-300'
          }`}>
          <Text
            className={
              selectedCategory === 'edge' ? 'text-white' : 'text-gray-700'
            }>
            Edge Cases
          </Text>
        </TouchableOpacity>
      </View>

      {/* View Mode Toggle */}
      <View className="flex-row mb-4 space-x-2">
        <TouchableOpacity
          onPress={handleShowSingle}
          className={`px-3 py-2 rounded ${
            !showAllScenarios ? 'bg-green-500' : 'bg-gray-300'
          }`}>
          <Text className={!showAllScenarios ? 'text-white' : 'text-gray-700'}>
            Single Test
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={handleShowAll}
          className={`px-3 py-2 rounded ${
            showAllScenarios ? 'bg-green-500' : 'bg-gray-300'
          }`}>
          <Text className={showAllScenarios ? 'text-white' : 'text-gray-700'}>
            Show All
          </Text>
        </TouchableOpacity>
      </View>

      {/* Scenario List */}
      {!showAllScenarios && (
        <ScrollView className="max-h-60">
          {getFilteredScenarios().map(scenario => (
            <TouchableOpacity
              key={scenario.id}
              onPress={() => handleScenarioSelect(scenario)}
              className={`p-3 mb-2 rounded border ${
                selectedScenario?.id === scenario.id
                  ? 'bg-blue-100 border-blue-500'
                  : 'bg-white border-gray-300'
              }`}>
              <Text className="font-medium text-sm">
                {scenario.description}
              </Text>
              <Text className="text-sm text-gray-600">
                Status: {scenario.statusId} | Type: {scenario.typeId}
              </Text>
              <Text className="text-sm text-gray-600">
                Expected: {scenario.expectedTitle || 'null'}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      )}

      {/* Selected Scenario Info */}
      {selectedScenario && !showAllScenarios && (
        <View className="mt-4 p-3 bg-blue-50 rounded">
          <Text className="font-bold text-sm">
            Selected: {selectedScenario.description}
          </Text>
          <Text className="text-sm text-gray-600">
            Status ID: {selectedScenario.statusId} | Type ID:{' '}
            {selectedScenario.typeId}
          </Text>
          <Text className="text-sm text-gray-600">
            Expected Title: {selectedScenario.expectedTitle || 'null'}
          </Text>
          <Text className="text-sm text-gray-600">
            Expected BG Color: {selectedScenario.expectedIconBgColor || 'null'}
          </Text>
        </View>
      )}
    </View>
  );

  const renderTransactions = () => {
    if (showAllScenarios) {
      return (
        <View className="p-4">
          <Text className="text-xl font-bold mb-4">All Scenarios Test:</Text>
          {getFilteredScenarios().map(scenario => (
            <View key={scenario.id} className="mb-4">
              <Text className="font-medium text-sm mb-2 text-gray-700">
                {scenario.description}
              </Text>
              <TransactionItem transaction={scenario} />
            </View>
          ))}
        </View>
      );
    }

    if (selectedScenario) {
      return (
        <View className="p-4">
          <Text className="text-xl font-bold mb-4">Single Scenario Test:</Text>
          <TransactionItem transaction={selectedScenario} />
        </View>
      );
    }

    return (
      <View className="p-4 items-center justify-center">
        <Text className="text-gray-500">Select a scenario to test</Text>
      </View>
    );
  };

  return (
    <View className="bg-dark-page-bg">
      <View className="flex space-between h-full">
        <SafeAreaView>
          <Header
            showBack={true}
            title="Transaction Test Scenarios"
            onBack={handleBack}
          />
        </SafeAreaView>

        <ScrollView className="flex bg-white grow ">
          <SafeAreaView>
            {renderScenarioSelector()}
            {renderTransactions()}
          </SafeAreaView>
        </ScrollView>
      </View>
    </View>
  );
};
