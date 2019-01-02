#Import "<std>"      ' Minimalist mojo3d app
#Import "<mojo>"     ' - Monkey2 2018-09, Mx2cc version 1.1.15
#Import "<mojo3d>"   ' - tested on macOS and iOS (iPad Pro)

Using mojo..
Using mojo3d..
Using std..

Class Program Extends Window
    Method New()
        Super.New ( "Torus", 800, 600, WindowFlags.Resizable|WindowFlags.HighDPI )
    End
    Method OnCreateWindow() Override
        Fullscreen = True
        Scene.GetCurrent().ClearColor = New Color( .3, .3, .3 )
        New Light
        camera = New Camera
        camera.Move( 0, 0, -70 )
        torus1 = mojo3d.Model.CreateTorus( 30, 10, 360, 360, New PbrMaterial( Color.Red , .1, .1 ) )
        torus2 = mojo3d.Model.CreateTorus( 10,  3, 360, 360, New PbrMaterial( Color.Blue, .1, .1 ) )
    End
    Method OnRender ( canvas:Canvas ) Override
        If Keyboard.KeyHit( Key.Escape ) Then App.Terminate() Else RequestRender()
        camera?.Viewport = New Recti( 0, 0, Width, Height )
        torus1?.Rotate( .3, .6, .9 )
        torus2?.Rotate( .6, .9, .3 )
        Scene.GetCurrent().Render( canvas )
        canvas.Scale( 2, 2 )
        canvas.DrawText( "Monkey2 - FPS: " + App.FPS, Width*.125, 10 )
    End
    Private '--------------------------[ Private ]
    Field camera:Camera
    Field torus1:Model
    Field torus2:Model
End

Function Main()
    New AppInstance
    New Program
    App.Run()
End
