tag: user.command_search
and tag: user.use_command_search
-
^please [<user.text>]$: user.command_search(user.text or "")
