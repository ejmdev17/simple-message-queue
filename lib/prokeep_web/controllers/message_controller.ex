defmodule ProkeepWeb.MessageController do
  use ProkeepWeb, :controller

  alias Prokeep.Processor
  require Logger

  action_fallback ProkeepWeb.FallbackController

  def receive_message(conn, %{"queue" => queue, "message" => message}) do
    render(conn, :show, message: message)
  end

  def receive_message(conn, params) do
    Logger.warn("Invalid params to receive_message - params: #{inspect(params)}")

    conn
    |> put_status(:bad_request)
    |> put_view(json: ProkeepWeb.ErrorJSON)
    |> render(:"400")
  end
end
