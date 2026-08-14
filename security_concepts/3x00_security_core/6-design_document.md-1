# Executive Summary

ApexVault is designed to provide **hyper-secure storage** for VIP clients by enforcing strong authentication, strict access controls, and tamper-proof accounting. The system eliminates traditional passwords, prevents even SysAdmins from accessing client files, and ensures audit logs remain immutable. ApexVault combines modern cryptography, hardware-based security, and centralized logging to create a secure, auditable, and trustworthy environment.

---

## 1. Authentication Strategy

- **Selected Technology:** FIDO2 Hardware Tokens + Biometric Verification  

- **Justification:**  
  Passwords are vulnerable to phishing, brute-force attacks, and credential reuse. FIDO2 hardware tokens generate cryptographic keys that are **never exposed to the network**, making them un-phishable. Biometric verification ensures that even if the token is stolen, only the legitimate user can authenticate. This approach eliminates risks associated with SMS codes, one-time passwords, or traditional passwords.

---

## 2. Authorization Model

- **Model Selected:** Role-Based Access Control (RBAC) with Mandatory Access Control (MAC) overlay  

- **Admin Restriction:**  
  - SysAdmins can manage servers, storage, and backups but **cannot access client files**.  
  - Client files are **encrypted client-side** using unique encryption keys per client.  
  - Encryption keys are stored in a **Hardware Security Module (HSM)** and never exposed to SysAdmins.  
  - SELinux policies enforce that even root processes cannot read or copy encrypted files, ensuring **technical separation of duties**.

---

## 3. Accounting Architecture

- **Storage Location:** Centralized, write-once log server (WORM) with replication across multiple secure sites.  

- **Integrity Mechanism:**  
  - All logs are **digitally signed** with asymmetric keys and **hash-chained** to prevent deletion or tampering.  
  - Real-time monitoring alerts administrators if logs are altered.  
  - Even if an attacker gains root access, logs cannot be modified due to **write-once storage** and cryptographic verification.

---

**Summary:**  

ApexVault combines **un-phishable authentication**, **strict access controls**, and **tamper-proof accounting** to protect client data. The design ensures that operational staff can manage systems without ever accessing sensitive content, audit trails are fully preserved, and all security pillars (Confidentiality, Integrity, Availability) are maintained.
