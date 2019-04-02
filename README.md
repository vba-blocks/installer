# vba-blocks CLI Installer

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

## Directories

|       | Windows                                 | macOS
| --    | --                                      | --
| lib   | C:\Users\me\AppData\Roaming\vba-blocks\ | /Users/me/Library/Application Support/vba-blocks
| cache | C:\Users\me\AppData\Local\vba-blocks\   | /Users/me/Library/Caches/vba-blocks/

|       | Windows                    | macOS
| --    | --                         | --
| lib   | %appdata%\vba-blocks\      | $HOME/Library/Application Support/vba-blocks
| cache | %localappdata%\vba-blocks\ | $HOME/Library/Caches/vba-blocks/

References:
- [denoland/deno_install#40](https://github.com/denoland/deno_install/issues/40)
- [macOS Standard Directories](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW6)
