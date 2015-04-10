Remote Shell Env
================

This is just a ghetto shell script that drops you into an SSH session with
a temp dir set up with dotfiles from your local machine set as your home dir.

Move along if you're not cool with sharp edges.  There's a lot of sharp edges.

Usage
-----

`./remote_se.sh manifest_file.lst user@host.com -i ~/.ssh/key_id_rsa`

where `manifest_file.lst` (or another given filename) is a file with
a list of files relative to the directory from which `remote_se` will be called
(probably your home dir)

For example, I'm using something like this

`.remote_manifest.lst`

```
.vimrc
.bashrc
.inputrc
```

Then with this alias:
`alias ssh_se='~/bin/remote_se.sh ~/.remote_manifest.lst '`

I can just `ssh_se user@host` to have an SSH session with my dotfiles available.

Feedback
--------

I can't tell if this is a stupid idea or not. I mean, I'm using it and it 
seems to work so maybe its not all bad, but if there's a better solution to
this problem out there I'm all ears.
