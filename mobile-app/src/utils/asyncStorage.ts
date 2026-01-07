import AsyncStorage from '@react-native-async-storage/async-storage';
import {SESSION_TIMING} from '@/constants/timing';
import {TWO_FACTOR_TRUST_ID_KEY} from '@/constants/authFlow';
import {REMEMBER_EMAIL_KEY} from '@/constants/rememberMe';

export const isAmountHiddenKey = (userId: string) => `amountHidden:${userId}`;

export const isTTPBannerDismissedKey = (userId: string) =>
  `ttpBannerDismissed:${userId}`;
export const isTTPSplashScreenDismissedKey = (userId: string) =>
  `ttpSplashScreenDismissed:${userId}`;

export const resetAsyncStorageSession = async (): Promise<void> => {
  const keysToRemove = [SESSION_TIMING.LAST_ACTIVITY_KEY];
  await Promise.all(keysToRemove.map(key => AsyncStorage.removeItem(key)));
};

export const getLastActivityTime = async (): Promise<string | null> => {
  const lastActivityTime = await AsyncStorage.getItem(
    SESSION_TIMING.LAST_ACTIVITY_KEY,
  );
  return lastActivityTime;
};

export const setLastActivityTime = async (time: number): Promise<void> => {
  await AsyncStorage.setItem(SESSION_TIMING.LAST_ACTIVITY_KEY, time.toString());
};

export const getTwoFactorTrustId = async (): Promise<string | null> => {
  const twoFactorTrustId = await AsyncStorage.getItem(TWO_FACTOR_TRUST_ID_KEY);
  return twoFactorTrustId;
};

export const setTwoFactorTrustId = async (id: string): Promise<void> => {
  await AsyncStorage.setItem(TWO_FACTOR_TRUST_ID_KEY, id);
};

export const removeTwoFactorTrustId = async (): Promise<void> => {
  await AsyncStorage.removeItem(TWO_FACTOR_TRUST_ID_KEY);
};

export const getRememberMeEmail = async (): Promise<string | null> => {
  const rememberMeEmail = await AsyncStorage.getItem(REMEMBER_EMAIL_KEY);
  return rememberMeEmail;
};

export const setRememberMeEmail = async (email: string): Promise<void> => {
  await AsyncStorage.setItem(REMEMBER_EMAIL_KEY, email);
};

export const removeRememberMeEmail = async (): Promise<void> => {
  await AsyncStorage.removeItem(REMEMBER_EMAIL_KEY);
};

export const getAmountHiddenKey = async (
  amountHiddenKey: string,
): Promise<string | null> => {
  const savedState = await AsyncStorage.getItem(amountHiddenKey);
  return savedState;
};

export const setAmountHiddenKey = async (
  userId: string,
  newState: boolean,
): Promise<void> => {
  await AsyncStorage.multiSet([
    ['userId', userId],
    [isAmountHiddenKey(userId), newState.toString()],
  ]);
};

export const getEnvironmentValue = async (
  env: string,
): Promise<string | null> => {
  const environment = await AsyncStorage.getItem(env);
  return environment;
};

export const setEnvironmentValue = async (
  env: string,
  environment: string,
): Promise<void> => {
  AsyncStorage.setItem(env, environment);
};

export const getTTPBannerDismissed = async (
  userId: string,
): Promise<boolean> => {
  const dismissed = await AsyncStorage.getItem(isTTPBannerDismissedKey(userId));
  return dismissed === 'true';
};

export const setTTPBannerDismissed = async (userId: string): Promise<void> => {
  await AsyncStorage.setItem(isTTPBannerDismissedKey(userId), 'true');
};

export const getTTPSplashScreenDismissed = async (
  userId: string,
): Promise<boolean> => {
  const dismissed = await AsyncStorage.getItem(
    isTTPSplashScreenDismissedKey(userId),
  );
  return dismissed === 'true';
};

export const setTTPSplashScreenDismissed = async (
  userId: string,
): Promise<void> => {
  await AsyncStorage.setItem(isTTPSplashScreenDismissedKey(userId), 'true');
};
