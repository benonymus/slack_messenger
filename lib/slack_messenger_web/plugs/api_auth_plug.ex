defmodule SlackMessengerWeb.Plugs.APIAuthPlug do
  import Plug.Conn

  # in the real world this would be genereted and saved in the db and checked against that
  @api_key "test_api_key"

  def init(opts), do: opts

  def call(conn, _opts) do
    [api_key] =
      get_req_header(conn, "x-api-key")

    if api_key == @api_key do
      conn
    else
      conn
      |> send_resp(401, "Invalid api_key!")
      |> halt()
    end
  end
end
