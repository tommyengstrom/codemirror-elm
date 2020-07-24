module Main exposing (..)

import Browser
import Html exposing (Html, text)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as D
import Time


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


codemirror : Mode -> KeyMap -> Theme -> String -> Html Msg
codemirror mode km theme content =
    Html.node "code-mirror"
        [ Attr.attribute "mode" <| modeToString mode
        , Attr.attribute "keymap" <| keyMapToString km
        , Attr.attribute "theme" <| themeToString theme
        , Attr.attribute "editorValue" content
        , Html.Events.on "editorChanged" <|
            D.map EditorChanged <|
                D.at [ "target", "editorValue" ] <|
                    D.string
        ]
        []


type AutoSaved a
    = Saved a
    | Unsaved a


unAutoSaved : AutoSaved a -> a
unAutoSaved x =
    case x of
        Saved a -> a
        Unsaved a -> a


type alias Model =
    { editorValue : AutoSaved String
    }


init : D.Value -> ( Model, Cmd Msg )
init _ =
    ( { editorValue = Unsaved "# Such headline\n" }
    , Cmd.none
    )


type Msg
    = NoOp
    | EditorChanged String
    | SaveChanges


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        NoOp ->
            ( m, Cmd.none )

        EditorChanged v ->
            if unAutoSaved m.editorValue /= v then
                ( { m | editorValue = Unsaved v }, Cmd.none )

            else
                ( m, Cmd.none )

        SaveChanges ->
            case m.editorValue of
                Saved _ -> ( m, Cmd.none )
                Unsaved v -> ( { m | editorValue = Saved v }, Cmd.none )


view : Model -> Html Msg
view m =
    Html.div []
        [ case m.editorValue of
            Unsaved _ -> text "Unsaved"
            Saved _ -> text "✔ Saved"
        , codemirror Markdown Vim Monokai (unAutoSaved m.editorValue)
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 5000 (always SaveChanges)
