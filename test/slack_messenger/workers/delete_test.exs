defmodule SlackMessenger.Workers.DeleteTest do
  use SlackMessenger.DataCase
  use Oban.Testing, repo: SlackMessenger.Repo
  use Mimic

  test "happy path works" do
    expect(Finch, :request!, 1, fn _, _ ->
      %Finch.Response{status: 200, body: Jason.encode!(%{"ok" => true})}
    end)

    assert :ok = perform_job(SlackMessenger.Workers.Delete, %{"slack_ts" => 500})
  end

  # would add some failing tests too
end
