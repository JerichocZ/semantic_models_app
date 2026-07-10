#import "preambles/page_style.typ": Document
#import "preambles/common_functions.typ": *
#import "preambles/layouts.typ": *

#Document([
  #slide_main_title(
    presentation_title,
    subtitle: [Template base para propuestas y reportes tecnicos],
    kicker: [Plantilla Typst],
  )

  #slide_two_cols(
    [Two cols],
    left: [
      #text(weight: 600, fill: color_main)[Columna izquierda]

      Este espacio queda listo para texto, listas, tablas pequenas o bloques de codigo.
    ],
    right: [
      #text(weight: 600, fill: color_main)[Columna derecha]

      La estructura del slide ya no depende de copiar el header y el footer en cada layout.
    ],
  )

  #slide_big_figure(
    [Big figure],
    figure: [
      #rect(
        width: 100%,
        height: 100%,
        fill: luma(245),
        stroke: (paint: color_main, thickness: 1pt),
        inset: 20pt,
      )[
        #align(center + horizon)[
          #text(size: 22pt, fill: color_sec)[Aqui va una figura grande]
        ]
      ]
    ],
    caption: [Espacio reservado para diagramas, fotos de tablero o graficas principales.],
  )

  #slide_section(
    [Arquitectura de la solucion],
    subtitle: [Un separador simple para cambiar de tema sin perder el marco de marca.],
    kicker: [Seccion 01],
  )

  #slide_bullets(
    [Agenda],
    lead: [Ideal para abrir una reunion tecnica o comercial con una ruta clara.],
    items: (
      [Contexto del proyecto],
      [Propuesta tecnica],
      [Alcance y exclusiones],
      [Cronograma y siguientes pasos],
    ),
  )

  #slide_figure_text(
    [Figure + notes],
    figure: [
      #text(size: 20pt, fill: color_sec)[Diagrama / foto]
    ],
    notes: (
      [Use este layout cuando la imagen necesita explicacion puntual.],
      [Funciona bien para topologias, tableros, pantallazos o esquemas de red.],
      [El parametro `figure_side` permite mover la figura a la derecha.],
    ),
  )

  #slide_cards(
    [Cards],
    cards: (
      ([Rapido de leer], [Cada bloque resume una idea, beneficio o modulo.]),
      ([Escalable], [El grid acepta mas tarjetas y columnas configurables.]),
      ([Ordenado], [Evita meter demasiada informacion en una sola columna.]),
    ),
  )

  #slide_metrics(
    [Metrics],
    metrics: (
      ([24/7], [Operacion], [Monitoreo continuo]),
      ([3], [Fases], [Diagnostico, despliegue y soporte]),
      ([< 1s], [Latencia], [Referencia para ejemplos de performance]),
    ),
  )

  #slide_compare(
    [Comparison],
    [Enfoque actual],
    [
      #slide_note_list((
        [Informacion dispersa entre varias diapositivas.],
        [Mas dificil comparar alternativas rapidamente.],
      ))
    ],
    [Enfoque propuesto],
    [
      #slide_note_list((
        [Dos alternativas visibles al mismo tiempo.],
        [Cierre con una recomendacion o criterio de seleccion.],
      ))
    ],
    verdict: [Uselo para decisiones, trade-offs, antes/despues o comparacion de proveedores.],
  )
])
