
#Import "<std>"     ' Realtime resize test for Monkey2 MojoX apps
#Import "<mojo>"    '
#Import "<mojox>"   ' We are installing the SdlEventFilter here
                    ' and update the main Monkey2 SDL window in the handler
                    ' to prevent stretching of the window content
                    ' while the user resizes the window.
                    '
                    ' Danilo Krahn, 2019/01/15
                    ' - Monkey2 2018-09, Mx2cc version 1.1.15
                    ' - tested on macOS Mojave

Function InstallWindowResizeFilter( _win:mojo.app.Window, _updateInterval:UInt = 1 )

    Global window_ResizeFilter:mojo.app.Window
    Global counter_ResizeFilter:UInt
    Global interval_ResizeFilter:UInt

    window_ResizeFilter   = _win
    interval_ResizeFilter = _updateInterval = 0 ? 1 Else _updateInterval

    mojo.app.App.SdlEventFilter =
        Lambda( eventPtr:sdl2.SDL_Event Ptr )
            If eventPtr->type = sdl2.SDL_WINDOWEVENT
                Select eventPtr->window.event
                    Case sdl2.SDL_WINDOWEVENT_RESIZED
                        '
                        ' This is a handler for realtime window resizing
                        '
                        '======================================================
                        ' SDL stuff:
                        Local sdlWindowID := eventPtr->window.windowID
                        Local sdlWindow   := sdl2.SDL_GetWindowFromID(sdlWindowID)

                        'SDL_SetWindowInputFocus(sdlWindow)
                        sdl2.SDL_CaptureMouse(sdl2.SDL_TRUE)

                        ' Monkey2 stuff
                        counter_ResizeFilter += 1
                        ' we do this only as long as the left mouse button is pressed
                        If window_ResizeFilter And
                           ( sdl2.SDL_GetGlobalMouseState(Null,Null) & sdl2.SDL_BUTTON_LMASK )
                            Local frame:std.geom.Recti = window_ResizeFilter.Frame
                            frame.Size = New std.geom.Vec2i(eventPtr->window.data1,
                                                            eventPtr->window.data2)
                            window_ResizeFilter.Frame = frame

                            window_ResizeFilter.ContentView.MakeKeyView()
                            'window_ResizeFilter.UpdateWindow(False)

                            ' update window content only every '_updateInterval' time
                            If counter_ResizeFilter <> 0 And
                               ( counter_ResizeFilter Mod interval_ResizeFilter ) = 0
                                window_ResizeFilter.RequestRender()
                                mojo.app.App.MainLoop()
                            Endif
                        Endif
                        '======================================================
                End Select
            EndIf
        End Lambda
End


Class Program Extends mojo.app.Window

    Method New()
        Super.New( "Monkey2 Realtime Window Resize Test",
                   800,
                   600,
                   mojo.app.WindowFlags.HighDPI   |
                   mojo.app.WindowFlags.Resizable )

    End

    Private

    Method OnCreateWindow() Override

        InstallWindowResizeFilter(Self)   ' update window on every resize step
        'InstallWindowResizeFilter(Self,2) ' update window on every 2nd resize step

        dockingView    = New mojox.DockingView

        namespacesView = New mojox.TreeView

        htmlView       = New mojox.HtmlView

        messageView    = New mojox.TextView( "Monkey2 Realtime Window Resize Test started.~n" )
        messageView.ReadOnly = True

        Local style:mojo.app.Style

        style = messageView.Style
        style.BackgroundColor = std.graphics.Color.DarkGrey

        style = htmlView.Style
        style.BackgroundColor = std.graphics.Color.DarkGrey
        style.TextColor       = std.graphics.Color.White

        Local txt:String = "<!DOCTYPE html><html><head>"+
                           "<meta charset=~qutf-8~q />"+
                           "    <style>"+
                           "        h1     { color: red;     } "+
                           "        body   { color: #808080; } "+
                           "        strong { color: #000000; } "+
                           "    </style>"+
                           "</head>"+
                           "<body> <h1>Hello</h1> <strong>strong</strong> text<p>"+
                           "</body></html>"
        For Local i := 0 To 1000
            txt += "a b c d e f g 0 1 2 3 4 5 6 7 8 9 "
        Next

        htmlView.HtmlSource = txt

        dockingView.AddView( namespacesView, "left", "250", True )
        dockingView.AddView( messageView, "bottom", "80", True )

        dockingView.ContentView = htmlView

        Self.ContentView = dockingView

        dockingView.ContentView.MakeKeyView()

    End

    Field dockingView    : mojox.DockingView
    Field namespacesView : mojox.TreeView
    Field htmlView       : mojox.HtmlView
    Field messageView    : mojox.TextView

End

Function Main()
    New mojo.app.AppInstance
    New Program
    mojo.app.App.Run()
End
