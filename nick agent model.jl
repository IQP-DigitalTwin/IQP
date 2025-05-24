using Agents # bring package into scope
using Random: Xoshiro
using CairoMakie

size = (15, 15)
@agent struct SAgent(GridAgent{2})
    mood::Bool
    group::Int
end

function schelling_step!(agent, model)
    minhappy = model.mintobehappy
    samegroupneighbors = 0
    for neighbor in nearby_agents(agent, model)
        if agent.group == neighbor.group
            samegroupneighbors += 1
        end
    end
    if samegroupneighbors >= minhappy
        agent.mood = true
    else
        agent.mood = false
        move_agent_single!(agent, model)
    end
    return
end

function initialize(; total_agents = 200, gridsize = (15, 15), mintobehappy = 4, seed = 892)
    properties = Dict(:mintobehappy => mintobehappy)
    space = GridSpaceSingle(gridsize; periodic = false, metric = :chebyshev)
    rng = Xoshiro(seed)
    model = AgentBasedModel(
        SAgent,
        space;
        properties = properties,
        rng = rng,
        scheduler = Schedulers.Randomly(),
        agent_step! = schelling_step!
    )

    for n in 1:total_agents
        add_agent_single!(model; mood = false, group = n < total_agents / 2 ? 1 : 2)
    end
    return model
end

happy95(model, time) = count(a -> a.mood == true, allagents(model))/nagents(model) >= .95

schelling = initialize()

groupcolor(a) = a.group == 1 ? :red : :green
groupmarker(a) = a.group == 1 ? :circle : :octagon

anim = abmvideo(
    "schelling.mp4", schelling;
    agent_color = groupcolor, agent_marker = groupmarker, agent_size = 10,
    framerate = 4, frames = 20,
    title = "test"
)

