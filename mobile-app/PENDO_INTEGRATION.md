# Pendo SDK Integration Guide

This document describes the Pendo SDK integration implemented in the Arise React Native app.

## Overview

Pendo has been integrated to track user behavior, collect analytics, and enable in-app messaging. The integration includes:

- Singleton service to prevent multiple initialization
- useEffect protection against multiple instances
- Automatic session management during login/logout
- React Navigation integration for screen tracking

## Architecture

### PendoService (Singleton)

Located in `src/services/PendoService.ts`, this service ensures:

- Only one Pendo instance is created
- Prevents multiple setup calls
- Manages session state
- Provides wrapped NavigationContainer

### usePendo Hook

Located in `src/hooks/usePendo.ts`, this hook:

- Automatically initializes Pendo once
- Provides startSession/endSession methods
- Uses useRef to prevent multiple useEffect calls
- Includes error handling

### Integration Points

1. **App.tsx**: Initializes Pendo and wraps NavigationContainer
2. **LoginScreen.tsx**: Starts Pendo session on successful login
3. **HomeScreen.tsx**: Ends session on manual logout
4. **appReset.ts**: Ends session during automatic logout/reset

## Usage

### Starting a Session

Sessions are automatically started after successful login with user data:

```typescript
const {startSession} = usePendo();

await startSession(
  visitorId, // User ID
  accountId, // Account/Application ID
  visitorData, // User metadata
  accountData, // Account metadata
);
```

### Ending a Session

Sessions are automatically ended during logout, but can be manually triggered:

```typescript
const {endSession} = usePendo();
await endSession();
```

### Custom Events (Optional)

You can track custom events using the PendoSDK directly:

```typescript
import {PendoSDK} from 'rn-pendo-sdk';

// Track custom events
PendoSDK.track('button_clicked', {
  buttonName: 'New Transaction',
  screenName: 'Home',
});
```

## Error Handling

The integration includes comprehensive error handling:

- Failed Pendo initialization doesn't block app functionality
- Logout continues even if Pendo session ending fails
- All errors are logged for debugging

## Troubleshooting

### Common Issues

1. **Multiple Setup Calls**

   - The singleton pattern prevents this
   - Check for "Pendo is already set up" in logs

2. **Session Not Starting**

   - Verify the app key is correct
   - Check network connectivity
   - Review error logs

3. **iOS Build Issues**

   - Ensure `pod install` was run after adding the SDK
   - Verify AppDelegate.mm imports are correct
