#Copyright (c) 2011 ~ 2013 Deepin, Inc.
#              2013 ~ 2013 Li Liqiang
#
#Author:      Li Liqiang <liliqiang@linuxdeepin.com>
#Maintainer:  Li Liqiang <liliqiang@linuxdeepin.com>
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


try
    s_dock = get_dbus("session", "com.deepin.dde.dock", "ToggleShow")
catch error
    s_dock = null


class Item extends Widget
    @autostart_flag: null
    @hoverItem: null
    @clean_hover_temp: false
    @dragCanvas: null  # to resize the drag image.
    constructor: (@id, @name, @path, @icon)->
        super
        @element.removeAttribute("id")
        @element.setAttribute("appid", @id)
        @hoverBoxOutter = create_element("div", "hoverBoxOutter", @element)
        @hoverBoxOutter.setAttribute("appid", @id)
        @hoverBox = create_element("div", "hoverBox", @hoverBoxOutter)
        @basename = get_path_name(@path) + ".desktop"
        @isAutostart = false
        @isFavor = false
        @status = SOFTWARE_STATE.IDLE

        @load_image()
        @itemName = create_element("div", "item_name", @hoverBox)
        @itemName.innerText = @name
        @hoverBoxOutter.draggable = true
        # @try_set_title(@element, @name, 80)
        # @element.setAttribute("title", @name)
        @elements = {'element': @element}#favor: null, search: null

    @updateHorizontalMargin:->
        containerWidth = $("#container").clientWidth - GRID_PADDING * 2
        if switcher.isShowCategory
            containerWidth -= GRID_EXTRA_LEFT_PADDING
        # console.log "containerWidth:#{containerWidth}"
        Item.itemNumPerLine = Math.floor(containerWidth / ITEM_WIDTH)
        # console.log "itemNumPerLine: #{Item.itemNumPerLine}"
        Item.horizontalMargin =  (containerWidth - Item.itemNumPerLine * ITEM_WIDTH) / 2 / Item.itemNumPerLine
        # console.log "horizontalMargin: #{Item.horizontalMargin}"
        for own id, info of applications
            info.updateProperty((k, v)->
                v.style.marginLeft = "#{Item.horizontalMargin}px"
                v.style.marginRight = "#{Item.horizontalMargin}px"
            )

    try_set_title: (el, text, width)->
        setTimeout(->
            height = calc_text_size(text, width)
            if height > 38
                el.setAttribute('title', text)
        , 200)

    destroy: ->
        delete @elements['element']
        for own k, v of @elements
            if k == 'favor' or k == 'search'
                @remove(k)
            else
                categoryList.category(k).removeItem(@id)
        delete Widget.object_table[@id]

    add:(pid, parent)->
        if @elements[pid]
            console.log 'exist'
            return @elements[pid]
        if pid == CATEGORY_ID.FAVOR
            pid = 'favor'

        el = @element.cloneNode(true)
        inner = el.firstElementChild.firstElementChild
        im = inner.firstElementChild
        # img may not be loaded.
        if im.classList.length == 1
            im.onload = (e)=>
                @setImageSize(im)

        @elements[pid] = el
        if pid == 'favor'
            @isFavor = true
        else if pid != "search"
            if !parent?
                categoryList.addItem(@id, pid)
        parent?.appendChild(el)
        el

    remove:(pid)->
        el = @elements[pid]
        if not el
            return
        delete @elements[pid]
        pNode = el.parentNode
        pNode.removeChild(el)
        if pid == 'favor' || pid == CATEGORY_ID.FAVOR
            @isFavor = false

    getElement:(pid)->
        if pid == CATEGORY_ID.FAVOR
            pid = 'favor'
        @elements[pid]

    get_img: ->
        im = DCore.get_theme_icon(@icon, ITEM_IMG_SIZE)
        if im == null
            @icon = get_path_name(@path)

        im = DCore.get_theme_icon(@icon, ITEM_IMG_SIZE)
        if im == null
            im = DCore.get_theme_icon(INVALID_IMG, ITEM_IMG_SIZE)

        im

    update: (info)->
        # TODO: update category infos
        # update it.
        if @name != info?.name
            @name = info.name
            @itemName.innerText = @name

        if @path != info?.path
            @path = info.path

        if @basename != info?.basename
            @basename = info.basename

        if @icon != info?.icon
            @icon = info.icon
            im = @get_img()
            @img.src = im

        if @isAutostart != info?.isAutostart
            @toggle_autostart()

        if @status != info?.status
            @status = info.status

    setImageSize: (img)=>
        if img.width == img.height
            # console.log 'set class name to square img'
            img.classList.add('square_img')
        else if img.width > img.height
            img.classList.add('hbar_img')
            new_height = ITEM_IMG_SIZE * img.height / img.width
            grap = (ITEM_IMG_SIZE - Math.floor(new_height)) / 2
            img.style.padding = "#{grap}px 0px"
        else
            img.classList.add('vbar_img')

    load_image: ->
        im = @get_img()
        @img = create_img("item_img", im, @hoverBox)
        # @img.draggable = true
        @img.onload = (e) =>
            @setImageSize(@img)

    on_click: (e)->
        target = e?.target
        target?.style.cursor = "wait"
        e = e && e.originalEvent || e
        e?.stopPropagation()
        startManager.Launch(@basename)
        Item.hoverItem = target.parentNode
        target?.style.cursor = "auto"
        exit_launcher()

    setCanvas:(dt, width, height, xoffset=0, yoffset=0)->
        if Item.dragCanvas == null
            Item.dragCanvas = create_element(tag: 'canvas', width: ITEM_IMG_SIZE, height: ITEM_IMG_SIZE)
        ctx = Item.dragCanvas.getContext("2d")
        ctx.clearRect(0, 0, Item.dragCanvas.width, Item.dragCanvas.height)
        ctx.drawImage(@img, xoffset, yoffset, width, height)
        # extra 3px for mouse offset
        dt.setDragCanvas(Item.dragCanvas, ITEM_IMG_SIZE/2+3, ITEM_IMG_SIZE/2)

    on_dragstart: (e)=>
        # s_dock?.Show()
        # target is hoverBoxOutter
        target = e.target
        o = e
        e = e.originalEvent || e
        dt = e.dataTransfer

        if @img.width < @img.height
            new_width = ITEM_IMG_SIZE * @img.width / @img.height
            offset = (ITEM_IMG_SIZE - Math.floor(new_width)) / 2
            @setCanvas(dt, new_width, ITEM_IMG_SIZE, offse)
        else if @img.width > @img.height
            @img.classList.add('hbar_img')
            new_height = ITEM_IMG_SIZE * @img.height / @img.width
            offset = (ITEM_IMG_SIZE - Math.floor(new_height)) / 2
            @setCanvas(dt, ITEM_IMG_SIZE, new_height, 0, offset)
        # else if @img.width != 48
        #     @setCanvas(dt, ITEM_IMG_SIZE, ITEM_IMG_SIZE)
        else
            @setCanvas(dt, ITEM_IMG_SIZE, ITEM_IMG_SIZE)
            # dt.setDragImage(@img, ITEM_IMG_SIZE/2 + 3, ITEM_IMG_SIZE/2)

        dt.setData("text/uri-list", "file://#{@path}")
        if switcher.isFavor()
            return
        # TODO: drag between favor items
        # console.log 'drag start'
        # grid = target.parentNode.parentNode
        # console.log grid.parentNode.getAttribute("catId")
        # if grid.parentNode.getAttribute("catId") == "#{CATEGORY_ID.FAVOR}"
        #     console.log 'drag favor'
        #     target = target.parentNode
        #     dt.effectAllowed = "move"
        #     dragSrcEl = target
        #     categoryList.favor.indicatorItem = @
        #     # dt.setData("text/html", target.innerHtml)
        #     # TODO: change to animation.
        #     setTimeout(->
        #         target.style.display = 'none'
        #     , 100)
        #     return
        switcher.addedToFavor = false
        item = target.parentNode
        item.classList.add("item_dragged")
        dt.setData("text/plain", @id)
        dt.effectAllowed = "copy"
        categoryBar.dark()
        switcher.bright()

    on_dragend: (e)=>
        # s_dock?.Hide()
        target = e.target
        item = target.parentNode
        item.classList.remove("item_dragged")

        e = e.originalEvent || e
        e.preventDefault()

        categoryBar.normal()
        switcher.normal()

        if !switcher.isShowCategory or !switcher.addedToFavor
            return

        switcher.notify()

    createMenu:->
        @menu = null
        @menu = new Menu(
            DEEPIN_MENU_TYPE.NORMAL,
            new MenuItem(1, _("_Open")),
            new MenuSeparator(),
            new MenuItem(2, FAVOR_MESSAGE[@isFavor]),
            new MenuItem(3, _("Send to d_esktop")).setActive(
                not daemon.IsOnDesktop_sync(@path)
            ),
            new MenuItem(4, _("Send to do_ck")).setActive(s_dock != null),
            new MenuSeparator(),
            new MenuItem(5, AUTOSTART_MESSAGE[@isAutostart]),
            new MenuItem(6, _("_Uninstall"))
        )

        # if DCore.DEntry.internal()
        #     @menu.addSeparator().append(
        #         new MenuItem(100, "report this bad icon")
        #     )

    on_rightclick: (e)->
        DCore.Launcher.force_show(true)
        e = e && e.originalEvent || e
        e.preventDefault()
        e.stopPropagation()

        @createMenu()

        # console.log @menu
        # return
        @menu.unregisterHook(->
            setTimeout(->
                DCore.Launcher.force_show(false)
            , 100)
        )
        @menu.addListener(@on_itemselected).showMenu(e.screenX, e.screenY)

    on_itemselected: (id)=>
        id = parseInt(id)
        switch id
            when 1
                startManager.Launch(@basename)
                # exit_launcher()
            when 2
                if @isFavor
                    console.log 'remove from favor'
                    favor.remove(@id)
                else
                    console.log 'add to favor'
                    if favor.add(@id)
                        switcher.notify()
            when 3 then daemon.SendToDesktop(@path)
            when 4
                try
                    dock = get_dbus(
                        "session",
                        name:"com.deepin.daemon.Dock",
                        path:"/dde/dock/DockedAppManager",
                        interface:"dde.dock.DockedAppManager",
                        "DockedAppList"
                    )
                    console.log(get_path_name(@path))
                    dock.Dock(get_path_name(@path), "", "", "")
                catch e
                    console.log(e)

            when 5 then @toggle_autostart()
            when 6
                if confirm(_("The operation may also remove other applications that depends on the item. Are you sure you want to uninstall the item?", "Launcher"), _("launcher"))
                    @status = SOFTWARE_STATE.UNINSTALLING
                    @hide()
                    categoryList.hideEmptyCategories()
                    uninstalling_apps[@id] = @
                    console.log 'start uninstall'
                    uninstall(item:@, purge:true)
            # when 100 then DCore.DEntry.report_bad_icon(@path)  # internal
        DCore.Launcher.force_show(false)

    updateProperty: (fn)->
        for own k, v of @elements
            if v
                fn(k, v)

    showAutostartFlag:->
        Item.autostart_flag ?= "file://#{DCore.get_theme_icon(AUTOSTART_ICON.NAME,
            AUTOSTART_ICON.SIZE)}"

        @updateProperty((k, v)->
            innerBox = v.firstElementChild.firstElementChild
            last = innerBox.lastElementChild
            if last.tagName != 'IMG'
                create_img("autostart_flag", Item.autostart_flag, innerBox)
            last.style.visibility = 'visible'
        )

    hideAutostartFlag:->
        @updateProperty((k, v)->
            innerBox = v.firstElementChild.firstElementChild
            last = innerBox.lastElementChild
            if last.tagName == 'IMG'
                last.style.visibility = 'hidden'
        )

    add_to_autostart: ->
        # console.log @basename
        if startManager.AddAutostart_sync(@path)
            # console.log 'add success'
            @isAutostart = true
            @showAutostartFlag()

    remove_from_autostart: ->
        if startManager.RemoveAutostart_sync(@path)
            @isAutostart = false
            @hideAutostartFlag()

    toggle_autostart: ->
        if @isAutostart
            @remove_from_autostart()
        else
            @add_to_autostart()

    hide: ->
        @updateProperty((k, v)->
            v.style.display = "none"
        )

    show: =>
        if @status == SOFTWARE_STATE.IDLE
            @updateProperty((k, v)->
                v.style.display = "-webkit-box"
            )

    on_mouseover: (e)=>
        # this event is a wrap, use e.originalEvent to get the original event
        # the target is hoverBoxOutter
        target = e.target
        Item.hoverItem = target.parentNode
        if not Item.clean_hover_temp
            item = target.parentNode
            item.classList.add("item_hovered")

    on_mouseout: (e)=>
        target = e.target
        item = target.parentNode
        item.classList.remove("item_hovered")
