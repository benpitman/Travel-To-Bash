# Travel To ...

## --------------------- Installation ----------------------

You can either dump the contents of `travel.sh` into your `~/.bashrc` file, or save it somewhere else and source it.
I keep mine in `/usr/local/bin` and at the bottom of `~/.bashrc` I have the line `source /usr/local/bin/travel.sh`.
Then just restart your terminal session.

## ------------------------ Usage -------------------------

Show help
```bash
~:$ tth
~:$ tt -h
~:$ tt --h
~:$ tt -help
~:$ tt --help
```
---
Add a route
```bash
~:$ tta /var/www/html
~:$ tta /usr/local/bin ulb
```
---
List available routes
```bash
~:$ ttl
[html]       = /var/www/html
[ulb]        = /usr/local/bin

~:$ tta /var/log/apache2 logap
~:$ ttl
[html]       = /var/www/html
[logap]      = /var/log/apache2
[ulb]        = /usr/local/bin
```
---
Rename a route
```bash
~:$ ttr html www
~:$ ttl
[logap]      = /var/log/apache2
[ulb]        = /usr/local/bin
[www]        = /var/www/html
```
---
Delete one or more routes
```bash
~:$ ttd www logap
~:$ ttl
[ulb]        = /usr/local/bin
```
---
Travel to a directory using an alias or path
```bash
~:$ tt ulb
/usr/local/bin:$ tt /var/www
/var/www:$ tt
~:$
```
---
`tt` `ttd` and `ttr` support autocomplete
```bash
~:$ tt u<TAB>
~:$ tt ulb<TAB>
~:$ tt /usr/local/bin

~:$ tta /usr/games ug
~:$ ttl
[ulb]        = /usr/local/bin
[ug]         = /usr/games

~:$ tt u<TAB><TAB>
ulb ug
~:$ tt u
```
