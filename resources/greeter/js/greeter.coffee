#Copyright (c) 2011 ~ 2013 Deepin, Inc.
#              2011 ~ 2013 yilang
#
#Author:      LongWei <yilang2007lw@gmail.com>
#Maintainer:  LongWei <yilang2007lw@gmail.com>
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

class Greeter extends Widget

    constructor:->
        super
        echo "Greeter"


    webview_ok:(_current_user)->
        DCore.Greeter.webview_ok(_current_user.id) if hide_face_login

    start_login_connect:(_current_user)->
        DCore.signal_connect("start-login", ->
            # echo "receive start login"
            # TODO: maybe some animation or some reflection.
            _current_user.is_recognizing = false
            DCore.Greeter.start_session(_current_user.id, _current_user.password, _current_user.session)
        )

    mousewheel_listener:(user)->
        document.body.addEventListener("mousewheel", (e) =>
            if not is_volume_control
                if e.wheelDelta >= 120 then user?.switchtonext_userinfo()
                else if e.wheelDelta <= -120 then user?.switchtoprev_userinfo()
        )


    keydown_listener:(e,user)->
        echo "greeter keydown_listener"
        if e.which == LEFT_ARROW
            user?.switch_userinfo("next")
        else if e.which == RIGHT_ARROW
            user?.switch_userinfo("prev")

    isOnlyOneSession:->
        @sessions = DCore.Greeter.get_sessions()
        @is_one_session = false
        if @sessions.length == 0
            echo "your system has no session!!!"
            warning_text = _("Your system has no session! Please go to tty and install session:'sudo apt-get install deepin-desktop-environment'")
            noSessionText = create_element("div","noSessionText",@element)
            noSessionText.innerText = warning_text
        else if @sessions.length == 1 then @is_one_session = true
       


greeter = new Greeter()
setBodyWallpaper("sky_move")
greeter.isOnlyOneSession()

desktopmenu = null
if greeter.sessions.length == 0 then return
else if greeter.sessions.length > 1
    desktopmenu = new DesktopMenu($("#div_desktop"))
    desktopmenu.new_desktop_menu()


user = new User()
$("#div_users").appendChild(user.element)
user.new_userinfo_for_greeter()
user.prev_next_userinfo_create() if user.userinfo_all.length > 1

left = (screen.width  - $("#div_users").clientWidth) / 2
top = (screen.height  - $("#div_users").clientHeight) / 2 * 0.8
$("#div_users").style.left = "#{left}px"
$("#div_users").style.top = "#{top}px"

userinfo = user.get_current_userinfo()
_current_user = user.get_current_userinfo()

greeter.start_login_connect(userinfo)
greeter.webview_ok(_current_user) if hide_face_login

version = new Version()
$("#div_version").appendChild(version.element)

powermenu = null
powermenu = new PowerMenu($("#div_power"))
powermenu.new_power_menu()

document.body.addEventListener("keydown",(e)->
    try
        if is_greeter
            if powermenu?.ComboBox.menu.is_hide() and desktopmenu?.ComboBox.menu.is_hide()
                greeter.keydown_listener(e,user)
            else
                powermenu?.keydown_listener(e)
                desktopmenu?.keydown_listener(e)
    catch e
        echo "#{e}"
)
