#Copyright (c) 2011 ~  Deepin, Inc.
#              2013 ~ Lee Liqiang
#
#Author:      Lee Liqiang <liliqiang@linuxdeepin.com>
#Maintainer:  Lee Liqiang <liliqiang@linuxdeepin.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, see <http://www.gnu.org/licenses/>.


DCore.signal_connect('workarea_changed', (alloc)->
    height = alloc.height
    _b.style.maxHeight = "#{height}px"
    # $('#grid').style.maxHeight = "#{height-60}px"
    $('#container').style.maxHeight = "#{height - CONTAINER_BOTTOM_MARGIN - SEARCH_BAR_HEIGHT}px"
    $('#grid').style.height = "#{height - CONTAINER_BOTTOM_MARGIN - SEARCH_BAR_HEIGHT}px"
    $('#searchResult').style.height = "#{height - CONTAINER_BOTTOM_MARGIN - SEARCH_BAR_HEIGHT}px"
    category_column_adaptive_height()

    # hidden_icon_ids = _get_hidden_icons_ids()
    # count = 0
    # for i in category_infos[CATEGORY_ID.ALL]
    #     if i not in hidden_icon_ids
    #         count += 1
    # _update_scroll_bar(count)
)


DCore.signal_connect("lost_focus", (info)->
    if s_dock.LauncherShouldExit_sync(info.xid)
        exit_launcher()
)


DCore.signal_connect("exit_launcher", ->
    reset()
)


# DCore.signal_connect("draw_background", (info)->
#     img = new Image()
#     img.src = info.path
#     img.onload = ->
#         _b.style.backgroundImage = "url(#{img.src})"
# )


# DCore.signal_connect("uninstall_failed", (info)->
#     if (item = uninstalling_apps[info.id])?
#         echo "#{info.id} uninstall failed"
#         item.status = SOFTWARE_STATE.IDLE
#         item.show()
#     delete uninstalling_apps[info.id]
# )


# DCore.signal_connect("autostart_update", (info)->
#     if (app = Widget.look_up(info.id))?
#         if DCore.Launcher.is_autostart(app.core)
#             # echo 'add'
#             app.add_to_autostart()
#         else
#             # echo 'delete'
#             app.remove_from_autostart()
# )


DCore.Launcher.notify_workarea_size()
