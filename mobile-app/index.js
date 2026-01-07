/**
 * @format
 */

import 'react-native-get-random-values';
import {AppRegistry} from 'react-native';
import {name as appName} from './app.json';
import Root from './src/Root';

import {LogBox} from 'react-native';
LogBox.ignoreLogs(['Warning: ...']); // Ignore log notification by message
LogBox.ignoreAllLogs(); //Ignore all log notifications

AppRegistry.registerComponent(appName, () => Root);
