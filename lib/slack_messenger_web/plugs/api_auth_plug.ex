defmodule SlackMessengerWeb.Plugs.APIAuthPlug do
  import Plug.Conn

  # in the real world this would be genereted and saved in the db and checked against that
  @api_key "test_api_key"

  def init(opts), do: opts

  def call(conn, _opts) do
    api_key =
      conn
      |> get_req_header("x-api-key")
      |> List.first()

    if not is_nil(api_key) and api_key == @api_key do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, Jason.encode!(%{msg: "Invalid api_key!"}))
      |> halt()
    end
  end
end
