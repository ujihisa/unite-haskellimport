# unite-haskellimport

## Install
This plugin requires [unite.vim](https://github.com/Shougo/unite.vim) and [hoogle](http://hackage.haskell.org/package/hoogle).

You need to install hoogle and generate a local database

```shell
$ cabal update && cabal install hoogle && hoogle data
```

## Usage
Lanuch unite-haskellimport.

```vim
:Unite haskellimport
```

Input a function name and choose what you want to import.

![choose candidates](http://i.gyazo.com/cc8deb70ca681eed36fac482567a43aa.png)

Then, the import sentence is inserted at suitable position.

![inserted import](http://i.gyazo.com/f0db4517158a05721cb6def269065e33.png)

## Testing

* Use [themis](https://github.com/thinca/vim-themis)

```
$ themis ./test/haskellimport.vim
1..2
ok 1 - haskellimport import
ok 2 - haskellimport import_with_pragmas

# tests 2
# passes 2
```

## Authors

* Tatsuhiro Ujihisa
* Itchyny

## License

GPLv3 or any later version
