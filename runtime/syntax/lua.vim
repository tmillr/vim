" Vim syntax file
" Language:     Lua 4.0, Lua 5.0, Lua 5.1, Lua 5.2 and Lua 5.3
" Maintainer:   Marcus Aurelius Farias <masserahguard-lua 'at' yahoo com>
" First Author: Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:  2023 Jul 19
" Options:      lua_version = 4 or 5
"               lua_subversion = 0 (for 4.0 or 5.0)
"                               or 1, 2, 3 (for 5.1, 5.2 or 5.3)
"               the default is 5.3

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("lua_version")
  " Default is lua 5.3
  let lua_version = 5
  let lua_subversion = 3
elseif !exists("lua_subversion")
  " lua_version exists, but lua_subversion doesn't. In this case set it to 0
  let lua_subversion = 0
endif

syn case match

" syncing method
syn sync minlines=1000

if lua_version >= 5
  syn keyword luaMetaMethod __add __sub __mul __div __pow __unm __concat
  syn keyword luaMetaMethod __eq __lt __le
  syn keyword luaMetaMethod __index __newindex __call
  syn keyword luaMetaMethod __metatable __mode __gc __tostring
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  syn keyword luaMetaMethod __mod __len
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaMetaMethod __pairs
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 3)
  syn keyword luaMetaMethod __idiv __name
  syn keyword luaMetaMethod __band __bor __bxor __bnot __shl __shr
endif

if lua_version > 5 || (lua_version == 5 && lua_subversion >= 4)
  syn keyword luaMetaMethod __close
endif

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks

syn region luaParen transparent start='(' end=')' contains=TOP,luaParenError
syn match  luaParenError ")"
syn match  luaError "}"
syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" Function declaration
syn region luaFunctionBlock transparent matchgroup=luaFunctionKeyword start="\<function\>" end="\<end\>" contains=TOP

" else
syn keyword luaCondElse matchgroup=luaCond contained containedin=luaCondEnd else

" then ... end
syn region luaCondEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=TOP

" elseif ... then
syn region luaCondElseif contained containedin=luaCondEnd transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=TOP

" if ... then
syn region luaCondStart transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4 contains=TOP nextgroup=luaCondEnd skipwhite skipempty

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>" contains=TOP
" repeat ... until
syn region luaRepeatBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>" contains=TOP

" while ... do
syn region luaWhile transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=TOP nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaFor transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2 contains=TOP nextgroup=luaBlock skipwhite skipempty

syn keyword luaFor contained containedin=luaFor in

" other keywords
syn keyword luaStatement return local break
if lua_version > 5 || (lua_version == 5 && lua_subversion >= 2)
  syn keyword luaStatement goto
  syn match luaLabel "::\I\i*::"
endif

" operators
syn keyword luaOperator and or not

if (lua_version == 5 && lua_subversion >= 3) || lua_version > 5
  syn match luaSymbolOperator "[#<>=~^&|*/%+-]\|\.\{2,3}"
elseif lua_version == 5 && (lua_subversion == 1 || lua_subversion == 2)
  syn match luaSymbolOperator "[#<>=~^*/%+-]\|\.\{2,3}"
else
  syn match luaSymbolOperator "[<>=~^*/+-]\|\.\{2,3}"
endif

" comments
syn keyword luaTodo            contained TODO FIXME XXX
syn match   luaComment         "--.*$" contains=luaTodo,@Spell
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]"
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  " Comments in Lua 5.1: --[[ ... ]], [=[ ... ]=], [===[ ... ]===], etc.
  syn region luaComment        matchgroup=luaCommentDelimiter start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
endif

" first line may start with #!
syn match luaComment "\%^#!.*"

syn keyword luaConstant nil
if lua_version > 4
  syn keyword luaConstant true false
endif

" strings
syn match  luaSpecial contained #\\[\\abfnrtv'"[\]]\|\\[[:digit:]]\{,3}#
if lua_version == 5
  if lua_subversion == 0
    syn region luaString2 matchgroup=luaStringDelimiter start=+\[\[+ end=+\]\]+ contains=luaString2,@Spell
  else
    if lua_subversion >= 2
      syn match  luaSpecial contained #\\z\|\\x[[:xdigit:]]\{2}#
    endif
    if lua_subversion >= 3
      syn match  luaSpecial contained #\\u{[[:xdigit:]]\+}#
    endif
    syn region luaString2 matchgroup=luaStringDelimiter start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
  endif
endif
syn region luaString matchgroup=luaStringDelimiter start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString matchgroup=luaStringDelimiter start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

" integer number
syn match luaNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match luaNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\="
" floating point number, starting with a dot, optional exponent
syn match luaNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match luaNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
if lua_version >= 5
  if lua_subversion == 1
    syn match luaNumber "\<0[xX]\x\+\>"
  elseif lua_subversion >= 2
    syn match luaNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
  endif
endif

" tables
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=TOP,luaStatement

" methods
syntax match luaFunction ":\@<=\k\+"

" built-in functions
syn keyword luaFunction assert collectgarbage dofile error next
syn keyword luaFunction print rawget rawset self tonumber tostring type _VERSION

if lua_version == 4
  syn keyword luaFunction _ALERT _ERRORMESSAGE gcinfo
  syn keyword luaFunction call copytagmethods dostring
  syn keyword luaFunction foreach foreachi getglobal getn
  syn keyword luaFunction gettagmethod globals newtag
  syn keyword luaFunction setglobal settag settagmethod sort
  syn keyword luaFunction tag tinsert tremove
  syn keyword luaFunction _INPUT _OUTPUT _STDIN _STDOUT _STDERR
  syn keyword luaFunction openfile closefile flush seek
  syn keyword luaFunction setlocale execute remove rename tmpname
  syn keyword luaFunction getenv date clock exit
  syn keyword luaFunction readfrom writeto appendto read write
  syn keyword luaFunction PI abs sin cos tan asin
  syn keyword luaFunction acos atan atan2 ceil floor
  syn keyword luaFunction mod frexp ldexp sqrt min max log
  syn keyword luaFunction log10 exp deg rad random
  syn keyword luaFunction randomseed strlen strsub strlower strupper
  syn keyword luaFunction strchar strrep ascii strbyte
  syn keyword luaFunction format strfind gsub
  syn keyword luaFunction getinfo getlocal setlocal setcallhook setlinehook
elseif lua_version == 5
  syn keyword luaFunction getmetatable setmetatable
  syn keyword luaFunction ipairs pairs
  syn keyword luaFunction pcall xpcall
  syn keyword luaFunction _G loadfile rawequal require
  if lua_subversion == 0
    syn keyword luaFunction getfenv setfenv
    syn keyword luaFunction loadstring unpack
    syn keyword luaFunction gcinfo loadlib LUA_PATH _LOADED _REQUIREDNAME
  else
    syn keyword luaFunction load select
    syn match   luaFunction /\<package\.cpath\>/
    syn match   luaFunction /\<package\.loaded\>/
    syn match   luaFunction /\<package\.loadlib\>/
    syn match   luaFunction /\<package\.path\>/
    syn match   luaFunction /\<package\.preload\>/
    if lua_subversion == 1
      syn keyword luaFunction getfenv setfenv
      syn keyword luaFunction loadstring module unpack
      syn match   luaFunction /\<package\.loaders\>/
      syn match   luaFunction /\<package\.seeall\>/
    elseif lua_subversion >= 2
      syn keyword luaFunction _ENV rawlen
      syn match   luaFunction /\<package\.config\>/
      syn match   luaFunction /\<package\.preload\>/
      syn match   luaFunction /\<package\.searchers\>/
      syn match   luaFunction /\<package\.searchpath\>/
    endif

    if lua_subversion >= 3
      syn match luaFunction /\<coroutine\.isyieldable\>/
    endif
    if lua_subversion >= 4
      syn keyword luaFunction warn
      syn match luaFunction /\<coroutine\.close\>/
    endif
    syn match luaFunction /\<coroutine\.running\>/
  endif
  syn match   luaFunction /\<coroutine\.create\>/
  syn match   luaFunction /\<coroutine\.resume\>/
  syn match   luaFunction /\<coroutine\.status\>/
  syn match   luaFunction /\<coroutine\.wrap\>/
  syn match   luaFunction /\<coroutine\.yield\>/

  syn match   luaFunction /\<string\.byte\>/
  syn match   luaFunction /\<string\.char\>/
  syn match   luaFunction /\<string\.dump\>/
  syn match   luaFunction /\<string\.find\>/
  syn match   luaFunction /\<string\.format\>/
  syn match   luaFunction /\<string\.gsub\>/
  syn match   luaFunction /\<string\.len\>/
  syn match   luaFunction /\<string\.lower\>/
  syn match   luaFunction /\<string\.rep\>/
  syn match   luaFunction /\<string\.sub\>/
  syn match   luaFunction /\<string\.upper\>/
  if lua_subversion == 0
    syn match luaFunction /\<string\.gfind\>/
  else
    syn match luaFunction /\<string\.gmatch\>/
    syn match luaFunction /\<string\.match\>/
    syn match luaFunction /\<string\.reverse\>/
  endif
  if lua_subversion >= 3
    syn match luaFunction /\<string\.pack\>/
    syn match luaFunction /\<string\.packsize\>/
    syn match luaFunction /\<string\.unpack\>/
    syn match luaFunction /\<utf8\.char\>/
    syn match luaFunction /\<utf8\.charpattern\>/
    syn match luaFunction /\<utf8\.codes\>/
    syn match luaFunction /\<utf8\.codepoint\>/
    syn match luaFunction /\<utf8\.len\>/
    syn match luaFunction /\<utf8\.offset\>/
  endif

  if lua_subversion == 0
    syn match luaFunction /\<table\.getn\>/
    syn match luaFunction /\<table\.setn\>/
    syn match luaFunction /\<table\.foreach\>/
    syn match luaFunction /\<table\.foreachi\>/
  elseif lua_subversion == 1
    syn match luaFunction /\<table\.maxn\>/
  elseif lua_subversion >= 2
    syn match luaFunction /\<table\.pack\>/
    syn match luaFunction /\<table\.unpack\>/
    if lua_subversion >= 3
      syn match luaFunction /\<table\.move\>/
    endif
  endif
  syn match   luaFunction /\<table\.concat\>/
  syn match   luaFunction /\<table\.insert\>/
  syn match   luaFunction /\<table\.sort\>/
  syn match   luaFunction /\<table\.remove\>/

  if lua_subversion == 2
    syn match   luaFunction /\<bit32\.arshift\>/
    syn match   luaFunction /\<bit32\.band\>/
    syn match   luaFunction /\<bit32\.bnot\>/
    syn match   luaFunction /\<bit32\.bor\>/
    syn match   luaFunction /\<bit32\.btest\>/
    syn match   luaFunction /\<bit32\.bxor\>/
    syn match   luaFunction /\<bit32\.extract\>/
    syn match   luaFunction /\<bit32\.lrotate\>/
    syn match   luaFunction /\<bit32\.lshift\>/
    syn match   luaFunction /\<bit32\.replace\>/
    syn match   luaFunction /\<bit32\.rrotate\>/
    syn match   luaFunction /\<bit32\.rshift\>/
  endif

  syn match   luaFunction /\<math\.abs\>/
  syn match   luaFunction /\<math\.acos\>/
  syn match   luaFunction /\<math\.asin\>/
  syn match   luaFunction /\<math\.atan\>/
  if lua_subversion < 3
    syn match   luaFunction /\<math\.atan2\>/
  endif
  syn match   luaFunction /\<math\.ceil\>/
  syn match   luaFunction /\<math\.sin\>/
  syn match   luaFunction /\<math\.cos\>/
  syn match   luaFunction /\<math\.tan\>/
  syn match   luaFunction /\<math\.deg\>/
  syn match   luaFunction /\<math\.exp\>/
  syn match   luaFunction /\<math\.floor\>/
  syn match   luaFunction /\<math\.log\>/
  syn match   luaFunction /\<math\.max\>/
  syn match   luaFunction /\<math\.min\>/
  if lua_subversion == 0
    syn match luaFunction /\<math\.mod\>/
    syn match luaFunction /\<math\.log10\>/
  elseif lua_subversion == 1
    syn match luaFunction /\<math\.log10\>/
  endif
  if lua_subversion >= 1
    syn match luaFunction /\<math\.huge\>/
    syn match luaFunction /\<math\.fmod\>/
    syn match luaFunction /\<math\.modf\>/
    if lua_subversion == 1 || lua_subversion == 2
      syn match luaFunction /\<math\.cosh\>/
      syn match luaFunction /\<math\.sinh\>/
      syn match luaFunction /\<math\.tanh\>/
    endif
  endif
  syn match   luaFunction /\<math\.rad\>/
  syn match   luaFunction /\<math\.sqrt\>/
  if lua_subversion < 3
    syn match   luaFunction /\<math\.pow\>/
    syn match   luaFunction /\<math\.frexp\>/
    syn match   luaFunction /\<math\.ldexp\>/
  else
    syn match   luaFunction /\<math\.maxinteger\>/
    syn match   luaFunction /\<math\.mininteger\>/
    syn match   luaFunction /\<math\.tointeger\>/
    syn match   luaFunction /\<math\.type\>/
    syn match   luaFunction /\<math\.ult\>/
  endif
  syn match   luaFunction /\<math\.random\>/
  syn match   luaFunction /\<math\.randomseed\>/
  syn match   luaFunction /\<math\.pi\>/

  syn match   luaFunction /\<io\.close\>/
  syn match   luaFunction /\<io\.flush\>/
  syn match   luaFunction /\<io\.input\>/
  syn match   luaFunction /\<io\.lines\>/
  syn match   luaFunction /\<io\.open\>/
  syn match   luaFunction /\<io\.output\>/
  syn match   luaFunction /\<io\.popen\>/
  syn match   luaFunction /\<io\.read\>/
  syn match   luaFunction /\<io\.stderr\>/
  syn match   luaFunction /\<io\.stdin\>/
  syn match   luaFunction /\<io\.stdout\>/
  syn match   luaFunction /\<io\.tmpfile\>/
  syn match   luaFunction /\<io\.type\>/
  syn match   luaFunction /\<io\.write\>/

  syn match   luaFunction /\<os\.clock\>/
  syn match   luaFunction /\<os\.date\>/
  syn match   luaFunction /\<os\.difftime\>/
  syn match   luaFunction /\<os\.execute\>/
  syn match   luaFunction /\<os\.exit\>/
  syn match   luaFunction /\<os\.getenv\>/
  syn match   luaFunction /\<os\.remove\>/
  syn match   luaFunction /\<os\.rename\>/
  syn match   luaFunction /\<os\.setlocale\>/
  syn match   luaFunction /\<os\.time\>/
  syn match   luaFunction /\<os\.tmpname\>/

  syn match   luaFunction /\<debug\.debug\>/
  syn match   luaFunction /\<debug\.gethook\>/
  syn match   luaFunction /\<debug\.getinfo\>/
  syn match   luaFunction /\<debug\.getlocal\>/
  syn match   luaFunction /\<debug\.getupvalue\>/
  syn match   luaFunction /\<debug\.setlocal\>/
  syn match   luaFunction /\<debug\.setupvalue\>/
  syn match   luaFunction /\<debug\.sethook\>/
  syn match   luaFunction /\<debug\.traceback\>/
  if lua_subversion == 1
    syn match luaFunction /\<debug\.getfenv\>/
    syn match luaFunction /\<debug\.setfenv\>/
  endif
  if lua_subversion >= 1
    syn match luaFunction /\<debug\.getmetatable\>/
    syn match luaFunction /\<debug\.setmetatable\>/
    syn match luaFunction /\<debug\.getregistry\>/
    if lua_subversion >= 2
      syn match luaFunction /\<debug\.getuservalue\>/
      syn match luaFunction /\<debug\.setuservalue\>/
      syn match luaFunction /\<debug\.upvalueid\>/
      syn match luaFunction /\<debug\.upvaluejoin\>/
    endif
    if lua_subversion >= 4
      syn match luaFunction /\<debug.setcstacklimit\>/
    endif
  endif
endif

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link luaStatement        Statement
hi def link luaRepeat           Repeat
hi def link luaFor              Repeat
hi def link luaString           String
hi def link luaString2          String
hi def link luaStringDelimiter  luaString
hi def link luaNumber           Number
hi def link luaOperator         Operator
hi def link luaSymbolOperator   luaOperator
hi def link luaConstant         Constant
hi def link luaCond             Conditional
hi def link luaCondElse         Conditional
hi def link luaFunctionKeyword  luaStatement
hi def link luaMetaMethod       Function
hi def link luaComment          Comment
hi def link luaCommentDelimiter luaComment
hi def link luaTodo             Todo
hi def link luaTable            Structure
hi def link luaError            Error
hi def link luaParenError       Error
hi def link luaSpecial          SpecialChar
hi def link luaFunction         Function
hi def link luaLabel            Label


let b:current_syntax = "lua"

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: et ts=8 sw=2
