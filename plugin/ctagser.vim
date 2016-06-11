" ctagser.vim - add header files
" Maintainer:	Nelo-T. Wallus <nelo@wallus.de>
" License:	MIT

" set TAGSDIR to a default
if $TAGSDIR == '' | let $TAGSDIR = "$HOME/.tags" | endif

com! ListTags call ctagser#list_tags()
com! CtagsIndex call ctagser#index_system()
