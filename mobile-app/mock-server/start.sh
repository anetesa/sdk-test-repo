#!/bin/bash

echo "Starting Arise Mock Server..."
echo "Server will be available at: http://localhost:3001"
echo "Transactions endpoint: http://localhost:3001/api/transactions"
echo "Health check: http://localhost:3001/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

node server.js 