local utils = require('blink_cmp_im.utils')

--- Default options
local im_opts = {
    enable = false,
    tables = {},
    symbols = {},
    format = function(key, text)
        return vim.fn.printf('%-15S %s', text, key)
    end,
    maxn = 10,
}
--- All IM tables
local im_tbls = nil

--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new(opts)
    local self = setmetatable({}, { __index = source })
    return self
end

--- Setup IM's options
function source.setup(opts)
    im_opts = vim.tbl_deep_extend('keep', opts, im_opts)
end

--- Enable/Disable IM source
function source.toggle()
    im_opts.enable = not im_opts.enable
    return im_opts.enable
end

function source:enabled()
    return im_opts.enable
end

function source:get_trigger_characters()
    local chars = {}
    for k, _ in pairs(im_opts.symbols) do
        chars[#chars + 1] = k
    end
    return chars
end

local function load_tbls(files)
    if not im_opts.enable then
        return
    end
    if not im_tbls then
        im_tbls = {}
        for _, fn in ipairs(files) do
            local tbl = utils.load_tbl(fn)
            if tbl:valid() then
                im_tbls[#im_tbls + 1] = tbl
            else
                vim.notify(
                    string.format("Failed to load %s as cmp-im's table", fn),
                    vim.log.levels.WARN
                )
            end
        end
    end
end

--- Match completions from IM tables
--- @param ctx blink.cmp.Context
local function match_tbls(ctx)
    local res = {}
    if not im_tbls then
        return res
    end
    local pre = ctx.line:sub(1, ctx.cursor[2])

    local add_item = function(txt, key, val, len)
        local ofs = len or string.len(txt)
        res[#res + 1] = {
            label = im_opts.format(key, val),
            kind = require('blink.cmp.types').CompletionItemKind.Text,
            sortText = key,
            filterText = pre .. key,
            textEdit = {
                newText = val,
                range = {
                    ['start'] = {
                        line = ctx.cursor[1] - 1,
                        character = ctx.cursor[2] - ofs,
                    },
                    ['end'] = {
                        line = ctx.cursor[1] - 1,
                        character = ctx.cursor[2],
                    },
                },
            },
        }
    end

    local sym = vim.fn.strcharpart(pre, vim.fn.strcharlen(pre) - 1)
    local val = im_opts.symbols[sym]
    if val then
        if type(val) == 'table' then
            for _, v in ipairs(val) do
                add_item(sym, sym, v, 1)
            end
        else
            add_item(sym, sym, val, 1)
        end
    else
        local str = pre:match('%l+$')
        if str then
            for _, tbl in ipairs(im_tbls) do
                tbl:match(add_item, str, im_opts.maxn)
            end
        end
    end
    return res
end

--- @param ctx blink.cmp.Context
function source:get_completions(ctx, callback)
    load_tbls(im_opts.tables)

    -- local t0 = vim.fn.reltime()
    --- @type lsp.CompletionItem[]
    local items = match_tbls(ctx)
    -- vim.notify('Match elapsed: ' .. tostring(vim.fn.reltimestr(vim.fn.reltime(t0))))

    callback({
        items = items,
        is_incomplete_backward = true,
        is_incomplete_forward = true,
    })

    return function() end
end

return source
