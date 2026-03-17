# SunX Authentication

All private API endpoints require signed requests using either Ed25519 or HmacSHA256.

## Base URLs

| Environment | URL |
|-------------|-----|
| Production | https://api.sunx.io |

## Overview

The API request may be tampered during internet transmission, therefore all private API must be signed by your API Key (Secret Key).

Each API Key has permission properties. Please check the API permission and make sure your API key has proper permission.

## Required Parameters for All Authenticated Requests

A valid request consists of the following parts:

* **API Path**: The endpoint path (e.g., `/sapi/v1/trade/order`)
* **AccessKeyId**: The 'Access Key' in your API Key
* **SignatureMethod**: Ed25519 or HmacSHA256
* **SignatureVersion**: 2 (fixed value)
* **Timestamp**: UTC time when the request is sent (format: YYYY-MM-DDThh:mm:ss), valid within 5 minutes
* **Parameters**: Each API method has a group of parameters
  - For GET requests: all parameters must be signed
  - For POST requests: parameters needn't be signed and should be put in request body
* **Signature**: The calculated signature value to guarantee the request is valid and not tampered

## Signature Methods

### Method 1: Ed25519 Signature

Ed25519 is a high-performance digital signature algorithm that provides fast signature verification and generation while having high security.

#### Signing Process

The signature may be different if the request text is different, therefore the request should be normalized before signing. Below signing steps take the order query as an example:

Full URL example:
```
https://api.sunx.io/sapi/v1/trade/order?AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&SignatureMethod=Ed25519&SignatureVersion=2&Timestamp=2017-05-11T15:19:30&order_id=1234567890
```

#### Step 1: Build Request Method
The request Method (GET or POST, WebSocket use GET), append line break "\n"
```
GET\n
```

#### Step 2: Add Host
The host with lower case, append line break "\n"
```
api.sunx.io\n
```

#### Step 3: Add API Path
The path, append line break "\n"

For REST API example:
```
/sapi/v1/trade/order\n
```

For WebSocket v1 example:
```
/ws/v1
```

#### Step 4: Prepare and Order Parameters

Original parameters:
```
AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx
order_id=1234567890
SignatureMethod=Ed25519
SignatureVersion=2
Timestamp=2017-05-11T15:19:30
```

**Important encoding rules:**
* Use UTF-8 encoding and URL encoding
* Hex characters must be uppercase
* Colon ':' should be encoded as '%3A'
* Space should be encoded as '%20'
* Timestamp format: YYYY-MM-DDThh:mm:ss (then URL encoded)
* The value is valid within 5 minutes

After URL encoding and ASCII sorting:
```
AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx
SignatureMethod=Ed25519
SignatureVersion=2
Timestamp=2017-05-11T15%3A19%3A30
order_id=1234567890
```

#### Step 5: Concatenate Parameters
Use "&" to join all sorted parameters:
```
AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&SignatureMethod=Ed25519&SignatureVersion=2&Timestamp=2017-05-11T15%3A19%3A30&order_id=1234567890
```

#### Step 6: Assemble Pre-Sign Text
Combine all parts with "\n":
```
GET\n
api.sunx.io\n
/sapi/v1/trade/order\n
AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&SignatureMethod=Ed25519&SignatureVersion=2&Timestamp=2017-05-11T15%3A19%3A30&order_id=1234567890
```

#### Step 7: Generate Signature

1. Use the request string obtained in the previous step to generate the signature with the Ed25519 private key
2. Encode the generated signature with Base64, and the resulting value is used as the digital signature

Result example:
```
4F65x5A2bLyMWVQj3Aqp+B4w+ivaA7n5Oi2SuYtCJ9o=
```

#### Step 8: Send the Request

**For REST API:**
1. Put all the parameters in the URL
2. URL encode the signature and append it with parameter name "Signature"

Final URL:
```
https://api.sunx.io/sapi/v1/trade/order?AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&order_id=1234567890&SignatureMethod=Ed25519&SignatureVersion=2&Timestamp=2017-05-11T15%3A19%3A30&Signature=4F65x5A2bLyMWVQj3Aqp%2BB4w%2BivaA7n5Oi2SuYtCJ9o%3D
```

**For WebSocket Interface:**
1. Fill the value according to required JSON schema
2. The value in JSON doesn't require URL encode

Private channel subscription example:
```json
{
  "SignatureVersion": "2",
  "op": "auth",
  "AccessKeyId": "e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx",
  "Signature": "4F65x5A2bLyMWVQj3Aqp+B4w+ivaA7n5Oi2SuYtCJ9o=",
  "SignatureMethod": "Ed25519",
  "type": "api",
  "Timestamp": "2025-09-27T11:14:48"
}
```

### Method 2: HmacSHA256 Signature

The signing process is identical to Ed25519, with these differences:

1. Use `SignatureMethod=HmacSHA256` instead of `Ed25519`
2. For WebSocket v2, use path `/ws/v2`
3. Use HmacSHA256 hash function with your API Secret Key to generate hash code
4. Encode the hash code with Base64 to generate the signature

#### Signing Process

Full URL example:
```
https://api.sunx.io/sapi/v1/trade/order?AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2017-05-11T15:19:30&order_id=1234567890
```

Follow steps 1-6 from the Ed25519 method, but use `SignatureMethod=HmacSHA256` in the parameters.

#### Step 7: Generate Signature (HmacSHA256)

1. Use the pre-signed text in step 6 and your API Secret Key to generate hash code by HmacSHA256 hash function
2. Encode the hash code with Base64 to generate the signature

Result example:
```
4F65x5A2bLyMWVQj3Aqp+B4w+ivaA7n5Oi2SuYtCJ9o=
```

#### Step 8: Send the Request

**For REST API:**
Same as Ed25519 method - put all parameters in URL with URL-encoded signature.

Final URL:
```
https://api.sunx.io/sapi/v1/trade/order?AccessKeyId=e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx&order_id=1234567890&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2017-05-11T15%3A19%3A30&Signature=4F65x5A2bLyMWVQj3Aqp%2BB4w%2BivaA7n5Oi2SuYtCJ9o%3D
```

**For WebSocket Interface:**
Private channel subscription example:
```json
{
  "SignatureVersion": "2",
  "op": "auth",
  "AccessKeyId": "e2xxxxxx-99xxxxxx-84xxxxxx-7xxxx",
  "Signature": "4F65x5A2bLyMWVQj3Aqp+B4w+ivaA7n5Oi2SuYtCJ9o=",
  "SignatureMethod": "HmacSHA256",
  "type": "api",
  "Timestamp": "2025-09-27T11:14:48"
}
```

## Parameter Notes for GET vs POST

### GET Requests:
* All parameters (including business parameters) are included in the signature
* All parameters go in the URL query string

### POST Requests:
* Only signature-related parameters (AccessKeyId, SignatureMethod, SignatureVersion, Timestamp) are signed
* Signature-related parameters go in URL query string
* Business parameters go in request body as JSON
* Business parameters are NOT included in the signature calculation

This is an important distinction - pay special attention when implementing POST requests.

## Security Notes

* **Never share your Secret Key** - Keep it secure at all times
* **Use IP whitelist** in SunX API settings for additional security
* **Enable only required permissions** (e.g., Read and Trade, avoid Withdraw unless needed)
* **Rotate keys periodically** - Update API keys regularly
* **Monitor API usage** - Check for unauthorized access
* **Timestamp validity** - Requests are valid for 5 minutes to prevent replay attacks
* **Use HTTPS only** - All requests must use secure HTTPS protocol

## Common Errors

### Timestamp Outside Valid Window

If you receive this error:

1. Check server time
2. Ensure your system clock is synchronized with UTC
3. Verify timestamp format is correct: YYYY-MM-DDThh:mm:ss
4. Timestamp must be within 5 minutes of server time

### Invalid Signature

If signature validation fails:

1. Verify all parameters are sorted in ASCII order
2. Check URL encoding is correct (uppercase hex)
3. Ensure line breaks in pre-sign text are "\n" (not "\r\n")
4. Verify Secret Key is correct
5. Check that business parameters for POST are in body, not in signature
