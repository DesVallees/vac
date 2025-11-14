#!/bin/bash

# Test script for chargeAppointment function locally
# Make sure the emulator is running first: npm run serve

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Testing chargeAppointment function locally...${NC}\n"

# Local emulator URL
LOCAL_URL="http://localhost:5001/vac-plus/us-central1/chargeAppointment"

# Test data - adjust these values as needed
TEST_DATA='{
  "appointmentId": "test-appointment-123",
  "customer": {
    "name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "doc_type": "CC",
    "doc_number": "1234567890",
    "phone": "3001234567",
    "city": "Bogotá",
    "address": "Test Address 123"
  },
  "card": {
    "number": "4575623182290326",
    "exp_month": "12",
    "exp_year": "2025",
    "cvc": "123"
  },
  "amount": 10000,
  "description": "Test Payment"
}'

echo -e "${GREEN}Sending test request to: ${LOCAL_URL}${NC}\n"
echo -e "${BLUE}Request data:${NC}"
echo "$TEST_DATA" | jq '.'

echo -e "\n${BLUE}Response:${NC}\n"

# Make the request
curl -X POST "$LOCAL_URL" \
  -H "Content-Type: application/json" \
  -d "$TEST_DATA" \
  -w "\n\nHTTP Status: %{http_code}\n" \
  | jq '.'

echo -e "\n${GREEN}Test complete!${NC}"

