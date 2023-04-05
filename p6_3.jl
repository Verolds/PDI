using ImageContrastAdjustment
using Images
using Plots
using TestImages

img_source = testimage("chelsea");
img_reference = testimage("coffee");

img_transformed = adjust_histogram(img_source, Matching(targetimg = img_reference))
imshow(mosaicview(img_source, img_reference, img_transformed; nrow = 1))

#Plotear
hist_final = [histogram(vec(c.(img)))
    for c in (red, green, blue)
    for img in [img_source, img_reference, img_transformed]
]

plot(
    hist_final...,
    layout = (3, 3),
    size = (800, 800),
    legend = false,
    title = ["IMG" "Referencia" "Histograms Matched"],
    reuse = false,
)

gui()