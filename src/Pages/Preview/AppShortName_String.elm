module Pages.Preview.AppShortName_String exposing (Model, Msg, Params, page)

import Components.ManifestViewer as ManifestViewer exposing (ManifestViewer)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Manifest exposing (Manifest)
import Manifest.Color
import Material.Icons.Outlined as MaterialIcons
import Material.Icons.Types exposing (Coloring(..))
import Session exposing (Session)
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Task
import UI.Colors as Colors exposing (Colors)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    { appShortName : String }


type alias Model =
    { session : Session
    , device : Device
    , appShortName : String
    , colors : Colors
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    let
        maybeManifest =
            List.head <|
                List.filter
                    (\manifest -> manifest.shortName == params.appShortName)
                    shared.manifests

        colors =
            case maybeManifest of
                Just manifest ->
                    { backgroundColor =
                        Maybe.withDefault Colors.lightPurple <|
                            Manifest.Color.fromHex manifest.backgroundColor
                    , themeColor =
                        Maybe.withDefault Colors.lightPurple <|
                            Manifest.Color.fromHex manifest.themeColor
                    , fontColor = Manifest.Color.contrast manifest.backgroundColor
                    , themeFontColor = Manifest.Color.contrast manifest.themeColor
                    }

                Nothing ->
                    Colors.init
    in
    ( { session = shared.session
      , device = shared.device
      , appShortName = params.appShortName
      , colors = colors
      }
      -- elm-spa needs an update to sync to Shared
    , Task.perform (\_ -> SyncShared) (Task.succeed Nothing)
    )



-- UPDATE


type Msg
    = SyncShared


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SyncShared ->
            ( model, Cmd.none )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared | colors = model.colors }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( { model
        | session = shared.session
        , device = shared.device
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Previewing " ++ model.appShortName
    , body =
        [ case model.device.class of
            Phone ->
                column
                    [ width fill
                    , height fill
                    , paddingXY 10 20
                    , Background.color model.colors.backgroundColor
                    , Font.color model.colors.fontColor
                    ]
                    []

            Tablet ->
                case model.device.orientation of
                    Portrait ->
                        column
                            [ width fill
                            , height fill
                            , paddingXY 10 20
                            , spacing 20
                            , Background.color model.colors.backgroundColor
                            , Font.color model.colors.fontColor
                            ]
                            []

                    Landscape ->
                        column
                            [ centerX
                            , width fill
                            , height fill
                            , paddingXY 30 30
                            , spacing 30
                            , Background.color model.colors.backgroundColor
                            , Font.color model.colors.fontColor
                            ]
                            []

            _ ->
                column
                    [ centerX
                    , width (px 1000)
                    , height fill
                    , paddingXY 30 30
                    , spacing 30
                    , Background.color model.colors.backgroundColor
                    , Font.color model.colors.fontColor
                    ]
                    []
        ]
    }
