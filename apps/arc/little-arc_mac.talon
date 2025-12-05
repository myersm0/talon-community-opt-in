user.running: arc
os: mac
tag: user.use_app_arc
-
# This assumes that you have not disabled Little Arc
little arc [<user.text>]:
    key("cmd-alt-n")
    sleep(200ms)
    insert(user.text or "")
