defmodule ProkeepWeb.MessageController do
  @moduledoc """
  Controller for receiving messages and queueing them up for processing.
  """

  use ProkeepWeb, :controller

  alias Prokeep.Queue
  require Logger

  action_fallback ProkeepWeb.FallbackController

  def receive_message(conn, %{"queue" => queue, "message" => message}) do
    {:ok, queue} = Queue.get_or_create_queue(queue)
    :ok = Queue.enqueue(queue, message)
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
