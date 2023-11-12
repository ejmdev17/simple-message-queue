defmodule Prokeep.QueueTest do
  use ExUnit.Case
  alias Prokeep.Queue
  import ExUnit.CaptureIO

  describe "get_or_create_queue/1" do
    test "creating a queue" do
      assert {:ok, _pid} = Queue.get_or_create_queue("q1")
    end

    test "getting a queue that already exists" do
      queue_name = "q2"
      {:ok, pid1} = Queue.get_or_create_queue(queue_name)
      {:ok, pid2} = Queue.get_or_create_queue(queue_name)
      assert pid1 === pid2
    end
  end

  describe "enqueue/2" do
    test "enqueueing a message" do
      {:ok, queue} = Queue.get_or_create_queue("q3")
      assert Queue.enqueue(queue, "test message") == :ok
    end
  end

  describe "dequeue/2" do
    test "enqueueing a message" do
      {:ok, queue} = Queue.get_or_create_queue("q4")
      :ok = Queue.enqueue(queue, "test message")
      assert Queue.dequeue(queue) == {:ok, "test message"}
    end
  end

  test "processing messages" do
    # Given a queue and process interval of in milliseconds
    interval = 50
    {:ok, queue} = Queue.get_or_create_queue("q5", interval)

    # When adding 5 messages
    messages = ~w(0 1 2 3 4 5)

    Enum.map(messages, fn message ->
      :ok = Queue.enqueue(queue, message)
    end)

    # Then the messages are processed in order at the given interval
    Enum.map(messages, fn message ->
      output =
        capture_io(fn ->
          Process.group_leader(queue, Process.group_leader())
          Process.sleep(interval + 1)
        end)

      assert output =~ message
    end)
  end
end
