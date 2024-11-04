
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

defmodule PlugCowboy do
  import Plug.Conn
  def init(options) do
   options   # initialize options
  end
  def call(conn, _opts) do 
    IO.puts("in call")
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp( 200 , "yo from cowboy\n")
  end
end
# Plug.Cowboy.http(PlugCowboy , [], port: 8888) # start directly
cowboy_plug_8 = {Plug.Cowboy , scheme: :http , plug: PlugCowboy , options: [port: 8888] }

### bandit router 

defmodule RouterBandit do
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  get "/dude" do
    send_resp(conn, 200, "Hello, dude from bandit!")
  end
  get "/" do
    send_resp(conn, 200, "Hello, bandit!")
  end
  match _ do
    send_resp(conn, 404, "not found")
  end
end

# Bandit.start_link(plug: RouterBandit, port: 7777) # start directly
bandit_router_7 = {Bandit , scheme: :http , plug: RouterBandit , port: 7777 }

#### phoenix style

Application.put_env(:phoenix, :json_library, Jason)
Application.put_env(:sample, PhoenixRouter.Endpoint, [
  http: [ip: {127, 0, 0, 1}, port: 3333],
  server: true,
  secret_key_base: String.duplicate("a", 64)
])

defmodule Router do
  use Phoenix.Router
  pipeline :browser do
    plug :accepts, ["html"]
  end
  scope "/", PhoenixRouter do
    pipe_through :browser
    get "/", SampleController, :index
    # Prevent a horrible error because ErrorView is missing
    get "/favicon.ico", SampleController, :index
  end
end
defmodule PhoenixRouter.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  plug Router
end
# {:ok, _} = Supervisor.start_link([PhoenixRouter.Endpoint], strategy: :one_for_one) # start directly

# phoenix_router_4 = {PhoenixEndpoint , scheme: :http , plug: RouterPhoenix , options: [port: 4444] }
# four = {Plug.Cowboy , scheme: :http , plug: Plug4 , options: [port: 8888] }
children = [
cowboy_plug_8,
bandit_router_7,
# # PhoenixRouter.Endpoint,
]
{:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)

Process.sleep(:infinity)
# System.no_halt(true)