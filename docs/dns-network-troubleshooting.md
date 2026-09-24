# DNS and Network Troubleshooting

## Objective

Demonstrate a structured troubleshooting method for separating basic IP connectivity from DNS and Active Directory service discovery.

## Healthy Baseline

The workstation baseline was verified before introducing the fault.

```text
LAB-PC01
IPv4: 10.10.10.20
DNS: 10.10.10.10

LAB-DC01
IPv4: 10.10.10.10
Domain: corp.lucalab.test
```

Healthy-state tests showed:

- `LAB-DC01.corp.lucalab.test` resolved to `10.10.10.10`
- `nltest /dsgetdc:corp.lucalab.test` located `LAB-DC01`
- `Test-ComputerSecureChannel -Verbose` returned `True`

## Fault Injection

The workstation DNS server was deliberately changed from:

```text
10.10.10.10
```

to:

```text
10.10.10.99
```

No changes were made to:

- the workstation IP address
- subnet mask
- VirtualBox network
- domain membership
- domain-controller IP address

This isolated DNS as the variable under test.

## Broken-State Results

### Layer 3 connectivity

```powershell
Test-Connection 10.10.10.10 -Count 2
```

Result: successful.

This showed that the workstation could still reach the domain controller at the IP layer.

### DNS resolution

```powershell
Resolve-DnsName LAB-DC01.corp.lucalab.test
```

Result: timeout.

### SMB by IP

```powershell
Test-NetConnection 10.10.10.10 -Port 445
```

Result:

```text
TcpTestSucceeded : True
```

### SMB by hostname

```powershell
Test-NetConnection LAB-DC01.corp.lucalab.test -Port 445
```

Result: name resolution failed.

This clearly separated network reachability from name resolution.

### Group Policy

```powershell
gpupdate /force
```

Both computer and user policy processing failed because Windows could not resolve the required domain names.

### Domain-controller locator nuance

```powershell
nltest /dsgetdc:corp.lucalab.test
```

still returned `LAB-DC01`.

This result should not be treated as proof that current DNS is working. In this test, it was consistent with cached domain-controller locator information already available on the workstation.

## Diagnosis

The key pattern was:

```text
IP address works
Hostname fails
TCP 445 by IP works
TCP 445 by FQDN fails
Group Policy fails
```

That pattern points toward DNS rather than a general connectivity failure.

The workstation configuration confirmed the incorrect DNS server:

```text
10.10.10.99
```

## Resolution

DNS was restored to the domain controller:

```powershell
Set-DnsClientServerAddress `
  -InterfaceAlias "Ethernet" `
  -ServerAddresses "10.10.10.10"
```

The DNS resolver cache was cleared:

```powershell
ipconfig /flushdns
```

## Restored-State Verification

After the correction:

```powershell
Resolve-DnsName LAB-DC01.corp.lucalab.test
```

returned:

```text
10.10.10.10
```

```powershell
nltest /dsgetdc:corp.lucalab.test
```

successfully located `LAB-DC01`.

```powershell
gpupdate /force
```

completed successfully for both computer and user policy.

Finally:

```powershell
Test-ComputerSecureChannel -Verbose
```

returned:

```text
True
```

## Practical Troubleshooting Sequence

A useful order for this class of issue is:

1. verify the local IP configuration with `ipconfig /all`
2. test the server by IP
3. test DNS resolution separately
4. test the service by IP and then by hostname
5. inspect configured DNS servers
6. correct the DNS client settings
7. flush the resolver cache
8. retest DNS, domain services, Group Policy, and the secure channel

## Skills Demonstrated

- IPv4 troubleshooting
- DNS diagnosis
- Active Directory service discovery
- SMB connectivity testing
- Group Policy troubleshooting
- Windows domain secure-channel validation
- distinguishing cached discovery data from live DNS resolution
- structured fault isolation
