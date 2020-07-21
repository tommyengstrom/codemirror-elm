module Main exposing (..)

import Browser
import Html exposing (Html, text)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as D


main : Program D.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Mode
    = Markdown
    | Haskell


modeToString : Mode -> String
modeToString m =
    case m of
        Markdown -> "markdown"
        Haskell -> "haskell"


type Theme
    = Monokai


themeToString : Theme -> String
themeToString t =
    case t of
        Monokai -> "monokai"


type KeyMap
    = Vim
    | Emacs


keyMapToString : KeyMap -> String
keyMapToString m =
    case m of
        Vim -> "vim"
        Emacs -> "emacs"


codemirror : Mode -> KeyMap -> Theme -> Html Msg
codemirror mode km theme =
    Html.node "code-mirror"
        [ Attr.attribute "mode" <| modeToString mode
        , Attr.attribute "keymap" <| keyMapToString km
        , Attr.attribute "theme" <| themeToString theme
        , Attr.attribute "editorValue" "module Main where\n"
        , Html.Events.on "editorChanged" <|
            D.map EditorChanged <|
                D.at [ "target", "editorValue" ] <|
                    D.string
        ]
        []


type alias Model =
    { currentTime : Int }


init : D.Value -> ( Model, Cmd Msg )
init _ =
    ( { currentTime = 1 }
    , Cmd.none
    )


type Msg
    = NoOp
    | EditorChanged String
    | EditorSave String


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ codemirror Markdown Vim Monokai
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
