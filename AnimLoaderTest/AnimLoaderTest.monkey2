#Import "<std>"             ' Mojo3D assimp loader test
#Import "<mojo>"            ' for loading animated 3D models
#Import "<mojo3d>"          ' 
#Import "<mojo3d-loaders>"  ' Danilo Krahn, 2019/01/01
                            ' - Monkey2 2018-09, Mx2cc version 1.1.15
                            ' - tested on macOS Mojave


'
' Import all models in folder 'assets'
'
#Import "assets/"


Using std..
Using mojo..
Using mojo3d..
Using assimp..


#Rem ==========================================================================

      The following constant changes
      which model is loaded!

      Allowed values: 1 = Scene 'Gangnam Style'
                          Model (c) by Doron Adler, Creative Commons, CC-BY 3.0
                          https://poly.google.com/view/c_Wgki8RDr6

                      2 = Scene 'Green hair girl'
                          Model (c) by Doron Adler, Creative Commons, CC-BY 3.0
                          https://poly.google.com/view/4LHkgfcw3ey

                      3 = Scene 'Wolf Rigged And Game Ready'
                          Model (c) by Dennis Haupt, https://free3d.com/user/3dhaupt
                          https://free3d.com/3d-model/wolf-rigged-and-game-ready-42808.html

#End '=========================================================================
Const SHOW_ANIM:Int = 1   ' <<=== CHANGE HERE
'==============================================================================


Class AnimInfo
    Method New( _name:String, _duration:Float )
        Name = _name
        Duration = _duration
    End
    Field Name:String
    Field Duration:Float
End


Class Program Extends Window

    Field camera:Camera

    Field model2:Model
    Field anims:Stack<AnimInfo> = New Stack<AnimInfo>
    Field currentAnim:Int = 0
    Field currentSpeed:Float = 1.0
    Field filename:String
    Field copyright:String

    Method New()
        Super.New( "Monkey2 - Anim Loader Test", 1024, 768, WindowFlags.Resizable|WindowFlags.HighDPI )
    End

    Method OnCreateWindow() Override

        '=================================
        ' Set this to True for fullscreen:
        '=================================
        Fullscreen = False  ' True / False               ' <<=== GO FULLSCREEN!
        '
        ' Simple Scene Setup
        '
        Local scene := Scene.GetCurrent()
        scene.GetCurrent().ClearColor = New Color ( .3, .3, .3)

        camera = New Camera( New Pivot )
        camera.Move( 0, 0, -2 )
        camera.Near = 0.01
        camera.Far  = 100000
        camera.FOV  = 90.0

        Local light := New Light

        Print "--------------------------------------------------"

        Select SHOW_ANIM
            Case 1
                '
                ' Gangnam Style
                '
                ' Model:   (c) by Doron Adler
                ' License: Creative Commons, CC-BY 3.0
                '
                ' https://poly.google.com/view/c_Wgki8RDr6
                '
                filename  = "asset::Polonia_LowRez.glb"
                copyright = "Model (c) by Doron Adler"
                camera.Move( 0, 1, 0 )
            Case 2
                '
                ' Green hair girl
                '
                ' Model:   (c) by Doron Adler
                ' License: Creative Commons, CC-BY 3.0
                '
                ' https://poly.google.com/view/4LHkgfcw3ey
                '
                filename = "asset::GreenHairAvgGirl.glb"
                copyright = "Model (c) by Doron Adler"
                camera.Move( 0, 1, 0 )
            Case 3
                '
                ' Wolf Rigged And Game Ready
                '
                ' Model (c) by Dennis Haupt, https://free3d.com/user/3dhaupt
                '
                ' https://free3d.com/3d-model/wolf-rigged-and-game-ready-42808.html
                '
                filename  = "asset::wolf/Wolf_UDK_2.fbx"
                copyright = "Model (c) by Dennis Haupt"
                camera.Move( 0, 30, -90 )
        End


        Print "Loading model: '" + filename + "'"
        Print "--------------------------------------------------"

        '
        ' Load the model using assimp
        '
        model2 = Model.LoadBoned( filename )
        If model2
            'model2.Move( 0,0,0 )

            Print model2.NumChildren
            Print model2.Name

            ' check if the model has any materials, just for information
            For Local material := Eachin model2.Materials
                Print "material found: '" + material.Name + "'"
            Next

            ' Are any components attached to the model?
            If model2.Animator  = Null Then Print "no Animator found!"
            If model2.RigidBody = Null Then Print "no RigidBody found!"
            If model2.Collider  = Null Then Print "no Collider found!"
            If model2.Joint     = Null Then Print "no Joint found!"

            '
            ' If the model has an Animator, there are animations
            '
            If model2.Animator <> Null
                '
                ' get all available animation names and
                ' add that information to the Stack 'anims'
                '
                For Local anim := Eachin model2.Animator.Animations
                    Print "animation found: '" + anim.Name + "' - Duration: '" + anim.Duration + "'"
                    anims.Add( New AnimInfo( anim.Name, anim.Duration ) )
                Next
                '
                ' Start Animation anims[0] ( the first animation in the model )
                '
                If anims.Length > 0
                    model2.Animator.Animate( anims[0].Name )
                Endif
            Endif

        Endif

        Print "--------------------------------------------------"
    End


    Method ChangeAnim(value:Int)
        '
        ' Change the current animation and update animation speed
        '
        currentAnim += value
        If currentAnim <  0            Then currentAnim = anims.Length - 1
        If currentAnim >= anims.Length Then currentAnim = 0
        model2?.Animator?.Animate( anims[currentAnim].Name )

        If currentSpeed < 0.1 Then currentSpeed = 0.1
        model2?.Animator?.MasterSpeed = currentSpeed
    End


    Method OnRender( canvas:Canvas ) Override
        '
        ' Check keyboard keys
        '
        ' - Note: Does currently not work on iPad Pro with bluetooth keyboard connected
        '
        If Keyboard.KeyHit(Key.Escape) Then App.Terminate() Else RequestRender()

        If Keyboard.KeyDown(Key.Left)  Then camera.Move( -.1, 0, 0 )
        If Keyboard.KeyDown(Key.Right) Then camera.Move(  .1, 0, 0 )
        If Keyboard.KeyDown(Key.Up)    Then camera.Move(  0, 0, .1 )
        If Keyboard.KeyDown(Key.Down)  Then camera.Move(  0, 0,-.1 )

        If Keyboard.KeyHit(Key.Key1)  Then ChangeAnim(-1)
        If Keyboard.KeyHit(Key.Key2)  Then ChangeAnim( 1)

        If Keyboard.KeyHit(Key.Key3)
            currentSpeed -= 0.1
            ChangeAnim(0)
        Endif
        If Keyboard.KeyHit(Key.Key4)
            currentSpeed += 0.1
            ChangeAnim(0)
        Endif

        '
        ' set Viewport, required after window resize
        '
        camera.Viewport = New Recti( 0, 0, Width, Height )

        '
        ' let our model rotate slowly
        '
        model2?.Rotate( 0, .5, 0 )

        '
        ' Update and render the 3D scene
        '                
        Local scene := Scene.GetCurrent()
        scene.Update()
        scene.Render( canvas )
        'camera.Render( canvas )


        '
        ' Scale canvas output, so standard text is bigger
        '
        canvas.Scale( 1.5, 1.5 )

        '
        ' Generate output info
        '
        Local animName := anims.Length > 0 ? currentAnim +
                          " ("                           +
                          anims[ currentAnim ].Name      +
                          ") "                           +
                          " (Duration: "                 +
                          String( anims[ currentAnim ].Duration ).Left(4) +
                          ")" Else "-"

        '
        ' Draw info text
        '
        canvas.Color = Color.Yellow

        canvas.DrawText( "Animations found: " + anims.Length, 0, 0 )
        canvas.DrawText( "Active Animation: " + animName, 0, 20 )
        canvas.DrawText( "Active AnimSpeed: " + String( currentSpeed ).Left(4), 0, 40 )
        canvas.DrawText( "FPS: " + App.FPS, 0, 70 )

        canvas.Color = Color.LightGrey

        canvas.DrawText( "Keyboard:", 0, 100 )
        canvas.DrawText( " '1': Previous Animation", 0, 120 )
        canvas.DrawText( " '2': Next Animation", 0, 140 )
        canvas.DrawText( " '3': Anim Speed -", 0, 160 )
        canvas.DrawText( " '4': Anim Speed +", 0, 180 )
        canvas.DrawText( " 'Cursor Keys':", 0, 200 )
        canvas.DrawText( "     Up/Down': Zoom", 0, 220 )
        canvas.DrawText( "     Left/Right': Camera Left/Right", 0, 240 )
        canvas.DrawText( " 'ESC': Quit", 0, 260 )

        canvas.Color = Color.Black

        canvas.DrawText( " Filename: " + filename, 0, 290 )
        canvas.DrawText( " " + copyright, 0, 310 )
    End
End

'
' App entry point. Everything starts here.
'
Function Main ()
    New AppInstance
    New Program
    App.Run ()
End
