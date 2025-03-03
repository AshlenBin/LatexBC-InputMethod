**LatexBC输入法**是基于AutoHotKey编写的一款输入法，用于快捷地输入各种Latex公式。本文档将详细介绍LatexBC输入法的安装、使用方法和常用功能。

>tip：从技术上严格来讲不算是“输入法”，因为它并不是一个独立的输入法软件，而是一个基于AutoHotKey的脚本程序。但是能用就完事了。

**注意**：本软件仅支持Windows系统，因为AutoHotkey只支持Windows系统。

**注意**：LatexBC输入法并不能完全取代徒手编码，使用者需要先有一定的Latex使用经验。


## 安装
直接下载库中的`exe`文件，双击运行即可。

如果您想要编写源码，请参考[AutoHotKey官网](https://www.autohotkey.com/)下载安装AutoHotKey解释器。

## 概览
先对`LatexBC输入法`的功能做一个简单的概览，后面会详细介绍每个功能。

**按下“CapsLock”键，打开LatexBC输入法**。这个键平常用于打开大写锁定，但其实按住Shift键也可以大写，所以这个键被我征用了。

首先介绍三个最典型的按键映射：
- 双击『a』输出“\alpha ”【 $\alpha $ 】
- 双击『 / 』输出“\cfrac{？}{？}”【 $\cfrac{？}{？}$ 分式】 
- 双击『 } 』，输出“\begin{cases} ？\end{cases}”【 $\begin{cases} ？\end{cases}$ 方程组】

这三个映射方便代表了Latex里典型的三类公式：
- 单独符号：“\alpha ”【 $\alpha $ 】
- 参数公式：“\cfrac{？}{？}”【 $\cfrac{？}{？}$ 】。与单独符号不同的是，它需要在{}大括号间输入参数。接下来，我们将用“？”代表参数，也就是等待用户输入的内容。
- 块公式：“\begin{cases} x+y=1\\ 2x+3y=0\end{cases}”【 $\begin{cases} x+y=1\\ 2x+3y=0\end{cases}$ 】

手动输入“\frac{？}{？}”是比较麻烦的，因为光标要在两个大括号间反复横跳。而LatexBC输入法可以帮你快速输入这类公式：
- 【 $\cfrac{|}{\Box }$ 】双击『 / 』输出“\cfrac{}{}”，此时光标会停留在第一个大括号里，等待你的输入。
- 【 $\cfrac{a}{|}$ 】当你想要去往下一个大括号时，点按『Enter』，光标会向右跳到第二个大括号里。
- 【 $\cfrac{a}{b}|$ 】编辑完第二个大括号后，点按『Enter』，光标会向右跳到大括号外，编辑结束。

『Enter』也可以是『右方向键』，在不处于“**矩阵/方程组模式**”时，『Enter』和『右方向键』是等效的。

如果你想返回去编辑，可以点按『左方向键』，操作逻辑是一样的。

>**声明**：为了区分“按键”、“输出文本”和“公式符号”，在本说明书中，“按键”用『 』括起来，“输出文本”用“ ”括起来，“公式符号”用【】括起来。

## 功能和使用方法介绍

### `LatexBC输入法`的三种主要输入方式：

#### 1、连击映射：

例：单击『a』输出“a”【$a$】，连击两下输出“\alpha ”【 $\alpha $ 】  
例：单击『 / 』输出“/”【 $/$ 】，连击两下输出“\cfrac{？}{？}”【 $\cfrac{？}{？}$ 】  
例：单击『 ( 』输出“(”【 $($ 】，连击两下输出“\in ”【 $\in $ 】，连击三下输出“\subset ”【 $\subset $ 】

单击也是一种连击，只是连击次数为1，最典型的是上下标：单击『上箭头』输出“^{？}”【 $x^{？}$ 】。下标就是『下箭头』。  


#### 2、联合按键输出：

例：先按『-』再按『>』（也就是『->』）输出“\to ”【 $\to $ 】  
例：先按『=』再按『>』（也就是『=>』）输出“\Rightarrow ”【 $\Rightarrow $ 】  
例：先按『/』再按『=』（也就是『/=』）输出“\neq ”【 $\neq $ 】


#### 3、点按shift转义：（注意是`点按`不是长按哦）

例：先输入『asin』再点按『Shift』输出“\arcsin ”【 $\arcsin $ 】  
例：连击两下输出“\cfrac{？}{？}”【 $\cfrac{？}{？}$ 】，点按『Shift』输出“\frac{？}{？}”【 $\frac{？}{？}$ 】（**大分式变小分式**，再按『Shift』也可以小变大）  
例：先输入『lim』再点按『Shift』输出“\lim\limits_{？\to ？}”【 $\lim\limits_{?\to ?}$ 】

另外，假如你在连击映射时按少了，也可以点按『Shift』增加连击次数，达到一样的效果。  
例：连击两下『 ( 』输出“\in ”【 $\in $ 】，此时点按『Shift』即可输出“\subset ”【 $\subset $ 】

### 其他功能：
#### 左Alt键变括号，右Alt键变+号：
点按『左Alt』键，输出“ ( ”【 $($ 】

双击『左Alt』键，输出“ ) ”【 $)$ 】

点按『右Alt』键，输出“ + ”【 $+$ 】

#### 『Shift+CapsLock』打开输入法的同时输入` $ $ `：
在Markdown中，我们经常需要输入行内公式，用` $ $ `包裹。
所以『Shift+CapsLock』可以在打开输入法的同时输入` $ $ `，可以方便地输入行内公式。（注意，`  $$  `左右会留空格）

在公式编辑完毕后也可以按『Shift+CapsLock』退出，光标会自动右移。

> 警告：有些笔记软件会以不同的形式定义公式块，比如飞书创建公式块的方式是连按`$$$$`，对此我做了专门的适配。然而飞书创建公式块似乎有一套自己的流程，因此有时候会出现“创建了公式块但是光标在公式块外面”的bug，这个是它软件自身问题，我无法解决。

#### 『CapsLock+v』带`$ $`的粘贴：
以往我们粘贴文本用的是『Ctrl+v』，但是在Markdown中，我们输入行内公式通常要带上` $ $ `，所以『CapsLock+v』可以先输入` $ $ `再粘贴文本。

#### 按住『CapsLock』临时快速输入：
有时我们只想简单输入一个符号 $x$ ，此时按住『CapsLock』同时点按『x』，可以跟往常一样输出 $x$ ，但此时松开『CapsLock』，输入法会自动退出。

其他符号同理：按住『CapsLock』同时双击『a』，输出 $\alpha $ 

如果您不介意一只手指一直按在『CapsLock』上的话，输入一大串公式也是可以的 $\sqrt{a^2 +b^2 } =c$ 。

#### 数字上下标：
这是基于“连击映射”的功能。比如：  
- 单击『2』输出“2”【 $2 $ 】  
- 连击两下输出“_2”【 $\Box _2 $ 】  
- 连击三下输出“^2”【 $\Box ^2 $ 】  

**同时，如果你在字母之后输入数字，会自动转成下标。**

例：输入『a2』会自动转成“a_{2}”【 $a_{2}$ 】  
例：输入『\beta 2』会自动转成“\beta _{2}”【 $\beta _{2}$ 】，连击两下变上标【 $\beta ^{2}$ 】

#### 数字+『/』自动转分式：

例：输入『123/』会自动转成“\cfrac{123}{}”【 $\cfrac{123}{|}$ 】


#### 矩阵/方程组模式：
连击三下『 { 』，或连击两下『 } 』，输出“\begin{cases} ？\end{cases}”【 $\begin{cases} ？\end{cases}$ 方程组】

连击三下『 [ 』，或连击两下『 ] 』，输出“\begin{bmatrix} ？\end{bmatrix}”【 $\begin{bmatrix} ？\end{bmatrix}$ 方括号矩阵】

连击三下『 ) 』，输出“\begin{pmatrix} ？\end{pmatrix}”【 $\begin{pmatrix}？ \end{pmatrix}$ 圆括号矩阵】

连击三下『 | 』，输出“\begin{vmatrix} ？\end{vmatrix}”【 $\begin{vmatrix} ？\end{vmatrix}$ 行列式】

在**矩阵/方程组模式**中，
- 单击『空格』可以输出“ & ”，用于分隔矩阵/方程组中的元素。
- 单击『Enter』可以输出“ \\ ”，用于换行。

#### 指令模式：
点按『 \ 』，弹出指令框，输入指令，再点按『Enter』，执行指令。  
常用指令有：
- `list(元素='a',下标=n,间隔符=',',省略号=true)`：快速输出数列
  - `\list(a,[2,n])`：输出 $a_{2} , a_{3} , a_{4} , \dots , a_{n} $
  - 在“元素”中可用@指定下标位置（“下标`index`”不一定是下标，只不过默认是下标）
    - `\list(a^{@},[2,n])`：输出 $a^{2} , a^{3} , a^{4} , \dots , a^{n} $ 
  - “间隔符”可以把`,`替换为其他符号，比如`+`
    - `\list(a,[2,n],+)`：输出 $a_{2} + a_{3} + a_{4} + \dots + a_{n} $ 
    - 不过另一个指令`\sum(a,[2,n])`可以达到一样效果： $a_{2} + a_{3} + a_{4} + \dots + a_{n} $ 
- `n(文本)`：重复文本n次
  - `4(1)`：输出 $1 ,1 ,1 ,1 $ 
  - 一样可以用@指定下标位置（默认无下标）
  - `\4(a_{@})`：输出 $a_{1} , a_{2} , a_{3} , a_{4} $
- `\matrix(元素='a',行='n',列=行,省略号=true)`：快速输出矩阵
  - `\matrix(a,3,5)`：输出3行5列矩阵 $\begin{bmatrix} a_{11} & a_{12} & a_{13} & a_{14} & a_{15}\\ a_{21} & a_{22} & a_{23} & a_{24} & a_{25}\\ a_{31} & a_{32} & a_{33} & a_{34} & a_{35} \end{bmatrix}$ 

输入指令名时会有补全提示，按『Tab』键可以补全。

注意事项：
- `指令名(参数,参数,参数)`：指令名与参数以小括号分隔，参数之间用逗号隔开。
- 下标的取值范围：`[2,8]`表示从2到8的闭区间，包括2和8。注意必须使用方括号！
  - 当下标范围超过5个数时，默认会使用省略号。
  - 对于`[2,n]`这样的写法，一定会使用省略号。
- 点按『Enter』执行指令，但光标必须先移动到指令末尾， `指令名(参数,参数)`的右括号之后。在未左移到末尾时，点按『Enter』和往常功能一样，会右移。

其余指令请查阅文末文档。

####  F1~F12键拷贝：

在打开LatexBC输入法的情况下，选中某段文本，按下『Shift+F1』键，会将选中的文本录入到『F1』键上。此后只要按下『F1』键，就会输出这段文本。这个功能可以用于存储一些常用的公式，方便快速输入。从『F1』到『F12』都可录入。

> 但是录多了可能会记不住，这个功能有待改进

#### 简单字符模式
在“简单字符模式”下，原本输出“\alpha ”会变成输出“α”，输出“\times ”会变成输出“×”，简而言之所有能用单个符号代替的补码都会使用单个符号代替，这样公式看起来会简洁很多。这在市面上大部分笔记软件（比如飞书、幕布）里是不影响显示效果的，然而在专业的Latex编辑器里会出错。

在托盘图标处右键菜单即可打开“简单字符模式”

### 注意事项

#### 在输入时，请尽可能不要使用鼠标。

由于基于AutoHotKey的`LatexBC输入法`的本质是替代用户实现一系列键盘输入，输入完后光标会停留在文本的末尾。所以在输入“\frac{？}{？}”时，**为了能让光标位置停留在第一个问号的位置**，LatexBC输入法实际上进行了这样的操作：先输入“\frac{}{}”，再连按『左方向键』三次。（实际上更复杂些，但姑且这样理解吧）

这样的功能是如何实现的？在于LatexBC输入法在你输入文本时记录下了你的上下文结构。

【所以】LatexBC输入法只能控制你顺序输入的字符，一旦你使用鼠标点击到其他地方，LatexBC输入法无法再掌控你光标左右的文本结构，就会直接清空记录，Enter和左右键也即不再有效。如果你处于矩阵/方程组中，就会直接**退出矩阵/方程组模式**。

所以在使用LatexBC输入法时，请尽可能不要使用鼠标。

#### 在VScode中使用时，请关闭括号补全。

尽管作者已经尽可能用各种设计避免了徒手编码，但它归根结底上只是个AutoHotKey脚本，是在替用户敲键盘，所以在不同的编辑器环境里会遇上各种奇怪bug。作者只能确保它在普通的文本编辑器里能正常使用。

作者目前对LatexBC输入法的高频的使用场景主要在“幕布”和“VScode”中。

在VScode中，由于括号补全功能，会导致在输入『 ( 』时，在输『 ) 』被自动补全，此时『 ) 』不在输入法的记录之内，导致左右移动光标时会移到错误位置。所以请关闭VScode的括号补全功能。

在幕布中，极小概率出现公式末尾“}”号无法删掉的bug，可能是幕布的问题，作者也无法解决。大部分情况下没有问题。





## 附录：映射表
提示：这份表格不必去记忆，因为绝大部分映射都是符合直觉的，比如
  - 双击『a』→ $\alpha $ ，双击『b』→ $\beta $ 都是映射到希腊字母
  - 双击『(』→ $∈$ ，单击『^』→ $∧$ 是形状相似 

警告：这份表格并不实时更新，有些映射可能发生变化，建议在需要用到某个字符时直接在`main.ahk`文件里`ctrl+F`查找，所有的映射都写在`def_keymapping()`函数里。

在按键中，『Ctrl』键用“ ^ ”表示，『Alt』键用“ ! ”表示，『Shift』键用“ + ”表示。比如『+a』表示『Shift+a』。（这是AutoHotKey里对快捷键的表示方法）  
当然，如果你遇到了单独的『+』，『^』，『!』，那就是它本来的意思。  
> 0 表示没有映射，也就是按什么就输出什么.

| 连击映射                 | [单击,双击,三击]                                                    |
| ------------------------ | ------------------------------------------------------------------- |
| 『LAlt』左Alt            | [`(`,`)`]                                                           |
| 『RAlt』右Alt            | [`+`,`+\infty `]                                                    |
| 『RCtrl』                | [`+`,`+\infty `]                                                    |
| 『tab』                  | [`\quad `]                                                          |
| 『space』                | [` `,`\ `]                                                          |
| 『a』                    | [`a`,`\alpha `,`\partial `,`\cfrac{\partial \$}{\partial \$}`]      |
|                          | `\cfrac{\$}{\$}`其中\$表示等待用户输入的位置                        |
| 『A』                    | [`A`,`\forall `]                                                    |
| 『b』                    | [`b`,`\beta `]                                                      |
| 『B』                    | 0                                                                   |
| 『c』                    | [`c`,`\theta `,`\vartheta `]                                        |
| 『C』                    | [`C`,`\Theta `]                                                     |
| 『d』                    | [`d`,`\delta `]                                                     |
| 『D』                    | [`D`,`\Delta `,`\nabla `]                                           |
| 『e』                    | [`e`,`\epsilon `,`\varepsilon `]                                    |
| 『E』                    | [`E`,`\exists `]                                                    |
| 『f』                    | [`f`,`\phi `,`\varphi `]                                            |
| 『F』                    | [`F`,`\Phi `]                                                       |
| 『g』                    | [`g`,`\gamma `]                                                     |
| 『G』                    | [`G`,`\Gamma `]                                                     |
| 『h』                    | [`h`,`\eta `,`\hbar `]                                              |
| 『H』                    | 0                                                                   |
| 『i』                    | [`i`,`\iota `,`\imath `]                                            |
| 『I』                    | 0                                                                   |
| 『j』                    | [`j`,`\jmath `]                                                     |
| 『J』                    | 0                                                                   |
| 『k』                    | [`k`,`\kappa `]                                                     |
| 『K』                    | 0                                                                   |
| 『l』                    | [`l`,`\lambda `,`\ell `]                                            |
| 『L』                    | [`L`,`\Lambda `]                                                    |
| 『m』                    | [`m`,`\mu `]                                                        |
| 『M』                    | 0                                                                   |
| 『N』                    | [`N`,`\aleph `]                                                     |
| 『o』                    | [`o`,`\circ `,`\bullet `,`\bigcirc `] ; 空心圆变实心圆,实心圆变大圆 |
| 『O』                    | 0                                                                   |
| 『p』                    | [`p`,`\pi `,`\frac{\pi}{2}`]                                        |
| 『P』                    | [`P`,`\Pi `]                                                        |
| 『q』                    | [`q`]                                                               |
| 『Q』                    | 0                                                                   |
| 『r』                    | [`r`,`\rho `]                                                       |
| 『R』                    | [`R`,`\Rho `]                                                       |
| 『s』                    | [`s`,`\sigma `]                                                     |
| 『S』                    | [`S`,`\Sigma `]                                                     |
| 『t』                    | [`t`,`\tau `]                                                       |
| 『T』                    | 0                                                                   |
| 『u』                    | [`u`,`\mu `]                                                        |
| 『U』                    | [`U`,`\cup `]                                                       |
| 『v』                    | [`v`,`\nu `,`\upsilon `]                                            |
| 『V』                    | [`V`,`\vee `,`\Upsilon `]                                           |
| 『w』                    | [`w`,`\omega `]                                                     |
| 『W』                    | [`W`,`\Omega `]                                                     |
| 『x』                    | [`x`,`\xi `]                                                        |
| 『X』                    | [`X`,`\chi `]                                                       |
| 『y』                    | [`y`,`\psi `]                                                       |
| 『Y』                    | [`Y`,`\Psi `]                                                       |
| 『z』                    | [`z`,`\zeta `]                                                      |
| 『Z』                    | 0                                                                   |
|                          |                                                                     |
| 『 ( 』                  | [`(`,`\in `,`\subset `]                                             |
| 『 ) 』                  | [`)`,`\left( \$ \right)`,pmatrix_on]                                |
| 『 [ 』                  | [`[`,`\left[ \$ \right]`,bmatrix_on]                                |
| 『 ] 』                  | [`]`,bmatrix_on]                                                    |
| 『 { 』                  | [`{`,`\{ \$ \} `,cases_on]                                          |
| 『}』                    | [`}`,cases_on]                                                      |
| 『                       | 』                                                                  | [` | `,`\| `, vmatrix_on] ; `\left | \$ \right | ` |
| 『:』                    | [`:`,`\because `,`\therefore `]                                     |
| 『'』                    | [`'`]                                                               |
| 『"』                    | [`^{(1)}`,`^{(2)}`,`^{(3)}`,`^{(n)}`]                               |
| 『,』                    | [`,`,`\langle `,`\cdots `]                                          |
| 『<』                    | [`<`,`\leq `,`\ll `]                                                |
| 『.』                    | [`.`,`\rangle `,`\dots `]                                           |
| 『>』                    | [`>`,`\geq `,`\gg `]                                                |
| 『/』                    | [`/`,`\cfrac{\$}{\$}`,`\div `]                                      |
|                          |                                                                     |
| 『~』                    | [`\sim `,`\approx `,`\widetilde{\$} `]                              |
| 『`』                    | [`ˋ`,`^{-1}`]                                                       |
| 『1』                    | [`1`,`_1 `,`^1 `]                                                   |
| 『2』                    | [`2`,`_2 `,`^2 `]                                                   |
| 『3』                    | [`3`,`_3 `,`^3 `]                                                   |
| 『4』                    | [`4`,`_4 `,`^4 `]                                                   |
| 『5』                    | [`5`,`_5 `,`^5 `]                                                   |
| 『6』                    | [`6`,`_6 `,`^6 `]                                                   |
| 『7』                    | [`7`,`_7 `,`^7 `]                                                   |
| 『8』                    | [`8`,`_8 `,`^8 `]                                                   |
| 『9』                    | [`9`,`_9 `,`^9 `]                                                   |
| 『0』                    | [`0`,`_0 `,`^0 `]                                                   |
| 『n』                    | [`n`,`_n `,`^n `]                                                   |
|                          |                                                                     |
| 『!』                    | [`!`,`\lnot `]                                                      |
| 『@』                    | [`\sqrt{\$} `]                                                      |
| 『#』                    | [`\notin `]                                                         |
| 『%』                    | [`\%`,`\bmod `]                                                     |
| 『^』                    | [`\wedge `,`\cap `]                                                 |
| 『&』                    | [`&`,`\land `,`\propto `]                                           |
| 『*』                    | [`\cdot `,`\times `,`*`]                                            |
|                          |                                                                     |
| 『-』                    | [`-`,`-\infty `]                                                    |
| 『_』                    | [`\limits`]                                                         |
| 『+』                    | [`+`,`+\infty `]                                                    |
| 『=』                    | [`=`,`\iff `,`\equiv `]                                             |
|                          |                                                                     |
| 『up』                   | [`^{\$}`]                                                           |
| 『down』                 | [`_{\$}`]                                                           |
| 『+right』               | [`\overrightarrow{\$}`]                                             |
| 『+left』                | [`\overleftarrow{\$}`]                                              |
| 『+up』                  | [`\limits^{\$}`]                                                    |
| 『+down』                | [`\limits_{\$}`]                                                    |
| 『^`』                   | [`\widetilde{\$}`]                                                  |
| 『^6』                   | [`\widehat{\$}`]                                                    |
| 『^-』                   | [`\underline{\$}`,`\overline{\$}`]                                  |
| 『^[』                   | [`\underbrace{\$}`,`\overbrace{\$}`]                                |
| 『!left』                | [`\gets `,`\Leftarrow `]                                            |
| 『!right』               | [`\to `,`\Rightarrow `]                                             |
| 『!up』                  | [`\uparrow `,`\Uparrow `]                                           |
| 『!down』                | [`\downarrow `,`\Downarrow `]                                       |
| 『^f』                   | [`\int `,`\iint\limits_{\$} `,`\iiint\limits_{\$} `]                |
| 『numpad0』              | [`0`]                                                               |
| 『numpad1』              | [`1`]                                                               |
| 『numpad2』              | [`2`]                                                               |
| 『numpad3』              | [`3`]                                                               |
| 『numpad4』              | [`4`]                                                               |
| 『numpad5』              | [`5`]                                                               |
| 『numpad6』              | [`6`]                                                               |
| 『numpad7』              | [`7`]                                                               |
| 『numpad8』              | [`8`]                                                               |
| 『numpad9』              | [`9`]                                                               |
| 『numpadadd』            | [`+`,`\oplus `]                                                     |
| 『numpaddiv』            | [`\div `,`\oslash `]                                                |
| 『numpadmult』           | [`\times `,`\otimes `]                                              |
| 『numpadsub』            | [`-`, `\ominus `]                                                   |
| 『numpadenter』          | [`=`]                                                               |
| 『numpaddot』            | [`.`]                                                               |
|                          |                                                                     |
|                          |                                                                     |
| 联合按键映射             |                                                                     |
| 『^{\$}down』            | `^{\$}_{\$}`                                                        |
| 『_{\$}up』              | `^{\$}_{\$}`                                                        |
| 『\gets !right』         | `#\leftrightarrow `                                                 |
| 『\to !left』            | `#\leftrightarrow `                                                 |
| 『/=』                   | `#\ne `                                                             |
| 『/~』                   | `#\nsim `                                                           |
| 『\sim /』               | `#\nsim `                                                           |
| 『\in /』                | `#\notin `                                                          |
| 『+-』                   | `\pm `                                                              |
| 『-+』                   | `\mp `                                                              |
| 『->』                   | `#\to `                                                             |
| 『=>』                   | `#\Rightarrow `                                                     |
| 『<=』                   | `#\Leftarrow `                                                      |
| 『=.』                   | `\frac{?}{\quad }\ `                                                |
| 『.=』                   | `\frac{?}{\quad }\ `                                                |
| 『\gets /』              | `#\nleftarrow `                                                     |
| 『\to /』                | `#\nrightarrow `                                                    |
| 『\gets up』             | `#\$\xleftarrow{\$}`                                                |
| 『\gets !up』            | `#\$\xleftarrow{\$}`                                                |
| 『\to up』               | `#\$\xrightarrow{\$}`                                               |
| 『\to !up』              | `#\$\xrightarrow{\$}`                                               |
| 『\gets down』           | `#\$\xleftarrow[\$]{\$}`                                            |
| 『\gets !down』          | `#\$\xleftarrow[\$]{\$}`                                            |
| 『\to down』             | `#\$\xrightarrow[\$]{\$}`                                           |
| 『\to !down』            | `#\$\xrightarrow[\$]{\$}`                                           |
| 『0/』                   | `\emptyset `                                                        |
| 『\subset =』            | `#\subseteq `                                                       |
| 『\supset =』            | `#\supseteq `                                                       |
| 『\sim -』               | `\simeq `                                                           |
| 『-~』                   | `\simeq `                                                           |
| 『\sim =』               | `\cong `                                                            |
| 『=~』                   | `\cong `                                                            |
|                          |                                                                     |
| 『ex』                   | `e^{x} `                                                            |
| 『'=』                   | `\overset{_{'}\quad }{=}`                                           |
| 『\int =』               | `#\overset{_{\int}\quad}{=}`                                        |
|                          |                                                                     |
| 『dx』                   | `\mathrm{d}x`                                                       |
| 『dy』                   | `\mathrm{d}y`                                                       |
| 『dz』                   | `\mathrm{d}z`                                                       |
| 『dt』                   | `\mathrm{d}t`                                                       |
| 『du』                   | `\mathrm{d}u`                                                       |
| 『dv』                   | `\mathrm{dv}`                                                       |
| 『dr』                   | `\mathrm{d}r`                                                       |
| 『\cdot O』              | `#\odot `                                                           |
| 『\times O』             | `#\otimes `                                                         |
| 『+O』                   | `#\oplus `                                                          |
| 『-O』                   | `#\ominus `                                                         |
| 『\div O』               | `#\oslash `                                                         |
| 『/O』                   | `#\oslash `                                                         |
|                          |                                                                     |
| ; 点按shift转义映射      |                                                                     |
| 『d』                    | `\mathrm{d}`                                                        |
| 『\cdots 』              | `\vdots `                                                           |
| 『\dots 』               | `\vdots `                                                           |
| 『\bigvee 』             | `\vee `                                                             |
| 『\vee 』                | `\bigvee `                                                          |
| 『\bigwedge 』           | `\wedge `                                                           |
| 『\wedge 』              | `\bigwedge `                                                        |
| 『\bigcup 』             | `\cup `                                                             |
| 『\cup 』                | `\bigcup `                                                          |
| 『\bigcap 』             | `\cap `                                                             |
| 『\cap 』                | `\bigcap `                                                          |
| 『\pm 』                 | `\mp `                                                              |
| 『\mp 』                 | `\pm `                                                              |
| 『(』                    | `)`                                                                 |
| 『)』                    | `(`                                                                 |
| 『[』                    | `\left[ \$ \right] `                                                |
| 『\{』                   | `\left\{ \$ \right\} `                                              |
| 『e^{x} 』               | `e^{-x} `                                                           |
|                          |                                                                     |
| 『\int 』                | `\oint\limits_{\$} `                                                |
| 『\iint\limits_{\$} 』   | `\oiint\limits_{\$} `                                               |
| 『\iiint\limits_{\$} 』  | `\oiiint\limits_{\$} `                                              |
|                          |                                                                     |
| 『\max 』                | `\max\limits_{\$} `                                                 |
| 『\min 』                | `\min\limits_{\$} `                                                 |
|                          |                                                                     |
| 依旧是 点按shift转义映射 | 当你写下`asin`，并紧跟一个shift时，会自动替换为`\arcsin `           |
| 『or』                   | `\lor `                                                             |
| 『and』                  | `\land `                                                            |
| 『not』                  | `\lnot `                                                            |
| 『in』                   | `\in `                                                              |
| 『xor』                  | `\oplus `                                                           |
| 『xnor』                 | `\odot `                                                            |
|                          |                                                                     |
| 『inf』                  | `\infty  `                                                          |
| 『dim』                  | `\dim `                                                             |
| 『sin』                  | `\sin `                                                             |
| 『arcsin』               | `\arcsin `                                                          |
| 『asin』                 | `\arcsin `                                                          |
| 『arcs』                 | `\arcsin `                                                          |
| 『cos』                  | `\cos `                                                             |
| 『arccos』               | `\arccos `                                                          |
| 『acos』                 | `\arccos `                                                          |
| 『arcc』                 | `\arccos `                                                          |
| 『tan』                  | `\tan `                                                             |
| 『arctan』               | `\arctan `                                                          |
| 『atan』                 | `\arctan `                                                          |
| 『arct』                 | `\arctan `                                                          |
| 『cot』                  | `\cot `                                                             |
| 『sec』                  | `\sec `                                                             |
| 『csc』                  | `\csc `                                                             |
| 『sinh』                 | `\sinh `                                                            |
| 『cosh』                 | `\cosh `                                                            |
| 『tanh』                 | `\tanh `                                                            |
| 『coth』                 | `\coth `                                                            |
| 『ln』                   | `\ln `                                                              |
| 『log』                  | `\log _{\$}`                                                        |
| 『sqrt_3 』              | `\sqrt[3]{\$}`                                                      |
| 『sqrtn』                | `\sqrt[n]{\$}`                                                      |
| 『sqrt』                 | `\sqrt[\$]{\$}`                                                     |
| 『lim』                  | `\lim\limits_{\$\to \$}`                                            |
| 『lim_8 』               | `\lim\limits_{\$ \to \infty}`                                       |
| 『lim_0 』               | `\lim\limits_{\$ \to 0}`                                            |
| 『limx』                 | `\lim\limits_{x\to \$}`                                             |
| 『limn』                 | `\lim\limits_{n\to \$}`                                             |
| 『sum』                  | `\sum\limits_{\$}^{\$}`                                             |
| 『sum_8 』               | `\sum\limits_{n=1}^{\infty}`                                        |
| 『vec』                  | `\vec{\$}`                                                          |
| 『max』                  | `\max `                                                             |
| 『min』                  | `\min `                                                             |
| 『argmax』               | `\argmax `                                                          |
| 『argmin』               | `\argmin `                                                          |
|                          |                                                                     |
| 『sa』                   | `\cfrac{\sin x}{x}`                                                 |
| 『fx』                   | `f(x)`                                                              |
| 『gx』                   | `g(x)`                                                              |
| 『hx』                   | `h(x)`                                                              |
|                          |                                                                     |
| 『d/d』                  | `\cfrac{d\$}{d\$}`                                                  |
| 『p/p』                  | `\cfrac{\partial \$}{\partial \$}`                                  |
|                          |                                                                     |
| 『xy_2 』                | `x^{2}+y^{2}`                                                       |
| 『xyz_2 』               | `x^{2}+y^{2}+z^{2}`                                                 |
| 『xyz』                  | `(x,y,z)`                                                           |

