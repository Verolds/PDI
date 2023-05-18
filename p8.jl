#     ESCUELA SUPERIOR DE COMPUTO IPN 
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 8

using TestImages, ImageView, Images, FFTW, SeisProcessing

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


img=testimage("fabio_gray_256")
n,m = size(img)
og = Float64.(copy(img))

aux_p1 = zeros(32,32)
aux_p2 = zeros(32,224)
aux_p3 = zeros(224,32)
aux_p4 = zeros(224,224)
p = zeros(n,m)

bloque = 8
info_p1 = []
info_p2 = []
info_p3 = []
info_p4 = []

for i in 1:bloque:n - bloque+1
    for j in 1:bloque:m - bloque+1
        #8x8
        @views aux = og[i:i + bloque-1, j:j + bloque-1]
        aux = dct(aux)
        og[i:i + bloque-1, j:j + bloque-1] = aux
        # Info for first p
        info1 = [i,j, aux[1,1]]
        push!(info_p1, info1)
        # Info for p 2 & 3
        unit_cords = 1
        for o in 1:7
            info2 = [i, o+j, aux[1:1, 2:end][1,o] ] 
            push!(info_p2, info2) 
            info3 = [o+i, j, aux[2:end, 1:1][o,1]] 
            push!(info_p3, info3) 
        end
        info4 = [i+unit_cords, j+unit_cords, aux[2:end, 2:end]] 
        push!(info_p4, info4) 
    end
end

cords4 = []
for i in 1:7:224 - 7+1
    for j in 1:7:224 - 7+1
        push!(cords4, [i:i + 7-1, j:j + 7-1])
    end
end

for j in 1:1024
    # Preictor 1
    if info_p1[j][1] == 1 || info_p1[j][2] == 1 
        aux_p1[j] = info_p1[j][3] 
    end
    # Preictor 4
    aux_p4[cords4[j][1],cords4[j][2]] = info_p4[j][3]
end

# Preictor 2 y 3
info_p2 = reshape(info_p2, 224,:)
info_p2 = info_p2'
info_p3 = reshape(info_p3, 32,:)
info_p3 = info_p3'

for j in 1: 7168
    aux_p2[j] = info_p2[j][3]
    aux_p3[j] = info_p3[j][3]
end

aux_p2[2:end, 2:end] .= 0
aux_p3[2:end, 2:end] .= 0
aux_p4[2:end, 2:end] .= 0

predictor(transpose(aux_p1))
predictor(transpose(aux_p2))
predictor(transpose(aux_p3))
predictor(transpose(aux_p4))

# Reconstruir Imagen
for i in 1:1024
    info_p4[i][3] = aux_p4[cords4[i][1],cords4[i][2]]
end

for i in 1:1024
    #og[Int64(info_p1[i][1]), Int64(info_p1[i][2])]  = aux_p1[i]
    p[Int64(info_p1[i][1]), Int64(info_p1[i][2])]  = aux_p1[i]
    p[Int64(info_p4[i][1]):Int64(info_p4[i][1])+6, Int64(info_p4[i][2]):Int64(info_p4[i][2])+6]  = info_p4[i][3]
end

for i in 1:7168
    #og[Int64(p2[i][1]), Int64(p2[i][2])]  = aux_p2[i]
    p[Int64(info_p2[i][1]), Int64(info_p2[i][2])]  = aux_p2[i]
    p[Int64(info_p3[i][1]), Int64(info_p3[i][2])]  = aux_p3[i]
end

function main()

    E = og - p

    while true
        println("\n########################################")
        println("Ingresa el numero de bits a comprimir [1:8]: ")
        n_bits = parse(Int, readline())
        if n_bits < 9 && n_bits ≥ 0
            n_muestras = 2^n_bits
            max_val = maximum(E)
            min_val = minimum(E)
            
            rg = (max_val - min_val) / n_muestras
            intervalo = collect(Float64(min_val):Float64(rg):Float64(max_val))

            #Quantification matrix
            Q = zeros(size(og))

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
            
            Q_inv = zeros(size(og))
            
            for j in CartesianIndices(Q)
                for k in 1:length(inversa) 
                    if Q[j] == k
                        Q_inv[j] = inversa[k]
                    end
                end
            end
            
            #Final matrix
            recup = Q_inv  + p

            for i in 1:bloque:n - bloque+1
                for j in 1:bloque:m - bloque+1
                    #8x8
                    aux = recup[i:i + bloque-1, j:j + bloque-1]
                    aux = idct(aux)
                    recup[i:i + bloque-1, j:j + bloque-1] = aux
                end
            end 

            k= mosaicview(img, p, E, Gray.(recup); nrow=2)
            display(k)

            s_n = MeasureSNR(Float64.(img), recup; db=false)
            println("PSNR : $s_n")
        
        else
            println("Ingresa un numero menor o igual a 8 y mayor a 0")
        end

        println("\n########################################")
        println("Si deseas salir del programa ingresa 'q' o presiona cualquier tecla")
        op = readline()
        if op  == "q"
            break
        end
    end
end


