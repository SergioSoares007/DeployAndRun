---
title: "Building Real-Time Order Notifications with IBM webMethods Integration Server 11.1 and WebSockets"
date: 2026-10-18T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["WebSockets", "Integration Server", "webmethods","Real-Time"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Building Real-Time Order Notifications with IBM webMethods Integration Server 11.1 and WebSockets"
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
# Building Real-Time Order Notifications with IBM webMethods Integration Server 11.1 and WebSockets

*How to implement server-push notifications using WebSocket endpoints, lifecycle callbacks, Java Services and a lightweight HTML dashboard.*

## Introduction

Traditional HTTP-based integrations typically follow a request-response model. A client sends a request, the server processes it and returns a response. If the client needs to know whether something has changed, it must make another request.

This works well for many integration scenarios, but it is less suitable for applications that require immediate updates.

Consider an order management system. A customer places an order, and its status changes throughout the fulfilment process:

`CREATED → PROCESSING → SHIPPED → DELIVERED`

With traditional HTTP polling, the frontend might request the order status every few seconds. Most requests return no new information.

**WebSockets provide a different approach:** the client establishes a persistent, bidirectional connection, allowing the server to push updates whenever an event occurs.

In this article, we will build a simple proof of concept (POC) using **IBM webMethods Integration Server 11.1**, demonstrating how to send order notifications from Integration Server directly to a browser.

We will also explore the WebSocket lifecycle callbacks, including `onConnect`, `onClose`, `onText` and `onBinary`, and discuss an important security configuration that can prevent callbacks from executing.

## 1. What Are WebSockets?

WebSocket is a communication protocol that establishes a persistent, full-duplex connection between a client and a server.

Unlike traditional HTTP, where each request typically initiates a separate interaction, WebSocket allows both parties to exchange messages over an established connection.

The connection begins with an HTTP upgrade handshake. Once the upgrade succeeds, the client and server communicate using WebSocket frames.

WebSocket connections commonly use two URL schemes:

- `ws://` — unencrypted WebSocket communication.
- `wss://` — WebSocket communication secured with TLS.

WebSockets are particularly useful for:

- Real-time order and shipment notifications.
- Monitoring dashboards.
- Live operational alerts.
- Chat applications.
- Financial market updates.
- Collaborative applications.
- Event-driven user interfaces.

For our POC, Integration Server acts as the **WebSocket server**, while a standard web browser acts as the **WebSocket client**.

## 2. POC Architecture

Our implementation has three main components:

1. An IBM webMethods Integration Server WebSocket endpoint.
2. A set of services that manage active WebSocket sessions and publish notifications.
3. A lightweight HTML dashboard that receives notifications.

The architecture looks like this:

```text
                IBM webMethods Integration Server 11.1
              +----------------------------------------+
              |                                        |
              |   orders:publishOrderUpdate            |
              |                |                       |
              |                v                       |
              |   sessionManager:getActiveSessions     |
              |                |                       |
              |                v                       |
              |        pub.websocket:send              |
              |                |                       |
              |                v                       |
              |   WebSocket Endpoint (Port 8088)       |
              |   /orders/notifications                |
              |                |                       |
              +----------------|-----------------------+
                               |
                          WebSocket
                               |
                               v
                    +----------------------+
                    |    HTML Dashboard    |
                    |                      |
                    |  Order notifications |
                    |      in real time    |
                    +----------------------+
```

When the browser connects, Integration Server registers the WebSocket session. When an order notification is published, Integration Server retrieves the active sessions and sends the message to each connected client.

For simplicity, the POC uses:

- A fixed JSON notification.
- In-memory session management.
- A single Integration Server instance.
- No database or external message broker.
- No additional frontend framework.

This keeps the focus on the native WebSocket capabilities of Integration Server.

## 3. Configuring the WebSocket Port

The first step is to configure a WebSocket listener.

In Integration Server Administrator, navigate to:

**Server → Ports → Add Port**

Create a port with the following configuration:

| Property | Value |
|---|---|
| Port Type | webMethods/WebSocket |
| Port Number | 8088 |
| Enabled | Yes |

For a production environment, a secure WebSocket listener using TLS would normally be preferable.

Once the port is configured, we can create the WebSocket endpoint.

## 4. Creating a WebSocket Server Endpoint

In Service Designer, create a package called:

`OrderNotificationsPOC`

Inside the package, create a folder named `websocket`.

Then create a WebSocket server endpoint named:

`orderNotifications`

Configure its endpoint path as:

`/orders/notifications`

The browser will connect using a URL similar to:

```text
ws://integration-server-host:8088/orders/notifications
```

Service Designer automatically creates the callback services associated with the endpoint:

```text
OrderNotificationsPOC
└── websocket
    └── orderNotifications
        ├── onConnect
        ├── onBinary
        ├── onText
        └── onClose
```

These callbacks allow Integration Server to react to WebSocket events.

## 5. Understanding the WebSocket Callbacks

One of the most important aspects of implementing WebSockets in Integration Server is understanding the purpose of each callback.

### onConnect — A Client Establishes a Connection

The `onConnect` callback is invoked when a WebSocket connection is established.

In our implementation, it receives a `sessionId` identifying the connected client.

We use this callback to register the session in an in-memory collection.

```text
Browser connects
       |
       v
WebSocket endpoint
       |
       v
onConnect
       |
       v
sessionManager:registerSession
       |
       v
Store sessionId
```

This allows Integration Server to maintain a list of connected clients.

Without session tracking, our notification service would not know which WebSocket sessions should receive messages.

### onClose — A Client Disconnects

The `onClose` callback handles the closing of a WebSocket connection.

In our POC, it invokes:

`sessionManager:unregisterSession`

The service removes the corresponding `sessionId` from the active-session collection.

This prevents the notification publisher from attempting to send messages to sessions that are no longer active.

The lifecycle becomes:

```text
onConnect → Register session
onClose   → Remove session
```

In a more advanced implementation, session cleanup should also account for unexpected disconnections, stale sessions and failed sends.

### onText — Receiving Text Messages

The `onText` callback is invoked when Integration Server receives a WebSocket text message from a client.

In our implementation, the callback exposes:

- `sessionId` — identifies the originating WebSocket session.
- `message` — contains the received text.

Text messages are especially useful for JSON-based communication.

For example, a browser could send:

```json
{
  "action": "subscribe",
  "orderId": "ORD-1001"
}
```

Integration Server could process this request and associate the session with a particular order.

For our initial implementation, we configured `onText` as a simple echo service using:

`pub.websocket:send`

This demonstrates that the same WebSocket connection supports communication in both directions.

However, the final order notification POC does not depend on the browser sending text messages. Notifications are initiated by a server-side Flow Service.

### onBinary — Receiving Binary Messages

The `onBinary` callback is invoked when a WebSocket client sends a **binary message** instead of a text message.

WebSocket supports both text and binary message types.

Text messages are suitable for JSON, XML, commands and other character-based data. Binary messages are suitable for raw bytes or application-specific binary formats.

Typical binary use cases include:

- Sending audio chunks from a browser to a backend service.
- Transferring binary telemetry from devices.
- Streaming compact binary-encoded data.
- Uploading binary payloads over a persistent connection.
- Exchanging messages encoded using formats such as Protocol Buffers or MessagePack.

For example, a browser can send binary data using the JavaScript WebSocket API:

```javascript
const socket = new WebSocket(
  "ws://integration-server-host:8088/orders/notifications"
);

socket.onopen = () => {
  const payload = new Uint8Array([10, 20, 30, 40]);
  socket.send(payload);
};
```

Because the payload is binary, Integration Server routes it to the `onBinary` callback rather than `onText`.

The callback can then process the received bytes according to the application's requirements. The exact input fields should be checked against the callback specification in the installed Integration Server version.

For example, a binary processing service might:

1. Receive a binary payload.
2. Validate its format.
3. Decode it into an application-specific structure.
4. Invoke an Integration Server service to process the decoded information.

**Do we need `onBinary` for order notifications?**

No.

Our POC sends JSON text notifications, so binary message handling is unnecessary.

Nevertheless, `onBinary` is valuable when building integrations that require efficient binary data exchange or protocols that are not text-based.

It is also worth noting that `onBinary` handles binary messages **received by the server**. It is not required simply because an application uses WebSockets.

## 6. Managing Active WebSocket Sessions

To send notifications to multiple connected browsers, Integration Server needs to know which sessions are active.

For this POC, we created a folder named:

`sessionManager`

It contains three Java Services:

```text
sessionManager
├── registerSession
├── unregisterSession
└── getActiveSessions
```

All three services use a shared in-memory collection.

### Shared Java Source

In the Shared Source Area, we defined a thread-safe set:

```java
private static final java.util.Set<String> ACTIVE_SESSIONS =
    java.util.concurrent.ConcurrentHashMap.newKeySet();

private static java.util.Set<String> getSessionMap() {
    return ACTIVE_SESSIONS;
}
```

The use of `ConcurrentHashMap.newKeySet()` is intentional.

WebSocket connections can be established and closed concurrently, so the session collection needs to support concurrent access.

An important detail of the Integration Server Java Service model is that Java Services within the same folder can use shared Java source.

This allows our three services to access the same session collection.

### registerSession

The `registerSession` service receives a `sessionId` and adds it to the collection:

```java
IDataCursor cursor = pipeline.getCursor();
String sessionId = IDataUtil.getString(cursor, "sessionId");
cursor.destroy();

if (sessionId == null || sessionId.trim().isEmpty()) {
    throw new ServiceException("sessionId is required");
}

ACTIVE_SESSIONS.add(sessionId);
```

The `onConnect` callback invokes this service whenever a client establishes a connection.

### unregisterSession

The `unregisterSession` service removes the session identifier:

```java
IDataCursor cursor = pipeline.getCursor();
String sessionId = IDataUtil.getString(cursor, "sessionId");
cursor.destroy();

if (sessionId != null) {
    ACTIVE_SESSIONS.remove(sessionId);
}
```

This service is invoked by `onClose`.

### getActiveSessions

Finally, `getActiveSessions` returns the active session identifiers as a String array:

```java
String[] sessionIds =
    ACTIVE_SESSIONS.toArray(new String[0]);

IDataCursor cursor = pipeline.getCursor();
IDataUtil.put(cursor, "sessionIds", sessionIds);
cursor.destroy();
```

Its output is:

`sessionIds` — String List

The notification publisher uses this list to send a message to every connected browser.

**Important limitation:** this is an in-memory registry. Sessions are lost when the relevant Java class is reloaded or Integration Server restarts. It is suitable for a demonstration, but it is not a distributed session-management solution.

## 7. Publishing Order Notifications

Next, we created a Flow Service named:

`OrderNotificationsPOC.orders:publishOrderUpdate`

Its responsibility is to publish an order notification to all currently connected WebSocket clients.

The Flow has the following structure:

```text
publishOrderUpdate
│
├── MAP
│   └── Create JSON message
│
├── INVOKE sessionManager:getActiveSessions
│
└── LOOP over sessionIds
    │
    └── INVOKE pub.websocket:send
```

### Creating the Notification

For the POC, we use a fixed JSON message:

```json
{
  "orderId": "ORD-1001",
  "status": "SHIPPED",
  "customer": "Cliente Demo"
}
```

The first MAP step assigns this JSON text to a String variable named `message`.

Using a fixed message keeps the demonstration simple and avoids introducing unnecessary dependencies.

### Retrieving Connected Clients

The next step invokes:

`sessionManager:getActiveSessions`

This returns the `sessionIds` array.

### Sending the Notification

We use a Flow `LOOP` over `sessionIds`.

Inside the loop, we invoke:

`pub.websocket:send`

The service receives:

| Input | Value |
|---|---|
| `sessionId` | Current session identifier from the loop |
| `message` | JSON notification |

Integration Server executes the send operation for each active session.

The result is a simple broadcast mechanism: every connected browser receives the same notification.

For a real order management solution, this could be extended to send notifications only to sessions subscribed to a particular customer, order or event category.

## 8. Building the HTML Dashboard

The frontend requires no framework or additional library.

A standard HTML page with JavaScript is sufficient.

Here is the complete dashboard:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Notifications POC</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 40px;
    }

    #status {
      margin-bottom: 20px;
    }

    li {
      padding: 10px;
      border-bottom: 1px solid #ddd;
    }
  </style>
</head>
<body>

  <h2>Order Notifications — WebSocket POC</h2>

  <div id="status">Connecting...</div>

  <h3>Received Notifications</h3>

  <ul id="notifications"></ul>

  <script>
    const ws = new WebSocket(
      "ws://integration-server-host:8088/orders/notifications"
    );

    ws.onopen = () => {
      document.getElementById("status").textContent =
        "Connected to Integration Server";
    };

    ws.onmessage = (event) => {
      const li = document.createElement("li");

      li.textContent =
        new Date().toLocaleTimeString() +
        " — " +
        event.data;

      document.getElementById("notifications").prepend(li);
    };

    ws.onclose = () => {
      document.getElementById("status").textContent =
        "Disconnected";
    };

    ws.onerror = () => {
      document.getElementById("status").textContent =
        "WebSocket connection error";
    };
  </script>

</body>
</html>
```

Replace `integration-server-host` with the hostname or IP address of your Integration Server.

When the browser opens the page, JavaScript establishes the WebSocket connection.

The `onopen` handler updates the connection status, while `onmessage` displays each notification received from Integration Server.

The dashboard does not need to poll any REST endpoint.

It simply waits for messages pushed by the server.

## 9. An Important Lesson: WebSocket Callback ACLs

During the implementation, we encountered an issue that is particularly relevant when working with Integration Server WebSocket endpoints.

The browser successfully established a WebSocket connection.

Integration Server Administrator showed an active session under:

**Server → Ports → WebSocket Server Endpoints**

However, the `onConnect` callback was not registering the session, and `getActiveSessions` returned an empty list.

Interestingly, manually executing `registerSession` worked correctly.

The Java Services were functioning, and the shared session collection was working as expected.

The actual problem was revealed by the Integration Server logs:

```text
[ISS.0084.9004] Access Denied

Invocation of the service
OrderNotificationsPOC.websocket.orderNotifications:onConnect
failed

Invocation of the service
OrderNotificationsPOC.websocket.orderNotifications:onClose
failed
```

### Why Did This Happen?

Integration Server enforces Access Control Lists (ACLs) when invoking services.

Although the WebSocket connection itself was established successfully, the execution context did not have permission to invoke the callback services.

Consequently:

- The browser could connect.
- Integration Server could display the active WebSocket session.
- The `onConnect` service invocation failed.
- The session was not added to our in-memory registry.
- The notification publisher found no recipients.

This is an important distinction:

**A successful WebSocket handshake does not necessarily mean that the application's lifecycle callbacks executed successfully.**

### The Fix

For this unauthenticated laboratory POC, we changed the **Execute ACL** of the following callback services to `Anonymous`:

```text
OrderNotificationsPOC.websocket.orderNotifications:onConnect

OrderNotificationsPOC.websocket.orderNotifications:onClose
```

After applying the ACL changes, the callbacks executed successfully and the session registry was populated automatically.

The dashboard then received notifications without any manual session registration.

For production environments, ACL configuration should be aligned with the application's authentication and authorisation requirements. Anonymous callback execution is appropriate only when the endpoint's security model permits it.

### Troubleshooting Checklist

If a WebSocket client connects but the expected server-side logic does not execute, check:

1. Whether the WebSocket port is enabled.
2. Whether the endpoint is registered and active.
3. Whether Integration Server Administrator shows an active WebSocket session.
4. Whether the callbacks are correctly associated with the endpoint.
5. Whether the Integration Server logs contain `Access Denied` errors.
6. Whether the callback services have the appropriate Execute ACL.
7. Whether the session registry is populated after a new connection.

In our case, the ACL configuration was the decisive issue.

## 10. Testing the Complete Solution

Once the callbacks and ACLs were configured, we tested the complete notification flow.

### Step 1 — Connect the Browser

Open the HTML dashboard.

The page displays:

```text
Connected to Integration Server
```

### Step 2 — Verify Session Registration

Execute:

`OrderNotificationsPOC.sessionManager:getActiveSessions`

The service should return the identifier of the connected WebSocket session.

### Step 3 — Publish a Notification

Execute:

`OrderNotificationsPOC.orders:publishOrderUpdate`

The service retrieves the active sessions and invokes `pub.websocket:send` for each one.

### Step 4 — Observe the Dashboard

The browser receives the notification immediately:

```json
{
  "orderId": "ORD-1001",
  "status": "SHIPPED",
  "customer": "Cliente Demo"
}
```

No page refresh is required.

### Step 5 — Disconnect

When the browser closes the connection, Integration Server invokes `onClose`, which removes the session identifier from the in-memory registry.

The lifecycle is complete.

## 11. From POC to Production

This implementation demonstrates the core capabilities of WebSockets in IBM webMethods Integration Server, but several enhancements would be necessary for a production solution.

**Secure connections:** use `wss://` with properly configured TLS certificates rather than an unencrypted WebSocket listener.

**Authentication and authorisation:** establish a security model for client connections, callback execution and access to order-specific events.

**Targeted notifications:** associate sessions with users, customers or subscriptions rather than broadcasting every event to every client.

**Error handling:** handle failed sends, disconnected sessions and unexpected connection termination.

**Reconnection:** implement automatic reconnection in the browser, with appropriate backoff behaviour.

**Scalability:** the current session registry exists in the memory of a single Integration Server instance. A multi-instance deployment requires a strategy for routing notifications to the instance that owns each WebSocket connection.

**Message reliability:** WebSockets provide real-time delivery over an active connection, but they do not automatically provide durable message storage or replay. If a client is disconnected when an event occurs, an additional mechanism is required to recover missed notifications.

**Business integration:** replace the fixed JSON message with events generated by an ERP, order management system, API or integration process.

For example, an SAP order status update could trigger an Integration Server Flow Service, which would then publish a WebSocket notification to the relevant frontend clients.

## 12. WebSockets vs REST APIs

WebSockets do not replace REST APIs. They solve a different communication problem.

| Capability | REST | WebSocket |
|---|---|---|
| Communication model | Request-response | Persistent, bidirectional |
| Server-initiated notifications | Requires an additional mechanism | Native |
| Connection | Usually independent requests | Long-lived |
| Real-time updates | Often implemented through polling | Server push |
| Typical use cases | CRUD, API operations, integrations | Notifications, live dashboards, interactive messaging |

A practical enterprise architecture can combine both approaches.

For example:

- REST APIs handle order creation and retrieval.
- Integration Server processes order status changes.
- WebSockets push notifications to connected applications.

This separation allows each technology to be used where it provides the greatest value.

## Conclusion

IBM webMethods Integration Server 11.1 provides native WebSocket capabilities that can be used to build real-time, event-driven integrations without introducing a separate WebSocket server.

In this POC, we implemented:

- A WebSocket server endpoint.
- Connection lifecycle callbacks.
- Thread-safe in-memory session management.
- A Flow Service that broadcasts JSON notifications.
- A lightweight HTML dashboard.
- A working end-to-end server-push notification mechanism.

We also explored the purpose of `onBinary`, which extends WebSocket integrations beyond text-based messaging to binary data exchange.

Perhaps the most valuable troubleshooting lesson was the importance of **Execute ACLs on WebSocket callback services**. Even when a client successfully establishes a WebSocket connection, callback execution can fail because of insufficient permissions.

With the correct ACL configuration, our implementation worked end to end.

The result is a simple but effective foundation for real-time order tracking, operational monitoring and event-driven user experiences using IBM webMethods Integration Server.

---

**Technology stack:** IBM webMethods Integration Server 11.1 · Service Designer · Flow Services · Java Services · WebSocket · HTML5 · JavaScript · JSON

**Keywords:** IBM webMethods, Integration Server, WebSocket, onConnect, onClose, onText, onBinary, Real-Time Notifications, Server Push, Integration Architecture
