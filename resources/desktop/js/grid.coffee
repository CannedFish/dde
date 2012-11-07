#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 snyh
#
#Author:      snyh <snyh@snyh.org>
#             Cole <phcourage@gmail.com>
#Maintainer:  Cole <phcourage@gmail.com>
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

# workarea size
s_width = 0
s_height = 0

# workarea offset
s_x = 0
s_y = 0

# item size
i_width = 80 + 6 * 2
i_height = 84 + 4 * 2

# gird size
cols = 0
rows = 0

# grid html elememt
div_grid = null

o_table = null

selected_item = new Array

# dlclick dealer
last_timestamp = 0
to_blur = 0
last_widget = null


gm = new DeepinMenu()
gi1 = new DeepinMenuItem(1, "New")
gi2 = new DeepinMenuItem(2, "Reorder Icons")
gi3 = new DeepinMenuItem(3, "Desktop Settings")
gm.appendItem(gi1)
gm.appendItem(gi2)
gm.appendItem(gi3)

# update the coordinate of the gird_div to fit the size of the workarea
update_gird_position = (wa_x, wa_y, wa_width, wa_height) ->
    s_x = wa_x
    s_y = wa_y
    s_width = wa_width
    s_height = wa_height

    div_grid.style.left = s_x
    div_grid.style.top = s_y
    div_grid.style.width = s_width
    div_grid.style.height = s_height

    new_cols = Math.floor(s_width / i_width)
    new_rows = Math.floor(s_height / i_height)

    new_table = new Array()
    for i in [0..new_cols]
        new_table[i] = new Array(new_rows)
        if i < cols
            for n in [0..cols]
                new_table[i][n] = o_table[i][n]

    cols = new_cols
    rows = new_rows
    o_table = new_table

load_position = (widget) ->
    localStorage.getObject(widget.path)


update_position = (old_path, new_path) ->
    o_p = localStorage.getObject(old_path)
    localStorage.removeItem(old_path)
    localStorage.setObject(new_path, o_p)


compare_position = (base, pos) ->
    if pos.y < base.y
        return -1
    else if pos.y >= base.y and pos.y <= base.y + base.height - 1
        if pos.x < base.x
            return -1
        else if pos.x >= base.x and pos.x <= base.x + base.width - 1
            0
        else
            return 1
    else
        return 1


clear_occupy = (info) ->
    for i in [0..info.width - 1] by 1
        for j in [0..info.height - 1] by 1
            o_table[info.x+i][info.y+j] = null


set_occupy = (info) ->
    assert(info!=null, "set_occupy")
    for i in [0..info.width - 1] by 1
        for j in [0..info.height - 1] by 1
            o_table[info.x+i][info.y+j] = true
    #draw_grid()


detect_occupy = (info) ->
    assert(info!=null, "detect_occupy")
    for i in [0..info.width - 1] by 1
        for j in [0..info.height - 1] by 1
            if o_table[info.x+i][info.y+j]
                return true
    return false


pixel_to_position = (x, y) ->
    p_x = x - s_x
    p_y = y - s_y
    index_x = Math.floor(p_x / i_width)
    index_y = Math.floor(p_y / i_height)
    echo "#{index_x},#{index_y}"
    return [index_x, index_y]


find_free_position = (w, h) ->
    info = {x:0, y:0, width:w, height:h}
    for i in [0..cols - 1]
        for j in [0..rows - 1]
            if not o_table[i][j]?
                info.x = i
                info.y = j
                return info
    return null


move_to_anywhere = (widget) ->
    info = localStorage.getObject(widget.path)
    if info?
        move_to_position(widget, info)
    else
        info = find_free_position(1, 1)
        move_to_position(widget, info)


move_to_position = (widget, info) ->
    old_info = localStorage.getObject(widget.path)

    if not info?
        info = localStorage.getObject(widget.path)

    if not detect_occupy(info)
            localStorage.setObject(widget.path, info)

            widget.move(info.x * i_width, info.y * i_height)

            if old_info?
                clear_occupy(old_info)
            set_occupy(info)


draw_grid = (ctx) ->
    grid = document.querySelector("#grid")
    ctx = grid.getContext('2d')
    ctx.fillStyle = 'rgba(0, 100, 0, 0.8)'
    for i in [0..cols] by 1
        for j in [0..rows] by 1
            if o_table[i][j]?
                ctx.fillRect(i*i_width, j*i_height, i_width-5, i_height-5)
            else
                ctx.clearRect(i*i_width, j*i_height, i_width-5, i_height-5)


sort_item = ->
    for item, i in $(".item")
        x = Math.floor (i / rows)
        y = Math.ceil (i % rows)
        echo "sort :(#{i}, #{x}, #{y})"


init_grid_drop = ->
    div_grid.addEventListener("drop", (evt) =>
        for file in evt.dataTransfer.files
            pos = pixel_to_position(evt.x, evt.y)
            p_info = {"x": pos[0], "y": pos[1], "width": 1, "height": 1}

            path = DCore.Desktop.move_to_desktop(file.path)
            if path.length > 1
                localStorage.setObject(path, p_info)

        evt.dataTransfer.dropEffect = "move"
    )
    div_grid.addEventListener("dragover", (evt) =>
        evt.dataTransfer.dropEffect = "move"
        evt.preventDefault()
        return false
    )
    div_grid.addEventListener("dragenter", (evt) =>
        #evt.dataTransfer.dropEffect = "move"
    )
    div_grid.addEventListener("dragleave", (evt) =>
        #evt.dataTransfer.dropEffect = "move"
    )


set_item_selected = (w, top = false) ->
    w.item_selected()
    if top = true
        selected_item.unshift(w.id)
    else
        selected_item.push(w.id)
    return


cancel_item_selected = (w) ->
    for i in [0...selected_item.length] by 1
        if selected_item[i] == w.id
            selected_item.splice(i, 1)
            w.item_normal()
            return true
    return false


cancel_item_selected_delay = ->
    echo "on Timeout #{to_blur}"
    to_blur = 0
    cancel_item_selected(last_widget)
    last_widget.item_blur()
    last_widget = null
    return


cancel_all_selected_stats = ->
    Widget.look_up(i)?.item_normal() for i in selected_item
    selected_item.splice(0)
    return


update_selected_stats = (w, env) ->
    if env.ctrlKey
        if selected_item.length == 0
            set_item_selected(w)
            w.item_focus()
        else
            if cancel_item_selected(w)
                last_widget?.item_blur()
                last_widget = null
            else
                set_item_selected(w)
                last_widget?.item_blur()
                w.item_focus()

    else if env.shiftKey
        if selected_item.length > 1
            Widget.look_up(i)?.item_normal() for i in selected_item.splice(0, selected_item.length - 1)

        if selected_item.length == 1
            coord = pixel_to_position(env.x, env.y)
            end_pos = {"x": coord[0], "y": coord[1], "width": 1, "height": 1}
            start_pos = load_position(Widget.look_up(elected_item[0]))

            ret = compare_position(start_pos, end_pos)
            if ret < 0
                for key, val of Widget.object_table
                    i_pos = load_position(val)
                    if compare_position(end_pos, i_pos) > 0 and compare_position(start_pos, i_pos) < 0
                        set_item_selected(val, true)

                    set_item_selected(w)
                    last_widget?.item_blur()
                    w.item_focus()

            else if ret == 0
                cancel_item_selected(selected_item[0])
                last_widget?.item_blur()

            else
                for key, val of Widget.object_table
                    i_pos = load_position(val)
                    if compare_position(start_pos, i_pos) > 0 and compare_position(end_pos, i_pos) < 0
                        set_item_selected(val, true)

                set_item_selected(w)
                last_widget?.item_blur()
                w.item_focus()

        else
            set_item_selected(w)
            w.item_focus()

    else
        if last_widget == w and env.timeStamp - last_timestamp < 200 and to_blur != 0
            echo "clearTimeout #{to_blur}"
            clearTimeout(to_blur)
            to_blur = 0
        else
            if selected_item.length > 1
                cancel_all_selected_stats()
                set_item_selected(w)
                last_widget?.item_blur()
                w.item_focus()

            else if selected_item.length == 1
                if w.selected == true
                    if env.timeStamp - last_timestamp < 200
                        echo "should be a dlclick, no blur"
                    else
                        to_blur = setTimeout(cancel_item_selected_delay, 200)
                        echo "setTimeout #{to_blur}"
                else
                    cancel_all_selected_stats()
                    set_item_selected(w)
                    last_widget?.item_blur()
                    w.item_focus()
            else
                set_item_selected(w)
                last_widget?.item_blur()
                w.item_focus()

    last_widget = w
    last_timestamp = env.timeStamp


gird_left_click = (env) ->
    if env.ctrlKey == false and env.shiftKey == false
        cancel_all_selected_stats()
        if last_widget?
            last_widget.item_blur()
            last_widget = null


grid_right_click = (env) ->
    if env.ctrlKey == false and env.shiftKey == false
        cancel_all_selected_stats()
        if last_widget?
            last_widget.item_blur()
            last_widget = null


create_item_grid = ->
    div_grid = document.createElement("div")
    div_grid.setAttribute("id", "item_grid")
    document.body.appendChild(div_grid)
    update_gird_position(s_x, s_y, s_width, s_height)
    init_grid_drop()
    div_grid.addEventListener("click", gird_left_click)
    div_grid.addEventListener("contextmenu", grid_right_click)
    div_grid.contextMenu = gm
