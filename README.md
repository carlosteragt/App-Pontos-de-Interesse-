
# lógica da localização e da distância:

### Geolocator.isLocationServiceEnabled() checa se o GPS está ligado

### Geolocator.checkPermission() checa as permissões

### Geolocator.requestPermission() requisita permissão ao usuário

### Geolocator.getCurrentPosition() pega as coordenadas atuais do dispositivo (Fica errado no Emulador mas no celular funciona)

### Geolocator.distanceBetween(lat1, lon1, lat2, lon2) calcula a distancia em metros entre a localização atual do dispositivo(lat1, lon1) e do ponto de interesse(lat2, lon2)

#### .latitude e .longitude pra mostrar a latitude e longitude

#### O POI e cadastrado manualmente podendo usar a localização atual ou inserindo uma latitude e longitude 
