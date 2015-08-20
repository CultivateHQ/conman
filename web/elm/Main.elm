-- Example based on Tutorial 5 on the Elm Architecture Tutorial (https://github.com/evancz/elm-architecture-tutorial)

module Main where

-- Gives us the ability to work with HTML elements
-- and attributes in our Views.
import Html exposing (..)
import Html.Attributes exposing (..)

-- Wiring that joins our Model-Update-View architecture
-- together and provides Effects for allowing Tasks to
-- flow through our application.
import StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

-- Enables the fetching of data over HTTP and the decoding
-- of the returned JSON.
import Http
import Json.Decode as Json exposing ((:=))


-- This starts up our app using StartApp:
--
-- init   = points to our init function that derives the initial
--          state of the Model and runs any preliminary Tasks that
--          need to be run
-- update = points to the Updater that can step the application Model
-- view   = points to the base View for the application
-- inputs = any external signal that our application needs, ignore for now
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


-- Display the HTML returned by StartApp.
main : Signal Html
main =
  app.html


-- Port Tasks that are created in StartApp to this application
-- without this we can't see any affects of updating the Model.
-- For more info see http://package.elm-lang.org/packages/evancz/start-app/2.0.0/StartApp
port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- MODEL
-- The Model describes the current state of the application.

-- Defines a Contact.
type alias Contact =
  { name: String
  , email: String
  , phone: String
  }


-- Defines the overall application Model.
type alias Model =
  { contacts : (List Contact) }


-- Defines how to set up the initial state of the application.
-- In this case we built a Model with an empty contacts list
-- and call fetchContacts to get an Effects Action that will
-- populate the contacts list.
init : (Model, Effects Action)
init =
  ( Model [ ], fetchContacts )


-- UPDATE
-- Updates the Model state through a set of defined Actions.
-- Whenever the Model's state is updated the Views will automatically
-- re-render.

-- Defines the Actions allowed by the application
type Action
  = RefreshContacts (Maybe (List Contact))


-- Takes any given input and produces a new application Model (and possibly also new Effects Action).
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    -- The supplied `contacts` params can either be an HTTP error
    -- or a List of Contact models.
    -- If contacts is an error the `Maybe.withDefault` will provide
    -- an empty list, otherwise it will provide the given List of
    -- Contact models.
    -- `Effects.none` is used to show that no further actions
    -- need to be taken.
    RefreshContacts contacts ->
      ( Model (Maybe.withDefault [] contacts)
      , Effects.none
      )


-- VIEW
-- Defines how the application Model is displayed.

-- Base view to display the ConMan UI.
view : Address Action -> Model -> Html
view address model =
  div [ class "container" ]
  [ h1 [ ] [ text "Conman" ]
  , contactList model.contacts
  ]


-- Display a list of contacts.
contactList : List Contact -> Html
contactList contacts =
  ul [ class "contact-list" ] (List.map contactListItem contacts)


-- Display an individual contact.
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

-- Fetches contact data from the dataAPI:
--
-- 1. GET contacts data and decode using the `decodeContacts` function below.
-- 2. Pipe to `Task.maybe` to move any errors from the fail response to the
--    success response. This allows us to bubble errors to the Update, which
--    can then handle them.
-- 3. Pipe to `Task.map` which converts the data into an Action that can be run.
-- 4. Pipe that Action to `Effects.task` which queues the Task to be run.
--
-- Result should be an updated application Model that contains Contact models for
-- each contact returned by the API.
fetchContacts : Effects Action
fetchContacts =
  Http.get decodeContacts "http://localhost:4000/api/contacts"
    |> Task.toMaybe
    |> Task.map RefreshContacts
    |> Effects.task


-- Defines the rule for decoding the JSON data returned by the API.
decodeContacts : Json.Decoder (List Contact)
decodeContacts =
  let contact =
        Json.object3 (\name email phone -> (Contact name email phone))
          ("name" := Json.string)
          ("email" := Json.string)
          ("phone" := Json.string)
  in
      "data" := Json.list contact
