defmodule ProkeepWeb.MessageJSON do
  @doc """
  Renders a single message.
  """
  def show(%{message: message}) do
    %{message: message}
  end
end
