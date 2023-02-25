#     INSTITUTO PLOTÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     PROCESAMEINTO DIGITAL DE IMAGENES
#     PRACTICA 1

# Sencilla manipulacion RGB de imagenes 

using  TestImages, Colors, Images, FileIO

img = testimage("mandrill")

# Imagen roja
red = copy(img)
red_cv = channelview(red)
red_p = permuteddimsview(red_cv, (2,3,1))
red_p[:,:,2:3] .= 0

# Imagen verde
green = copy(img)
green_cv = channelview(green)
green_p = permuteddimsview(green_cv, (2,3,1))
green_p[:,:,1] .= 0
green_p[:,:,3] .= 0

# Imagen azul
blue = copy(img)
blue_cv = channelview(blue)
blue_p = permuteddimsview(blue_cv, (2,3,1))
blue_p[:,:,1:2] .= 0 

A = mosaicview(img, red, green, blue; nrow=2, rowmajor=true);


lake = testimage("lake_color");

# División vertical de la imagen
img2 = copy(lake);
img2_cv = channelview(img2);
img2_p = permuteddimsview(img2_cv, (2,3,1));

#Dividimos el tamaño de la imagen en 3
t = Int(round(m/3));
t2 = 2*t;

img2_p[:, 1:t, 2:3 ] .= 0
img2_p[:, t:t2, 1] .= 0
img2_p[:, t:t2, 3] .= 0
img2_p[:, t2:end, 1:2] .= 0

# División horizontal de la imagen

img3 = copy(lake);
img3_cv = channelview(img3);
img3_p = permuteddimsview(img3_cv, (2,3,1));

#Dividimos el tamaño de la imagen en 3
th = Int(round(n/3));
th2 = 2*t;

img3_p[1:th, :, 2:3 ] .= 0
img3_p[th:th2, :, 1] .= 0
img3_p[th:th2, :, 3] .= 0
img3_p[th2:end, :, 1:2] .= 0

BC = mosaicview(lake, img2, img3; nrow=1);
