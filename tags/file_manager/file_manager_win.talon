os: windows
tag: user.file_manager
and tag: user.use_file_manager
-
^go {user.letter}$: user.file_manager_open_volume("{letter}:\\")
