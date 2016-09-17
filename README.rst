vim-ctagser is a rough, manual but simple approach to handling
ctags-files for system headers.

Install vim-ctagser, ensure you have ctags installed and run
``:CtagsIndex``. vim-ctagser will create a folder (``~/.tags`` by default,
changeable by exporting ``$TAGSDIR``) and place instruct ctags to generate
tags files for each system header in ``/usr/include`` and
``/usr/local/include`` (headers in ``/usr/local/include`` take
precedence over those in ``/usr/include``).

When you update or install new libraries run ``:CtagsIndex`` again. It
will only update tags files for changes headers.

Afterwards ctags will automatically add the appropriate tags-files to
your ``:h 'tags'`` upon opening or reloading a file.

If you want tags file for your project use vim-gutentags_, which does
a good job at automatically updating your projects' tags files.

.. _vim-gutentags: https://github.com/ludovicchabant/vim-gutentags
