from PIL import Image

# Abre a imagem do logótipo
img = Image.open("assets/images/logo.png").convert("RGBA")
datas = img.getdata()

new_data = []
for item in datas:
    # Se o pixel for claro/cinzento (fundo), torna-o 100% transparente
    if item[0] > 150 and item[1] > 150 and item[2] > 150:
        new_data.append((255, 255, 255, 0))
    else:
        # Se for escuro, força a ser preto puro
        new_data.append((0, 0, 0, 255))

img.putdata(new_data)
img.save("logo_transparente.png", "PNG")
print("Imagem salva como logo_transparente.png com sucesso!")