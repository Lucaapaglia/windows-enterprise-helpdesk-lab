# Ticket 005 · The server answers by IP, but Group Policy fails

On the Windows 11 workstation `LAB-PC01`, Group Policy stopped updating and the file server's name would not resolve. The domain controller still answered by IP. I reproduced this in the lab by changing only the workstation's DNS server from `10.10.10.10` to `10.10.10.99`.

## What narrowed it down

The domain controller `LAB-DC01` provides DNS and file sharing for `corp.lucalab.test`. These checks were run from the affected workstation, `10.10.10.20`.

| Check | Result during the fault |
| --- | --- |
| `Test-Connection 10.10.10.10 -Count 2` | Both requests succeeded, about 1 ms each. |
| `Test-NetConnection 10.10.10.10 -Port 445` | `TcpTestSucceeded` was `True`. The workstation could reach the server's SMB port. |
| `Resolve-DnsName LAB-DC01.corp.lucalab.test` | The lookup timed out. |
| `Test-NetConnection LAB-DC01.corp.lucalab.test -Port 445` | The hostname lookup failed before a connection could be made. |
| `gpupdate /force` | Windows reported that it could not resolve the names needed to apply policy. |

One result could have sent the investigation in the wrong direction. `nltest /dsgetdc:corp.lucalab.test` still returned `LAB-DC01`, consistent with a cached domain controller lookup. The direct DNS query timed out, and the workstation's DNS settings showed `10.10.10.99`.

[Captured failure output](../screenshots/10-dns-broken-state.svg)

## Resolution and checks after recovery

I restored the lab DNS server on the workstation's Ethernet adapter and cleared its resolver cache.

```powershell
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '10.10.10.10'
ipconfig /flushdns
```

| Check repeated on LAB-PC01 | Result after the change |
| --- | --- |
| `Resolve-DnsName LAB-DC01.corp.lucalab.test` | The name resolved to `10.10.10.10`. |
| `nltest /dsgetdc:corp.lucalab.test` | Domain controller discovery returned `LAB-DC01`. |
| `gpupdate /force` | Windows reported successful updates for both computer and user policy. |
| `Test-ComputerSecureChannel -Verbose` | Returned `True` for the workstation's channel to the domain. |

[Captured recovery output](../screenshots/11-dns-restored-state.svg) · [Network baseline and full lab notes](../docs/dns-network-troubleshooting.md)
