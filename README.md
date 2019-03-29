# vba-blocks CLI Installer

With PowerShell:

```shellsession
> iwr https://vba-blocks.com/install.ps1 | iex
```

With Shell:

```shellsession
$ curl -fsSL https://vba-blocks.com/install.sh | sh
```

## Directories

|       | Windows                                 | macOS
| --    | --                                      | --
| bin   | C:\Users\me\AppData\Roaming\vba-blocks\ | /Users/me/.local/bin/
| cache | C:\Users\me\AppData\Local\vba-blocks\   | /Users/me/Library/Caches/vba-blocks/

|       | Windows                    | macOS
| --    | --                         | --
| bin   | %appdata%\vba-blocks\      | $HOME/.local/bin/
| cache | %localappdata%\vba-blocks\ | $HOME/Library/Caches/vba-blocks/

Reference: [denoland/deno_install#40](https://github.com/denoland/deno_install/issues/40)
