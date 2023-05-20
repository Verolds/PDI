#     ESCUELA SUPERIOR DE COMPUTO IPN 
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 10

using TestImages, Images, Plots, StatsBase, DataStructures, DelimitedFiles

# Definición de la estructura del nodo del árbol Huffman
struct HuffmanNode
    value::Any
    frequency::Any
    left::Union{HuffmanNode, Nothing}
    right::Union{HuffmanNode, Nothing}
end

# Función para construir el árbol Huffman
function build_huffman_tree(text)
    # Crear una cola de prioridad para los nodos del árbol
    priority_queue = PriorityQueue{HuffmanNode, Any}()

    # Crear un nodo Huffman para cada carácter y agregarlo a la cola de prioridad
    for (val, prob) in text
        node = HuffmanNode(val, prob, nothing, nothing)
        enqueue!(priority_queue, node, node.frequency)
    end

    open("./p10.txt", "a") do io
        println(io, "\n####################")
        println(io, "Nodo y su frecuencia:")
        writedlm(io, priority_queue)
        println(io, "####################\n")
    end

    # Construir el árbol Huffman fusionando los nodos de menor frecuencia
    while length(priority_queue) > 1
        node1 = dequeue!(priority_queue)
        node2 = dequeue!(priority_queue)
        merged_freq = node1.frequency + node2.frequency
        merged_node = HuffmanNode(-1, merged_freq, node1, node2)
        open("./p10.txt", "a") do io
            println(io, "\n####################")
            println(io, "Nodos Nuevos y Nuevas frecuencias:")
            println(io, "Nodos: $node1, $node2 y nueva frecuencia $merged_freq")
            println(io, "Frecuencia: $merged_freq")
            println(io, "####################\n")
        end
        enqueue!(priority_queue, merged_node, merged_node.frequency)
        
        open("./p10.txt", "a") do io
            println(io, "\n####################")
            println(io, "Nuevo Arbol:")
            writedlm(io, priority_queue)
            println(io, "####################\n")
        end
    end

    # Devolver el nodo raíz del árbol Huffman
    aux = dequeue!(priority_queue)
    open("./p10.txt", "a") do io
        println(io, "\n####################")
        println(io, "Arbol de Huffman:")
        println(io, aux)
        println(io, "####################\n")
    end
    return aux
end

# Función auxiliar para generar los códigos Huffman recursivamente
function generate_huffman_codes(node::HuffmanNode, code::AbstractString, codes::Dict{Any, AbstractString})
   if node.value != -1
        codes[node.value] = code
        open("./p10.txt", "a") do io
            println(io, "\n####################")
            println(io, "Valor y su codigo final:")
            writedlm(io, [node.value code ])
            println(io, "####################\n")
        end
    else
        open("./p10.txt", "a") do io
            println(io, "\n####################")
            println(io, "Se agrego un 0 a $node.left")
            println(io,"Genernado codigo:")
            println(io, code * "0")
            println(io, "Se agrego un 1 a $node.right")
            println(io, "Genernado codigo:")
            println(io, code * "1")
            println(io, "####################\n")
        end
        generate_huffman_codes(node.left, code * "0", codes)
        generate_huffman_codes(node.right, code * "1", codes)
    end
end

# Función principal para codificar un texto usando Huffman
function huffman_encode(text)
    # Construir el árbol Huffman
    huffman_tree = build_huffman_tree(text)

    # Generar los códigos Huffman para cada carácter
    open("./p10.txt", "a") do io
        println(io, "\n####################")
        println(io, "Codificando:")
        println(io, "####################\n")
    end
    codes = Dict{Any, AbstractString}()
    generate_huffman_codes(huffman_tree, "", codes)

    return codes
end

function main()
    # Cargar imagen
    img = testimage("fabio_gray_256");
    # Castear imagen 
    img_copy = round.(Int, Float64.(copy(img)) .* 255);
    # Tamaño de la imagen
    m, n = size(img)
    total_b = m * n

    # Histogramas
    hist = fit(Histogram, vec(img_copy), nbins=255);
    plt = plot(hist, opacity=.5)
    display(plt)
    edges= collect(hist.edges[1][1:end-1]);

    # Pixeles de la imagen y su probabilidad 
    g =[i for i in edges]
    P_g = [(i/total_b) for i in hist.weights]
    # Agrupamos los valores de g y P_g
    values = []
    for i in 1:size(g,1)
        if P_g[i] != 0
            push!(values, [g[i], P_g[i]]) 
        end
    end

    #Aplicamos el codigo Huffman a cada pixel con su probabilidad
    codes = huffman_encode(values);

    # Calculamos la eficiencia de la imagen
    H_IMG = 0
    Len = 0
    for i in values 
        H_IMG = H_IMG + i[2]*log2(1/i[2])
        Len = Len + i[2]*length.(codes[i[1]])
    end
    ef = (H_IMG/Len) * 100

    # Imprimimos en txt los codigos y la eficiencia
    open("./p10.txt", "a") do io
        println(io, "\n####################")
        println(io, "Códigos Huffman:")
        writedlm(io, sort(codes), ",\n")
        println(io, "####################\n")
        println(io, "\n####################")
        println(io, "H(f) : $H_IMG")
        println(io, "Len : $Len")
        println(io, "Eficiencia del codigo: $ef%")
        println(io, "####################\n")
    end
    
    # Ciclo para elegir un valor en especifico
    while true
        println("\n########################################")
        println("Ingresa un rango del: [0:255]")
        println("Ingresa el numero menor: ")
        xMin = parse(Int, readline())
        println("Ingresa el numero mayor: ")
        xMax = parse(Int, readline())
    
        if xMin ≥ 0 && xMax <= 255
            # Histograma del rango deleccionado
            p_range  = plot(plt, xlim=(xMin,xMax), yflip = false);
            display(p_range)
            aux1 = codes[xMin]
            aux2 = codes[xMax]
            # Escribimos en el txt el codigo y su valor
            open("./p10.txt", "a") do io
                println(io, "\n####################")
                println(io, "Códigos Huffman de los valores seleccionados:")
                println(io, "$xMin : $aux1")
                println(io, "$xMax : $aux2")
                println(io, "####################\n")
            end
        else 
            println("Por favor ingresa una opcion valida")    
        end
      
        println("\n########################################")
        println("Si deseas salir del programa ingresa 'q' o presiona cualquier tecla")
        op = readline()
        if op  == "q"
            break
        end
    end 
    # Eliminamos el archivo creado
    rm("./p10.txt")
end
