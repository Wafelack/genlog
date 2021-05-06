genlog
======

A simple changelog generator written in Perl.

Installation
------------

* Run the following as root in your favorite shell.

```
wget https://raw.githubusercontent.com/Wafelack/genlog/master/genlog.pl \
  chmod 711 genlog.pl \
  cp genlog.pl /usr/bin/
```

Usage
-----

`genlog.pl [--hash HASH] [--title TITLE]`

If no `HASH` is specified, the changelog will be generated since the first commit.
If no `TITLE` is specified, the changelog title will be `Changelog from {HASH} to HEAD.`.

License
-------

This program is licensed under the GNU General Public License version 3.0

Acknowledgments
---------------

* Author: Wafelack \<wafelack@protonmail.com>
