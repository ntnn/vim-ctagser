vim-ctagser is a simple approach to handle ctags for system headers.

Install vim-ctagser, ensure you have ctags installed and run
``:CtagsIndex``. vim-ctagser will create a folder (``~/.tags`` by default,
changeable by exporting ``$TAGSDIR``) and instruct ctags to generate
tags for each system header in ``/usr/include`` and
``/usr/local/include``.

Headers in ``/usr/local/include`` take precedence over those in ``/usr/include``.

vim-ctagser compares the modification times of a header and its
corresponding tags file, ensuring that tags are only recreated for
changed files.

Afterwards vim-ctagser will automatically add the appropriate tags-files
to your ``:h 'tags'`` upon opening or reloading a file.

If you want ctags files for your project use vim-gutentags_, which does
a good job at automatically updating your projects' tags files.

.. _vim-gutentags: https://github.com/ludovicchabant/vim-gutentags
