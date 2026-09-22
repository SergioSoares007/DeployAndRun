---
title: "Cryptography Basics for Developers: Encoding, Hashing, Encryption and Digital Signatures"
date: 2026-09-13T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Encoding", "Hashing", "Encryption","Digital signatures","Hybrid cryptography"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Cryptography Basics for Developers: Encoding, Hashing, Encryption and Digital Signatures"
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
# Cryptography Basics for Developers: Encoding, Hashing, Encryption and Digital Signatures

Cryptography has a reputation for being complicated. The mathematics certainly can be, but the fundamental concepts that developers and solution architects need every day are surprisingly approachable.

The real difficulty is often understanding **which tool solves which problem**.

Base64 is not encryption.
URL encoding is not encryption either.
Hashing is not reversible.
Encryption provides confidentiality but not necessarily authenticity.
Digital signatures do not encrypt your data.
And asymmetric encryption is normally not how we encrypt large amounts of data.

This article builds these concepts progressively using practical Linux and OpenSSL examples.

We'll cover:

1. URL Encoding
2. Base64 Encoding
3. Cryptographic Hashing
4. Symmetric Encryption
5. Asymmetric Encryption
6. Hybrid Encryption
7. Digital Signing and Verification

By the end, we'll be able to put all the pieces together and understand technologies such as TLS, certificates, JWT/JWS and SAML signatures much more easily.

---

# 1. Before Cryptography: Encoding Is Not Encryption

Before touching cryptography, we need to eliminate one of the most common sources of confusion:

> **Encoding and encryption solve completely different problems.**

Consider these transformations:

```text
Hello World

URL encoded:
Hello%20World

Base64:
SGVsbG8gV29ybGQ=
```

Neither protects the information.

Anyone can reverse them.

Encryption is different:

```text
Plaintext
    |
    | encryption + key
    v
Ciphertext
```

Without the appropriate key, recovering the plaintext should be computationally infeasible.

A useful mental model is:

| Operation             | Purpose                       |            Reversible? |    Secret required? |
| --------------------- | ----------------------------- | ---------------------: | ------------------: |
| URL Encoding          | Safe URL representation       |                    Yes |                  No |
| Base64                | Binary-to-text representation |                    Yes |                  No |
| Hashing               | Fingerprint/integrity         |                     No |                  No |
| Symmetric encryption  | Confidentiality               |                    Yes |                 Yes |
| Asymmetric encryption | Confidentiality/key exchange  |                    Yes |         Private key |
| Digital signature     | Integrity + authenticity      | Verified, not reversed | Private key to sign |

Let's start with the simplest transformations.

---

# 2. URL Encoding

URLs have a defined syntax, and not every character can safely appear everywhere in a URL.

Suppose we want to send:

```text
http://sergio?user=test name
```

The space causes a problem.

URL encoding — more precisely **percent-encoding** — represents special characters using their byte values.

For example:

```text
space → %20
?     → %3F
:     → %3A
```

Depending on whether we're encoding a URL component or form data, spaces may also appear as `+`.

On Linux, one utility we can use is `urlencode`.

## Getting help

```bash
urlencode
```

## Encoding

```bash
urlencode -m "http://sergio?user=test name"
```

The result will contain the encoded representation of characters that require escaping.

## Decoding

For example:

```bash
urlencode -d 'http%3A//sergio%3Fuser=test+name'
```

### Why does this matter?

You'll encounter URL encoding constantly in:

* query parameters
* REST APIs
* OAuth 2.0
* OpenID Connect
* SAML HTTP-Redirect binding
* browser redirects

For example, a SAML authentication request might eventually travel as:

```text
https://idp.example.com/sso?SAMLRequest=<URL-ENCODED-DATA>
```

The important lesson is:

> URL encoding changes representation so data can safely travel inside a URL. It provides **zero confidentiality**.

---

# 3. Base64 Encoding

Base64 solves another representation problem.

Computers frequently need to transport binary data through systems designed primarily for text.

Base64 converts arbitrary bytes into printable ASCII characters.

Conceptually:

```text
Binary data
    |
    | Base64 encode
    v
Text representation
```

And:

```text
Base64 text
    |
    | Base64 decode
    v
Original binary data
```

Again:

> **Base64 is not encryption.**

There is no key.

Anyone receiving the Base64 string can decode it.

---

## Encoding Text

```bash
echo -n "This is a line" | base64
```

Result:

```text
VGhpcyBpcyBhIGxpbmU=
```

Decode it:

```bash
echo -n 'VGhpcyBpcyBhIGxpbmU=' | base64 -d
```

Result:

```text
This is a line
```

---

# 4. Beware of End-of-Line Characters

One small detail causes a surprising number of problems.

Compare:

```bash
echo "This is a line" | base64
```

with:

```bash
echo -n "This is a line" | base64
```

`echo` normally appends a newline.

The `-n` prevents it.

Cryptographic and encoding functions operate on **bytes**, so:

```text
"This is a line"
```

and:

```text
"This is a line\n"
```

are different inputs.

This becomes particularly important when comparing hashes and signatures.

---

# 5. Base64 Encoding Binary Files

Base64 works just as well with binary data.

For example:

```bash
base64 dataimage.png > dataimage-base64.txt
```

Now the PNG image is represented entirely as text.

We can restore it:

```bash
base64 -d dataimage-base64.txt > dataimage-decoded.png
```

The reconstructed image should contain exactly the same bytes as the original.

This capability explains why Base64 appears everywhere:

* email attachments
* JSON APIs
* certificates
* JWTs
* SAML
* MIME
* Kubernetes Secrets
* PEM files

It is simply a convenient way of representing binary data as text.

---

# 6. Base64 Increases the Data Size

Base64 is not compression.

In fact, it normally makes the data larger.

Every 3 bytes of input become 4 Base64 characters, giving roughly:

```text
~33% size increase
```

So don't Base64-encode a file because you want to make it smaller.

Do it because you need a **text-safe representation of binary data**.

---

# 7. Cryptographic Hashing

Now we enter actual cryptography.

A cryptographic hash function takes arbitrary input and produces a fixed-size output called a **hash** or **digest**.

```text
Input
  |
  | SHA-256
  v
Digest
```

The same input should always generate the same digest:

```text
Data A → SHA-256 → X
Data A → SHA-256 → X
```

Change even one bit:

```text
Data B → SHA-256 → Y
```

and the digest should change dramatically.

---

# 8. Hashing Is One-Way

Encryption is designed to be reversed with a key.

Hashing isn't.

There is no operation like:

```text
unhash(hash)
```

that reconstructs the original input.

A cryptographic hash is therefore a **one-way function**.

This makes hashes extremely useful for things such as:

* integrity checking
* file verification
* password verification
* digital signatures
* content identification
* certificate fingerprints

---

# 9. Hashing Files with OpenSSL

OpenSSL provides the `dgst` command.

Help:

```bash
openssl dgst -help
```

Calculate a digest:

```bash
openssl dgst dataimage.png
```

Explicitly use SHA-512:

```bash
openssl dgst -sha512 dataimage.png
```

We can request the raw binary digest:

```bash
openssl dgst -sha512 -binary dataimage.png
```

or save it:

```bash
openssl dgst \
  -sha512 \
  -binary \
  -out dataimage-dgst \
  dataimage.png
```

---

# 10. Hashing Text

Again, beware of newlines:

```bash
echo -n "xxx" | openssl dgst -sha512
```

Run the command repeatedly.

The digest will always be identical.

Change:

```text
xxx
```

to:

```text
xxy
```

and you'll obtain a completely different digest.

This is one of the fundamental properties we want from cryptographic hash functions.

---

# 11. Using Hashes to Verify Downloads

Suppose I publish a file:

```text
application.tar.gz
```

and tell you its SHA-256 digest is:

```text
8e6c...etc
```

After downloading the file, you calculate:

```bash
openssl dgst -sha256 application.tar.gz
```

If your digest matches mine, you have strong evidence that the bytes you received are the same bytes whose digest was published.

But there is an important caveat:

> A hash proves integrity only relative to a hash value you already trust.

If an attacker can modify both the file **and the hash published beside it**, simply comparing hashes achieves very little.

This distinction leads us later to **digital signatures**.

---

# 12. Passwords and Hashing

Passwords should not normally be stored in plaintext.

A naïve implementation might store:

```text
password → hash(password)
```

When the user logs in:

```text
entered password
       |
       v
     hash()
       |
       v
compare with stored hash
```

The server doesn't need to recover the password.

However, simply applying a fast general-purpose hash such as SHA-256 to passwords is **not sufficient**.

Why?

Attackers can calculate enormous numbers of candidate hashes and compare them with stolen password hashes.

Common passwords are particularly vulnerable.

---

# 13. Salted Password Hashes

A **salt** is random data combined with a password before deriving the stored password representation.

Conceptually:

```text
password + unique salt
          |
          v
 password hashing/KDF
          |
          v
     stored result
```

This makes precomputed lookup attacks substantially less useful and ensures that two users with the same password don't simply have identical stored values.

OpenSSL can demonstrate salted password hashing:

```bash
openssl passwd -6
```

Here `-6` selects the SHA-512-based Unix `crypt` password scheme.

You can explicitly provide a salt:

```bash
openssl passwd -6 -salt ThisIsASalt password
```

For real application password storage, however, prefer a dedicated, deliberately expensive password-hashing/KDF algorithm such as:

* Argon2id
* scrypt
* bcrypt
* PBKDF2 where appropriate

rather than a plain SHA-256 or SHA-512 digest.

The key distinction is:

> Fast hashing is desirable for many cryptographic operations. Password hashing should deliberately be expensive.

---

# 14. Symmetric Encryption

Now suppose we don't merely want to detect modifications.

We want to prevent someone from reading the data.

That's encryption.

The simplest model is **symmetric encryption**.

```text
                Secret Key
                    |
                    v
Plaintext ------> Encrypt ------> Ciphertext


                Secret Key
                    |
                    v
Ciphertext -----> Decrypt ------> Plaintext
```

The **same secret key** is available to both sides.

AES is the best-known modern symmetric cipher.

---

# 15. Why Symmetric Encryption Is Useful

Symmetric encryption is:

* fast
* efficient
* suitable for large amounts of data

It can encrypt:

```text
10 bytes
10 MB
10 GB
```

without the fundamental message-size restriction associated with direct RSA encryption.

The difficult part is not AES itself.

The difficult part is:

> **How do Alice and Bob securely share the secret key?**

If Alice sends Bob the encryption key over an insecure network, an attacker can simply steal the key.

This is the classic **key distribution problem**.

We'll solve that shortly.

---

# 16. Symmetric Encryption with OpenSSL

OpenSSL's `enc` command demonstrates symmetric encryption.

Help:

```bash
openssl enc -help
```

List supported ciphers:

```bash
openssl enc -list
```

For example:

```bash
echo -n "this is junk" |
openssl enc \
  -aes-256-cbc \
  -k secret \
  -md sha256 \
  -pbkdf2
```

The password isn't directly used as the AES key.

PBKDF2 derives keying material from the password.

We can Base64-encode the ciphertext for convenient textual transport:

```bash
echo -n "this is junk" |
openssl enc \
  -aes-256-cbc \
  -k secret \
  -md sha256 \
  -pbkdf2 \
  -base64
```

---

# 17. Encrypting a File

Encrypt:

```bash
openssl enc \
  -aes-256-cbc \
  -k secret \
  -md sha256 \
  -pbkdf2 \
  -base64 \
  -in dataimage.png \
  -out dataimage-enc
```

Decrypt:

```bash
openssl enc \
  -d \
  -aes-256-cbc \
  -k secret \
  -md sha256 \
  -pbkdf2 \
  -base64 \
  -in dataimage-enc \
  -out dataimage-original.png
```

We can verify that the original and decrypted files are identical:

```bash
openssl dgst -sha256 dataimage.png
openssl dgst -sha256 dataimage-original.png
```

The digests should match.

---

# 18. Encryption Does Not Automatically Mean Integrity

This distinction is extremely important.

Encryption answers:

> Can an unauthorised party read the message?

Integrity answers:

> Has somebody modified the message?

Authentication answers:

> Who created/sent this message?

These are different security properties.

Some modern encryption modes provide **authenticated encryption**, giving confidentiality and integrity together.

AES-GCM is a widely used example.

For new application designs, authenticated encryption such as **AES-GCM** or **ChaCha20-Poly1305** is generally preferable to constructing your own AES-CBC-plus-integrity scheme.

---

# 19. Asymmetric Encryption

Symmetric encryption has one obvious difficulty:

```text
How do Alice and Bob exchange the secret?
```

Public-key cryptography introduces another model.

Instead of one shared key, Bob has a **key pair**:

```text
Bob

Private Key  ← SECRET
Public Key   ← CAN BE DISTRIBUTED
```

These keys are mathematically related.

For RSA encryption, the simplified model is:

```text
Alice
  |
  | Bob's Public Key
  v
Encrypt
  |
  v
Ciphertext
  |
  | send
  v
Bob
  |
  | Bob's Private Key
  v
Decrypt
  |
  v
Plaintext
```

Alice does **not** need Bob's private key.

She only needs his public key.

---

# 20. Generate RSA Keys with OpenSSL

Create private keys for Alice and Bob:

```bash
openssl genrsa -out alice-private.pem 2048
openssl genrsa -out bob-private.pem 2048
```

A private key can itself be protected with encryption:

```bash
openssl genrsa \
  -aes256 \
  -out private_enc.pem \
  2048
```

OpenSSL will ask for a passphrase.

---

# 21. Extract the Public Keys

Alice:

```bash
openssl rsa \
  -in alice-private.pem \
  -pubout \
  -out alice-public.pem
```

Bob:

```bash
openssl rsa \
  -in bob-private.pem \
  -pubout \
  -out bob-public.pem
```

Now we have:

```text
alice-private.pem    KEEP SECRET
alice-public.pem     DISTRIBUTE

bob-private.pem      KEEP SECRET
bob-public.pem       DISTRIBUTE
```

---

# 22. RSA Encryption

Suppose Alice wants to send this message to Bob:

```bash
echo "Run for your life Now!" > important.txt
```

Alice encrypts it using **Bob's public key**:

```bash
openssl pkeyutl \
  -encrypt \
  -pubin \
  -inkey bob-public.pem \
  -in important.txt \
  -out important.enc
```

Bob decrypts it using **Bob's private key**:

```bash
openssl pkeyutl \
  -decrypt \
  -inkey bob-private.pem \
  -in important.enc
```

This demonstrates one of the central rules of public-key encryption:

```text
Encrypt with recipient's PUBLIC key
Decrypt with recipient's PRIVATE key
```

---

# 23. The RSA Message Size Problem

Why don't we just use RSA to encrypt a 5 GB file?

Because RSA is not designed for that.

The input to an RSA encryption operation must fit within the RSA modulus and padding scheme.

With a 2048-bit RSA key, the modulus is:

```text
2048 bits = 256 bytes
```

But you **cannot encrypt a full 256-byte message** because secure RSA encryption requires padding.

For example, with RSA-OAEP the maximum plaintext is smaller still and depends on the selected hash function.

So the useful rule is:

> RSA encrypts small pieces of data, not arbitrary large files.

This isn't really a disadvantage once we understand how modern cryptosystems are designed.

Because we can combine RSA and AES.

And that's where things get interesting.

---

# 24. Hybrid Encryption

Hybrid encryption combines the strengths of symmetric and asymmetric cryptography.

Typically:

```text
AES → encrypt the actual data
RSA/public-key mechanism → protect or establish the AES key
```

Why?

Because:

```text
AES
+ extremely fast
+ handles huge amounts of data
- requires a shared secret
```

while:

```text
RSA/public-key crypto
+ solves key-distribution problems
- expensive
- unsuitable for bulk data
```

Combine them:

```text
                HYBRID ENCRYPTION

Large message
     |
     | AES + random symmetric key
     v
Encrypted message
     
Symmetric key
     |
     | Bob's public key
     v
Encrypted symmetric key
```

Alice sends Bob:

```text
1. Encrypted data
2. Encrypted symmetric key
```

---

# 25. Hybrid Encryption Step by Step

Alice wants to send Bob a large image.

First generate random secret material.

For a simple command-line demonstration:

```bash
openssl rand -out passphrase.key 245
```

Alice encrypts the large file symmetrically:

```bash
openssl enc \
  -aes-256-cbc \
  -kfile passphrase.key \
  -md sha256 \
  -base64 \
  -pbkdf2 \
  -in dataimage.png \
  -out dataimage-aes
```

Then she encrypts the small passphrase/key file using Bob's public RSA key:

```bash
openssl pkeyutl \
  -encrypt \
  -pubin \
  -inkey bob-public.pem \
  -in passphrase.key \
  -out passphrase_enc.key
```

Alice sends:

```text
dataimage-aes
passphrase_enc.key
```

Notice that Bob's RSA public key was **not used to encrypt the image**.

It only protected the small secret required to decrypt the image.

---

# 26. Bob Decrypts the Hybrid Message

Bob receives:

```text
dataimage-aes
passphrase_enc.key
```

First he recovers the secret using his private key:

```bash
openssl pkeyutl \
  -decrypt \
  -inkey bob-private.pem \
  -in passphrase_enc.key \
  -out passphrase.key
```

Then he decrypts the large file:

```bash
openssl enc \
  -d \
  -aes-256-cbc \
  -kfile passphrase.key \
  -md sha256 \
  -base64 \
  -pbkdf2 \
  -in dataimage-aes \
  -out dataimage_original.png
```

The complete process is:

```text
ALICE                                      BOB

Random secret
     |
     +------ AES encrypt data ------+
     |                              |
     |                              v
     |                        Encrypted Data ----------------+
     |                                                      |
     |                                                      v
     |                                                  AES decrypt
     |                                                      ^
     |                                                      |
     +-- Bob Public Key --> RSA encrypt                     |
                              |                              |
                              v                              |
                      Encrypted Secret ----------------------+
                              |
                              | Bob Private Key
                              v
                         RSA decrypt
                              |
                              v
                       Original Secret
```

This idea is fundamental to modern cryptography.

Real protocols use more sophisticated constructions, but the principle remains:

> **Use asymmetric cryptography to establish/protect keying material and symmetric cryptography to protect bulk data.**

TLS is a major real-world example of hybrid cryptography, although modern TLS commonly uses ephemeral Diffie-Hellman key agreement rather than RSA encryption to establish session keys.

---

# 27. Public Keys and Certificates

There is still a major problem.

Alice has:

```text
bob-public.pem
```

But how does Alice know it actually belongs to Bob?

An attacker could say:

```text
"Hello Alice. I'm Bob. Here's my public key."
```

Alice needs a way to associate an identity with a public key.

This is where **digital certificates and Public Key Infrastructure (PKI)** enter the picture.

A certificate contains, among other things:

```text
Identity information
Public key
Issuer information
Validity period
Digital signature
```

A trusted Certificate Authority signs the certificate.

Conceptually:

```text
             Certificate Authority
                     |
                     | signs
                     v
            +------------------+
            | Bob's identity   |
            | Bob's public key |
            | Validity         |
            +------------------+
                     |
                     v
                Certificate
```

Alice doesn't blindly trust the certificate.

She validates its certification path against CAs she trusts.

This is the foundation of HTTPS certificates and much of enterprise PKI.

---

# 28. Creating a Self-Signed Certificate

For laboratory purposes:

```bash
openssl req \
  -x509 \
  -nodes \
  -sha256 \
  -days 3650 \
  -newkey rsa:2048 \
  -keyout private.key \
  -out certificate.crt
```

Important options:

```text
-x509
    Produce an X.509 certificate.

-newkey rsa:2048
    Generate a new 2048-bit RSA key.

-sha256
    Use SHA-256 as the certificate signature digest.

-days 3650
    Certificate validity.

-nodes
    Do not encrypt the generated private key.
```

`-nodes` is convenient for labs and unattended services, but it also means anyone obtaining the private key file can use it directly. File-system protection therefore becomes critical.

A self-signed certificate is useful for testing, but it isn't automatically trusted by another organisation.

---

# 29. Digital Signatures

So far we've solved confidentiality.

But suppose Alice sends Bob a document and Bob wants to answer:

> Did Alice really produce this?

and:

> Has the document changed since Alice signed it?

That's what **digital signatures** address.

The simplified process is:

```text
ALICE

Message
   |
   | Hash
   v
Digest
   |
   | Sign using Alice's PRIVATE key
   v
Signature
```

Alice sends:

```text
Message
+
Signature
```

Notice:

> The message does not have to be encrypted.

Signing and encryption solve different problems.

---

# 30. Signature Verification

Bob receives the message and signature.

Conceptually:

```text
                  RECEIVED MESSAGE
                        |
                        | hash
                        v
                    Digest A


RECEIVED SIGNATURE
        |
        | verify using
        | Alice's PUBLIC key
        v
   Signature verification
        |
        +------ compare against message digest
                        |
                        v
                   valid / invalid
```

If verification succeeds, Bob has evidence that:

1. The holder of Alice's private key created the signature.
2. The signed data has not changed.

Assuming, of course, that Bob has a trustworthy association between the public key and Alice's identity.

---

# 31. Signing with `openssl dgst`

Alice signs an image using SHA-512 and her private key:

```bash
openssl dgst \
  -sha512 \
  -sign alice-private.pem \
  -out dataimage-digest.sign \
  dataimage.png
```

This performs the hash-and-sign operation.

We can Base64-encode the binary signature:

```bash
base64 \
  dataimage-digest.sign \
  > dataimage-digest.sign.base64
```

And, if required by our transport mechanism, Base64-encode the image:

```bash
base64 \
  dataimage.png \
  > dataimage.png.base64
```

Alice sends:

```text
dataimage.png.base64
dataimage-digest.sign.base64
```

Again, Base64 provides **transport encoding**, not security.

---

# 32. Bob Verifies the Signature

Bob reconstructs the original data:

```bash
base64 -d \
  dataimage.png.base64 \
  > dataimage.png.orig
```

Recover the binary signature:

```bash
base64 -d \
  dataimage-digest.sign.base64 \
  > dataimage-digest.sign.orig
```

Then verify using **Alice's public key**:

```bash
openssl dgst \
  -sha512 \
  -verify alice-public.pem \
  -signature dataimage-digest.sign.orig \
  dataimage.png.orig
```

A successful verification produces something similar to:

```text
Verified OK
```

Modify even one byte of the signed file and verification should fail.

The rule is:

```text
Sign with PRIVATE key
Verify with PUBLIC key
```

---

# 33. Signing with `pkeyutl`

We can also separate hashing and the public-key operation.

First create the SHA-512 digest:

```bash
openssl dgst \
  -sha512 \
  -binary \
  -out dataimage-digest \
  dataimage.png
```

Alice signs the digest:

```bash
openssl pkeyutl \
  -sign \
  -inkey alice-private.pem \
  -in dataimage-digest \
  -out dataimage-digest.sign
```

Bob calculates the digest of the received file and verifies the signature using Alice's public key:

```bash
openssl pkeyutl \
  -verify \
  -pubin \
  -inkey alice-public.pem \
  -in dataimage-digest \
  -sigfile dataimage-digest.sign
```

For production protocols, don't invent your own signature format from these low-level primitives. Use a standard protocol and its prescribed signature scheme and padding.

---

# 34. Signing Is Not "Encrypting with the Private Key"

You'll often hear RSA signatures explained as:

> "Encrypt the hash with the private key."

It's a convenient introductory mental model, but technically it is misleading.

Modern RSA encryption and RSA signatures use different padding and encoding schemes and are distinct cryptographic operations.

For example:

```text
RSA-OAEP
    encryption

RSA-PSS
    signatures
```

So a better rule is:

```text
Public key encryption:
    encrypt with public key
    decrypt with private key

Digital signatures:
    sign with private key
    verify with public key
```

Don't think of a signature as encrypted data.

---

# 35. Encryption vs Signing

This distinction deserves its own table.

| Alice wants...                          | Alice uses          | Bob uses           |
| --------------------------------------- | ------------------- | ------------------ |
| Only Bob to read data                   | Bob's public key    | Bob's private key  |
| Bob to verify Alice created/signed data | Alice's private key | Alice's public key |

Or visually:

```text
CONFIDENTIALITY

Alice
  |
  | Bob PUBLIC key
  v
Encrypt
  |
  v
Bob
  |
  | Bob PRIVATE key
  v
Decrypt
```

versus:

```text
AUTHENTICITY + INTEGRITY

Alice
  |
  | Alice PRIVATE key
  v
Sign
  |
  v
Bob
  |
  | Alice PUBLIC key
  v
Verify
```

Those are fundamentally different operations.

---

# 36. What If We Need Both?

Often we want:

```text
Confidentiality
+
Integrity
+
Authenticity
```

Then encryption and authentication/signing mechanisms can be combined appropriately.

For example:

```text
Original Data
     |
     +----> authenticated encryption ----> Ciphertext
     |
     +----> digital signature where protocol requires it
```

Exactly how this should be combined depends on the protocol. Don't design a custom cryptographic protocol unless you have an exceptionally good reason to do so.

---

# 37. Putting Everything Together

We can now organise the entire subject into a few simple transformations.

## URL Encoding

```text
Unsafe URL characters
        |
        v
URL-safe representation
```

**Purpose:** transport.

**Security:** none.

---

## Base64

```text
Binary
  |
  v
Text
```

**Purpose:** representation/transport.

**Security:** none.

---

## Hashing

```text
Any amount of data
       |
       v
Fixed-size digest
```

**Purpose:** fingerprint/integrity building block.

**Reversible:** no.

---

## Symmetric Encryption

```text
Plaintext + Secret Key
          |
          v
      Ciphertext
```

**Purpose:** confidentiality.

**Strength:** fast and suitable for bulk data.

**Problem:** key distribution.

---

## Asymmetric Encryption

```text
Plaintext + Recipient Public Key
              |
              v
          Ciphertext
              |
              v
      Recipient Private Key
              |
              v
           Plaintext
```

**Purpose:** public-key confidentiality/key transport in appropriate schemes.

**Strength:** no pre-shared secret required.

**Limitation:** unsuitable for encrypting large amounts of data directly.

---

## Hybrid Encryption

```text
DATA ----------------------+
                           |
                    Symmetric encryption
                           |
                           v
                    Encrypted Data


SYMMETRIC KEY -------------+
                           |
                 Public-key protection
                           |
                           v
                    Protected Key
```

**Purpose:** combine the performance of symmetric encryption with public-key key establishment/protection.

---

## Digital Signature

```text
Data
 |
 | Hash + Signature algorithm
 v
Signature
 |
 | Public key verification
 v
Valid / Invalid
```

**Purpose:**

```text
Integrity
+
Authenticity
```

It does **not** inherently provide confidentiality.

---

# 38. How This Appears in Real Systems

Once these fundamentals are clear, many apparently complicated technologies become much easier to understand.

## HTTPS / TLS

At a high level, TLS combines:

```text
Certificates
Public-key cryptography / key agreement
Digital signatures
Symmetric session encryption
Authenticated encryption
Hash functions
```

The expensive asymmetric operations help establish/authenticate the secure session.

Fast symmetric cryptography protects the application traffic.

---

## JWT

A JWT frequently looks like:

```text
xxxxx.yyyyy.zzzzz
```

The first two parts use **Base64URL encoding**.

That does **not** make their contents secret.

For a signed JWT/JWS:

```text
Header.Payload.Signature
```

the signature protects integrity/authenticity.

Anyone possessing the token can generally decode its header and payload.

A signed JWT is therefore not automatically encrypted.

---

## SAML

SAML uses many of the same concepts:

```text
XML
+
Base64
+
URL encoding
+
XML Digital Signature
+
X.509 certificates
```

For example, the HTTP-Redirect binding commonly involves:

```text
SAML XML
   |
   v
DEFLATE
   |
   v
Base64
   |
   v
URL encode
```

A SAML Response sent with HTTP POST is commonly Base64 encoded.

And the SAML Response or Assertion may be digitally signed:

```text
IdP Private Key
      |
      v
Sign SAML Assertion
      |
      v
Service Provider
      |
      | IdP Certificate/Public Key
      v
Verify Signature
```

Once encoding, hashing and signatures are understood independently, SAML becomes much less mysterious.

---

# 39. A Practical Mental Model

When examining an unfamiliar security protocol, ask these questions.

### Is the data merely encoded?

Look for:

```text
Base64
Base64URL
percent encoding
hex
```

That is representation, not confidentiality.

### Is there a hash?

Ask:

```text
What data is being hashed?
Which algorithm?
Where does the trusted comparison value come from?
```

### Is data encrypted?

Ask:

```text
Which cipher?
Where does the key come from?
How is integrity/authentication provided?
```

### Is public-key cryptography involved?

Ask:

```text
Whose public key?
Whose private key?
What operation is being performed?
How do we trust the public key?
```

### Is there a digital signature?

Ask:

```text
Who signs?
Which private key?
Who verifies?
Which public key/certificate?
What exact bytes are signed?
```

Those questions often reveal the entire security architecture.

---

# 40. The Most Important Distinctions

If you remember nothing else, remember these:

```text
Base64 != Encryption

URL Encoding != Encryption

Hashing != Encryption

Encryption != Signing
```

And:

```text
Symmetric encryption:
    same shared secret/key material
    fast
    bulk data

Public-key encryption:
    public/private key pair
    comparatively expensive
    small payloads / key protection

Hybrid encryption:
    symmetric encryption for data
    public-key cryptography for key establishment/protection

Digital signature:
    private key signs
    public key verifies
```

Finally:

```text
Encoding
    solves representation.

Hashing
    creates a one-way fingerprint.

Encryption
    protects confidentiality.

Digital signatures
    protect integrity and establish authenticity.

Certificates
    bind identities to public keys.

Hybrid cryptography
    combines these primitives into practical secure systems.
```

That small set of concepts underpins an enormous part of modern application security.
