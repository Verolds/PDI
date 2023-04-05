#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 1

# Manipulacion RGB de imagenes 

using  TestImages, Images

vista(x) = permuteddimsview(channelview(x) , (2,3,1));

img = testimage("fabio")

# Imagen roja
r = copy(img)
red_f = vista(r);
red_f[:,:,2:3] .= 0;

# Imagen verde
g = copy(img);
green_f = vista(g);
green_f[:,:,1:2:3] .= 0

# Imagen azul
b = copy(img);
blue_f = vista(b);
blue_f[:,:,1:2] .= 0 

A = mosaicview(img, r, g, b; nrow=2, rowmajor=true);

#####################################
lake = testimage("lake_color");
n, m = size(lake)

# División vertical de la imagen
img2 = copy(lake);
img2_f = vista(img2);

#Dividimos el tamaño la imagen en 3
t = Int(round(m/3));

img2_f[:, 1:t, 2:3 ] .= 0
img2_f[:, t:2*t, 1:2:3] .= 0
img2_f[:, 2*t:end, 1:2] .= 0

# División horizontal de la imagen
img3 = copy(lake);
img3_f = vista(img3);

#Dividimos el tamaño la imagen en 
th = Int(round(n/3));

img3_f[1:th, :, 2:3 ] .= 0
img3_f[th:2*th, :, 1:2:3] .= 0
img3_f[2*th:end, :, 1:2] .= 0

BC = mosaicview(lake, img2, img3; nrow=1);

#####################################
img_path = "4SEM/IMG/Parcial1/Practicas/Images/letra.jpg"
letra = load(img_path);
n,m = size(letra)

letra_f = copy(letra);
mask = (blue.(letra_f).<0.1) .& (red.(letra_f).<0.1) .& (green.(letra_f).<0.1) 

# Fondo rojo y azul
letra_f[:, 1:Int(m/2)] .= RGB(1,0,0)
letra_f[:, Int(m/2):end] .= RGB(0,0,1)
#Letra verde
letra_f[mask] .= RGB(0,1,0);


D = mosaicview(letra, letra_f; nrow=1)