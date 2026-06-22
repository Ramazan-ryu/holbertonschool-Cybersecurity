# Vanguard Security - Careers: Offensive Security Roles

## Strategic Justification for Chosen Roles

I have chosen to hire for the following three roles: **Infrastructure Penetration Tester**, **Web Application Security Consultant**, and **Red Team Operator**. This combination represents a highly strategic, "full-stack" expansion for Vanguard Security. The Infrastructure and Web Application roles are the bread-and-butter of the consulting industry; they allow us to capture the massive demand for compliance-driven testing across network architectures and the ever-growing surface area of cloud/web applications. Meanwhile, adding a dedicated Red Team Operator signals that Vanguard is maturing. It allows us to move upmarket, offering high-margin, advanced adversary simulations to enterprise clients whose security posture has outgrown standard vulnerability hunting. Together, these hires tell the market that Vanguard can test the plumbing, test the applications, and test the human defenders.

---

## Role 1: Infrastructure Penetration Tester

**Role Title and Positioning:**
As an Infrastructure Penetration Tester at Vanguard Security, you sit at the core of our technical assessment division. You will work closely with client network engineers, system administrators, and IT directors to evaluate the security of their foundational environments. Internally, you will collaborate frequently with our Web Application consultants to provide full-scope coverage.

**Scope of Intervention:**
You are responsible for testing internal and external corporate networks. Your domain includes Active Directory environments, domain controllers, firewalls, VPNs, routing protocols, and endpoint operating systems (Windows/Linux). It is explicitly *not* your domain to conduct deep-dive logic testing on custom web applications or to execute physical facility breaches.

**Key Technical and Soft Skills:**
*   **Technical:** Deep mastery of Active Directory exploitation (Kerberos attacks, NTLM relaying, BloodHound), proficiency in scripting (Python, Bash, PowerShell) for tool automation, and expertise with network protocols (TCP/IP, BGP, OSPF).
*   **Soft Skills:** The ability to translate complex attack chains into business risk for C-level executives, and meticulous documentation habits to ensure every exploited vector is reproducible and clearly explained.

**Relevant Certifications:**
*   **OSCP (Offensive Security Certified Professional):** Demonstrates a foundational, applied ability to enumerate, exploit, and document network and system vulnerabilities under a strict time limit.
*   **PNPT (Practical Network Penetration Tester):** Specifically validates modern skills in Active Directory exploitation and Open-Source Intelligence (OSINT), which are critical for internal network assessments.

**Distinction from Adjacent Roles:**
Unlike a Web Application Consultant who focuses on Layer 7 (the application), the Infrastructure Tester focuses on Layers 3 and 4, targeting the underlying operating systems and network infrastructure. They don't care about a site's Cross-Site Scripting (XSS) if they can just exploit the underlying IIS server via an unpatched Windows vulnerability.

**Typical Engagement Scenario:**
*Internal Network Penetration Test:* You are deployed to a client's headquarters and given a standard Ethernet connection to their employee VLAN without any credentials. Over the next two weeks, you perform network discovery, identify a misconfigured legacy database server, and exploit it to gain a foothold. From there, you pivot into the Active Directory environment, identifying and exploiting excessive privileges to escalate to Domain Admin. You conclude the engagement by delivering a report that prioritizes AD misconfigurations and offers a roadmap for hardening their internal network.

---

## Role 2: Web Application Security Consultant

**Role Title and Positioning:**
As a Web Application Security Consultant, you sit within the AppSec division. You act as the bridge between offensive security and software engineering, working closely with client development teams, DevOps engineers, and product managers to secure their software before and after deployment.

**Scope of Intervention:**
You will test custom web applications, APIs (REST, GraphQL, SOAP), cloud-hosted interfaces, and microservices architectures. Your focus is on logic flaws, injection vulnerabilities, and authentication bypasses. It is explicitly *not* your domain to test the corporate VPN, perform social engineering on employees, or assess physical site security.

**Key Technical and Soft Skills:**
*   **Technical:** Mastery of Burp Suite Professional, deep understanding of the OWASP Top 10, proficiency in code review (Java, C#, JavaScript/TypeScript), and strong knowledge of modern frontend frameworks (React, Angular) and API structures.
*   **Soft Skills:** High empathy for software developers. You must write remediation steps that are actionable for engineers—providing exact code snippets or configuration changes rather than just criticizing the flaw.

**Relevant Certifications:**
*   **OSWE (Offensive Security Web Expert):** Proves the ability to conduct rigorous, white-box code review to find complex, chained vulnerabilities in web applications that automated scanners miss.
*   **GWAPT (GIAC Web Application Penetration Tester):** Validates a comprehensive methodology for testing web applications, ensuring a standardized and rigorous approach to client engagements.

**Distinction from Adjacent Roles:**
While an Infrastructure Tester looks for unpatched servers, the Web App Consultant assumes the server is fully patched and attacks the custom code running on top of it. They differ from Cloud Security Assessors by focusing purely on the application's logic and data flow, rather than the AWS/Azure IAM policies and tenant configurations hosting it.

**Typical Engagement Scenario:**
*E-commerce Platform Assessment:* You are provided with authenticated and unauthenticated access to a staging environment for a new retail web application. By intercepting and manipulating API traffic, you identify an Insecure Direct Object Reference (IDOR) combined with a logic flaw in the payment gateway integration that allows a user to checkout without processing a financial charge. You document the exact HTTP requests required to reproduce the exploit and provide specific code-level remediation advice for the engineering team to patch the flaw before the app goes live.

---

## Role 3: Red Team Operator

**Role Title and Positioning:**
As a Red Team Operator, you sit in Vanguard’s advanced simulation unit. You work with mature enterprise clients, specifically interfacing with their C-suite and defensive teams (SOC/Blue Team). Internally, you act as the highest tier of offensive capability, often mentoring standard penetration testers.

**Scope of Intervention:**
Your scope is holistic and objective-based. You assess the people, processes, and technology of an organization to simulate a real-world Advanced Persistent Threat (APT). This includes evasion, stealth, payload delivery, lateral movement, and sometimes OSINT and remote social engineering. Exhaustive vulnerability listing is explicitly *not* your domain; you seek only the path of least resistance to achieve the objective.

**Key Technical and Soft Skills:**
*   **Technical:** Expertise in Command and Control (C2) frameworks (Cobalt Strike, Mythic), payload creation and EDR (Endpoint Detection and Response) evasion, advanced spear-phishing techniques, and stealthy lateral movement.
*   **Soft Skills:** Extreme patience and a "stealth mindset." Furthermore, you must possess the ego-free ability to run "Purple Team" debriefings, where you sit down with the SOC to transparently review logs and help them build better detection rules.

**Relevant Certifications:**
*   **OSEP (Offensive Security Evasion Techniques and Breaching Defenses):** Validates the ability to bypass modern defensive mechanisms like Antivirus and EDR, which is critical for operating quietly in a mature client environment.
*   **CRTO (Certified Red Team Operator):** Focuses specifically on the operational use of C2 frameworks (like Cobalt Strike) and attacking Active Directory environments while maintaining operational security (OpSec).

**Distinction from Adjacent Roles:**
A penetration tester (Infra or Web App) is noisy and tries to find *all* possible vulnerabilities to build a comprehensive list. A Red Team Operator is quiet, goal-oriented, and tries to find only *one* valid path to the objective (e.g., "steal the customer database"). They test the organization's *ability to detect and respond* to an attack, not just their patch management.

**Typical Engagement Scenario:**
*Adversary Simulation:* Vanguard is hired to test a financial institution's SOC. Over a 6-week period, you conduct OSINT to identify key employees and craft a highly targeted spear-phishing campaign that successfully grants you a foothold on a single HR workstation. Operating entirely in memory to evade the client's EDR, you establish stealthy C2 communication, move laterally to the database servers, and simulate the exfiltration of "crown jewel" financial data. At the end of the engagement, you conduct a collaborative debriefing with the Blue Team, mapping your actions to the MITRE ATT&CK framework so they can tune their alerts.
