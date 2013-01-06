class LoginEntry extends Widget
    constructor: (@id, @on_active)->
        super
        @password = create_element("input", "Password", @element)
        @password.setAttribute("type", "password")
        @password.setAttribute("autofocus", "true")
        @password.index = 0
        @password.addEventListener("keydown", (e)=>
            if e.which == 13
                @on_active(@password.value)
        )

        @login = create_element("button", "LoginButton", @element)
        @login.innerText = "User Login"
        @login.addEventListener("click", =>
            @on_active(@password.value)
        )
        @login.index = 1
        @password.focus()

class Loading extends Widget
    constructor: (@id)->
        super
        create_element("div", "ball", @element)
        create_element("div", "ball1", @element)
        create_element("span", "", @element).innerText = "Welcome !"

_current_user = null
class UserInfo extends Widget
    constructor: (@id, name, img_src)->
        super
        @li = create_element("li", "")
        @li.appendChild(@element)
        @img = create_img("UserImg", img_src, @element)
        @name = create_element("span", "UserName", @element)
        @name.innerText = name
        @active = false

    focus: ->
        _current_user?.blur()
        _current_user = @
        @add_css_class("UserInfoSelected")
        DCore.Greeter.set_selected_user(@id)
        DCore.Greeter.start_authentication(@id)
    
    blur: ->
        @element.setAttribute("class", "UserInfo")
        @login?.destroy()
        @login = null
        @loading?.destroy()
        @loading = null
        if DCore.Greeter.in_authentication()
            DCore.Greeter.cancel_authentication()
    
    show_login: ->
        if false
            @login()
        else if not @login
            @login = new LoginEntry("login", (p)=>@on_verify(p))
            @element.appendChild(@login.element)

    do_click: (e)->
        if _current_user == @
            @show_login()
        else
            @focus()

    on_verify: (password)->
        @login.destroy()
        @loading = new Loading("loading")
        @element.appendChild(@loading.element)

        _session = de_menu.menu.items[de_menu.get_current()][0]
        DCore.Greeter.login_clicked(password)

        #debug code begin
        div_auth = create_element("div", "", $("#Debug"))
        div_auth.innerText += "authenticate"

        div_id = create_element("div", "", div_auth)
        div_id.innerText = @id

        div_password = create_element("div", "", div_auth)
        div_password.innerText = password

        div_session = create_element("div", "", div_auth)
        div_session.innerText = _session
        #debug code end

# below code should use c-backend to fetch data 
if DCore.Greeter.is_hide_users()
    alert "hide users"
else
    users = DCore.Greeter.get_users()
    for user in users
        u = new UserInfo(user, user, "images/img01.jpg")
        roundabout.appendChild(u.li)
        if user == DCore.Greeter.get_default_user()
            u.focus()
            # DCore.Greeter.start_authentication(user)

    if roundabout.children.length == 2
        roundabout.style.width = "0"

    run_post(->
        l = (screen.width  - roundabout.clientWidth) / 2
        roundabout.style.left = "#{l}px"
    )
