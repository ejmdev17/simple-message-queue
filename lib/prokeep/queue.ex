defmodule Prokeep.Queue do
  @moduledoc """
  Queue for processing messages.
  """

  use GenServer

  @doc """
  Enqueue a message to the queue.
  """
  @spec enqueue(pid, String.t()) :: :ok
  def enqueue(pid, element) when is_binary(element) do
    GenServer.call(pid, {:enqueue, element})
  end

  @doc """
  Dequeue a message from the queue
  """
  @spec dequeue(pid) :: {:ok, String.t()} | {:error, :empty}
  def dequeue(pid) do
    GenServer.call(pid, :dequeue)
  end

  @doc """
  Start and link the queue GenServer.
  """
  @spec start_link(String.t(), pos_integer()) :: {:ok, pid}
  def start_link(name, interval) when is_binary(name) and is_integer(interval) do
    # This is dangerous, should never allow arbitrary atom creation from strings.
    # But allowing unlimited creation of queues from user input is bad to begin with :).
    name = String.to_atom(name)
    GenServer.start_link(__MODULE__, {name, interval}, name: name)
  end

  @doc """
  Get or create a queue with the given name.
  param name - the name of the queue
  param interval - the interval in milliseconds to process messages, default to 1 second
  """
  @spec get_or_create_queue(String.t(), pos_integer()) :: {:ok, pid}
  def get_or_create_queue(name, interval \\ :timer.seconds(1))
      when is_binary(name) and is_integer(interval) do
    child_spec = %{id: :test, start: {__MODULE__, :start_link, [name, interval]}}

    case DynamicSupervisor.start_child(Prokeep.QueueSupervisor, child_spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  # Server (callbacks)
  @impl true
  def init({name, interval}) do
    send(self(), :process)
    {:ok, %{name: name, queue: :queue.new(), interval: interval}}
  end

  @impl true
  def handle_call({:enqueue, message}, _from, state) do
    queue = :queue.in(message, state[:queue])
    {:reply, :ok, %{state | queue: queue}}
  end

  @impl true
  def handle_call(:dequeue, _from, state) do
    {status, message, queue} =
      case :queue.out(state[:queue]) do
        {{:value, message}, queue} -> {:ok, message, queue}
        {:empty, queue} -> {:error, :empty, queue}
      end

    {:reply, {status, message}, %{state | queue: queue}}
  end

  @impl true
  def handle_info(:process, state) do
    queue =
      case :queue.out(state[:queue]) do
        {{:value, message}, queue} ->
          IO.puts(message)
          queue

        {:empty, queue} ->
          queue
      end

    schedule_process(state[:interval])
    {:noreply, %{state | queue: queue}}
  end

  defp schedule_process(interval) do
    Process.send_after(self(), :process, interval)
  end
end
