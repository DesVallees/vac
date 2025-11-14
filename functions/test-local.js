/**
 * Test script for chargeAppointment function locally
 * Usage: node test-local.js
 * 
 * Make sure the emulator is running first: npm run serve
 */

const http = require('http');

const LOCAL_URL = 'http://localhost:5001/vac-plus/us-central1/chargeAppointment';

// Test data - adjust these values as needed
const testData = {
    appointmentId: 'test-appointment-123',
    customer: {
        name: 'Test',
        last_name: 'User',
        email: 'test@example.com',
        doc_type: 'CC',
        doc_number: '1234567890',
        phone: '3001234567',
        city: 'Bogotá',
        address: 'Test Address 123'
    },
    card: {
        number: '4575623182290326', // Test card number
        exp_month: '12',
        exp_year: '2025',
        cvc: '123'
    },
    amount: 10000, // Small amount for testing
    description: 'Test Payment'
};

console.log('Testing chargeAppointment function locally...\n');
console.log('Request URL:', LOCAL_URL);
console.log('Request data:', JSON.stringify(testData, null, 2));
console.log('\n---\n');

const postData = JSON.stringify(testData);

const options = {
    hostname: 'localhost',
    port: 5001,
    path: '/vac-plus/us-central1/chargeAppointment',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
    }
};

const req = http.request(options, (res) => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Headers:`, res.headers);
    console.log('\n---\n');

    let data = '';

    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        try {
            const parsed = JSON.parse(data);
            console.log('Response:', JSON.stringify(parsed, null, 2));
        } catch (e) {
            console.log('Response (raw):', data);
        }
    });
});

req.on('error', (error) => {
    console.error('Error:', error);
    console.error('\nMake sure the emulator is running: npm run serve');
});

req.write(postData);
req.end();

