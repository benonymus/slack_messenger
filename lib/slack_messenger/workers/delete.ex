defmodule SlackMessenger.Workers.Delete do
  use Oban.Worker, queue: :delete, max_attempts: 5

  @impl true
  def perform(%Oban.Job{args: %{"slack_ts" => nil}}), do: :ok

  def perform(%Oban.Job{args: %{"slack_ts" => slack_ts}}) do
    # the request could be built in a utility module, but that might limit future extensibility
    with request =
           Finch.build(
             :post,
             "#{Application.fetch_env!(:slack_messenger, :slack_webhook_url)}/chat.delete",
             [
               {"Content-Type", "application/json; charset=utf-8"},
               {"Authorization",
                "Bearer #{Application.fetch_env!(:slack_messenger, :slack_auth_token)}"}
             ],
             Jason.encode!(%{
               channel: Application.fetch_env!(:slack_messenger, :slack_channel_id),
               ts: slack_ts
             })
           ),
         %Finch.Response{status: 200, body: body} <-
           Finch.request!(request, SlackMessenger.Finch),
         %{"ok" => true} <- Jason.decode!(body) do
      :ok
    else
      err -> {:error, err}
    end
  end
end
