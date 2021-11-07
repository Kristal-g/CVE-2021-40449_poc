# CVE-2021-40449
More info here: [https://kristal-g.github.io/2021/11/05/CVE-2021-40449_POC.html](https://kristal-g.github.io/2021/11/05/CVE-2021-40449_POC.html)

## Compiling
I did a bit of a hack with the MinHook library so it supports (somewhat partially) the 2019 Platform Toolset.  
That's why I included the lib files with this repo.  
  
## Windows Version Adapting
To adapt this repo to another Windows build you have to fix:
* ntoskrnl.exe gadgets offsets for the rop chain
* `MiGetPteAddress` offset in ntoskrnl.exe
* The size of palettes, according to the (undocumented) size of `PDEVOBJ` (look at `win32kbase!PDEV::Allocate`)
* Shellcode offsets of various structs (`shellcode_offsets` struct)
