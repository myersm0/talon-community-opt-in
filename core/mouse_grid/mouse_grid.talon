tag: user.mouse_grid_enabled
and tag: user.use_mouse_grid
-
M grid:
    app.notify("please use the voice command 'mouse grid' instead of 'm grid'")
    user.grid_select_screen(1)
    user.grid_activate()
