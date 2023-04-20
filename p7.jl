#     ESCUELA SUPERIOR DE COMPUTO IPN 
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 7

using TestImages, ImageView, Images

function predictor(A)
    #Create matrix 
    out = zeros(size(A))
    # Get Indices of A to iterate
    R = CartesianIndices(A)
    Ifirst, Ilast = first(R), last(R)
    I1 = oneunit(Ifirst)
    # Get positions of high frecuencies values 
    HighFre = [x for x in R if x[1]==1 || x[2]==1]

    for I in R
        n, s = 0, zero(eltype(out))
        # Evaluate 3X3 submatrix and gets his mean
        for J in max(Ifirst, I-I1):min(Ilast, I+I1)
            s += A[J]
            for x in A[J] 
                if x != 0
                    n += 1
                end
            end
        end
        if I ∉ HighFre
            out[I] = s/n
            A[I] = out[I]
        end
    end
end

function main()
    #  Load Image
    img_og = testimage("fabio_gray_256")
    # Image size
    n,m = size(img_og)
    # Create Predictor matrix
    P = zeros(n,m)
    # blocs 8x8
    bloque = 8

    for i in 1:bloque-1:n - bloque+1
        for j in 1:bloque-1:m - bloque+1
            p_aux = zeros(bloque,bloque)
            @views aux = img_og[i:i + bloque-1, j:j + bloque-1]
            p_aux[1, 1:end] = aux[1, 1:end]
            p_aux[1:end, 1] = aux[1:end, 1]
            predictor(transpose(p_aux))

            P[i:i + bloque-1, j:j + bloque-1] = p_aux
        end
    end
   
    # Error matrix 
    E = img_og - P

    while true
        println("\n########################################")
        println("Ingresa el numero de bits a comprimir: ")
        n_bits = parse(Int, readline())

        n_muestras = 2^n_bits
        max_val = maximum(E)
        min_val = minimum(E)
        
        rg = (max_val - min_val) / n_muestras
        intervalo = collect(Float64(min_val):Float64(rg):Float64(max_val))

        #Quantification matrix
        Q = zeros(size(P))

        for j in CartesianIndices(E)
            for k in 1:length(intervalo)
                if E[j] == min_val
                    Q[j] = 1
                end
                if E[j] > intervalo[k]
                    Q[j] = k
                end
            end
        end
        #intervalo
        inversa = []
        
        for x in 1:length(intervalo)
            if x < length(intervalo)
                c = (intervalo[x] + intervalo[x+1])/ 2
                push!(inversa, c)  
            end
        end
        
        Q_inv = zeros(size(P))
        
        for j in CartesianIndices(Q)
            for k in 1:length(inversa) 
                if Q[j] == k
                    Q_inv[j] = inversa[k]
                end
            end
        end
        
        #Final matrix
        M_recup = Q_inv  + P
        
        k= mosaicview(img_og, P, E, M_recup; nrow=2)
        display(k)
        s_n = 10 * log10(sum(Float64.(img_og).^2) / sum((Float64.(img_og) - M_recup).^2))
        println("Signal/Noice : $s_n")

        println("\n########################################")
        println("Si deseas salir del programa ingresa 'q' o presiona cualquier tecla")
        op = readline()
        if op  == "q"
            break
        end
    end
end
