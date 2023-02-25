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

img2_p[:, 1:171, 2:3 ] .= 0
img2_p[:, 172:341, 1] .= 0
img2_p[:, 172:341, 3] .= 0
img2_p[:, 342:end, 1:2] .= 0

# División horizontal de la imagen
img3 = copy(lake);
img3_cv = channelview(img3);
img3_p = permuteddimsview(img3_cv, (2,3,1));

img3_p[1:171, :, 2:3 ] .= 0
img3_p[172:341, :, 1] .= 0
img3_p[172:341, :, 3] .= 0
img3_p[342:end, :, 1:2] .= 0

BC = mosaicview(lake, img2, img3; nrow=1);

img_path = "/home/verolds/Documents/Code/IMG/images.png"
letra = load(img_path)

letra_f = copy(letra)
l_cv = channelview(letra_f)
l_p = permuteddimsview(l_cv, (2,3,1))

l_verde = copy(l_p);

# Fondo rojo y azul
l_p[:, 1:90,2:3] .= 0
l_p[:, 91:end,1:2] .= 0

# Letra verde
l_verde[20:267, 8:76,1] .= 0
l_verde[20:267, 8:76,3] .= 0

l_verde[20:72, 76:176,1] .= 0
l_verde[20:72, 76:176,3] .= 0

l_verde[115:165, 76:161,1] .= 0
l_verde[115:165, 76:161,3] .= 0

l_p[20:267, 8:76,:] = l_verde[20:267, 8:76,:];
l_p[20:72, 76:176,:] = l_verde[20:72, 76:176,:];
l_p[115:165, 76:161,:] = l_verde[115:165, 76:161,:];

D = mosaicview(letra, letra_f; nrow=1);
