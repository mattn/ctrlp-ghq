# ctrlp-ghq

CtrlP extension for `ghq list`. Default action is `lcd`.

![](http://go-gyazo.appspot.com/ceb199372928d194.png)

## Usage

```vim
:CtrlPGhq
```

If may add map into your vimrc like below: >

```vim
noremap <leader>g :<c-u>CtrlPGhq<cr>
```

## Customize

When you want to do custom action for the selected line, you can do it with
`<c-a>` key. It require following configuration:

```vim
let g:ctrlp_ghq_actions = [
\ {"label": "Open", "action": "e", "path": 1},
\ {"label": "Look", "action": "!ghq look", "path": 0},
\]
```

`label` is used for displaying menu. `action` is used for prefix string of
command to be called. `path` is used for checking whether the argument should
be full-path(1) or selected string(0).

You can change default action by following configuration:

```vim
let ctrlp_ghq_default_action = 'e'
```

If you don't set this, default action will do `lcd`.

You can enable cache function which stores repositories into cache file.

```vim
let g:ctrlp_ghq_cache_enabled = 1
```

* Press `<F5>` to purge the cache for the repositories under the `ghq.root` directory.

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)
