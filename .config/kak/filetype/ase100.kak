provide-module ase100syntax %&
  add-highlighter shared/ase100 regions
  add-highlighter shared/ase100/ region "//" '\n' fill comment
  add-highlighter shared/ase100/string region '"' '"' group
  add-highlighter shared/ase100/string/ fill string
  add-highlighter shared/ase100/string/ \
    regex (\\[\\abefhnrtv\n])|(\\.) 1:keyword 2:Error
  add-highlighter shared/ase100/char region "'" "'" group
  add-highlighter shared/ase100/char/ fill string
  add-highlighter shared/ase100/other default-region group
  add-highlighter shared/ase100/other/ \
    regex ^\w[\w_\d]* 0:function
  add-highlighter shared/ase100/other/ \
    regex \W\K-?[0-9]+ 0:value
  add-highlighter shared/ase100/other/ \
    regex 0x[1-9a-f][0-9a-f]* 0:value
  add-highlighter shared/ase100/other/ \
    regex \b(halt|add|sub|mult|div|cp|cpdata|and|or|not|sl|sr|cpfa|cpta|be|bne|blt|call|ret)\b 0:keyword
  add-highlighter shared/ase100/other/ \
    regex (\x23\w+)[^\n]* 1:meta
&

hook global WinSetOption filetype=ase100 %{
  require-module ase100syntax

  add-highlighter window/ase100 ref ase100

  hook -group "ase100-indent" window InsertChar \n ase100-insert-on-newline
  hook -group "ase100-indent" window InsertChar \n ase100-indent-on-newline

  hook -once -always window WinSetOption filetype=.* %{
    remove-highlighter window ase100
    remove-hooks window ase100-.+
  }
}

# stolen from c-family.kak
define-command -hidden ase100-indent-on-newline %< evaluate-commands -draft -itersel %<
  execute-keys <semicolon>
  try %<
    # if previous line is part of a comment, do nothing
    execute-keys -draft <a-?>/\*<ret> <a-K>^\h*[^/*\h]<ret>
  > catch %<
    # else if previous line closed a paren (possibly followed by words and a comment),
    # copy indent of the opening paren line
    execute-keys -draft kx 1s(\))(\h+\w+)*\h*(\;\h*)?(?://[^\n]+)?\n\z<ret> m<a-semicolon>J <a-S> 1<a-&>
  > catch %<
    # else indent new lines with the same level as the previous one
    execute-keys -draft K <a-&>
  >
  # remove previous empty lines resulting from the automatic indent
  try %< execute-keys -draft k x <a-k>^\h+$<ret> Hd >
  # indent after an opening brace or parenthesis at end of line
  try %< execute-keys -draft k x <a-k>[{(]\h*$<ret> j <a-gt> >
  # indent after a label
  try %< execute-keys -draft k x s[a-zA-Z0-9_-]+:\h*$<ret> j <a-gt> >
  # indent after a statement not followed by an opening brace
  try %< execute-keys -draft k x s\)\h*(?://[^\n]+)?\n\z<ret> \
                 <a-semicolon>mB <a-k>\A\b(if|for|while)\b<ret> <a-semicolon>j <a-gt> >
  try %< execute-keys -draft k x s \belse\b\h*(?://[^\n]+)?\n\z<ret> \
                 j <a-gt> >
  # deindent after a single line statement end
  try %< execute-keys -draft K x <a-k>\;\h*(//[^\n]+)?$<ret> \
                 K x s\)(\h+\w+)*\h*(//[^\n]+)?\n([^\n]*\n){2}\z<ret> \
                 MB <a-k>\A\b(if|for|while)\b<ret> <a-S>1<a-&> >
  try %< execute-keys -draft K x <a-k>\;\h*(//[^\n]+)?$<ret> \
                 K x s \belse\b\h*(?://[^\n]+)?\n([^\n]*\n){2}\z<ret> \
                 <a-S>1<a-&> >
  # deindent closing brace(s) when after cursor
  try %< execute-keys -draft x <a-k> ^\h*[})] <ret> gh / [})] <esc> m <a-S> 1<a-&> >
  # align to the opening parenthesis or opening brace (whichever is first)
  # on a previous line if its followed by text on the same line
  try %< evaluate-commands -draft %<
    # Go to opening parenthesis and opening brace, then select the most nested one
    try %< execute-keys [c [({],[)}] <ret> >
    # Validate selection and get first and last char
    execute-keys <a-k>\A[{(](\h*\S+)+\n<ret> <a-K>"(([^"]*"){2})*<ret> <a-K>'(([^']*'){2})*<ret> <a-:><a-semicolon>L <a-S>
    # Remove possibly incorrect indent from new line which was copied from previous line
    try %< execute-keys -draft , <a-h> s\h+<ret> d >
    # Now indent and align that new line with the opening parenthesis/brace
    execute-keys 1<a-&> &
   > >
> >

define-command -hidden ase100-insert-on-newline %[ evaluate-commands -itersel -draft %[
  execute-keys <semicolon>
  try %[
    evaluate-commands -draft -save-regs '/"' %[
      # copy the commenting prefix
      execute-keys -save-regs '' k x1s^\h*(//+\h*)<ret> y
      try %[
        # if the previous comment isn't empty, create a new one
        execute-keys x<a-K>^\h*//+\h*$<ret> jxs^\h*<ret>P
      ] catch %[
        # if there is no text in the previous comment, remove it completely
        execute-keys d
      ]
    ]

    # trim trailing whitespace on the previous line
    try %[ execute-keys -draft k x s\h+$<ret> d ]
  ]
  try %[
    # if the previous line isn't within a comment scope, break
    execute-keys -draft kx <a-k>^(\h*/\*|\h+\*(?!/))<ret>

    # find comment opening, validate it was not closed, and check its using star prefixes
    execute-keys -draft <a-?>/\*<ret><a-H> <a-K>\*/<ret> <a-k>\A\h*/\*([^\n]*\n\h*\*)*[^\n]*\n\h*.\z<ret>

    try %[
      # if the previous line is opening the comment, insert star preceeded by space
      execute-keys -draft kx<a-k>^\h*/\*<ret>
      execute-keys -draft i*<space><esc>
    ] catch %[
       try %[
        # if the next line is a comment line insert a star
        execute-keys -draft jx<a-k>^\h+\*<ret>
        execute-keys -draft i*<space><esc>
      ] catch %[
        try %[
          # if the previous line is an empty comment line, close the comment scope
          execute-keys -draft kx<a-k>^\h+\*\h+$<ret> x1s\*(\h*)<ret>c/<esc>
        ] catch %[
          # if the previous line is a non-empty comment line, add a star
          execute-keys -draft i*<space><esc>
        ]
      ]
    ]

    # trim trailing whitespace on the previous line
    try %[ execute-keys -draft k x s\h+$<ret> d ]
    # align the new star with the previous one
    execute-keys Kx1s^[^*]*(\*)<ret>&
  ]
] ]
