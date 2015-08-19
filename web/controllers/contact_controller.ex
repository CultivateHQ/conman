defmodule Conman.ContactController do
  use Conman.Web, :controller

  alias Conman.Contact

  plug :scrub_params, "contact" when action in [:create, :update]

  def index(conn, _params) do
    contacts = Repo.all(Contact)
    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    changeset = Contact.changeset(%Contact{}, contact_params)

    case Repo.insert(changeset) do
      {:ok, contact} ->
        conn
        |> put_status(:created)
        |> render("show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Conman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    contact = Repo.get!(Contact, id)
    render conn, "show.json", contact: contact
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Repo.get!(Contact, id)
    changeset = Contact.changeset(contact, contact_params)

    case Repo.update(changeset) do
      {:ok, contact} ->
        render(conn, "show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Conman.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Repo.get!(Contact, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    contact = Repo.delete!(contact)

    send_resp(conn, :no_content, "")
  end
end
