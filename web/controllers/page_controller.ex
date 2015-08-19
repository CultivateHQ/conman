defmodule Conman.PageController do
  use Conman.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
