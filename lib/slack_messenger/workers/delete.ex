defmodule SlackMessenger.Workers.Delete do
  use Oban.Worker, queue: :delete, max_attempts: 5

  @impl true
  def perform(%Oban.Job{args: %{"slack_ts" => nil}}), do: :ok

  def perform(%Oban.Job{args: %{"slack_ts" => slack_ts}}) do
    Req.post!(
      "#{Application.fetch_env!(:slack_messenger, :slack_webhook_url)}/chat.delete",
      headers: [
        {"content-type", "application/json; charset=utf-8"},
        {"authorization", "Bearer #{Application.fetch_env!(:slack_messenger, :slack_auth_token)}"}
      ],
      json: %{
        channel: Application.fetch_env!(:slack_messenger, :slack_channel_id),
        ts: slack_ts
      }
    )
    |> case do
      %Req.Response{status: 200, body: %{"ok" => true}} ->
        :ok

      resp ->
        {:error, resp}
    end
  end
end
