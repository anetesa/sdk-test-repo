# Arise Mock Server

This is a mock server for the Arise React Native UI application that provides fake transaction data.

## Setup

1. Navigate to the mock-server directory:

```bash
cd mock-server
```

2. Install dependencies:

```bash
npm install
```

3. Start the server:

```bash
npm start
```

For development with auto-restart:

```bash
npm run dev
```

## Endpoints

- `GET /api/transactions` - Returns mock transaction data
- `GET /health` - Health check endpoint
- `GET /` - Server info

## Usage

The server runs on `http://localhost:3001` by default.

To test the transactions endpoint:

```bash
curl http://localhost:3001/api/transactions
```

## Integration with React Native App

The AriseClient.ts file has been modified to use this mock server instead of the real API when the `USE_MOCK_SERVER` environment variable is set to `true`.

To enable mock server mode, set the environment variable in your `.env` file:

```
USE_MOCK_SERVER=true
```
