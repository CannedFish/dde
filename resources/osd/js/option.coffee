#Copyright (c) 2011 ~ 2014 Deepin, Inc.
#              2011 ~ 2014 bluth
#
#encoding: utf-8
#Author:      bluth <yuanchenglu@linuxdeepin.com>
#Maintainer:  bluth <yuanchenglu@linuxdeepin.com>
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

class Option extends Widget
    constructor:(@id)->
        super
        echo "new Option:#{@id}"
        _b.appendChild(@element)

    hide:->
        @element.style.Option = "none"
    
    set_bg:(imgName)->
        @element.style.backgroundImage = "url(img/#{imgName}.png)"
    
    show:->
        clearTimeout(@timepress) if @timepress
        @timepress = setTimeout(=>
            clearTimeout(timeout_osdHide) if timeout_osdHide
            
            echo "Option #{@id} show"
            osdShow()
            @element.style.display = "block"
            @set_bg(@id)

            timeout_osdHide = setTimeout(=>
                osdHide()
            ,TIME_HIDE)
        ,TIME_PRESS)


OptionCls = null

CapsLockOn = (keydown)->
    if !keydown then return
    echo "CapsLockOn"
    OptionCls  = new Option("Option") if not OptionCls?
    OptionCls.id = "CapsLockOn"
    OptionCls.show()

CapsLockOff = (keydown)->
    if !keydown then return
    echo "CapsLockOff"
    OptionCls  = new Option("Option") if not OptionCls?
    OptionCls.id = "CapsLockOff"
    OptionCls.show()

NumLockOn = (keydown)->
    if !keydown then return
    echo "NumLockOn"
    OptionCls  = new Option("Option") if not OptionCls?
    OptionCls.id = "NumLockOn"
    OptionCls.show()

NumLockOff = (keydown)->
    if !keydown then return
    echo "NumLockOff"
    OptionCls  = new Option("Option") if not OptionCls?
    OptionCls.id = "NumLockOff"
    OptionCls.show()

DBusMediaKey.connect("CapsLockOn",CapsLockOn) if DBusMediaKey?
DBusMediaKey.connect("CapsLockOff",CapsLockOff) if DBusMediaKey?
DBusMediaKey.connect("NumLockOn",NumLockOn) if DBusMediaKey?
DBusMediaKey.connect("NumLockOff",NumLockOff) if DBusMediaKey?
