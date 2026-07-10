#import "preambles/page_style.typ": DiagramDocument
#import "preambles/alignment_model.typ": normalize_recipe
#import "preambles/alignment_report.typ": alignment_contract_report
#import "data/example_recipe.typ": example_recipe

#let resolved_example_recipe = normalize_recipe(example_recipe)

#DiagramDocument[
  #alignment_contract_report(resolved_example_recipe)
]
