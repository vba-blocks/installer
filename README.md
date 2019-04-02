# vba-blocks Installer

## Install Latest Version

__Windows__

In powershell, run the following:

```shellsession
> iwr https://vba-blocks.com/install.ps1 | iex
```

__Mac__

In terminal, run the following:

```shellsession
$ curl -fsSL https://vba-blocks.com/install.sh | sh
```

For more recent versions of Office for Mac, you will need to trust access to the VBA project object model for vba-blocks to work correctly:

<details>
  <summary>Trust access to the VBA project object model</summary>
  <ol>
    <li>Open Excel</li>
    <li>Click "Excel" in the menu bar</li>
    <li>Select "Preferences" in the menu</li>
    <li>Click "Security" in the Preferences dialog</li>
    <li>Check "Trust access to the VBA project object model" in the Security dialog</li>
    <img src="./images/trust-access-VBOM.png">
 </ol>
</details>

## Install Specific Version

__Windows__

```shellsession
> iwr https://vba-blocks.com/install.ps1 -out install.ps1; .\install.ps1 v0.2.0
```

__Mac__

```shellsession
$ curl -fsSL https://vba-blocks.com/install.sh | sh -s v0.2.0
```

## Known Issues

<details>
  <summary>Could not create SSL/TLS secure channel</summary>

```
PS C:\> iwr https://vba-blocks.com/install.ps1 | iex
iwr : The request was aborted: Could not create SSL/TLS secure channel.
At line:1 char:1
+ iwr https://vba-blocks.com/install.ps1 | iex
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (System.Net.HttpWebRequest:HttpWebRequest) [Invoke-WebRequest], WebException
    + FullyQualifiedErrorId : WebCmdletWebResponseException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand
```

**When does this issue occur?**

If your systems' [ServicePointManager](https://docs.microsoft.com/en-us/dotnet/api/system.net.servicepointmanager.securityprotocol) is configured to use an out-dated security protocol, such as, TLS 1.0.

**How can this issue be fixed?**

Configure your system to use an up-to-date security protocol, such as, TLS 1.2:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
</details>

<details>
  <summary>Running scripts is disabled</summary>

```
PS C:\> iwr https://vba-blocks.com/install.ps1 -out install.ps1; .\install.ps1 v0.2.10
.\install.ps1 : File C:\install.ps1 cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:63
+ ... ://vba-blocks.com/install.ps1 -out install.ps1; .\install.ps1 v0.2.10
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

**When does this issue occur?**

If your systems' [ExecutionPolicy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) is `Undefined` or `Restricted`.

**How can this issue be fixed?**

Allow scripts that are downloaded from the internet to be executed by setting the execution policy to `RemoteSigned`:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```
</details>

---

_Based on the great work on [deno_install](https://github.com/denoland/deno_install)_