# webMethods Service Catalog

This directory contains JSON files that describe the service contracts (input and output signatures) for built-in webMethods Integration Server services. The services are organized by functional category, such as `STRING`, `MATH`, `JDBC`, `JSON`, and `XML`.

AI skills use these files to identify valid service names and pipeline parameters during FSL generation. This prevents hallucinated or incorrect service invocations.
