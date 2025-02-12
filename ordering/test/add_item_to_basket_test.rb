require_relative 'test_helper'

module Ordering
  class AddItemToBasketTest < Ecommerce::InMemoryTestCase
    include TestPlumbing

    cover 'Pricing::OnAddItemToBasket*'

    test 'item is added to draft order' do
      aggregate_id = SecureRandom.uuid
      stream = "Pricing::Order$#{aggregate_id}"
      product_id = SecureRandom.uuid
      run_command(ProductCatalog::RegisterProduct.new(product_id: product_id, name: "Async Remote"))
      run_command(Pricing::SetPrice.new(product_id: product_id, price: 39))

      expected_events = [
        Pricing::ItemAddedToBasket.new(
          data: {
            order_id: aggregate_id,
            product_id: product_id
          }
        ),
        Pricing::OrderTotalValueCalculated.new(data: {order_id: aggregate_id, discounted_amount: 39, total_amount: 39})
      ]
      assert_events(
        stream,
        *expected_events
      ) do
        act(Pricing::AddItemToBasket.new(order_id: aggregate_id, product_id: product_id))
      end
    end
  end
end
