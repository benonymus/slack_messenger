defmodule SlackMessengerWeb.Messages.MessageAPIControllerTest do
  use SlackMessengerWeb.ConnCase

  import SlackMessenger.MessagesFixtures

  alias SlackMessenger.Messages.Message

  @create_attrs %{body: "some body", subject: "some subject"}
  @update_attrs %{body: "some updated body", subject: "some updated subject"}
  @invalid_attrs %{body: nil, subject: nil}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    auth_conn = put_req_header(conn, "x-api-key", "test_api_key")
    {:ok, conn: conn, auth_conn: auth_conn}
  end

  describe "index" do
    test "lists all messages", %{auth_conn: auth_conn} do
      conn = get(auth_conn, ~p"/api/messages")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all messages no auth", %{conn: conn} do
      conn = get(conn, ~p"/api/messages")
      assert json_response(conn, 401)
    end
  end

  describe "create message" do
    test "renders message when data is valid", %{auth_conn: auth_conn} do
      conn = post(auth_conn, ~p"/api/messages", message: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(auth_conn, ~p"/api/messages/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders message when data is valid no auth", %{auth_conn: auth_conn} do
      conn = post(auth_conn, ~p"/api/messages", message: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")

      assert json_response(conn, 401)
    end

    test "renders errors when data is invalid", %{auth_conn: auth_conn} do
      conn = post(auth_conn, ~p"/api/messages", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message" do
    setup [:create_message]

    test "renders message when data is valid", %{
      auth_conn: auth_conn,
      message: %Message{id: id} = message
    } do
      conn = put(auth_conn, ~p"/api/messages/#{message}", message: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(auth_conn, ~p"/api/messages/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders message when data is valid no auth", %{
      auth_conn: auth_conn,
      message: %Message{id: id} = message
    } do
      conn = put(auth_conn, ~p"/api/messages/#{message}", message: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")

      assert json_response(conn, 401)
    end

    test "renders errors when data is invalid", %{auth_conn: auth_conn, message: message} do
      conn = put(auth_conn, ~p"/api/messages/#{message}", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message" do
    setup [:create_message]

    test "deletes chosen message", %{auth_conn: auth_conn, message: message} do
      conn = delete(auth_conn, ~p"/api/messages/#{message}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(auth_conn, ~p"/api/messages/#{message}")
      end
    end

    test "deletes chosen message no auth", %{conn: conn, message: message} do
      conn = delete(conn, ~p"/api/messages/#{message}")
      assert json_response(conn, 401)
    end
  end

  defp create_message(_) do
    message = message_fixture()
    %{message: message}
  end
end
