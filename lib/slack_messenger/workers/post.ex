defmodule SlackMessenger.Workers.Post do
  use Oban.Worker, queue: :post, max_attempts: 5

  alias SlackMessenger.Messages

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    with message = Messages.get_message!(id),
         {:not_posted, true} <- {:not_posted, is_nil(message.slack_ts)},
         request =
           Finch.build(
             :post,
             "#{Application.fetch_env!(:slack_messenger, :slack_webhook_url)}/chat.postMessage",
             [
               {"Content-Type", "application/json; charset=utf-8"},
               {"Authorization",
                "Bearer #{Application.fetch_env!(:slack_messenger, :slack_auth_token)}"}
             ],
             Jason.encode!(%{
               channel: Application.fetch_env!(:slack_messenger, :slack_channel_id),
               text: message.subject <> "\n" <> message.body
             })
           ),
         %Finch.Response{status: 200, body: body} <-
           Finch.request!(request, SlackMessenger.Finch),
         %{"ok" => true, "ts" => slack_ts} <- Jason.decode!(body) do
      Messages.update_message_slack_ts(message, slack_ts)
    else
      {:not_posted, false} -> {:cancel, "already posted"}
      err -> {:error, err}
    end
  end
end
