module Update exposing (..)

import Commands exposing (..)
import Messages exposing (..)
import Model exposing (..)
import Navigation
import Routing exposing (Route(..), parse, toPath)
import Uuid exposing (uuidGenerator)
import Random.Pcg exposing (step)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange location ->
            let
                currentRoute =
                    parse location
            in
                urlUpdate { model | route = currentRoute }

        NavigateTo route ->
            model ! [ Navigation.newUrl <| toPath route ]

        AutoLogin ->
            model ! [ Navigation.load "/auth" ]

        HandleSearchInput value ->
            { model | search = value } ! []

        LoginUserResult (Ok response) ->
            { model | loginUser = Success response } ! []
        LoginUserResult (Err error) ->
            { model | loginUser = Failure (toString error) } ! []

        OtherUserResult (Ok response) ->
            { model | otherUser = Success response } ! []
        OtherUserResult (Err error) ->
            { model | otherUser = Failure (toString error) } ! []

        DeleteSession ->
            model ! [ logout model.csrfToken ]

        PostDeleted (Ok response) ->
            { model | loginUser = NotRequested } ! []
        PostDeleted (Err error) ->
            model ! [ Debug.crash (toString error) ]

        SelectMeta string ->
            { model | csrfToken = string } ! []

        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    step uuidGenerator model.currentSeed
                newUuidList =
                    case model.currentUuid of
                        Nothing ->
                            List.singleton newUuid
                        Just uuidList ->
                            uuidList ++ [newUuid]
            in
                { model
                  | currentUuid = Just newUuidList
                  , currentSeed = newSeed
                } ! [ {-updateApiKey model.loginUser model.currentUuid-} ]

--        KeyDown 191 ->
--            model ! [ FocusOn ]

        _ ->
            model ! []

urlUpdate : Model -> ( Model, Cmd Msg )
urlUpdate model =
    case model.route of
        UsersRoute id ->
            case (model.loginUser, model.otherUser) of
                (NotRequested, NotRequested) ->
                    model ! [ getSession, getUser id ]
                (NotRequested, _) ->
                    model ! [ getSession ]
                (_, NotRequested) ->
                    model ! [ getUser id ]
                _ ->
                    model ! []

--        SettingsRoute ->
--            case model.loginUser of
--                NotRequested ->
--                    model ! [ Navigation.load "/auth", getSession ]
--                _ ->
--                    model ! []

        _ ->
            case model.loginUser of
                NotRequested ->
                    model ! [ getSession ]
                _ ->
                    model ! []
