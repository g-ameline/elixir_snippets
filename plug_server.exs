
# def deps do
#  [
#    {:plug_cowboy, "~> 2.0"}
#  ]
# end

Mix.install([:plug, :plug_cowboy])
defmodule MyPlug do

  use Plug.Router
  plug :match
  plug :dispatch

  get "/" do 
    send_file(conn,200,"./index.html")
  end
  get "/script.js" do
    send_file(conn,200,"./script.js")
  end
    
  # use Plug.Builder
  # plug Plug.Static,
  #   at: "/static",
  #   from: "",
  #   only: ~w(images robots.txt)
  # plug :not_found

  # def not_found(conn, _) do
  #   send_resp(conn, 404, "not found")
  # end
end

require Logger
webserver = {Plug.Cowboy, plug: MyPlug, scheme: :http, options: [port: 4000]}
{:ok, _} = Supervisor.start_link([webserver], strategy: :one_for_one)
Logger.info("Plug now running on localhost:4000")
Process.sleep(:infinity)
