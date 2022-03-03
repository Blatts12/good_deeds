defmodule GoodDeeds.Points.GiveawayNotifier do
  import Bamboo.Email
  alias GoodDeeds.Mailer

  @from_address "noreplay@example.com"

  # Delivers the email using the application mailer.
  defp deliver(to, subject, text_body, html_body) do
    email =
      new_email(
        to: to,
        from: @from_address,
        subject: subject,
        text_body: text_body,
        html_body: html_body
      )
      |> Mailer.deliver_now()

    {:ok, email}
  end

  @doc """
  Deliver notification about recived points
  """
  def deliver_giveaway_notification(from_user, to_user, points) do
    text_body = """
    ==========================
    
      Hi #{to_user.email}
    
      You recived #{points} points from #{from_user.email}
    
    ==========================
    """

    html_body = """
      Hi #{to_user.email}, <br/><br/>
      You recived <strong>#{points} points</strong> from #{from_user.email}
    """

    deliver(to_user.email, "You recived points", text_body, html_body)
  end
end
