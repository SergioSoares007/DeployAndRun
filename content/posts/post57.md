---
title: "Building a SAML 2.0 Service Provider with webMethods Integration Server"
date: 2026-09-20T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["SAML", "IDP", "SP"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Building a SAML 2.0 Service Provider with webMethods Integration Server"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link

---
# Building a SAML 2.0 Service Provider with webMethods Integration Server

SAML integration is often handled by dedicated identity products, but there are situations where an integration platform needs to act directly as a SAML Service Provider.

In this article, we'll build a working SAML 2.0 Service Provider using **webMethods Integration Server (IS)**, with **WSO2 Identity Server 7.3.0** acting as the Identity Provider.

The implementation covers the complete SP-initiated authentication flow, including:

* Generating a SAML `AuthnRequest`
* Redirecting the browser to the Identity Provider
* Receiving the SAML Response through an ACS endpoint
* Validating the XML signature
* Validating the SAML protocol and assertion
* Correlating the response with the original request
* Implementing basic replay protection
* Extracting a custom SAML attribute
* Redirecting the authenticated user to the target application

The implementation was built and tested using **webMethods Integration Server 10.15** and **WSO2 Identity Server 7.3.0**.

---

## 1. Architecture

The proof of concept uses the following SP-initiated flow:

```text
                 SAML 2.0
             SP-Initiated SSO

+---------+
|  App A  |
+----+----+
     |
     | Access protected application
     v
+----------------------------+
| webMethods Integration     |
| Server                     |
|                            |
| /startSaml                 |
+-------------+--------------+
              |
              | AuthnRequest
              | HTTP 302
              v
+----------------------------+
| WSO2 Identity Server       |
| Identity Provider          |
+-------------+--------------+
              |
              | Authentication
              |
              | SAMLResponse
              | HTTP POST
              v
+----------------------------+
| webMethods Integration     |
| Server                     |
|                            |
| /consumeResponse (ACS)     |
|                            |
| - Verify signature         |
| - Validate assertion       |
| - Validate request ID      |
| - Extract attributes       |
+-------------+--------------+
              |
              | HTTP 302
              v
+----------------------------+
| App B                      |
| Protected application      |
+----------------------------+
```

For the lab environment:

| Component          | Configuration                                 |
| ------------------ | --------------------------------------------- |
| Integration Server | webMethods IS 10.15                           |
| IS host            | `192.168.150.215`                             |
| IS HTTP port       | `5575`                                        |
| WSO2               | WSO2 Identity Server 7.3.0                    |
| SAML SP Entity ID  | `mycalie-lab`                                 |
| ACS                | `http://192.168.150.215:5575/consumeResponse` |
| Custom SAML claim  | `http://wso2.org/claims/trigram`              |

The webMethods implementation was placed in a package called:

```text
SAMLIntegration
```

---

# 2. Configure the Service Provider in WSO2

The first step is to tell the Identity Provider about our Service Provider.

In WSO2, create a SAML application for the Integration Server SP.

For the lab, the application was configured with:

```text
SP Entity ID / Issuer:
mycalie-lab

Assertion Consumer Service URL:
http://192.168.150.215:5575/consumeResponse
```

Enable the bindings required by the flow:

```text
HTTP-Redirect
HTTP-POST
```

The SP sends the authentication request using HTTP Redirect, while WSO2 sends the SAML Response to the ACS using HTTP POST.

SAML Response signing was also enabled.

The resulting relationship is:

```text
Integration Server                       WSO2
       SP                                 IdP

mycalie-lab
       |
       | AuthnRequest
       +------------------------------->
                                        Authenticate
                                            |
       <------------------------------------+
               SAMLResponse
```

---

# 3. Configure the Custom `trigram` Claim

Our application requires a business identifier called `trigram`.

A custom claim was configured in WSO2 using:

```text
http://wso2.org/claims/trigram
```

For the test user, the value was:

```text
SER
```

The resulting SAML Assertion contains an attribute similar to:

```xml
<saml2:Attribute
    Name="http://wso2.org/claims/trigram"
    NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">

    <saml2:AttributeValue
        xsi:type="xsd:string">SER</saml2:AttributeValue>

</saml2:Attribute>
```

We will extract this value later in Integration Server.

---

# 4. Trust the WSO2 Signing Certificate

A Service Provider must never accept a SAML Response simply because it contains a certificate.

The SP must independently trust the certificate used by the Identity Provider to sign the assertion or response.

WSO2 7.3.0 stores its certificate in:

```text
/opt/wso2/wso2is-7.3.0/repository/resources/security/wso2carbon.p12
```

Export the WSO2 signing certificate:

```bash
keytool -exportcert \
  -alias wso2carbon \
  -keystore /opt/wso2/wso2is-7.3.0/repository/resources/security/wso2carbon.p12 \
  -storetype PKCS12 \
  -rfc \
  -file /tmp/wso2-signing.crt
```

Import it into the Integration Server platform truststore:

```bash
keytool -importcert \
  -alias wso2-signing \
  -file /tmp/wso2-signing.crt \
  -keystore /opt/findmore/ibm_mft_bpm_11_1/common/conf/platform_truststore.jks
```

The resulting truststore contains the WSO2 certificate under:

```text
wso2-signing
```

The relevant IS truststore is:

```text
/opt/findmore/ibm_mft_bpm_11_1/common/conf/platform_truststore.jks
```

This is an important security boundary:

```text
SAMLResponse
     |
     | XML Signature
     v
Certificate supplied by WSO2
     |
     | must match/trust
     v
platform_truststore.jks
     |
     +-- wso2-signing
```

---

# 5. The `/startSaml` Service

The first Integration Server endpoint is:

```text
/startSaml
```

It represents the beginning of the SP-initiated authentication flow.

Its responsibility is to:

1. Generate a unique SAML request ID
2. Generate the current `IssueInstant`
3. Store the request ID
4. Build an `AuthnRequest`
5. Encode it according to the SAML HTTP-Redirect binding
6. Redirect the browser to WSO2

---

# 6. Generate a Unique Request ID

We created a Java Service called:

```text
generateSamlRequestData
```

It returns:

```text
requestId
issueInstant
```

The essential implementation is:

```java
IDataCursor c = pipeline.getCursor();

String requestId = "_" + java.util.UUID.randomUUID().toString();
String issueInstant = java.time.Instant.now().toString();

IDataUtil.put(c, "requestId", requestId);
IDataUtil.put(c, "issueInstant", issueInstant);

c.destroy();
```

A generated request might therefore have:

```text
requestId:
_c0b31216-...

issueInstant:
2026-09-13T15:42:18.123Z
```

Using a unique ID is critical because the SAML Response will later contain:

```xml
InResponseTo="_c0b31216-..."
```

That allows the SP to correlate a response with an authentication request it actually generated.

---

# 7. Build the AuthnRequest

The `/startSaml` flow builds an XML SAML AuthnRequest using the generated values.

Conceptually:

```xml
<samlp:AuthnRequest
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    ID="_GENERATED_UUID"
    Version="2.0"
    IssueInstant="CURRENT_UTC_TIME"
    Destination="https://ibm-dev-05:9443/samlsso"
    AssertionConsumerServiceURL="http://192.168.150.215:5575/consumeResponse">

    <saml:Issuer>mycalie-lab</saml:Issuer>

</samlp:AuthnRequest>
```

The important point is that neither `ID` nor `IssueInstant` is hard-coded.

---

# 8. Encode the AuthnRequest

For the SAML HTTP-Redirect binding, the AuthnRequest cannot simply be Base64-encoded.

The sequence is:

```text
AuthnRequest XML
       |
       v
Raw DEFLATE
       |
       v
Base64
       |
       v
URL Encode
       |
       v
SAMLRequest=<encoded value>
```

We implemented this in an IS Java Service:

```text
encodeSamlRequest
```

The resulting browser redirect targets WSO2:

```text
https://ibm-dev-05:9443/samlsso?SAMLRequest=<encoded-request>
```

The browser follows the HTTP `302`, and the user reaches the WSO2 login page.

---

# 9. Store the Outstanding SAML Request

Generating a unique ID isn't useful unless the SP remembers it.

We implemented a Java Service:

```text
samlRequestCache
```

with inputs:

```text
action
requestId
```

and output:

```text
validRequest
```

For the POC, the shared cache is:

```java
private static final
java.util.concurrent.ConcurrentHashMap<String, Long> SAML_REQUESTS =
    new java.util.concurrent.ConcurrentHashMap<String, Long>();
```

When `/startSaml` executes:

```text
action = STORE
```

the request is stored:

```java
SAML_REQUESTS.put(
    requestId,
    System.currentTimeMillis()
);
```

The `/startSaml` flow therefore looks roughly like:

```text
generateSamlRequestData
        |
        v
samlRequestCache
action = STORE
        |
        v
Build AuthnRequest
        |
        v
encodeSamlRequest
        |
        v
HTTP 302 → WSO2
```

---

# 10. Implement the Assertion Consumer Service

The second endpoint is:

```text
/consumeResponse
```

This is the **Assertion Consumer Service (ACS)**.

After successful authentication, WSO2 performs an HTTP POST to:

```text
http://192.168.150.215:5575/consumeResponse
```

containing:

```text
SAMLResponse
RelayState
```

The important field is `SAMLResponse`.

It is Base64-encoded.

The IS flow first performs:

```text
SAMLResponse
     |
     v
pub.string:base64Decode
     |
     v
pub.string:bytesToString
     |
     v
samlXml
```

The resulting `samlXml` is the actual SAML protocol response.

---

# 11. Validate the XML Signature

We implemented the validation logic in:

```text
validateSamlSignature
```

The Java XML Digital Signature API is used to locate and validate the `<ds:Signature>`.

The certificate is obtained from the trusted IS keystore rather than blindly trusting the certificate embedded in the SAML Response.

Conceptually:

```java
KeyStore ks = KeyStore.getInstance("JKS");

java.io.FileInputStream fis =
    new java.io.FileInputStream(
        "/opt/findmore/ibm_mft_bpm_11_1/common/conf/platform_truststore.jks"
    );

ks.load(fis, null);
fis.close();

X509Certificate cert =
    (X509Certificate) ks.getCertificate("wso2-signing");
```

The XML signature can then be validated using:

```java
DOMValidateContext ctx =
    new DOMValidateContext(
        cert.getPublicKey(),
        signatureElement
    );

XMLSignatureFactory factory =
    XMLSignatureFactory.getInstance("DOM");

XMLSignature signature =
    factory.unmarshalXMLSignature(ctx);

boolean valid = signature.validate(ctx);
```

Our test returned:

```text
valid = true
```

But signature verification alone is **not sufficient**.

A secure SAML consumer must also validate the semantics of the response.

---

# 12. Validate the SAML Status

First, ensure that the IdP actually returned a successful authentication response.

We check:

```xml
<saml2p:StatusCode
    Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
```

For example:

```java
NodeList statusCodes = doc.getElementsByTagNameNS(
    "urn:oasis:names:tc:SAML:2.0:protocol",
    "StatusCode"
);

if (statusCodes.getLength() == 0) {
    valid = false;
}

Element statusCode = (Element) statusCodes.item(0);

if (!"urn:oasis:names:tc:SAML:2.0:status:Success"
        .equals(statusCode.getAttribute("Value"))) {
    valid = false;
}
```

---

# 13. Validate the Issuer

The POC WSO2 instance emits:

```xml
<saml2:Issuer>localhost</saml2:Issuer>
```

The SP therefore validates:

```text
Issuer == localhost
```

For example:

```java
NodeList issuers = response.getElementsByTagNameNS(
    "urn:oasis:names:tc:SAML:2.0:assertion",
    "Issuer"
);

String issuer =
    issuers.item(0).getTextContent().trim();

if (!"localhost".equals(issuer)) {
    valid = false;
}
```

---

# 14. Validate the Destination

The response must have been issued for our ACS.

Expected value:

```text
http://192.168.150.215:5575/consumeResponse
```

Validation:

```java
String destination =
    response.getAttribute("Destination");

if (!"http://192.168.150.215:5575/consumeResponse"
        .equals(destination)) {
    valid = false;
}
```

This prevents a valid SAML Response intended for another endpoint from being accepted here.

---

# 15. Validate the Audience

The assertion also contains an `AudienceRestriction`.

For this SP:

```xml
<saml2:AudienceRestriction>
    <saml2:Audience>mycalie-lab</saml2:Audience>
</saml2:AudienceRestriction>
```

The SP checks:

```text
Audience == mycalie-lab
```

For example:

```java
NodeList audiences = doc.getElementsByTagNameNS(
    "urn:oasis:names:tc:SAML:2.0:assertion",
    "Audience"
);

String audience =
    audiences.item(0).getTextContent().trim();

if (!"mycalie-lab".equals(audience)) {
    valid = false;
}
```

---

# 16. Validate the Assertion Lifetime

A correctly signed SAML Assertion can still be invalid if it has expired.

The assertion contains:

```xml
<saml2:Conditions
    NotBefore="..."
    NotOnOrAfter="...">
```

We validate both timestamps.

A small clock skew is allowed to accommodate minor clock differences between the SP and IdP:

```java
java.time.Instant now =
    java.time.Instant.now();

java.time.Instant notBefore =
    java.time.Instant.parse(notBeforeStr);

java.time.Instant notOnOrAfter =
    java.time.Instant.parse(notOnOrAfterStr);

long clockSkewSeconds = 60;

if (now.plusSeconds(clockSkewSeconds)
       .isBefore(notBefore)) {
    valid = false;
}

if (!now.minusSeconds(clockSkewSeconds)
        .isBefore(notOnOrAfter)) {
    valid = false;
}
```

During testing, replaying an old assertion correctly resulted in:

```text
valid = false
```

while obtaining a fresh response restored:

```text
valid = true
```

---

# 17. Validate `SubjectConfirmationData`

The bearer assertion also contains:

```xml
<saml2:SubjectConfirmationData
    InResponseTo="_..."
    NotOnOrAfter="..."
    Recipient="http://192.168.150.215:5575/consumeResponse"/>
```

The SP validates:

### Recipient

```text
Recipient ==
http://192.168.150.215:5575/consumeResponse
```

### Expiry

`NotOnOrAfter` must still be valid.

### InResponseTo

The value is extracted for correlation:

```java
String inResponseTo =
    subjectConfirmationData.getAttribute("InResponseTo");

IDataUtil.put(
    c,
    "inResponseTo",
    inResponseTo
);
```

---

# 18. Correlate the Response with the Original Request

This is where the request cache created earlier becomes important.

The ACS calls:

```text
samlRequestCache
```

with:

```text
action = CONSUME
requestId = inResponseTo
```

The implementation removes the request from the map:

```java
Long createdAt =
    SAML_REQUESTS.remove(requestId);
```

and verifies that it exists and is recent:

```java
boolean validRequest = false;

if (createdAt != null) {

    long ageMillis =
        System.currentTimeMillis() - createdAt;

    validRequest =
        ageMillis >= 0 &&
        ageMillis <= 600000;
}
```

The 600,000 milliseconds represent a ten-minute request lifetime for the POC.

Notice the use of:

```java
remove()
```

rather than:

```java
get()
```

This is intentional.

Once a response has consumed the request ID, the same ID cannot be consumed again.

This provides basic replay protection.

The successful end-to-end test produced:

```text
valid = true
validRequest = true
```

---

# 19. Extract the SAML Attribute

Only after both conditions succeed:

```text
valid == true

AND

validRequest == true
```

does the flow process the application's identity attributes.

We created:

```text
extractSamlTrigram
```

which receives:

```text
samlXml
```

and returns:

```text
trigram
```

The service searches for:

```text
http://wso2.org/claims/trigram
```

For example:

```java
NodeList attributes = doc.getElementsByTagNameNS(
    "urn:oasis:names:tc:SAML:2.0:assertion",
    "Attribute"
);

String trigram = null;

for (int i = 0; i < attributes.getLength(); i++) {

    Element attribute =
        (Element) attributes.item(i);

    if ("http://wso2.org/claims/trigram"
            .equals(attribute.getAttribute("Name"))) {

        NodeList values =
            attribute.getElementsByTagNameNS(
                "urn:oasis:names:tc:SAML:2.0:assertion",
                "AttributeValue"
            );

        if (values.getLength() > 0) {
            trigram =
                values.item(0)
                      .getTextContent()
                      .trim();
        }

        break;
    }
}
```

Our test user produced:

```text
trigram = SER
```

---

# 20. The Complete ACS Flow

At this stage, `/consumeResponse` looks conceptually like this:

```text
SAMLResponse
     |
     v
base64Decode
     |
     v
bytesToString
     |
     +----> samlXml
              |
              v
      validateSamlSignature
              |
              +----> valid
              |
              +----> inResponseTo
                         |
                         v
                samlRequestCache
                action=CONSUME
                         |
                         +----> validRequest
                                  |
                     +------------+------------+
                     |                         |
               validation OK             validation failed
                     |
                     v
             extractSamlTrigram
                     |
                     +----> trigram
```

The critical condition is:

```text
valid == true
&&
validRequest == true
```

Only then is the identity trusted.

---

# 21. Redirect to the Protected Application

For the proof of concept we created a simple application page under the Integration Server package:

```text
SAMLIntegration/
└── pub/
    └── app-b-mycalie-lab.html
```

It is therefore served directly by Integration Server.

After successful validation, `/consumeResponse` returns:

```text
HTTP 302
```

with:

```text
Location:
http://ibm-dev-01:5575/SAMLIntegration/app-b-mycalie-lab.html?trigram=%trigram%
```

The complete browser flow becomes:

```text
App A
  |
  v
/startSaml
  |
  | HTTP 302
  v
WSO2
  |
  | login
  |
  | HTTP POST SAMLResponse
  v
/consumeResponse
  |
  | validate SAML
  | validate request correlation
  | extract trigram
  |
  | HTTP 302
  v
App B

SSO completed successfully
Trigram: SER
```

And that was the final end-to-end result of the POC.

---

# 22. Integration Server Services

The resulting `SAMLIntegration` package contains the following main services:

| Service                   | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `/startSaml`              | Entry point for SP-initiated authentication      |
| `generateSamlRequestData` | Generates request ID and IssueInstant            |
| `samlRequestCache`        | Stores and consumes outstanding SAML request IDs |
| `encodeSamlRequest`       | Implements Redirect-binding encoding             |
| `/consumeResponse`        | Assertion Consumer Service                       |
| `validateSamlSignature`   | Validates the SAML Response and Assertion        |
| `extractSamlTrigram`      | Extracts the application's custom SAML claim     |

The two HTTP-facing services represent the core SP interface:

```text
/startSaml
    SP authentication entry point

/consumeResponse
    SAML Assertion Consumer Service (ACS)
```

---

# 23. Security Checks Implemented

An important lesson from this implementation is that **"the XML signature is valid" does not mean "the SAML Response is valid"**.

Our SP checks all of the following:

```text
✓ XML signature
✓ Trusted IdP certificate
✓ SAML Status = Success
✓ Expected Issuer
✓ Expected Destination
✓ Expected Audience
✓ Assertion NotBefore
✓ Assertion NotOnOrAfter
✓ SubjectConfirmation Recipient
✓ SubjectConfirmation NotOnOrAfter
✓ InResponseTo
✓ Outstanding request exists
✓ Request has not expired
✓ Request has not already been consumed
```

Only after these checks does the application trust attributes such as:

```text
trigram = SER
```

---

# 24. What Should Change for Production?

The implementation described here is a **proof of concept**, not a production-ready SAML stack.

There are several areas that should be hardened before using the same approach in production.

### Protect the XML parser

The XML parser should explicitly disable DTD processing and external entities to protect against XXE attacks.

### Harden XML Signature processing

Signature validation should enforce exactly which SAML element is signed and ensure the signature reference corresponds to the Response or Assertion being processed.

This is important to defend against XML Signature Wrapping attacks.

### Replace the in-memory request cache

This:

```java
ConcurrentHashMap<String, Long>
```

works well for demonstrating request correlation on a single Integration Server instance.

It is not appropriate for a clustered production environment.

A production implementation should use a shared store with expiration semantics.

### Use HTTPS everywhere

The lab ACS uses:

```text
http://192.168.150.215:5575/consumeResponse
```

A production ACS must be exposed over HTTPS.

### Don't expose identity attributes in query parameters

This was useful for the POC:

```text
?trigram=SER
```

but it is not how application identity context should normally be transferred.

A production solution should establish a server-side session or issue a short-lived, integrity-protected token/reference.

### Implement explicit error paths

The Flow should have separate handling for:

```text
invalid signature
invalid issuer
invalid audience
expired assertion
unknown InResponseTo
replayed response
missing required attributes
```

rather than simply continuing or returning a generic error.

---

# 25. Final Result

We successfully turned webMethods Integration Server into a basic SAML 2.0 Service Provider.

The complete tested flow was:

```text
Application
     |
     v
webMethods Integration Server
     |
     | SAML AuthnRequest
     v
WSO2 Identity Server
     |
     | Authentication
     |
     | Signed SAMLResponse
     v
webMethods Integration Server
     |
     | Signature validation
     | Protocol validation
     | Assertion validation
     | Request correlation
     | Replay protection
     | Attribute extraction
     |
     | trigram = SER
     v
Protected Application
```

The interesting part of the exercise wasn't generating or decoding SAML XML. The important part was implementing the **trust boundary** correctly.

A SAML Service Provider must be able to answer several questions before trusting an identity:

> Who issued this assertion?
> Was it modified?
> Was it issued for me?
> Is it still valid?
> Did I actually request it?
> Has it already been used?

Once Integration Server could answer all of those questions, extracting `trigram=SER` was the easy part.

That is the difference between simply **parsing a SAML Response** and actually behaving as a **SAML Service Provider**.
