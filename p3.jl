#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 3

using TestImages, ImageView, Images, Revise, ImageSegmentation, Statistics, Plots

global repre = 15;

mostrar(I) = return imshow(I, canvassize=(500, 300));

# Formula distancia por valores RGB
distancia(des,comp,pos) = sqrt((float(red(des)) - red(comp[pos]))^2
                        + (float(green(des)) - green(comp[pos]))^2
                        + (float(blue(des)) - blue(comp[pos]))^2);

function dividr(clase, arr, cord)
    for i in 1:length(clase)
        push!(arr, clase[i][cord])
    end
end

function seleccion(img, cl, auxc)
    s = mostrar(img);
    contador = 0;
    println("\n\nSeleccina $repre pixeles")
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
                        push!(cl, pixel)
                        push!(auxc, aux)
                        contador += 1;
                        println("valor $contador agregado")
                    else
                        println("ERROS SOLO $repre VALORES")
                    end
            end
        end
        
        println("Si deseas salir de seleccion ingresa 'q' ");
        input = readline(stdin);
        if input == "q"
            break;
        end
    end
end

                        
function main()
    # Seleccion de imagen
    img = load("4SEM/IMG/Parcial1/Practicas/Images/Belgium.png");
    m, n = size(img)
    #Seleccion de clases y representantes
    cl = [];
    auxc = [];
    descaux = [];
    seleccion(img, cl, auxc);

    # scatter!(auxc[1:15][1], auxc[1:15][2], markercolor=[:red,:green,:blue])

    c1 = []; c1aux = [];
    c2 = []; c2aux = [];
    c3 = []; c3aux = [];
    
    for i in 1:repre
        if (blue(cl[i])<0.1) .& (red(cl[i])<0.1) .& (green(cl[i])<0.1)
            push!(c1, cl[i])
            push!(c1aux, auxc[i]) 
        elseif (red(cl[i]) > 0.9) .& (green(cl[i]) < 0.5)
            push!(c3, cl[i])
            push!(c3aux, auxc[i]) 
        else
            push!(c2, cl[i])
            push!(c2aux, auxc[i]) 
        end
    end

    X1 = []; dividr(c1aux, X1, 1)
    Y1 = []; dividr(c1aux, Y1, 2)
    X2 = []; dividr(c2aux, X2, 1)
    Y2 = []; dividr(c2aux, Y2, 2)
    X3 = []; dividr(c3aux, X3, 1)
    Y3 = []; dividr(c3aux, Y3, 2)

    anim = Animation()
    scatter(Y1, X1, color=:black, label=false)
    scatter!(Y2, X2, color=:yellow, label=false)
    scatter!(Y3, X3, color=:red3, label=false)
    frame(anim)
    

    #Mostramos canvas 
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
                push!(descaux, daux);
                comp = [mean(c1[1:end]) mean(c2[1:end]) mean(c3[1:end])]
           
                local d = Dict( "Negro" => distancia(desc,comp,1), "Amarillo" => distancia(desc,comp,2), "Rojo" => distancia(desc,comp,3));
                local min = minimum(values(d));

                Xd = []; dividr(descaux, Xd, 1)
                Yd = []; dividr(descaux, Yd, 2)
                scatter!(Yd, Xd, color=:green, label=false)
                frame(anim)
                gif(anim, "4SEM/IMG/Parcial1/Practicas/Images/p3.gif", fps = 15)

                for (k, v) = d
                    if (v == min)
                        println("#####################################")
                        println("El pixel seleccionado pertenece a $k")
                        println("#####################################")
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