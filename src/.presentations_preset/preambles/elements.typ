#import "@preview/cetz:0.5.2": canvas, draw
#import "settings.typ": *

// Frame graphics =======================================================
#let header_basic() = {
  block(
    inset: 0pt,
    canvas(
      length: 5cm,
      {
        import draw: *
        // Settings ==========================================
        // Space settings
        let height = 0.2
        let height_logo = 0.3
        let width = 5.95
        let width_logo = 0.45
        let proportion = 3
        let triangles_gap = 0.5

        // Geometry settings
        let triangle_factor = 0.8 // 1 is a rectangle

        // Static operations
        let _proportion_unit = proportion / (proportion + 1)
        let _main_width = width * _proportion_unit - triangles_gap / 2
        let _sec_width = width * (1 - _proportion_unit) - triangles_gap / 2

        // Drawing ==========================================
        set-style(
          stroke: (thickness: 2pt, paint: color_main),
          fill: color_main,
        )

        // Main triangle
        line(
          (0, 0),
          (_main_width, 0),
          (_main_width * triangle_factor, -height),
          (width_logo, -height),
          (width_logo * _proportion_unit, -height_logo),
          (0, -height_logo),
          close: true,
        )

        // Secondary triangle
        line(
          (width, 0),
          (width - _sec_width, 0),
          (width - _sec_width + (_sec_width) * (1 - triangle_factor), -height_logo),
          (width, -height_logo),
          close: true,
        )
      },
    ),
  )
}

#let header_fed(company: presentation_brand) = {
  block(width: 100%)[
    #header_basic()
    #place(top)[
      #table(
        align: (
          center + horizon,
          top,
          center,
          right + top,
        ),
        columns: (60pt, 300pt, 1fr, 300pt),
        inset: (x: 10pt, y: 0pt),
        stroke: 0pt,
        [
          #v(2pt)
          #image(
            width: 100%,
            common_resources_dir + "page_format/logo_minimalistic.pdf",
          )
        ],
        text(fill: white, weight: 500, size: 20pt, [#v(7pt) #company]),
        [],
        [
          #v(5pt)
          #image(
            width: 45%,
            common_resources_dir + "page_format/soluciones_en_automatizacion.pdf",
          )
        ],
      )
    ]
  ]
}

#let footer_basic() = {
  block(
    inset: 0pt,
    canvas(
      length: 5cm,
      {
        import draw: *

        // General settings ====================
        let pol_l_height = 0.15
        let pol_l_height_autor = 0.25
        let pol_l_width_autor = 1
        let pol_r_height = 0.1
        let width = 5.95
        let proportion = 10
        let polygons_gap = 0

        // Geometry settings =====================
        let pol_l_triangle_factor = 0.9
        let pol_l_triangle_factor_autor = pol_l_triangle_factor
        let pol_r_triangle_factor = 0.6

        // Static operations =====================
        let _pol_left_proportion_unit = proportion / (proportion + 1)
        let _pol_l_width = width * _pol_left_proportion_unit - polygons_gap / 2
        let _pol_r_width = width - _pol_l_width - polygons_gap / 2

        // Drawing ===================
        set-style(
          stroke: (thickness: 2pt, paint: color_main),
          fill: color_main,
        )

        // Left polygon
        line(
          (0, 0),
          (_pol_l_width, 0),
          (_pol_l_width * pol_l_triangle_factor, pol_l_height),
          (pol_l_width_autor, pol_l_height),
          (pol_l_width_autor * pol_l_triangle_factor_autor, pol_l_height_autor),
          (0, pol_l_height_autor),
          close: true,
        )

        // Right polygon
        line(
          (width, 0),
          (width, pol_r_height),
          (width - _pol_r_width * pol_r_triangle_factor, pol_r_height),
          (width - _pol_r_width, 0),
        )
      },
    ),
  )
}

#let footer_fed(footer_title: presentation_title, author: presentation_author, role: presentation_author_role) = {
  let footer_title_content = if footer_title == none { [] } else { footer_title }

  block(width: 100%)[
    #footer_basic()
    #place(top)[
      #set text(
        fill: white,
        weight: 400,
      )
      #table(
        columns: (200pt, 1fr, 200pt),
        stroke: 0pt,
        inset: 0pt,
        align: (left + horizon, center + horizon, right + bottom),
        [
          #v(6pt)
          #h(10pt) #author \ #h(10pt) #role
        ],
        [
          #v(15pt)
          #text(size: slide_footer_title_size, [#footer_title_content])
        ],
        [
          #v(23pt)
          #context [#here().page()] #h(15pt)
        ],
      )
    ]
  ]
}

// Shared frame =========================================================
#let slide_frame(
  body,
  title: none,
  footer_title: none,
  content_inset: slide_content_inset,
  show_header: true,
  show_footer: true,
  brand: presentation_brand,
  author: presentation_author,
  role: presentation_author_role,
) = {
  let resolved_footer_title = if footer_title == none { presentation_title } else { footer_title }

  block(
    width: 100%,
    height: 100%,
    inset: 0pt,
    grid(
      columns: (1fr,),
      rows: (auto, 1fr, auto),
      gutter: 0pt,
      if show_header { header_fed(company: brand) } else { [] },
      block(width: 100%, inset: content_inset)[#body],
      if show_footer {
        footer_fed(
          footer_title: resolved_footer_title,
          author: author,
          role: role,
        )
      } else { [] },
    ),
  )
}
