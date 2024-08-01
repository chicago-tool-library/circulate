require "test_helper"

class ValidationInspectorTest < ActiveSupport::TestCase
  class ValidationInspectorTestModel
    include ActiveModel::Model

    validates :name, presence: true
    validates :description, length: {minimum: 10, blank: false}
    validates :sku, format: /\d{3}-\d{3}/

    validates :associated, presence: true
  end

  setup do
    @inspector = ValidationInspector.new(ValidationInspectorTestModel)
  end
  test "presence validation" do
    assert @inspector.attribute_required?(:name)
  end

  test "non-blank length validation" do
    assert @inspector.attribute_required?(:description)
  end

  test "format validation" do
    assert @inspector.attribute_required?(:sku)
  end

  test "belongs_to default validation" do
    assert @inspector.attribute_required?(:associated_id)
  end
end
