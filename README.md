# pass-age

A simple [pass](https://www.passwordstore.org/) extension for displaying password age.

## Usage

```
Usage:
     pass age [-h] pass-names
         Display the age of passwords based on their last commit time
         in the pass git repository.
Options:
     --version        Show version information.
     -h, --help       Print this help message and exit.

     PASSWORD_STORE_AGE_CRITICAL
                      Age in seconds before highlighting in red.
                      Default is 31536000 (1 year).
     PASSWORD_STORE_AGE_WARN
                      Age in seconds before highlighting in yellow.
                      Default is 15552000 (180 days).
```

## Examples

```
$ pass age logins
amazon.com            2 months ago
aur.archlinux.org     2 days ago
facebook.com          6 months ago
github.com            5 days ago
google.com            3 weeks ago
mail.protonmail.com   2 months ago
```
