# Hardening Updates: IR-2026-0414-01

This document outlines the mandatory baseline security enhancements required across corporate infrastructure. All recommendations are directly justified by incident evidence documented inside `forensic_findings_summary.md` and map to specific administrative and technical security gaps.

---

## HRD-001: PowerShell Constrained Language Mode

* **Control:** PowerShell Constrained Language Mode for non-administrative user accounts
* **Closes:** GAP-005, GAP-006
* **Configuration:**
  * **GPO Path:** Computer Configuration > Preferences > Windows Settings > Registry
  * **Registry Key:** `HKLM\System\CurrentControlSet\Control\Session Manager\Environment`
  * **Value name:** `__PSLockdownPolicy`
  * **Value type:** `REG_SZ`
  * **Value data:** `4`
* **Effect:** Restricts PowerShell to ConstrainedLanguage mode for standard users. This configuration completely blocks `[System.Management.Automation.ScriptBlock]::Create` invocations, unsafe COM object instantiation, and dynamic `.NET` type loading that critical LOLBin proxy execution techniques depend on.
* **Applies to:** Non-administrative domain accounts on all corporate workstations.
* **Validation:** Run `$ExecutionContext.SessionState.LanguageMode` inside a standard user shell prompt; expected output: `ConstrainedLanguage`

---

## HRD-002: AppLocker Rule for MSBuild.exe

* **Control:** AppLocker or Windows Defender Application Control application restriction policies for system compilation binaries
* **Closes:** GAP-005, GAP-006
* **Configuration:**
  * **GPO Path:** Computer Configuration > Windows Settings > Security Settings > Application Control Policies > AppLocker > Executable Rules
  * **Rule Logic:** Explicitly restrict execution of `MSBuild.exe` to members of `BUILTIN\Administrators` and named CI/CD service accounts, while enforcing a deny rule structure for all non-administrative accounts.
* **XML Rule Structure:**
```xml
<RuleCollection EnforcementMode="Enabled" Type="Exe">
  <FilePathRule Action="Deny" Id="61a34b22-8df2-46cc-9d43-df9c95b05814" Name="Deny MSBuild for Standard Users" UserOrGroupSid="S-1-1-0">
    <Description>Deny execution of MSBuild.exe to non-administrative users to mitigate compilation bypasses.</Description>
    <Conditions>
      <FilePathCondition Path="*\MSBuild.exe"/>
    </Conditions>
  </FilePathRule>
</RuleCollection>

Effect: Restricts the execution of development binaries like MSBuild.exe to isolate system compilers from standard users, removing the execution vectors used for direct code compilation bypasses.
Applies to: All standard endpoint user environments.
Validation: Execute MSBuild.exe from a standard user context; confirm the operating system blocks execution and logs Event ID 8004 in the AppLocker application control logs.

HRD-003: Conditional Access Policy for VPN Authentication
Control: Conditional access policy for edge network identity gateways
Closes: GAP-003, GAP-004

Configuration:
Platform: Microsoft Entra ID / Enterprise Identity Management Systems
Policy Parameters: Applied natively to all organizational VPN authentication endpoints.
Policy Logic: Evaluate every authentication request in real-time. Automatically block access or require step-up phishing-resistant MFA when a VPN login originates from new geographies or anomalous countries not previously seen for that specific user account within the prior 30 days.

Effect: Prevents the reuse of compromised domain credentials from untrusted network locations by demanding geographical validation and strict MFA verification at the perimeter.
Applies to: All domain user accounts attempting remote network access.
Validation: Initiate a remote VPN access session from an unapproved location segment or new geographies; confirm that an immediate step-up MFA challenge issues or an explicit block event is registered in the central sign-in logs.

HRD-004: Windows Credential Guard
Control: Windows Credential Guard local security authority subsystem isolation
Closes: GAP-008

Configuration:
GPO Path: Computer Configuration > Administrative Templates > System > Device Guard
Enablement Path: Turn On Virtualization Based Security > Set to Enabled with UEFI Lock configuration enabled.

Windows versions: This capability is natively supported on Windows 10 Enterprise, Windows 11 Enterprise, and Windows Server 2016/2019/2022/2026 deployment frames.
Effect: Uses virtualization-based security to run LSASS inside an isolated hypervisor-protected memory container, preventing local credential harvesting tools from extracting raw identity hashes and tokens.
Applies to: All physical and virtual Windows Enterprise infrastructure nodes.
Validation: Execute the command Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard from an elevated prompt and verify that SecurityServicesRunning indicates that Credential Guard is active.
