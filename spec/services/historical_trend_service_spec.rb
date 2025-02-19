RSpec.describe HistoricalTrendService, type: :service do
  let(:organization) { create(:organization) }
  let(:type) { "Donation" }
  let(:service) { described_class.new(organization.id, type) }

  describe "#series" do
    let(:item1) { create(:item, organization: organization, name: "Item 1") }
    let(:item2) { create(:item, organization: organization, name: "Item 2") }
    let(:donation1) { create(:donation, organization:, issued_at: Date.current) }
    let(:donation2) { create(:donation, organization:, issued_at: 2.months.ago) }
    let!(:line_items) do
      (0..11).map do |n|
        create(:line_item, item: item1, itemizable_type: type, itemizable_id: donation1.id, quantity: 10, created_at: n.months.ago)
      end
    end
    let!(:line_item2) { create(:line_item, item: item2, itemizable_type: type, itemizable_id: donation2.id, quantity: 60, created_at: 6.months.ago) }
    let!(:line_item3) { create(:line_item, item: item2, itemizable_type: type, itemizable_id: donation2.id, quantity: 30, created_at: 3.months.ago) }

    it "returns an array of items with their monthly data" do
      expected_result = [
        {name: "Item 1", data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 120], visible: false},
        {name: "Item 2", data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 90, 0, 0], visible: false}
      ]
      expect(service.series).to eq(expected_result)
    end

    it "the last data point is the quantity for the current month" do
      item1_quantities = service.series.first[:data]
      expect(item1_quantities.last).to be(line_items.pluck(:quantity).sum)
    end
  end
end
