#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 5


using TestImages, Images, Plots, StatsBase, ImageView, Colors

# Valores RGB de la imagen tipo float
function channel_matrix(channel, img)
    aux_channel = channel.(img)
    img_n0f8_raw = rawview(aux_channel)
    return float.(img_n0f8_raw)
end

# Formula para expandir o comprimir histograma
function comp_expan(Img, New, newMIN, newMAX)
    MAX = maximum(vec(Img))
    MIN = minimum(vec(Img))

    for i=1:m, j=1:n
        New[i,j] = ceil(
                    (((Img[i,j] - MIN) / (MAX-MIN)) * (newMAX-newMIN))
                    + newMIN 
                    )
    end 
end

#Recrear imagen {Gray} desde los nuevos canales RGB
function recreate_img(RGB_channels)
    img_new = zeros(m,n)
    for i=1:m, j=1:n
        img_new[i,j] = Gray.(
            (0.299*RGB_channels[1][i,j] + 0.587*RGB_channels[2][i,j] + 0.114*RGB_channels[3][i,j] ) / 255
            )
    end
    return img_new
end

#Imagen 
img = testimage("fabio");
#Tamaño de la imagen
global m,n = size(img)

# Canales RGB
channels =[ channel_matrix(red, img) , channel_matrix(green, img), channel_matrix(blue, img)]
# Histogramas del RGB
hr = fit(Histogram, vec(channels[1]))
hg = fit(Histogram, vec(channels[2]))
hb = fit(Histogram, vec(channels[3]))
p1 = plot(hr, color=:red3, opacity=.5)
p2 = plot(hg, color=:green, opacity=.5)
p3 = plot(hb, color=:blue, opacity=.5)

while true
    #Inicializamos nuevos canales de RGB 
    new_channels = [zeros(m,n), zeros(m,n), zeros(m,n)]

    #Pedimos al usuario los valores del histograma MAX y MIN {edges}
    println("\n########################################")
    println("Ingresa el valor minimo de los valores del histograma")
    newMIN = parse(Int, readline())
    println("Ingresa el valor maximo de los valores del histograma")
    newMAX = parse(Int, readline())

    #Ocupamos la formula y creamos los nuevos canales RGB
    comp_expan(channels[1], new_channels[1], newMIN, newMAX);
    comp_expan(channels[2], new_channels[2], newMIN, newMAX);
    comp_expan(channels[3], new_channels[3], newMIN, newMAX);
    #Histogramas nuevos canales
    hr_new = fit(Histogram, vec(new_channels[1]))
    hg_new = fit(Histogram, vec(new_channels[2]))
    hb_new = fit(Histogram, vec(new_channels[3]))
    p4 = plot(hr_new, color=:red3, opacity=.5)
    p5 = plot(hg_new, color=:green, opacity=.5)
    p6 = plot(hb_new, color=:blue, opacity=.5)
    #Mostramos los Histogramas
    p = plot(p1, p2, p3, p4, p5, p6, layout=(2, 3), label="", fillrange=0,fillalpha=0.3)
    display(p)
    #Recremaos la imagen con los canales creados y la mostramos
    img_New = recreate_img(new_channels);
    imshow(mosaicview(Gray.(img), img_New))
    
    println("\n########################################")
    println("Si deseas salir del programa ingresa 'q'")
    println("Para continuar ingresa cualquier tecla")
    op = readline()
    if op  == "q"
        break
    end
end