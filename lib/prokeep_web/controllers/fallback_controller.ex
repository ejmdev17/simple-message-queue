defmodule ProkeepWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ProkeepWeb, :controller
  require Logger

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: ProkeepWeb.ErrorHTML, json: ProkeepWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(_conn, error) do
    Logger.error("Unhandled error in FallbackController: #{inspect(error)}")
  end
end
