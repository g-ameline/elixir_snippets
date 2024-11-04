
# declare dependencies
Mix.install([
## cowboy plug dependencies
  :plug,
  :plug_cowboy,
## bandit router
  :bandit,
## phoenix dependencies
  :phoenix,
  :jason,
  # :plug_cowboy,
])

## cowboy part

Application.put_env(:sample, Example.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5555],
  server: true,
  live_view: [signing_salt: "aaaaaaaa"],
  secret_key_base: String.duplicate("a", 64)
)
defmodule Example.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  plug(Plug.Static,
    at: "static",
    from: "./" ,
    only: ["index.html","script.js","favicon.png"]
  )
end
children = [Example.Endpoint]
{:ok, _} = Supervisor.start_link([Example.Endpoint], strategy: :one_for_one)

# unless running from IEx, sleep idenfinitely so we can serve requests
### bandit router 

defmodule PlugEx.Router do
  IO.puts "listening at 8000"
	use Plug.Router
	use Plug.Debugger
	plug(Plug.Logger, log: :debug)
  # plug Plug.Static ,
  #   at: "static", 
  #   from: "./" #"."    # "./"
    # only: ["index.html","script.js","favicon.png"]
	plug :match
	plug :dispatch

	get "/" do
    IO.puts "at root path"
		send_resp(conn, 200, "Hello There!")
	end

	get "/about/:user_name" do
		send_resp(conn, 200, "Hello, #{user_name}")
	end

	get "/home" do
		conn = put_resp_content_type(conn, "text/html")
		send_file(conn, 200, "static/index.html")
	end
	match _, do: send_resp(conn, 404, "404 error not found!")
end


# Plug.Cowboy.http(PlugEx.Router, [], port: 80000) # start directly
# # Bandit.start_link(plug: StaticServer, port: 6666) # start directly
cowboy_static_6 = {Plug.Cowboy , scheme: :http , plug: PlugEx.Router, options: [port: 8888] }
{:ok, _} = Supervisor.start_link([cowboy_static_6] , strategy: :one_for_one)

# bandit_router_5 = {Bandit , scheme: :http , plug: StaticServer , port: 5555 }

defmodule RouterBasic do
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  get "/dude" do
    send_resp(conn, 200, "Hello, dude from bandit!")
  end
	get "/home" do
		conn = put_resp_content_type(conn, "text/html")
		send_file(conn, 200, "static/index.html")
  end
	get "/script.js" do
		conn = put_resp_content_type(conn, "text/javascript")
		send_file(conn, 200, "static/script.js")
  end
  get "/" do
    send_resp(conn, 200, "Hello, bandit!")
  end
  match _ do
    send_resp(conn, 404, "not found")
  end
end

cowboy_plug_8 = {Plug.Cowboy , scheme: :http , plug: RouterBasic , options: [port: 4321] }
Bandit.start_link(plug: RouterBasic, port: 4321) # start directly

defmodule CowboyStatici do
  use Plug.Builder

  plug(Plug.Static,
    at: "static",
    from: "./" ,
    only: ["index.html","script.js","favicon.png"]
  )
end

children = [{Plug.Cowboy, scheme: :http,plug: CowboyStatic, options: [ port: 8099,] }]
IO.puts("Starting server at http://localhost:8099")
Supervisor.start_link(children, strategy: :one_for_one)

Process.sleep(:infinity)
