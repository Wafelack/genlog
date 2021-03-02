genlog
======

A fully POSIX changelog generator written in bash for repository following the commit rule `<scope>: <description>`.

Installation
------------

* Run the following in your favorite shell.

```bash
$ wget https://raw.githubusercontent.com/Wafelack/genlog/master/genlog.sh \
  chmod 711 genlog.sh \
  sudo cp genlog.sh /usr/bin/
```

Usage
-----

### Creating a changelog for a single version

Usage: `genlog.sh <commit | version_tag>`

### Creating a full changelog

Usage: `genlog.sh`

> TIP: Redirect `stdout` to a file to save your changelog.

License
-------

This program is licensed under the GNU General Public License version 3.0

Acknowledgments
---------------

* Author: Wafelack \<wafelack@protonmail.com>
