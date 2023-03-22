using Plots: size
#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 4

using ImageView, Images, Plots, Statistics

global repre = 1;

distancia(des,comp,pos) = sqrt((float(red(des)) - red(comp[pos]))^2
                        + (float(green(des)) - green(comp[pos]))^2
                        + (float(blue(des)) - blue(comp[pos]))^2);

mostrar(I) = return imshow(I, canvassize=(500, 300));

function dividr(clase, arr, cord)
    for i in 1:length(clase)
        push!(arr, clase[i][cord])
    end
end

function seleccion(img, pos)
    s = mostrar(img); 
    contador = 0;
    while true
        #Leemos posicion del mouse 
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            # println("x = $(Int(round(float(x)))), y = $(Int(round(float(y))))")

            if x != -1 && y != -1
                    #Evaluamos el pixel seleccionado y lo clasificamos
                    pixel = img[Int(round(float(x))), Int(round(float(y)))];
                    aux = [Int(round(float(x))) Int(round(float(y)))];
                    if contador < repre
                        push!(clases[pos], pixel)
                        push!(clasesAux[pos], aux)
                        contador += 1;
                        println("\nvalor $contador agregado")
                    else
                        println("ERROS SOLO $repre VALORES")
                    end
            end
        end
        
        print("Si deseas salir de seleccion ingresa 'q' ");
        input = readline(stdin);
        if input == "q"
            break;
        end
    end
end

                        
function main()
    # Seleccion de imagen
    img = load("/Users/macbook/Desktop/ESCOM/4SEM/IMG/Parcial1/Belgium.png");
    m, n =size(img)
    descA=[]

    println("Ingresa el numero de clases: ");
    cInput = parse(Int64, readline(stdin))

    global clases = [[] for i=1:cInput]
    global clasesAux = [[] for i=1:cInput]

    for i in 1:cInput
        println("##############################")
        println("Slecciona la clase $i:")
        seleccion(img, i) 
    end

    println("Ingresa el numero de representantes: ");
    rInput = parse(Int64, readline(stdin))

    for  i in 1:cInput
        cont = 0;
        while cont < rInput
            x = rand(1:m);
            y = rand(1:n);
            pixel = img[x,y]
            pixelAux = [x y];

            println("Analizando [$pixelAux]")
            
            if pixel == clases[i][1]
                push!(clases[i], pixel)
                push!(clasesAux[i], pixelAux)
                cont+=1
                println("\n##############################")
                println("Valor [$pixelAux] aceptado")
                println("Representante $cont agregado a clase $i")
                println("##############################\n")
            end   
        end
    end

    X1 = []; dividr(clasesAux[1], X1, 1)
    Y1 = []; dividr(clasesAux[1], Y1, 2)
    X2 = []; dividr(clasesAux[2], X2, 1)
    Y2 = []; dividr(clasesAux[2], Y2, 2)
    X3 = []; dividr(clasesAux[3], X3, 1)
    Y3 = []; dividr(clasesAux[3], Y3, 2)

    anim = Animation()
    scatter(Y1, X1, color=:black, label=false)
    scatter!(Y2, X2, color=:yellow, label=false)
    scatter!(Y3, X3, color=:red3, label=false)
    frame(anim)

    s = mostrar(img); 
    #INICIO
    println("\n\nSelecciona un pixel aleatorio: ")
    while true
        #Leemos posicion del mouse 
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 

            if x != -1 && y != -1
                #Evaluamos el pixel seleccionado y lo clasificamos
                desc = img[Int(round(float(x))), Int(round(float(y)))];
                daux = [Int(round(float(x))) Int(round(float(y)))];
                push!(descA, daux);
                comp = []; 
                for i in 1:cInput 
                    push!(comp, mean(clases[i][1:end]))
                end
           
                local d = Dict( "Negro" => distancia(desc,comp,1), "Amarillo" => distancia(desc,comp,2), "Rojo" => distancia(desc,comp,3));
                local min = minimum(values(d));

                Xd = []; dividr(descA, Xd, 1)
                Yd = []; dividr(descA, Yd, 2)
                scatter!(Yd, Xd, color=:green, label=false)
                frame(anim)
                gif(anim, "/Users/macbook/Desktop/ESCOM/4SEM/IMG/Parcial1/p4.gif", fps = 15)

                for (k, v) = d
                    if (v == min)
                        println("\n#####################################")
                        println("El pixel seleccionado pertenece a $k")
                        println("#####################################\n")
                    end
                end 
            end
        end
        println("\n\nSi deseas salir del programas ingresa 'q' ");
        input = readline(stdin);
        if input == "q"
            break
        end
    end
end