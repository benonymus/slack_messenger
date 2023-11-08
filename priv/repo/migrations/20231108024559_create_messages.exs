defmodule SlackMessenger.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :subject, :string
      add :body, :text
      add :slack_ts, :string

      timestamps(type: :utc_datetime)
    end
  end
end
