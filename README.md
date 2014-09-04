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

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)
