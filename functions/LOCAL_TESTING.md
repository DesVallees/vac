# Local Testing Guide

This guide explains how to test Firebase Cloud Functions locally before deploying to production.

## Prerequisites

1. **Firebase CLI** installed and logged in
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Node.js 20** installed

3. **ePayco Test Credentials** - Get these from your ePayco dashboard

## Setup

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Set Up Environment Variables

Create a `.env` file in the `functions` directory (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and add your ePayco test credentials:

```env
EPAYCO_PUBLIC_KEY=your_test_public_key
EPAYCO_PRIVATE_KEY=your_test_private_key
EPAYCO_CUSTOMER_ID=your_test_customer_id
EPAYCO_P_KEY=your_test_p_key
```

### 3. Build the Functions

```bash
npm run build
```

## Running the Emulator

### Start the Functions Emulator

```bash
npm run serve
```

This will:
- Build the TypeScript code
- Start the Firebase Functions emulator on port 5001
- Start the Firebase Emulator UI on port 4000

You should see output like:
```
✔  functions[chargeAppointment]: http function initialized (http://localhost:5001/vac-plus/us-central1/chargeAppointment).
✔  All emulators ready! It is now safe to connect.
```

### Access the Emulator UI

Open your browser to: http://localhost:4000

This provides a nice interface to:
- View function logs
- Test functions interactively
- Monitor requests

## Testing the Function

### Option 1: Using the Test Script (Node.js)

```bash
# In a new terminal, make sure you've set environment variables
export EPAYCO_PUBLIC_KEY="your_key"
export EPAYCO_PRIVATE_KEY="your_key"
export EPAYCO_CUSTOMER_ID="your_id"
export EPAYCO_P_KEY="your_key"

# Run the test script
node test-local.js
```

### Option 2: Using the Test Script (Bash)

```bash
# Make sure environment variables are set
export EPAYCO_PUBLIC_KEY="your_key"
export EPAYCO_PRIVATE_KEY="your_key"
export EPAYCO_CUSTOMER_ID="your_id"
export EPAYCO_P_KEY="your_key"

# Make script executable
chmod +x test-local.sh

# Run the test
./test-local.sh
```

### Option 3: Using cURL

```bash
curl -X POST http://localhost:5001/vac-plus/us-central1/chargeAppointment \
  -H "Content-Type: application/json" \
  -d '{
    "appointmentId": "test-123",
    "customer": {
      "name": "Test",
      "last_name": "User",
      "email": "test@example.com",
      "doc_type": "CC",
      "doc_number": "1234567890",
      "phone": "3001234567",
      "city": "Bogotá",
      "address": "Test Address"
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
```

### Option 4: Using the Emulator UI

1. Go to http://localhost:4000
2. Click on "Functions" in the sidebar
3. Find `chargeAppointment`
4. Click "Test function"
5. Enter your test data in JSON format
6. Click "Test"

## Important Notes

### Test Mode

The function automatically runs in **test mode** when using the emulator. This means:
- It will use ePayco's test environment
- Test card numbers can be used
- No real charges will be made

### Test Card Numbers

For testing, you can use ePayco's test card numbers:
- **Card Number**: `4575623182290326`
- **CVV**: Any 3 digits (e.g., `123`)
- **Expiry**: Any future date

### Amount Limits

ePayco test mode has transaction limits. Use smaller amounts (e.g., 10,000 - 50,000 COP) for testing.

### Firestore

The emulator will try to connect to your actual Firestore database. If you want to use a local Firestore emulator, you'll need to:
1. Add Firestore emulator to `firebase.json`
2. Configure your app to use the emulator

For now, it will use your production Firestore (but with test payments, this should be safe).

## Troubleshooting

### "ePayco credentials not found"

Make sure you've set the environment variables:
```bash
export EPAYCO_PUBLIC_KEY="your_key"
export EPAYCO_PRIVATE_KEY="your_key"
export EPAYCO_CUSTOMER_ID="your_id"
export EPAYCO_P_KEY="your_key"
```

### "Cannot connect to emulator"

Make sure the emulator is running:
```bash
npm run serve
```

### "Function not found"

Check the function name in the URL. It should be:
```
http://localhost:5001/vac-plus/us-central1/chargeAppointment
```

Replace `vac-plus` with your project ID if different.

## Deploying After Testing

Once you've tested locally and everything works:

```bash
# Build the functions
npm run build

# Deploy to production
firebase deploy --only functions:chargeAppointment
```

The function will automatically use production secrets from Firebase Secrets Manager when deployed.

