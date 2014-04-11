class LauncherItem extends PrefixedItem
    constructor: (@id, @icon, @title)->
        super
        @set_tooltip(@title)
        DCore.signal_connect("launcher_running", =>
            @show(true)
        )
        DCore.signal_connect("launcher_destroy", =>
            @show(false)
        )

    on_click: (e)=>
        super
        DCore.Dock.toggle_launcher(!@__show)

