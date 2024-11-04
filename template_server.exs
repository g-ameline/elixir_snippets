
# declare dependencies
Mix.install([
  :plug,
  :plug_cowboy,
])

defmodule ServeTemplate do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    name = "dude"
    html = EEx.eval_file("./template/index.html.eex", name: name)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
  match _ do
    send_resp(conn, 404, "not found")
  end

end

Plug.Cowboy.http(ServeTemplate , [], port: 8888) # start directly
# cowboy_tempalte_server= {Plug.Cowboy , scheme: :http , plug: Serve_tempalte , options: [port: 8888] }
# {:ok, _} = Supervisor.start_link([cowboy_tempalte_server], strategy: :one_for_one)

Process.sleep(:infinity)
