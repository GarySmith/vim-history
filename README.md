# vim-history

This plugin adds the ability to save a local history of all changes to particular files.  
Changes are tracked in a local git repository created for this purpose.

## Features

* Create a local git repository for file history
* Command suitable for autocmd usage for capturing all file saves

More to come:
* [ ] Ability to create local history repo at same level as an existing git repo
* [ ] Support for editing a file in a different directory tree from curdir
* [ ] Window to display file history, including showing diffs and restoring a particular saved version
* [ ] Example autocmd for saving history entries when a file is modified externally (FileChangedShell)
* [ ] Handle permission issues when attempting to write to save history owned by another user

## Commands

### HistorySave

This command is intended to be used in an `autocmd`, and will track the change in the local history.  
The following example triggers saving history of all saves of python files.
```
  autocmd BufWritePost *.py HistorySave
```

## Options

### g:history_dir

The directory in which local file history will be saved.  Defaults to `.local_history`.

## License

Copyright (c) Gary W. Smith. Distributed under the same terms as Vim itself. See :help license.
