---
title: "Connecting webMethods JDBC Adapter to a IBM Informix Database"
date: 2026-01-04T23:00:03+00:00
# weight: 1
# aliases: ["/first"]
tags: ["Database", "Informix", "JDBC Adapter"]
author: "me"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false
draft: false
hidemeta: false
comments: false
description: "Running IBM Informix in Docker and Connecting webMethods JDBC Adapter"
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
# Running IBM Informix in Docker and Connecting webMethods JDBC Adapter

## Overview

This article documents, end‑to‑end, the setup of **IBM Informix Developer Edition** running in a **Docker container** and its successful integration with **Software AG webMethods Integration Server** using the **JDBC Adapter**.

The goal is to provide a practical, real‑world guide covering:

* Informix installation via Docker
* Linux host preparation and security pitfalls
* Network and port exposure
* JDBC driver selection and placement
* webMethods JDBC Adapter configuration
* Common errors and how they were resolved

This guide is based on a real troubleshooting session and reflects the issues you are *most likely* to encounter in enterprise Linux environments.

---

## 1. Informix Architecture Basics (Context)

Before starting, it is important to understand a few Informix concepts:

* **Instance**: the Informix engine (oninit)
* **Database**: logical container for tables and schemas
* **DBSpace**: physical storage (files/disks) where databases live
* **sysmaster / sysadmin / sysutils**: system databases (not for business data)

Unlike some RDBMSs, Informix **requires dbspaces** before creating databases.

---

## 2. Installing Informix Using Docker

### 2.1 Docker Image

We used the official Informix Developer image:

```bash
docker pull ibmcom/informix-developer-database:latest
```

### 2.2 Running the Container

```bash
docker run -it --name ifx -h ifx --privileged \
  -e LICENSE=accept \
  -p 192.168.150.218:9088:9088 \
  -p 192.168.150.218:9089:9089 \
  ibmcom/informix-developer-database:latest
```

**Key points:**

* Explicit IP binding avoids Docker networking ambiguities
* Port **9088** = primary SQL listener (onsoctcp)
* Port **9089** = DR listener

---

## 3. Validating Informix Inside the Container

```bash
docker exec -it ifx bash
su - informix
onstat -
```

Check sqlhosts:

```bash
cat /opt/ibm/informix/etc/sqlhosts
```

Example:

```
informix   onsoctcp   *ifx   9088
```

---

## 4. Linux Host Networking & Security

### 4.1 Docker Port Visibility

```bash
docker port ifx
```

Expected:

```
9088/tcp -> 0.0.0.0:9088
```

### 4.2 Verifying Listener

```bash
ss -lntp | grep 9088
```

---

## 5. SELinux: The Hidden Blocker

On Rocky / RHEL‑based systems, **SELinux blocks Docker‑published ports** even if:

* firewalld is disabled
* ports are published correctly

### 5.1 Detecting SELinux

```bash
getenforce
```

If output is:

```
Enforcing
```

SELinux **will block external connections**.

### 5.2 Temporary Test

```bash
sudo setenforce 0
```

### 5.3 Permanent Correct Fix

```bash
sudo dnf install -y policycoreutils-python-utils
sudo semanage port -a -t docker_port_t -p tcp 9088
sudo semanage port -a -t docker_port_t -p tcp 9089
sudo setenforce 1
```

After this:

```bash
telnet <docker-host-ip> 9088
```

must succeed from remote hosts.

---

## 6. Creating a Business Database

System databases are **not** for application data.

### 6.1 Creating a Database (Developer Setup)

If no data dbspace exists yet:

```sql
CREATE DATABASE fnac WITH LOG;
```

Later, for production, you should create dedicated dbspaces.

### 6.2 Example Table

```sql
CREATE TABLE clientes (
  cliente_id  SERIAL PRIMARY KEY,
  nome        VARCHAR(100) NOT NULL,
  email       VARCHAR(150),
  telefone    VARCHAR(30),
  nif         CHAR(9),
  data_criacao DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND
);
```

---

## 7. JDBC Driver Selection (Critical)

### ❌ What Does *Not* Work

* `libAPI.jar`
* Native client libraries

These **do not contain** the JDBC `jdbcx` classes required by webMethods.

### ✅ Correct Driver

Use the **official Informix JDBC driver**:

```text
jdbc-15.0.0.2.jar
```

Downloaded from Maven Central.

---

## 8. Placing the Driver in webMethods

### 8.1 Correct Location

```text
<IntegrationServer>/instances/default/packages/WmJDBCAdapter/code/jars/static/
```

### 8.2 Important Rules

* Driver **must exist only once**
* Do **not** duplicate jars in `code/jars/`
* Restart Integration Server after copying

---

## 9. webMethods JDBC Adapter Configuration

### 9.1 DataSource Mode (Required)

webMethods expects a **DataSource**, not a raw Driver.

```text
DataSource Class: com.informix.jdbcx.IfxDataSource
```

### 9.2 Connection Properties

| Property         | Value                      |
| ---------------- | -------------------------- |
| Server Name      | informix                   |
| Network Protocol | onsoctcp                   |
| Port             | 9088                       |
| Database         | fnac                       |
| User             | informix                   |
| Password         | in4mix                     |
| Other Properties | IfxIFXHOST=192.168.150.218 |

### 9.3 Common Mistakes

❌ Using `IfxDriver` as DataSource
❌ Missing jdbcx classes
❌ Multiple Informix jars
❌ Using `sysmaster` for business data

---

## 10. Typical Errors and Root Causes

| Error                      | Root Cause            |
| -------------------------- | --------------------- |
| Connection refused         | Docker bind / SELinux |
| DataSource class not found | Wrong driver          |
| Unexpected error occurred  | Hidden SQLException   |
| INFORMIXSERVER mismatch    | Wrong Server Name     |

Always check:

```
IntegrationServer/instances/<inst>/logs/server.log
```

---

## 11. Final Result

✅ Informix running in Docker
✅ Secure networking resolved
✅ Correct JDBC driver loaded
✅ webMethods JDBC Adapter connected
✅ Business database created

---

## 12. Final Recommendations

* Use a **dedicated DB user** (not `informix`)
* Avoid `rootdbs` for business data
* Always enable logging (`WITH LOG`)
* Document SELinux rules for future nodes

---

## Conclusion

This setup demonstrates that Informix integrates cleanly with webMethods when:

* Docker networking is understood
* SELinux is handled correctly
* The proper JDBC driver is used

Most issues arise **outside** the database itself — in security and classloading.

Once those are addressed, Informix is stable, fast, and reliable in containerized enterprise environments.

---

*End of document.*
