#     ESCUELA SUPERIOR DE COMPUTO IPN 
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 9

using TestImages, Images, FFTW, TypedTables

function zigZag(matrix, row, col)
    result = rand(Int, row*col)
    result[1] = matrix[1,1]
    k=2
    i=j=1
    while k < (row*col)
        while i>=2 && j<row
            i-=1
            j+=1
            result[k] = matrix[i,j]
            k+=1
        end
        if j<row
            j+=1
            result[k] = matrix[i,j]
            k+=1
        elseif i<col
            i+=1
            result[k] = matrix[i,j]
            k+=1
        end
        while i<col && j>=2
            i+=1
            j-=1
            result[k] = matrix[i,j]
            k+=1
        end
        if i<col
            i+=1
            result[k] = matrix[i,j]
            k+=1
        elseif j<row
            j+=1
            result[k] = matrix[i,j]
            k+=1
        end
    end
    return result 
end  

function binary_code(num)
    b = string(abs(num); base=2)
    b = replace(b, "0" => "1",  "1" => "0")
    return string((parse(Int, b, base = 2) + 1); base=2)
end

function main()

    img = testimage("fabio_gray_256")
    n,m = size(img)
    og = (Float64.(img))

    bloque = 8
    info= []

    mtx_Q = [
        16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;
        14 13 16 24 40 57 69 56;
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99
    ];
    mtx_Q = mtx_Q ./ 255

    t = Table( 
        Range = [0, -1:1, 
                -3:-2, 2:3, 
                -7:-4, 4:7, 
                -15:-8, 8:15, 
                -31:-16, 16:31, 
                -63:-32, 32:63,
                -127:-64, 64:127,
                -255:-128, 128:255, 
                -511:-256, 256:511],
        Category = [0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9],
        Base_Code = ["010", "011", "100", "100", "00", "00", "101", "101", "110", 
        "110", "1110", "1110", "11110", "11110", "111110", "111110", "1111110", "1111110"],
        Longitud = [3, 4, 5, 5, 5, 5, 7, 7, 8, 8, 10, 10, 12, 12, 14, 14, 16, 16],
    );

    Run = [
        [ ["00", "01", "100", "1011", "11010", "111000", "1111000", "1111110110", "1111111110000010"],
        [3, 4, 6, 8, 10, 12, 14, 18, 25] ] , 
        [["1100", "111001", "1111001", "111110110", "11111110110", "1111111110000100", "1111111110000101", "1111111110000110", "1111111110000111"],
        [5, 8, 10, 13, 16, 22, 23, 24, 25]],
        [["11011", "11111000", "1111110111", "1111111110001001", "1111111110001010", "1111111110001011", "1111111110001100", "1111111110001101", "1111111110001110"],
        [6, 10, 13, 20, 21, 22, 23, 24, 25]],
        [["111010", "111110111", "11111110111", "1111111110010000", "1111111110010001", "1111111110010010", "1111111110010011", "1111111110010100", "1111111110010101"],
        [7, 11, 14, 20, 21, 22, 23, 24, 25]],
        [["111011", "1111111000", "1111111110010111", "1111111110011000", "1111111110011001", "1111111110011010", "1111111110011011", "1111111110011100", "1111111110011101"],
        [7, 12, 19, 20, 21, 22, 23, 24, 25]],
        [["1111010", "1111111001", "1111111110011111", "1111111110100000", "1111111110100001", "1111111110100010", "1111111110100011", "1111111110100100", "1111111110100101"],
        [8, 12, 19, 20, 21, 22, 23, 24, 25]],
        [["1111011", "11111111000", "1111111110100111", "1111111110101000", "1111111110101001", "1111111110101010", "1111111110101011", "1111111110101100", "1111111110101101"],
        [8, 13, 19, 20, 21, 22, 23, 24 ,25]],
        [["11111001", "11111111001", "1111111110101111", "1111111110110000", "1111111110110001", "1111111110110010", "1111111110110011", "1111111110110100", "1111111110110101"],
        [9, 13, 19, 20, 21, 22, 23, 24, 25]],
        [["11111010", "111111111000000", "1111111110110111", "1111111110111000", "1111111110111001", "1111111110111010", "1111111110111011", "1111111110111100", "1111111110111101"],
        [9, 17, 19, 20, 21, 22, 23, 24, 25]],
        [["111111000", "1111111110111111 ", "1111111111000000", "1111111111000001", "1111111111000010", "1111111111000011", "1111111111000100", "1111111111000101", "1111111111000110"],
        [10, 18, 19, 20, 21, 22, 23, 24, 25]]
    ];

    for i in 1:bloque:n-bloque+1
        for j in 1:bloque:m-bloque+1
            aux = og[i:i + bloque-1, j:j + bloque-1] .- (128/255)
            push!(info, aux)
        end
    end

    while true
        println("\n########################################")

        bounds = size(info, 1)
        len = Array{Int}(undef,64)
        code = Array{String}(undef,64)
        code_aux = Array{String}(undef,64)
        cat = Array{Int}(undef,64)
        binaryCd = Array{String}(undef,64)

        println("Ingresa el numero del cuadrado: [2:$bounds]")
        usuario = parse(Int, readline())

        if usuario > 1 && usuario <= bounds
            
            cont = 0
            len .= 0
            cat .= 0
            code_aux .= ""
            code .= ""
            binaryCd .= ""
            cuadro = round.(Int, dct(info[usuario])./mtx_Q)

            println("\nCuador seleccionado:")
            display(cuadro)
            result = zigZag(cuadro, 8,8)

            if result[1] == 0
                code[1] = t.Base_Code[1]
                len[1] = t.Longitud[1]
                cat[1] = t.Category[1]
            end
            
            for j in 1:size(t,1)
                if (result[1] in t.Range[j]) && (result[1] != 0)
                    code[1] = t.Base_Code[j]
                    len[1] = t.Longitud[j]
                    cat[1] = t.Category[j]
                end
            end

            resta =  round(Int, cuadro[1] - info[usuario][1])
            binaryCd[1] = string(Int(abs(resta)); base=2)
            code_aux[1] = code[1] * binaryCd[1]
            
            for i in 2:size(result,1)
                if result[i] == 0
                    cat[i] = t.Category[1]
                end
                for j in 1:size(t,1)
                    if (result[i] in t.Range[j]) && (result[i] != 0)
                        cat[i] = t.Category[j]
                    end
                end
            end
        
            for i in 2:size(result,1)
                if result[i] == 0 
                    cont += 1
                    code[i] = "1010"
                    len[i] = -1
                elseif result[i] != 0
                    binaryCd[i] = binary_code(result[i])
                    code[i] = Run[cont+1][1][cat[i]]
                    code_aux[i] = code[i] * binaryCd[i]
                    len[i] = Run[cont + 1][2][cat[i]]
                    cont = 0
                end
            end

            for  i in 2:size(result,1)
                if result[i] != 0
                    if length.(code_aux[i]) != len[i] 
                        while length.(code_aux[i]) != len[i] 
                            binaryCd[i] = "0" * binaryCd[i]
                            code_aux[i] = code[i] * binaryCd[i] 
                        end 
                    end
                end
            end

            #push!(code_aux, "1010");

            t2 = Table(
                    Numero =  filter(e->e∉0,result),
                    Categoria = filter(e->e∉0,cat),
                    Code = filter(e->e != "" ,code_aux),
                    Longitud = filter(e->e∉-1,len)
            )
            
            println("\nCodificacion")
            display(t2)
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
end






