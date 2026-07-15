// Global diagram settings =============================================
#let color_main = rgb("#f06b32")
#let color_sec = rgb("#a34922")
#let color_text = rgb("#202020")
#let color_muted = rgb("#666666")
#let color_panel = luma(248)
#let color_panel_stroke = luma(218)
#let color_page = white
#let color_block_section = luma(242)
#let color_block_grid = luma(214)
#let default_color_scheme = "ember"

#let diagram_page_width = auto
#let diagram_page_height = auto
#let diagram_margin = 24pt
#let diagram_title_size = 21pt
#let diagram_subtitle_size = 10pt
#let diagram_label_size = 7pt
#let body_text_size = 9.5pt
#let small_text_size = 8pt
#let block_title_size = 11pt
#let block_text_size = 8.2pt
#let block_code_text_size = 7.5pt

#let font_body = "Helvetica Neue"
#let font_mono = "DejaVu Sans Mono"

#let block_width = 350pt
#let side_panel_width = 190pt
#let page_content_gutter = 22pt
#let diagram_content_width = block_width + side_panel_width + page_content_gutter
#let block_radius = 3pt
#let block_cell_inset = (x: 6pt, y: 4.2pt)
#let panel_inset = 10pt
#let common_resources_dir = "../../.common_resources/"

// Manual alignment layout =============================================
#let layout_column_width = 350pt
#let layout_column_gap = 10pt
#let layout_constellation_gap = 10pt
#let layout_block_gap = 8pt
#let layout_block_column_width = layout_column_width
#let layout_block_column_gap = 18pt
#let layout_constellation_padding = 10pt
#let layout_block_padding = 0pt
#let layout_row_height = 20pt
#let layout_constellation_radius = 4pt
#let layout_block_radius = 3pt
#let layout_show_anchor_debug = false
#let layout_anchor_marker_size = 9pt
#let color_anchor_left = rgb("#1f78a8")
#let color_anchor_right = rgb("#b33f1f")
#let color_anchor_center = color_muted
#let color_link_block = rgb("#fff7d8")
#let color_link_block_stroke = rgb("#c88f13")
#let color_link_block_text = rgb("#7b5404")
#let color_link_arrow = color_link_block_stroke
#let layout_link_block_width = 78pt
#let layout_link_block_text_size = 4.8pt
#let layout_link_block_side_width = 58pt
#let layout_link_block_side_gap = 4pt
#let layout_link_block_badge_width = 34pt
#let layout_link_block_badge_height = 12pt
#let layout_link_block_code_size = 4.8pt
#let layout_link_block_arrow_width = 16pt
#let layout_link_block_arrow_gap = 2pt
#let layout_link_block_arrow_stroke = 0.65pt
#let layout_link_block_marker_width = (
  layout_link_block_badge_width + layout_link_block_arrow_gap + layout_link_block_arrow_width
)
#let layout_row_anchor_side_inset = (layout_link_block_side_width - layout_link_block_marker_width) / 2
#let layout_row_port_gap = layout_link_block_side_gap + layout_row_anchor_side_inset
#let layout_link_block_outer_port_gap = layout_row_port_gap
#let layout_link_block_outer_anchor_reserve = layout_link_block_outer_port_gap
#let layout_direct_pipe_inset = 6pt
#let layout_direct_pipe_line_width = 0.75pt
#let layout_direct_pipe_gutter = 4pt
#let layout_inner_direct_pipe_inset = layout_direct_pipe_inset
#let layout_inner_direct_pipe_gutter = layout_direct_pipe_gutter
#let color_direct_arrow = color_sec
#let layout_direct_arrow_stroke = layout_direct_pipe_line_width
#let layout_direct_arrow_corner_radius = 4pt
#let layout_direct_arrow_canvas_padding = 16pt

#let alignment_content_width(level_count, include_info: true, pipe_width: 0pt, level_widths: none) = {
  let diagram_width = if level_widths == none {
    layout_column_width * level_count
  } else {
    level_widths.sum()
  }
  if level_count > 1 {
    diagram_width += layout_column_gap * (level_count - 1)
  }
  diagram_width += pipe_width

  if include_info {
    diagram_width + layout_column_gap + side_panel_width
  } else {
    diagram_width
  }
}
