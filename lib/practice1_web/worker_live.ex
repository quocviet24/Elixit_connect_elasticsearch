# # Trong file worker_live.ex
# defmodule Practice1Web.WorkerLive do
#   use Phoenix.LiveView
#   alias Practice1.Sync

#   def mount(_params, _session, socket) do
#     {:ok, socket |> assign(:workers, Sync.get_all_worker())}
#   end

#   def handle_info(:update, socket) do
#     {:noreply, socket |> assign(:workers, Sync.get_all_worker())}
#   end

#   def render(assigns) do
#     ~HL"""
#     <.header>
#       Listing Workers
#       <:actions>
#         <.link href="/create">
#           <.button>New Worker</.button>
#         </.link>
#       </:actions>
#     </.header>

#     <.table id="worker" rows={@workers}>
#       <:col :let={worker} label="Name"><%= worker["name"] %></:col>
#       <:col :let={worker} label="Age"><%= worker["age"] %></:col>
#       <:col :let={worker} label="Salary"><%= worker["salary"] %></:col>
#       <:col :let={worker} label="Department"><%= worker["department_name"] %></:col>
#     </.table>
#     """
#   end
# end
