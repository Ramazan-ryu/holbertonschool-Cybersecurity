# Persistence Artifact Analysis: ART-001 (wst-ws-031.dd)

## Artifact verification
- **Artifact:** `wst-ws-031.dd`
- **Hash at analysis start:** a8f2c49c237024bdd0c176cb93063dc4e2a5e89d4aad51b3b3e4f7b72bce7e5e
- **CoC entry updated:** yes, ART-001 access logged at 2026-04-14T09:05Z

---

## Registry Hive Extraction and Mounting Context
To isolate persistence and execution vectors, the offline Windows registry hives were extracted from the mounted `wst-ws-031.dd` image. Forensic parsing was performed on the extracted `NTUSER.DAT` hive for user-specific configurations, the `SYSTEM` hive for system-wide execution caches, and the `Amcache.hve` file for binary installation metadata.

---

## Registry persistence

### ART-001-R01: Run / RunOnce startup entry
- **Key:** `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
- **Value name:** WindowsUpdateSvc
- **Value data:** `C:\Users\dmarsh\AppData\Local\Temp\update.exe`
- **Last write:** 2026-04-14T02:47:00Z
- **Significance:** Startup persistence established via the HKCU Run and RunOnce keys inside the extracted `NTUSER.DAT` registry hive for the `dmarsh` user profile.
- **Evidence ID:** ART-001-R01

### ART-001-R02: Automated Task Configuration
- **Key:** `C:\Windows\System32\Tasks\MSBuild_Update`
- **Value name:** MSBuild_Update
- **Value data:** `msbuild.exe C:\Users\dmarsh\AppData\Local\Temp\update.xml`
- **Last write:** 2026-04-14T02:48:00Z
- **Significance:** This malicious scheduled task is configured in an XML document. Parsing this scheduled task file reveals specific configuration parameters detailing execution triggers, actions, and the context of the principal user.
- **Evidence ID:** ART-001-R02

---

## Execution evidence

### ART-001-E01: UserAssist tracking
- **Key:** `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}\Count`
- **Value name:** `MSBuild.exe`
- **Value data:** Run count: 1, Last executed: 2026-04-14T02:47:00Z
- **Last write:** 2026-04-14T02:47:00Z
- **Significance:** Decoded UserAssist execution evidence within the `NTUSER.DAT` registry hive tracking interactive application launcher counters for the `dmarsh` user account.
- **Evidence ID:** ART-001-E01

### ART-001-E02: ShimCache / AppCompatCache profiles
- **Key:** `SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache`
- **Value name:** `update.exe`
- **Value data:** Execution metrics recorded in the engine database.
- **Last write:** 2026-04-14T02:46:00Z
- **Significance:** ShimCache / AppCompatCache structures parsed from the system-wide `SYSTEM` hive to map out an ordered sequence of executables and execution context verified on the operating system without traditional log footprints.
- **Evidence ID:** ART-001-E02

### ART-001-E03: Amcache execution timestamps
- **Key:** `C:\Windows\AppCompat\Programs\Amcache.hve`
- **Value name:** `update.exe`
- **Value data:** Tracking records mapped to first execution parameters and SHA-1 values.
- **Last write:** 2026-04-14T02:46:00Z
- **Significance:** Low-level timeline profiling from the independent `Amcache.hve` hive identifying first execution timestamps for unverified binaries, indexed uniquely by SHA-1 hash attributes.
- **Evidence ID:** ART-001-E03

### ART-001-E04: Recent LNK tracking records
- **Key:** `C:\Users\dmarsh\AppData\Roaming\Microsoft\Windows\Recent\`
- **Value name:** `update.xml.lnk`
- **Value data:** Shortcut properties indicating specific LNK targets opened by the profile.
- **Last write:** 2026-04-13T18:14:00Z
- **Significance:** Shortcut metrics located in the `Recent` directory identifying file system LNK targets and folders opened explicitly by the `dmarsh` user before and during the security compromise.
- **Evidence ID:** ART-001-E04
