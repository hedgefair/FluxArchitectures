# Function for loading sample data

"""
    get_data(dataset, poollength, datalength, horizon)

Function for importing one of the sample datasets in the repository. `dataset` can be one of
`:solar`, `:traffic`, `:exchange_rate` or `:electricity`. `poollength` gives the number of
timesteps to pool for the model, `datalength` determines the batch size of the output data,
and `horizon` determines the number of time steps that should be forecasted by the model.
"""
function get_data(dataset, poollength, datalength, horizon)
    admissible = [:solar, :traffic, :exchange_rate, :electricity]
    dataset in admissible || error("Sample data not implemented")

    datalength = datalength + poollength
    (dataset == :solar) && (BSON.@load "../data/solar_AL.bson" inp_raw)
    (dataset == :traffic) && (BSON.@load "../data/traffic.bson" inp_raw)
    (dataset == :exchange_rate) && (BSON.@load "../data/exchange_rate.bson" inp_raw)
    (dataset == :electricity) && (BSON.@load "../data/electricity.bson" inp_raw)

    out_ft = similar(inp_raw, size(inp_raw,2), poollength, 1, size(inp_raw,1))
    for i=0:poollength-1
        for j=poollength:min(datalength, size(inp_raw,1)-poollength)
            out_ft[:,i+1,1,j] = inp_raw[j-i,:]
        end
    end
    out_lb = circshift(inp_raw[1:datalength-poollength,1], -horizon)
    return out_ft[:,:,:,1:min(datalength, size(inp_raw,1)-poollength)-poollength], out_lb
end
