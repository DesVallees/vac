"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.epaycoConfirmation = exports.epaycoResponse = exports.chargeAppointment = exports.startCheckout = void 0;
const functions = require("firebase-functions");
const params_1 = require("firebase-functions/params");
const admin = require("firebase-admin");
const crypto = require("crypto");
// Import epayco-sdk-node with any type for now
const epaycoSDK = require('epayco-sdk-node');
// Initialize Firebase Admin
admin.initializeApp();
// Define secrets from Firebase Secrets Manager
const EPAYCO_PUBLIC_KEY = (0, params_1.defineSecret)('EPAYCO_PUBLIC_KEY');
const EPAYCO_PRIVATE_KEY = (0, params_1.defineSecret)('EPAYCO_PRIVATE_KEY');
const EPAYCO_CUSTOMER_ID = (0, params_1.defineSecret)('EPAYCO_CUSTOMER_ID');
const EPAYCO_P_KEY = (0, params_1.defineSecret)('EPAYCO_P_KEY');
// Initialize ePayco SDK
let epayco = null;
/**
 * Initialize ePayco SDK with secrets
 */
function initializeEpayco() {
    if (!epayco) {
        const publicKey = EPAYCO_PUBLIC_KEY.value();
        const privateKey = EPAYCO_PRIVATE_KEY.value();
        epayco = epaycoSDK({
            apiKey: publicKey,
            privateKey: privateKey,
            lang: 'ES',
            test: true, // Set to false for production
        });
    }
    return epayco;
}
/**
 * Generates ePayco signature for secure payment processing
 * @param data - Object containing payment data
 * @param pKey - ePayco private key
 * @returns SHA256 signature
 */
function generateSignature(data, pKey) {
    // Sort keys alphabetically for consistent signature generation
    const sortedKeys = Object.keys(data).sort();
    const signatureString = sortedKeys
        .map(key => `${key}=${data[key]}`)
        .join('&') + `&p_key=${pKey}`;
    return crypto.createHash('sha256').update(signatureString).digest('hex');
}
/**
 * Creates ePayco checkout payload with proper signature
 * @param request - Payment request data
 * @returns Checkout payload for ePayco
 */
function createCheckoutPayload(request) {
    const publicKey = EPAYCO_PUBLIC_KEY.value();
    const privateKey = EPAYCO_PRIVATE_KEY.value();
    const customerId = EPAYCO_CUSTOMER_ID.value();
    const pKey = EPAYCO_P_KEY.value();
    if (!publicKey || !privateKey || !customerId || !pKey) {
        throw new Error('Missing ePayco configuration secrets');
    }
    // Generate unique invoice ID
    const invoice = `VAQ-${request.appointmentId}-${Date.now()}`;
    // Create base payment data
    const paymentData = {
        p_cust_id_cliente: customerId,
        p_key: pKey,
        p_amount: request.amountCOP.toString(),
        p_currency_code: 'COP',
        p_description: request.description,
        p_signature: '',
        p_customer_email: request.customer.email,
        p_customer_document: '',
        p_customer_name: request.customer.name,
        p_customer_lastname: '',
        p_customer_phone: '',
        p_customer_address: '',
        p_customer_city: '',
        p_customer_country: 'CO',
        p_test_request: 'TRUE',
        p_url_response: 'https://us-central1-vac-plus.cloudfunctions.net/epaycoResponse',
        p_url_confirmation: 'https://us-central1-vac-plus.cloudfunctions.net/epaycoConfirmation',
        p_extra1: request.appointmentId,
        p_extra2: request.customer.uid,
        p_invoice: invoice,
        p_tax: '0',
        p_tax_base: request.amountCOP.toString(),
    };
    // Generate signature
    const signature = generateSignature(paymentData, pKey);
    paymentData.p_signature = signature;
    // Return payload in format expected by Flutter WebView
    return {
        public_key: publicKey,
        p_key: pKey,
        amount: request.amountCOP.toString(),
        name: request.description,
        currency: 'COP',
        invoice: invoice,
        tax: '0',
        description: request.description,
        response: 'https://us-central1-vac-plus.cloudfunctions.net/epaycoResponse',
        confirmation: 'https://us-central1-vac-plus.cloudfunctions.net/epaycoConfirmation',
        testMode: true,
        external: JSON.stringify({
            appointmentId: request.appointmentId,
            customerUid: request.customer.uid,
            customerEmail: request.customer.email,
            customerName: request.customer.name,
        }),
    };
}
/**
 * Validates the request body for required fields
 * @param body - Request body to validate
 * @returns Validation result
 */
function validateRequest(body) {
    if (!body) {
        return { isValid: false, error: 'Request body is required' };
    }
    const { appointmentId, amountCOP, description, customer } = body;
    if (!appointmentId || typeof appointmentId !== 'string') {
        return { isValid: false, error: 'appointmentId is required and must be a string' };
    }
    if (!amountCOP || typeof amountCOP !== 'number' || amountCOP <= 0) {
        return { isValid: false, error: 'amountCOP is required and must be a positive number' };
    }
    if (!description || typeof description !== 'string') {
        return { isValid: false, error: 'description is required and must be a string' };
    }
    if (!customer || typeof customer !== 'object') {
        return { isValid: false, error: 'customer is required and must be an object' };
    }
    const { uid, name, email } = customer;
    if (!uid || typeof uid !== 'string') {
        return { isValid: false, error: 'customer.uid is required and must be a string' };
    }
    if (!name || typeof name !== 'string') {
        return { isValid: false, error: 'customer.name is required and must be a string' };
    }
    if (!email || typeof email !== 'string') {
        return { isValid: false, error: 'customer.email is required and must be a string' };
    }
    return { isValid: true };
}
/**
 * Firebase Function: Start ePayco Checkout
 *
 * This endpoint creates a signed checkout payload for ePayco payment processing.
 * The Flutter app will use this payload to render the ePayco checkout widget
 * in an embedded WebView.
 *
 * Expected Input:
 * {
 *   "appointmentId": "b3c36740-b21f-4954-86f0-5e5ea7249e73",
 *   "amountCOP": 459000,
 *   "description": "Cita médica",
 *   "customer": { "uid": "...", "name": "...", "email": "..." }
 * }
 *
 * Response:
 * {
 *   "success": true,
 *   "checkoutPayload": {
 *     "public_key": "...",
 *     "p_key": "...",
 *     "amount": "...",
 *     "name": "...",
 *     "currency": "COP",
 *     "invoice": "...",
 *     "tax": "0",
 *     "description": "...",
 *     "response": "<URL webhook>",
 *     "confirmation": "<URL webhook>"
 *   }
 * }
 *
 * Flutter Integration:
 * The returned checkoutPayload should be passed to the ePayco JavaScript SDK
 * in the WebView HTML. The SDK will handle the payment form rendering and
 * redirect to custom scheme URLs (vaq://payment/success or vaq://payment/failure)
 * upon completion.
 */
exports.startCheckout = functions.runWith({
    secrets: [EPAYCO_PUBLIC_KEY, EPAYCO_PRIVATE_KEY, EPAYCO_CUSTOMER_ID, EPAYCO_P_KEY]
}).https.onRequest(async (req, res) => {
    // Set CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }
    // Only allow POST requests
    if (req.method !== 'POST') {
        res.status(405).json({
            success: false,
            error: 'Method not allowed. Only POST requests are supported.'
        });
        return;
    }
    try {
        // Validate request body
        const validation = validateRequest(req.body);
        if (!validation.isValid) {
            res.status(400).json({
                success: false,
                error: validation.error
            });
            return;
        }
        const request = req.body;
        // Create checkout payload
        const checkoutPayload = createCheckoutPayload(request);
        // Log successful checkout creation (for audit)
        functions.logger.info('Checkout created successfully', {
            appointmentId: request.appointmentId,
            amount: request.amountCOP,
            customerUid: request.customer.uid,
            invoice: checkoutPayload.invoice
        });
        // Return success response
        res.status(200).json({
            success: true,
            checkoutPayload
        });
    }
    catch (error) {
        functions.logger.error('Error creating checkout', error);
        // Return error response
        res.status(500).json({
            success: false,
            error: 'Internal server error. Please try again later.'
        });
    }
});
/**
 * Direct payment processing using ePayco SDK
 * This function handles the complete payment flow:
 * 1. Tokenize card
 * 2. Create/update customer
 * 3. Process charge
 * 4. Update Firestore
 */
exports.chargeAppointment = functions.runWith({
    secrets: [EPAYCO_PUBLIC_KEY, EPAYCO_PRIVATE_KEY, EPAYCO_CUSTOMER_ID, EPAYCO_P_KEY]
}).https.onRequest(async (req, res) => {
    var _a, _b, _c, _d;
    // Set CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }
    // Only allow POST requests
    if (req.method !== 'POST') {
        res.status(405).json({
            success: false,
            error: 'Method not allowed. Only POST requests are supported.'
        });
        return;
    }
    try {
        // Validate request body
        const validation = validateChargeRequest(req.body);
        if (!validation.isValid) {
            res.status(400).json({
                success: false,
                error: validation.error
            });
            return;
        }
        const request = req.body;
        // Initialize ePayco SDK
        const epaycoClient = initializeEpayco();
        // Step 1: Tokenize card
        functions.logger.info('Tokenizing card for appointment', { appointmentId: request.appointmentId });
        const cardInfo = {
            "card[number]": request.card.number,
            "card[exp_year]": request.card.exp_year,
            "card[exp_month]": request.card.exp_month,
            "card[cvc]": request.card.cvc,
            "hasCvv": true
        };
        const tokenResult = await epaycoClient.token.create(cardInfo);
        if (!tokenResult.success) {
            throw new Error(`Token creation failed: ${((_a = tokenResult.error) === null || _a === void 0 ? void 0 : _a.message) || 'Unknown error'}`);
        }
        // Step 2: Create or update customer
        functions.logger.info('Creating/updating customer', {
            appointmentId: request.appointmentId,
            email: request.customer.email
        });
        const customerInfo = {
            token_card: tokenResult.id,
            name: request.customer.name,
            last_name: request.customer.last_name,
            email: request.customer.email,
            default: true,
            city: request.customer.city || 'Bogotá',
            address: request.customer.address || 'N/A',
            phone: request.customer.phone || '3000000000',
            cell_phone: request.customer.phone || '3000000000'
        };
        const customerResult = await epaycoClient.customers.create(customerInfo);
        if (!customerResult.success) {
            throw new Error(`Customer creation failed: ${((_b = customerResult.error) === null || _b === void 0 ? void 0 : _b.message) || 'Unknown error'}`);
        }
        // Step 3: Process charge
        functions.logger.info('Processing charge', {
            appointmentId: request.appointmentId,
            amount: request.amount
        });
        const paymentInfo = {
            token_card: tokenResult.id,
            customer_id: customerResult.data.customerId,
            doc_type: request.customer.doc_type,
            doc_number: request.customer.doc_number,
            name: request.customer.name,
            last_name: request.customer.last_name,
            email: request.customer.email,
            city: request.customer.city || 'Bogotá',
            address: request.customer.address || 'N/A',
            phone: request.customer.phone || '3000000000',
            cell_phone: request.customer.phone || '3000000000',
            bill: `VAQ-${request.appointmentId}-${Date.now()}`,
            description: request.description,
            value: request.amount.toString(),
            tax: "0",
            tax_base: request.amount.toString(),
            currency: "COP",
            dues: "1",
            ip: req.ip || "127.0.0.1",
            url_response: `https://us-central1-vac-plus.cloudfunctions.net/epaycoResponse`,
            url_confirmation: `https://us-central1-vac-plus.cloudfunctions.net/epaycoConfirmation`,
            method_confirmation: "GET",
            use_default_card_customer: true,
            extras: {
                extra1: request.appointmentId,
                extra2: request.customer.email,
                extra3: "",
                extra4: "",
                extra5: "",
                extra6: ""
            }
        };
        const chargeResult = await epaycoClient.charge.create(paymentInfo);
        // Step 4: Update Firestore
        const db = admin.firestore();
        const appointmentRef = db.collection('appointments').doc(request.appointmentId);
        const updateData = {
            lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (chargeResult.success) {
            updateData.paymentStatus = 'paid';
            updateData.paymentRef = chargeResult.data.ref_payco;
            updateData.transactionId = chargeResult.data.transaction_id;
            updateData.paymentData = {
                amount: request.amount,
                currency: 'COP',
                method: 'card',
                processedAt: new Date().toISOString()
            };
        }
        else {
            updateData.paymentStatus = 'failed';
            updateData.paymentError = ((_c = chargeResult.error) === null || _c === void 0 ? void 0 : _c.message) || 'Payment failed';
        }
        await appointmentRef.update(updateData);
        // Step 5: Return response
        if (chargeResult.success) {
            functions.logger.info('Payment successful', {
                appointmentId: request.appointmentId,
                refPayco: chargeResult.data.ref_payco,
                transactionId: chargeResult.data.transaction_id
            });
            res.status(200).json({
                success: true,
                status: 'success',
                refPayco: chargeResult.data.ref_payco,
                transactionId: chargeResult.data.transaction_id,
                data: {
                    amount: request.amount,
                    currency: 'COP',
                    method: 'card',
                    processedAt: new Date().toISOString()
                }
            });
        }
        else {
            functions.logger.error('Payment failed', {
                appointmentId: request.appointmentId,
                error: chargeResult.error
            });
            res.status(200).json({
                success: false,
                status: 'failure',
                error: ((_d = chargeResult.error) === null || _d === void 0 ? void 0 : _d.message) || 'Payment failed',
                data: chargeResult.error
            });
        }
    }
    catch (error) {
        functions.logger.error('Error processing payment', error);
        // Try to update appointment with error status
        try {
            const db = admin.firestore();
            const appointmentRef = db.collection('appointments').doc(req.body.appointmentId);
            await appointmentRef.update({
                paymentStatus: 'failed',
                paymentError: error instanceof Error ? error.message : 'Unknown error',
                lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        catch (updateError) {
            functions.logger.error('Failed to update appointment with error status', updateError);
        }
        res.status(500).json({
            success: false,
            status: 'error',
            error: 'Internal server error. Please try again later.'
        });
    }
});
/**
 * Validate charge request body
 */
function validateChargeRequest(body) {
    if (!body) {
        return { isValid: false, error: 'Request body is required' };
    }
    const { appointmentId, customer, card, amount, description } = body;
    if (!appointmentId || typeof appointmentId !== 'string') {
        return { isValid: false, error: 'appointmentId is required and must be a string' };
    }
    if (!customer || typeof customer !== 'object') {
        return { isValid: false, error: 'customer is required and must be an object' };
    }
    const { name, last_name, email, doc_type, doc_number } = customer;
    if (!name || typeof name !== 'string') {
        return { isValid: false, error: 'customer.name is required and must be a string' };
    }
    if (!last_name || typeof last_name !== 'string') {
        return { isValid: false, error: 'customer.last_name is required and must be a string' };
    }
    if (!email || typeof email !== 'string') {
        return { isValid: false, error: 'customer.email is required and must be a string' };
    }
    if (!doc_type || typeof doc_type !== 'string') {
        return { isValid: false, error: 'customer.doc_type is required and must be a string' };
    }
    if (!doc_number || typeof doc_number !== 'string') {
        return { isValid: false, error: 'customer.doc_number is required and must be a string' };
    }
    if (!card || typeof card !== 'object') {
        return { isValid: false, error: 'card is required and must be an object' };
    }
    const { number, exp_month, exp_year, cvc } = card;
    if (!number || typeof number !== 'string') {
        return { isValid: false, error: 'card.number is required and must be a string' };
    }
    if (!exp_month || typeof exp_month !== 'string') {
        return { isValid: false, error: 'card.exp_month is required and must be a string' };
    }
    if (!exp_year || typeof exp_year !== 'string') {
        return { isValid: false, error: 'card.exp_year is required and must be a string' };
    }
    if (!cvc || typeof cvc !== 'string') {
        return { isValid: false, error: 'card.cvc is required and must be a string' };
    }
    if (!amount || typeof amount !== 'number' || amount <= 0) {
        return { isValid: false, error: 'amount is required and must be a positive number' };
    }
    if (!description || typeof description !== 'string') {
        return { isValid: false, error: 'description is required and must be a string' };
    }
    return { isValid: true };
}
/**
 * Firebase Function: ePayco Webhook Handler (Response)
 *
 * This endpoint handles the response from ePayco after payment processing.
 * It should be called by ePayco when the user completes or cancels the payment.
 *
 * Note: This is a placeholder implementation. In production, you should:
 * 1. Validate the webhook signature from ePayco
 * 2. Update the appointment payment status in Firestore
 * 3. Send confirmation emails if needed
 * 4. Handle failed payments appropriately
 */
exports.epaycoResponse = functions.runWith({
    secrets: [EPAYCO_PUBLIC_KEY, EPAYCO_PRIVATE_KEY, EPAYCO_CUSTOMER_ID, EPAYCO_P_KEY]
}).https.onRequest(async (req, res) => {
    var _a, _b, _c, _d;
    try {
        // ePayco puede enviar GET o POST → unificamos
        const params = Object.assign(Object.assign({}, req.query), req.body);
        functions.logger.info('ePayco response received', params);
        // Inferimos éxito con claves comunes (flexible para sandbox/producción)
        const refPayco = params.ref_payco || params.x_ref_payco || params.refPayco || '';
        const code = String((_b = (_a = params.x_cod_response) !== null && _a !== void 0 ? _a : params.code) !== null && _b !== void 0 ? _b : '').toLowerCase();
        const state = String((_d = (_c = params.x_response) !== null && _c !== void 0 ? _c : params.state) !== null && _d !== void 0 ? _d : '').toLowerCase();
        const ok = code === '1' ||
            state.includes('acept') || // Aceptada
            state.includes('aprob') || // Aprobada
            state === 'accepted' || state === 'approved' ||
            params.success === true || params.success === 'true';
        const deeplink = `vaq://payment/${ok ? 'success' : 'failure'}?` +
            new URLSearchParams({ refPayco: String(refPayco) }).toString();
        // Devolvemos HTML mínimo que rebota al esquema personalizado
        res.status(200).send(`<!DOCTYPE html>
  <html><head><meta charset="utf-8"><title>Redirigiendo…</title></head>
  <body>
  <script>
    (function(){
      try { window.location.href = '${deeplink}'; } catch(e) {}
    })();
  </script>
  <p>Regresando a la app…</p>
  </body></html>`);
    }
    catch (error) {
        functions.logger.error('Error processing ePayco response', error);
        res.status(500).send('Error');
    }
});
/**
 * Firebase Function: ePayco Webhook Handler (Confirmation)
 *
 * This endpoint handles the confirmation from ePayco.
 * It's called by ePayco to confirm the payment status.
 */
exports.epaycoConfirmation = functions.runWith({
    secrets: [EPAYCO_PUBLIC_KEY, EPAYCO_PRIVATE_KEY, EPAYCO_CUSTOMER_ID, EPAYCO_P_KEY]
}).https.onRequest(async (req, res) => {
    try {
        functions.logger.info('ePayco confirmation received', req.body);
        // TODO: Implement webhook signature validation
        // TODO: Update appointment payment status in Firestore
        // TODO: This should be the source of truth for payment status
        res.status(200).send('OK');
    }
    catch (error) {
        functions.logger.error('Error processing ePayco confirmation', error);
        res.status(500).send('Error');
    }
});
//# sourceMappingURL=index.js.map