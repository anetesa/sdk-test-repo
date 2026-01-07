# Arise Merchant App - Tap to Pay Architecture

This document describes the architecture and data flow for the Tap to Pay implementation in the Arise Merchant App. It details how the React Native UI layer interacts with the native iOS SDK through a centralized Zustand store.

## Architecture Overview

The Tap to Pay implementation follows a unidirectional data flow pattern using a centralized store (`CloudCommerceStore`) that acts as the "Brain" of the operation. This store manages the state machine, handles errors, and bridges the gap between the React Native UI and the native iOS hardware events.

## Key Components & Methods

### 1. Preparation & Configuration (Initialization)

These methods handle the setup of the payment terminal hardware and software session.

- **`prepareTerminal()`**

  - **Purpose:** Initializes the underlying SDK, authenticates with the backend, and prepares the NFC hardware.
  - **Trigger:** Automatically triggered after a successful **Login** (only if active is true). It ensures the terminal is ready before the user even navigates to the payment screen.

- **`activateTapToPay()`**
  - **Purpose:** Checks permissions and activates the Tap to Pay capability on the merchant's account.
  - **Trigger:** on TapToPaySplashScreen.tsx Screen

### 2. Transaction Flow (Processing Payments)

The core business logic for executing a payment.

- **`resumeTerminal()`**

  - **Purpose:** Refreshes the existing session without a full re-initialization. It is lighter and faster than `prepareTerminal`.
  - **Trigger:** Called by **`LoadingTapToPayScreen`** when starting a new transaction to ensure the session token is valid.

- **`performTransaction(details)`**
  - **Purpose:** Sends the transaction data (amount, currency, etc.) to the native SDK.

### 3. Event System (Real-time Feedback)

Manages the bidirectional communication between the Native SDK and the UI.

- **`subscribeToCloudCommerceEvents()`**
  - **Purpose:** Establishes the listener for native events.
- **`convertTTPEventToCloudCommerceEvent(event)`**

  - **Purpose:** **The Adapter.** Translates raw native events (e.g., `readNotCompleted`, `pinEntryRequested`) into the standardized format expected by the UI (`CloudCommerceEvent`).

- **`handleSdkEvent(event)`**
  - **Purpose:** The state reducer. Receives the translated event and updates the store's `status` and `sdkState`.
  - **Example:** Receiving an `Approved` event.

### 4. Resilience & Recovery (The "Safety Net")

Defensive programming to handle edge cases like app backgrounding or hardware interruptions.

- **`handleBackgroundReturn()`**

  - **Purpose:** Automatic self-healing. When the app returns to the foreground (`active` state), it checks if the terminal connection was lost.
  - **Logic:** If the terminal is disconnected or in an error state, it silently calls `prepareTerminal()` to reconnect, ensuring the user finds a ready-to-use app.

## Error Handling & Recovery Strategy

Tap to Pay errors can come from two places, and we handle both:

### 1) Native Promise Failures (command calls)

These are errors thrown/rejected by native calls like:

- `prepareTerminal()` → `CloudCommerce.prepare()` → native `AriseMobileSdk.ttp.prepare()`
- `resumeTerminal()` → `CloudCommerce.resume()` → native `AriseMobileSdk.ttp.resume()`
- `performTransaction()` → `CloudCommerce.performTransaction()` → native `AriseMobileSdk.ttp.performTransaction()`

**How we handle them:**

- The store sets `error` and `status` so the UI can decide what to do next.
- Some errors are treated as expected/non-fatal (e.g., “no active session” on resume) and are not persisted as `error` to avoid showing an error UI.

### 2) Streaming SDK Events (real-time TTP events)

While a transaction is running, the SDK emits a stream of events (reader state, transaction state, status updates).

**Pipeline:**

1. `subscribeToCloudCommerceEvents()` registers a listener.
2. Raw `TTPEvent` comes from the native event emitter.
3. `convertTTPEventToCloudCommerceEvent()` translates it into a `CloudCommerceEvent`.
4. `handleSdkEvent()` updates the store (`status`, `sdkState`, `error`, `readerProgress`).

### App-Level Error Taxonomy (GPS / Device / Reader / Attestation / etc.)

We maintain a canonical mapping layer for CloudCommerce/Tap to Pay errors in `src/constants/cloudCommerceErrors.ts`.

- **`CLOUD_COMMERCE_ERROR_MAPPINGS`**: maps error codes to a `CloudCommerceErrorInfo` object with:

  - user-facing `title` and `message`

- **`getCloudCommerceErrorInfo(error)`**: extracts an error code from different formats (native error objects, event payloads, or string messages) and returns the matching `CloudCommerceErrorInfo`

#### GPS / Location Examples

This is the layer that drives your “GPS errors” behavior:

- `GPS003`, `GPS006`: location required / device could not be located
- `GPS004`: merchant not allowed to operate in the current country
- `GPS005`: partner not allowed to operate in the current country

> Note: **Device country detection** (`detectCountryFromDevice()` using `react-native-localize`) is not the same thing as **CloudCommerce GPS/location validation** (`GPS00x` errors).
>
> - Device country detection is a best-effort locale-based mapping used for SDK configuration defaults.
> - `GPS00x` errors are policy/location validations coming from the Tap to Pay / CloudCommerce flow and must be surfaced to the user with the mapped remediation actions.

### Special Cases We Handle Explicitly

- **User cancellation / UI dismissed (iOS Reader `ReadError 13`)**

  - Treated as a **user-driven cancellation**, not a “system error”.
  - The store clears the error and signals the UI via `sdkState` so the screen can navigate back cleanly without showing an error page.

- **Background/Foreground transitions**
  - On app becoming active, we re-subscribe to events and call `handleBackgroundReturn()` to proactively ensure the terminal is usable.

### UI Behavior (What the screen does)

`LoadingTapToPayScreen` listens to `cloudCommerce.error`, `sdkState`, and preparation flags:

- For **cancellation-like states**, it navigates back immediately.

## References

- Mastercard Cloud Commerce iOS SDK documentation: [Cloud Commerce iOS SDK Docs](https://developer.mastercard.com/cloud-commerce-ios-sdk/documentation/)
