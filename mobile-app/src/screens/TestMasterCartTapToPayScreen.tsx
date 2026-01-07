import React, {useState, useCallback, useEffect} from 'react';
import {
  View,
  Text,
  SafeAreaView,
  TouchableOpacity,
  TextInput,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import AriseHeader from '@/components/baseComponents/AriseHeader';
import {TransactionDetails} from '../cloudcommerce'; // Adjust path as needed based on your project structure
import {logger} from '@/utils/logger';
import {NativeModules, NativeEventEmitter} from 'react-native';
const {CloudCommerceModule} = NativeModules;
const eventEmitter = new NativeEventEmitter(CloudCommerceModule);

const TestMasterCartTapToPayScreen = (): React.JSX.Element => {
  const countries = [
    {name: 'Brazil', code: 'BRA'},
    {name: 'Chile', code: 'CHL'},
    {name: 'India', code: 'IND'},
    {name: 'Poland', code: 'POL'},
    {name: 'Turkey', code: 'TUR'},
    {name: 'Ukraine', code: 'UKR'},
    {name: 'United States', code: 'USA'},
  ].sort((a, b) => a.name.localeCompare(b.name)); // Keep it sorted for better UX

  // State variables for the terminal functionality
  const [isPrepared, setIsPrepared] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [amount, setAmount] = useState(0); // Store amount in cents as a number
  const [status, setStatus] = useState('Ready to prepare');
  const [sdkState, setSdkState] = useState<string | null>(null);

  /**
   * @property {string} selectedCountryCode - The ISO code of the selected country.
   * @property {boolean} isPickerVisible - Controls the visibility of the country picker dropdown.
   * Simple UUID generator for React Native.
   * For production, consider a more robust library like `uuid`.
   */
  const generateUUID = useCallback(() => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
      /[xy]/g,
      function (c) {
        // eslint-disable-next-line no-bitwise
        const r = (Math.random() * 16) | 0;
        // eslint-disable-next-line no-bitwise
        const v = c === 'x' ? r : (r & 0x3) | 0x8;
        return v.toString(16);
      },
    );
  }, []);
  const [selectedCountryCode, setSelectedCountryCode] = useState(
    countries[0].code,
  );
  const [isPickerVisible, setIsPickerVisible] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Effect to subscribe to SDK events
  useEffect(() => {
    logger.info('Setting up CloudCommerce event listener...');
    const subscription = eventEmitter.addListener(
      'CloudCommerceEvent',
      event => {
        logger.info(
          'Received CloudCommerce Event:',
          JSON.stringify(event, null, 2),
        );

        // Handle different types of events based on the new structured format
        switch (event.type) {
          case 'StatusUpdate':
            setStatus(event.message);
            setSdkState(null);
            break;
          case 'ReaderState':
          case 'TransactionState':
            setStatus(event.message);
            setSdkState(event.state);
            break;
          case 'ReaderProgress':
            setStatus(`${event.message} ${event.progress}%`);
            setSdkState('progress');
            break;
          case 'TransactionResult':
            setStatus(`${event.message} (Success: ${event.success})`);
            setSdkState(event.success ? 'Completed' : 'Failed');
            break;
          case 'Error':
            setStatus(`❌ ERROR: ${event.message} (Code: ${event.code})`);
            setSdkState('Error');
            break;
          default:
            setStatus(`Unknown Event: ${event.message}`);
            setSdkState('Unknown');
        }
      },
    );

    // Cleanup function: remove the subscription when the component unmounts
    return () => {
      logger.info('Removing CloudCommerce event listener.');
      subscription.remove();
    };
  }, []); // The empty dependency array ensures this effect runs only once on mount and unmount
  /**
   * Formats a number (amount in cents) into a currency string.
   * Simulates terminal input where digits fill from the right for cents.
   * E.g., "1" -> "0.01", "12" -> "0.12", "123" -> "1.23", "005" -> "0.05".
   * @param amountInCents - A number representing the amount in cents.
   * @returns A formatted currency string (e.g., "12.34").
   */
  const formatCurrency = useCallback((amountInCents: number): string => {
    if (amountInCents === 0) {
      return '0.00'; // Display 0.00 if no digits are entered
    }

    const integerPart = Math.floor(amountInCents / 100);
    const fractionalPart = (amountInCents % 100).toString().padStart(2, '0');

    return `${integerPart}.${fractionalPart}`;
  }, []);

  /**
   * Handles changes in the amount TextInput, updating the amount in cents.
   * This logic is designed for a number-pad input where digits are appended.
   * @param text - The new text from the TextInput.
   */
  const handleAmountChange = useCallback(
    (text: string) => {
      // Remove any non-digit characters from the input
      const digitsOnly = text.replace(/\D/g, '');

      // Convert to cents (e.g., "123" becomes 123 cents)
      let newAmountInCents = parseInt(digitsOnly, 10) || 0;

      // Limit the maximum amount (e.g., $999,999.99 which is 99999999 cents)
      const MAX_AMOUNT_CENTS = 99999999;
      if (newAmountInCents <= MAX_AMOUNT_CENTS) {
        setAmount(newAmountInCents);
      }
    },
    [setAmount],
  );

  /**
   * Handles the "Prepare Terminal" action.
   * Initializes the CloudCommerce terminal.
   */
  const handlePerform = async () => {
    setIsLoading(true);
    setStatus('Preparing...');
    try {
      // IMPORTANT: Replace this hardcoded JWT token with a secure, dynamic token
      // obtained from your authentication system. Hardcoding tokens is a security risk.
      const response = await CloudCommerceModule.prepare(
        'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldJQUlTNFU1SUFNNzI5R1ZQLUFFWkJDRkRRSENQTUpSUkJOOENUVU4ifQ.eyJzdWIiOiI5YzljM2QyZi1lOTQ3LTQ3OTYtOTNlMi04OGQ3YmY3OTkxOTkiLCJhdWQiOiJjbG91ZHBvcyIsImp0aSI6IjI1YzBjNWE1LWJmZDMtNDkyMS04ODYyLWQ1NDc3ZDM0ZmI4NSIsImRldmljZV9pZCI6IjI4ZWYyZmE2LTBkNWYtNDgzOC1iMmMwLWI4ZmVjNmRmOGVyNSIsImlzcyI6Imh0dHBzOi8vb2F1dGgudWF0LnJpc2VvczIubmV0LyIsImlhdCI6MTc2Mjg3NzAzMCwiZXhwIjoxNzczMjQ1MDMwLCJuYmYiOjE3NjI4NzcwMzB9.oSX7W0tDXzb-UOGg9l36qXOq3tje7WI1b9DTJ3ulX150_L2v7xlfXLrxEUgXC4BU1adGAcy-SLC67mVCFjOuF52Kxt8nxSaUK9-ZdzfoN3LVUK4x1sCg4_Q3p4mhMdpPIgRwbWMJDHgcMk6UEVYSqGWtFgUrNqVcpwjlPEW2uSemmxPRAEEakNw22yrpwiy2EYtJStsJ2vZGZJWWzMLP3LBr_TYzSnExnUOfH1XrZn-I6UcyLf2oMZ7w9Kk9RPeeVAPBN32dSK0Tr1vUd6LNWqrmWw1rdx2MNhBnRO2yjnBwA4aYZHSuj322wubxiV62CmoBpCo8wLWB7T2zIVqO4g',
        {
          bannerName: "Caio's Barber Shop",
          categoryCode: '7230',
          terminalProfileId: '4c840000-0000-0000-0fd2-e456682cc625',
          currencyCode: 'USD',
          countryCode: selectedCountryCode,
        },
        false,
      );
      logger.info('Upgrade info', response);
      setIsPrepared(true);
      setStatus('✅ Prepared Successfully');
      Alert.alert('Success', 'Terminal prepared successfully!');
    } catch (e: any) {
      logger.error(e, 'Error during preparation');
      setStatus('❌ Preparation Failed');
      Alert.alert('Error', `Preparation failed: ${e.message || e}`);
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Handles the "Resume Terminal" action.
   * Resumes the CloudCommerce terminal session.
   */
  const handleResume = async () => {
    setIsLoading(true);
    setStatus('Resuming...');
    try {
      // IMPORTANT: Replace this hardcoded JWT token with a secure, dynamic token
      // obtained from your authentication system. Hardcoding tokens is a security risk.
      const jwtToken =
        'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldJQUlTNFU1SUFNNzI5R1ZQLUFFWkJDRkRRSENQTUpSUkJOOENUVU4ifQ.eyJzdWIiOiI5YzljM2QyZi1lOTQ3LTQ3OTYtOTNlMi04OGQ3YmY3OTkxOTkiLCJhdWQiOiJjbG91ZHBvcyIsImp0aSI6IjI1YzBjNWE1LWJmZDMtNDkyMS04ODYyLWQ1NDc3ZDM0ZmI4NSIsImRldmljZV9pZCI6IjI4ZWYyZmE2LTBkNWYtNDgzOC1iMmMwLWI4ZmVjNmRmOGVyNSIsImlzcyI6Imh0dHBzOi8vb2F1dGgudWF0LnJpc2VvczIubmV0LyIsImlhdCI6MTc2Mjg3NzAzMCwiZXhwIjoxNzczMjQ1MDMwLCJuYmYiOjE3NjI4NzcwMzB9.oSX7W0tDXzb-UOGg9l36qXOq3tje7WI1b9DTJ3ulX150_L2v7xlfXLrxEUgXC4BU1adGAcy-SLC67mVCFjOuF52Kxt8nxSaUK9-ZdzfoN3LVUK4x1sCg4_Q3p4mhMdpPIgRwbWMJDHgcMk6UEVYSqGWtFgUrNqVcpwjlPEW2uSemmxPRAEEakNw22yrpwiy2EYtJStsJ2vZGZJWWzMLP3LBr_TYzSnExnUOfH1XrZn-I6UcyLf2oMZ7w9Kk9RPeeVAPBN32dSK0Tr1vUd6LNWqrmWw1rdx2MNhBnRO2yjnBwA4aYZHSuj322wubxiV62CmoBpCo8wLWB7T2zIVqO4g';
      const upgrade = await CloudCommerceModule.resume(jwtToken);
      logger.info('Upgrade info', upgrade);
      setStatus('✅ Resumed Successfully');
    } catch (e: any) {
      logger.error(e, 'Error during resume');
      setStatus('❌ Resume Failed');
      Alert.alert('Error', `Resume failed: ${e.message || e}`);
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Handles the "Perform Transaction" action.
   * Initiates a transaction with the specified amount.
   */
  const handlePerformTransaction = async () => {
    const amountInCents = amount; // amount is already in cents

    if (amountInCents <= 0) {
      Alert.alert('Invalid Amount', 'Please enter a valid dollar amount');
      return;
    }

    if (!isPrepared) {
      Alert.alert('Not Prepared', 'Please prepare the terminal first');
      return;
    }

    setIsLoading(true);
    setStatus('Processing transaction...');

    const transactionDetails: TransactionDetails = {
      amount: (amountInCents / 100).toFixed(2),
      currencyCode: 'USD',
      countryCode: 'USA',
      tip: '0.00',
      discount: '0.00',
      salesTaxAmount: '0.00',
      federalTaxAmount: '0.00',
      customData: undefined,
      subTotal: formatCurrency(amountInCents), // subTotal as a formatted string (e.g., "1.23")
      orderId: generateUUID(),
    };

    try {
      const transactionResult = await CloudCommerceModule.performTransaction(
        transactionDetails,
      );
      logger.info('Transaction result:', transactionResult);
      setStatus('✅ Transaction Completed');
      Alert.alert(
        'Success',
        `Transaction completed for $${formatCurrency(amountInCents)}`,
      );
      setAmount(0); // Clear amount after successful transaction
    } catch (e: any) {
      logger.error(e, 'Error during transaction');
      setStatus('❌ Transaction Failed');
      Alert.alert('Error', `Transaction failed: ${e.message || e}`);
    } finally {
      setIsLoading(false);
    }
  };

  // Filter countries based on the search query
  const filteredCountries = countries.filter(country =>
    country.name.toLowerCase().includes(searchQuery.toLowerCase()),
  );

  return (
    <SafeAreaView style={styles.safeArea}>
      <AriseHeader title="Tap to Pay Test" />
      <KeyboardAvoidingView
        style={styles.keyboardAvoidingContainer}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
        <ScrollView
          contentContainerStyle={styles.scrollContainer}
          keyboardShouldPersistTaps="handled">
          <View style={styles.innerContainer}>
            <Text style={styles.title}>CloudCommerce Terminal</Text>

            {/* Status Section */}
            <View style={styles.statusContainer}>
              {sdkState && (
                <>
                  <Text style={styles.statusLabel}>SDK State:</Text>
                  <Text style={styles.sdkStateText}>{sdkState}</Text>
                </>
              )}
              <Text
                style={[styles.statusLabel, sdkState ? {marginTop: 8} : {}]}>
                Status Message:
              </Text>
              <Text
                style={[
                  styles.statusText,
                  isPrepared ? styles.successText : styles.neutralText,
                ]}>
                {status}
              </Text>
            </View>

            {/* Country Picker Section */}
            {!isPrepared && (
              <View style={styles.pickerSection}>
                <Text style={styles.pickerLabel}>Select Country:</Text>
                <TouchableOpacity
                  style={styles.pickerButton}
                  onPress={() => {
                    // Clear search when opening the picker
                    if (!isPickerVisible) {
                      setSearchQuery('');
                    }
                    setIsPickerVisible(!isPickerVisible);
                  }}>
                  <Text style={styles.pickerButtonText}>
                    {countries.find(c => c.code === selectedCountryCode)?.name}
                  </Text>
                </TouchableOpacity>
                {isPickerVisible && (
                  <View style={styles.pickerOptionsContainer}>
                    <TextInput
                      style={styles.searchInput}
                      placeholder="Search country..."
                      placeholderTextColor="#999"
                      value={searchQuery}
                      onChangeText={setSearchQuery}
                    />
                    <ScrollView style={{maxHeight: 200}}>
                      {filteredCountries.map(country => (
                        <TouchableOpacity
                          key={country.code}
                          style={styles.pickerOption}
                          onPress={() => {
                            setSelectedCountryCode(country.code);
                            setIsPickerVisible(false);
                          }}>
                          <Text style={styles.pickerOptionText}>
                            {country.name}
                          </Text>
                        </TouchableOpacity>
                      ))}
                    </ScrollView>
                  </View>
                )}
              </View>
            )}

            {/* Prepare Button */}
            <TouchableOpacity
              style={[
                styles.button,
                styles.prepareButton,
                isLoading && styles.disabledButton,
              ]}
              onPress={handlePerform}
              disabled={isLoading}>
              <Text style={styles.buttonText}>
                {isLoading && status.includes('Preparing')
                  ? 'Preparing...'
                  : 'Prepare Terminal'}
              </Text>
            </TouchableOpacity>

            {/* Resume Button */}
            <TouchableOpacity
              style={[
                styles.button,
                styles.resumeButton,
                isLoading && styles.disabledButton,
              ]}
              onPress={handleResume}
              disabled={isLoading}>
              <Text style={styles.buttonText}>
                {isLoading && status.includes('Resuming')
                  ? 'Resuming...'
                  : 'Resume Terminal'}
              </Text>
            </TouchableOpacity>

            {/* Amount Entry Section */}
            {isPrepared && (
              <View style={styles.amountSection}>
                <Text style={styles.sectionTitle}>Transaction Amount</Text>
                <View style={styles.amountInputContainer}>
                  <Text style={styles.dollarSign}>$</Text>
                  <TextInput
                    style={styles.amountInput}
                    value={formatCurrency(amount)} // Display the formatted amount from cents
                    onChangeText={handleAmountChange}
                    placeholder="0.00"
                    keyboardType="number-pad" // Recommended for numeric input without extra characters
                    returnKeyType="done"
                  />
                </View>

                <TouchableOpacity
                  // Disable button if amount is 0 or invalid, or if loading
                  style={[
                    styles.button,
                    styles.transactionButton,
                    (amount <= 0 || isLoading) && styles.disabledButton,
                  ]}
                  onPress={handlePerformTransaction}
                  disabled={amount <= 0 || isLoading}>
                  <Text style={styles.buttonText}>
                    {isLoading && status.includes('Processing')
                      ? 'Processing...'
                      : `Process Transaction ${
                          amount > 0 ? `($${formatCurrency(amount)})` : ''
                        }`}
                  </Text>
                </TouchableOpacity>
              </View>
            )}
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default TestMasterCartTapToPayScreen;

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5', // Background for the entire screen
  },
  keyboardAvoidingContainer: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1, // Ensures content can grow and enable scrolling
    justifyContent: 'center', // Keeps content centered if smaller than screen
    backgroundColor: '#f5f5f5', // Match the innerContainer background
  },
  innerContainer: {
    // Replaces the old 'container' for padding and background
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  statusContainer: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statusLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
    marginBottom: 5,
  },
  statusText: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  sdkStateText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FF9800', // An orange color for the state
    marginBottom: 4,
    textTransform: 'capitalize',
  },
  successText: {
    color: '#4CAF50',
  },
  neutralText: {
    color: '#666',
  },
  button: {
    padding: 15,
    borderRadius: 10,
    marginVertical: 8,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  prepareButton: {
    backgroundColor: '#2196F3',
  },
  infoButton: {
    backgroundColor: '#607D8B', // A neutral grey/blue color
  },
  resumeButton: {
    backgroundColor: '#FF9800',
  },
  transactionButton: {
    backgroundColor: '#4CAF50',
    marginTop: 15,
  },
  disabledButton: {
    backgroundColor: '#ccc',
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  amountSection: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 10,
    marginTop: 20,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
    textAlign: 'center',
  },
  amountInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#ddd',
    borderRadius: 10,
    paddingHorizontal: 15,
    backgroundColor: '#f9f9f9',
    marginBottom: 10,
  },
  dollarSign: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginRight: 5,
  },
  amountInput: {
    flex: 1,
    fontSize: 24,
    padding: 15,
    color: '#333',
  },
  pickerSection: {
    marginBottom: 20,
  },
  pickerLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
    marginBottom: 8,
  },
  pickerButton: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    alignItems: 'center',
  },
  pickerButtonText: {
    fontSize: 16,
    color: '#333',
  },
  pickerOptionsContainer: {
    marginTop: 5,
    backgroundColor: '#fff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  pickerOption: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  pickerOptionText: {
    fontSize: 16,
    color: '#333',
  },
  searchInput: {
    paddingHorizontal: 15,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    fontSize: 16,
    color: '#333',
    backgroundColor: '#fff',
  },
});
