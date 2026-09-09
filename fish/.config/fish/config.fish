# Fish entry point. conf.d/*.fish is auto-sourced in order.
# Functions in functions/ are auto-loaded.
# Completions in completions/ are auto-loaded.

# Don't print the welcome message on first run
set -g fish_greeting

# Better default pager
set -gx MANROFFOPT "-c"
set -gx PAGER "less -R"
