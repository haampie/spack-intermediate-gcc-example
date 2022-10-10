# Simple(r) example of dependencies across spack environments

Run

```
make -j$(nproc)
```

to build a compiler in `./store-1` using system compiler, and another compiler
in `./store-2` using the compiler of `./store-1`.

This is useful if the system compiler can't directly build the latest GCC.

```
make clean
```

removes all intermediate files, but does not remove stores.

This `Makefile` is supposed to be somewhat human readable.
