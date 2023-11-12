defmodule ProkeepWeb.MessageControllerTest do
  use ProkeepWeb.ConnCase
  import ExUnit.CaptureLog
  alias Prokeep.Queue

  setup do
    {:ok, conn: put_req_header(build_conn(), "accept", "application/json")}
  end

  describe "receive_message/2" do
    test "valid request", %{conn: conn} do
      # Given
      params = %{
        queue: "q1",
        message: "test message"
      }

      # When
      conn = get(conn, "/receive-message", params)

      # Then
      assert json_response(conn, 200) == %{"message" => "test message"}
      assert {:ok, queue} = Queue.get_or_create_queue("q1")
      assert Queue.dequeue(queue) == {:ok, "test message"}
    end

    @tag capture_log: true
    test "invalid request", %{conn: conn} do
      # GIVEN
      message = "missing queue in params"

      params = %{
        message: "missing queue in params"
      }

      # When
      {conn, log} =
        with_log(fn ->
          get(conn, "/receive-message", params)
        end)

      # Then
      assert log =~ message
      assert json_response(conn, 400) == %{"errors" => %{"detail" => "Bad Request"}}
    end
  end
end
