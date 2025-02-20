require "csv"

class ItemExporter
  def initialize(items)
    @items = items
  end

  def export(stream)
    converter = HTMLToMarkdown.new
    columns = %w[
      size brand model serial strength power_source
      other_names quantity checkout_notice status
      location_area location_shelf
      purchase_link purchase_price myturn_item_type url
      created_at updated_at
    ]
    headers = [
      "id",
      "complete_number",
      "code",
      "number",
      "name",
      "categories",
      "description_markdown",
      "item_url",
      *columns
    ]
    stream.write(CSV.generate_line(headers))
    @items.includes(:borrow_policy, :category_nodes, :rich_text_description).in_batches(of: 100) do |items|
      items.each do |item|
        stream.write(CSV.generate_line([
          item.id,
          item.complete_number,
          item.borrow_policy.code,
          item.number,
          item.name,
          item.category_nodes.map { |cn| cn.path_names.join("//") }.sort.join("; "),
          converter.convert(item.description),
          "https://app.chicagotoollibrary.org/admin/items/#{item.id}",
          *columns.map { |c| item.send(c) }
        ]))
      end
    end
  end
end
