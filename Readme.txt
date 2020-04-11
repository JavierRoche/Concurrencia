Dudas:
- ¿Por que no es mas limpio, despues de actualizar datos en un servidor, volver a llamar al servidor a recoger los datos actualizados, en vez de actualizar los datos solo en una tabla? ¿No podria dar alguna incongruencia con los datos que hay en el servidor? Se que lo hemos hecho asi para no complicarlo y porque el API de latestTopics vuelve a recuperar los borrados o los modificados, ¿pero es lo normal, es la forma de hacerlo? 
- Teniendo en cuenta que el API de latestTopics no recupera todos los datos de un topic, ¿seria correcto recuperar los latestTopics, luego recorrerlos con .map u otra forma, y por cada uno llamar al API singleTopic para completar datos? Como mejora, intente poner en cada celda el avatar del user que lo creo, pero me empezo a hacer cosas raras y desisti.
- ¿Por que siempre en la vista de detalle definimos como optional el objeto detalle, sea este user o topic o lo que sea? Si hemos seleccionado una celda de topic unico, y lo pasamos al init de la vista de detalle inicializando nuestro objeto optional, ¿por que tiene que ser optional si es seguro que ahi va un topic?
- Para que algunos result patern de mi App puedan recibir un error del tipo que creamos en los ejercicios y mostrar su descripcion, ErrorTypes lo he puesto que herede de Error. No se si es correcto, aunque funciona.
- ¿Donde y como se definen las constantes para todo el proyecto? ... es decir, por ejemplo si quiero definir el churro del Api-Key, o el user, o constantes numericas de toda la app, como statusCode, ya sabes cosas asi...
- He intentado hacer un diseño con colores y tal, pero no conseguia que las celas de la tabla cojan colores y al final desisti, supongo que ya iremos aprendiendo mas cosas.
- Queria saber si e


Funcionamiento:
1. Nuevo Topic: 
	- Comunicacion de creacion con vista principal por delegado
	- Gestion de desaparacion de los keyboards delegada
	- Al crear el topic queda fijado y los text se inabilitan, obligando a salir cerrando ventana
	- La tabla esta actualizada con el nuevo topic

2. Detalle de topic:
	- Si eres el usuario creador y no esta borrado ya, te dejara borrar el topic.
	- He metido la mejora de que pueda editar el titulo del topic, igualmente si eres el creador del topic y este es editable. 
	- Se obliga a salir con barra de navegacion, hayas modificado o borrado antes ... o no.

3. Categorias:
	- Se muestra la lista de categorias del servidor Discourse para Keepcoding.

4. Users:
	- La lista de usuarios se carga con algunos datos mas; principalmente lo hice para que se viese actualizado el nombre del user, una vez lo ha modificado.
	- La comunicacion se realiza por delegado, pero aun asi, aunque la tabla se queda actualizada despues de llamar a la funcion delegada, he metido una nueva llamada al API de lista de users en el viewDidAppear. Queria saber si esto es correcto o sobrecargaria mucho la app. Esta claro una de las dos cosas sobraria, lo meti para practicar principalmente, pero queria saber tambien si es correcto o no se suele hacer 
	- El detalle del topic muestra los datos requeridos, y si eres el usuario en cuestion, pues te deja modificar el nombre.
	- Igualmente se obliga a volver atras utilizando la navegacion
