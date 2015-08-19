module Main where

import Html exposing (..)
import Html.Attributes exposing (..)

import StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

import Http
import Json.Decode as Json exposing ((:=))


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Contact =
  { name: String
  , email: String
  , phone: String
  }


newContact : String -> String -> String -> Contact
newContact name email phone =
  { name = name,
    email = email,
    phone = phone
  }


type alias Model =
  { contacts : (List Contact) }


init : (Model, Effects Action)
init =
  ( Model [ ], fetchContacts )


-- UPDATE

type Action
  = RefreshContacts (Maybe (List Contact))


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    RefreshContacts contacts ->
      ( Model (Maybe.withDefault [] contacts)
      , Effects.none
      )


-- VIEW

view : Address Action -> Model -> Html
view address model =
  div [ class "container" ]
  [ h1 [ ] [ text "Conman" ]
  , contactList model.contacts
  ]


contactList : List Contact -> Html
contactList contacts =
  ul [ class "contact-list" ] (List.map contactListItem contacts)


contactListItem : Contact -> Html
contactListItem contact =
  li [ class "contact-list__contact" ]
  [ h2 [ class "contact-list__contact__name" ] [ text contact.name ]
  , div [ class "contact-list__contact__email" ]
    [ span [ ] [ text "Email:" ]
    , a [ href ("mailto:" ++ contact.email) ] [ text contact.email ]
    ]
  , div [ class "contact-list__contact__phone" ]
    [ span [ ] [ text "Phone:" ]
    , a [ href ("tel:" ++ contact.phone) ] [ text contact.phone ]
    ]
  ]


-- EFFECTS

fetchContacts : Effects Action
fetchContacts =
  Http.get decodeContacts "http://localhost:4000/api/contacts"
    |> Task.toMaybe
    |> Task.map RefreshContacts
    |> Effects.task


decodeContacts : Json.Decoder (List Contact)
decodeContacts =
  let contact =
        Json.object3 (\name email phone -> (newContact name email phone))
          ("name" := Json.string)
          ("email" := Json.string)
          ("phone" := Json.string)
  in
      "data" := Json.list contact
