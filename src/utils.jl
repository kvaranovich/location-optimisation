using Dates

function logger(message, level=0)
    output_message = "_"^(4*level) * " [" * string(now()) * "] - " * message
    println(output_message)
end
