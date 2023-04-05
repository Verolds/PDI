#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 2

using TestImages, ImageView, Images, Revise, ImageSegmentation, Statistics, Plots

global repre =5;

mostrar(I) = return imshow(I, canvassize=(500, 300));

# Formula distancia por valores RGB
distancia(des,comp,pos) = sqrt((float(red(des)) - red(comp[pos]))^2
                        + (float(green(des)) - green(comp[pos]))^2
                        + (float(blue(des)) - blue(comp[pos]))^2);

function seleccion(img, pos)
    s = mostrar(img);
    contador = 0;
    println("\n\nSeleccina $repre pixeles por clase: ")
    while true
        #Leemos posicion del mouse 
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            println("x = $(Int(round(float(x)))), y = $(Int(round(float(y))))")

            if x != -1 && y != -1
                    #Evaluamos el pixel seleccionado y lo clasificamos
                    pixel = img[Int(round(float(x))), Int(round(float(y)))];
                    contador += 1;
                    try
                        cl[pos][contador+1] = pixel;
                        println("valor $contador agregado") 
                    catch BoundsError
                        println("ERROR SOLO $repre PIXELES POR CLASE")
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
    img = load("4SEM/IMG/Parcial1/Practicas/Images/playa.jpg");
    #Seleccion de clases y representantes
    global cl = [["Sky" undef undef undef undef undef], ["Water" undef undef undef undef undef], ["Sand" undef undef undef undef undef]]
    seleccion(img, 1);
    seleccion(img, 2);
    seleccion(img, 3); 
    # Mostramos canvas 
    s = mostrar(img);
   
    plt = plot3d(
        1,
        xlim = (0, 1),
        ylim = (0, 1),
        zlim = (0, 1),
        title = "ahhhhhh",
        legend = false,
        marker = 2,
    )

    anim = Animation()
    
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
                comp = [mean(cl[1][2:end]) mean(cl[2][2:end]) mean(cl[3][2:end])]
                
                local d = Dict( "Sky" => distancia(desc,comp,1), "Water" => distancia(desc,comp,2), "Sand" => distancia(desc,comp,3));

                local grafica = [comp[1] comp[2] comp[3] float(desc)];
        
                # build an animated gif by pushing new points to the plot, saving every 10th frame
                for i=1:4
                    push!(plt, red(grafica[i]), green(grafica[i]), blue(grafica[i]))
                    frame(anim)
                end

                gif(anim, "4SEM/IMG/Parcial1/Practicas/Images/p2.jpg", fps = 15)

                local min = minimum(values(d));

                for (k, v) = d
                    if (v == min)
                        println("El pixel seleccionado pertenece a $k")
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