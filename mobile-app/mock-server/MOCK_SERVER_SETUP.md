# Mock Server Setup for Arise React Native UI

## Overview

I've successfully created a mock server that replaces the real API call to `api_url/transactions` with local mock data. The server is currently running and serving the transaction data you provided.

## What was created

### 1. Mock Server Files

- `mock-server/package.json` - Dependencies for Express.js server
- `mock-server/server.js` - Main server file with mock data
- `mock-server/start.sh` - Convenient startup script
- `mock-server/README.md` - Server documentation
- `mock-server/env.example` - Environment variable example

### 2. Modified Client Code

- Updated `src/clients/AriseClient.ts` to support mock server mode
- Added environment variable `USE_MOCK_SERVER` support
- Fixed linter errors in the original code

## Current Status

✅ **Mock server is running** on `http://localhost:3001`
✅ **Transactions endpoint** available at `http://localhost:3001/api/transactions`
✅ **Health check** available at `http://localhost:3001/health`
✅ **Server logs** show successful requests

## How to use

### Option 1: Use the mock server (current setup)

1. The mock server is already running in the background
2. Set `USE_MOCK_SERVER=true` in your environment variables
3. The `getTransactions()` function will automatically use the mock server

### Option 2: Start/stop the server manually

```bash
# Navigate to mock server directory
cd mock-server

# Start the server
./start.sh
# or
npm start

# Stop the server (find the process and kill it)
ps aux | grep "node server.js"
kill <process_id>
```

### Option 3: Use real API

1. Set `USE_MOCK_SERVER=false` or remove the environment variable
2. The `getTransactions()` function will use the real API

## Testing the mock server

```bash
# Health check
curl http://localhost:3001/health

# Get transactions
curl http://localhost:3001/api/transactions

# With query parameters
curl "http://localhost:3001/api/transactions?page=1&pageSize=10&asc=true"
```

## Environment Variables

Add to your `.env` file:

```
USE_MOCK_SERVER=true
```

## Server Details

- **Port**: 3001
- **Framework**: Express.js
- **CORS**: Enabled for React Native
- **Data**: 15 mock transactions with full structure
- **Response time**: ~100ms (simulated delay)

## Integration

The `getTransactions()` function in `AriseClient.ts` now checks for the `USE_MOCK_SERVER` environment variable:

```typescript
if (USE_MOCK_SERVER === 'true') {
  // Use mock server
  const response = await axios.get(`${MOCK_SERVER_URL}/api/transactions`, ...);
} else {
  // Use real API
  const response = await axios.get(API_URL + '/transactions', ...);
}
```

## Next Steps

1. Test the integration in your React Native app
2. Add more mock endpoints if needed
3. Customize the mock data as required
4. Consider adding more sophisticated filtering/pagination logic to the mock server

The mock server is ready to use and will provide consistent, predictable data for development and testing!
