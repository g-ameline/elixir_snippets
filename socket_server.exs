Mix.install([
:plug, 
:bandit, 
:websock_adapter
])

defmodule EchoServer do
  def init(options) do
    {:ok, options}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    IO.puts("ponging back the client")
    dbg self()
    {:reply, :ok, {:text, "pong"}, state}
  end

  def terminate(:timeout, state) do
    {:ok, state}
  end
end

defmodule Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title>
          My WebSocket App
        </title>
      </head>
      <body>
        <script>
        console.log("creating socket")
        sock  = new WebSocket("ws://localhost:4000/websocket")
        sock.addEventListener("message", console.log)
        sock.addEventListener("open", () => sock.send("ping"))
        </script>
      </body>
    </html>
    """)
  end

  get "/websocket" do
    conn
    |> WebSockAdapter.upgrade(EchoServer, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

require Logger
webserver = {Bandit, plug: Router, scheme: :http, port: 4000}
{:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)
Logger.info("Plug now running on localhost:4000")
Process.sleep(:infinity)
