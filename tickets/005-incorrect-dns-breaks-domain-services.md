# Ticket 005 — Incorrect DNS Configuration Breaks Domain Services

## Reported Issue

A domain-joined workstation could still reach the domain controller by IP address, but name-based access and Group Policy processing failed.

## Environment

```text
LAB-PC01
IPv4: 10.10.10.20

LAB-DC01
IPv4: 10.10.10.10
DNS: 10.10.10.10
Domain: corp.lucalab.test
```

Healthy workstation DNS configuration:

```text
10.10.10.10
```

For the troubleshooting exercise, the workstation DNS server was deliberately changed to:

```text
10.10.10.99
```

## Symptoms

Raw IP connectivity to the domain controller continued to work:

```powershell
Test-Connection 10.10.10.10 -Count 2
```

Both ICMP requests succeeded with approximately 1 ms response time.

DNS resolution failed:

```powershell
Resolve-DnsName LAB-DC01.corp.lucalab.test
```

Result:

```text
This operation returned because the timeout period expired
```

SMB connectivity by IP also worked:

```powershell
Test-NetConnection 10.10.10.10 -Port 445
```

Result:

```text
TcpTestSucceeded : True
```

The same SMB test by FQDN failed because the hostname could not be resolved:

```powershell
Test-NetConnection LAB-DC01.corp.lucalab.test -Port 445
```

Result:

```text
Name resolution of LAB-DC01.corp.lucalab.test failed
```

Group Policy processing also failed:

```powershell
gpupdate /force
```

Windows reported that it could not resolve the computer name or user name.

## Important Observation

This command still returned the domain controller:

```powershell
nltest /dsgetdc:corp.lucalab.test
```

even while direct DNS resolution was failing.

This is consistent with Windows using previously cached domain-controller locator information. Therefore, a successful `nltest /dsgetdc` result by itself was not enough to prove that current DNS resolution was healthy.

The stronger evidence was the combination of:

```text
IP connectivity succeeds
DNS resolution fails
SMB by IP succeeds
SMB by name fails
Group Policy fails
```

## Root Cause

`LAB-PC01` was configured to use an incorrect DNS server:

```text
10.10.10.99
```

Active Directory depends heavily on DNS for locating domain services. Basic network connectivity remained available because the workstation and domain controller were still on the same IP network.

## Resolution

The workstation DNS server was restored:

```powershell
Set-DnsClientServerAddress `
  -InterfaceAlias "Ethernet" `
  -ServerAddresses "10.10.10.10"
```

The DNS client cache was then cleared:

```powershell
ipconfig /flushdns
```

## Verification

DNS resolution recovered:

```powershell
Resolve-DnsName LAB-DC01.corp.lucalab.test
```

Result:

```text
LAB-DC01.corp.lucalab.test -> 10.10.10.10
```

Domain-controller discovery succeeded:

```powershell
nltest /dsgetdc:corp.lucalab.test
```

Group Policy successfully updated:

```text
Computer Policy update has completed successfully.
User Policy update has completed successfully.
```

The computer secure channel was also verified:

```powershell
Test-ComputerSecureChannel -Verbose
```

Result:

```text
True
The secure channel between the local computer and the domain corp.lucalab.test is in good condition.
```

## Troubleshooting Logic

```text
Can the DC be reached by IP?
        |
       Yes
        |
        v
Can the DC be resolved by DNS?
        |
       No
        |
        v
Check workstation DNS configuration
        |
        v
Restore AD DNS server
        |
        v
Flush resolver cache
        |
        v
Retest DNS, Group Policy, and secure channel
```

## Skills Demonstrated

- TCP/IP troubleshooting
- DNS client configuration
- Active Directory DNS dependency
- `Resolve-DnsName`
- `Test-Connection`
- `Test-NetConnection`
- `nltest`
- Group Policy troubleshooting
- secure-channel verification
- root-cause isolation
