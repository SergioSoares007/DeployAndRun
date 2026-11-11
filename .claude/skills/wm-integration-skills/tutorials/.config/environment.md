# webMethods Environment Configuration

This file defines the local installation directory required for deployment automation.

---

## Optional Setting

WEBMETHODS_HOME = <PATH_TO_WEBMETHODS_INSTALLATION>

Example:
WEBMETHODS_HOME = C:\IBMwebMethods_12_1_Fix2

---

## Rules

- WEBMETHODS_HOME MUST point to the top-level installation directory
- The directory MUST contain:
  - IntegrationServer/
- Do NOT point to IntegrationServer directly
