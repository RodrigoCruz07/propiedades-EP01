# language: es
Característica: Servicio Propiedades (microservicio propiedades del caso caso11)
  Los escenarios validan el contrato REST del microservicio alineado a sus endpoints.

  Escenario: el listado del recurso responde 200
    Dado el servicio "Propiedades" está disponible
    Cuando consulto el listado de "propiedads"
    Entonces el listado responde con código 200

  Escenario: ciclo de vida completo del recurso
    Dado un nuevo "propiedad" con nombre "hola-cucumber"
    Cuando consulto el "propiedad" recién creado
    Entonces el recurso tiene nombre "hola-cucumber" y código 200
    Cuando actualizo el "propiedad" con nombre "cucumber-actualizado"
    Entonces el recurso queda con nombre "cucumber-actualizado" y código 200
    Cuando elimino el "propiedad"
    Entonces la eliminación responde con código 204
    Y al consultar el "propiedad" eliminado responde 404
