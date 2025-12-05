app: windows_explorer
app: windows_file_browser
tag: user.use_app_windows_explorer
-
tag(): user.address
tag(): user.file_manager
tag(): user.navigation

go app data: user.file_manager_open_directory("%AppData%")
go program files: user.file_manager_open_directory("%ProgramFiles%")
