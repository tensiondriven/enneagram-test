defmodule EnneagramWebWeb.HomeLiveTest do
  use EnneagramWebWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "home page" do
    test "renders the landing page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Enneagram Test"
      assert html =~ "Discover Your Personality Type"
      assert html =~ "70 questions"
    end

    test "displays feature highlights", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Your Primary Type"
      assert html =~ "Core Motivations"
      assert html =~ "Growth Path"
    end

    test "has start test button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view |> element("button", "Start Test") |> has_element?()
    end

    test "start test button navigates to test page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Click start test button
      view |> element("button", "Start Test") |> render_click()
      assert_redirect(view, "/test")
    end

    test "displays pro tip", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Pro Tip"
      assert html =~ "naturally"
    end
  end
end
