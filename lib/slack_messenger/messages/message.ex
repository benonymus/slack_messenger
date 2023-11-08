defmodule SlackMessenger.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :subject, :string
    field :slack_ts, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:subject, :body, :slack_ts])
    |> validate_required([:subject, :body])
    |> validate_length(:subject, min: 3, max: 140)
    |> validate_length(:body, min: 3, max: 1000)
  end

  @doc false
  def changeset_slack_ts(message, attrs) do
    message
    |> cast(attrs, [:slack_ts])
    |> validate_required([:slack_ts])
  end
end
