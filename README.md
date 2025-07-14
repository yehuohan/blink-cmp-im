# blink-cmp-im

Input Method source.

<div align="center">
<img alt="blink-cmp-im" src="im.gif" style="width:75%; height:auto;" />
</div>

## Setup

- Defaults configuration

```lua
local cmp_im = require('blink_cmp_im')
cmp_im.setup({
  -- Enable/Disable IM
  enable = false,
  -- IM tables path array
  tables = { },
  -- IM symbols table<char, char|char[]>
  symbols = { },
  -- Function to format IM-key and IM-tex for completion display
  format = function(key, text) return vim.fn.printf('%-15S %s', text, key) end,
  -- Max number entries to show for completion of each table
  maxn = 10,
})

require('blink.cmp').setup({
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'im' },
    providers = {
        im = { name = 'IM', module = 'blink_cmp_im' },
    }
  }
})
```

- Enable/Disable IM

```lua
vim.keymap.set({'n', 'v', 'c', 'i'}, '<M-;>', function()
  vim.notify(string.format('IM is %s', cmp_im.toggle() and 'enabled' or 'disabled'))
end)
```

## Tables

Table is a plain text file, where each line is a Im-key with one or multiple IM-texts that splited with whitespace character (`<Space>` or `<Tab>`) like below.

> blink-cmp-im has a better performance with IM-key being ascending order, which can be done with `:sort`.

```
a 阿 啊 呵 腌 嗄 锕 吖 錒
```

Here is some table-repos for you:

- [cmp-im-zh](https://github.com/yehuohan/cmp-im-zh): Chinese input with wubi, pinyin
- [ZSaberLv0/ZFVimIM#db-samples](https://github.com/ZSaberLv0/ZFVimIM#db-samples)
- [fcitx-table-extra](https://github.com/fcitx/fcitx-table-extra)
- [fcitx-table-data](https://github.com/fcitx/fcitx-table-data)


## Symbols

Symbols is a table for punctuation completion like below.

```lua
{
  [","] = "，",
  ["'"] = { "‘", "’" }
}
```
