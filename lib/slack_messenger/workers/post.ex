defmodule SlackMessenger.Workers.Post do
  use Oban.Worker, queue: :post, max_attempts: 5

  alias SlackMessenger.Messages

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    message = Messages.get_message!(id)

    with true <- check_not_posted(message),
         {:ok, slack_ts} <- make_request(message) do
      Messages.update_message_slack_ts(message, slack_ts)
    end
  end

  defp check_not_posted(%Messages.Message{slack_ts: nil}), do: true

  defp check_not_posted(_), do: {:cancel, "already posted"}

  defp make_request(message) do
    Req.post!(
      "#{Application.fetch_env!(:slack_messenger, :slack_webhook_url)}/chat.postMessage",
      headers: [
        {"content-type", "application/json; charset=utf-8"},
        {"authorization", "Bearer #{Application.fetch_env!(:slack_messenger, :slack_auth_token)}"}
      ],
      json: %{
        channel: Application.fetch_env!(:slack_messenger, :slack_channel_id),
        text: message.subject <> "\n" <> message.body
      }
    )
    |> case do
      %Req.Response{status: 200, body: %{"ok" => true, "ts" => slack_ts}} ->
        {:ok, slack_ts}

      resp ->
        {:error, resp}
    end
  end
end
