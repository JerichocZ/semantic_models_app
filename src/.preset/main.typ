#import "preambles/page_style.typ": DiagramDocument
#import "preambles/layouts.typ": diagram_general_page
#import "data/metadata.typ": diagram_metadata
#import "data/constellations.typ": constellations
#import "data/blocks.typ": blocks
#import "data/links.typ": links
#import "data/legend.typ": legend_terms
#import "data/type_abstractions.typ": data_type_abstractions
#import "data/color_schemas.typ": custom_color_schemas

#DiagramDocument[
  #diagram_general_page(
    diagram_metadata,
    constellations: constellations,
    blocks: blocks,
    links: links,
    legend_terms: legend_terms,
    data_type_abstractions: data_type_abstractions,
    custom_color_schemas: custom_color_schemas,
  )
]
