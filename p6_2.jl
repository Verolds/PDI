#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     ECUALIZACIÓN HISTOGRAMA / HISTOGRAMA DE CORRESPONDENCIA
#     PRACTICA 6
using TestImages, Images, Plots, StatsBase, ImageView, Colors, TypedTables

# Valores RGB de la imagen tipo float
function channel_matrix(channel, img)
    aux_channel = channel.(img)
    img_n0f8_raw = rawview(aux_channel)
    return float.(img_n0f8_raw)
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

function ecualizacion(t, rango)
    MAX = maximum(vec(t.g))
    MIN = minimum(vec(t.g))
    F = []
    for i in 1:rango 
        push!(F, ceil((MAX - MIN)*(t.P_acum[i]) + MIN))
    end
    return F
end

function prob_acumulada(rango, col)
    value = 0
    aux = []
    for i in 1:rango
        value += col[i]
        push!(aux, value)   
    end
    return aux
end

function create_nc(tabla, channels)
    new = zeros(m,n)
    for i=1:m, j=1:n
        for k in 1:length(tabla.g)
            if channels[i,j] == tabla.g[k]
                new[i,j] = tabla.F_g[k] 
            end 
        end
    end
    return new
end

function main()
    #Imagen 
    img = testimage("fabio");
    #img = load("/Users/macbook/Desktop/ESCOM/4SEM/IMG/Parcial1/p5.png")
    #Tamaño de la imagen
    global m,n = size(img)
    total_b = m * n

    # Canales RGB
    channels =[ channel_matrix(red, img) , channel_matrix(green, img), channel_matrix(blue, img)]
    # Histogramas del RGB
    hr = fit(Histogram, vec(channels[1]), nbins=255)
    hg = fit(Histogram, vec(channels[2]), nbins=255)
    hb = fit(Histogram, vec(channels[3]), nbins=255)
    p1 = plot(hr, color=:red3, opacity=.5)
    p2 = plot(hg, color=:green, opacity=.5)
    p3 = plot(hb, color=:blue, opacity=.5)

    edges_r= collect(hr.edges[1][1:end-1])
    range_r = length(edges_r)
    edges_g= collect(hg.edges[1][1:end-1])
    range_g = length(edges_g)
    edges_b= collect(hb.edges[1][1:end-1])
    range_b = length(edges_b)

    tr = FlexTable(g =[i for i in edges_r], 
                N_g = [j for j in hr.weights],
                P_g = [(i/total_b) for i in hr.weights],
                )
                tr.P_acum = prob_acumulada(range_r, tr.P_g)
                tr.F_g = ecualizacion(tr, range_r)

    tg = FlexTable(g =[i for i in edges_g], 
                N_g = [j for j in hg.weights],
                P_g = [(i/total_b) for i in hg.weights],
                )
                tg.P_acum = prob_acumulada(range_g, tg.P_g)
                tg.F_g = ecualizacion(tg, range_g)

    tb = FlexTable(g =[i for i in edges_b], 
                N_g = [j for j in hb.weights],
                P_g = [(i/total_b) for i in hb.weights],
                )
                tb.P_acum = prob_acumulada(range_b, tb.P_g)
                tb.F_g = ecualizacion(tb, range_b)

    
    new_channels = [create_nc(tr, channels[1]), create_nc(tr, channels[2]), create_nc(tr, channels[3]) ]

    #Histogramas nuevos canales
    hr_new = fit(Histogram, vec(new_channels[1]), nbins=255)
    hg_new = fit(Histogram, vec(new_channels[2]), nbins=255)
    hb_new = fit(Histogram, vec(new_channels[3]), nbins=255)

    p4 = plot(hr_new, color=:red3, opacity=.5)
    p5 = plot(hg_new, color=:green, opacity=.5)
    p6 = plot(hb_new, color=:blue, opacity=.5)

    #Mostramos los Histogramas
    p = plot(p1, p2, p3, p4, p5, p6, layout=(2, 3), label="")
    gui()
    
    #Recremaos la imagen con los canales creados y la mostramos
    img_New = recreate_img(new_channels);
    imshow(mosaicview(Gray.(img), img_New))
end