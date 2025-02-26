#Requires AutoHotkey v2.0
; Author: AshlenBin（B站号：@遥遥白草）
; Version: 1.0.1
; Date: 2025-02-25
; 更新1：在该版本中所有能被替换为字符的编码都会用字符代替，主要集中在希腊字母（比如\alpha会被替换为α）
; 更新2：combine联合映射不再有连击时间限制，去掉#号

linefeed := false ; 公式块内是否允许换行（幕布不允许换行）
combos_delay := -400 ; 按键连击的延迟时间，加负号是因为SetTimer的参数要求

if (!FileExist('config.ini')) { ; 初始化配置文件
    FileAppend(
        '[additional_functions]`nsimpleChar_mode = 0`n'
        '[temp_mapping]`nF1 = 0`nF2 = 0`nF3 = 0`nF4 = 0`nF5 = 0`nF6 = 0`nF7 = 0`nF8 = 0`nF9 = 0`nF10 = 0`nF11 = 0`nF12 = 0`n'
        , 'config.ini')
}

global exe_mode := 0
global temporary_latex := false
global CapsLock_is_being_pressed := false
global simpleChar_mode := IniRead('config.ini', 'additional_functions', 'simpleChar_mode')

; 不要试图给长按设置映射，会变得不幸
; 这是所有会参与映射的按键
input_keys := ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '[', '{', ']', '}', '\', '|', ';', ':', '`'', '`"', ',', '<', '.', '>', '/', '?',
    '``', '~', '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', '8', '*', '9', '(', '0', ')', '-', '_', '=', '+',
    'numpad0', 'numpad1', 'numpad2', 'numpad3', 'numpad4', 'numpad5', 'numpad6', 'numpad7', 'numpad8', 'numpad9',
    'numpadmult', 'numpadadd', 'numpadsub', 'numpaddot', 'numpaddiv', 'numpadenter',
    'insert', 'delete', 'home', 'end', 'pgup', 'pgdn', 'up', 'down', 'left', 'right',
    '+up', '+down', '+left', '+right',
    '^a', '^b', '^c', '^d', '^e', '^+f', '^f', '^g', '^h', '^i', '^j', '^k', '^l', '^m', '^n', '^o', '^p', '^q', '^r', '^s', '^t', '^u', '^v', '^w', '^x', '^y', '^z',
    '^[', '^]', '^;', '^`'', '^,', '^.', '^/',
    '^``', '^1', '^2', '^3', '^4', '^5', '^6', '^7', '^8', '^9', '^0', '^-', '^=',
    '+left', '+right', '+up', '+down',
    '+^9', '+^0', '+^[', '+^]',
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
    'LAlt', 'RAlt', 'LCtrl', 'RCtrl', 'space', 'tab',
]

def_keymapping() {
    global key_mapping := Map()
    ; 禁止映射的按键：
    ; '$': 在markdown里用于插入数学公式，所以不允许转义
    ; '\': 用于进入指令模式
    ; 'Ctrl'(单键): 常用于快捷键，不允许转义
    ; 连击映射中第一下禁止修改的按键：
    ; '@': 可以修改，但在指令模式下会强行转为@，因为用于标记变量
    ; '('和')': 用于在指令模式中分隔函数名和参数
    ; 所有的字母和数字
    ; '{'和'}': 在latex中有特殊意义的符号
    key_mapping['LAlt'] := ['(', ')']
    key_mapping['RAlt'] := ['+', '+\infty ']
    key_mapping['tab'] := ['\quad ']
    key_mapping['space'] := [' ', '\ ']
    key_mapping['+^9'] := ['\Big(', '\bigg(']
    key_mapping['+^0'] := ['\Big)', '\bigg)']
    key_mapping['+^['] := ['\Big[', '\bigg[']
    key_mapping['+^]'] := ['\Big]', '\bigg]']
    key_mapping['a'] := ['a', '\alpha ', '\partial ']
    key_mapping['A'] := ['A', '\forall ']
    key_mapping['b'] := ['b', '\beta ']
    key_mapping['B'] := 0 ; 0表示不设置连击映射
    key_mapping['c'] := ['c', '\theta ', '\vartheta ']
    key_mapping['C'] := ['C', '\Theta ']
    key_mapping['d'] := ['d', '\delta ']
    key_mapping['D'] := ['D', '\Delta ', '\nabla ']
    key_mapping['e'] := ['e', '\varepsilon ', '\epsilon ']
    key_mapping['E'] := ['E', '\exists ']
    key_mapping['f'] := ['f', '\varphi ', '\phi ']
    key_mapping['F'] := ['F', '\Phi ']
    key_mapping['g'] := ['g', '\gamma ']
    key_mapping['G'] := ['G', '\Gamma ']
    key_mapping['h'] := ['h', '\eta ', '\hbar ']
    key_mapping['H'] := 0
    key_mapping['i'] := ['i', '\iota ', '\imath ']
    key_mapping['I'] := 0
    key_mapping['j'] := ['j', '\jmath ']
    key_mapping['J'] := 0
    key_mapping['k'] := ['k', '\kappa ']
    key_mapping['K'] := 0
    key_mapping['l'] := ['l', '\lambda ', '\ell ']
    key_mapping['L'] := ['L', '\Lambda ']
    key_mapping['m'] := ['m', '\mu ']
    key_mapping['M'] := 0
    key_mapping['N'] := ['N', '\aleph ']
    key_mapping['o'] := ['o', '\circ ', '\bullet ', '\bigcirc '] ; 空心圆变实心圆,实心圆变大圆
    key_mapping['O'] := 0
    key_mapping['p'] := ['p', '\pi ', '\frac{\pi}{2}']
    key_mapping['P'] := ['P', '\Pi ']
    key_mapping['q'] := ['q']
    key_mapping['Q'] := 0
    key_mapping['r'] := ['r', '\rho ', '\varrho ']
    key_mapping['R'] := ['R', '\Rho ']
    key_mapping['s'] := ['s', '\sigma ', '\varsigma ']
    key_mapping['S'] := ['S', '\Sigma ']
    key_mapping['t'] := ['t', '\tau ']
    key_mapping['T'] := ['T', '\Gamma ']
    key_mapping['u'] := ['u', '\mu ']
    key_mapping['U'] := ['U', '\cup ']
    key_mapping['v'] := ['v', '\nu ', '\upsilon ']
    key_mapping['V'] := ['V', '\vee ', '\Upsilon ']
    key_mapping['w'] := ['w', '\omega ']
    key_mapping['W'] := ['W', '\Omega ']
    key_mapping['x'] := ['x', '\xi ']
    key_mapping['X'] := ['X', '\chi ']
    key_mapping['y'] := ['y', '\psi ']
    key_mapping['Y'] := ['Y', '\Psi ']
    key_mapping['z'] := ['z', '\zeta ']
    key_mapping['Z'] := 0

    key_mapping['`('] := ['`(', '\in ', '\subset ']
    key_mapping['`)'] := ['`)', '\left( $ \right)', pmatrix_on]
    key_mapping['['] := ['[', '\left[ $ \right]', bmatrix_on]
    key_mapping[']'] := [']', bmatrix_on]
    key_mapping['{'] := ['{', '\{ $ \} ', cases_on]
    key_mapping['}'] := ['}', cases_on]
    ; key_mapping['\'] := ['\','\backslash ']
    key_mapping['|'] := ['|', '\| ', vmatrix_on] ; '\left| $ \right| '
    ; key_mapping[';'] := []
    key_mapping[':'] := [':', '\because ', '\therefore ']
    key_mapping['`''] := ['`'']
    key_mapping['`"'] := ['\mathrm{$}']
    key_mapping[','] := [',', '\langle ', '\cdots ']
    key_mapping['<'] := ['<', '\leq ', '\ll ']
    key_mapping['.'] := ['.', '\rangle ', '\dots ']
    key_mapping['>'] := ['>', '\geq ', '\gg ']

    key_mapping['/'] := ['/', [send_frac, '/'], '\div ']
    ; 没有问号

    key_mapping['~'] := ['\sim ', '\approx ', '\widetilde{$} ']
    key_mapping['``'] := ['``', '^{-1}']
    key_mapping['1'] := ['1', '_1 ', '^1 ']
    key_mapping['2'] := ['2', '_2 ', '^2 ']
    key_mapping['3'] := ['3', '_3 ', '^3 ']
    key_mapping['4'] := ['4', '_4 ', '^4 ']
    key_mapping['5'] := ['5', '_5 ', '^5 ']
    key_mapping['6'] := ['6', '_6 ', '^6 ']
    key_mapping['7'] := ['7', '_7 ', '^7 ']
    key_mapping['8'] := ['8', '_8 ', '^8 ']
    key_mapping['9'] := ['9', '_9 ', '^9 ']
    key_mapping['0'] := ['0', '_0 ', '^0 ']
    key_mapping['n'] := ['n', '_n ', '^n ']

    key_mapping['!'] := ['!', '\lnot ', '\bar{$} ', '\overline{$}']
    key_mapping['@'] := ['\sqrt{$} ']
    key_mapping['#'] := ['\sharp ']
    key_mapping['%'] := ['\%', '\bmod ']
    key_mapping['^'] := ['\wedge ', '\cap ']
    key_mapping['&'] := ['&', '\land ', '\propto ']
    key_mapping['*'] := ['\cdot ', '\times ', '*']

    key_mapping['-'] := ['-', '-\infty ']
    key_mapping['_'] := ['\limits']
    key_mapping['+'] := ['+', '+\infty ']
    key_mapping['='] := ['=', '\iff ', '\equiv ']

    ; F1-F12的映射由用户自定义
    loop 12 {
        key_mapping['F' A_Index] := [IniRead('config.ini', 'temp_mapping', 'F' A_Index)]
    }

    key_mapping['up'] := ['^{$}']
    key_mapping['down'] := ['_{$}']
    ; key_mapping['left'] := 0
    ; key_mapping['right'] := 0
    ; key_mapping['+left'] := ['\gets ','\Leftarrow ']


    key_mapping['^``'] := ['\widetilde{$}']
    key_mapping['^6'] := ['\widehat{$}']
    key_mapping['^-'] := ['\underline{$}', '\overline{$}']
    key_mapping['^['] := ['\underbrace{$}', '\overbrace{$}']
    key_mapping['+left'] := ['\gets ', '\Leftarrow ']
    key_mapping['+right'] := ['\to ', '\Rightarrow ']
    key_mapping['+up'] := ['\uparrow ', '\Uparrow ']
    key_mapping['+down'] := ['\downarrow ', '\Downarrow ']
    key_mapping['^f'] := ['\int ', '\iint\limits_{$} ', '\iiint\limits_{$} ']
    key_mapping['^+f'] := ['\int_{$}^{$}']
    key_mapping['numpad0'] := ['0']
    key_mapping['numpad1'] := ['1']
    key_mapping['numpad2'] := ['2']
    key_mapping['numpad3'] := ['3']
    key_mapping['numpad4'] := ['4']
    key_mapping['numpad5'] := ['5']
    key_mapping['numpad6'] := ['6']
    key_mapping['numpad7'] := ['7']
    key_mapping['numpad8'] := ['8']
    key_mapping['numpad9'] := ['9']
    key_mapping['numpadadd'] := ['+', '\oplus ']
    key_mapping['numpaddiv'] := ['\div ', '\oslash ']
    key_mapping['numpadmult'] := ['\times ', '\otimes ']
    key_mapping['numpadsub'] := ['-', '\ominus ']
    key_mapping['numpadenter'] := ['=']
    key_mapping['numpaddot'] := ['.']


    ; 联合按键的映射
    ; 下列这几种编码的符号是一样的：['\rightarrow ','\to'],['\leftarrow ','\gets '],['\Longleftrightarrow ','\iff ']
    ; 请统一使用较短的那个，即['\to ','\gets ','\iff ']
    global combine_mapping := Map()
    combine_mapping['^{$}down'] := '_{$}^{$}'
    combine_mapping['_{$}up'] := '_{$}^{$}'
    combine_mapping['\gets +right'] := '\leftrightarrow '
    combine_mapping['\to +left'] := '\leftrightarrow '
    combine_mapping['\leftrightarrow up'] := '\xleftrightarrow{$} '
    combine_mapping['/='] := '\ne '
    ; combine_mapping['=/'] := '\ne ' 这个映射会和 =\cfrac{}{} 冲突
    combine_mapping['/~'] := '\nsim '
    combine_mapping['\sim /'] := '\nsim ' ; #表示无视连击时间限制
    combine_mapping['\in /'] := '\notin '
    combine_mapping['+-'] := '\pm '
    combine_mapping['-+'] := '\mp '
    combine_mapping['->'] := '\to '
    combine_mapping['=>'] := '\Rightarrow '
    combine_mapping['<='] := '\Leftarrow '
    combine_mapping['=.'] := '\frac{?}{\quad }\ '
    combine_mapping['.='] := '\frac{?}{\quad }\ '
    combine_mapping['\gets /'] := '\nleftarrow '
    combine_mapping['\to /'] := '\nrightarrow '
    combine_mapping['\gets up'] := '\xleftarrow{$}'
    combine_mapping['\to up'] := '\xrightarrow{$}'
    combine_mapping['\gets down'] := '\xleftarrow[$]{$}'
    combine_mapping['\to down'] := '\xrightarrow[$]{$}'
    combine_mapping['0/'] := '\emptyset '
    combine_mapping['\subset ='] := '\subseteq '
    combine_mapping['\supset ='] := '\supseteq '
    combine_mapping['\sim -'] := '\simeq '
    combine_mapping['-~'] := '\simeq '
    combine_mapping['\sim ='] := '\cong '
    combine_mapping['=~'] := '\cong '


    combine_mapping['ex'] := 'e^{x} '
    combine_mapping['\int ='] := '\overset{_{\int}\quad}{=}'
    combine_mapping['=up'] := '\xlongequal{$}'


    combine_mapping['dx'] := '\mathrm{d}x'
    combine_mapping['dy'] := '\mathrm{d}y'
    combine_mapping['dz'] := '\mathrm{d}z'
    combine_mapping['dt'] := '\mathrm{d}t'
    combine_mapping['du'] := '\mathrm{d}u'
    combine_mapping['dv'] := '\mathrm{dv}'
    combine_mapping['dr'] := '\mathrm{d}r'
    combine_mapping['\cdot O'] := '\odot '
    combine_mapping['\times O'] := '\otimes '
    combine_mapping['+O'] := '\oplus '
    combine_mapping['-O'] := '\ominus '
    combine_mapping['\div O'] := '\oslash '
    combine_mapping['/O'] := '\oslash '
    combine_mapping['\sharp 0'] := ['⓪']
    combine_mapping['\sharp 1'] := ['①']
    combine_mapping['\sharp 2'] := ['②']
    combine_mapping['\sharp 3'] := ['③']
    combine_mapping['\sharp 4'] := ['④']
    combine_mapping['\sharp 5'] := ['⑤']
    combine_mapping['\sharp 6'] := ['⑥']
    combine_mapping['\sharp 7'] := ['⑦']
    combine_mapping['\sharp 8'] := ['⑧']
    combine_mapping['\sharp 9'] := ['⑨']


    ; 点按shift切换映射
    global code_mapping := Map()
    code_mapping['d'] := '\mathrm{d}'
    code_mapping['\cdots '] := '\vdots '
    code_mapping['\dots '] := '\vdots '

    code_mapping['\bigvee '] := '\vee '
    code_mapping['\vee '] := '\bigvee '
    code_mapping['\bigwedge '] := '\wedge '
    code_mapping['\wedge '] := '\bigwedge '
    code_mapping['\bigcup '] := '\cup '
    code_mapping['\cup '] := '\bigcup '
    code_mapping['\bigcap '] := '\cap '
    code_mapping['\cap '] := '\bigcap '
    code_mapping['\pm '] := '\mp '
    code_mapping['\mp '] := '\pm '
    code_mapping['('] := ')'
    code_mapping[')'] := '('

    code_mapping['e^{x} '] := 'e^{-x} '

    code_mapping['\int '] := '\oint_{$} '
    code_mapping['\iint\limits_{$} '] := '\oiint\limits_{$} '
    code_mapping['\iiint\limits_{$} '] := '\oiiint\limits_{$} '

    code_mapping['\max '] := '\max\limits_{$} '
    code_mapping['\min '] := '\min\limits_{$} '
    code_mapping['\\ '] := '\\[1ex] '
    code_mapping['\\ `n'] := '\\[1ex] `n'
    combine_mapping['[]'] := '\Box '

    global text_mapping := Map()
    ; text_mapping的触发方式是，当你写下'arcs'，并紧跟了一个shift时，会自动替换为'\arcsin '
    ; text的长度不得小于2，中间不得有空格，开头和结尾允许有一个空格
    ; 不允许出现'\'
    ; 不能用Enter当快捷键，会和其它功能混淆

    text_mapping['if'] := '\mathrm{if\ }' ; 注意，code_mapping['d'] := '\mathrm{d}'写在了code_mapping里
    text_mapping['then'] := '\mathrm{then\ }'
    text_mapping['div'] := '\mathrm{div}'
    text_mapping['grad'] := '\mathrm{grad}'

    text_mapping['or'] := '\lor '
    text_mapping['and'] := '\land '
    text_mapping['not'] := '\lnot '
    text_mapping['in'] := '\in '
    text_mapping['xor'] := '\oplus '
    text_mapping['xnor'] := '\odot '

    text_mapping['inf'] := '\infty  '
    text_mapping['dim'] := '\dim '
    text_mapping['sin'] := '\sin '
    text_mapping['arcsin'] := '\arcsin '
    text_mapping['asin'] := '\arcsin '
    text_mapping['arcs'] := '\arcsin '
    text_mapping['cos'] := '\cos '
    text_mapping['arccos'] := '\arccos '
    text_mapping['acos'] := '\arccos '
    text_mapping['arcc'] := '\arccos '
    text_mapping['tan'] := '\tan '
    text_mapping['arctan'] := '\arctan '
    text_mapping['atan'] := '\arctan '
    text_mapping['arct'] := '\arctan '
    text_mapping['cot'] := '\cot '
    text_mapping['sec'] := '\sec '
    text_mapping['csc'] := '\csc '
    text_mapping['sinh'] := '\sinh '
    text_mapping['cosh'] := '\cosh '
    text_mapping['tanh'] := '\tanh '
    text_mapping['coth'] := '\coth '
    text_mapping['ln'] := '\ln '
    text_mapping['log'] := '\log _{$}'
    text_mapping['sqrt3'] := '\sqrt[3]{$}'
    text_mapping['sqrtn'] := '\sqrt[n]{$}'
    text_mapping['sqrt'] := '\sqrt[$]{$}'
    text_mapping['lim'] := '\lim\limits_{$\to $}'
    text_mapping['lim8'] := '\lim\limits_{$ \to \infty}'

    text_mapping['lim0'] := '\lim\limits_{$ \to 0}'
    text_mapping['limx'] := '\lim\limits_{x\to $}'
    text_mapping['limn'] := '\lim\limits_{n\to $}'
    text_mapping['sum'] := '\sum\limits_{$}^{$}'
    text_mapping['sum8'] := '\sum\limits_{n=$}^{\infty}'
    text_mapping['mult'] := '\prod\limits_{$}^{$}'
    text_mapping['mult '] := '\prod\limits_{n=1}^{\infty}'

    text_mapping['vec'] := '\vec{$}'
    text_mapping['max'] := '\max '
    text_mapping['min'] := '\min '
    text_mapping['argmax'] := '\argmax '
    text_mapping['argmin'] := '\argmin '

    text_mapping['sa'] := [send_frac, 'shift', 'sin x', 'x']
    text_mapping['fx'] := 'f(x)'
    text_mapping['gx'] := 'g(x)'
    text_mapping['hx'] := 'h(x)'

    text_mapping['p/p'] := [send_frac, 'shift', '\partial $', '\partial $']
    ; 此处有bug：因为在字母背后输入数字会自动转下标，所以这段映射永远无法触发，除非用小键盘
    text_mapping['xy2'] := 'x^{2}+y^{2}'
    text_mapping['xyz2'] := 'x^{2}+y^{2}+z^{2}'
    text_mapping['xyz'] := '(x,y,z)'
    text_mapping['`'='] := '\overset{_{`'}\quad }{=}'
    ; 如果你害怕误触发，就在开头加上空格text_mapping[' sec'] := '\sec '

}

def_simple_keymapping() {
    key_mapping['RAlt'] := ['+', '+∞']
    key_mapping['a'] := ['a', 'α', '∂']
    key_mapping['A'] := ['A', '∀']
    key_mapping['b'] := ['b', 'β']
    key_mapping['B'] := 0   ; 0表示不设置连击映射
    key_mapping['c'] := ['c', 'θ', 'ϑ']
    key_mapping['C'] := ['C', 'Θ']
    key_mapping['d'] := ['d', 'δ']
    key_mapping['D'] := ['D', 'Δ', '∇']
    key_mapping['e'] := ['e', 'ε', '\epsilon']
    key_mapping['E'] := ['E', '∃']
    key_mapping['f'] := ['f', 'φ', 'ϕ']  ; 这里的ϕ实际上是φ，φ实际上是ϕ，是字体的问题
    key_mapping['F'] := ['F', 'Φ']
    key_mapping['g'] := ['g', 'γ']
    key_mapping['G'] := ['G', 'Γ']
    key_mapping['h'] := ['h', 'η', 'ħ']
    key_mapping['H'] := 0
    key_mapping['i'] := ['i', 'ι', '\imath ']
    key_mapping['I'] := 0
    key_mapping['j'] := ['j', '\jmath ']
    key_mapping['J'] := 0
    key_mapping['k'] := ['k', 'κ']
    key_mapping['K'] := 0
    key_mapping['l'] := ['l', 'λ', 'ℓ']
    key_mapping['L'] := ['L', 'Λ']
    key_mapping['m'] := ['m', 'μ']
    key_mapping['M'] := 0
    key_mapping['N'] := ['N', 'ℵ']
    key_mapping['o'] := ['o', '∘', '\bullet ', '\bigcirc '] ; 空心圆变实心圆,实心圆变大圆
    key_mapping['O'] := 0
    key_mapping['p'] := ['p', 'π', '\frac{π}{2}']
    key_mapping['P'] := ['P', 'Π']
    key_mapping['q'] := ['q']
    key_mapping['Q'] := 0
    key_mapping['r'] := ['r', 'ρ', 'ϱ']
    key_mapping['R'] := ['R', 'Ρ']
    key_mapping['s'] := ['s', 'σ', 'ς']
    key_mapping['S'] := ['S', 'Σ']
    key_mapping['t'] := ['t', 'τ']
    key_mapping['T'] := ['T', 'Γ']
    key_mapping['u'] := ['u', 'μ']
    key_mapping['U'] := ['U', '∪']
    key_mapping['v'] := ['v', 'ν', 'υ']
    key_mapping['V'] := ['V', '∨', 'Υ']
    key_mapping['w'] := ['w', 'ω']
    key_mapping['W'] := ['W', 'Ω']
    key_mapping['x'] := ['x', 'ξ']
    key_mapping['X'] := ['X', 'χ']
    key_mapping['y'] := ['y', 'ψ']
    key_mapping['Y'] := ['Y', 'Ψ']
    key_mapping['z'] := ['z', 'ζ']
    key_mapping['Z'] := 0

    key_mapping['`('] := ['`(', '∈', '⊂']
    key_mapping[':'] := [':', '∵', '∴']
    key_mapping[','] := [',', '⟨', '⋯']
    key_mapping['<'] := ['<', '≤', '≪']
    key_mapping['.'] := ['.', '⟩', '\dots ']
    key_mapping['>'] := ['>', '≥', '≫']
    key_mapping['/'] := ['/', [send_frac, '/'], '÷']
    ; 没有问号∝

    key_mapping['~'] := ['\sim ', '≈', '\widetilde{$} ']

    key_mapping['!'] := ['!', '¬', '\bar{$} ', '\overline{$}']
    key_mapping['@'] := ['\sqrt{$} ']
    key_mapping['%'] := ['\%', '\bmod ']
    key_mapping['^'] := ['∧', '∩']
    key_mapping['&'] := ['&', '∧', '∝']
    key_mapping['*'] := ['⋅', '×', '*']

    key_mapping['-'] := ['-', '-∞']
    key_mapping['_'] := ['\limits']
    key_mapping['+'] := ['+', '+∞']
    key_mapping['='] := ['=', '⟺', '≡']

    key_mapping['+left'] := ['←', '⇐']
    key_mapping['+right'] := ['→', '⇒']
    key_mapping['+up'] := ['↑', '\Uparrow ']
    key_mapping['+down'] := ['↓', '\Downarrow ']
    key_mapping['^f'] := ['∫', '∬\limits_{$} ', '∭\limits_{$} ']
    key_mapping['^+f'] := ['∫_{$}^{$}']

    key_mapping['numpadadd'] := ['+', '⊕']
    key_mapping['numpaddiv'] := ['÷', '⊘']
    key_mapping['numpadmult'] := ['×', '⊗']
    key_mapping['numpadsub'] := ['-', '⊖']
    key_mapping['numpadenter'] := ['=']
    key_mapping['numpaddot'] := ['.']


    combine_mapping['←+right'] := '↔'
    combine_mapping['→+left'] := '↔'
    combine_mapping['↔up'] := '\xleftrightarrow{$} '
    combine_mapping['/='] := '≠'
    combine_mapping['/~'] := '≁'
    combine_mapping['\sim /'] := '≁'
    combine_mapping['∈/'] := '∉'
    combine_mapping['+-'] := '±'
    combine_mapping['-+'] := '∓'
    combine_mapping['->'] := '→'
    combine_mapping['=>'] := '⇒'
    combine_mapping['<='] := '⇐'
    combine_mapping['=.'] := '\frac{?}{\quad }\ '
    combine_mapping['.='] := '\frac{?}{\quad }\ '
    combine_mapping['←/'] := '\nleftarrow '
    combine_mapping['→/'] := '\nrightarrow '
    combine_mapping['←up'] := '\xleftarrow{$}'
    combine_mapping['←+up'] := '\xleftarrow{$}'
    combine_mapping['→up'] := '\xrightarrow{$}'
    combine_mapping['→+up'] := '\xrightarrow{$}'
    combine_mapping['←down'] := '\xleftarrow[$]{$}'
    combine_mapping['←+down'] := '\xleftarrow[$]{$}'
    combine_mapping['→down'] := '\xrightarrow[$]{$}'
    combine_mapping['→+down'] := '\xrightarrow[$]{$}'
    combine_mapping['0/'] := '∅'
    combine_mapping['⊂='] := '⊆'
    combine_mapping['⊃='] := '⊇'
    combine_mapping['\sim -'] := '≃'
    combine_mapping['-~'] := '≃'
    combine_mapping['\sim ='] := '≅'
    combine_mapping['=~'] := '≅'


    combine_mapping['ex'] := 'e^{x} '
    combine_mapping['∫='] := '\overset{_{∫}\quad}{=}'


    combine_mapping['⋅O'] := '⊙'
    combine_mapping['×O'] := '⊗'
    combine_mapping['+O'] := '⊕'
    combine_mapping['-O'] := '⊖'
    combine_mapping['\div O'] := '⊘'
    combine_mapping['/O'] := '⊘'
    ; 点按shift切换映射
    code_mapping['⋯'] := '\vdots '
    code_mapping['\dots '] := '\vdots '
    code_mapping['\bigvee '] := '∨'
    code_mapping['∨'] := '\bigvee '
    code_mapping['\bigwedge '] := '∧'
    code_mapping['∧'] := '\bigwedge '
    code_mapping['\bigcup '] := '∪'
    code_mapping['∪'] := '\bigcup '
    code_mapping['\bigcap '] := '∩'
    code_mapping['∩'] := '\bigcap '
    code_mapping['±'] := '∓'
    code_mapping['∓'] := '±'

    code_mapping['e^{x} '] := 'e^{-x} '

    code_mapping['∫'] := '∮_{$} '
    code_mapping['∬\limits_{$} '] := '∯\limits_{$} '
    code_mapping['∭\limits_{$} '] := '∰\limits_{$} '


    combine_mapping['[]'] := '□'

    text_mapping['or'] := '∨'
    text_mapping['and'] := '∧'
    text_mapping['not'] := '¬'
    text_mapping['in'] := '∈'
    text_mapping['xor'] := '⊕'
    text_mapping['xnor'] := '⊙'

    text_mapping['inf'] := '∞'
    text_mapping['lim'] := '\lim\limits_{$→$}'
    text_mapping['lim_8 '] := '\lim\limits_{$→∞}'
    ; 因为在字母背后输入数字会自动转下标，所以要写lim_0 (记得空格)，不能写lim0
    text_mapping['lim_0 '] := '\lim\limits_{$→0}'
    text_mapping['limx'] := '\lim\limits_{x→$}'
    text_mapping['limn'] := '\lim\limits_{n→$}'
    text_mapping['sum'] := '\sum\limits_{$}^{$}'
    text_mapping['sum_8 '] := '\sum\limits_{n=1}^{∞}'

    text_mapping['d/d'] := [send_frac, 'shift', '\mathrm{d}$', '\mathrm{d}$']
    text_mapping['p/p'] := [send_frac, 'shift', '∂$', '∂$']
    text_mapping['p/pp'] := [send_frac, 'shift', '∂^2 $', '∂$∂$']

}
if (simpleChar_mode) {
    def_simple_keymapping()
} else {
    def_keymapping()
}

global Cap_Status := GetKeyState("CapsLock", "T")
MarkdownStates() {
    global Cap_Status := GetKeyState("CapsLock", "T")
    if (Cap_Status) {
        for gui_ in MD_gui {
            WinSetAlwaysOnTop(1, gui_)
            WinSetTransparent(200, gui_)
        }
    }
    else {
        for gui_ in MD_gui {
            WinSetTransparent(0, gui_)
        }
        clear_all()
    }
}

global command_mode := command_mode_class()
create_gui() {
    global MD_gui := []
    MD_gui.text := []
    loop MonitorGetCount() {
        MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
        gui_ := Gui("+LastFound +AlwaysOnTop -Caption +ToolWindow")
        gui_.BackColor := "53372a"
        gui_.SetFont("cFFFFFF s22", "Segoe UI bold")
        MD_gui.text.Push(gui_.Add("Text", "x10 y5 w500 h60", "`tL a T e X"))
        WinSetTransparent(200, gui_)
        WinSetExStyle("+0x20", gui_)

        init_position := [Left, Top]
        gui_.Show("NA x" init_position[1] " y" init_position[2] ' w' 400 ' h' 50)
        real := real_xywh(gui_)
        init_position := [(Left + Right - real[3]) / 2, Top]
        gui_.Show("NA x" init_position[1] " y" init_position[2])

        MD_gui.Push(gui_)
    }

    try {
        A_TrayMenu.delete('&Open')
        A_TrayMenu.delete('&Window Spy')
        A_TrayMenu.delete('&Edit Script')
        A_TrayMenu.delete('&Pause Script')
    }

    A_TrayMenu.Add("简单字符模式", menu_func, 'P1')
    if (simpleChar_mode) {
        A_TrayMenu.Check("简单字符模式")
    }
}
create_gui()
MarkdownStates()

menu_func(ItemName, ItemPos, MyMenu) {
    if (ItemName = "简单字符模式") {
        global simpleChar_mode := !simpleChar_mode
        if (simpleChar_mode) {
            def_simple_keymapping()
            MyMenu.Check(ItemName)
        } else {
            def_keymapping()
            MyMenu.Uncheck(ItemName)
        }
        IniWrite(simpleChar_mode, 'config.ini', 'additional_functions', 'simpleChar_mode')
        return
    }
}

global matrix_mode := 0
cases_on() { ; 方程组
    global matrix_mode += 1
    send_text('{', '\begin{cases}`n$`n\end{cases}')
}
bmatrix_on() {   ; 矩阵，注意，在矩阵中用右键换列（不是用空格），用ctrl+回车换行
    global matrix_mode += 1
    ; 什么时候matrix_mode会等于2？当你在矩阵里面套矩阵的时候
    send_text('[', '\begin{bmatrix}`n$`n\end{bmatrix}')
}
pmatrix_on() {   ; 圆括号矩阵
    global matrix_mode += 1
    send_text('|', '\begin{pmatrix}`n$`n\end{pmatrix}')
}
vmatrix_on() {   ; 行列式
    global matrix_mode += 1
    send_backspace()
    send_text('|', '\begin{vmatrix}`n$`n\end{vmatrix}')
}
send_frac(key, a := '$', b := '$') {
    ; 因为分式有大小之分
    ; 在{}内应该用小分式（比如e^{\frac{1}{x}}）
    ; 在最外层应该用大分式
    ; 很多地方都要输入分式，所以交给这个函数接口
    if (IsInBrace()) { ; 在{}里用小分式
        send_text(key, '\frac{' a '}{' b '}', false)
    } else {
        if (exe_mode == "飞书") {
            send_text(key, '\frac{' a '}{' b '}', false)
        } else {
            send_text(key, '\cfrac{' a '}{' b '}', false)
        }
    }
}


ending_rightright() {
    ; \sqrt{\frac{1}{2|}} 编辑完成时光标落在括号里，还要多敲两下右键才能跳出来，所以我帮你按了
    ; 为什么不写在~CapsLock::里面？
    ; 因为这个功能只有在退出Markdown模式的时候才会触发，而在临时markdown模式下，按下Cap时无法判定是不是退出
    if (right_list.Length == 0) {
        OutputDebug('ending_rightright right_list.Length == 0')
        return
    }
    OutputDebug('ending_rightright')
    while right_list.Length {
        element := right_list.Pop()
        loop StrLen(element.text) {
            SendInput("{Right}")
        }
        OutputDebug("ending_rightright.text: " . element.text)
        left_list.Push(element)
        if (element.code == 'command_end') {
            return
        }
    }
}

global block_beginning := false
false_block_beginning() {
    global block_beginning := false
}
global latex_block_quote := Map()  ; 该变量用于『^b::为选中的文本添加公式块括号』
latex_block_quote["飞书"] := ['$$', '$$']
latex_block_quote["闪记卡"] := ['\(', '\)']
latex_block_quote["语雀"] := ['$', '$']

block_begin() {
    OutputDebug("exe_mode: " . exe_mode)
    global block_beginning := true

    if (exe_mode == "飞书") {
        if (temporary_latex) {
            SendText('$$')
            global block_beginning := false
            return
        }
        SendText('$$$$')
        SetTimer(false_block_beginning, -450)
    } else if (exe_mode == "闪记卡") {
        SendText('\(\)')
        Send('{Left}')
        Send('{Left}')
        global block_beginning := false
    } else if (exe_mode == "语雀") {
        SendText("$ $")
        SendInput('{Space}')
        SendInput('{Left}')
        global block_beginning := false
    } else {
        SendText(' $$ ')
        Send('{Left}')
        Send('{Left}')
        global block_beginning := false
    }


    return
}
block_end() {
    OutputDebug("block_end exe_mode: " . exe_mode)
    if send_texting { ; 不能使用sleep。loop sleep也不行，会把send_text也阻塞
        SetTimer(block_end, -100)
        return
    }
    if (exe_mode == "飞书") {
        if (temporary_latex) {
            SendText('$$')
            return
        }
        SendInput('{Space}')
        SendInput('{BackSpace}')
        SendInput('{Esc}')
    } else if (exe_mode == "闪记卡") {
        ending_rightright()
        SendInput('{Right}')
        SendInput('{Right}')
    } else if (exe_mode == "语雀") {
        ending_rightright()
        SendInput('{Right}')
    } else {
        ending_rightright()
        SendInput('{Right}')
        SendInput('{Right}')
    }
}

CapsLock:: {
    OutputDebug(A_Hour . ':' . A_Min . ':' . A_Sec)
    if (CapsLock_is_being_pressed) {
        OutputDebug('CapsLock_is_being_pressed')
        return
    }
    if (!Cap_Status) {
        SetCapsLockState(true)
        global CapsLock_is_being_pressed := true
        global temporary_latex := false
        MarkdownStates()
        OutputDebug('CapsLock :' . Cap_Status)
        return
    }
    if (command_mode.is_on) {   ; 关闭指令模式
        command_mode.set(false)
        OutputDebug('CapsLock(command):' . Cap_Status)
        return
    }
    SetCapsLockState(false)
    MarkdownStates()
    OutputDebug('CapsLock :' . Cap_Status)

}
CapsLock up:: {
    global CapsLock_is_being_pressed := false
    ; OutputDebug('temporary_latex: ' . temporary_latex)
    if (!temporary_latex) {
        return
    }
    ; 如果在按下到抬起的期间有任何其它文本被触发，一定会让temporary_latex变为true
    block_end()
    global temporary_latex := false
    ; if(GetKeyState("Shift", "P")){
    ;     return
    ; }

    SetCapsLockState(0)
    MarkdownStates()

    return
}

+CapsLock:: {
    if (Cap_Status) {
        SetCapsLockState(false)
        block_end()     ; MarkdownStates()会清空right_list导致block_end()执行出错，此处顺序切勿搞反
        MarkdownStates()
    } else {
        SetCapsLockState(true)
        MarkdownStates()
        block_begin()
    }
}
class text_code_key {
    __New(text, code := '', key := '') {
        this.key := key
        this.code := code
        this.text := text
    }
    ; 如果text非人为敲出（如$\frac{$}{$}里后面的括号），那么key和code==''
    ; !!! text不准放空! 不准text=''
    ; 而\frac{是人为敲出的，所以key='/',code='\frac{$}{$}'
}

global left_list := []
global right_list := []

to_left() {
    if (left_list.Length == 0) {
        return false
    }

    element := left_list.Pop()
    OutputDebug("to_left.text: " . element.text)
    OutputDebug("to_left.code: " . element.code)
    if (command_mode.is_on and element.code == 'command_func') {
        left_list.Push(element)
        return false
    }

    if (element.code == 'clipboard') {
        Send("{Left}")
        char := SubStr(element.text, StrLen(element.text), 1)
        rest := SubStr(element.text, 1, StrLen(element.text) - 1)
        right_list.Push(text_code_key(char, char, ''))
        if (rest != '') {
            left_list.Push(text_code_key(rest, 'clipboard', ''))
        }

        return true
    }
    if (InStr(element.text, '\end{')) {
        global matrix_mode += 1
    }
    loop StrLen(element.text) {
        Send("{Left}")
    }
    right_list.Push(element)
    return true
}
to_right(stop := '') {
    ; 返回值：
    ; 如果被stop阻止了，返回'stopped'
    ; 如果right_list为空，返回'empty'
    ; 如果成功移动，返回true
    if (right_list.Length == 0) {
        return 'empty'
    }
    element := right_list.Pop()
    OutputDebug("to_right.text: " . element.text)
    OutputDebug("to_right.code: " . element.code)
    if (element.code == 'clipboard') {
        loop element.text {
            Send("{Right}")
        }
        left_list.Push(element)
        return true
    }
    if (stop != '' and InStr(element.text, stop)) {
        right_list.Push(element)
        return 'stopped'
    }
    if (InStr(element.text, '\end{')) {
        OutputDebug('to_right : matrix_mode -=1 : ' . matrix_mode)
        global matrix_mode -= 1
    }
    ; OutputDebug(element.text)
    loop StrLen(element.text) {
        Send("{Right}")
    }
    left_list.Push(element)
    return true
}

send_backspace(stop_code := '') {
    ; 返回值：
    ; 只要不是被stop_code阻止的，都返回true
    ; 比如\frac{a}{b}想切换成\cfrac但是语句里已经有东西了，会在碰到a时停止删除，返回1
    if (left_list.Length == 0) {
        return false
    }
    element := left_list.Pop()
    ; OutputDebug('BackSpace.code: ' . element.code)
    ; OutputDebug('BackSpace.text: ' . element.text)
    if (element.code == '') {
        ; code==''的文本都是与前面的文本配对的，比如\right{ \left}，后面的'\left}'的code就是''
        while (element.code == '') { ; 如果配对的附属文本（比如\left}），就循环到主文本为止
            loop StrLen(element.text) {
                SendInput("{Left}")
            }
            right_list.Push(element)
            if (left_list.Length == 0) {
                return true
            }
            element := left_list.Pop()
        }
        left_list.Push(element)
        return true
    }
    if (element.code == 'command_end') {
        right_list.Push(element)
        SendInput('{Left}')
        return true
    }
    if (element.code == stop_code) {
        left_list.Push(element)
        return false
    }
    if (element.code == 'command_func' and command_mode.is_on) {
        command_mode.reset()
        return true
    }

    if (element.code == 'clipboard') {
        SendInput("{Backspace}")
        element.text := SubStr(element.text, 1, StrLen(element.text) - 1)
        if (element.text != '') {
            left_list.Push(element)
        }
        return true
    }
    if (InStr(element.text, '\begin')) {
        global matrix_mode
        OutputDebug('send_backspace: matrix_mode -=(matrix_mode>0) : ' . matrix_mode)
        matrix_mode -= (matrix_mode > 0)
    }
    loop StrLen(element.text) {
        SendInput("{Backspace}")
    }
    delete_operate := '{delete}'
    try {
        title := WinGetTitle("A")
        if (InStr(title, "幕布")) {   ; 幕布里delete键失效，闪记卡里{Right}失效，傻逼bug一堆
            delete_operate := '{Right}{Backspace}'
        }
    }
    if (InStr(element.code, '$')) {
        sub_num := StrSplit(Trim(element.code, "$"), '$').Length - 1
        ; 如果被删除的嵌套语句里还嵌套着东西，比如\frac{a}{bbb}要删除'\frac{'，那么整个嵌套语句连同里面的内容会一起删除
        while sub_num > 0 {
            right_element := right_list.Pop()
            loop StrLen(right_element.text) {
                SendInput(delete_operate)
            }
            if (right_element.code == '') {
                sub_num -= 1
            }
            ; OutputDebug(right_element.text)
        }
    }

    if (exe_mode == "VSCode") {  ; VSCode里输入按键延迟很高
        Sleep(50)
    }
    return true

}

global Alt_to_bracket := false
global send_texting := false  ; 用于在临时Latex模式中判断是否有文本要输出，避免block_end抢在send_text之前执行

send_text(key, code, backspace := false) {   ; 从code到text
    if (CapsLock_is_being_pressed and !temporary_latex) {
        if (code == 'clipboard') {  ; temporary_latex会作为一个信号告知block_begin一些信息（单纯为了兼容飞书）
            block_begin()
            global temporary_latex := true
            global send_texting := true
        } else {
            global temporary_latex := true
            global send_texting := true
            block_begin()
        }

    }
    if block_beginning { ; 等待block_begin执行完毕
        global send_text_params := [key, code, backspace]
        SetTimer(send_text_callback, -50)
        return
    }
    ; OutputDebug('send_text: ' . key)
    if (command_mode.func_checking) {
        command_mode.clean()
    }

    if (command_mode.is_on and left_list[left_list.Length].code == 'command_end') {
        ; 如果函数括号已经闭合，则不允许再输入任何东西
        gui_twinkle_warning("括号已闭合")
        return
    }
    ; OutputDebug('send_text: ' . key)
    if (GetKeyState('Alt', 'P') and !Alt_to_bracket) {
        global Alt_to_bracket := true
        send_text_insertMOD('Alt_to_bracket', '($)')
        Sleep(50)  ; 飞书里有奇怪的延迟bug
    }
    ; OutputDebug_Array(code)

    if (backspace) {
        ; backspace是用于在触发切换的时候删除掉前面的触发文本的
        send_backspace()
    }
    ; send_backspace里会修改pre_code，函数型code有可能是连击映射，所以这里有严格的先后顺序

    if (Type(code) == "Func") {
        ; OutputDebug('Function: ' . code.Name)
        code()
        ; 执行函数时，backspace字段无效
        global send_texting := false
        return
    }
    if (Type(code) == "Array") { ; 有参数的函数
        fun := code[1]
        ; code.RemoveAt(1) 这个数组是浅拷贝的，不能修改！
        code := code.Clone()
        code.RemoveAt(1)
        fun(code*)
        global send_texting := false
        return
    }
    ; OutputDebug('right_stop: ' . right_stop)

    if (!linefeed) {  ; 如果不允许换行，则任何输出`n都会被删去
        code := StrReplace(code, '`n', '')
    }

    ; 一切文本输出从此处开始
    OutputDebug('key: ' . key)
    OutputDebug('code:' code)
    if (code == 'clipboard') {
        Send("^v")
        left_list.Push(text_code_key(A_Clipboard, 'clipboard', key))
        global send_texting := false
        return
    }


    if (InStr(code, '$') and code != '$') {
        send_text_insertMOD(key, code)
        global send_texting := false
        return
    }
    ; OutputDebug('send_text: |' code '|' )
    ; 当code='`''时有时候会sendtext不出来，完全找不到原因的逆天bug
    OutputDebug('code: ' . code)
    SendText(code)
    left_list.Push(text_code_key(code, code, key))
    global send_texting := false
}
send_text_insertMOD(key, code) {
    code_Split := StrSplit(Trim(code, "$"), '$')
    ; AHK的数组是从1计数的（逆天）
    whole_text := StrReplace(code, '$', "")
    head_text := code_Split.RemoveAt(1)

    SendText(whole_text)
    loop StrLen(whole_text) - StrLen(head_text) {
        Send("{Left}")
    }

    left_list.Push(text_code_key(head_text, code, key))

    loop code_Split.Length {
        ; OutputDebug(code_Split.Length)
        text := code_Split[code_Split.Length - A_Index + 1]
        right_list.Push(text_code_key(text))
    }
}
send_text_callback() {
    send_text(send_text_params*)
}

global pre_key := ''
; pre_key在联合按键中用到，因此在修改pre_key前必须进行combine_key_combos检查
main(key) {
    ; OutputDebug('key: ' . key)
    ; 指令模式在输入函数名期间禁用所有映射，点按cap退出指令模式
    if (key == 'end') {
        ending_rightright()
        return
    }
    if (command_mode.is_on) {
        if (command_mode.func_is_inputting) {
            if (key == 'up') {
                command_mode.turn_to_last_command()
            } else if (key == 'tab') {
                command_mode.tab()
            } else {
                command_mode.input_func(key)
            }
            return
        }
        if (key == '@') {
            send_text('@', '@')
            return
        }
    }

    if (IsNumber(key) and left_list.Length >= 1 and !GetKeyState('Alt', 'P') and key_pressed[key] == 0) {
        ; 数字下标特别定制：
        pre_text := left_list[left_list.Length].text
        if (left_list.Length >= 2   ; 防止把111变成1_{1}
            and IsNumber(pre_text)
            and IsNumber(left_list[left_list.Length - 1].text)) {
            send_text(key, key)
            return
        }
        ; 在 字母或右括号]和) 后面输入数字，自动转下标，双击转上标
        pre_text_last := SubStr(pre_text, StrLen(pre_text), 1) ; 获取pre_text的最后一个字符
        if (IsLetter(pre_text) or IsGreekLetter(pre_text)
            or pre_text_last == ')' or pre_text_last == ']') { ; x1直接变成x_{1}
            send_text(key, '_' key ' ') ; 别忘了末尾空格
            key_pressed[key] += 2
            SetTimer(clear_pressed[key], combos_delay)
            return
        }
        ; 如果前一个输入是下标，则紧接着输入数字会变成上标
        ; 注意，不能和连击相混淆，当连续输入22时，应该判断为^2而不是_2^2
        if (Ord(pre_text) == 95 and pre_text_last != '{') { ; 95是下划线
            send_text(key, '^' key ' ')
            return
        }
    }
    key_combos(key)
}


key_combos(key) {    ; 从key到code
    ; 映射优先级：选中文本映射（废弃） > 连击映射 > 联合映射 > 单击映射 ,
    global key_pressed
    global pre_key

    ; OutputDebug('key_combos: ' . key)
    if (!key_mapping.Has(key) or key_mapping[key] == 0) {
        ; 如果a键没有设置连击映射，要么key_mapping['key']等于0，要么根本没写
        if (!combine_key_combos(key)) {
            key_pressed[key] += 1
            send_text(key, key)
            SetTimer(clear_pressed[key], combos_delay)
        }
        if (pre_key != key) {
            clear_pressed[pre_key]()
            pre_key := key
        }
        return
    }
    if (key_pressed[key] == 0) {   ; 如果a键已经按下过了,key_pressed['a']就不等于0
        if (combine_key_combos(key)) {   ; 如果已经触发了联合按键，就不再执行单键按键
            return
        }
    }
    if (pre_key != key) {
        clear_pressed[pre_key]()
        global pre_key := key
    }

    key_pressed[key] += 1
    if (key_pressed[key] > key_mapping[key].Length) {
        ; 如果a键已经连击达到4次,key_pressed['a']就置1
        key_pressed[key] := 1
    }

    ; 连击2下，key_pressed['key']就等于2，调用key_mapping['key'][2]
    send_text(key, key_mapping[key][key_pressed[key]], key_pressed[key] > 1)
    SetTimer(clear_pressed[key], combos_delay)

    return
}

combine_key_combos(key) {
    ; 联合按键的意思是，比如你前面输入了'='，那么你再输入一个'/'就会变成'\ne '（不等于号）
    ; 注意，联合按键对于先前的输入只关心它的code而不是key也不是text
    ; 比如触发'=/'是因为你前一个code是'='，而不是因为你前一个key是'='
    if (left_list.Length == 0) {
        return false
    }
    element := left_list[left_list.Length]
    if (element.code == '') {
        return false
    }
    pre_code := element.code
    pre_key := element.key

    ; 专为分式设计：如果你输入了一个数字（或常数e和π），紧接着一个/，它就会变成一个分式
    if (key == '/' and StrLen(pre_code) == 1 and IsNumber(pre_code) and pre_code != 0) {
        number_string := ""
        while IsNumber(left_list[left_list.Length].text) {
            text := left_list.Pop().text
            loop StrLen(text) {
                Send("{Backspace}")
            }
            if (exe_mode == "VSCode") {  ; VSCode里输入按键延迟很高
                Sleep(50)
            }
            number_string := text . number_string
            if (left_list.Length == 0) {
                break
            }
        }
        send_frac('/', number_string)
        return true
    } else if (key == '/' and (pre_code == 'e' or pre_code == '\pi ')) {
        send_backspace()
        send_frac('/', pre_code)
        return true
    }

    if (combine_mapping.Has(pre_code . key)) {
        code := combine_mapping[pre_code . key]
    } else if (!key_mapping.Has(key) or key_mapping[key] == 0) {
        return false
    } else if (combine_mapping.Has(pre_code . key_mapping[key][1])) {
        code := combine_mapping[pre_code . key_mapping[key][1]]
    } else {
        return false
    }
    SetTimer(clear_pressed[pre_key], -1)
    ; SetTimer(clear_pressed[key], -1)
    ; OutputDebug(text)
    send_text(key, code, true)
    return true
}

code_convert() {
    ; 先在自定义的code_mapping里找，再在key_mapping里找
    if (left_list.Length == 0) {
        return
    }
    element := left_list[left_list.Length]
    if (element.code == '') {
        return
    }
    pre_code := Trim(element.code, "$")
    pre_text := element.text
    pre_key := element.key

    ; OutputDebug(pre_code)
    ; left_list[left_list.Length]没有pop出来
    if (code_mapping.Has(pre_code)) {
        code := Trim(code_mapping[pre_code], "$")
        if (InStr(pre_code, '$')) {
            if (!InStr(code, '$')) {
                send_backspace()
                send_text(pre_key, code)
                return
            }
            ; 如果替换前后都是嵌套语句，那么嵌套的内容会按位置照搬到新的语句
            ; 比如\frac{}{bbb}要切换成\lim_{$\to $}$=0，那么就变成\lim_{\to bbb}=0

            code_Split := StrSplit(code, '$')
            pre_code_Split := StrSplit(pre_code, '$')
            right_times := 0  ; 记录右移次数，因为最后要左移回来
            head_text := code_Split.RemoveAt(1)
            loop StrLen(left_list.Pop().text) {
                Send("{Backspace}")
            }
            if (exe_mode == "VSCode") {  ; VSCode里输入按键延迟很高
                Sleep(50)
            }
            SendText(head_text)
            left_list.Push(text_code_key(head_text, code, pre_key))
            ; 如果被删除的嵌套语句里还嵌套着东西，比如\frac{a}{bbb}要删除'\frac{'，那么整个嵌套语句连同里面的内容会一起删除
            sub_num := pre_code_Split.Length - 1
            while sub_num > 0 {
                right_element := right_list.Pop()
                right_times += 1
                loop StrLen(right_element.text) {
                    Send("{Right}")
                }
                if (right_element.code == '') {
                    sub_num -= 1
                    loop StrLen(right_element.text) {
                        Send("{Backspace}")
                    }
                    if (exe_mode == "VSCode") {  ; VSCode里输入按键延迟很高
                        Sleep(50)
                    }
                    if (code_Split.Length == 0) { ; 说明旧语句的空缺比新语句的多
                        right_times -= 1
                        continue
                    }
                    text := code_Split.RemoveAt(1)
                    SendText(text)
                    left_list.Push(text_code_key(text, '', pre_key))
                } else {
                    left_list.Push(right_element)
                }

            }
            while (code_Split.Length != 0) { ; 说明新语句的空缺比旧语句的多
                text := code_Split.RemoveAt(1)
                SendText(text)
                left_list.Push(text_code_key(text, '', pre_key))
                right_times += 1
            }
            loop right_times {
                to_left()
            }
            return
        }
        send_text(pre_key, code, true)
        return
    }

    replace(str, str2) {
        if (InStr(pre_text, str, true)) {
            element.text := StrReplace(pre_text, str, str2)
            element.code := StrReplace(pre_code, str, str2)
            loop StrLen(pre_text) {
                send("{BackSpace}")
            }
            if (exe_mode == "VSCode") {  ; VSCode里输入按键延迟很高
                Sleep(50)
            }
            SendText(element.text)
            left_list.Pop()
            left_list.Push(element)
            return true
        }
    }
    if (replace('cfrac', 'frac')) {
        return
    } else if (replace('frac', 'cfrac')) {
        return
    }

    if (replace('big', 'Big')) {
        return
    } else if (replace('Big', 'bigg')) {
        return
    } else if (replace('bigg', 'Bigg')) {
        return
    }

    if (key_mapping.Has(pre_key)) {
        i := 0
        for code in key_mapping[pre_key] {
            if (i == 1) {
                send_text(pre_key, code, true)
                return
            }
            if (code == pre_code) {
                i := 1
            }
        }
        return
    }
}

text_convert() {
    text_string := ''
    result := ''
    text_string_length := 0
    space_end := false
    loop left_list.Length {
        if (space_end) {
            break
        }
        text := left_list[left_list.Length - A_Index + 1].text
        if (!StrLen(text) == 1 or text == '\') {
            break
        } else if (text == ' ') {
            if (A_Index == 1) {
                ; 'sin '这种情况，空格出现在结尾
                continue
            } ; 否则说明空格出现在开头
            space_end := true
        }
        text_string := text . text_string
        ; OutputDebug(text_mapping.Has(text_string))
        if (!text_mapping.Has(text_string)) {
            continue
        }
        ; 为了避免误判到较短的text，比如arcsin，只识别到sin，所以不能直接输出，要继续遍历
        result := text_mapping[text_string]
        text_string_length := StrLen(text_string)
    }
    if (result == '') {
        return false
    }
    ; OutputDebug(result)
    loop text_string_length {
        send_backspace()
    }
    send_text('shift', result)
    return true
}

#Include GuiPlus.ahk
class command_mode_class_base {
    __New() {
        this.is_on := false
        this.func_is_inputting := false
        this.func := ''
        this.args_str := 1451
        this.func_checking := false

        this.last_func := ''    ; 保存上一条成功执行的指令的函数名
        this.last_command := '' ; 保存上一条成功执行的指令的文本
        this.last_command_element_list := []   ; 保存上一条成功执行的指令，以left_list的格式，不包含'\'

        this.candidate_func := []
        this.command_func_list := []  ; 保存所有指令函数的名字,由继承的子类定义

        this.workingWindow := 0
        this.inputGUI := gui('+AlwaysOnTop -Caption +ToolWindow')
        this.inputGUI.BackColor := '53372a'

        this.func_tip := this.inputGUI.AddText('w350 h18 x3 y3 -Wrap', 'Function does not exist')
        this.func_tip.SetFont('s11 cWhite bold', "Consolas")
        this.input_editor := this.inputGUI.add('Edit', 'w350 h25 x3 y23 Multi')
        this.input_editor.SetFont('s13', "Consolas")
        this.inputGUI.show('w356 h51')
        this.inputGUI.Hide()

        this.func_doc := Map()  ; 用于给指令函数加提示
    }
    set(status := true, input_to_screen := false) {
        ; input_to_screen=true,退出指令模式时会将指令框内的文本上屏

        OutputDebug('command_mode:' status)
        if (!status and !this.is_on) {
            return
        }
        if (status and !this.is_on) {
            try {
                workingWindow := WinGetTitle("A")
                if (workingWindow == 0) {
                    OutputDebug("no active window")
                }
            } catch {
                OutputDebug("no active window")
            }
            this.is_on := true
            this.func_is_inputting := true
            this.func := ''
            this.args_str := 1451
            this.func_suggest()
            ; 状态栏变为蓝色
            gui_blue()

            CoordMode('Caret', 'Screen')
            if !GetCaretPosEx(&CaretX, &CaretY, &CaretW, &CaretH) {
                OutputDebug("no caret")
                this.inputGUI.show('x' A_ScreenWidth // 2 - 340 'y' A_ScreenHeight // 2 - 100)
                SendText('\')
                left_list.Push(text_code_key('\', 'command_begin', '\'))
                return
            }

            show_inScreen(this.inputGUI, CaretX, CaretY)
            SendText('\')
            left_list.Push(text_code_key('\', 'command_begin', '\'))
            return
        }
        this.is_on := false
        this.func_is_inputting := false
        gui_blown()

        this.inputGUI.Hide()
        if (this.workingWindow != 0) {
            WinActivate(this.workingWindow)
        }
        OutputDebug('指令模式结束时的文本：' this.input_editor.Text)
        if (input_to_screen) {
            SendText(this.input_editor.Text)
        }
        this.input_editor.Text := ''

    }

    has_func() {
        if (IsNumber(this.func)) {
            ; 特殊设计，输入\10(\alpha)会输出10次\alpha（默认用逗号分隔）
            return true
        }
        for func in this.command_func_list {
            if (func == this.func) {
                return true
            }
        }
        return false
    }

    input_func(key) {
        if (IsNumber(key) or IsLetter(key)) {
            SendText(key)
            this.func := this.func . key
            this.func_suggest()
            return
        }
        if (key == '`(' or (key_mapping.Has(key) and key_mapping[key] != 0 and key_mapping[key][1] == '`(')) {
            if (!this.has_func()) {
                gui_twinkle_warning("指令不存在")
                return
            }
            this.complete_func()
            return
        }
        ; 如果是标点符号（除了'('），那么直接退出指令模式，指令框内的文本上屏
        if (key_mapping.Has(key) and key_mapping[key] != 0) {
            SendText(key_mapping[key][1])
        } else {
            SendText(key)
        }
        if (StrLen(command_mode.input_editor.text) != 0) {
            if (command_mode.input_editor.text == '\\') {
                command_mode.set(false)
                send_text('\', '\setminus ')
                return
            } else {
                left_list.Push(text_code_key(command_mode.input_editor.text, key, key))
            }
        }
        command_mode.set(false, true)
    }

    func_suggest() {
        if (this.func == '') {
            this.candidate_func := []
            this.func_tip.Text := '上条指令: ' this.last_command

            return
        }
        candidate := [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
        ; 一共20个[]，不会有函数的名字超过20个字符

        for fun in this.command_func_list {
            if (fun == '__Class') {
                continue
            }
            regex := '(?i)' RegExReplace(this.func, "\S", "$0\S*")
            place := RegExMatch(fun, regex)
            ; place := InStr(fun,this.func) ; AHK里的函数不区分大小写
            if (place == 0) {
                continue
            }
            candidate[place].Push(fun)
        }
        this.candidate_func := []
        for i in candidate {
            for j in i {
                this.candidate_func.Push(j)
            }
        }
        if (this.candidate_func.Length == 0) {
            this.func_tip.Text := '|'
            return
        }
        text := ''
        for i in this.candidate_func {
            if (A_Index == 1) {
                text := i
                continue
            }
            text := text ',' i

        }
        this.func_tip.Text := text
    }

    complete_func() {
        SendText('()')
        Send("{Left}")
        try {
            this.func_tip.Text := this.GetOwnPropDesc('__doc_' this.func).Value
        } catch {
            this.func_tip.Text := this.func
        }
        left_list.Push(text_code_key(this.func . '(', 'command_func', ''))
        right_list.Push(text_code_key(')', 'command_end', ''))
        this.func_is_inputting := false
    }

    tab() {
        ; OutputDebug('tab')
        if (this.candidate_func.Length == 0) {
            this.turn_to_last_command()
            return
        }
        loop StrLen(this.func) {
            send("{Backspace}")
        }
        this.func := this.candidate_func[1]
        SendText(this.func)
        this.complete_func()
    }

    num_repeat(element, sep := 1451) {
        element := element . ' '
        if (sep == 1451) {
            if (matrix_mode) {
                sep := '& '
            } else {
                sep := ','
            }
        }
        repeat_times := Number(this.func)

        loop repeat_times {
            send_text('', StrReplace(element, '@', A_Index))
            send_text('', sep)
        }
        send_backspace()
        return true
    }


    execute() {
        ; 在按下\时触发指令，跟MC的命令行一样
        ; 按下回车执行指令(如果括号未闭合就执行正常的右移功能)
        ; 指令编写的过程中允许连击转义等各种日常操作，但是禁止回车右移，因为回车会直接执行指令
        ; 指令规范：\函数名(参数1,参数2,...)
        ; 函数名只能由字母和数字组成
        ; 所有参数均被视为字符串，首尾的空格会被忽略，'\ '这样的空格不会被忽略
        ; 函数名不得包含空格，在敲下'('前一旦敲下非字母的键就会终止指令模式
        ; 参数用','分隔，也就意味着参数内不得包含','，除非用括号括起来

        ; 如果按下回车时 括号没有闭合 那么是不会执行指令的，比如
        ; \list(\alpha _{@},1,n 没打右括号
        ; \list(\alpha ^{(@)},1,n 打了右括号但是并不是左括号的对应括号

        ; 逗号会被视为参数分隔符，所以逗号不得出现在参数内，除非被括号括起来
        ; 我想不到在什么需求下参数里会只有左括号没有右括号，因为在数学公式里左右括号也是要匹配的
        if (this.args_str == 1451) {
            ; 1451是初始化值，只要不是这个值就说明args_str已经被其他函数修改过了
            if (left_list[left_list.Length].code != 'command_end') {
                return false
            }
            this.args_str := ''
            ; 把参数部分的输入合并成字符串
            i := 1
            while (left_list[left_list.Length - i].code != 'command_func') {
                ; OutputDebug(left_list[left_list.Length - i].code)
                this.args_str := left_list[left_list.Length - i].text . this.args_str
                i += 1
            }
        }
        this.args := this.args_str_parse(this.args_str)
        if (this.args == false) {
            this.args_str := 1451
            return false
        }
        OutputDebug('command: ' . this.func . '(' . this.args_str . ')')
        ; (this.args)
        if (IsNumber(this.func)) {
            func := this.num_repeat
        } else {
            func := this.GetMethod(this.func)
        }
        ; 注意，func最少也需要一个this参数
        if (func.MinParams - 1 > this.args.Length) {
            gui_twinkle_warning("过少的参数")
            OutputDebug('参数过少')
            this.args_str := 1451
            return false
        }
        if (!func.IsVariadic) {
            while (func.MaxParams - 1 < this.args.Length) {
                ; 多余的参数会直接忽略
                this.args.pop()
            }
        }

        try {
            this.func_checking := true
            func(this, this.args*)
            Sleep(100)
            this.set(false, true)
        } catch ValueError as err {
            OutputDebug(err.Message)
            gui_twinkle_warning(err.Message)
            this.func_checking := false
            this.args_str := 1451
            return false
        }
        this.func_checking := false
        return true
    }

    args_str_parse(args_str) {
        ; 这里的args_str必须是传参，不能是this.args_str，因为里面采用了递归
        if (args_str == '') {
            return []
        }
        OutputDebug('args_str: ' . args_str)
        args := []

        parentheses_close := 0
        ; 我相信没有这样子写的傻逼abc(de{fgh)ij}klm
        ; \list(\alpha _{@},[1,2,.,n]) 列表对象只认方括号，写成(1,2,.,n)会被当成字符串
        index := 0
        begin := 1
        while index < StrLen(args_str) {
            index += 1

            char := SubStr(args_str, index, 1)
            if (char == '``') { ; 转义字符
                index += 1
                continue
            }
            if (char == '`(' or char == '`[' or char == '`{') {
                parentheses_close += 1
                continue
            }
            if (char == '`)' or char == '`]' or char == '`}') {
                parentheses_close -= 1
                continue
            }
            if (parentheses_close != 0) {
                ; 这是为了避免将\alpha_{a,b}这样的逗号识别为分隔符
                continue
            }
            if (char == ',') {
                temp := SubStr(args_str, begin, index - begin)
                ; OutputDebug('temp: ' . temp)
                temp := Trim(temp)
                if (Ord(SubStr(temp, StrLen(temp))) == 92) { ; 93是']'，92是'\',91是'['
                    temp := temp . ' '
                }
                if (Ord(temp) == 91 and Ord(SubStr(temp, StrLen(temp))) == 93) {
                    ; 不能用Trim因为它会把[[1,2,3],a,b]把前面的两个[[全去掉
                    temp := SubStr(temp, 2, StrLen(temp) - 2)
                    temp := this.args_str_parse(temp)
                } else {
                    temp := StrReplace(temp, '``', '')
                }
                args.Push(temp)
                begin := index + 1
            }
        }
        ; OutputDebug('parentheses_close:' . parentheses_close)
        if (parentheses_close != 0) {
            gui_twinkle_warning("括号未闭合")
            return false
        }
        if (begin > StrLen(args_str)) {
            args.Push('')
        } else {
            temp := SubStr(args_str, begin, index - begin + 1)
            ; OutputDebug('temp: ' . temp)
            temp := Trim(temp)
            if (Ord(SubStr(temp, StrLen(temp))) == 92) {
                temp := temp . ' '
            }
            if (Ord(temp) == 91 and Ord(SubStr(temp, StrLen(temp))) == 93) {
                temp := SubStr(temp, 2, StrLen(temp) - 2)
                temp := this.args_str_parse(temp)
            }
            args.Push(temp)
        }
        ; OutputDebug_Array(args)
        return args
    }

    reset() {    ; 清空命令行
        if (!this.is_on) {
            return
        }
        this.func_is_inputting := true
        this.func := ''
        this.func_checking := false
        this.args_str := 1451
        this.func_suggest()

        this.input_editor.Text := ''
        SendText('\')

        element := text_code_key('')
        while (element.code != 'command_begin') {
            element := left_list.Pop()
        }
        while (element.code != 'command_end' and right_list.Length != 0) {
            element := right_list.Pop()
        }
        left_list.Push(text_code_key('\', 'command_begin', '\'))
    }

    clean() {    ; 如果函数可以执行，那么要先清除掉前面输入的指令文本
        ; 因为清除文本前必须确认函数可以执行，所以没办法写在函数调用之前，只能靠编写者自己在函数里写上了
        ; 注意，clean()执行的前提一定要是指令成功执行，因为我把“保存上一条指令”的功能也写在这里了
        this.func_checking := false
        this.save_command := []
        this.last_func := this.func
        ; OutputDebug('last_func: ' . this.last_func)
        if (left_list.Length == 0) {  ; 说明是点按shift执行选中文本
            OutputDebug('shift_command')
            this.last_command := '\' this.func '(' this.args_str ')'
            send("{BackSpace}")
            this.set(false)
            this.save_command.Push(text_code_key(this.func . '(', 'command_func', ''))
            this.save_command.Push(text_code_key(this.args_str, 'clipboard', ''))
            this.save_command.Push(text_code_key('`)', '`)', '`)'))
            return
        }
        this.last_command := this.input_editor.Text
        this.input_editor.Text := ''
        element := text_code_key('')
        while (element.code != 'command_func') {
            element := left_list.Pop()
            this.save_command.InsertAt(1, element)
        }

    }

    turn_to_last_command() {
        ; 用于在指令模式下，按下'tab'时调用
        ; 先清除掉前面的指令文本，然后把上一条指令文本放进去
        OutputDebug('turn_to_last_command')
        if (this.last_command == '') {
            OutputDebug('没有上一条指令')
            return
        }
        this.reset()

        ; 小心不要篡改this.save_command，因为复原可能不止一次
        for element in this.save_command {
            ; OutputDebug(element.text)
            left_list.Push(element)
            ; OutputDebug('left_list: ' . left_list[left_list.Length].text)
        }
        this.input_editor.Text := ''
        SendText(this.last_command)
        this.func := this.last_func
        this.func_is_inputting := false
        try {
            this.func_tip.Text := this.GetOwnPropDesc('__doc_' this.func).Value
        } catch {
            this.func_tip.Text := this.func
        }
    }


    range_parse(range, ellipsis := false) {
        ; 服务于指令函数的函数，作用是将字符或数字或区间转换成一个数组
        ; 输入：[a,b,c,d]（如果输入就是一个长度大于2的数组，那么原封不动返回）
        ; 输出：[a,b,c,d]
        ; 输入：5
        ; 输出：[1,2,3,4,5]
        ; 如果range数组只有两个元素，那么它是一个区间，比如[1,100]，[3,n]
        ; 输入：[1,n]
        ; 输出：[1,2,.,n]   '.'表示省略号
        ; 输入：[1,10]
        ; 输出：[1,2,3,4,5,6,7,8,9,10]
        ; 如果ellipsis为true，那么对于完全为数字的序列（比如[1,100]）
        ; 当序列长度超过5时会使用省略号，从第3个之后开始省略
        ; 特别地，从1开始的序列(比如[1,2,.,n])从2之后开始省略，因为人们很容易看出规律
        ; 输入：[3,10], true
        ; 输出：[3,4,5,.,10]
        ; 输入：[0,10], true
        ; 输出：[0,1,2,.,10]
        ; 输入：1:5（相当于[1,5]）
        ; 输出：[1,2,3,4,5]
        ; OutputDebug_Array(range)
        if (ellipsis == 'false') {
            ellipsis := false
        }
        if (ellipsis == 'true') {
            ellipsis := true
        }
        if (IsNumber(range)) {
            num := Number(range)
            if (num < 1) {
                return "empty range"
            }
            if (ellipsis and num > 5) {
                return [1, 2, '.', num]
            } else {
                range := []
                loop num {
                    range.Push(A_Index)
                }
                return range
            }
        }
        if (Type(range) == "String") {
            ; 输入：1:5（相当于[1,5]）
            ; 输出：[1,2,3,4,5]
            if (InStr(range, ':')) {
                range := StrSplit(range, ':', , 2)
                OutputDebug_Array(range)
            } else {
                if (ord(range) == 45) { ; 如果是"-n"，那么输出是[-1,-2,...,-n]
                    return [-1, -2, '.', range]
                }
                return [1, 2, '.', range]
            }
        }

        if (!IsArray_with_num_and_string(range)) {
            throw ValueError("列表的元素必须是数字或字符串")
        }
        if (range.Length == 2) {
            beg := range[1]
            end := range[2]
            if (IsNumber(beg) and IsNumber(end)) {
                if (beg < end) {
                    if (ellipsis and end - beg > 4) {
                        if (beg == 1) {
                            return [1, 2, '.', end]
                        }
                        return [beg, beg + 1, beg + 2, '.', end]
                    }
                    range := [beg]
                    loop end - beg {
                        range.Push(beg + A_Index)
                    }
                    return range
                }
                if (beg > end) {
                    ; 如果区间结尾比开头小，比如[10,1]
                    ; 那么输出是[10,9,...,1]
                    ; 而不是[1,2,3,...,10]
                    if (ellipsis and beg - end > 4) {
                        return [beg, beg - 1, beg - 2, '.', end]
                    }
                    range := [beg]
                    loop beg - end {
                        range.Push(beg - A_Index)
                    }
                    return range
                } else {
                    return [beg]
                }
            }
            if (IsNumber(beg) and Type(end) == "String") {
                if (ord(end) == 45) { ; 如果是[0,-n]，那么输出是[0,-1,-2,...,-n]
                    return [beg, beg - 1, beg - 2, '.', end]
                }
                if (beg == 1) {
                    return [1, 2, '.', end]
                }
                return [beg, beg + 1, beg + 2, '.', end]
            }
            if (Type(beg) == "String") {
                range := [beg, beg . '+1', beg . '+2', '.', end]
            }
        }
        return range
    }

    StrReplace_rc(text, rr, cc) {
        if (StrLen(cc) > 1 or StrLen(rr) > 1) {
            text := StrReplace(text, '@r@c', '@r,@c')
            text := StrReplace(text, '@c@r', '@c,@r')
        }
        text := StrReplace(text, '@r', rr)
        text := StrReplace(text, '@c', cc)
        return text
    }
}

class command_mode_class extends command_mode_class_base {
    ; 指令函数编写处(Command Functions) ------------------------------
    ; 所有的指令函数请写在command_mode_class的类定义内
    ; 这样子做的好处是不用多写一行command.mapping['list']:='list'
    ; 坏处是会把固有的类和额外编写的指令函数混淆在一起了
    ; 因此通过继承来解决这个问题
    ; 指令的参数存储在this.args
    ; 指令函数的编辑应该严格遵循以下格式
    ; func(){
    ;     ; 检查参数，当参数不符合要求时throw ValueError
    ;     this.clean() ; 删除前面输入的指令文本
    ;     ; 执行涉及键盘输出的功能
    ; }
    __New() {
        super.__New()
        for func in command_mode_class.Prototype.OwnProps() {
            if (A_Index <= 2) {
                continue
            }
            this.command_func_list.Push(func)
        }
        ; OutputDebug_Array(this.command_func_list)
    }

    __doc_list := "list(元素='a',下标=n,间隔符=',',省略号=true)"
    list(element := 'a', range := 'n', sep := 1451, ellipsis := true) {  ; 函数功能是将@自动替换为要遍历的序列
        ; element : str
        ; range : 要遍历的序列，只有两个元素时表示区间
        ; sep : 分隔符
        ; ellipsis : 是否使用省略号，如果为true，那么超过5个数时会使用省略号

        ; 输入：\list(\alpha _{@},[1,n]) 此时range是一个区间
        ; 输出：\alpha _{1},\alpha _{2},\dots ,\alpha _{n}
        ; 输入：\list(\alpha _{@},a)
        ; 输出：\alpha _{1},\alpha _{2},\dots ,\alpha _{a}
        ; 输入：\list(\alpha _{@},[1,2,.,n],+)
        ; 输出：\alpha _{1}+\alpha _{2}+\dots +\alpha _{n}
        ; '.'表示省略号
        if (sep == 1451) {   ; 说明没有人为定义分隔符
            if (matrix_mode) {
                sep := '&'
            } else {
                sep := ','
            }
        }
        if (ellipsis == 0 or ellipsis == 'false') {
            range := this.range_parse(range, false)
        } else {
            range := this.range_parse(range, true)
        }
        if (range == "empty range") {
            return false
        }

        if (!InStr(element, '@')) {    ; 如果没给出变量的位置，那就当作下标自动补上
            element := element . '_{@}'
        }
        if (SubStr(element, StrLen(element)) != ' ') {
            element := element . ' '  ; 我会贴心地给每个元素后面加个空格
        }
        if (SubStr(sep, StrLen(sep)) != ' ') {
            sep := sep . ' '
        }
        for i in range {
            if (i == '.') {
                ; OutputDebug(sep . '|')
                if (sep == '& ') {
                    send_text('', '\cdots ')
                } else if (sep == '\\ ') {
                    send_text('', '\vdots ')
                } else {
                    send_text('', '\dots ')
                }
            } else {
                send_text('', StrReplace(element, '@', i))
            }
            if (A_Index != range.Length) {
                send_text('', sep)
            }
        }
        return true
    }

    __doc_sum := "sum(元素='a',下标=[1,2,.,n],省略号=true)"
    sum(element, range := 'n', ellipsis := true) {
        ; 用法和list完全相同，只不过间隔的逗号变成了加号
        this.list(element, range, '+')
        return true
    }

    __doc_mutiply_dot := "mutiply_dot(元素='a',下标=[1,2,.,n],省略号=true)"
    mutiply_dot(element, range := 'n', ellipsis := true) {
        ; 用法和list完全相同，只不过间隔的逗号变成了\cdot
        this.list(element, range, '\cdot')
        return true
    }

    __doc_mutiply_cross := "mutiply_cross(元素='a',下标=[1,2,.,n],省略号=true)"
    mutiply_cross(element, range := 'n', ellipsis := true) {
        ; 用法和list完全相同，只不过间隔的逗号变成了\cdot
        this.list(element, range, '\times')
        return true
    }

    __doc_vlist := "vlist(元素='a',下标=[1,2,.,n],省略号=true)"
    vlist(element := 'a', range := 'n', ellipsis := true) { ; 垂直的列向量
        ; 用法和list完全相同，只不过间隔的逗号变成了'\\'

        range := this.range_parse(range, ellipsis)
        if (range == "empty range") {
            return false
        }


        temporary_matrix := false
        if (!matrix_mode) {
            temporary_matrix := true
            bmatrix_on()
        }
        if (!InStr(element, '@')) {    ; 如果没给出变量的位置，那就当作下标自动补上
            element := element . '_{@}'
        }
        if (SubStr(element, StrLen(element)) != ' ') {
            element := element . ' '  ; 我会贴心地给每个元素后面加个空格
        }

        for i in range {
            if (i == '.') {
                send_text('', '\vdots ')
            } else {
                send_text('', StrReplace(element, '@', i))
            }
            if (A_Index != range.Length) {
                send_text('', '\\ `n')
            }
        }
        return true
    }

    __doc_alist := "alist(元素='a',下标=[1,2,.,n],间隔符=',') 不用省略号的list"
    alist(element := 'a', range := 'n', sep := 1451) { ; 不用省略号的list
        this.list(element, range, sep, false)
        return true
    }

    __doc_matrix := "matrix(元素='a',行='n',列=行,省略号=true)"
    matrix(element := 'a', rows := 'n', cols := 1451, ellipsis := true) {
        ; matrix(element:str)
        ; 输出: n阶方阵
        ; 特别地，matrix(E)输出单位阵
        ; matrix(element:str, rows行数:int|str)
        ; 输出: rows阶方阵
        ; matrix(element:str,rows行数:int|str,cols列数:int|str)
        ; 输出: rows行cols列的矩阵
        ; 当行数/列数是数字或区间时，超过5行/列会用省略号
        ; 例如matrix('a',5,6)输出的是
        ; a_{11} & a_{12} & a_{13} & \cdots & a_{16} \\
        ; a_{21} & a_{22} & a_{23} & \cdots & a_{26} \\
        ; a_{31} & a_{32} & a_{33} & \cdots & a_{36} \\
        ; a_{41} & a_{42} & a_{43} & \cdots & a_{46} \\
        ; a_{51} & a_{52} & a_{53} & \cdots & a_{56}

        ; element中，用@r表示所在行数，@c表示所在列数，单独用@相当于@r@c
        ; 例如要输出[a,b,c,d,e]的范德蒙德矩阵，这样写：
        ; \matrix(@c^{@r},[0,4],[a,b,c,d,e])

        ; 当不处于matrix_mode时，会默认输出方括号矩阵（用户可能想要圆括号或行列式）
        ; 当处于matrix_mode时，不会输出\begin{bmatrix}和\end{bmatrix}，只会输出矩阵内容

        if (cols == 1451) {
            cols := rows
        }
        rows := this.range_parse(rows, ellipsis)
        cols := this.range_parse(cols, ellipsis)
        if (rows == "empty range" or cols == "empty range") {
            return false
        }
        temporary_matrix := false
        if (!matrix_mode) {
            temporary_matrix := true
            bmatrix_on()
        }
        if (element == 'E') {
            for rr in rows {
                for cc in cols {
                    if (cc == '.' and rr == '.') {
                        send_text('', '\ddots ')
                    } else if (rr == cc) {
                        send_text('', '1')
                    }
                    if (A_Index != cols.Length) {
                        send_text('', ' & ')
                    }
                }
                if (A_Index != rows.Length) {
                    send_text('', '\\ `n')
                }
            }
            return
        }
        if (element == 'E0') {  ; 前面的单位阵不显示0，这里显示0
            for rr in rows {
                for cc in cols {
                    if (cc == '.' and rr == '.') {
                        send_text('', '\ddots ')
                    } else if (cc == '.') {
                        send_text('', '\cdots ')
                    } else if (rr == '.') {
                        send_text('', '\vdots ')
                    } else if (rr == cc) {
                        send_text('', '1')
                    } else {
                        send_text('', '0')
                    }
                    if (A_Index != cols.Length) {
                        send_text('', ' & ')
                    }
                }
                if (A_Index != rows.Length) {
                    send_text('', '\\ `n')
                }
            }
            return
        }

        if (!InStr(element, '@') and !IsNumber(element)) {
            element := element . '_{@r@c}'
        }
        ; OutputDebug(element)
        for rr in rows {
            for cc in cols {
                if (cc == '.' and rr == '.') {
                    send_text('', '\ddots ')
                } else if (cc == '.') {
                    send_text('', '\cdots ')
                } else if (rr == '.') {
                    send_text('', '\vdots ')
                } else {
                    ; OutputDebug(this.StrReplace_rc(element,rr,cc))
                    send_text('', this.StrReplace_rc(element, rr, cc))
                }
                if (A_Index != cols.Length) {   ; 最后一列不需要输出分隔符
                    send_text('', ' & ')
                }
            }
            if (A_Index != rows.Length) {   ; 最后一行不需要输出换行符
                send_text('', '\\ `n')
            }
        }
    }

    __doc_matrixColumn := "matrixColumn(元素='a',行='n',列=行,省略号=true)"
    matrixColumn(element := 'a', rows := 'n', cols := 1451, ellipsis := true) {
        ; 用法和matrix完全相同，只不过是列向量

        if (cols == 1451) {
            cols := rows
        }
        rows := this.range_parse(rows, ellipsis)
        cols := this.range_parse(cols, ellipsis)
        if (rows == "empty range" or cols == "empty range") {
            return false
        }

        if (element == 'E') {  ; 前面的单位阵不显示0，这里显示0
            bmatrix_on()
            for cc in cols {
                if (cc == '.') {
                    send_text('', '\cdots ')
                    continue
                }
                for rr in rows {
                    if (rr == '.') {
                        send_text('', '\vdots ')
                    } else if (rr == cc) {
                        send_text('', '1')
                    } else {
                        send_text('', '0')
                    }
                    if (A_Index != cols.Length) {   ; 最后一列不需要输出分隔符
                        send_text('', '\\ `n')
                    }
                }
            }
            return
        }

        if (!InStr(element, '@') and !IsNumber(element)) {
            element := element . '_{@r@c}'
        }
        ; OutputDebug(element)
        for cc in cols {
            if (cc == '.') {
                send_text('', '\cdots ')
                continue
            }
            send_text('', '\begin{bmatrix}')
            for rr in rows {
                if (rr == '.') {
                    send_text('', '\vdots ')
                } else {
                    text := element
                    if (StrLen(cc) > 1 or StrLen(rr) > 1) {
                        text := StrReplace(text, '@r@c', '@r,@c')
                        text := StrReplace(text, '@c@r', '@c,@r')
                    }
                    text := StrReplace(text, '@r', rr)
                    text := StrReplace(text, '@c', cc)
                    send_text('', text)
                }
                if (A_Index != cols.Length) {   ; 最后一列不需要输出分隔符
                    send_text('', '\\ `n')
                }
            }
            send_text('', '\end{bmatrix}')

        }
    }

    __doc_matrixDiag := "matrixDiag(对角线元素='a',阶数=n,填充=false) 对角线可以是列表"
    matrixDiag(element_list := 'a', rows := 'n', filling := '') {
        if (Type(filling) = 'Array') {
            throw ValueError("填充不能是列表")
        }
        if (Type(element_list) = 'Array') {
            rows := []
            for element in element_list {
                if (element == '.') {
                    rows.Push('.')
                } else {
                    rows.Push(A_Index)
                }
            }
        } else {
            if (rows == 0) {
                throw ValueError("阶数不得为0")
            }
            rows := this.range_parse(rows, true)
            if (!InStr(element_list, '@') and !IsNumber(element_list)) {
                element_list := element_list . '_{@}'
            }
        }

        temporary_matrix := false
        if (!matrix_mode) {
            temporary_matrix := true
            bmatrix_on()
        }

        for rr1 in rows {
            outside_index := A_Index
            for rr2 in rows {
                if (rr1 == '.') {
                    if (rr2 == '.') {
                        if (filling != '') {
                            send_text('', '\vdots & ')
                        } else {
                            send_text('', '\ddots ')
                        }
                    } else {
                        if (filling != '') {
                            send_text('', '\vdots ')
                        }
                    }
                } else {
                    if (rr2 == '.') {
                        if (filling != '') {
                            send_text('', filling . '&\cdots ') ; 参照丘维声高等代数里的写法，多写一个0列
                        }
                    } else if (outside_index == A_Index) {
                        if (Type(element_list) == 'Array') {
                            text := element_list[A_Index]
                        } else {
                            text := StrReplace(element_list, '@', rr1)
                        }
                        send_text('', text)
                    } else if (filling != '') {
                        send_text('', filling)
                    }
                }
                if (A_Index != rows.Length) {
                    send_text('', ' & ')
                }
            }
            if (A_Index != rows.Length) {
                send_text('', '\\ `n')
            }
        }
        return
    }

    __doc_cases := "cases(系数='a',x='x',b=0,行=n,列=n,省略号=true)"
    cases(k := 'a', x := 'x', b := 0, rows := 'n', cols := 'n', ellipsis := true) {
        if (Type(k) == 'Array') {
            throw ValueError("k不能是列表")
        }
        if (Type(x) == 'Array') {
            throw ValueError("x不能是列表")
        }
        if (Type(b) == 'Array') {
            throw ValueError("b不能是列表")
        }
        rows := this.range_parse(rows, ellipsis)
        cols := this.range_parse(cols, ellipsis)
        if (rows == "empty range" or cols == "empty range") {
            return false
        }
        if (!InStr(k, '@') and !IsNumber(k)) {
            k := k . '_{@r@c}'
        }
        if (!InStr(x, '@') and !IsNumber(x)) {
            x := x . '_{@c}'
        }
        if (!InStr(b, '@') and !IsNumber(b)) {
            b := b . '_{@r}'
        }
        if (SubStr(x, StrLen(x)) != ' ') {
            x := x . ' '  ; 我会贴心地给每个元素后面加个空格，唯独k没有
        }
        if (SubStr(b, StrLen(b)) != ' ') {
            b := b . ' '
        }
        send_text('', '\begin{cases} $ \end{cases}')
        for rr in rows {
            if (rr == '.') {
                send_text('', '\quad \vdots ')
                send_text('', '\\ `n')
                continue
            }
            for cc in cols {
                if (cc == '.') {
                    send_text('', '\cdots ')
                } else {
                    if (k != 1) {
                        send_text('', this.StrReplace_rc(k, rr, cc))
                    }
                    send_text('', this.StrReplace_rc(x, rr, cc))
                }
                if (A_Index != cols.Length) {
                    send_text('', '+ ')
                }
            }
            send_text('', '= ')
            send_text('', StrReplace(b, '@r', rr))
            if (A_Index != rows.Length) {
                send_text('', '\\ `n')
            }
        }
    }
    __doc_polynomial := "polynomial(变量符号='x',系数符号='c',次数=n)`npolynomial(变量符号='x',系数符号=[a,b,c])"
    polynomial(x := 'x', c := 'c', range := 'n') {
        if (c == '') { ; 参数为一个时
            c := 'c'
        }
        if (range == '') { ; 参数为两个时
            if (Type(c) != 'Array') {
                throw ValueError("range省略时c必须是列表")
            }
            range := c.Length - 1  ; 3个系数就是2次多项式
        }
        if (range == 0) {
            range := [0]
        }
        range := this.range_parse(range, Type(c) != 'Array') ; 如果c是列表，那么不用省略号
        if (range == "empty range") {
            return false
        }
        range.InsertAt(1, 0) ; 因为range_parse输出的范围都是从1开始的，而多项式还需要一个0次项

        if (Type(c) == 'Array') {
            if (c.Length != range.Length) {
                throw ValueError("c的长度必须和range的长度一致")
            }
            for rr in range {
                if (rr == 0) { ; 0次项不需要写x
                    send_text('', c[A_Index])
                } else if (rr == 1) { ; 1次项不需要写次数
                    send_text('', c[A_Index] StrReplace(x, '@', rr))
                } else {
                    send_text('', c[A_Index] StrReplace(x, '@', rr) '^{' rr '}')
                }
                if (A_Index != range.Length) {
                    send_text('', '+ ')
                }
            }
        } else {
            for rr in range {
                if (rr == '.') {
                    send_text('', '\cdots ')
                } else if (rr == 0) {
                    send_text('', c '_{0}')
                } else if (rr == 1) {
                    send_text('', c '_{1}' StrReplace(x, '@', rr))
                } else {
                    send_text('', c '_{' rr '}' StrReplace(x, '@', rr) '^{' rr '}')
                }
                if (A_Index != range.Length) {
                    send_text('', '+ ')
                }
            }
        }
    }

    __doc_rand := 'rand(取值范围,小数位数=2)'
    rand(range, decimal_precision := 2) {
        ; rand([beg:int,end:int])
        ; 输入：\rand([1,10])
        ; 输出：[1,10]内的整数，包括1和10
        ; rand([beg:float,end:float])
        ; 输入：\rand([1.0,10.0])
        ; 输出：[1.0,10.0]的随机数，包括1.0和10.0
        ; rand(end:int) 相当于beg=0
        ; 输入：\rand(10)
        ; 输出：[0,10]内的整数，包括0和10
        ; decimal_precision:保留小数位数
        ; 输入：\rand([1.0,10.0],3)
        ; 输出：[1,10]内的随机数，保留3位小数
        if (IsNumber(range)) {
            end := range
            beg := 0
        } else if (Type(range) != 'Array') {
            throw ValueError("rand的范围必须是数字或数组")
        } else {
            beg := range[1]
            end := range[2]
        }

        if (!IsNumber(beg) or !IsNumber(end)) {
            throw ValueError("rand的范围必须是数字")
        }
        if (beg > end) {
            temp := beg
            beg := end
            end := temp
        }

        ; 关于随机数生成范围的官方解释：
        ; Although the specified maximum value is excluded by
        ; design when returning a floating point number, it may
        ; in theory be returned due to floating point rounding errors.
        ; This has not been confirmed, and might only be possible if
        ; the chosen bounds are larger than 2**53. Also note that since
        ; there may be up to 2**53 possible values (such as in the range 0.0 to 1.0),
        ; the probability of generating exactly the lower bound is generally very low.

        ; 如果随机数是浮点数，则保留decimal_precision位小数
        num := Random(beg, end)
        if (Type(num) == 'Float') {
            num := Round(num, decimal_precision)
        }
        send_text('', num)
    }

    __doc_listRand := "listRand(长度,取值范围,间隔符=',',小数位数=2)"
    listRand(len, range, sep := 1451, decimal_precision := 2) {
        if (!IsNumber(len)) {
            throw ValueError("rand_list的长度必须是整数")
        }
        if (IsNumber(range)) {
            end := range
            beg := 0
        } else if (Type(range) != 'Array') {
            throw ValueError("rand_list的范围必须是数字或数组")
        } else {
            beg := range[1]
            end := range[2]
        }

        if (!IsNumber(beg) or !IsNumber(end)) {
            throw ValueError("rand_list的范围必须是数字")
        }
        if (beg > end) {
            temp := beg
            beg := end
            end := temp
        }
        if (sep == 1451) {   ; 说明没有人为定义分隔符
            if (matrix_mode) {
                sep := '&'
            } else {
                sep := ','
            }
        }


        ; 如果随机数是浮点数，则保留decimal_precision位小数
        loop len {
            num := Random(beg, end)
            if (Type(num) == 'Float') {
                num := Round(num, decimal_precision)
            }
            send_text('', num)
            if (A_Index != len) {
                send_text('', sep)
            }
        }

    }

    __doc_matrixRand := "matrixRand(取值范围,行,列=行,小数位数=2)"
    matrixRand(range, rows, cols := 1451, decimal_precision := 2) {
        if (cols == 1451) {
            cols := rows
        }
        if (!IsNumber(rows) or !IsNumber(cols)) {
            throw ValueError("rand_matrix的行数和列数必须是整数")
        }
        if (IsNumber(range)) {
            end := range
            beg := 0
        } else if (Type(range) != 'Array') {
            throw ValueError("rand_matrix的范围必须是数字或数组")
        } else {
            beg := range[1]
            end := range[2]
        }
        if (!IsNumber(beg) or !IsNumber(end)) {
            throw ValueError("rand_matrix的范围必须是数字")
        }
        if (beg > end) {
            temp := beg
            beg := end
            end := temp
        }
        temporary_matrix := false
        if (!matrix_mode) {
            temporary_matrix := true
            bmatrix_on()
        }

        loop rows {
            loop cols {
                num := Random(beg, end)
                if (Type(num) == 'Float') {
                    num := Round(num, decimal_precision)
                }
                send_text('', num)
                if (A_Index != cols) {
                    send_text('', ' & ')
                }
            }
            if (A_Index != rows) {
                send_text('', ' \\ ')
            }
        }


    }

    __doc_temp := 'temp(key,code)'
    temp(key, code) { ; 存储一个临时的code,存放在F1-F12中
        ; temp(key,code)
        ; 输入: \temp(3,\sqrt{$^{2}+$^{2}})
        ; 输出: 相当于key_mapping['F3']:= ['\sqrt{$^{2}+$^{2}}']

        if (!IsNumber(key) or key < 1 or key > 12) {
            throw ValueError("temp的键必须是1-12的整数")
        }

        this.clean()
        key_mapping['F' key] := [code ' ']
        IniWrite("'" code " '", 'config.ini', 'temp', 'F' key)
        return true

        ; temp(f1,f2,,,,f12) ;废除!!!
        ; 输入: \temp(rank_{row},rank_{col})
        ; 输出: 相当于key_mapping['F1']:= ['rank_{row}'], key_mapping['F2']:= ['rank_{col}']
        ; OutputDebug_Array(this.args)
        ; if(args.Length==0){
        ;     throw ValueError("Ftemp函数至少需要一个参数")
        ; }
        ; if(args.Length>12){
        ;     throw ValueError("最多只能映射12个键")
        ; }
        ; this.clean()

        ; if(args.Length==2 and IsNumber(args[1])
        ;     and args[1]>=1 and args[1]<=12){
        ;     key_mapping['F' args[1]]:= [args[2] ' ']
        ;     IniWrite("'" args[2] " '",'config.ini','temp','F' args[1])
        ;     return true
        ; }
        ; for code in args{
        ;     key_mapping['F' A_Index]:= [code ' ']
        ;     IniWrite("'" code " '",'config.ini','temp','F' A_Index)
        ; }
    }

}


; 分号，用于存储一个临时的文本（符号），类似于剪切板
; 当连击两下ctrl+c时，将剪切板的内容存储到temp_text中
; global temp_text := ''
; +^c::{
;     clipboardSave := A_clipboard
;     send("^c")
;     Sleep(100)
;     global temp_text := Trim(A_clipboard,' `t$')
;     A_Clipboard := clipboardSave
; }

global Shift_clicked := true
false_Shift_clicked() {
    global Shift_clicked := false
}
~Shift:: SetTimer(false_Shift_clicked, -150)
~Shift up:: {
    SetTimer(false_Shift_clicked, 0)
    if (!shift_clicked or !InStr(A_PriorKey, 'Shift')) {
        global shift_clicked := true
        return
    }
    ; OutputDebug('shift')
    if (command_mode.func_is_inputting) {
        return
    }

    if (text_convert()) {
        return
    }
    OutputDebug('shift')
    code_convert()
}

~LButton up:: {
    if (Cap_Status) {
        clear_all()
    }
    Sleep(500)
    try {
        ProcessName := WinGetProcessName("A")
        Title := WinGetTitle("A")
        OutputDebug(ProcessName)

        global exe_mode
        if (ProcessName == 'msedge.exe' or ProcessName == 'chrome.exe') {
            exe_mode := 0
            if (InStr(Title, '飞书云文档')) {
                exe_mode := "飞书"
            }
        } else if (ProcessName == '幕布.exe') {
            exe_mode := "幕布"
        } else if (ProcessName == 'Feishu.exe') {
            exe_mode := "飞书"
        } else if (ProcessName == 'SimpleTex.exe') {
            exe_mode := "SimpleTex"
        } else if (InStr(Title, '闪记卡')) {
            exe_mode := "闪记卡"
        } else if (InStr(ProcessName, '语雀')) {
            exe_mode := "语雀"
        } else if (ProcessName == 'Code.exe') {
            exe_mode := "VSCode"
        } else {
            exe_mode := 0
        }
    }
    global linefeed
    if (array_has(['飞书', 'SimpleTex', 'VSCode'], exe_mode)) {
        ; OutputDebug('linefeed')
        linefeed := true
    } else {
        linefeed := false
    }
}

#HotIf Cap_Status

global LAlt_clicked := true
false_LAlt_clicked() {
    global LAlt_clicked := false
}
LAlt:: SetTimer(false_LAlt_clicked, -150)
LAlt up:: {
    OutputDebug('LAlt')
    SetTimer(false_LAlt_clicked, 0)
    if (!GetKeyState('RAlt', 'P') and Alt_to_bracket) {
        global Alt_to_bracket := false
        global LAlt_clicked := true
        to_right()
        return
    }
    if (!LAlt_clicked) {
        global LAlt_clicked := true
        return
    }
    main('LAlt')
}

global RAlt_clicked := true
false_RAlt_clicked() {
    global RAlt_clicked := false
}
RAlt:: SetTimer(false_RAlt_clicked, -150)
RAlt up:: {
    SetTimer(false_RAlt_clicked, 0)
    if (!GetKeyState('LAlt', 'P') and Alt_to_bracket) {
        global Alt_to_bracket := false
        global RAlt_clicked := true
        to_right()
        return
    }
    if (!RAlt_clicked) {
        global RAlt_clicked := true
        return
    }
    main('RAlt')
}


BackSpace:: {
    if (command_mode.func_is_inputting) {
        if (StrLen(command_mode.func) == 0) {
            send_backspace()
            command_mode.set(false)
            return
        }
        send("{BackSpace}")
        command_mode.func := SubStr(command_mode.func, 1, StrLen(command_mode.func) - 1)
        command_mode.func_suggest()
        return
    }
    if (send_backspace()) {
        return
    }
    if (left_list.Length == 0) {
        Send("{Backspace}")
        return
    }

}
clear_all() {
    ; OutputDebug('clear_all')
    global right_list := []
    global left_list := []
    global matrix_mode := 0
    command_mode.set(false)
}

~^a:: {
    if (command_mode.is_on) {
        return
    }
    clear_all()
}


Enter:: { ; 普通模式下Enter是不能换行的，shift+Enter才能换行（矩阵模式下可以直接Enter换行）
    if (command_mode.func_is_inputting) {
        return
    }
    if (command_mode.is_on and command_mode.execute()) {
        return
    }
    msg := to_right('\end{')
    if (msg == true) {
        return
    } else if (msg == 'stopped') {
        send_text('enter', '\\ `n')
        return
    }
    SendInput("{Enter}")
}

+Enter:: {
    if (command_mode.func_is_inputting) {
        command_mode.set(false)
    }

    send_text('enter', '\\ `n')
    return
}

Right:: {
    if (command_mode.func_is_inputting) {
        return
    }
    if (GetKeyState('LAlt', 'P')) {
        main('+right')
        false_LAlt_clicked()
        return
    } else if (GetKeyState('RAlt', 'P')) {
        main('+right')
        false_RAlt_clicked()
        return
    }
    msg := to_right()
    if (msg == true) {
        return
    }
    if (msg == 'empty' and !command_mode.is_on) {
        send("{Right}")
        clear_all()
        return
    }

}


Left:: {
    if (command_mode.func_is_inputting) {
        loop StrLen(command_mode.func) {
            send("{BackSpace}")
        }
        command_mode.func := ''
        return
    }
    if (to_left()) {
        return
    }
    if (left_list.Length == 0) {
        send("{Left}")
        clear_all()
    }
}


^Enter:: {
    ; 在矩阵外可以用于右移到尽头
    ; 在矩阵内则右移到矩阵的尽头
    if (IsInBrace() and !matrix_mode) { ;改作换行
        send_text('enter', '\atop `n')
        return
    }
    if (!matrix_mode) {
        ending_rightright()
    }
    while to_right('\end{') == true {
    }
}


\:: {
    if (command_mode.is_on) {
        main('\')
        return
    }
    command_mode.set()
}

Space:: {
    if (matrix_mode) {
        if (command_mode.is_on) {
            ; 如果你想在矩阵里开指令那么指令内部敲空格不受矩阵影响
            ; 如果你想在指令里开矩阵那我救不了你
            main('space')
            return
        }
        send_text('right', ' & ')
    } else {
        main('space')
    }

}
Tab:: main('tab')

^Tab:: {
    send_text('tab', '    ')
}


v:: { ; Capture + V 在数学公式块里粘贴
    if (CapsLock_is_being_pressed and !temporary_latex) {
        send_text('Cap+v', 'clipboard')
        return
    }
    main('v')
}
^v:: {  ; 让ctrl+v时黏贴的文本也可以被记录
    send_text('^v', 'clipboard')
}
^b:: {  ; 为选中的文本添加公式块括号
    SendInput("^x")
    clipboardSave := A_clipboard
    if (latex_block_quote.Has(exe_mode)) {
        quote := latex_block_quote[exe_mode]
    } else {
        quote := [' $', '$ ']
    }
    SendText(quote[1])
    Sleep(300)
    OutputDebug(A_clipboard)
    text := Trim(A_clipboard, ' `t$')
    text := Trim(text, ' `t$')
    text := Trim(text, ' `t$')
    ; if(InStr(text,'$$')){
    ;     text := StrReplace(text,'$$','')
    ; }
    SendText(text)
    SendText(quote[2])
    A_Clipboard := clipboardSave
}

; 鼠标选中文本，shift+F1把选中的文本录入到F1键的code
copy_temp(key) {
    ; temp(key,code)
    ; 输入: \temp(3,\sqrt{$^{2}+$^{2}})
    ; 输出: 相当于key_mapping['F3']:= ['\sqrt{$^{2}+$^{2}}']
    clipboardSave := A_clipboard
    send("^c")
    Sleep(100)
    code := Trim(A_clipboard, ' `t$')
    key_mapping[key] := [code]
    IniWrite("'" code " '", 'config.ini', 'temp_mapping', key)
    A_Clipboard := clipboardSave
    gui_twinkle_warning('已录入到' key)
}
+F1:: copy_temp('F1')
+F2:: copy_temp('F2')
+F3:: copy_temp('F3')
+F4:: copy_temp('F4')
+F5:: copy_temp('F5')
+F6:: copy_temp('F6')
+F7:: copy_temp('F7')
+F8:: copy_temp('F8')
+F9:: copy_temp('F9')
+F10:: copy_temp('F10')
+F11:: copy_temp('F11')
+F12:: copy_temp('F12')
; 完毕


a:: main('a')
b:: main('b')
c:: main('c')
d:: main('d')
e:: main('e')
f:: main('f')
g:: main('g')
h:: main('h')
i:: main('i')
j:: main('j')
k:: main('k')
l:: main('l')
m:: main('m')
n:: main('n')
o:: main('o')
p:: main('p')
q:: main('q')
r:: main('r')
s:: main('s')
t:: main('t')
u:: main('u')
w:: main('w')
x:: main('x')
y:: main('y')
z:: main('z')
+a:: main('A')
+b:: main('B')
+c:: main('C')
+d:: main('D')
+e:: main('E')
+f:: main('F')
+g:: main('G')
+h:: main('H')
+i:: main('I')
+j:: main('J')
+k:: main('K')
+l:: main('L')
+m:: main('M')
+n:: main('N')
+o:: main('O')
+p:: main('P')
+q:: main('Q')
+r:: main('R')
+s:: main('S')
+t:: main('T')
+u:: main('U')
+v:: main('V')
+w:: main('W')
+x:: main('X')
+y:: main('Y')
+z:: main('Z')

[:: main('[')
+[:: main('{')
]:: main(']')
+]:: main('}')

+\:: main('|')
`;:: main(';')
+;:: main(':')
':: main('`'')
+':: main('`"')
,:: main(',')
+,:: main('<')
.:: main('.')
+.:: main('>')
/:: main('/')
?:: main('?')

`:: main('``')
+`:: main('~')
1:: main('1')
+1:: main('!')
2:: main('2')
+2:: main('@')
3:: main('3')
+3:: main('#')
$:: main('$')
4:: main('4')
5:: main('5')
+5:: main('%')
6:: main('6')
+6:: main('^')
7:: main('7')
+7:: main('&')
8:: main('8')
+8:: main('*')
9:: main('9')
+9:: main('(')
0:: main('0')
+0:: main(')')
-:: main('-')
+-:: main('_')
+=:: main('+')

numpad0:: main('numpad0')
numpad1:: main('numpad1')
numpad2:: main('numpad2')
numpad3:: main('numpad3')
numpad4:: main('numpad4')
numpad5:: main('numpad5')
numpad6:: main('numpad6')
numpad7:: main('numpad7')
numpad8:: main('numpad8')
numpad9:: main('numpad9')
numpadmult:: main('numpadmult')
numpadadd:: main('numpadadd')
numpadsub:: main('numpadsub')
numpaddot:: main('numpaddot')
numpaddiv:: main('numpaddiv')
numpadenter:: {  ; 此处未兼容指令模式
    if (!matrix_mode) {
        main('numpadenter')
        return
    }

    msg := to_right('\end{')
    if (msg == true) {
        return
    } else if (msg == 'stopped') {
        send_text('enter', '\\ `n')
        return
    }
}
insert:: main('insert')
; delete::main('delete')
home:: main('home')
end:: main('end')
F1:: main('F1')
F2:: main('F2')
F3:: main('F3')
F4:: main('F4')
F5:: main('F5')
F6:: main('F6')
F7:: main('F7')
F8:: main('F8')
F9:: main('F9')
F10:: main('F10')
F11:: main('F11')
F12:: main('F12')
pgup:: main('pgup')
pgdn:: main('pgdn')
up:: main('up')
down:: main('down')

^`:: main('^``')
^6:: main('^6')
^-:: main('^-')
^f:: main('^f')
^+f:: main('^+f')


+up:: main('+up')
+down:: main('+down')
+Left:: main('+left')
+Right:: main('+right')

=:: main('=')
+^9:: main('+^9')
+^0:: main('+^0')
+^[:: main('+^[')
+^]:: main('+^]')

#HotIf


global key_pressed := Map()
for key in input_keys {
    key_pressed[key] := 0
}
def_clear_pressed() {  ; 为每个键定义一个清除函数
    global clear_pressed := Map()
    global key_pressed
    clear_pressed[''] := () => 0
    ; 为什么不能这样写？
    ; for key in input_keys{
    ;     clear_pressed[key] := ()=> key_pressed[key] := 0
    ; }
    ; 因为lambda表达式里的key会变！
    clear_pressed['LAlt'] := () => key_pressed['LAlt'] := 0
    clear_pressed['RAlt'] := () => key_pressed['RAlt'] := 0
    clear_pressed['LCtrl'] := () => key_pressed['LCtrl'] := 0
    clear_pressed['RCtrl'] := () => key_pressed['RCtrl'] := 0
    clear_pressed['space'] := () => key_pressed['space'] := 0
    clear_pressed['tab'] := () => key_pressed['tab'] := 0
    clear_pressed['+^9'] := () => key_pressed['+^9'] := 0
    clear_pressed['+^0'] := () => key_pressed['+^0'] := 0
    clear_pressed['+^['] := () => key_pressed['+^['] := 0
    clear_pressed['+^]'] := () => key_pressed['+^]'] := 0
    clear_pressed['a'] := () => key_pressed['a'] := 0
    clear_pressed['b'] := () => key_pressed['b'] := 0
    clear_pressed['c'] := () => key_pressed['c'] := 0
    clear_pressed['d'] := () => key_pressed['d'] := 0
    clear_pressed['e'] := () => key_pressed['e'] := 0
    clear_pressed['f'] := () => key_pressed['f'] := 0
    clear_pressed['g'] := () => key_pressed['g'] := 0
    clear_pressed['h'] := () => key_pressed['h'] := 0
    clear_pressed['i'] := () => key_pressed['i'] := 0
    clear_pressed['j'] := () => key_pressed['j'] := 0
    clear_pressed['k'] := () => key_pressed['k'] := 0
    clear_pressed['l'] := () => key_pressed['l'] := 0
    clear_pressed['m'] := () => key_pressed['m'] := 0
    clear_pressed['n'] := () => key_pressed['n'] := 0
    clear_pressed['o'] := () => key_pressed['o'] := 0
    clear_pressed['p'] := () => key_pressed['p'] := 0
    clear_pressed['q'] := () => key_pressed['q'] := 0
    clear_pressed['r'] := () => key_pressed['r'] := 0
    clear_pressed['s'] := () => key_pressed['s'] := 0
    clear_pressed['t'] := () => key_pressed['t'] := 0
    clear_pressed['u'] := () => key_pressed['u'] := 0
    clear_pressed['v'] := () => key_pressed['v'] := 0
    clear_pressed['w'] := () => key_pressed['w'] := 0
    clear_pressed['x'] := () => key_pressed['x'] := 0
    clear_pressed['y'] := () => key_pressed['y'] := 0
    clear_pressed['z'] := () => key_pressed['z'] := 0
    clear_pressed['A'] := () => key_pressed['A'] := 0
    clear_pressed['B'] := () => key_pressed['B'] := 0
    clear_pressed['C'] := () => key_pressed['C'] := 0
    clear_pressed['D'] := () => key_pressed['D'] := 0
    clear_pressed['E'] := () => key_pressed['E'] := 0
    clear_pressed['F'] := () => key_pressed['F'] := 0
    clear_pressed['G'] := () => key_pressed['G'] := 0
    clear_pressed['H'] := () => key_pressed['H'] := 0
    clear_pressed['I'] := () => key_pressed['I'] := 0
    clear_pressed['J'] := () => key_pressed['J'] := 0
    clear_pressed['K'] := () => key_pressed['K'] := 0
    clear_pressed['L'] := () => key_pressed['L'] := 0
    clear_pressed['M'] := () => key_pressed['M'] := 0
    clear_pressed['N'] := () => key_pressed['N'] := 0
    clear_pressed['O'] := () => key_pressed['O'] := 0
    clear_pressed['P'] := () => key_pressed['P'] := 0
    clear_pressed['Q'] := () => key_pressed['Q'] := 0
    clear_pressed['R'] := () => key_pressed['R'] := 0
    clear_pressed['S'] := () => key_pressed['S'] := 0
    clear_pressed['T'] := () => key_pressed['T'] := 0
    clear_pressed['U'] := () => key_pressed['U'] := 0
    clear_pressed['V'] := () => key_pressed['V'] := 0
    clear_pressed['W'] := () => key_pressed['W'] := 0
    clear_pressed['X'] := () => key_pressed['X'] := 0
    clear_pressed['Y'] := () => key_pressed['Y'] := 0
    clear_pressed['Z'] := () => key_pressed['Z'] := 0
    clear_pressed['['] := () => key_pressed['['] := 0
    clear_pressed['{'] := () => key_pressed['{'] := 0
    clear_pressed[']'] := () => key_pressed[']'] := 0
    clear_pressed['}'] := () => key_pressed['}'] := 0
    clear_pressed['\'] := () => key_pressed['\'] := 0
    clear_pressed['|'] := () => key_pressed['|'] := 0
    clear_pressed[';'] := () => key_pressed[';'] := 0
    clear_pressed[':'] := () => key_pressed[':'] := 0
    clear_pressed['`''] := () => key_pressed['`''] := 0
    clear_pressed['`"'] := () => key_pressed['`"'] := 0
    clear_pressed[','] := () => key_pressed[','] := 0
    clear_pressed['<'] := () => key_pressed['<'] := 0
    clear_pressed['.'] := () => key_pressed['.'] := 0
    clear_pressed['>'] := () => key_pressed['>'] := 0
    clear_pressed['/'] := () => key_pressed['/'] := 0
    clear_pressed['?'] := () => key_pressed['?'] := 0

    clear_pressed['``'] := () => key_pressed['``'] := 0
    clear_pressed['~'] := () => key_pressed['~'] := 0
    clear_pressed['1'] := () => key_pressed['1'] := 0
    clear_pressed['2'] := () => key_pressed['2'] := 0
    clear_pressed['3'] := () => key_pressed['3'] := 0
    clear_pressed['4'] := () => key_pressed['4'] := 0
    clear_pressed['5'] := () => key_pressed['5'] := 0
    clear_pressed['6'] := () => key_pressed['6'] := 0
    clear_pressed['7'] := () => key_pressed['7'] := 0
    clear_pressed['8'] := () => key_pressed['8'] := 0
    clear_pressed['9'] := () => key_pressed['9'] := 0
    clear_pressed['0'] := () => key_pressed['0'] := 0
    clear_pressed['!'] := () => key_pressed['!'] := 0
    clear_pressed['@'] := () => key_pressed['@'] := 0
    clear_pressed['#'] := () => key_pressed['#'] := 0
    clear_pressed['$'] := () => key_pressed['$'] := 0
    clear_pressed['%'] := () => key_pressed['%'] := 0
    clear_pressed['^'] := () => key_pressed['^'] := 0
    clear_pressed['&'] := () => key_pressed['&'] := 0
    clear_pressed['*'] := () => key_pressed['*'] := 0
    clear_pressed['('] := () => key_pressed['('] := 0
    clear_pressed[')'] := () => key_pressed[')'] := 0
    clear_pressed['-'] := () => key_pressed['-'] := 0
    clear_pressed['_'] := () => key_pressed['_'] := 0
    clear_pressed['='] := () => key_pressed['='] := 0
    clear_pressed['+'] := () => key_pressed['+'] := 0

    clear_pressed['numpad0'] := () => key_pressed['numpad0'] := 0
    clear_pressed['numpad1'] := () => key_pressed['numpad1'] := 0
    clear_pressed['numpad2'] := () => key_pressed['numpad2'] := 0
    clear_pressed['numpad3'] := () => key_pressed['numpad3'] := 0
    clear_pressed['numpad4'] := () => key_pressed['numpad4'] := 0
    clear_pressed['numpad5'] := () => key_pressed['numpad5'] := 0
    clear_pressed['numpad6'] := () => key_pressed['numpad6'] := 0
    clear_pressed['numpad7'] := () => key_pressed['numpad7'] := 0
    clear_pressed['numpad8'] := () => key_pressed['numpad8'] := 0
    clear_pressed['numpad9'] := () => key_pressed['numpad9'] := 0
    clear_pressed['numpadmult'] := () => key_pressed['numpadmult'] := 0
    clear_pressed['numpadadd'] := () => key_pressed['numpadadd'] := 0
    clear_pressed['numpadsub'] := () => key_pressed['numpadsub'] := 0
    clear_pressed['numpaddot'] := () => key_pressed['numpaddot'] := 0
    clear_pressed['numpaddiv'] := () => key_pressed['numpaddiv'] := 0
    clear_pressed['numpadenter'] := () => key_pressed['numpadenter'] := 0
    clear_pressed['F1'] := () => key_pressed['F1'] := 0
    clear_pressed['F2'] := () => key_pressed['F2'] := 0
    clear_pressed['F3'] := () => key_pressed['F3'] := 0
    clear_pressed['F4'] := () => key_pressed['F4'] := 0
    clear_pressed['F5'] := () => key_pressed['F5'] := 0
    clear_pressed['F6'] := () => key_pressed['F6'] := 0
    clear_pressed['F7'] := () => key_pressed['F7'] := 0
    clear_pressed['F8'] := () => key_pressed['F8'] := 0
    clear_pressed['F9'] := () => key_pressed['F9'] := 0
    clear_pressed['F10'] := () => key_pressed['F10'] := 0
    clear_pressed['F11'] := () => key_pressed['F11'] := 0
    clear_pressed['F12'] := () => key_pressed['F12'] := 0

    clear_pressed['insert'] := () => key_pressed['insert'] := 0
    clear_pressed['delete'] := () => key_pressed['delete'] := 0
    clear_pressed['home'] := () => key_pressed['home'] := 0
    clear_pressed['end'] := () => key_pressed['end'] := 0
    clear_pressed['pgup'] := () => key_pressed['pgup'] := 0
    clear_pressed['pgdn'] := () => key_pressed['pgdn'] := 0
    clear_pressed['up'] := () => key_pressed['up'] := 0
    clear_pressed['down'] := () => key_pressed['down'] := 0
    clear_pressed['left'] := () => key_pressed['left'] := 0
    clear_pressed['right'] := () => key_pressed['right'] := 0

    clear_pressed['+up'] := () => key_pressed['+up'] := 0
    clear_pressed['+down'] := () => key_pressed['+down'] := 0
    clear_pressed['+left'] := () => key_pressed['+left'] := 0
    clear_pressed['+right'] := () => key_pressed['+right'] := 0

    clear_pressed['^a'] := () => key_pressed['^a'] := 0
    clear_pressed['^b'] := () => key_pressed['^b'] := 0
    clear_pressed['^c'] := () => key_pressed['^c'] := 0
    clear_pressed['^d'] := () => key_pressed['^d'] := 0
    clear_pressed['^e'] := () => key_pressed['^e'] := 0
    clear_pressed['^f'] := () => key_pressed['^f'] := 0
    clear_pressed['^+f'] := () => key_pressed['^+f'] := 0
    clear_pressed['^g'] := () => key_pressed['^g'] := 0
    clear_pressed['^h'] := () => key_pressed['^h'] := 0
    clear_pressed['^i'] := () => key_pressed['^i'] := 0
    clear_pressed['^j'] := () => key_pressed['^j'] := 0
    clear_pressed['^k'] := () => key_pressed['^k'] := 0
    clear_pressed['^l'] := () => key_pressed['^l'] := 0
    clear_pressed['^m'] := () => key_pressed['^m'] := 0
    clear_pressed['^n'] := () => key_pressed['^n'] := 0
    clear_pressed['^o'] := () => key_pressed['^o'] := 0
    clear_pressed['^p'] := () => key_pressed['^p'] := 0
    clear_pressed['^q'] := () => key_pressed['^q'] := 0
    clear_pressed['^r'] := () => key_pressed['^r'] := 0
    clear_pressed['^s'] := () => key_pressed['^s'] := 0
    clear_pressed['^t'] := () => key_pressed['^t'] := 0
    clear_pressed['^u'] := () => key_pressed['^u'] := 0
    clear_pressed['^v'] := () => key_pressed['^v'] := 0
    clear_pressed['^w'] := () => key_pressed['^w'] := 0
    clear_pressed['^x'] := () => key_pressed['^x'] := 0
    clear_pressed['^y'] := () => key_pressed['^y'] := 0
    clear_pressed['^z'] := () => key_pressed['^z'] := 0
    clear_pressed['^['] := () => key_pressed['^['] := 0
    clear_pressed['^]'] := () => key_pressed['^]'] := 0
    clear_pressed['^\'] := () => key_pressed['^\'] := 0
    clear_pressed['^;'] := () => key_pressed['^;'] := 0
    clear_pressed['^`''] := () => key_pressed['^`''] := 0
    clear_pressed['^,'] := () => key_pressed['^,'] := 0
    clear_pressed['^.'] := () => key_pressed['^.'] := 0
    clear_pressed['^/'] := () => key_pressed['^/'] := 0
    clear_pressed['^``'] := () => key_pressed['^``'] := 0
    clear_pressed['^1'] := () => key_pressed['^1'] := 0
    clear_pressed['^2'] := () => key_pressed['^2'] := 0
    clear_pressed['^3'] := () => key_pressed['^3'] := 0
    clear_pressed['^4'] := () => key_pressed['^4'] := 0
    clear_pressed['^5'] := () => key_pressed['^5'] := 0
    clear_pressed['^6'] := () => key_pressed['^6'] := 0
    clear_pressed['^7'] := () => key_pressed['^7'] := 0
    clear_pressed['^8'] := () => key_pressed['^8'] := 0
    clear_pressed['^9'] := () => key_pressed['^9'] := 0
    clear_pressed['^0'] := () => key_pressed['^0'] := 0
    clear_pressed['^-'] := () => key_pressed['^-'] := 0
    clear_pressed['^='] := () => key_pressed['^='] := 0
    clear_pressed['+up'] := () => key_pressed['+up'] := 0
    clear_pressed['+down'] := () => key_pressed['+down'] := 0
    clear_pressed['+left'] := () => key_pressed['+left'] := 0
    clear_pressed['+right'] := () => key_pressed['+right'] := 0
}
def_clear_pressed()

OutputDebug_Array(arr) {
    if (Type(arr) == "Array") {
        OutputDebug('[')
        for element in arr {
            OutputDebug_Array(element)
        }
        OutputDebug(']')
    } else {
        OutputDebug(arr)
    }
}

IsLetter(str) {
    if (StrLen(str) != 1) {
        return false
    }
    ooo := Ord(str)
    if (ooo >= 65 and ooo <= 90) {
        return true
    }
    if (ooo >= 97 and ooo <= 122) {
        return true
    }
}
IsGreekLetter(str) {
    GreekLetter := [
        '\Gamma ', '\Delta ', '\Theta ', '\Lambda ', '\Xi ', '\Pi ',
        '\Sigma ', '\Upsilon ', '\Phi ', '\Psi ', '\Omega ', '\alpha ',
        '\beta ', '\gamma ', '\delta ', '\epsilon ', '\varepsilon ',
        '\zeta ', '\eta ', '\theta ', '\vartheta ', '\iota ', '\kappa ',
        '\lambda ', '\mu ', '\nu ', '\xi ', '\pi ', '\varpi ', '\rho ',
        '\varrho ', '\sigma ', '\varsigma ', '\tau ', '\upsilon ', '\phi ',
        '\varphi ', '\chi ', '\psi ', '\omega ',
        'Γ', 'Δ', 'Θ', 'Λ', 'Ξ', 'Π',
        'Σ', 'Υ', 'Φ', 'Ψ', 'Ω', 'α',
        'β', 'γ', 'δ', 'ε',
        'ζ', 'η', 'θ', 'ι', 'κ',
        'λ', 'μ', 'ν', 'ξ', 'π', 'ρ',
        'σ', 'τ', 'υ', 'φ',
        'χ', 'ψ', 'ω', 'Ρ']
    ; OutputDebug(str . 'IsGreekLetter')
    for letter in GreekLetter {
        if (str == letter) {
            return true
        }
    }
    return false
}

IsArray_with_num_and_string(arr) {
    if (Type(arr) != "Array") {
        return false
    }
    for eee in arr {
        if (Type(eee) != 'String' and !IsNumber(eee)) {
            return false
        }
    }
    return true
}

IsInBrace() { ; 判断当前位置是否在{}内
    ; 遍历right_list，一旦}的个数多于{的个数，就肯定在括号内
    ; 【证明】每个}一定有一个{与之对应，如果在光标的右边有一个}没有与它对应的{，
    ; 那么这个{一定在光标的左边
    if (matrix_mode) { ; 矩阵里也算
        return true
    }
    count := 0
    for element in right_list {
        text := element.text
        pos := 0
        while 1 {
            pos := InStr(text, '{', false, pos + 1)
            if (pos == 0) {
                break
            }
            count += 1
        }
        pos := 0
        while 1 {
            pos := InStr(text, '}', false, pos + 1)
            if (pos == 0) {
                break
            }
            count -= 1
        }
        if (count < 0) {
            return true
        }
        ; 【提问】万一出现“}{”怎么办？
        ; 那么这个后面的“{”肯定也需要一个“}”与之对应吧
    }
    return false
}

array_has(arr, element) {
    for eee in arr {
        if (eee == element) {
            return A_Index
        }
    }
    return 0
}


gui_blue() {
    for gui_ in MD_gui {
        gui_.BackColor := "68b8eb"
    }
}
gui_blown() {
    for gui_ in MD_gui {
        gui_.BackColor := "53372a"
    }
}

gui_twinkle_warning(text := '') {
    if (text != '') {
        ; 不知为什么非得两次才能生效
        for textGUI in MD_gui.text {
            textGUI.Text := text
        }
    }
    twinkle_downup(MD_gui, 100, 200, 2)
    fun() {
        for textGUI in MD_gui.text {
            textGUI.Text := '`tL a T e X'
        }
    }
    SetTimer(fun, -2000)
}

; Latex功能全部完毕-------------------
