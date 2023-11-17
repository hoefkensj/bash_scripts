# SourcePath
## installation:
```sh
git clone https://github.com/hoefkensj/SourcePath
cd SourcePath
./install.sh
````


HELP:
```help
sourcepath [-h]|[-iqd] [DIR] [MATCH]

ARGS:

<DIR>             Directory to source files from.

<MATCH>           Regex to match Files against. Globbing and Expansion follow Bash Settings

OPTIONS:

-h   --help       Show this help text
-i   --nocase     Ignore Case when matching
-q   --quiet      Quiet/Silent/Script, Dont produce any output
-d   --debug      Enable xtrace for this script
-w   --warning    Shows WARNING: This File Needs to be Sourced not Executed !

EXAMPLES:

Source files in ~/.config/bashrc/ that end in '.bashrc'
...and (-q) do not produce any output:

sourcedir -q ~/.config/bashrc/ '.*\.bashrc'

Source all files in '.env' starting with config case insensitive
...this inlcudes 'CONFIG.cfg' 'conFig.conf' but not 'mycfg.config'

sourcedir -i .env '^config.*'

Source all files in '~/.bash_aliasses/' starting with 2 numbers,
...followed by an '_'. this matches '00_file.alias' but not '99file'

sourcedir ~/.bash_aliasses/ '\/[0-9]{2}_.*$'  :

DEFAULTS:

-MATCH: '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$'
-DIR: '$PWD'
```